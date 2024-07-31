local addonName, addon = ...

function addon.getEventVars(eventInfo)
    local timestamp = eventInfo[1] or ""
    local subEvent = eventInfo[2] or ""
    local hideCaster = eventInfo[3] or ""
    local sourceGuid = eventInfo[4] or ""
    local sourceName = eventInfo[5] or ""
    local sourceFlags = eventInfo[6] or ""
    local raidFlags = eventInfo[7] or ""
    local destGuid = eventInfo[8] or ""
    local destName = eventInfo[9] or ""
    local destFlags = eventInfo[10] or ""
    local destRaidFlags = eventInfo[11] or ""
    local spellId = eventInfo[12] or ""
    local spellName = eventInfo[13] or ""
    local spellSchool = eventInfo[14] or ""

    local sourceFriendly = sourceFlags and bit.band(sourceFlags, COMBATLOG_OBJECT_REACTION_FRIENDLY) > 0 or false
    local destFriendly = destFlags and bit.band(destFlags, COMBATLOG_OBJECT_REACTION_FRIENDLY) > 0 or nil
    
    local failedType = ""
    if subEvent == "SPELL_CAST_FAILED" then
        failedType = eventInfo[15]
    end

    local auraType = ""
    local amount = ""
    if subEvent == "SPELL_AURA_APPLIED" or
       subEvent == "SPELL_AURA_REMOVED" or
       subEvent == "SPELL_AURA_APPLIED_DOSE" or
       subEvent == "SPELL_AURA_REMOVED_DOSE" or
       subEvent == "SPELL_AURA_REFRESH" or
       subEvent == "SPELL_AURA_BROKEN" then
        auraType = eventInfo[15]
        amount = eventInfo[16]
    end

    local targetAura = false
    if subEvent == "SPELL_AURA_APPLIED_TARGET" then
        targetAura = true
        auraType = eventInfo[15]
    end

    local extraSpellId = ""
    local extraSpellName = ""
    local extraSchool = ""
    if subEvent == "SPELL_AURA_BROKEN_SPELL" or
       subEvent == "SPELL_INTERRUPT" then
        extraSpellId = eventInfo[15]
        extraSpellName = eventInfo[16]
        extraSchool = eventInfo[17]
        auraType = eventInfo[18]
    end

    local eventVars = {
        timestamp = timestamp,
        subEvent = subEvent,
        hideCaster = hideCaster,
        sourceGuid = sourceGuid,
        sourceName = sourceName,
        sourceFriendly = sourceFriendly,
        destFriendly = destFriendly,
        sourceFlags = sourceFlags,
        raidFlags = raidFlags,
        destGuid = destGuid,
        destName = destName,
        destFlags = destFlags,
        destRaidFlags = destRaidFlags,
        spellId = spellId,
        spellName = spellName,
        spellSchool = spellSchool,
        failedType = failedType,
        auraType = auraType,
        amount = amount,
        extraSpellId = extraSpellId,
        extraSpellName = extraSpellName,
        extraSchool = extraSchool,
        targetAura = targetAura
    }
    
    return eventVars
end

function addon.getSpellAttributes(event, eventType, options)
    local spellAttributes = {}

    if addon.isNullOrWhiteSpace(eventType) then return end
    if addon.profiles[addon.settings.profile][eventType] == nil then return end

    options.useDestUnit = options.useDestUnit or false
    
    if options.useExtraSpellId then
        event.spellId = event.extraSpellId
    end

    local attributes = addon.profiles[addon.settings.profile][eventType][event.spellId]
    if attributes == nil then
        -- Check to see if we might just have the wrong spell id in the profile
        if addon.debug then
            for spellId, spell in pairs(addon.profiles[addon.settings.profile][eventType]) do
                if event.spellName == spell.name and string.match(event.sourceGuid, "Player") then
                    addon.debug(tostring(eventType) .. ": " .. tostring(event.spellName) .. " (" .. tostring(event.spellId) .. ") not found in profile.")
                end
            end
        end
        return nil
    end

    if addon.ignoreSpell(attributes) then return end
    attributes = addon.cloneSpells(attributes, eventType)

    if not addon.validateSource(spellAttributes, attributes, options) then return end
    if not addon.validateSpec(spellAttributes, attributes) then return end

    spellAttributes = addon.setSpellKey(event, spellAttributes, options)
    spellAttributes = addon.setDisplayBar(event, spellAttributes, attributes, options)
    spellAttributes = addon.setSpellText(event, spellAttributes, attributes, options)
    spellAttributes = addon.setStyle(spellAttributes, attributes, options)
    spellAttributes = addon.setMiscAttributes(spellAttributes, attributes)

    addon.playSounds(event, spellAttributes, attributes, options)

    return spellAttributes
end

function addon.ignoreSpell(attributes)
    local ignore = false
    ignore = addon.isTrue(attributes.ignore)
    return ignore
end

function addon.cloneSpells(attributes, eventType)
    local cloneId = attributes.clone
    if cloneId then
        attributes = addon.profiles[addon.settings.profile][eventType][tonumber(cloneId)]
        if attributes == nil then
            print(addon.L["RCT_Error_Clone_Not_Found"] .. tostring(cloneId))
        end
    end

    return attributes
end

function addon.validateSource(spellAttributes, attributes, options)
    local sourceValid = true

    spellAttributes.source = not addon.isNullOrWhiteSpace(attributes.source) and string.lower(attributes.source) or nil
    if spellAttributes.source then
        if ((options.useDestUnit and event.destFriendly) or (not options.useDestUnit and event.sourceFriendly)) and not string.find(spellAttributes.source, "friendly") or
           ((options.useDestUnit and not event.destFriendly) or (not options.useDestUnit and not event.sourceFriendly)) and not string.find(spellAttributes.source, "hostile") then
            sourceValid = false
        end
    end

    return sourceValid
end

function addon.buildValidSpecList(spellAttributes, attributes)
    spellAttributes.enabledSpecs = attributes.enabledSpecs or ""
    spellAttributes.enabledGroups = attributes.enabledGroups or ""

    if spellAttributes.enabledGroups then
        local enabledGroups = {strsplit(",", spellAttributes.enabledGroups)}
        for key, group in pairs(enabledGroups) do
            group = string.lower(group)
            spellAttributes.enabledSpecs = not addon.isNullOrWhiteSpace(addon.specGroups[group]) and
                                           spellAttributes.enabledSpecs .. "," .. addon.specGroups[group] or
                                           spellAttributes.enabledSpecs
        end
    end

    return spellAttributes
end

function addon.validateSpec(spellAttributes, attributes)
    local specValid = false

    spellAttributes = addon.buildValidSpecList(spellAttributes, attributes)

    if not addon.isNullOrWhiteSpace(spellAttributes.enabledSpecs) then
        local enabledSpecs = {strsplit(",", spellAttributes.enabledSpecs)}

        for key, spec in pairs(enabledSpecs) do
            if string.lower(addon.settings.spec) == string.lower(spec) then
                specValid = true
            end
        end
    else
        specValid = true
    end

    return specValid
end

function addon.setSpellKey(event, spellAttributes, options)
    local guid = options.useDestUnit and event.destGuid or event.sourceGuid
    spellAttributes.spellKey = addon.getSpellKey(guid, event.spellId)

    return spellAttributes
end

function addon.setDisplayBar(event, spellAttributes, attributes, options)
    local bar = options.bar or attributes.bar or addon.settings.defaultBar
    spellAttributes.bar = ((options.useDestUnit and event.destFriendly) or
                           (not options.useDestUnit and event.sourceFriendly)) and
                            bar .. addon.settings.friendlyBarSuffix or 
                            bar .. addon.settings.hostileBarSuffix
    
    return spellAttributes
end

function addon.setSpellText(event, spellAttributes, attributes, options)
    spellAttributes.text = attributes.text
    if addon.isTrue(attributes.showUnitName) or options.showUnitName then
        spellAttributes.text = options.useDestUnit and event.destName or event.sourceName
    end

    return spellAttributes
end

function addon.setStyle(spellAttributes, attributes, options)
    spellAttributes.backdropColor = attributes.backdropColor
    spellAttributes.borderColor = attributes.borderColor
    spellAttributes.desaturate = attributes.desaturate
    spellAttributes.customSound = attributes.customSound
    spellAttributes.targetOnlyCustomSound = attributes.targetOnlyCustomSound

    local spellType = options.spellType or attributes.spellType
    local style = addon.settings.styles[spellType]
    if style ~= nil then
        spellAttributes.backdropColor = style.backdropColor
        spellAttributes.borderColor = style.borderColor
        spellAttributes.desaturate = addon.isTrue(style.desaturate)
        spellAttributes.customSound = style.customSound
        spellAttributes.targetOnlyCustomSound = addon.isTrue(style.targetOnlyCustomSound)
    end

    return spellAttributes
end

function addon.setMiscAttributes(spellAttributes, attributes)
    spellAttributes.cd = tonumber(attributes.cd)
    spellAttributes.nameplate = addon.isTrue(attributes.nameplate)
    spellAttributes.npcDuration = attributes.npcDuration ~= nil and tonumber(attributes.npcDuration) or nil
    spellAttributes.playerDuration = attributes.playerDuration ~= nil and tonumber(attributes.playerDuration) or nil

    return spellAttributes
end

function addon.playSounds(event, spellAttributes, attributes, options)
    spellAttributes.soundPriority = not addon.isNullOrWhiteSpace(attributes.soundPriority) and attributes.soundPriority or 3
    spellAttributes.soundPriority = string.lower(spellAttributes.soundPriority) == "off" and 0 or
                                    string.lower(spellAttributes.soundPriority) == "high" and 1 or
                                    string.lower(spellAttributes.soundPriority) == "medium" and 2 or
                                    string.lower(spellAttributes.soundPriority) == "low" and 3 or
                                    spellAttributes.soundPriority

    if tonumber(addon.settings.soundPriority) >= spellAttributes.soundPriority and spellAttributes.soundPriority ~= 0 then
        options.announce = options.announce == nil and true or options.announce
        spellAttributes.announce = attributes.announce    
        if spellAttributes.announce and options.announce and not event.targetAura then
            if ((options.useDestUnit and event.destFriendly) or (not options.useDestUnit and event.sourceFriendly)) and string.find(spellAttributes.announce, "friendly") or
               ((options.useDestUnit and not event.destFriendly) or (not options.useDestUnit and not event.sourceFriendly)) and string.find(spellAttributes.announce, "hostile")
                then
                    local soundFileName = event.spellName
                    if options.addAnnouncementSuffix then
                        soundFileName = soundFileName .. "-" .. options.addAnnouncementSuffix
                    end
                    addon.announceSpell(soundFileName, event.sourceFriendly, event.spellId)
            end
        end
        
        options.soundEffects = options.soundEffects == nil and true or options.soundEffects
        if spellAttributes.targetOnlyCustomSound then
            local targetGuid = UnitGUID("target")
            if options.useDestUnit and event.destGuid ~= targetGuid or
               not options.useDestUnit and event.sourceGuid ~= targetGuid then
                options.soundEffects = false
            end               
        end

        if options.soundEffects and event.destFriendly ~= false then
            if not addon.isNullOrWhiteSpace(spellAttributes.customSound) and addon.settings.soundEffects then
                addon.playCustomSound(spellAttributes.customSound)
            end
        end
    end
end

function addon.getSpellConfig(event, attributes)
    local spell = {
        key = attributes.spellKey,
        spellId = event.spellId,        
        backdropColor = attributes.backdropColor,
        borderColor = attributes.borderColor,
        desaturate = attributes.desaturate,
        text = attributes.text
    }

    return spell
end

function addon.announceSpell(spellName, isFriendly, spellId)
    if addon.isNullOrWhiteSpace(spellName) then return end

    -- Control spam
    local currentSecond = math.modf(GetTime())
    if addon.announceThrottle[currentSecond] == spellId then return else
        addon.announceThrottle[currentSecond] = spellId
    end

    for key, spellId in pairs(addon.announceThrottle) do
        if currentSecond - key > 5 then
            addon.announceThrottle[key] = nil
        end
    end

    local isFriendly = isFriendly == true and true or false
    local friendlyPath = isFriendly and "Friendly" or "Hostile"
    local fileName = spellName:gsub(" ", "-")
    local fileName = fileName:gsub(":", "")
    local fileName = fileName:gsub("\'", "")
    local fileName = fileName:gsub(",", "")
    local fileName = string.lower(fileName)
    local file = "Interface\\AddOns\\RokksCombatTracker\\Media\\Sounds\\Spells\\" .. friendlyPath .. "\\" .. fileName .. ".mp3"

    local success = PlaySoundFile(file, addon.settings.soundChannel)
    -- addon.debug("Playing " .. fileName)

    if not success then
        print(addon.L["RCT_Error_Playing_Sound"] .. tostring(file))
    end

    return
end

function addon.playCustomSound(soundfile)
    if addon.isNullOrWhiteSpace(soundfile) then return end

    local success = PlaySoundFile(soundfile, addon.settings.soundChannel)
    -- addon.debug("Playing " .. soundfile:gsub("Interface\\AddOns\\RokksCombatTracker\\Media\\Sounds\\SoundEffects\\", ""))

    if not success then
        print(addon.L["RCT_Error_Playing_Sound"] .. tostring(soundfile))
    end

    return
end

function addon.getAuraDuration(spellId, destGuid, auraType, inArena)
    local destUnitId = addon.getUnitId(inArena, destGuid)
    local auraFilter = auraType == "BUFF" and "HELPFUL" or auraType == "DEBUFF" and "HARMFUL" or ""

    if destUnitId == nil then return end
    
    local spellData = addon.getUnitAura(destUnitId, spellId, auraFilter)
    
    local duration = spellData.duration
    local expTime = spellData.expirationTime

    duration = expTime ~= nil and expTime ~= 0 and expTime - GetTime() or nil

    return duration
end

function addon.createTargetAuraEvents(auraType, sourceFlags, destFlags, destGuid, destName, timestamp, inArena)
    AuraUtil.ForEachAura("target", auraType, nil, function(...)
        local eventInfo = {}
        local spellId = select(10, ...)
        local spellName = select(1, ...)
        local spellType = auraType == "HELPFUL" and "BUFF" or "DEBUFF"

        eventInfo[1] = timestamp                    -- timestamp
        eventInfo[2] = "SPELL_AURA_APPLIED_TARGET"         -- subEvent
        eventInfo[3] = false                        -- hideCaster
        eventInfo[4] = "Unknown-00-00000000"        -- sourceGuid
        eventInfo[5] = "Unknown"                    -- sourceName
        eventInfo[6] = sourceFlags                  -- sourceFlags
        eventInfo[7] = 0                            -- raidFlags
        eventInfo[8] = destGuid                     -- destGuid
        eventInfo[9] = destName                     -- destName
        eventInfo[10] = destFlags                   -- destFlags
        eventInfo[11] = 0                           -- destRaidFlags
        eventInfo[12] = spellId                     -- spellId
        eventInfo[13] = spellName                   -- spellName
        eventInfo[14] = 0                           -- spellSchool
        eventInfo[15] = spellType                   -- auraType
        eventInfo[16] = 0                           -- amount

        addon.auraEvent(eventInfo)
    end)
end