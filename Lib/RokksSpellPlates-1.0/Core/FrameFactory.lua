local addonName, addon = ...
addon.spellPlates = addon.spellPlates ~= nil and addon.spellPlates or {}

function addon.spellPlates.createNameplateFrames()
	local settings = addon.spellPlates.settings

	for i = 1, settings.maxIcons do
		local frameKey = addonName .. "_IconFrame" .. i
		local icon = CreateFrame("Frame", frameKey, UIParent, "BackdropTemplate")

		if rctdebug == true then print("Creating  " .. icon:GetDebugName()) end

		icon:SetPoint("CENTER")
			
		icon.texture = icon:CreateTexture()
		icon:SetSize(settings.iconSize, settings.iconSize)

		icon.texture:SetTexCoord(.08, .92, .08, .92)

		icon.border = addon.spellPlates.borderFactory(icon, settings.borderSize, settings.backdropSize, settings.borderColor)
		icon.backdrop = addon.spellPlates.backdropFactory(icon, settings.borderSize, settings.backdropSize, settings.backdropColor)

		if settings.innerBorder then
			icon.innerBorder = addon.spellPlates.borderFactory(icon, 1, 0, settings.innerBorderColor)
		end

		icon.cooldown = addon.spellPlates.cooldownFactory(icon)
        icon:Hide()
	end
end

function addon.spellPlates.borderFactory(parentFrame, borderSize, padding, borderColor)
	local border = CreateFrame("Frame", nil, parentFrame)
	local insetSize = borderSize + padding

	border:SetAllPoints(parentFrame)

	border.left = addon.spellPlates.borderSideFactory(border, "LEFT", insetSize, padding, borderColor)
	border.right = addon.spellPlates.borderSideFactory(border, "RIGHT", insetSize, padding, borderColor)
	border.top = addon.spellPlates.borderSideFactory(border, "TOP", insetSize, padding, borderColor)
	border.bottom = addon.spellPlates.borderSideFactory(border, "BOTTOM", insetSize, padding, borderColor)
	
	border.setColor = function(color)
		border.left.texture:SetColorTexture(color[1], color[2], color[3], color[4])
		border.right.texture:SetColorTexture(color[1], color[2], color[3], color[4])
		border.top.texture:SetColorTexture(color[1], color[2], color[3], color[4])
		border.bottom.texture:SetColorTexture(color[1], color[2], color[3], color[4])
	end

	return border
end

function addon.spellPlates.borderSideFactory(parentFrame, side, insetSize, padding, borderColor)
	local borderSide = CreateFrame("Frame", nil, parentFrame)
	borderSide:SetAllPoints(parentFrame)
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

function addon.spellPlates.backdropFactory(frame, iconSize, backdropSize, backdropColor)
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

	local backdrop = {}
	backdrop.setColor = function(color)
		frame:SetBackdropColor(color[1], color[2], color[3], color[4])
	end
	
	return backdrop
end

function addon.spellPlates.cooldownFactory(icon)
	local cooldown = CreateFrame("Cooldown", nil, icon, "CooldownFrameTemplate")
	local settings = addon.spellPlates.settings

	cooldown.icon = icon
	cooldown:SetHideCountdownNumbers(not settings.cooldownCounter and true or false)
	cooldown.noCooldownCount = (not settings.cooldownCounter)
	cooldown:SetSwipeColor(0, 0, 0, settings.swipeAlpha)
	cooldown:SetScript("OnHide", addon.spellPlates.cooldownFinished)

	local timerColor = settings.cooldownFontColor
	local timer = cooldown:GetRegions()
	local timerFont = timer:GetFont()
	timer:SetFont(timerFont, settings.cooldownFontSize)
	timer:SetTextColor(timerColor[1], timerColor[2], timerColor[3], timerColor[4])

	return cooldown
end
