local addonName, addon = ...
addon.spellBars = addon.spellBars ~= nil and addon.spellBars or {}
addon.frameFactory = {}

function addon.frameFactory.infoFrame()
	local frameKey = addonName .. "_infoFrame"
	local infoFrame = CreateFrame("Frame", frameKey, UIParent)

	infoFrame:SetFrameStrata("BACKGROUND")
	infoFrame:Show()
	infoFrame:SetMovable(false)
	infoFrame:EnableMouse(false)
    infoFrame:SetPoint("CENTER", "UIParent", "CENTER", 0, 0)

	infoFrame.addonName = infoFrame:CreateFontString()
	infoFrame.addonName:SetFontObject(GameFontNormalLarge)

	infoFrame.addonName:SetJustifyH("CENTER")
	infoFrame.addonName:SetJustifyV("MIDDLE")	
	infoFrame.addonName:SetPoint("CENTER", "UIParent", "CENTER", 0, -10)

    local font = infoFrame.addonName:GetFont()
	infoFrame.addonName:SetFont(font, "35")
    infoFrame.addonName:SetText(addon.L["RCT_Splash_Title"] .. " " .. tostring(addon.version))

	infoFrame.Text = infoFrame:CreateFontString()
	infoFrame.Text:SetFontObject(GameFontNormalLarge)

	infoFrame.Text:SetJustifyH("CENTER")
	infoFrame.Text:SetJustifyV("MIDDLE")	
	infoFrame.Text:SetPoint("CENTER", "UIParent", "CENTER", 0, -50)

    local font = infoFrame.Text:GetFont()
	infoFrame.Text:SetFont(font, "30")
    infoFrame.Text:SetText(addon.L["RCT_Splash_Text"])

	if addon.settings.locked then
		infoFrame:Hide()
	else
		infoFrame:Show()
	end

	return infoFrame
end
