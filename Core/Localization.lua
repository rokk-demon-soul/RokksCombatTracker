local addonName, addon = ...

function addon.setLocalization()
	local L = {}
	L["RCT"] = "Rokks Combat Tracker"
	L["RCT_Command_Lock"] = "Locks the bars."
	L["RCT_Command_Unlock"] = "Unlocks the bars."
	L["RCT_Command_Reset"] = "Resets all settings to default."
	L["RCT_Command_Resting"] = "Toggle setting to enable/disable while resting."
	L["RCT_Debug_Enabled"] = "Debuging enabled."
	L["RCT_Debug_Disabled"] = "Debuging disabled."
	L["RCT_Resting_Enabled"] = "Enabled while resting."
	L["RCT_Resting_Disabled"] = "Disabled while resting."
	L["RCT_Error_Playing_Sound"] = "Error playing: "
	L["RCT_Error_Clone_Not_Found"] = "Error. Clone ID not found: "
	L["RCT_Error_Settings_Not_Found"] = "Fatal Error: Settings not found."
	L["RCT_Splash_Title"] = "Rokk's Combat Tracker"
	L["RCT_Splash_Text"] = "/rct lock"

	local locale = GetLocale()
	if locale == "ruRU" then
		L["RCT"] = "Роккс Комбат Трэкер"
	end

	addon.L = L
end
