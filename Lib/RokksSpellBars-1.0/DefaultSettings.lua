local addonName, addon = ...
addon.spellBars = addon.spellBars ~= nil and addon.spellBars or {}

addon.spellBars.defaultSettings = {
    ["locked"] = false,
    ["bars"] = {        
        ["defaultBar"] = {
            ["displayName"] = "Default Bar",
            ["refreshRate"] = .1,
            ["maxSpellQueue"] = 100,
            ["clampedToScreen"] = true,
            ["strata"] = "LOW",            
            ["position"] = {
                ["anchorPoint"] = "CENTER",
                ["relativeTo"] = "UIParent",
                ["relativePoint"] = "CENTER",
                ["xOfs"] = 0,
                ["yOfs"] = 200,
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
                ["font"] = "GameFontNormal",
                ["ellipsis"] = true,
                ["zoom"] = true,
                ["max"] = 8,
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
