rednet.open("back")
rednet.host("gps_server", "master")

local PATH = "logs/"

function main()
  print("Listening for GPS data on protocol 'gps_server'...")
  while true do
    event, senderId, message, protocol = os.pullEvent("rednet_message")
    if protocol == "gps_server" then
      
      local file = fs.open(PATH..senderId..".txt", "w")
      print("Saving GPS data for sender "..senderId.."...")
      file.writeLine(message)
      file.close()
      print("Done.")
    end
  end
end

main{...}