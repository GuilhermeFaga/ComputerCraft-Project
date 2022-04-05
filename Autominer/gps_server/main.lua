rednet.open("back")
rednet.host("gps_server")

local PATH = "data.txt"
function main()
  print("Listening for GPS data on protocol 'gps_server'...")
  while true do
    event, senderId, message, protocol = os.pullEvent("rednet_message")
    if protocol == "gps_server" then
      local x, y, z = split(message, " ")
      
      local file = fs.open(PATH, "r")
      local table = {}

      while true do
        local line = file.readLine()
        if not line then break end

        str = split(line, "=")
        key = str[1]
        value = str[2]
        table[key] = value
      end
      file.close()

      print("Saving GPS data for sender "..senderId.."...")
      table[senderId+""] = message

      writeTableToFile(table, PATH)
    end
  end

  function writeTableToFile(table, path)
    fs.delete(path)
    local file = fs.open(path, "w")
    for key, value in pairs(table) do
      file.writeLine(key.."="..value)
    end
  end
end

main{...}