local addonName, addon = ...

function addon.targetChangedEvent(...)
    local sourceFlags = 0
    local destFlags = UnitIsFriend("player","target") and 1304 or 1352 -- 1304 is friendly, 1352 is hostile
    local destGuid = UnitGUID("target")
    local destName = UnitName("target")
    local timestamp = GetTime()

    sourceFlags = UnitIsFriend("player","target") and 1304 or 1352 -- for buffs
    addon.createTargetAuraEvents("HELPFUL", sourceFlags, destFlags, destGuid, destName, timestamp)

    sourceFlags = UnitIsFriend("player","target") and 1352 or 1304 -- for debuffs
    addon.createTargetAuraEvents("HARMFUL", sourceFlags, destFlags, destGuid, destName, timestamp)
   
end