local addonName, addon = ...

function addon.castFailedEvent(eventInfo)
    local event = addon.getEventVars(eventInfo)

    -- If this event is closing a previously started cast, remove it
    local endCastAttributes = addon.getSpellAttributes(event, "castStart", {useDestUnit=false, announce=false, spellType="castFailed"})
    if endCastAttributes ~= nil then
        local spell = addon.getSpellConfig(event, endCastAttributes)
        spell.duration = addon.settings.removeSpellDuration
        spell.showCooldown = true
        -- addon.spellBars.showSpell(endCastAttributes.bar, spell)
    end
    
end