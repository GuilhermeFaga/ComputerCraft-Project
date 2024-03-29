

function main(tArgs)
  if #tArgs==0 then
    error("Usage: git clone <repo>")
    error("eg. git clone autominer")
  end

  local func = tArgs[1]
  local repo = tArgs[2]

  if func == "clone" then
    clone(repo)
  end
end

function clone(repo)
  urls = {
    ["git"] = {
      {"https://raw.githubusercontent.com/GuilhermeFaga/ComputerCraft-Project/main/git.lua", "git.lua"}
    },
    ["autominer"] = {
      {"https://raw.githubusercontent.com/GuilhermeFaga/ComputerCraft-Project/main/Autominer/xray.lua", "xray.lua"},
      {"https://raw.githubusercontent.com/GuilhermeFaga/ComputerCraft-Project/main/Autominer/turtle.lua", "turtle.lua"}
    },
    ["autominer/gps_turtle"] = {
      {"https://raw.githubusercontent.com/GuilhermeFaga/ComputerCraft-Project/main/Autominer/gps_turtle/startup.lua", "startup.lua"}
    },
    ["autominer/gps_server"] = {
      {"https://raw.githubusercontent.com/GuilhermeFaga/ComputerCraft-Project/main/Autominer/gps_server/startup.lua", "startup.lua"},
      {"https://raw.githubusercontent.com/GuilhermeFaga/ComputerCraft-Project/main/Autominer/gps_server/main.lua", "main.lua"},
      {"https://raw.githubusercontent.com/GuilhermeFaga/ComputerCraft-Project/main/Autominer/gps_server/display.lua", "display.lua"},
      {"https://raw.githubusercontent.com/GuilhermeFaga/ComputerCraft-Project/main/Autominer/gps_server/monitor.lua", "monitor.lua"}
    },
    ["dashboard"] = {
      {"https://raw.githubusercontent.com/GuilhermeFaga/ComputerCraft-Project/main/Dashboard/class.lua", "class.lua"},
      {"https://raw.githubusercontent.com/GuilhermeFaga/ComputerCraft-Project/main/Dashboard/startup.lua", "startup.lua"},
      {"https://raw.githubusercontent.com/GuilhermeFaga/ComputerCraft-Project/main/Dashboard/monitor.lua", "monitor.lua"}
    }
  }

  for _, i in pairs(urls[repo]) do
    shell.run("rm", i[2])
    shell.run("wget", i[1])
  end
end

main{...}