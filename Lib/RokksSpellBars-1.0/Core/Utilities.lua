local addonName, addon = ...
addon.spellBars = addon.spellBars ~= nil and addon.spellBars or {}

function addon.spellBars.getBar(key)
	local barKey = addonName .. "_" .. key
	return _G[barKey]
end

function addon.spellBars.loadSettings(settings)
	if settings ~= nil then
    	addon.spellBars.settings = settings
	else
		print(addon.L["RCT_Error_Settings_Not_Found"])
	end
end

function addon.spellBars.getSettings(bar)
	if bar == nil then
		return addon.spellBars.settings
	elseif type(bar) == "string" then
		return addon.spellBars.settings.bars[bar]
	elseif type(bar) == "table" and type(bar.key) == "string" and bar.key ~= nil then
		return addon.spellBars.settings.bars[bar.key]
	else
		return nil
	end
end

function addon.spellBars.lockBars()
	addon.spellBars.settings.locked = true
	for barKey, barSettings in pairs(addon.spellBars.settings.bars) do
		local bar = addon.spellBars.getBar(barKey)
		bar:SetMovable(false)
		bar:EnableMouse(false)
		bar:RegisterForDrag()
		bar:SetBackdrop(nil)
		bar.Text:SetText(nil)
	end
end

function addon.spellBars.unlockBars()
	addon.spellBars.settings.locked = false
	for barKey, settings in pairs(addon.spellBars.settings.bars) do
		local bar = addon.spellBars.getBar(barKey)
		local barText = settings.displayName

		bar:SetMovable(true)
		bar:EnableMouse(true)
		bar:RegisterForDrag("LeftButton")
		bar:SetBackdrop(BACKDROP_TUTORIAL_16_16)
		bar.Text:SetText(barText)
	end
end

function addon.spellBars.uid()
	local random = math.random
    local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    return string.gsub(template, '[xy]', function (c)
        local v = (c == 'x') and random(0, 0xf) or random(8, 0xb)
        return string.format('%x', v)
    end)
end

function addon.spellBars.removeFromArray(array, fnRemove)	
	if array == nil or fnRemove == nil then return end
    local j = 1
    for i = 1, #array do
		local remove = fnRemove(array[i])
		
		array[j] = array[i]		
		
		if remove or i ~= j then
			array[i] = nil
		end

		if not remove then
			j = j + 1
		end		
    end
end

function addon.spellBars.updateIcons(bar)
	addon.spellBars.expireSpellsFromQueue(bar)

	local settings = addon.spellBars.getSettings(bar)
	if #bar.spellQueue > settings.maxSpellQueue then return end

	for iconKey, icon in pairs(bar.icons) do
		local spell = bar.spellQueue[iconKey]
		addon.spellBars.updateIcon(bar, icon, spell)
	end
end

function addon.spellBars.updateIcon(bar, icon, spell)
	local settings = addon.spellBars.getSettings(bar)

	if spell == nil then
		icon:Hide()
		icon.Text:SetText(nil)
		icon.border:Hide()
		icon.backdrop.setColor(settings.icons.backdropColor)
		icon.border.setColor(settings.icons.borderColor)
		return
	end

	if icon.uid == spell.uid then return end

	icon.uid = spell.uid
	icon.spellId = spell.spellId
	icon.texture:SetAllPoints(icon)
	icon.texture:SetTexture(spell.texture)				

	icon:Show()
	icon.border:Show()
	icon.Text:SetText(spell.text)

	if settings.icons.showCooldown and spell.showCooldown ~= false then
		icon.cooldown:SetCooldown(spell.startTime, spell.duration)
		icon.cooldown.finish = spell.endTime
	end

	local desaturate = spell.desaturate and 1 or nil
	icon.texture:SetDesaturated(desaturate)

	local backdropColor = spell.backdropColor ~= nil and spell.backdropColor or settings.icons.backdropColor
	icon.backdrop.setColor(backdropColor)

	local borderColor = spell.borderColor ~= nil and spell.borderColor or settings.icons.borderColor
	icon.border.setColor(borderColor)
end
