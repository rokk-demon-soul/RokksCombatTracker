aura_env.rokks = aura_env.rokks ~= nil and aura_env.rokks or {}
aura_env.config = aura_env.config ~= nil and aura_env.config or {}

aura_env.rokks.eventHandler = function(...)
    local const = aura_env.rokks.const
    local enum = aura_env.rokks.enum

    local eventInfo = aura_env.rokks.getEventVars(...)
    if eventInfo == nil then return false end

    -- Clean up allstates
    aura_env.rokks.cleanAllstates(eventInfo.allstates, eventInfo.event)

    -- Check if anyone is drinking
    local inArena = IsActiveBattlefieldArena()
    aura_env.rokks.showDrinking(eventInfo.allstates, inArena)

    -- If we're changing targets, show the auras on the new target otherwise show the current spell
    if eventInfo.event == const.targetChangedEvent then
        aura_env.rokks.showTargetAuras(eventInfo.allstates, const.helpful, inArena)
        aura_env.rokks.showTargetAuras(eventInfo.allstates, const.harmful, inArena)
    else
        eventInfo.sourceFriendly = bit.band(eventInfo.sourceFlags, COMBATLOG_OBJECT_REACTION_FRIENDLY) > 0
        eventInfo.auraType = eventInfo.auraType == const.buff and enum.auraType.buff or eventInfo.auraType == const.debuff and enum.auraType.debuff or enum.auraType.unknown
        aura_env.rokks.showSpell(eventInfo.allstates, eventInfo.subEvent, eventInfo.sourceName, eventInfo.sourceGuid, eventInfo.destGuid, eventInfo.spellId, eventInfo.spellName, eventInfo.auraType, eventInfo.sourceFriendly, nil, nil, inArena)
    end

    return true
end

aura_env.rokks.getEventVars = function(...)
    local const = aura_env.rokks.const
    local enum = aura_env.rokks.enum
    local eventInfo = {}

    eventInfo.allstates = select(1, ...)
    eventInfo.event = select(2, ...)
    eventInfo.subEvent = select(4, ...)
    eventInfo.sourceGuid = select(6, ...)
    eventInfo.sourceName = select(7, ...)
    eventInfo.sourceFlags = select(8, ...)
    eventInfo.destGuid = select(10, ...)
    eventInfo.spellId = select(14, ...)
    eventInfo.spellName = select(15, ...)
    eventInfo.auraType = select(17, ...)
    
    -- Basic event and nil checks
    if (
        type(eventInfo.allstates) ~= "table" or
        eventInfo.event == nil
    ) then return nil end

    if (
        eventInfo.event == const.combatLogEvent and (
            eventInfo.subEvent == nil or
            eventInfo.sourceGuid == nil or
            eventInfo.sourceName == nil or
            eventInfo.sourceFlags == nil or
            eventInfo.spellId == nil or
            eventInfo.spellName == nil
        )
    ) then return nil end

    -- Filter subEvent
    if eventInfo.subEvent ~= const.castStart and
       eventInfo.subEvent ~= const.castSuccess and
       eventInfo.subEvent ~= const.castFailed and
       eventInfo.subEvent ~= const.auraApplied and
       eventInfo.subEvent ~= const.auraRemoved and
       eventInfo.subEvent ~= const.auraRefreshed and
       eventInfo.subEvent ~= const.addStack and
       eventInfo.subEvent ~= const.removeStack and
       eventInfo.event ~= const.targetChangedEvent then
       return nil
    end

    return eventInfo
end

aura_env.rokks.cleanAllstates = function(allstates, event)
    local const = aura_env.rokks.const
    local enum = aura_env.rokks.enum
    
    for i, state in pairs(allstates) do
        --Reset auraOn on PLAYER_TARGET_CHANGED event
        if event == const.targetChangedEvent and state.show then
            state.auraOn = state.auraOn == enum.auraOn.target and enum.auraOn.unknown or state.auraOn
            state.changed = true
        elseif not state.show then
            table.remove(allstates, i)
        end
    end
end

aura_env.rokks.showTargetAuras = function(allstates, buffType, inArena)
    local const = aura_env.rokks.const
    local enum = aura_env.rokks.enum

    AuraUtil.ForEachAura(const.target, buffType, nil, function(...)
        local auraInfo = {}

        auraInfo.spellName = select(1, ...)
        auraInfo.stacks = select(3, ...)
        auraInfo.expirationTime = select(6, ...)
        auraInfo.spellId = select(10, ...)
        auraInfo.duration = auraInfo.expirationTime - GetTime()

        local subEvent = const.auraApplied
        local destGuid = UnitGUID(const.target)
        local spellId = auraInfo.spellId
        local spellName = auraInfo.spellName
        local auraType = buffType == const.helpful and enum.auraType.buff or
                         buffType == const.harmful and enum.auraType.debuff or
                         enum.auraType.unknown
        local duration = auraInfo.duration
        local stacks = auraInfo.stacks
        
        -- if we're checking buffs and the target is friendly
        -- or if we're checking debuffs and the target is hostile
        -- then source is friendly
        local sourceFriendly = buffType == const.helpful and UnitIsFriend(const.player,const.target) or
                               buffType == const.harmful and not UnitIsFriend(const.player,const.target)

        local sourceName = const.unknownName
        local sourceGuid = const.unknownGuid        

        aura_env.rokks.showSpell(allstates, subEvent, sourceName, sourceGuid, destGuid, spellId, spellName, auraType, sourceFriendly, duration, stacks, inArena)
    end)
end

aura_env.rokks.showDrinking = function(allstates, inArena)
    local const = aura_env.rokks.const
    local enum = aura_env.rokks.enum

    if not inArena then return false end
    
    -- Throttle drinking check
    local throttled, currentTime = true, GetTime()
    throttled = aura_env.rokks.drinkingThrottleTime ~= 0 and currentTime - aura_env.rokks.drinkingThrottleTime < aura_env.rokks.drinkingThrottle or false

    if throttled then return false end

    aura_env.rokks.drinkingThrottleTime = currentTime
    aura_env.rokks.currentlyDrinking = aura_env.rokks.currentlyDrinking ~= nil and aura_env.rokks.currentlyDrinking or {}
    
    aura_env.rokks.showDrinkingByUnit(allstates, const.player, inArena)
    aura_env.rokks.showDrinkingByUnit(allstates, const.party1, inArena)
    aura_env.rokks.showDrinkingByUnit(allstates, const.party2, inArena)
    aura_env.rokks.showDrinkingByUnit(allstates, const.arena1, inArena)
    aura_env.rokks.showDrinkingByUnit(allstates, const.arena2, inArena)
    aura_env.rokks.showDrinkingByUnit(allstates, const.arena3, inArena)
end

aura_env.rokks.showDrinkingByUnit = function(allstates, unit, inArena)
    local const = aura_env.rokks.const
    local enum = aura_env.rokks.enum

    spellName, _, stacks, _, duration, expirationTime,
    source, _, _, spellId = AuraUtil.FindAuraByName(const.drinking, unit)

    if spellName == nil then
        aura_env.rokks.currentlyDrinking[unit] = false
        return false
    end

    if aura_env.rokks.currentlyDrinking[unit] then return false end

    local subEvent = const.castStart
    local destGuid = UnitGUID(unit)
    local auraType = enum.auraType.buff
    local duration = nil -- expirationTime - GetTime() -- Tracking as cast start and not aura, don't send duration
    local stacks = nil -- Tracking as cast start and not aura, don't send duration
    local sourceFriendly = UnitIsFriend(const.player, unit)

    local sourceName = UnitName(unit)
    local sourceGuid = UnitGUID(unit)    
    
    aura_env.rokks.currentlyDrinking[unit] = true
    aura_env.rokks.showSpell(allstates, subEvent, sourceName, sourceGuid, destGuid, spellId, spellName, auraType, sourceFriendly, duration, stacks, inArena)
end

aura_env.rokks.showSpell = function(allstates, subEvent, sourceName, sourceGuid, destGuid, spellId, spellName, auraType, sourceFriendly, auraDuration, auraStacks, inArena)
    local const = aura_env.rokks.const
    local enum = aura_env.rokks.enum

    -- Basic validation
    if subEvent == nil or subEvent == const.emptyString then return aura_env.rokks.exit("subEvent missing") end
    if type(allstates) ~= "table" then return aura_env.rokks.exit("Type of 'allstates' is not table") end
    if sourceGuid == nil or sourceGuid == const.emptyString then return aura_env.rokks.exit("sourceGuid missing") end
    if spellId == nil or spellId == const.emptyString then return aura_env.rokks.exit("spellId missing") end
    if spellName == nil or spellName == const.emptyString then return aura_env.rokks.exit("spellName missing") end
    if auraType == nil or auraType == const.emptyString then return aura_env.rokks.exit("auraType missing") end
    if sourceFriendly == nil or sourceFriendly == const.emptyString then return aura_env.rokks.exit("sourceFriendly missing") end
    
    local subEventType = aura_env.rokks.getSubEventType(subEvent)
    local eventType = aura_env.rokks.getEventType(subEventType, sourceGuid, spellId)

    -- Event type validation
    if eventType == enum.eventType.aura and (destGuid == nil or destGuid == const.emptyString) then return aura_env.rokks.exit("destGuid missing") end
    if eventType == enum.eventType.unknown then return aura_env.rokks.exit("Invalid subEvent") end
    
    -- Apply filters
    aura_env.rokks.showCurrentSpell = false
    aura_env.rokks.showCurrentSpell = aura_env.rokks.allowSpellByFilter(spellName, spellId, eventType)
    aura_env.rokks.showCurrentSpell = aura_env.rokks.showCurrentSpell and aura_env.rokks.allowSpellByHostility(aura_env.config.reactionFilter, sourceFriendly)

    -- If the spell was filtered go ahead and exit here
    if not aura_env.rokks.showCurrentSpell then return false end

    -- We're showing the spell, get additional spell info
    local spellCategory = aura_env.rokks.getSpellCategory(spellName)
    local ccCategory = aura_env.rokks.getSubCategory(spellName)
    local casterHostility = sourceFriendly and enum.casterHostility.friendly or enum.casterHostility.hostile
    local auraOn = eventType == enum.eventType.aura and
                   (UnitGUID(const.player) == destGuid and enum.auraOn.player or
                   UnitGUID(const.target) == destGuid and enum.auraOn.target) or
                   enum.auraOn.unknown

    -- Get auraDuration and auraStacks if we don't already have it
    auraDuration, auraStacks = aura_env.rokks.getAuraInfo(eventType, destGuid, spellId, auraType, auraDuration, auraStacks, inArena)

    -- Determine how long to show the event
    local displayDuration = 
            auraDuration ~= nil and auraDuration or -- if we have an auraDuration, use it
            subEventType == enum.subEventType.castStart and const.maxCastDuration or -- If this is cast start, use maxCastDuration so in case something goes wrong it will time out and disappear
            subEventType == enum.subEventType.auraRemoved and const.minDuration or -- If the aura is removed, then hide it
            eventType == enum.eventType.casted and const.minDuration or -- If this is casted spell and not cast start (because we already checked cast start) then the cast is over, hide it
            subEventType == enum.subEventType.castSuccess and aura_env.config.defaultDuration or -- Standard instant cast spell, show for x seconds
            const.minDuration -- By default we'll hide in case some weird situation happens

    -- Make sure we can't pass nil or 0 as the displayDuration, otherwise the aura will show indefinitely
    if displayDuration == nil or displayDuration <= 0 then displayDuration = const.minDuration end

    -- If the spell was filtered by any other process then exit
    if not aura_env.rokks.showCurrentSpell then return false end
    
    local spellInfo = {
        show = true,
        changed = true,
        progressType = const.progressTypeTimed,
        autoHide = true,
        duration = displayDuration,
        expirationTime = GetTime() + displayDuration,
        spellId = spellId,
        spellName = spellName,
        name = spellName,
        icon = GetSpellTexture(spellId),
        sourceGuid = sourceGuid ~= nil and sourceGuid or const.emptyString,
        destGuid = destGuid ~= nil and destGuid or const.emptyString,
        casterName = sourceName,
        inArena = inArena,
        stacks = auraStacks,        
        eventType = eventType,
        auraType = auraType,
        auraOn = auraOn,
        spellCategory = spellCategory,
        ccCategory = ccCategory,
        casterHostility = casterHostility
    }

    -- Compile the stack index based on event type
    local stackIndex = eventType == enum.eventType.aura and
                       destGuid:gsub(const.guidSeparator, const.emptyString) .. spellId or
                       sourceGuid:gsub(const.guidSeparator, const.emptyString) .. spellId

    -- Play the sound file if this is the first time this spell is shown or if aura is being removed
    if allstates[stackIndex] == nil or eventType == enum.eventType.aura and subEventType == enum.subEventType.auraRemoved then
        aura_env.rokks.playSound(eventType, subEventType, spellName, sourceFriendly)
    end

    allstates[stackIndex] = spellInfo
    return true
end

aura_env.rokks.getSpellCategory = function(spellName)
    return aura_env.rokks.spells[spellName] ~= nil and
           aura_env.rokks.spells[spellName].category ~= nil and
           aura_env.rokks.spells[spellName].category or
           nil
end

aura_env.rokks.getSubCategory = function(spellName)
    return aura_env.rokks.spells[spellName] ~= nil and
           aura_env.rokks.spells[spellName].subCategory ~= nil and
           aura_env.rokks.spells[spellName].subCategory or nil
end

aura_env.rokks.getSpellTag = function(spellName, tag)
    return aura_env.rokks.spells[spellName] ~= nil and aura_env.rokks.spells[spellName][tag] or false
end

aura_env.rokks.getSubEventType = function(subEvent)
    local const = aura_env.rokks.const
    local enum = aura_env.rokks.enum

    return subEvent == const.castStart and enum.subEventType.castStart or
           subEvent == const.castSuccess and enum.subEventType.castSuccess or
           subEvent == const.castFailed and enum.subEventType.castAborted or
           subEvent == const.auraApplied and enum.subEventType.auraApplied or
           subEvent == const.auraRemoved and enum.subEventType.auraRemoved or
           (subEvent == const.auraRefreshed or subEvent == const.addStack or subEvent == const.removeStack) and enum.subEventType.auraUpdated or
           false    
end

aura_env.rokks.getEventType = function(subEventType, sourceGuid, spellId)
    local const = aura_env.rokks.const
    local enum = aura_env.rokks.enum

    local eventType = subEventType == enum.subEventType.castSuccess and enum.eventType.instant or
                      (subEventType == enum.subEventType.castStart or subEventType == enum.subEventType.castAborted) and enum.eventType.casted or
                      enum.eventType.aura

    local castStartIndex = sourceGuid:gsub(const.guidSeparator, const.emptyString) .. spellId

    -- log SPELL_CAST_START in a table if it's not already there
    aura_env.rokks.castStart[castStartIndex] = aura_env.rokks.castStart[castStartIndex] or castStart

    -- if this cast was aborted then remove from the table
    if subEventType == enum.subEventType.castAborted then aura_env.rokks.castStart[castStartIndex] = false end

    -- If this is SPELL CAST SUCCESS and there is a matching index in the spell cast start table,
    -- then this is closing a previously started cast. Remove it from the table
    if subEventType == enum.subEventType.castSuccess and aura_env.rokks.castStart[castStartIndex] then
        eventType = enum.eventType.casted
        aura_env.rokks.castStart[castStartIndex] = false
    end

    return eventType
end

aura_env.rokks.getAuraInfo = function(eventType, destGuid, spellId, auraType, auraDuration, auraStacks, inArena)
    local const = aura_env.rokks.const
    local enum = aura_env.rokks.enum

    -- If we already have aura duration and stacks, or if this isn't an aura, no need to go get it
    local fetchAuraInfo = auraDuration == nil and auraStacks == nil and eventType == enum.eventType.aura

    -- If we need to get the aura info, make sure it's a unit we can track...
    -- if not, filter out this spell
    local destUnitId = fetchAuraInfo and aura_env.rokks.getUnitId(inArena, destGuid) or nil
    if fetchAuraInfo and destUnitId == nil then
        aura_env.rokks.showCurrentSpell = false
        return nil, nil
    end

    -- Go get the aura information if we need it
    if fetchAuraInfo then
        auraDuration = 0
        auraStacks = 0
        local auraFilter = auraType == enum.auraType.buff and const.helpful or
                            auraType == enum.auraType.debuff and const.harmful or
                            const.emptyString

        local _,_, waAuraStacks, _,_, expTime = WA_GetUnitAura(destUnitId, spellId, auraFilter)    
        auraStacks = waAuraStacks ~= nil and waAuraStacks or auraStacks

        auraDuration = expTime ~= nil and expTime ~= 0 and expTime - GetTime() or auraDuration
    end

    return auraDuration, auraStacks
end

aura_env.rokks.getUnitId = function(inArena, destGuid)
    local const = aura_env.rokks.const
    local enum = aura_env.rokks.enum

    if inArena then
        unitId = UnitGUID(const.player) == destGuid and const.player or
                 UnitGUID(const.party1) == destGuid and const.party1 or
                 UnitGUID(const.party2) == destGuid and const.party2 or
                 UnitGUID(const.arena1) == destGuid and const.arena1 or
                 UnitGUID(const.arena2) == destGuid and const.arena2 or
                 UnitGUID(const.arena3) == destGuid and const.arena3 or nil
    else
        unitId = UnitGUID(const.player) == destGuid and const.player or
                 UnitGUID(const.target) == destGuid and const.target or
                 UnitGUID(const.focus) == destGuid and const.focus or nil
    end

    return unitId
end

aura_env.rokks.allowSpellByFilter = function(spellName, spellId, eventType)
    local const = aura_env.rokks.const
    local enum = aura_env.rokks.enum
    spellId = tonumber(spellId)

    if aura_env.rokks.spells[spellName] == nil then return false end
    if spellId > 0 and aura_env.rokks.spells[spellName].spellId ~= nil and aura_env.rokks.spells[spellName].spellId ~= spellId then return false end
    if eventType ~= aura_env.rokks.spells[spellName].spellType then return false end

    return true
end

aura_env.rokks.allowSpellByHostility = function(reactionFilter, sourceFriendly)
    local const = aura_env.rokks.const
    local enum = aura_env.rokks.enum

    return reactionFilter == enum.reactionFilter.friendly and sourceFriendly or
           reactionFilter == enum.reactionFilter.hostile and not sourceFriendly or
           reactionFilter == enum.reactionFilter.both
           or false
end

aura_env.rokks.getIndex = function(spellName)
    local const = aura_env.rokks.const
    local enum = aura_env.rokks.enum

    spellNameStr = strtrim(tostring(spellName))
    local spellIndex = const.emptyString
        
    -- Limit max characters. Could potentially cause collisions, but better to prevent overflows since this
    -- will be used as an index. Collisions can be resolved by using spell ID rather than spell name in the
    -- spell filter list of the calling trigger
    local length = #spellNameStr > const.spellIndexLimit and const.spellIndexLimit or #spellNameStr

    -- Convert the string to bytes for use as an index. Would rather have base64 encode but didn't find that option
    for i = 1, length do
        spellIndex = spellIndex .. string.byte(spellNameStr:sub(i,i))
    end    

    return spellIndex
end

aura_env.rokks.playSound = function(eventType, subEventType, spellName, sourceFriendly)
    local const = aura_env.rokks.const
    local enum = aura_env.rokks.enum

    local playSound = false
    local playCategory = false

    local spellCategory = aura_env.rokks.getSpellCategory(spellName)
    local isTeamSpell = aura_env.rokks.getSpellTag(spellName, enum.tags.teamSpell)

     playSound = spellCategory == enum.spellCategory.offensive and aura_env.config.sounds.playOffensive >= enum.playSound.spellName or
                spellCategory == enum.spellCategory.defensive and aura_env.config.sounds.playDefensive >= enum.playSound.spellName or
                spellCategory == enum.spellCategory.immunity and aura_env.config.sounds.playImmunity >= enum.playSound.spellName or
                spellCategory == enum.spellCategory.reflect and aura_env.config.sounds.playReflect >= enum.playSound.spellName or
                spellCategory == enum.spellCategory.interrupt and aura_env.config.sounds.playInterrupt >= enum.playSound.spellName or
                spellCategory == enum.spellCategory.cc and aura_env.config.sounds.playCc >= enum.playSound.spellName or
                spellCategory == enum.spellCategory.ccPrevention and aura_env.config.sounds.playCcPrevention >= enum.playSound.spellName or
                spellCategory == enum.spellCategory.utility and aura_env.config.sounds.playUtility >= enum.playSound.spellName or
                isTeamSpell and aura_env.config.sounds.playTeamSpells >= enum.playSound.spellName or
                false

    playCategory = spellCategory == enum.spellCategory.offensive and aura_env.config.sounds.playOffensive == enum.playSound.category or
                   spellCategory == enum.spellCategory.defensive and aura_env.config.sounds.playDefensive == enum.playSound.category or
                   spellCategory == enum.spellCategory.immunity and aura_env.config.sounds.playImmunity == enum.playSound.category or
                   spellCategory == enum.spellCategory.reflect and aura_env.config.sounds.playReflect == enum.playSound.category or
                   spellCategory == enum.spellCategory.interrupt and aura_env.config.sounds.playInterrupt == enum.playSound.category or
                   spellCategory == enum.spellCategory.cc and aura_env.config.sounds.playCc == enum.playSound.category or
                   spellCategory == enum.spellCategory.ccPrevention and aura_env.config.sounds.playCcPrevention == enum.playSound.category or
                   spellCategory == enum.spellCategory.utility and aura_env.config.sounds.playUtility == enum.playSound.category or
                   isTeamSpell and aura_env.config.sounds.playTeamSpells == enum.playSound.category or
                   false

    local soundFile = aura_env.rokks.getSoundFile(eventType, subEventType, spellName, sourceFriendly, playCategory)
    -- If we don't have a sound file just exit
    if soundFile == nil then return false end

    -- If we've filtered the spell then exit
    if not playSound then return false end

    local audioChannel = aura_env.config.sounds.soundChannel == enum.soundChannel.master and const.masterChannel or
                         aura_env.config.sounds.soundChannel == enum.soundChannel.music and const.musicChannel or
                         aura_env.config.sounds.soundChannel == enum.soundChannel.sfx and const.sfxChannel or
                         aura_env.config.sounds.soundChannel == enum.soundChannel.ambience and const.ambienceChannel or
                         aura_env.config.sounds.soundChannel == enum.soundChannel.dialog and const.dialogChannel or
                         nil

    PlaySoundFile(soundFile, audioChannel)
    return soundFile, audioChannel
end

aura_env.rokks.getSoundFile = function(eventType, subEventType, spellName, sourceFriendly, playCategory)
    local const = aura_env.rokks.const
    local enum = aura_env.rokks.enum
    local spellPath = playCategory and const.spellAudioCategoryPath or const.spellAudioPath
    local soundFile = const.emptyString
    local fileName = playCategory and aura_env.rokks.getSpellCategoryName(spellName) or
                     string.lower(spellName:gsub(const.alphaNumericRegEx, const.emptyString))

    if subEventType == enum.subEventType.auraApplied or subEventType == enum.subEventType.auraRemoved or subEventType == enum.subEventType.castStart or (subEventType == enum.subEventType.castSuccess and eventType == enum.eventType.instant) then
       local hostility = sourceFriendly and const.friendly or const.hostile
       local spellDown = subEventType == enum.subEventType.auraRemoved and const.downSuffix or const.emptyString
       
       soundFile = const.baseSoundfilePath .. hostility .. spellPath .. fileName .. spellDown .. const.audioSuffix
   end

   return soundFile
end

aura_env.rokks.getSpellCategoryName = function(spellName)
    local const = aura_env.rokks.const
    local enum = aura_env.rokks.enum

    local spellCategory = aura_env.rokks.getSpellCategory(spellName)
    local ccCategory = aura_env.rokks.getSubCategory(spellName)

    local categoryName = spellCategory == enum.spellCategory.cc and enum.ccCategoryNames[ccCategory] or
                         enum.categoryNames[spellCategory]

    return categoryName
end

aura_env.rokks.exit = function(string)
    print("Error: "..tostring(string))
    return false
end

-- aura_env.rokks.indexFilters = function(filter, filterName)
--     local const = aura_env.rokks.const
--     local enum = aura_env.rokks.enum

--     -- Makes sure we only build the index once on aura init
--     if aura_env.rokks[filterName] ~= nil then return end
    
--     -- Create the spell filter table for the calling WeakAura
--     aura_env.rokks[filterName] = {}

--     -- Exit if there are no spells to add
--     if filter == nil then return false end

--     -- Parse the pipe delimited string into a table
--     local spells = {strsplit(const.listDelimiter, filter)}
    
--     -- Add spell indices to the table
--     for _, spell in pairs(spells) do
--         if spell ~= nil and strtrim(spell) ~= const.emptyString then
--             local spellIndex = aura_env.rokks.getIndex(spell)
--             aura_env.rokks[filterName][spellIndex] = true
--         end
--     end

--     return
-- end

aura_env.rokks.constants = function()
    aura_env.rokks.const = {}
    aura_env.rokks.enum = {}

    local const = aura_env.rokks.const
    local enum = aura_env.rokks.enum

    const.emptyString = ""
    const.alphaNumericRegEx = '%W'
    const.listDelimiter = "|"
    const.guidSeparator = "-"
    const.spellIndexLimit = 20

    -- const.instantSpellFilter = "instantSpellFilter"
    -- const.castStartFilter = "castStartFilter"    
    -- const.spellAuraFilter = "spellAuraFilter"

    const.maxCastDuration = 5
    const.minDuration = .001

    const.player = "player"
    const.target = "target"
    const.focus = "focus"

    const.party1 = "party1"
    const.party2 = "party2"

    const.arena1 = "arena1"
    const.arena2 = "arena2"
    const.arena3 = "arena3"

    const.helpful = "HELPFUL"
    const.harmful = "HARMFUL"

    const.buff = "BUFF"
    const.debuff = "DEBUFF"

    const.drinking = "Drink"

    const.unknownName = "Unknown"
    const.unknownGuid = "Unknown-00-00000000"

    const.progressTypeTimed = "timed"

    const.friendly = "friendly"
    const.hostile = "hostile"

    const.downSuffix = "_down"
    const.audioSuffix = ".mp3"

    const.baseSoundfilePath = "Interface\\AddOns\\RokksCombatTrackerSoundPack\\sounds\\"
    const.spellAudioPath = "\\spells\\"
    const.spellAudioCategoryPath = "\\categories\\"

    const.combatLogEvent = "COMBAT_LOG_EVENT_UNFILTERED"
    const.targetChangedEvent = "PLAYER_TARGET_CHANGED"
    const.auraApplied = "SPELL_AURA_APPLIED"
    const.auraRemoved = "SPELL_AURA_REMOVED"
    const.castStart = "SPELL_CAST_START"
    const.castSuccess = "SPELL_CAST_SUCCESS"
    const.castFailed = "SPELL_CAST_FAILED"
    const.auraRefreshed = "SPELL_AURA_REFRESH"
    const.addStack = "SPELL_AURA_APPLIED_DOSE"
    const.removeStack = "SPELL_AURA_REMOVED_DOSE"

    const.masterChannel = "Master"
    const.musicChannel = "Music"
    const.sfxChannel = "SFX"
    const.ambienceChannel = "Ambience"
    const.dialogChannel = "Dialog"

    enum.playSound = {}
    enum.playSound.disabled = 1
    enum.playSound.spellName = 2
    enum.playSound.category = 3

    enum.eventType = {}
    enum.eventType.instant = 1
    enum.eventType.casted = 2
    enum.eventType.aura = 3

    enum.subEventType = {}
    enum.subEventType.castStart = 1
    enum.subEventType.castSuccess = 2
    enum.subEventType.castAborted = 3
    enum.subEventType.auraApplied = 4
    enum.subEventType.auraRemoved = 5
    enum.subEventType.auraUpdated = 6

    enum.auraType = {}
    enum.auraType.buff = 1
    enum.auraType.debuff = 2
    enum.auraType.unknown = 3

    enum.spellCategory = {}
    enum.spellCategory.offensive = 1
    enum.spellCategory.defensive = 2
    enum.spellCategory.immunity = 3
    enum.spellCategory.reflect = 4
    enum.spellCategory.interrupt = 5
    enum.spellCategory.cc = 6
    enum.spellCategory.ccPrevention = 7
    enum.spellCategory.utility = 8
    enum.spellCategory.other = 9

    enum.ccCategories = {}
    enum.ccCategories.roots = 1
    enum.ccCategories.incapacitate = 2
    enum.ccCategories.disorient = 3
    enum.ccCategories.stun = 4
    enum.ccCategories.silence = 5
    enum.ccCategories.disarm = 6
    enum.ccCategories.other = 7

    enum.tags = {}
    enum.tags.teamSpell = "teamSpell"

    -- Spell Categories
    enum.categoryNames = {}
    enum.categoryNames[enum.spellCategory.offensive] = "offensive"
    enum.categoryNames[enum.spellCategory.defensive] = "defensive"
    enum.categoryNames[enum.spellCategory.immunity] = "immune"
    enum.categoryNames[enum.spellCategory.reflect] = "reflect"
    enum.categoryNames[enum.spellCategory.interrupt] = "interrupt"
    enum.categoryNames[enum.spellCategory.ccPrevention] = "ccprevention"
    enum.categoryNames[enum.spellCategory.utility] = "utility"
    
    -- CC Categories
    enum.ccCategoryNames = {}
    enum.ccCategoryNames[enum.ccCategories.roots] = "roots"
    enum.ccCategoryNames[enum.ccCategories.incapacitate] = "incap"
    enum.ccCategoryNames[enum.ccCategories.disorient] = "disorient"
    enum.ccCategoryNames[enum.ccCategories.stun] = "stun"
    enum.ccCategoryNames[enum.ccCategories.silence] = "silence"
    enum.ccCategoryNames[enum.ccCategories.disarm] = "disarm"

    enum.casterHostility = {}
    enum.casterHostility.friendly = 1
    enum.casterHostility.hostile = 2

    enum.reactionFilter = {}
    enum.reactionFilter.friendly = 1
    enum.reactionFilter.hostile = 2
    enum.reactionFilter.both = 3

    enum.soundChannel = {}
    enum.soundChannel.master = 1
    enum.soundChannel.music = 2
    enum.soundChannel.sfx = 3
    enum.soundChannel.ambience = 4
    enum.soundChannel.dialog = 5

    enum.auraOn = {}
    enum.auraOn.unknown = 0
    enum.auraOn.player = 1
    enum.auraOn.target = 2
end

aura_env.rokks.resetEnv = function()
    aura_env.rokks.constants()

    local const = aura_env.rokks.const
    local enum = aura_env.rokks.enum

    -- Reset envionment vars on load
    aura_env.rokks.spellFiltered = false
    -- aura_env.rokks[const.instantSpellFilter] = nil
    -- aura_env.rokks[const.castStartFilter] = nil    
    -- aura_env.rokks[const.spellAuraFilter] = nil
    aura_env.rokks.castStart = {}
    aura_env.rokks.allstates = {}
    aura_env.rokks.currentlyDrinking = {}
    aura_env.rokks.drinkingThrottle = .5 -- Throttle in seconds - drinking will not be checked more frequently than the throttle
    aura_env.rokks.drinkingThrottleTime = 0

    aura_env.rokks.spells = aura_env.rokks.getSpells()

    -- Index spell filters
    -- if aura_env.config.spellFilters ~= nil then
    --     aura_env.rokks.indexFilters(aura_env.config.spellFilters.instantSpellFilter, const.instantSpellFilter)
    --     aura_env.rokks.indexFilters(aura_env.config.spellFilters.castStartFilter, const.castStartFilter)    
    --     aura_env.rokks.indexFilters(aura_env.config.spellFilters.spellAuraFilter, const.spellAuraFilter)
    -- end
end




aura_env.rokks.getSpells = function()
    -- In order to prevent having unneeded information on the screen, there are criteria for adding spells to
    -- the list to be tracked. A spell must meet the following criteria before being added to a particular category.
    --
    -- Offensive        Povides the caster or teammate approx 20% or more increased damage via buff, debuff,
    --                    stat increase, or other
    -- Defensive        Provides the caster or a teammate approx 20% or more damage reduction to one or more
    --                    types of damage
    -- Immunity            Provides the caster or teammate immunity, immunity-like or near immunity to one or more
    --                     types of attacks
    -- Reflect            Causes the caster or teammate to reflect damage of any type back to the attacker
    -- Interrupt        Interrupts a cast
    -- CC                Causes an enemy to be CC'd with one of the CC categories listed below
    -- CC Prevention    Prevents some or all CC, silences or interrupts from being applied to the caster
    -- Utility            Provides some sort of utility to the caster

    -- By giving spells a spell type and category, the tracker is enabled to customize the way
    -- spells are displayed. Border colors change based on category, auras are tracked with a timer
    -- and notification when the aura is removed, etc.

    -- Spell Types
    -- 1 = Instant - tracks when the spell is successfully completed
    -- 2 = Cast Start - starts tracking as soon as the spell cast is started
    -- 3 = Buff/Debuff - tracks the aura applied by the spell with a timer

    -- Categories
    -- 1 = Offensive
    -- 2 = Defensive
    -- 3 = Immunity
    -- 4 = Reflect
    -- 5 = Interrupt
    -- 6 = CC
    -- 7 = CC Prevention
    -- 8 = Utility
    -- 9 = Other

    -- CC Subcategories
    -- 1 = Roots
    -- 2 = Incapacitate
    -- 3 = Disorient
    -- 4 = Stun
    -- 5 = Silence
    -- 6 = Disarm
    -- 7 = Other

    -- spellId tag
    -- Some spells are better tracked by ID than by name. This is the case when there are multiple
    -- spells with the same name, for example the Rake stun, and the Rake dot. Adding a spell ID
    -- ensures the propper spell is tracked in these cases.

    -- teamSpell tag
    -- teamSpell is a tag that marks a spell as an important team spell. Examples include Earthwall Totem,
    -- Blessing of Sacrifice and other team spells a player likely wants to be aware of. This allows a player
    -- to choose only to announce spells tagged as a team spell rather than spamming the announcements with every
    -- single offensive or defensive spell just to hear the few that are very important.

    s = {}

    -- Offensive Spells
    s["Abomination Limb"] = { spellType = 1, category = 1, spellId = 383313 }
    s["Chill Streak"] = { spellType = 1, category = 1 }
    s["Dark Transformation"] = { spellType = 1, category = 1 }
    s["Summon Gargoyle"] = { spellType = 1, category = 1 }
    s["Unholy Assault"] = { spellType = 1, category = 1 }
    s["Fel Barrage"] = { spellType = 1, category = 1 }
    s["Feral Frenzy"] = { spellType = 1, category = 1 }
    s["Fury of Elune"] = { spellType = 1, category = 1 }
    s["Breath of Eons"] = { spellType = 1, category = 1, teamSpell = true }
    s["Deep Breath"] = { spellType = 1, category = 1 }
    s["Shattering Star"] = { spellType = 1, category = 1 }
    s["Fury of the Eagle"] = { spellType = 1, category = 1 }
    s["Call of the Wild"] = { spellType = 1, category = 1 }
    s["Touch of the Magi"] = { spellType = 1, category = 1 }
    s["Invoke Xuen, the White Tiger"] = { spellType = 1, category = 1 }
    s["Fists of Fury"] = { spellType = 1, category = 1 }
    s["Storm, Earth, and Fire"] = { spellType = 1, category = 1 }
    s["Divine Toll"] = { spellType = 1, category = 1 }
    s["Psyfiend"] = { spellType = 1, category = 1 }
    s["Phantom Singularity"] = { spellType = 1, category = 1 }
    s["Deathmark"] = { spellType = 1, category = 1 }
    s["Secret Technique"] = { spellType = 1, category = 1, spellId = 280719 }
    s["Shiv"] = { spellType = 1, category = 1 }
    s["Echoing Shock"] = { spellType = 1, category = 1 }
    s["Skyfury Totem"] = { spellType = 1, category = 1 }
    s["Primordial Wave"] = { spellType = 1, category = 1 }
    s["Fel Obelisk"] = { spellType = 1, category = 1 }
    s["Summon Darkglare"] = { spellType = 1, category = 1 }
    s["Summon Demonic Tyrant"] = { spellType = 1, category = 1 }
    s["Summon Infernal"] = { spellType = 1, category = 1 }
    s["Summon Observer"] = { spellType = 1, category = 1 }
    s["Sharpen Blade"] = { spellType = 1, category = 1 }
    s["Spear of Bastion"] = { spellType = 1, category = 1 }
    s["War Banner"] = { spellType = 1, category = 1 }

    s["The Hunt"] = { spellType = 2, category = 1 }
    s["Sniper Shot"] = { spellType = 2, category = 1 }
    s["Aimed Shot"] = { spellType = 2, category = 1 }
    s["Arcane Surge"] = { spellType = 2, category = 1 }
    s["Greater Pyroblast"] = { spellType = 2, category = 1 }
    s["Mindgames"] = { spellType = 2, category = 1 }
    s["Chaos Bolt"] = { spellType = 2, category = 1 }
    s["Soul Rot"] = { spellType = 2, category = 1 }
    s["Arcanosphere"] = { spellType = 2, category = 1 }

    s["Ghoulish Frenzy"] = { spellType = 3, category = 1 }
    s["Pillar of Frost"] = { spellType = 3, category = 1 }
    s["Remorseless Winter"] = { spellType = 3, category = 1 }
    s["Empower Rune Weapon"] = { spellType = 3, category = 1 }
    s["Demon Soul"] = { spellType = 3, category = 1 }
    s["Metamorphosis"] = { spellType = 3, category = 1 }
    s["Berserk"] = { spellType = 3, category = 1 }
    s["Celestial Alignment"] = { spellType = 3, category = 1 }
    s["Incarnation: Avatar of Ashamane"] = { spellType = 3, category = 1 }
    s["Incarnation: Chosen of Elune"] = { spellType = 3, category = 1 }
    s["Dragonrage"] = { spellType = 3, category = 1 }
    s["Tip the Scales"] = { spellType = 3, category = 1 }
    s["Bestial Wrath"] = { spellType = 3, category = 1 }
    s["Coordinated Assault"] = { spellType = 3, category = 1 }
    s["Trueshot"] = { spellType = 3, category = 1 }
    s["Combustion"] = { spellType = 3, category = 1 }
    s["Icy Veins"] = { spellType = 3, category = 1 }
    s["Serenity"] = { spellType = 3, category = 1 }
    s["Avenging Wrath"] = { spellType = 3, category = 1 }
    s["Final Reckoning"] = { spellType = 3, category = 1 }
    s["Dark Archangel"] = { spellType = 3, category = 1 }
    s["Power Infusion"] = { spellType = 3, category = 1, teamSpell = true }
    s["Voidform"] = { spellType = 3, category = 1 }
    s["Adrenaline Rush"] = { spellType = 3, category = 1 }
    s["Echoing Reprimand"] = { spellType = 3, category = 1 }
    s["Shadow Blades"] = { spellType = 3, category = 1 }
    s["Ascendance"] = { spellType = 3, category = 1 }
    s["Feral Spirit"] = { spellType = 3, category = 1 }
    s["Stormkeeper"] = { spellType = 3, category = 1 }
    s["Dark Soul: Misery"] = { spellType = 3, category = 1 }
    s["Avatar"] = { spellType = 3, category = 1 }
    s["Bladestorm"] = { spellType = 3, category = 1 }
    s["Death Wish"] = { spellType = 3, category = 1 }
    s["Recklessness"] = { spellType = 3, category = 1 }

    -- Defensive Spells
    s["Healing Tide Totem"] = { spellType = 1, category = 2, teamSpell = true }
    s["Earthen Wall Totem"] = { spellType = 1, category = 2, teamSpell = true }
    s["Spirit Link Totem"] = { spellType = 1, category = 2, teamSpell = true }
    s["Rapture"] = { spellType = 1, category = 2, teamSpell = true }
    s["Restitution"] = { spellType = 1, category = 2 }
    s["Power Word: Barrier"] = { spellType = 1, category = 2, teamSpell = true }
    s["Void Shift"] = { spellType = 1, category = 2, teamSpell = true }
    s["Gladiator's Medallion"] = { spellType = 1, category = 2, teamSpell = true }
    s["Phase Shift"] = { spellType = 1, category = 2 }

    s["Drain Life"] = { spellType = 2, category = 2 }

    s["Anti-Magic Shell"] = { spellType = 3, category = 2 }
    s["Death Pact"] = { spellType = 3, category = 2 }
    s["Icebound Fortitude"] = { spellType = 3, category = 2 }
    s["Blur"] = { spellType = 3, category = 2 }
    s["Darkness"] = { spellType = 3, category = 2, teamSpell = true }
    s["Netherwalk"] = { spellType = 3, category = 2 }
    s["Nether Bond"] = { spellType = 3, category = 2 }
    s["Rain from Above"] = { spellType = 3, category = 2 }
    s["Barkskin"] = { spellType = 3, category = 2 }
    s["Cenarion Ward"] = { spellType = 3, category = 2 }
    s["Ironbark"] = { spellType = 3, category = 2, teamSpell = true }
    s["Survival Instincts"] = { spellType = 3, category = 2 }
    s["Obsidian Scales"] = { spellType = 3, category = 2 }
    s["Renewing Blaze"] = { spellType = 3, category = 2 }
    s["Time Stop"] = { spellType = 3, category = 2, teamSpell = true }
    s["Fortitude of the Bear"] = { spellType = 3, category = 2 }
    s["Interlope"] = { spellType = 3, category = 2, teamSpell = true }
    s["Roar of Sacrifice"] = { spellType = 3, category = 2, teamSpell = true }
    s["Survival of the Fittest"] = { spellType = 3, category = 2 }
    s["Dampen Harm"] = { spellType = 3, category = 2 }
    s["Diffuse Magic"] = { spellType = 3, category = 2 }
    s["Fortifying Brew"] = { spellType = 3, category = 2 }
    s["Ardent Defender"] = { spellType = 3, category = 2 }
    s["Blessing of Sacrifice"] = { spellType = 3, category = 2, teamSpell = true }
    s["Guardian of Ancient Kings"] = { spellType = 3, category = 2 }
    s["Guardian Spirit"] = { spellType = 3, category = 2, teamSpell = true }
    s["Pain Suppression"] = { spellType = 3, category = 2, teamSpell = true }
    s["Ray of Hope"] = { spellType = 3, category = 2, teamSpell = true }
    s["Cloak of Shadows"] = { spellType = 3, category = 2 }
    s["Astral Shift"] = { spellType = 3, category = 2 }
    s["Burrow"] = { spellType = 3, category = 3 }
    s["Dark Pact"] = { spellType = 3, category = 2 }
    s["Unending Resolve"] = { spellType = 3, category = 2 }
    s["Enraged Regeneration"] = { spellType = 3, category = 2 }
    s["Ignore Pain"] = { spellType = 3, category = 2 }
    s["Last Stand"] = { spellType = 3, category = 2 }
    s["Rallying Cry"] = { spellType = 3, category = 2, teamSpell = true }
    s["Shield Wall"] = { spellType = 3, category = 2 }
    s["Spirit of Redemption"] = { spellType = 3, category = 2, teamSpell = true }

    -- Immunity
    s["Glimpse"] = { spellType = 3, category = 3 }
    s["Tranquility"] = { spellType = 3, category = 3 }
    s["Aspect of the Turtle"] = { spellType = 3, category = 3 }
    s["Survival Tactics"] = { spellType = 3, category = 3 }
    s["Alter Time"] = { spellType = 3, category = 3 }
    s["Ice Block"] = { spellType = 3, category = 3 }
    s["Life Cocoon"] = { spellType = 3, category = 3, teamSpell = true }
    s["Blessing of Protection"] = { spellType = 3, category = 3, teamSpell = true }
    s["Divine Shield"] = { spellType = 3, category = 3 }
    s["Dispersion"] = { spellType = 3, category = 3 }
    s["Riposte"] = { spellType = 3, category = 3 }
    s["Evasion"] = { spellType = 3, category = 3 }
    s["Ethereal Form"] = { spellType = 3, category = 3 }
    s["Die by the Sword"] = { spellType = 3, category = 3 }

    -- Reflect
    s["Rage of the Sleeper"] = { spellType = 3, category = 4 }
    s["Thorns"] = { spellType = 3, category = 4, teamSpell = true }
    s["Touch of Karma"] = { spellType = 3, category = 4 }
    s["Shield of Vengeance"] = { spellType = 3, category = 4 }
    s["Spell Reflection"] = { spellType = 3, category = 4 }
    s["Blistering Scales"] = { spellType = 3, category = 4 }

    -- Interrupt
    s["Mind Freeze"] = { spellType = 1, category = 5 }
    s["Disrupt"] = { spellType = 1, category = 5 }
    s["Skull Bash"] = { spellType = 1, category = 5 }
    s["Quell"] = { spellType = 1, category = 5 }
    s["Counter Shot"] = { spellType = 1, category = 5 }
    s["Counterspell"] = { spellType = 1, category = 5 }
    s["Rebuke"] = { spellType = 1, category = 5 }
    s["Kick"] = { spellType = 1, category = 5 }
    s["Wind Shear"] = { spellType = 1, category = 5 }
    s["Spell Lock"] = { spellType = 1, category = 5 }
    s["Pummel"] = { spellType = 1, category = 5 }

    -- CC
        -- Roots
        s["Steel Trap"] = { spellType = 3, category = 6, subCategory = 1, spellId = 162480 }
        s["Chains of Ice"] = { spellType = 3, category = 6, subCategory = 1 }
        s["Earthgrab Totem"] = { spellType = 3, category = 6, subCategory = 1 }
        s["Entangling Roots"] = { spellType = 3, category = 6, subCategory = 1 }
        s["Entrapment"] = { spellType = 3, category = 6, subCategory = 1 }
        s["Freeze"] = { spellType = 3, category = 6, subCategory = 1 }
        s["Frost Nova"] = { spellType = 3, category = 6, subCategory = 1 }
        s["Ice Nova"] = { spellType = 3, category = 6, subCategory = 1 }
        s["Landslide"] = { spellType = 3, category = 6, subCategory = 1 }
        s["Mass Entanglement"] = { spellType = 3, category = 6, subCategory = 1 }
        s["Nature's Grasp"] = { spellType = 3, category = 6, subCategory = 1 }
        s["Tracker's Net"] = { spellType = 3, category = 6, subCategory = 1 }
        
        -- Incapacitate
        s["Detainment"] = { spellType = 3, category = 6, subCategory = 2 }
        s["Freezing Trap"] = { spellType = 3, category = 6, subCategory = 2 }
        s["Gouge"] = { spellType = 3, category = 6, subCategory = 2 }
        s["Hibernate"] = { spellType = 3, category = 6, subCategory = 2 }
        s["Holy Word: Chastise"] = { spellType = 3, category = 6, subCategory = 2 }
        s["Imprison"] = { spellType = 3, category = 6, subCategory = 2 }
        s["Incapacitating Roar"] = { spellType = 3, category = 6, subCategory = 2 }
        s["Mortal Coil"] = { spellType = 3, category = 6, subCategory = 2 }
        s["Paralysis"] = { spellType = 3, category = 6, subCategory = 2 }
        s["Quaking Palm"] = { spellType = 3, category = 6, subCategory = 2 }
        s["Sap"] = { spellType = 3, category = 6, subCategory = 2 }
        s["Scatter Shot"] = { spellType = 3, category = 6, subCategory = 2 }
        s["Shackle Undead"] = { spellType = 3, category = 6, subCategory = 2 }
        s["Hex"] = { spellType = 4, category = 6, subCategory = 2 }
        s["Polymorph"] = { spellType = 4, category = 6, subCategory = 2 }
        s["Repentance"] = { spellType = 4, category = 6, subCategory = 2 }
        s["Ring of Frost"] = { spellType = 4, category = 6, subCategory = 2 }
        
        -- Disorient
        s["Blind"] = { spellType = 3, category = 6, subCategory = 3 }
        s["Blinding Light"] = { spellType = 3, category = 6, subCategory = 3 }
        s["Blinding Sleet"] = { spellType = 3, category = 6, subCategory = 3 }
        s["Dragon's Breath"] = { spellType = 3, category = 6, subCategory = 3 }
        s["Intimidating Shout"] = { spellType = 3, category = 6, subCategory = 3 }
        s["Psychic Scream"] = { spellType = 3, category = 6, subCategory = 3 }
        s["Seduction"] = { spellType = 3, category = 6, subCategory = 3 }
        s["Sigil of Misery"] = { spellType = 3, category = 6, subCategory = 3 }
        s["Cyclone"] = { spellType = 4, category = 6, subCategory = 3 }
        s["Fear"] = { spellType = 4, category = 6, subCategory = 3 }
        s["Mind Control"] = { spellType = 4, category = 6, subCategory = 3 }
        s["Sleep Walk"] = { spellType = 4, category = 6, subCategory = 3 }
        s["Song of Chi-Ji"] = { spellType = 4, category = 6, subCategory = 3 }
        s["Scare Beast"] = { spellType = 4, category = 6, subCategory = 3 }
        
        -- Stun
        s["Rake"] = { spellType = 3, category = 6, subCategory = 4, spellId = 163505 }
        s["Axe Toss"] = { spellType = 3, category = 6, subCategory = 4 }
        s["Capicator Totem"] = { spellType = 3, category = 6, subCategory = 4 }
        s["Chaos Nova"] = { spellType = 3, category = 6, subCategory = 4 }
        s["Cheap Shot"] = { spellType = 3, category = 6, subCategory = 4 }
        s["Fel Eruption"] = { spellType = 3, category = 6, subCategory = 4 }
        s["Gnaw"] = { spellType = 3, category = 6, subCategory = 4 }
        s["Hammer of Justice"] = { spellType = 3, category = 6, subCategory = 4 }
        s["Haymaker"] = { spellType = 3, category = 6, subCategory = 4 }
        s["Intimidation"] = { spellType = 3, category = 6, subCategory = 4 }
        s["Kidney Shot"] = { spellType = 3, category = 6, subCategory = 4 }
        s["Leg Sweep"] = { spellType = 3, category = 6, subCategory = 4 }
        s["Lightning Lasso"] = { spellType = 3, category = 6, subCategory = 4 }
        s["Maim"] = { spellType = 3, category = 6, subCategory = 4 }
        s["Mighty Bash"] = { spellType = 3, category = 6, subCategory = 4 }
        s["Psychic Horror"] = { spellType = 3, category = 6, subCategory = 4 }
        s["Shockwave"] = { spellType = 3, category = 6, subCategory = 4 }
        s["Storm Bolt"] = { spellType = 3, category = 6, subCategory = 4 }
        s["War Stomp"] = { spellType = 3, category = 6, subCategory = 4 }        
        s["Shadowfury"] = { spellType = 4, category = 6, subCategory = 4 }
        
        -- Silence
        s["Garrote"] = { spellType = 3, category = 6, subCategory = 5 }
        s["Sigil of Silence"] = { spellType = 3, category = 6, subCategory = 5 }
        s["Silence"] = { spellType = 3, category = 6, subCategory = 5 }
        s["Solar Beam"] = { spellType = 3, category = 6, subCategory = 5 }
        s["Spider Venom"] = { spellType = 3, category = 6, subCategory = 5 }
        
        -- Disarm
        s["Disarm"] = { spellType = 3, category = 6, subCategory = 6 }
        s["Dismantle"] = { spellType = 3, category = 6, subCategory = 6 }
        s["Faerie Swarm"] = { spellType = 3, category = 6, subCategory = 6 }
        s["Grapple Weapon"] = { spellType = 3, category = 6, subCategory = 6 }
        s["Sticky Tar Bomb"] = { spellType = 3, category = 6, subCategory = 6 }

    -- CC Prevention
    s["Lichborne"] = { spellType = 3, category = 7 }
    s["Nullifying Shroud"] = { spellType = 3, category = 7 }
    s["Zen Focus Tea"] = { spellType = 3, category = 7 }
    s["Holy Ward"] = { spellType = 3, category = 7, teamSpell = true }
    s["Grounding Totem"] = { spellType = 3, category = 7, teamSpell = true }
    s["Nether Ward"] = { spellType = 3, category = 7 }

    -- Utility
    s["Demonic Circle"] = { spellType = 1, category = 8 }
    s["Demonic Circle: Teleport"] = { spellType = 1, category = 8, teamSpell = true }
    s["Displacement"] = { spellType = 1, category = 8 }
    s["Spellsteal"] = { spellType = 1, category = 8 }
    s["Transcendence"] = { spellType = 1, category = 8 }
    s["Transcendence: Transfer"] = { spellType = 1, category = 8, teamSpell = true }
    s["Vanish"] = { spellType = 1, category = 8 }
    s["Shadow Word: Death"] = { spellType = 1, category = 8 }    
    s["Drink"] = { spellType = 2, category = 8, teamSpell = true }
    s["Mass Dispel"] = { spellType = 2, category = 8, teamSpell = true }
    s["Shattering Throw"] = { spellType = 2, category = 8, teamSpell = true }
    s["Time Skip"] = { spellType = 2, category = 8 }    
    s["Spectral Sight"] = { spellType = 3, category = 8 }
    s["Time Spiral"] = { spellType = 3, category = 8 }
    s["Shadowy Duel"] = { spellType = 3, category = 8 }
    s["Camouflage"] = { spellType = 3, category = 8 }
    s["Greater Invisibility"] = { spellType = 3, category = 8 }
    s["Invisibility"] = { spellType = 3, category = 8 }
    s["Mass Invisibility"] = { spellType = 3, category = 8, teamSpell = true }
    s["Prowl"] = { spellType = 3, category = 8 }
    s["Shadowmeld"] = { spellType = 3, category = 8 }
    s["Stealth"] = { spellType = 3, category = 8 }
    s["Blessing of Freedom"] = { spellType = 3, category = 8, teamSpell = true }
    s["Master's Call"] = { spellType = 3, category = 8, teamSpell = true, spellId = 54216 }

    return s
end

aura_env.rokks.resetEnv()