Version: 1.0

Author: Rokk (Demon Soul)

RokksSpellPlates is a library to display spells on nameplates. It is not intended to be used as a standalone addon, but rather used in the development of other addons.

To use RokksSpellPlates

* Include RokksSpellPlates.xml in your toc file
* Create a settings object, see Example.lua
* Initialize SpellPlates with your settings object
* The library attaches a table named spellPlates to your addon
* Call spellPlates.showSpell(UnitGuid, SpellId, Duration) to display a spell on a particular nameplate

---

#### showSpell (UnitGuid, SpellId, Duration)
| Parameter | Type     | Description                            |
| --------- | -------- | -------------------------------------- |
| UnitGuid  | (string) | The unit guid of a player or npc       |
| SpellId   | (number) | The spell id to display                |
| Duration  | (number) | Number of seconds to display the spell |

---

#### Example

```
local addonName, addon = ...

local spellPlateSettings = {
    ["yOffset"] = 0,
    ["maxIcons"] = 100,
    ["maxDuration"] = 60,
    ["iconSize"] = 30,
    ["iconSpacing"] = 3,
    ["borderSize"] = 2,
    ["backdropSize"] = 2,
    ["borderColor"] = {1, 0, 1, .9},        
    ["backdropColor"] = {0, 0, 0, .4},
    ["innerBorder"] = true,
    ["innerBorderColor"] = {0, 0, 0, .9},
    ["cooldownCounter"] = true,
    ["swipeAlpha"] = .3,
    ["cooldownFontColor"] = {1, 1, 0, 1},
    ["cooldownFontSize"] = 20,
}

addon.spellPlates.initialize(spellPlateSettings)

addon.spellPlates.showSpell("Creature-0-3133-2222-1924-174571-00002297C7", 47528, 8)
```
