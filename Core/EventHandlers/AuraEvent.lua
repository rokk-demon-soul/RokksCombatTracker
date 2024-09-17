local addonName, addon = ...

function addon.auraEvent(eventInfo)
    local event = addon.getEventVars(eventInfo)
    local attributes = addon.getSpellAttributes(event, "auras", {useDestUnit=true})

    -- Exit if there are no spell attributes for this spell id
    if attributes == nil then return end
    local spell = addon.getSpellConfig(event, attributes)

    -- Duration
    local duration = addon.getAuraDuration(event.spellId, event.destGuid, event.auraType)

    local nameplatesEnabled = true    
    if addon.settings.nameplateIconsEnabledInDungeons == false and addon.state.inDungeon or addon.state.inRaid then
        nameplatesEnabled = false
    end

    if attributes.nameplate and nameplatesEnabled then
        local isNpc = strfind(string.lower(event.destGuid), "creature")
        if duration == nil then
            duration = isNpc and attributes.npcDuration or attributes.playerDuration
        elseif addon.settings.debug and not isNpc then
            -- Collect PVE/PVP CC durations
            addon.settings.ccDurations = addon.settings.ccDurations or {}
            local existingLog = addon.settings.ccDurations[event.spellId]
            local durations = existingLog and existingLog.durations or {}
            local rounded = addon.round(duration, 0)

            durations[rounded] = rounded

            addon.settings.ccDurations[event.spellId] = {
                spellName = event.spellName,
                durations = durations
            }
        end

        if duration == nil then return end

        addon.spellPlates.showSpell(event.destGuid, spell.spellId, duration)
    else
        if duration == nil then return end
        spell.duration = duration

        addon.spellBars.showSpell(attributes.bar, spell)
    end
end