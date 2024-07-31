local addonName, addon = ...

function addon.spellPlates.registerEvents()
    addon.spellPlates.eventFrame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
    addon.spellPlates.eventFrame:RegisterEvent("NAME_PLATE_UNIT_REMOVED")

    addon.spellPlates.eventFrame:SetScript("OnEvent", function(self, event, ...) if self then self[event](...) end end)
end