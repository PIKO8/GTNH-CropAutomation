-- non-linear database for storage farm

local config = require('config')
local scanner = require('scanner')
local action = require('action')
local gps = require('gps')

-- Main storage: key - slot number, value - crop or nil if empty
local storage = {}
-- Set of free slots for quick lookup
local freeSlots = {}
-- Total number of slots in the farm
local totalSlots = config.storageFarmArea or 81

-- Initialize storage with empty slots
local function initializeStorage()
    for i = 1, totalSlots do
        storage[i] = nil
        freeSlots[i] = true
    end
end

-- ======================== MAIN FUNCTIONS ========================

-- Get the entire storage
local function getStorage()
    return storage
end

-- Reset storage (clear all slots)
local function resetStorage()
    for i = 1, totalSlots do
        storage[i] = nil
        freeSlots[i] = true
    end
end

-- Add crop to specific slot
local function addToStorage(crop, slot)
    if slot < 1 or slot > totalSlots then
        error("Slot index out of bounds: " .. slot)
    end
    
    if storage[slot] ~= nil then
        error("Slot " .. slot .. " is already occupied")
    end
    
    storage[slot] = crop
    freeSlots[slot] = nil
end

-- Remove crop from slot (free the slot)
local function removeFromStorage(slot)
    if slot < 1 or slot > totalSlots then
        error("Slot index out of bounds: " .. slot)
    end
    
    if storage[slot] == nil then
        error("Slot " .. slot .. " is already empty")
    end
    
    storage[slot] = nil
    freeSlots[slot] = true
end

-- ======================== FREE SLOTS MANAGEMENT ========================

-- Get first free slot, or nil if no free slots available
local function nextStorageSlot()
    for slot = 1, totalSlots do
        if freeSlots[slot] then
            return slot
        end
    end
    return nil
end

-- Check if there are any free slots
local function hasFreeSlots()
    return next(freeSlots) ~= nil
end

-- Get count of free slots
local function countFreeSlots()
    local count = 0
    for slot = 1, totalSlots do
        if freeSlots[slot] then
            count = count + 1
        end
    end
    return count
end

-- Get all free slots as array
local function getAllFreeSlots()
    local slots = {}
    for slot = 1, totalSlots do
        if freeSlots[slot] then
            slots[#slots + 1] = slot
        end
    end
    return slots
end

-- ======================== HELPER FUNCTIONS ========================

-- Check if crop exists in storage
local function existInStorage(cropName)
    for slot = 1, totalSlots do
        if storage[slot] and storage[slot].name == cropName then
            return true, slot
        end
    end
    return false, nil
end

-- Get crop by slot number
local function getCropBySlot(slot)
    if slot < 1 or slot > totalSlots then
        error("Slot index out of bounds: " .. slot)
    end
    return storage[slot]
end

-- Check if slot is occupied
local function isSlotOccupied(slot)
    if slot < 1 or slot > totalSlots then
        error("Slot index out of bounds: " .. slot)
    end
    return storage[slot] ~= nil
end

-- ==================== STORAGE SCAN ====================

local function storageScan()
    for slot=1, config.storageFarmArea, 1 do
        os.sleep(0)

        gps.go(gps.storageSlotToPos(slot))
        local crop = scanner.scan()
        if scanner.cropAirOrEmpty(crop) and storage.isSlotOccupied(slot) then
            storage.removeFromStorage(slot)
        elseif scanner.cropNonAirOrEmpty(crop) then
            if scanner.isWeed(crop, 'storage') or crop.size >= crop.max - 1 then
                action.deweed()
                action.harvest()
                if storage.isSlotOccupied(slot) then
                    storage.removeFromStorage(slot)
                end
            end
        end
    end
end


-- Initialize storage on load
initializeStorage()

return {
    getStorage = getStorage,
    resetStorage = resetStorage,
    addToStorage = addToStorage,
    removeFromStorage = removeFromStorage,
    nextStorageSlot = nextStorageSlot,
    hasFreeSlots = hasFreeSlots,
    countFreeSlots = countFreeSlots,
    getAllFreeSlots = getAllFreeSlots,
    existInStorage = existInStorage,
    getCropBySlot = getCropBySlot,
    isSlotOccupied = isSlotOccupied,
    storageScan = storageScan,
    totalSlots = totalSlots
}