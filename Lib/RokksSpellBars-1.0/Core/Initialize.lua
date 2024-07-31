local addonName, addon = ...
addon.spellBars = addon.spellBars ~= nil and addon.spellBars or {}

function addon.spellBars.arrangeIcons(bar)
	local settings = addon.spellBars.getSettings(bar)
	local iconPosition = 0

	for index, icon in pairs(bar.icons) do
		local totalSingleIconWidth = (settings.icons.borderSize + settings.icons.backdropSize) * 2 + settings.icons.size + settings.icons.padding
		local currentIconOffset = settings.icons.borderSize + settings.icons.backdropSize
		local absOfs = currentIconOffset + (iconPosition * totalSingleIconWidth)
		local align = settings.icons.align

		local xOfs = align == "RIGHT" and absOfs * -1 or absOfs
		local yOfs = 0

		icon:ClearAllPoints()
		icon:SetPoint(align, bar, align, xOfs, yOfs)
		iconPosition = iconPosition + 1
	end

	return true
end

function addon.spellBars.initializeIcons(bar)
	local settings = addon.spellBars.getSettings(bar)

	for i = 1, settings.icons.max do
		local icon
		local iconKey = bar.key .. "_Icon" .. i

		icon = addon.spellBars.iconFactory(iconKey, bar)
		if settings.icons.showCooldown then
			icon.cooldown = addon.spellBars.cooldownFactory(icon)
		end
		table.insert(bar.icons, icon)
	end
end

function addon.spellBars.initializeBars()
    for barKey, barSettings in pairs(addon.spellBars.settings.bars) do
		local settings = addon.spellBars.getSettings(barKey)
		local bar = addon.spellBars.barFactory(barKey)

		addon.spellBars.initializeIcons(bar)
		addon.spellBars.arrangeIcons(bar)		
	end

	if not addon.spellBars.settings.locked then
		addon.spellBars.unlockBars()
	end
end