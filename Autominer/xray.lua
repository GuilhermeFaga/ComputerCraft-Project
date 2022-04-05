-- Fork from GuitarMusashi616/XrayMiner

-- y level 14 diamond miner
-- messes with turtle library
-- now working

local turtle = require "turtle"

-- mines blocks whose names have these following strings in them
local TARGETS = {"diamond", "redstone"}
local DEFAULT_RADIUS = 8
local GEOSCAN_SLOT = 16
local FUEL_SLOT = 15
local CHEST_SLOT = 14
local GPS_SLOT = 13
local FREE_SLOT = 12

function main(tArgs)
  if #tArgs==0 then
    print("Usage: xray <dir> [dist]")
    print("eg. xray north 5")
  end

  local dir = tArgs[1]
  local x = 0
  local y = 0
  local z = 0
  local dist = tArgs[2] or 1

  turtle.reset(x,y,z,dir)
  scanArea()
  for _=1,dist do
    tunnel()
    scanArea()
  end
end

function is_target(ore_name)
  for i,target in pairs(TARGETS) do
    if ore_name:find(target) then
      return true
    end
  end
  return false
end

function tunnel()
  turtle.digUp()
  for i=1,17 do
    turtle.dig()
    turtle.forward()
    turtle.digUp()
  end
end

function checkFuel()
  if turtle.getFuelLevel() < 100 then
    turtle.useSlot(FUEL_SLOT)
    turtle.suckDown(10)
    turtle.refuel()
    turtle.storeSlot(FUEL_SLOT)
  end
end

function checkInv()
  if not (turtle.getItemCount(FREE_SLOT) == 0) then
    turtle.storeItems(CHEST_SLOT, FREE_SLOT)
  end
end

function sendLocation()
  turtle.useSlot(GPS_SLOT)
  os.sleep(2)
  turtle.storeSlot(GPS_SLOT)
end

function scanBlocks()
  local tbl = turtle.useSlot(GEOSCAN_SLOT).scan(DEFAULT_RADIUS)
  turtle.storeSlot(GEOSCAN_SLOT)
  return tbl
end

function scanArea()
  checkInv()
  local tbl = scanBlocks()
  local dir = turtle.dir
  turtle.reset(0,0,0,dir)
  for i,item in pairs(tbl) do
    if is_target(item.name) then
      turtle.goTo(item.x,item.y,item.z)
    end
  end
  turtle.goTo(0,0,0)
  turtle.turnTo(dir)
end

main{...}