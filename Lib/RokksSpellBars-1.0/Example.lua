local addonName, addon = ...

local barSettings = {
    ["locked"] = false,
    ["bars"] = {
        ["friendlySpells"] = {
            ["displayName"] = "Friendly Spells",
            ["refreshRate"] = .1,
            ["maxSpellQueue"] = 100,
            ["clampedToScreen"] = true,
            ["strata"] = "LOW",            
            ["position"] = {
                ["anchorPoint"] = "CENTER",
                ["relativeTo"] = "UIParent",
                ["relativePoint"] = "CENTER",
                ["xOfs"] = -300,
                ["yOfs"] = -100,
            },
            ["icons"] = {
                ["align"] = "RIGHT",
                ["size"] = 42,
                ["borderSize"] = 2,
                ["borderColor"] = {0, 0, 0, .6},
                ["backdropSize"] = 5,
                ["backdropColor"] = {0, 0, 0, .4},
                ["innerBorder"] = true,
                ["innerBorderColor"] = {0, 0, 0, .9},
                ["zoom"] = true,
                ["max"] = 6,
                ["padding"] = 6,
                ["showCooldown"] = true,
                ["cooldownCounter"] = true,
                ["cooldownFontSize"] = 30,
                ["cooldownFontColor"] = {1, 1, 0, 1},
                ["endAnimationTime"] = 1,
                ["swipeAlpha"] = .3,
                ["showTooltips"] = true,
            }
        },
        ["enemySpells"] = {
            ["displayName"] = "Enemy Spells",
            ["refreshRate"] = .1,
            ["maxSpellQueue"] = 100,
            ["clampedToScreen"] = true,
            ["strata"] = "LOW",
            ["position"] = {
                ["anchorPoint"] = "CENTER",
                ["relativeTo"] = "UIParent",
                ["relativePoint"] = "CENTER",
                ["xOfs"] = 300,
                ["yOfs"] = -100,
            },
            ["icons"] = {
                ["align"] = "LEFT",
                ["size"] = 42,
                ["borderSize"] = 2,
                ["borderColor"] = {0, 0, 0, .6},
                ["backdropSize"] = 5,
                ["backdropColor"] = {0, 0, 0, .4},
                ["innerBorder"] = true,
                ["innerBorderColor"] = {0, 0, 0, .9},
                ["zoom"] = true,
                ["max"] = 6,
                ["padding"] = 6,
                ["showCooldown"] = true,
                ["cooldownCounter"] = true,
                ["cooldownFontSize"] = 30,
                ["cooldownFontColor"] = {1, 1, 0, 1},
                ["endAnimationTime"] = 1,
                ["swipeAlpha"] = .3,
                ["showTooltips"] = true,
            }
        }
    }
}

addon.spellBars.initialize(barSettings)

local spell1 = {spellId = 47528, duration = 24}
local spell2 = {spellId = 183752, duration = 16}
local spell3 = {spellId = 96231, duration = 18, backdropColor = {.793, .121, .926, .3}, borderColor = {.793, .121, .926, .8}}
local spell4 = {spellId = 106839, duration = 14}
local spell5 = {spellId = 6552, duration = 19, desaturate = true}
local spell6 = {spellId = 119910, duration = 22, backdropColor = {0, 1, 1, .6}}
local spell7 = {spellId = 57994, duration = 28, text="Rokks-Sargeras"}
local spell8 = {spellId = 2139, duration = 18}
local spell9 = {spellId = 1766, duration = 30, backdropColor = {1, 1, 0, .8}}

addon.spellBars.showSpell("friendlySpells", spell1)
addon.spellBars.showSpell("friendlySpells", spell2)
addon.spellBars.showSpell("friendlySpells", spell3)
addon.spellBars.showSpell("friendlySpells", spell4)
addon.spellBars.showSpell("friendlySpells", spell5)
addon.spellBars.showSpell("friendlySpells", spell6)
addon.spellBars.showSpell("friendlySpells", spell7)
addon.spellBars.showSpell("friendlySpells", spell8)
addon.spellBars.showSpell("friendlySpells", spell9)

addon.spellBars.showSpell("enemySpells", spell9)
addon.spellBars.showSpell("enemySpells", spell8)
addon.spellBars.showSpell("enemySpells", spell7)
addon.spellBars.showSpell("enemySpells", spell6)
addon.spellBars.showSpell("enemySpells", spell5)
addon.spellBars.showSpell("enemySpells", spell4)
addon.spellBars.showSpell("enemySpells", spell3)
addon.spellBars.showSpell("enemySpells", spell2)
addon.spellBars.showSpell("enemySpells", spell1)
