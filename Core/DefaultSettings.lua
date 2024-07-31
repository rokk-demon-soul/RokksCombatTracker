local addonName, addon = ...

addon.defaultSettings = {
    ["locked"] = false,
    ["enabled"] = true,
    ["enabledWhileResting"] = true,
    ["profile"] = "default",
    ["defaultBar"] = "primary",
    ["friendlyBarSuffix"] = "-friendly",
    ["hostileBarSuffix"] = "-hostile",
    ["debug"] = true,
    ["defaultDuration"] = 5,
    ["removeSpellDuration"] = .001,
    ["soundPriority"] = 2,
    ["soundEffects"] = true,
    ["soundChannel"] = "DIALOG",
    ["styles"] = {
        ["offensive"] = {backdropColor={0,1,1,.3},borderColor={0,1,1,.8}}, -- light blue
        ["defensive"] = {backdropColor={.54,.27,.07,.6},borderColor={.78,.61,.43,.9}}, -- brown
        ["immunity"] = {backdropColor={.98, 0, 0, .3},borderColor={.98,0,0,.8},targetOnlyCustomSound="true",customSound="Interface\\AddOns\\RokksCombatTracker\\Media\\Sounds\\SoundEffects\\blip-videogame.mp3"}, -- red
        ["reflect"] = {backdropColor={1,.102,.4,.3},borderColor={1,.102,.4,.8},targetOnlyCustomSound="true",customSound="Interface\\AddOns\\RokksCombatTracker\\Media\\Sounds\\SoundEffects\\blip-scifi.mp3"}, -- pink
        ["cc"] = {backdropColor={.97,0,.97,.3},borderColor={.97,0,.97,.9}}, -- purple
        ["ccImmunity"] = {backdropColor={0,0,0,.3},borderColor={0,0,0,.8}}, -- yellow
        ["cooldown"] =  {desaturate="true",backdropColor={0,0,0,.3},borderColor={0,0,0,.8}}, -- gray
        ["castFailed"] =  {backdropColor={.98, 0, 0, .3},borderColor={.98,0,0,.8}}, -- red
        ["castInterrupt"] =  {backdropColor={.98, 0, 0, .3},borderColor={.98,0,0,.8},customSound="Interface\\AddOns\\RokksCombatTracker\\Media\\Sounds\\SoundEffects\\blip-chirp.mp3"}, -- yellow
        ["castSuccess"] =  {backdropColor={.549,1,.102,.3},borderColor={.549,1,.102,.8},customSound="Interface\\AddOns\\RokksCombatTracker\\Media\\Sounds\\SoundEffects\\robotic-phaser.mp3"} -- green
    }
}
