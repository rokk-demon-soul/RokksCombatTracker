local addonName, addon = ...

function addon.castSuccessEvent(eventInfo)
    local event = addon.getEventVars(eventInfo)

    -- Cast Success
    local castSuccessAttributes = addon.getSpellAttributes(event, "castSuccess", {useDestUnit=false})
    if castSuccessAttributes ~= nil then 
        local spell = addon.getSpellConfig(event, castSuccessAttributes)
        spell.duration = addon.settings.defaultDuration
        spell.showCooldown = false        
        addon.spellBars.showSpell(castSuccessAttributes.bar, spell)
        return
    end

    -- If this event is closing a previously started cast, remove it
    local endCastAttributes = addon.getSpellAttributes(event, "castStart", {useDestUnit=false, announce=false, spellType="castSuccess"})
    if endCastAttributes ~= nil then
        local spell = addon.getSpellConfig(event, endCastAttributes)
        spell.duration = addon.settings.removeSpellDuration
        spell.showCooldown = true
        addon.spellBars.showSpell(endCastAttributes.bar, spell)
    end

    -- Track Cooldowns
    local cooldownAttributes = addon.getSpellAttributes(event, "cooldowns", {useDestUnit=false, spellType="cooldown", bar="cooldowns"})
    if cooldownAttributes ~= nil then 
        local spell = addon.getSpellConfig(event, cooldownAttributes)
        spell.duration = cooldownAttributes.cd
        spell.showCooldown = true

        addon.spellBars.showSpell(cooldownAttributes.bar, spell)
    end
end