Version: 1.0

Author: Rokks-Sargeras

RokksSpellBars is a library for displaying bars with a queue of spells on the screen. It is not intended to be used as a standalone addon, but rather used in the development of other addons.

* Bars with display settings are defined in a settings object and passed into the initialization call.
* Spells can be added to the queue and given a duration plus other options. The spellKey is returned when adding spells to the queue.
* Spells can be removed from the queue at any time, otherwise they will exist until their duration is complete.
* The spell bar will display up to the specified maximum number of spells in the queue. Spells beyond the maximum will still exist in the queue and will be displayed once room is available.
* RokksSpellBars will use the addon name and create the namespace %addon%.spellBars where %addon% is the name of the addon.

To use RokksSpellBars

* Include RokksSpellBars.xml in your toc file
* Create a settings object, use DefaultSettings.lua as a starting point
* Create bar objects for the number of bars you need.
    * The bar named "defaultBar" is an example, change the name
    * Adjust the settings as desired
    * Add additional bar objects with their own settings for each bar you require
* Call %addon%.spellBars.initialize(settings)
* Call %addon%.spellBars.showSpell as desired.
* Call %addon%.spellBars.removeSpell as desired. If spells are not removed manually they will automatically be removed when the duration expires.

---

### %addon%.spellBars.initialize(settings)

Used to initialize the desired bars. Create a settings object with definitions for the bars to create. Use the object in DefaultSettings.lua as a reference.

**Return Value** - true

---

### %addon%.spellBars.showSpell(barKey, spellInfo)

**barKey** - the name of the bar you want to modify in the settings spellInfo - an object that defines how to display the spell

**spellInfo** - an object that defines the spell and display criteria
```
local spellInfo = {
    spellId = 871, -- Id of the spell to add
    duration = 8, -- Duration to display the spell
    backdropColor = {0, .8, .8, .6}, -- {red, green, blue, alpha}
    borderColor = {0, 0, 0, .8}, -- {red, green, blue, alpha}
    desaturate = false, -- Whether or not to show the spell in black & white
    callback = spellRemoved -- Optional function to call when the spell expires
}
```

*Custom properties can be added into the spellInfo object. The spellInfo object will be passed back into the callback funtion when the spell expires from the queue.*

**Return Value** - the spellKey of the spell that was added

---

### %addon%.spellBars.initialize(settings)

Used to initialize the desired bars. Create a settings object with definitions for the bars to create. Use the object in DefaultSettings.lua as a reference.

---

### %addon%.spellBars.removeSpell(barKey, spellKey)

**barKey** - the name of the bar you want to modify in the settings

**spellKey** - the spellKey of the spell you wish to remove

**Return Value** - true if the spell was removed, otherwise false
