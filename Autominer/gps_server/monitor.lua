
local displayAPI = require "display"

turtles = {}
 
_headers = {
    {
        ["key"] = "id",
        ["title"] = "ID",
        ["width"] = 5
    },
    {
        ["key"] = "desc",
        ["title"] = "Descrição",
        ["width"] = 12
    },
    {
        ["key"] = "last_seen",
        ["title"] = "Hora",
        ["width"] = 7
    },
    {
        ["key"] = "coords",
        ["title"] = "X   Y   Z",
        ["width"] = 12
    }
}

_lookup = {
  ["2"] = {
    ["desc"] = "Netherite"
  },
  ["10"] = {
    ["desc"] = "Netherite"
  }
}

function loop()
  while true do
    main()
    os.sleep(60)
  end
end

function main()
  local display = displayAPI.createDisplay("top")
  turtles = {}

  local files = fs.list("coords")

  for _,file in pairs(files) do
    f = fs.open("coords/"..file, "r")
    line = f.readAll()
    f.close()
    
    arr = split(file, ".")
    id = arr[1]
    arr2 = split(line, ":")
    last_seen = arr2[1]..":"..arr2[2]
    coords = arr2[3]

    desc = ""
    if _lookup[id] ~= nil then
      desc = _lookup[id]["desc"]
    end

    tb = {
      ["id"] = id,
      ["desc"] = desc,
      ["name"] = "_"..id,
      ["coords"] = coords,
      ["last_seen"] = last_seen
    }

    table.insert(turtles, tb)
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

loop{...}