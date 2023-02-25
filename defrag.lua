-- Config

local maxUsedSlotsPerCell = 55
local paddingPercent = 75

local systemDriveNames = {
	"ae2:drive_2",
	"ae2:drive_4"
}
local workspaceNames = {
	ioPort = "ae2:io_port_0",
	interface = "ae2:interface_1",
	chest = "ae2:chest_0",
	drives = {
		"ae2:drive_1",
		"ae2:drive_3"
	}
}

local capacityByName = {
	["ae2:item_storage_cell_1k"] = 1024,
	["ae2:item_storage_cell_4k"] = 4096,
	["ae2:item_storage_cell_16k"] = 16384,
	["ae2:item_storage_cell_64k"] = 65536,
	["ae2:item_storage_cell_256k"] = 262144,
	["megacells:item_storage_cell_1m"] = 1048576,
	["megacells:item_storage_cell_4m"] = 4194304,
	["megacells:item_storage_cell_16m"] = 16777216,
	["megacells:item_storage_cell_64m"] = 67108864,
	["megacells:item_storage_cell_64m"] = 268435456,
}

-- /Config

-- Util Functions

local clock = os.clock
local function sleep(n)	-- seconds
	local t0 = clock()
	while clock() - t0 <= n do end
end

local function map(array, func)
	local new_array = {}
	for i,v in pairs(array) do
		new_array[i] = func(v, i)
	end
	return new_array
end

local function values(obj)
	local result = {}
	for _, v in pairs(obj) do
		table.insert(result, v)
	end
	return result
end

local function groupBy(array, prop)
	local result = {}
	for _, element in pairs(array) do
		if element[prop] ~= nil then
			if result[element[prop]] == nil then
				result[element[prop]] = {}
			end
			table.insert(result[element[prop]], element)
		end
	end
	return result
end

-- /Util Functions

-- Peripherals

local systemDrives = map(systemDriveNames, function(driveName)
	return peripheral.wrap(driveName)
end)
local workspace = {
	ioPort = peripheral.wrap(workspaceNames.ioPort),
	interface = peripheral.wrap(workspaceNames.interface),
	chest = peripheral.wrap(workspaceNames.chest),
	drives = map(workspaceNames.drives, function(driveName)
		return peripheral.wrap(driveName)
	end)
}

-- /Peripherals

-- Classes

-- Cell

local cells = {}
local additionallyRequiredCells = {}
local Cell = {}
Cell.__index = Cell

Cell.capacities = (function()
	local capacities = values(capacityByName)
	table.sort(capacities, function(a, b) return a < b end)
	return capacities
end)()

function Cell.sortByUnusedBytesDesc(a, b)
	return b:getNumUnusedBytes() < a:getNumUnusedBytes()
end

function Cell.sortByCapacity(a, b)
	return a.capacity < b.capacity
end

function Cell.sortByCapacityDesc(a, b)
	return b.capacity < a.capacity
end

function Cell.loadAll()
	for driveNum, systemDrive in ipairs(systemDrives) do
		local systemCells = systemDrive.items()
		local toSlotNum = 1
		for _, cell in pairs(systemCells) do
			table.insert(cells, Cell.new(capacityByName[cell.name], driveNum, toSlotNum))
			toSlotNum = toSlotNum + 1
		end
	end
	table.remove(cells, #cells)
end

function Cell.new(capacity, driveNum, slotNum)
	local self = setmetatable({}, Cell)
	self.capacity = capacity
	self.driveNum = driveNum
	self.slotNum = slotNum
	self.inventory = {}
	return self
end

function Cell.getSmallestCellNeededForStack(stack)
	for _, capacity in ipairs(Cell.capacities) do
		local cell = Cell.new(capacity)
		if cell:hasSpaceFor(stack) then
			return cell
		end
	end
end

function Cell:getNumUsedBytes()
	local bytesUsed = 0
	for _, stackData in pairs(self.inventory) do
		bytesUsed = bytesUsed + self:getBytesForStack(stackData)
	end
	return bytesUsed
end

function Cell:add(stack)
	table.insert(self.inventory, stack)
	if self:getNumUsedBytes() > self.capacity then
		error("Unexpected error: inventory has exceeded capacity")
	end
end

function Cell:getBytesForStack(stack)
	return (self.capacity / 128) + math.ceil(stack.count / 8)
end

function Cell:hasSpaceFor(stack)
	local bytesUsed = self:getNumUsedBytes()
	local hasEnoughBytes = bytesUsed + self:getBytesForStack(stack) < self.capacity
	local hasEnoughSlots = self:getNumUnusedSlots() > 0
	return hasEnoughBytes and hasEnoughSlots
end

function Cell:getNumUnusedBytes()
	return self.capacity - self:getNumUsedBytes()
end

function Cell:getNumUnusedSlots()
	return maxUsedSlotsPerCell - #self.inventory
end

function Cell:clearAndPutInWorkspaceChest()
	local drive = workspace.drives[self.driveNum]
	drive.pushItem(workspaceNames.ioPort, drive.items()[self.slotNum].name, 1)
	while workspace.ioPort.items()[7] == nil do
		sleep(0.1)
	end
	workspace.ioPort.pushItem(workspaceNames.chest, drive.items()[7].name)
end

function Cell:exportInventoryToWorkspaceChest()
	for _, stack in ipairs(self.inventory) do
		stack:exportToWorkspaceChest()
	end
end

local outputDrives = {}
for _, drive in pairs(systemDrives) do
	table.insert(outputDrives, drive)
end
local currentOutputDrive = table.remove(outputDrives, 1)
function Cell:moveBackToSystem()
	currentOutputDrive.pullItem(workspaceNames.chest, currentOutputDrive.items()[2].name)
	if table.getn(#currentOutputDrive.items()) == 10 then
		currentOutputDrive = table.remove(outputDrives, 1)
	end
end

-- Stack

local stacks = {}
local Stack = {}
Stack.__index = Stack

function Stack.sortByCountDesc(a, b)
	return b.count < a.count
end

function Stack.loadAll()
	local handledItemTypes = {}
	local allItemTypes = workspace.interface.items()
	for _, itemType in pairs(allItemTypes) do
		if handledItemTypes[itemType.name] == nil then
			handledItemTypes[itemType.name] = 1
			local ccStacks = workspace.interface.findItems(itemType.name)
			for _, ccStack in pairs(ccStacks) do
				table.insert(stacks, Stack.new(ccStack))
			end
		end
	end
end

function Stack.new(ccStack)
	local self = setmetatable({}, Stack)
	self.ccStack = ccStack
	self.metadata = ccStack.getMetadata()
	self.name = self.metadata.name
	self.count = (1+paddingPercent/100)*self.metadata.count
	return self
end

function Stack:addToCellWithLargestUnusuedSpace()
	table.sort(cells, Cell.sortByUnusedBytesDesc)
	for _, cell in ipairs(cells) do
		if cell:hasSpaceFor(self) then
			cell:add(self)
			return
		end
	end
	local newCell = Cell.getSmallestCellNeededForStack(self)
	newCell:add(self)
	table.insert(cells, newCell)
	table.insert(additionallyRequiredCells, newCell)
	error("No cell found to add stack to")
end

function Stack:exportAllToWorkspaceChest()
	local amountToExport = self.metadata.count
	print("	Exporting "..amountToExport.." "..self.name.."...")
	local amountExported = 0
	while amountExported < amountToExport do
		amountExported = amountExported + self.ccStack.export(workspaceNames.chest)
	end
end

-- /Classes

-- Main

print("Scanning for cells...")
Cell.loadAll()

print("Moving cells to workspace...")
local function moveDrivesFromSystemToWorkspace()
	for driveNum, systemDrive in ipairs(systemDrives) do
		local systemCells = systemDrive.items()
		systemDrive.pushItem(workspaceNames.drives[driveNum])
		-- for fromSlotNum, _ in pairs(systemCells) do
		-- 	systemDrive.pushItem(workspaceNames.drives[driveNum], systemCells[fromSlotNum].name)
		-- end
	end
end

moveDrivesFromSystemToWorkspace()

print("Scanning for stacks...")
Stack.loadAll()

print("Planning...")
table.sort(stacks, Stack.sortByCountDesc)
for _, stack in ipairs(stacks) do
	stack:addToCellWithLargestUnusuedSpace()
end

if #additionallyRequiredCells > 0 then
	print("Needed cells:")
	local requiredCellsByCapacity = groupBy(additionallyRequiredCells, 'capacity')
	for _, capacity in ipairs(Cell.capacities) do
		if requiredCellsByCapacity[capacity] ~= nil and #requiredCellsByCapacity[capacity] > 0 then
			print("	"..#requiredCellsByCapacity[capacity].." "..(capacity/1024).."k cells")
		end
	end
	error("Add the above cells to continue")
end

print("Executing plan...")

table.sort(cells, Cell.sortByCapacity)

for _, cell in ipairs(cells) do
	print("clearing and putting in workspace...")
	cell:clearAndPutInWorkspaceChest()
	print("moving stacks to chest...")
	for _, stack in ipairs(cell.inventory) do
		stack:exportAllToWorkspaceChest()
	end
	print("moving cell back to system...")
	cell:moveBackToSystem()
end