

function main(tArgs)
  if #tArgs==0 then
    print("Usage: git clone <repo>")
    print("eg. git clone autominer")
  end

  local dir = tArgs[1]
end

function clone(repo)
  urls = {
    ["autominer"] = {
      "https://raw.githubusercontent.com/GuilhermeFaga/ComputerCraft-Project/main/Autominer/xray.lua",
      "https://raw.githubusercontent.com/GuilhermeFaga/ComputerCraft-Project/main/Autominer/turtle.lua"
    }
  }

  for _, i in pairs(urls[repo]) do
    shell.run("wget", i)
  end
end

main{...}