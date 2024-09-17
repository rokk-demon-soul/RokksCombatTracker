local addonName, addon = ...

function addon.setLocalization()
	local L = {}
	L["RCT"] = "Rokks Combat Tracker"
	L["RCT_Command_Lock"] = "Locks the bars."
	L["RCT_Command_Unlock"] = "Unlocks the bars."
	L["RCT_Command_Reset"] = "Resets all settings to default."

	L["RCT_Spam_Level_High"] = "Lots of audio spam."
	L["RCT_Spam_Level_Medium"] = "Medium audio spam."
	L["RCT_Spam_Level_Low"] = "Low audio spam."
	L["RCT_Spam_Level_Off"] = "Voicing spells disabled."


	L["RCT_Sound_Priority_High"] = "Spam level set to LOW. Voicing high priority spells only."
	L["RCT_Sound_Priority_Medium"] = "Spam level set to MEDIUM. Voicing high and medium priority spells."
	L["RCT_Sound_Priority_Low"] = "Spam level set to HIGH. Voicing high, medium and low priority spells."
	L["RCT_Sound_Priority_Off"] = "Voicing spells is now disabled."
	L["RCT_Toggle_BGs"] = "Toggle setting to enable/disable while in Battlegrounds."
	L["RCT_Toggle_Resting"] = "Toggle setting to enable/disable while resting."
	L["RCT_Debug_Enabled"] = "Debuging enabled."
	L["RCT_Debug_Disabled"] = "Debuging disabled."
	L["RCT_Resting_Enabled"] = "Enabled while resting."
	L["RCT_Resting_Disabled"] = "Disabled while resting."
	L["RCT_Battlegrounds_Enabled"] = "Enabled while in battlegrounds."
	L["RCT_Battlegrounds_Disabled"] = "Disabled while in battlegrounds."
	L["RCT_Error_Playing_Sound"] = "Error playing: "
	L["Unknown_Option"] = "Unknown option: "
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
