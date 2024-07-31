local addonName, addon = ...
addon.spellPlates = addon.spellPlates ~= nil and addon.spellPlates or {}

addon.spellPlates.eventFrame = CreateFrame("Frame", nil, UIParent)

function addon.spellPlates.eventFrame.NAME_PLATE_UNIT_ADDED(nameplateId)
    local unitGuid = UnitGUID(nameplateId);
    local inactive = addon.spellPlates.inactiveSpells[unitGuid]

    addon.spellPlates.nameplateIds[unitGuid] = nameplateId
    addon.spellPlates.unitGuids[nameplateId] = unitGuid

    if inactive and inactive.spells then
        local currentTime = GetTime()

        for spellId, spell in pairs(inactive.spells) do
            if spell.startTime + spell.duration <= currentTime then
            else
                local newDuration = spell.duration - (currentTime - spell.startTime)
                addon.spellPlates.showSpell(unitGuid, spellId, newDuration)
            end
        end

        addon.spellPlates.inactiveSpells[unitGuid] = nil
    end
end

function addon.spellPlates.eventFrame.NAME_PLATE_UNIT_REMOVED(nameplateId)
    local unitGuid = addon.spellPlates.unitGuids[nameplateId]

    addon.spellPlates.nameplateIds[unitGuid] = nil
    addon.spellPlates.unitGuids[nameplateId] = nil
end
