local addonName, addon = ...

function addon.registerEvents()
    if addon.eventFrame == nil then
        addon.eventFrame = CreateFrame("Frame", nil, UIParent)
    end
    
    addon.eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    addon.eventFrame:RegisterEvent("ADDON_LOADED")
    addon.eventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    addon.eventFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
    addon.eventFrame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
    addon.eventFrame:RegisterEvent("PVP_MATCH_ACTIVE")
    addon.eventFrame:RegisterEvent("PVP_MATCH_INACTIVE")
    addon.eventFrame:SetScript("OnEvent", addon.routeEvent)
end

function addon.routeEvent(self, event, ...)
    if addon.settings ~= nil and addon.settings.enabled == false then return end

    if event == "ADDON_LOADED" then
        local loadedAddon = select(1, ...)
        if loadedAddon == "RokksCombatTracker" then
            addon.initialize()
        end
    end

    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        if not addon.initialized then return end
        addon.onCombatLogEvent({CombatLogGetCurrentEventInfo()})
    end

    if event == "PVP_MATCH_ACTIVE" then
        if not addon.initialized then return end
        addon.checkDrinkingTimer = C_Timer.NewTicker(1, function() addon.checkDrinking() end)
    end

    if event == "PVP_MATCH_INACTIVE" then
        if not addon.initialized then return end
        if addon.checkDrinkingTimer then
            addon.checkDrinkingTimer:Cancel()
            addon.checkDrinkingTimer = nil
        end
    end
    
    if event == "PLAYER_TARGET_CHANGED" then
        if not addon.initialized then return end
        addon.targetChangedEvent(...)       
    end

    if event == "PLAYER_ENTERING_WORLD" or 
       event == "PLAYER_SPECIALIZATION_CHANGED" then
        if not addon.initialized then return end
        addon.setPlayerSpec()
    end
end

function addon.onCombatLogEvent(eventInfo)
    if IsResting() and addon.settings.enabledWhileResting == false then return end
    
    local subEvent = eventInfo[2]

    if subEvent == "SPELL_AURA_APPLIED" or
       subEvent == "SPELL_AURA_REFRESH" or
       subEvent == "SPELL_AURA_APPLIED_DOSE" or
       subEvent == "SPELL_AURA_REMOVED_DOSE"
       then
        
        addon.auraEvent(eventInfo)
    end

    if subEvent == "SPELL_AURA_REMOVED" or
       subEvent == "SPELL_AURA_BROKEN" or
       subEvent == "SPELL_AURA_BROKEN_SPELL"
    then

        addon.auraRemovedEvent(eventInfo)
 end

    if subEvent == "SPELL_CAST_START" then
        addon.castStartEvent(eventInfo)
    end

    if subEvent == "SPELL_CAST_FAILED" then
        addon.castFailedEvent(eventInfo)
    end

    if subEvent == "SPELL_INTERRUPT" then
        addon.castInterruptEvent(eventInfo)
    end
    
    if subEvent == "SPELL_CAST_SUCCESS" then
        addon.castSuccessEvent(eventInfo)
    end
end
