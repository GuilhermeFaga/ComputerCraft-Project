
local display = {}

function display.createDisplay(side)
  display.peripheral = peripheral.wrap(side)
  return display
end

function display.renderTableArray(tables, headers)

  local monitor = peripheral.wrap("top")
    
  monitor.clear()

  local x = 1
  local y = 1
  monitor.setCursorPos(x,y)

  for _,header in pairs(headers) do
    monitor.write(header["title"])
    x = x + header["width"]
    monitor.setCursorPos(x,y)
  end

  for _,tb in pairs(tables) do
    x = 1
    y = y + 1
    for _,header in pairs(headers) do
      monitor.setCursorPos(x,y)
      monitor.write(tb[header["key"]])
      x = x + header["width"]
    end
  end

end

return display