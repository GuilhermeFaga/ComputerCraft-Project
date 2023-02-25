local class = require("class")

Monitor = class(function(monitor)
  monitor.peripheral = peripheral.find("monitor")
end)

function Monitor:jumpLine()
  local _, y = self.peripheral.getCursorPos()
  self.peripheral.setCursorPos(1, y + 1)
  self.peripheral.setTextColor(colors.white)
end

function Monitor:clear()
  self.peripheral.clear()
  self.peripheral.setCursorPos(1, 1)
end

function Monitor:writeLine(text, color)
  color = color or colors.white
  self.peripheral.setTextColor(color)
  self.peripheral.write(text)
  self:jumpLine()
end

return Monitor