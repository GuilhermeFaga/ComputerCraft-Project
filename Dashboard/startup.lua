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

local _energy = 1808686.2530807
local _energyCapacity = 1808800
local _energyDemand = 114.03086


mon = Monitor()
mon:clear()

while true do
    -- Data fetch

    -- local craftingUnit = peripheral.wrap("ae2:crafting_unit_0").getCraftingCPUs()
    local craftingCPUs = _craftingCPUs -- craftingUnit.getCraftingCPUs()
    local energy = _energy -- craftingUnit.getEnergy()
    local energyCapacity = _energyCapacity -- craftingUnit.getEnergyCapacity()
    local energyDemand = _energyDemand -- craftingUnit.getAverageEnergyDemand()

    -- END Data fetch

    mon:writeLine("Energy Capacity")
    local energyPercentage = energyCapacity/energy
    mon:writeLine(math.floor(energyPercentage*100) .. "% - " .. math.floor(energy) .. "/" .. math.floor(energyCapacity) .. " AE", colors.yellow)
    mon:writeLine("")

    mon:writeLine("Energy Consumption")
    mon:writeLine(math.floor(energyDemand) .. " AE/t", colors.yellow)
    mon:writeLine("")

    mon:writeLine("Crafting CPUs")
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