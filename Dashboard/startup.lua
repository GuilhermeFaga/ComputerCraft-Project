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

    local craftingCPUs = _craftingCPUs -- peripheral.wrap("ae2:crafting_unit_0").getCraftingCPUs()


    -- END Data fetch

    for i, CPU in pairs(craftingCPUs) do
        local status = "FREE"
        local color = colors.green
        if (CPU.isBusy) then
            status = "BUSY"
            color = colors.red
        end
    
        local line = "CPU " .. i .. ": " .. status 
        mon:writeLine(line, color)
    end

    os.sleep(3)
    mon:clear()
end