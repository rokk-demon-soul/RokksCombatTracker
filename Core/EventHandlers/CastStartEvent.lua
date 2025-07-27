local addonName, addon = ...

function addon.castStartEvent(eventInfo)
    local event = addon.getEventVars(eventInfo)
    local attributes = addon.getSpellAttributes(event, "castStart", {useDestUnit=false})

    -- Exit if there are no spell attributes for this spell id
    if attributes == nil then return end

    local spell = addon.getSpellConfig(event, attributes)
    spell.duration = addon.settings.defaultDuration
    spell.showCooldown = false

    -- addon.spellBars.showSpell(attributes.bar, spell)
end
