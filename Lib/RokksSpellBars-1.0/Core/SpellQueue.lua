local addonName, addon = ...
addon.spellBars = addon.spellBars ~= nil and addon.spellBars or {}

function addon.spellBars.addSpellToQueue(bar, spell)
	local settings = addon.spellBars.getSettings(bar)
	local index = #bar.spellQueue + 1
	
	if spell.key == nil or
	   type(spell.key) ~= "string" or
	   spell.spellId == nil or
	   spell.duration == nil or
	   type(spell.duration) ~= "number" or
	   index > settings.maxSpellQueue
	   then return end

	local spellData, rank, texture	
	spellData, rank, texture = addon.GetSpellInfo(spell.spellId)

	if addon.WoWInterfaceVersion <= 110000 then
		-- Old WoW v <= 11.0
		name = spellData
		texture = texture
	else
		-- War Within >= v11.0002
		name = spellData.name
		texture = spellData.iconID
	end

	local startTime = GetTime()

	spell.name = name
	spell.texture = texture
	spell.startTime = startTime
	spell.endTime = startTime + spell.duration
	spell.expired = false
	spell.uid = addon.spellBars.uid()

	local existingIndex = addon.spellBars.getQueueIndexBySpellKey(bar, spell.key)
	index = existingIndex ~= nil and existingIndex or index

	bar.spellQueue[index] = spell
	addon.spellBars.onSpellAdded(spell)
end

function addon.spellBars.removeSpellFromQueue(bar, spellKey)
	local spell = addon.spellBars.getSpellFromQueue(bar, spellKey)
	if spell == nil then return end
	spell.duration = 0
	addon.spellBars.addSpellToQueue(bar, spell)
end

function addon.spellBars.getQueueIndexBySpellKey(bar, spellKey)
	for i = 1, #bar.spellQueue do
		if tostring(bar.spellQueue[i].key) == tostring(spellKey) then
			return i
		end
	end
end

function addon.spellBars.getSpellFromQueue(bar, spellKey)
	for i = 1, #bar.spellQueue do
		if tostring(bar.spellQueue[i].key) == tostring(spellKey) then
			return bar.spellQueue[i]
		end
	end
end

function addon.spellBars.expireSpellsFromQueue(bar)	
	addon.spellBars.removeFromArray(bar.spellQueue, function(spell)
		local settings = addon.spellBars.getSettings(bar)
		local expirationTime = spell.startTime + spell.duration
		local currentTime = GetTime()

		if expirationTime < currentTime then
			addon.spellBars.onSpellRemoved(spell)
		end

		if expirationTime + settings.icons.endAnimationTime < currentTime then
			return true
		end
	end)
end
