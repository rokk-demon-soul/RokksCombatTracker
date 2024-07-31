local addonName, addon = ...

function b35904e6bb2943c5adcfc4058c8cf6b3_func()
    addon.help()
end

function table.pack(...)
    return { n = select("#", ...), ... }
end

function addon.debugVarArgs(...)
    if not addon.settings.debug then return end

    local args = table.pack(...)

    print("... {")
    for i = 1,args.n do
        print("  arg" .. i .. ": " .. tostring(v))
    end

    print("}")
end

function addon.debug(var, name)
    if type(var) == "string" then
        local output = name ~= nil and name .. ": " .. var or var
        print(output)
        return
    end
    
    local name = name ~= nil and name or nil
    if type(var) == "table" then
        local tableName = string.gsub(tostring(var), "table: ", "")
        print(tostring(name) .. " (" .. tableName .. ") {")
        for k, v in pairs(var) do
            print("  " .. tostring(k) .. ": " .. tostring(v))
        end
        print("}")
    else
        local debugString = name == nil and tostring(var) or name .. ": " .. tostring(var)
        print(debugString)
    end
end

function addon.help()
    print(" ")
    print("\124cffDB09FE------------------------------------")
    print("\124cffDB09FE" .. addon.L["RCT"])
    print("\124cffDB09FE------------------------------------")
    print("\124cffBAFF1A/rct lock \124cffFFFFFF- " .. addon.L["RCT_Command_Lock"])
    print("\124cffBAFF1A/rct unlock \124cffFFFFFF- " .. addon.L["RCT_Command_Unlock"])
    print("\124cffBAFF1A/rct reset \124cffFFFFFF- " .. addon.L["RCT_Command_Reset"])
    print("\124cffBAFF1A/rct resting \124cffFFFFFF- " .. addon.L["RCT_Command_Resting"])
    print("\124cffDB09FE------------------------------------")
end

function addon.getUnitId(inArena, destGuid)
    if inArena then
        unitId = UnitGUID("player") == destGuid and "player" or
                 UnitGUID("party1") == destGuid and "party1" or
                 UnitGUID("party2") == destGuid and "party2" or
                 UnitGUID("arena1") == destGuid and "arena1" or
                 UnitGUID("arena2") == destGuid and "arena2" or
                 UnitGUID("arena3") == destGuid and "arena3" or nil
    else
        unitId = UnitGUID("player") == destGuid and "player" or
                 UnitGUID("target") == destGuid and "target" or
                 UnitGUID("focus") == destGuid and "focus" or nil
    end

    return unitId
end

function addon.getUnitAura(unit, spell, filter)
    if filter and not filter:upper():find("FUL") then
        filter = filter.."|HELPFUL"
    end

    local i = 1
    local spellData = nil
    AuraUtil.ForEachAura(unit, filter, nil, function(name, _, _, _, _, _, _, _, _, spellId)
        if not name then return end
        if spellData == nil and spell == spellId or spell == name then
            spellData = C_UnitAuras.GetAuraDataByIndex(unit, i, filter)
        end
        i = i + 1
    end)
    return spellData
end

function addon.getSpellKey(unit, spellId)
    return unit:gsub("-", "") .. spellId
end

function addon.lock()
    addon.spellBars.lockBars()
    addon.infoFrame:Hide()
    addon.settings.locked = true
end

function addon.unlock()
    addon.spellBars.unlockBars()
    addon.infoFrame:Show()
    addon.settings.locked = false
end

function addon.enable()
    addon.unlock()
    addon.settings.enabled = true
end

function addon.disable()
    addon.lock()
    addon.settings.enabled = false
end

function addon.toggleDebug()
    addon.settings.debug = not addon.settings.debug
    local debugState = addon.settings.debug and addon.L["RCT_Debug_Enabled"] or addon.L["RCT_Debug_Disabled"]
    print(debugState)
end

function addon.toggleResting()
    addon.settings.enabledWhileResting = not addon.settings.enabledWhileResting
    local restingState = addon.settings.enabledWhileResting and addon.L["RCT_Resting_Enabled"] or addon.L["RCT_Resting_Disabled"]
    print(restingState)
end

function addon.isTrue(value)
    return value == true or value ~= nil and type(value) == "string" and string.lower(value) == "true"
end

function addon.isNullOrWhiteSpace(var)
    return var == nil or type(var) ~= "string" or strtrim(var) == ""
end

function addon.setPlayerSpec()
    local playerClassLocal, playerClassEnglish, playerClassIndex = UnitClass("player")
    local currentSpec = GetSpecialization()

    if currentSpec then
        local specId, currentSpecName = GetSpecializationInfo(currentSpec)
        local fullSpec = currentSpecName .. " " .. playerClassEnglish
        addon.settings.playerSpec = fullSpec:gsub(" ", "-")
        addon.settings.spec = addon.specs[addon.settings.playerSpec]
    else
        addon.settings.playerSpec = "UNKNOWN"
    end
end

function addon.checkDrinking()
    local inArena = IsActiveBattlefieldArena()
    if not inArena then return false end

    local checkUnits = {"player", "party1", "party2", "arena1", "arena2", "arena3"}
    for key, unit in pairs(checkUnits) do
        addon.checkUnitForDrinking(unit)
    end
end

function addon.checkUnitForDrinking(unit)
    local spellName AuraUtil.FindAuraByName("Drink", unit)
    if spellName == nil then return false end
    addon.drinking(unit)
end

function addon.drinking(unit)
    local sourceName = UnitName(unit)

    if (addon.isNullOrWhiteSpace(sourceName)) then return end

    local sourceGuid = UnitGUID(unit)
    local eventInfo = {}
    local timestamp = GetTime()
    local unitIsFriend = UnitIsFriend("player",unit)
    local sourceFlags = unitIsFriend and 1304 or 1352    

    eventInfo[1] = timestamp                    -- timestamp
    eventInfo[2] = "SPELL_CAST_SUCCESS"         -- subEvent
    eventInfo[3] = false                        -- hideCaster
    eventInfo[4] = sourceGuid                   -- sourceGuid
    eventInfo[5] = sourceName                   -- sourceName
    eventInfo[6] = sourceFlags                  -- sourceFlags
    eventInfo[7] = 0                            -- raidFlags
    eventInfo[8] = nil                          -- destGuid
    eventInfo[9] = nil                          -- destName
    eventInfo[10] = nil                         -- destFlags
    eventInfo[11] = 0                           -- destRaidFlags
    eventInfo[12] = 396920                       -- spellId
    eventInfo[13] = "Drink"                     -- spellName
    eventInfo[14] = 0                           -- spellSchool

    addon.castSuccessEvent(eventInfo)
end

function addon.round(number, decimals)
    return (("%%.%df"):format(decimals)):format(number)
end
