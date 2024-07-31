local addonName, addon = ...

function addon.castInterruptEvent(eventInfo)
    local event = addon.getEventVars(eventInfo)

    -- If this event is closing a previously started cast, remove it
    local endCastAttributes = addon.getSpellAttributes(event, "castStart", {useExtraSpellId=true, useDestUnit=true, showUnitName=true, announce=false, spellType="castInterrupt"})
    if endCastAttributes ~= nil then
        local spell = addon.getSpellConfig(event, endCastAttributes)
        spell.duration = addon.settings.removeSpellDuration
        spell.showCooldown = true
        addon.spellBars.showSpell(endCastAttributes.bar, spell)
    end    
end