local addonName, addon = ...
addon.spellBars = addon.spellBars ~= nil and addon.spellBars or {}

function addon.spellBars.barFactory(key)
	local frameKey = addonName .. "_" .. key
	local bar = CreateFrame("Frame", frameKey, UIParent, "BackdropTemplate")
	local settings = addon.spellBars.getSettings(key)

	bar:SetClampedToScreen(settings.clampedToScreen)
	bar:SetFrameStrata(settings.strata)
	bar:SetFrameLevel(1)

	local totalSingleIconWidth = (settings.icons.borderSize + settings.icons.backdropSize) * 2 + settings.icons.size + settings.icons.padding
	local totalIconsWidth = settings.icons.max * totalSingleIconWidth
	local totalBarWidth = totalIconsWidth - settings.icons.padding
	local totalBarHeight = settings.icons.size + (settings.icons.borderSize + settings.icons.backdropSize) * 2

	local barWidth = totalBarWidth
	local barHeight = totalBarHeight

	bar:SetSize(barWidth, barHeight)
	bar:Show()	
	bar.key = key
	bar.spellQueue = {}
	bar.icons = {}
	bar:SetMovable(false)
	bar:EnableMouse(false)
	bar:RegisterForDrag()
	bar:SetBackdrop(nil)
	bar:SetScript("OnDragStart", function() addon.spellBars.onDragStart(bar) end)
	bar:SetScript("OnDragStop", function() addon.spellBars.onDragStop(bar) end)
	bar:SetPoint(settings.position.anchorPoint,
				 settings.position.relativeTo,
				 settings.position.relativePoint,
				 settings.position.xOfs,
				 settings.position.yOfs)

	bar.Text = bar:CreateFontString()
	bar.Text:SetFontObject(GameFontNormalLarge)
	bar.Text:SetJustifyH("CENTER")
	bar.Text:SetJustifyV("MIDDLE")
	bar.Text:SetText(nil)
	bar.Text:SetPoint("CENTER", bar, "CENTER", 0, 0)

	local refreshRate = settings.refreshRate < .1 and .1 or settings.refreshRate
	C_Timer.NewTicker(refreshRate, function() addon.spellBars.updateIcons(bar) end)

	return bar
end

function addon.spellBars.iconFactory(key, bar)
	local frameKey = addonName .. "_" .. key
	local icon = CreateFrame("Frame", frameKey, bar, "BackdropTemplate")
	local settings = addon.spellBars.getSettings(bar)

	icon.key = key
	icon:SetPoint("CENTER")
		
	icon.texture = icon:CreateTexture()
	icon:SetSize(settings.icons.size, settings.icons.size)
	icon:SetFrameLevel(5)
	icon:SetScript("OnEnter", addon.spellBars.showTooltip)
	icon:SetScript("OnLeave", addon.spellBars.hideTooltip)

	if settings.icons.zoom then
		icon.texture:SetTexCoord(.08, .92, .08, .92)
	end

	icon.border = addon.spellBars.borderFactory(icon, settings.icons.borderSize, settings.icons.backdropSize, settings.icons.borderColor)
	icon.backdrop = addon.spellBars.backdropFactory(icon, settings.icons.size, settings.icons.backdropSize, settings.icons.backdropColor)

	if settings.icons.innerBorder then
		icon.innerBorder = addon.spellBars.borderFactory(icon, 1, 0, settings.icons.innerBorderColor)
	end
	
	local textOffset = settings.icons.borderSize + settings.icons.backdropSize + 5

	icon.Text = icon:CreateFontString()
	icon.Text:SetFontObject(settings.icons.font)
	icon.Text:SetJustifyH("CENTER")
	icon.Text:SetJustifyV("MIDDLE")
	icon.Text:SetText(nil)
	icon.Text:SetPoint("TOP", icon, "BOTTOM", 0, -textOffset)

	fontName, fontHeight, fontFlags = icon.Text:GetFont()
	local iconWidth = (settings.icons.borderSize + settings.icons.backdropSize) * 2 + settings.icons.size	
	local fontHeight = settings.icons.ellipsis == false and 0 or fontHeight
	
	icon.Text:SetSize(iconWidth, fontHeight)

	return icon
end

function addon.spellBars.backdropFactory(frame, iconSize, backdropSize, backdropColor)
	local insetSize = backdropSize * -1
	local backdropSettings = {
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
		tileSize = iconSize,
		tile = true,		
		edgeSize = backdropSize,
		insets = { left = insetSize, right = insetSize, top = insetSize, bottom = insetSize }
	}

	frame:SetBackdrop(backdropSettings)
	frame:SetBackdropColor(backdropColor[1], backdropColor[2], backdropColor[3], backdropColor[4])
	frame:SetBackdropBorderColor(0, 0, 0)
	frame:SetFrameLevel(5)

	local backdrop = {}
	backdrop.setColor = function(color)
		frame:SetBackdropColor(color[1], color[2], color[3], color[4])
	end
	
	return backdrop
end

function addon.spellBars.borderFactory(parentFrame, borderSize, padding, borderColor)
	local border = CreateFrame("Frame", nil, parentFrame)
	local insetSize = borderSize + padding

	border:SetAllPoints(parentFrame)
	border:SetFrameLevel(10)

	border.left = addon.spellBars.borderSideFactory(border, "LEFT", insetSize, padding, borderColor)
	border.right = addon.spellBars.borderSideFactory(border, "RIGHT", insetSize, padding, borderColor)
	border.top = addon.spellBars.borderSideFactory(border, "TOP", insetSize, padding, borderColor)
	border.bottom = addon.spellBars.borderSideFactory(border, "BOTTOM", insetSize, padding, borderColor)
	
	border.setColor = function(color)
		border.left.texture:SetColorTexture(color[1], color[2], color[3], color[4])
		border.right.texture:SetColorTexture(color[1], color[2], color[3], color[4])
		border.top.texture:SetColorTexture(color[1], color[2], color[3], color[4])
		border.bottom.texture:SetColorTexture(color[1], color[2], color[3], color[4])
	end

	return border
end

function addon.spellBars.borderSideFactory(parentFrame, side, insetSize, padding, borderColor)
	local borderSide = CreateFrame("Frame", nil, parentFrame)
	borderSide:SetAllPoints(parentFrame)
	borderSide:SetFrameLevel(15)
	borderSide.texture = borderSide:CreateTexture()
	borderSide.texture:SetAllPoints(borderSide)
	borderSide.texture:SetColorTexture(borderColor[1], borderColor[2], borderColor[3], borderColor[4])

	if side == "LEFT" then
		borderSide.texture:SetPoint("TOPLEFT", parentFrame, "TOPLEFT", -insetSize, padding)
		borderSide.texture:SetPoint("BOTTOMRIGHT", parentFrame, "BOTTOMLEFT", -padding, -padding)
	elseif side == "RIGHT" then
		borderSide.texture:SetPoint("TOPLEFT", parentFrame, "TOPRIGHT", padding, padding)
		borderSide.texture:SetPoint("BOTTOMRIGHT", parentFrame, "BOTTOMRIGHT", insetSize, -padding)
	elseif side == "TOP" then
		borderSide.texture:SetPoint("TOPLEFT", parentFrame, "TOPLEFT", -insetSize, insetSize)
		borderSide.texture:SetPoint("BOTTOMRIGHT", parentFrame, "TOPRIGHT", insetSize, padding)
	elseif side == "BOTTOM"then
		borderSide.texture:SetPoint("TOPLEFT", parentFrame, "BOTTOMLEFT", -insetSize, -insetSize)
		borderSide.texture:SetPoint("BOTTOMRIGHT", parentFrame, "BOTTOMRIGHT", insetSize, -padding)
	end 

	return borderSide
end

function addon.spellBars.cooldownFactory(icon)
	local cooldown = CreateFrame("Cooldown", nil, icon, "CooldownFrameTemplate")
	local settings = addon.spellBars.getSettings(icon:GetParent())
	
	cooldown:SetHideCountdownNumbers(not settings.icons.cooldownCounter and true or false)
	cooldown.noCooldownCount = (not settings.icons.cooldownCounter)
	cooldown:SetSwipeColor(0, 0, 0, settings.icons.swipeAlpha)
	cooldown:SetScript("OnShow", addon.spellBars.cooldownOnShow)
	cooldown:SetScript("OnHide", addon.spellBars.cooldownOnHide)

	local timerColor = settings.icons.cooldownFontColor
	local timer = cooldown:GetRegions()
	local timerFont = timer:GetFont()
	timer:SetFont(timerFont, settings.icons.cooldownFontSize)
	timer:SetTextColor(timerColor[1], timerColor[2], timerColor[3], timerColor[4])

	return cooldown
end
