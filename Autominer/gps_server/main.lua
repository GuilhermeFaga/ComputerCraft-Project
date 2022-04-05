rednet.open("back")
rednet.host("gps_server", "master")

local PATH = "coords/"

function main()
  print("Listening for GPS data on protocol 'gps_server'...")
  while true do
    event, senderId, message, protocol = os.pullEvent("rednet_message")
    if protocol == "gps_server" then
      
      local file = fs.open(PATH..senderId..".txt", "w")
      print("Update from "..senderId.." at "..message)
      file.writeLine(message)
      file.close()
    end
  end
end

main{...}