x, y, z = gps.locate(2)

rednet.open("right")
rednet.broadcast(x.." "..y.." "..z, "gps_server");