local Monitor = require("monitor")

local _craftingCPUs = {
    {
        capacity = 2,
        isBusy = false,
        storage = 4096
    },
    {
        capacity = 2,
        isBusy = true,
        storage = 4096
    }
}

mon = Monitor()
mon:clear()

while true do
    -- Data fetch

    local craftingCPUs = _craftingCPUs


    -- END Data fetch

    for i, CPU in pairs(craftingCPUs) do
        local status = "FREE"
        if (CPU.isBusy) then
            status = "BUSY"
        end
    
        local line = "CPU " .. i .. ": " .. status 
        mon:writeLine(line)
    end

end