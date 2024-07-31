local addonName, addon = ...

function addon.auraRemovedEvent(eventInfo)    
    local event = addon.getEventVars(eventInfo)
    local attributes = addon.getSpellAttributes(event, "auras", {useDestUnit=true, addAnnouncementSuffix="down", soundEffects=false})

    -- Exit if there are no spell attributes for this spell id
    if attributes == nil then return end

    local spell = addon.getSpellConfig(event, attributes)
    
    if attributes.nameplate and addon.spellPlates.isVisible(spell.spellId) then
        addon.spellPlates.showSpell(event.destGuid, spell.spellId, addon.settings.removeSpellDuration)
    end

    local spellOnBars = addon.spellBars.isSpellVisible(attributes.bar, attributes.spellKey)
    if not spellOnBars then return end

    spell.duration = addon.settings.removeSpellDuration
    addon.spellBars.showSpell(attributes.bar, spell)
end