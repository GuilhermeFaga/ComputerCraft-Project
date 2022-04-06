
local displayAPI = require "display"

turtles = {}
 
_headers = {
    {
        ["key"] = "id",
        ["title"] = "ID",
        ["width"] = 4
    },
    {
        ["key"] = "last_seen",
        ["title"] = "Hora",
        ["width"] = 10
    },
    {
        ["key"] = "coords",
        ["title"] = "X Y Z",
        ["width"] = 12
    }
}

function main()
  local display = displayAPI.createDisplay("top")
  
  local files = fs.list("coords")

  for _,file in pairs(files) do
    f = fs.open("coords/"..file, "r")
    line = f.readAll()
    f.close()
    
    arr = split(file, ".")
    id = arr[1]
    arr2 = split(line, ":")
    last_seen = arr2[1]
    coords = arr2[2]

    table.insert(turtles, {
      ["id"] = id,
      ["name"] = "Netherite_"..id,
      ["coords"] = coords,
      ["last_seen"] = last_seen
    })
  end

  display.renderTableArray(turtles, _headers)
end

function split (inputstr, sep)
   if sep == nil then
      sep = "%s"
   end
   local t={}
   for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
      table.insert(t, str)
   end
   return t
end

main{...}