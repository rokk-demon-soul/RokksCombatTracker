local addonName, addon = ...
addon.spellPlates = addon.spellPlates ~= nil and addon.spellPlates or {}

function addon.spellPlates.initialize(settings)
	if addon.spellPlates.initialized then return end
	
	addon.spellPlates.settings = settings
	addon.spellPlates.createNameplateFrames()
	addon.spellPlates.registerEvents()
	
	addon.spellPlates.nameplateIds = {}
	addon.spellPlates.unitGuids = {}
	addon.spellPlates.visibleSpells = {}
	addon.spellPlates.activeSpells = {}
	addon.spellPlates.inactiveSpells = {}
	addon.spellPlates.frameLevel = 1

	addon.spellPlates.initialized = true
end

function addon.spellPlates.isVisible(spellId)
	return addon.spellPlates.visibleSpells[spellId]
end

function addon.spellPlates.showSpell(unitGuid, spellId, duration)
	local nameplateId = addon.spellPlates.nameplateIds[unitGuid]
	
	if duration > addon.spellPlates.settings.maxDuration then return end
	if duration <= 0 then duration = .001 end

	if not nameplateId then
		local inactive = addon.spellPlates.inactiveSpells[unitGuid]
		local startTime = GetTime()
				
		inactive = inactive ~= nil and inactive or {}
		inactive.spells = inactive.spells ~= nil and inactive.spells or {}

		local currentSpell = {
			duration = duration,
			startTime = startTime
		}

		inactive.spells[spellId] = currentSpell

		addon.spellPlates.inactiveSpells[unitGuid] = inactive
		return
	end
	
	local nameplateFrame = C_NamePlate.GetNamePlateForUnit(nameplateId)

	if nameplateFrame[addonName] == nil then nameplateFrame[addonName] = {} end
	
	if not nameplateFrame[addonName].frameLevel then
		nameplateFrame[addonName].frameLevel = addon.spellPlates.getFrameLevel()
	end
	
    local duration = duration
    local startTime = GetTime()
    local endTime = startTime + duration

	local activeSpellId = addon.spellPlates.getActiveSpellIndex(unitGuid, nameplateId, spellId)	
	addon.spellPlates.showIcon(activeSpellId, nameplateFrame, spellId, duration, startTime, endTime)
end

function addon.spellPlates.showIcon(id, parent, spellId, duration, startTime, endTime)
	local spellData, rank, texture	
	spellData, rank, texture = addon.GetSpellInfo(spellId)

	name = spellData.name
	texture = spellData.iconID
	
	local icon = addon.spellPlates.activeSpells[id] ~= nil and addon.spellPlates.activeSpells[id] or
			     addon.spellPlates.getNewIcon()

	if icon == nil then return end

	if rctdebug == true then print("Showing  " .. icon:GetDebugName()) end

	icon.parent = parent
	icon.spellId = spellId
	icon.inUse = true
	icon.id = id

	icon.texture:SetAllPoints(icon)
    icon.texture:SetTexture(texture)
    
	icon.cooldown:SetCooldown(startTime, duration)
    icon.cooldown.finish = endTime

	addon.spellPlates.activeSpells[id] = icon
	addon.spellPlates.visibleSpells[spellId] = true

	if parent[addonName] == nil then parent[addonName] = {} end
	if parent[addonName].spells == nil then parent[addonName].spells = {} end		
	parent[addonName].spells[spellId] = icon

	addon.spellPlates.arrangeIcons(parent)

	return icon
end

function addon.spellPlates.hideIcon(icon)
	icon:Hide()
	icon.border:Hide()
	icon.inUse = false

	if rctdebug == true then print("Hiding  " .. icon:GetDebugName()) end	

	local parent = icon.parent
	
	if parent[addonName] == nil then parent[addonName] = {} end
	if parent[addonName].spells == nil then parent[addonName].spells = {} end

	parent[addonName].spells[icon.spellId] = nil
	addon.spellPlates.activeSpells[icon.id] = nil
	addon.spellPlates.visibleSpells[icon.spellId] = nill

	addon.spellPlates.arrangeIcons(parent)
end

function addon.spellPlates.arrangeIcons(nameplate)
	local count = 0
	for _ in pairs(nameplate[addonName].spells) do
		count = count + 1
	end

	local settings = addon.spellPlates.settings
	local iconNumber = 0
	local offset = settings.iconSize + settings.borderSize * 2 + settings.backdropSize * 2 + settings.iconSpacing
	local totalWidth = offset * (count - 1)
	local centerOffset = totalWidth / 2

	for spellId, icon in pairs(nameplate[addonName].spells) do
		local currentOffset = offset * iconNumber - centerOffset
		local frameLevel = icon.parent[addonName].frameLevel

		icon:ClearAllPoints()
    	icon:SetPoint("CENTER", icon.parent, "CENTER", currentOffset, settings.yOffset)		
		
		icon:SetFrameLevel(frameLevel)
		icon.border:SetFrameLevel(frameLevel + 1)
		icon.border.left:SetFrameLevel(frameLevel + 1)
		icon.border.right:SetFrameLevel(frameLevel + 1)
		icon.border.top:SetFrameLevel(frameLevel + 1)
		icon.border.bottom:SetFrameLevel(frameLevel + 1)

		icon:Show()
    	icon.border:Show()
		iconNumber = iconNumber + 1
	end
end

function addon.spellPlates.cooldownFinished(self)
	local icon = self.icon
	addon.spellPlates.hideIcon(icon)
end

function addon.spellPlates.getNewIcon()
	for i = 1, addon.spellPlates.settings.maxIcons do
		local icon = _G[addonName .. "_IconFrame" .. i]
		if not icon.inUse then
			if rctdebug == true then print("Fetching free icon frame " .. icon:GetDebugName()) end
			return icon
		end
	end
end

function addon.spellPlates.getActiveSpellIndex(unitGuid, nameplateId, spellId)
	unitGuid = unitGuid:gsub("-", "")
	return unitGuid .. nameplateId .. spellId
end

function addon.spellPlates.getFrameLevel()
	if addon.spellPlates.frameLevel > 9000 then addon.spellPlates.frameLevel = 1 end
	addon.spellPlates.frameLevel = addon.spellPlates.frameLevel + 2
	return addon.spellPlates.frameLevel
end