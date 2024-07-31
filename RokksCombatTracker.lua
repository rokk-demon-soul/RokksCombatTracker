local addonName, addon = ...

addon.WoWInterfaceVersion = select(4, GetBuildInfo())
addon.version = "v1.1 Beta"
addon.registerEvents()
