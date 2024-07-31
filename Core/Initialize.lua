local addonName, addon = ...

function addon.initialize()
    if addon.initialized then return end
    
    addon.loadSettings()
    addon.setLocalization()

    addon.infoFrame = addon.frameFactory.infoFrame()
    
    addon.spellBars.initialize(addon.profiles[addon.settings.profile], addon.settings.locked)
    addon.spellPlates.initialize(addon.profiles[addon.settings.profile].nameplates)

    addon.loadProfiles()
    addon.registerSlashCommands()
    addon.announceThrottle = addon.announceThrottle or {}

    addon.initialized = true
end

function addon.resetSettings()
    addon.spellBars.lockBars()
    b35904e6bb2943c5adcfc4058c8cf6b3 = nil
    b35904e6bb2943c5adcfc4058c8cf6b3 = defaultSettings
    addon.settings = b35904e6bb2943c5adcfc4058c8cf6b3
    ReloadUI()
end

function addon.loadSettings()
    if b35904e6bb2943c5adcfc4058c8cf6b3 == nil then
        b35904e6bb2943c5adcfc4058c8cf6b3 = addon.defaultSettings
    end

    addon.settings = b35904e6bb2943c5adcfc4058c8cf6b3
end

function addon.loadProfiles()
    if eccf8d028d224e618ac7f15b81a1c211 == nil or type(eccf8d028d224e618ac7f15b81a1c211) ~= "table" then return end
    for profileName, externalProfile in pairs(eccf8d028d224e618ac7f15b81a1c211) do
        if addon.profiles[profileName] == nil then
            addon.profiles[profileName] = externalProfiles
        end
    end
end