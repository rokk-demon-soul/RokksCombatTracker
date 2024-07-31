local addonName, addon = ...
addon.spellBars = addon.spellBars ~= nil and addon.spellBars or {}

function addon.spellBars.onDragStart(bar)
	bar:StartMoving()
end

function addon.spellBars.onDragStop(bar)
	local settings = addon.spellBars.getSettings(bar)
	local anchorPoint, relativeTo, relativePoint, xOfs, yOfs = bar:GetPoint(1)

	settings.position.anchorPoint = anchorPoint
	settings.position.relativeTo = relativeTo ~= nil and relativeTo or settings.position.relativeTo
	settings.position.relativePoint = relativePoint
	settings.position.xOfs = xOfs
	settings.position.yOfs = yOfs

	bar:StopMovingOrSizing()
end

function addon.spellBars.onSpellAdded(spell)
	return spell
end

function addon.spellBars.onSpellRemoved(spell)	
	if spell.expired then return end
	
	if spell.callback ~= nil then
		spell.callback(spell)
	end
	
	spell.expired = true
	return true
end

function addon.spellBars.showTooltip(icon)
	local settings = addon.spellBars.getSettings(icon:GetParent())
	if not settings.icons.showTooltips then return end

	local tooltipAlign = settings.icons.align == "LEFT" and "ANCHOR_TOPLEFT" or "ANCHOR_TOPRIGHT"
	if not icon or not icon.spellId then return end
	
	GameTooltip:SetOwner(icon, tooltipAlign)
	GameTooltip:SetSpellByID(icon.spellId)
end

function addon.spellBars.hideTooltip(icon)
	GameTooltip:Hide()
end
