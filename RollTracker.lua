-------------------------------------------------------------------------------
-- Dice Master (C) 2019 <The League of Lordaeron> - Moon Guard
-------------------------------------------------------------------------------

--
-- Roll tracker interface.
--

local Me = DiceMaster4
local Profile = Me.Profile

-------------------------------------------------------------------------------
local MAJOR, MINOR = "HereBeDragons-Pins-2.0", 16 
local HBD = LibStub("HereBeDragons-2.0")
local HBDPins = LibStub("HereBeDragons-Pins-2.0")

---------------------------------------------------------

if not Me.SavedRolls then
	Me.SavedRolls = {}
end
Me.HistoryRolls = {}

local WORLD_MARKER_NAMES = {
	"|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_1:14:14|t |cffffff00Gold|r World Marker"; -- [1]
	"|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_2:14:14|t |cffff7f3fOrange|r World Marker"; -- [2]
	"|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_3:14:14|t |cffa335eePurple|r World Marker"; -- [3]
	"|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_4:14:14|t |cff1eff00Green|r World Marker"; -- [4]
	"|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_5:14:14|t |cffaaaaddSilver|r World Marker"; -- [5]
	"|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_6:14:14|t |cff0070ddBlue|r World Marker"; -- [6]
	"|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_7:14:14|t |cffff2020Red|r World Marker"; -- [7]
	"|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_8:14:14|t |cffffffffWhite|r World Marker"; -- [8]
}

local MAP_NODE_ICONS = {
	["PvP Alliance"] = {
		{ "Captured" },
		{ "Blacksmith", 29 },
		{ "Docks", 147 },
		{ "Emblem", 47 },
		{ "Farm", 34 },
		{ "Flag", 44 },
		{ "Flight Point", 181 },
		{ "Gate", 81 },
		{ "Graveyard", 16 },
		{ "Hangar", 142 },
		{ "Lighthouse", 168 },
		{ "Lumber Mill", 24 },
		{ "Mine", 19 },
		{ "Mogu", 211 },
		{ "Mogu Gate", 216 },
		{ "Oil Refinery", 152 },
		{ "Stables", 39 },
		{ "Tower", 12 },
		{ "Workshop", 137 },
		{ "Capture" },
		{ "Blacksmith", 28 },
		{ "Docks", 148 },
		{ "Emblem", 48 },
		{ "Farm", 33 },
		{ "Graveyard", 5 },
		{ "Hangar", 143 },
		{ "Lighthouse", 171 },
		{ "Lumber Mill", 23 },
		{ "Mine", 18 },
		{ "Mogu", 214 },
		{ "Mogu Gate", 219 },
		{ "Oil Refinery", 153 },
		{ "Stables", 38 },
		{ "Tower", 10 },
		{ "Workshop", 138 },
		{ "Destroyed" },
		{ "Gate", 82 },
		{ "Tower", 51 },
		{ "Tower 2", 52 },
		{ "Open" },
		{ "Gate", 83 },
	},
	["PvP Horde"] = {
		{ "Captured" },
		{ "Blacksmith", 31 },
		{ "Docks", 149 },
		{ "Emblem", 49 },
		{ "Farm", 36 },
		{ "Flag", 45 },
		{ "Flight Point", 180 },
		{ "Gate", 78 },
		{ "Graveyard", 14 },
		{ "Hangar", 144 },
		{ "Lighthouse", 169 },
		{ "Lumber Mill", 26 },
		{ "Mine", 21 },
		{ "Mogu", 212 },
		{ "Mogu Gate", 217 },
		{ "Oil Refinery", 154 },
		{ "Stables", 41 },
		{ "Tower", 11 },
		{ "Workshop", 139 },
		{ "Capture" },
		{ "Blacksmith", 30 },
		{ "Docks", 150 },
		{ "Emblem", 50 },
		{ "Farm", 35 },
		{ "Graveyard", 15 },
		{ "Hangar", 145 },
		{ "Lighthouse", 172 },
		{ "Lumber Mill", 25 },
		{ "Mine", 20 },
		{ "Mogu", 215 },
		{ "Mogu Gate", 220 },
		{ "Oil Refinery", 155 },
		{ "Stables", 40 },
		{ "Tower", 13 },
		{ "Workshop", 140 },
		{ "Destroyed" },
		{ "Gate", 79 },
		{ "Tower 1", 53 },
		{ "Tower 2", 54 },
		{ "Open" },
		{ "Gate", 80 },
	},
	["PvP Neutral"] = {
		{ "Captured" },
		{ "Blacksmith", 27 },
		{ "Docks", 146 },
		{ "Farm", 32 },
		{ "Flag", 46 },
		{ "Flag 2", 08 },
		{ "Flight Point", 179 },
		{ "Gate", 75 },
		{ "Gate Yellow", 103 },
		{ "Gate Purple", 106 },
		{ "Gate Green", 109 },
		{ "Graveyard", 09 },
		{ "Hangar", 141 },
		{ "House", 06 },
		{ "Lighthouse", 170 },
		{ "Lumber Mill", 22 },
		{ "Mine", 17 },
		{ "Mogu", 213 },
		{ "Mogu Gate", 218 },
		{ "Oil Refinery", 151 },
		{ "Stables", 37 },
		{ "Tower", 07 },
		{ "Tower Yellow", 132 },
		{ "Tower Green", 129 },
		{ "Workshop", 136 },
		{ "Destroyed" },
		{ "Gate", 76 },
		{ "Gate Yellow", 104 },
		{ "Gate Purple", 107 },
		{ "Gate Green", 110 },
		{ "Tower 1", 55 },
		{ "Tower 2", 56 },
		{ "Tower Yellow 1", 133 },
		{ "Tower Yellow 2", 134 },
		{ "Tower Green 1", 130 },
		{ "Tower Green 2", 131 },
		{ "Open" },
		{ "Gate", 77 },
		{ "Gate Yellow", 105 },
		{ "Gate Purple", 108 },
		{ "Gate Green", 111 },
	},
	["Holiday"] = {
		{ "Darkmoon Faire", 182 },
		{ "Lunar Festival", 183 },
		{ "Hallow's End 1", 184 },
		{ "Hallow's End 2", 185 },
		{ "Midsummer Festival 1", 186 },
		{ "Midsummer Festival 2", 187 },
		{ "Midsummer Festival 3", 188 },
	},
	["Numbers"] = {
		{ "Zero", 112 },
		{ "One", 113 },
		{ "Two", 114 },
		{ "Three", 115 },
		{ "Four", 116 },
		{ "Five", 117 },
		{ "Six", 118 },
		{ "Seven", 119 },
		{ "Eight", 120 },
		{ "Nine", 121 },
	},
	["Tracking"] = {
		{ "Ammunition Vendor", "Interface/MINIMAP/TRACKING/Ammunition"},
		{ "Archaeology Blob", "Interface/MINIMAP/TRACKING/ArchBlob" },
		{ "Auctioneer", "Interface/MINIMAP/TRACKING/Auctioneer" },
		{ "Banker", "Interface/MINIMAP/TRACKING/Banker" },
		{ "Barbershop", "Interface/MINIMAP/TRACKING/Barbershop" },
		{ "Battle Master", "Interface/MINIMAP/TRACKING/BattleMaster" },
		{ "Class Trainer", "Interface/MINIMAP/TRACKING/Class" },
		{ "Flight Master", "Interface/MINIMAP/TRACKING/FlightMaster" },
		{ "Focus", "Interface/MINIMAP/TRACKING/Focus" },
		{ "Food Vendor", "Interface/MINIMAP/TRACKING/Food" },
		{ "Innkeeper", "Interface/MINIMAP/TRACKING/Innkeeper" },
		{ "Mailbox", "Interface/MINIMAP/TRACKING/Mailbox" },
		{ "None", "Interface/MINIMAP/TRACKING/None" },
		{ "Poison Vendor", "Interface/MINIMAP/TRACKING/Poisons" },
		{ "Profession Trainer", "Interface/MINIMAP/TRACKING/Profession" },
		{ "Quest Blob", "Interface/MINIMAP/TRACKING/QuestBlob" },
		{ "Reagent Vendor", "Interface/MINIMAP/TRACKING/Reagents" },
		{ "Repairs", "Interface/MINIMAP/TRACKING/Repair" },
		{ "Stable Master", "Interface/MINIMAP/TRACKING/StableMaster" },
		{ "Target", "Interface/MINIMAP/TRACKING/Target" },
		{ "Transmogrifier", "Interface/MINIMAP/TRACKING/Transmogrifier" },
		{ "Trivial Quest", "Interface/MINIMAP/TRACKING/TrivialQuests" },
		{ "Wild Battle Pet", "Interface/MINIMAP/TRACKING/WildBattlePet" },
	},
	["Instance"] = {
		path = "Interface/Minimap/ObjectIconsAtlas",
		x = 1024,
		y = 512,
		{ "Dungeon", 22, 22, 0.133789, 0.155273, 0.894531, 0.9375 },
		{ "Raid", 22, 22, 0.133789, 0.155273, 0.941406, 0.984375 },
	},
	["Azerite"] = {
		path = "Interface/Minimap/ObjectIconsAtlas",
		x = 1024,
		y = 512,
		{ "Azerite Boss", 32, 32, 0.507812, 0.539062, 0.400391, 0.462891 },
		{ "Azerite Chest", 32, 32, 0.507812, 0.539062, 0.466797, 0.529297 },
		{ "Azerite Ready", 32, 32, 0.474609, 0.505859, 0.537109, 0.599609 },
		{ "Azerite Spawning", 32, 32, 0.474609, 0.505859, 0.603516, 0.666016 },
	},
	["Legion Invasion"] = {
		path = "Interface/Minimap/ObjectIconsAtlas",
		x = 1024,
		y = 512,
		{ "Demon Invasion 1", 32, 32, 0.575195, 0.606445, 0.00195312, 0.0644531 },
		{ "Demon Invasion 2", 32, 32, 0.608398, 0.639648, 0.00195312, 0.0644531 },
		{ "Demon Invasion 3", 32, 32, 0.641602, 0.672852, 0.00195312, 0.0644531 },
		{ "Demon Invasion 4", 32, 32, 0.674805, 0.706055, 0.00195312, 0.0644531 },
		{ "Demon Invasion 5", 32, 32, 0.708008, 0.739258, 0.00195312, 0.0644531 },
		{ "Rift 1", 27, 26, 0.133789, 0.160156, 0.519531, 0.570312 },
		{ "Rift 2", 33, 32, 0.507812, 0.540039, 0.00195312, 0.0644531 },
	},
	["Vignettes"] = {
		path = "Interface/Minimap/ObjectIconsAtlas",
		x = 1024,
		y = 512,
		{ "Event", 32, 32, 0.873047, 0.904297, 0.267578, 0.330078 },
		{ "EventElite", 32, 32, 0.90625, 0.9375, 0.267578, 0.330078 },
		{ "KillElite", 32, 32, 0.640625, 0.671875, 0.333984, 0.396484 },
		{ "Loot", 32, 32, 0.640625, 0.671875, 0.400391, 0.462891 },
		{ "LootElite", 32, 32, 0.640625, 0.671875, 0.466797, 0.529297 },
	},
	["Vehicles"] = {
		path = "Interface/Minimap/ObjectIconsAtlas",
		x = 1024,
		y = 512,
		{ "Acherus", 64, 64, 0.0693359, 0.131836, 0.517578, 0.642578 },
		{ "Air Alliance", 64, 64, 0.0693359, 0.131836, 0.130859, 0.255859 },
		{ "Air Horde", 64, 64, 0.0693359, 0.131836, 0.259766, 0.384766 },
		{ "Air Occupied", 32, 32, 0.806641, 0.837891, 0.201172, 0.263672 },
		{ "Air Unoccupied", 32, 32, 0.839844, 0.871094, 0.201172, 0.263672 },
		{ "Arrow", 32, 32, 0.607422, 0.638672, 0.732422, 0.794922 },
		{ "Ball Cyan", 32, 32, 0.640625, 0.671875, 0.267578, 0.330078 },
		{ "Ball Green", 32, 32, 0.673828, 0.705078, 0.267578, 0.330078 },
		{ "Ball Orange", 32, 32, 0.707031, 0.738281, 0.267578, 0.330078 },
		{ "Ball Purple", 32, 32, 0.740234, 0.771484, 0.267578, 0.330078 },
		{ "Boat Alliance", 64, 64, 0.000976562, 0.0634766, 0.654297, 0.779297 },
		{ "Boat Horde", 64, 64, 0.000976562, 0.0634766, 0.783203, 0.908203 },
		{ "Carriage", 64, 64, 0.0693359, 0.131836, 0.388672, 0.513672 },
		{ "Cart Alliance", 32, 32, 0.873047, 0.904297, 0.201172, 0.263672 },
		{ "Cart Horde", 32, 32, 0.607422, 0.638672, 0.599609, 0.662109 },
		{ "Demon Ship", 31, 56, 0.133789, 0.164062, 0.00195312, 0.111328 },
		{ "Demon Ship East", 56, 31, 0.000976562, 0.0556641, 0.912109, 0.972656 },
		{ "Ground Occupied", 32, 32, 0.90625, 0.9375, 0.201172, 0.263672 },
		{ "Ground Unoccupied", 32, 32, 0.939453, 0.970703, 0.201172, 0.263672 },
		{ "Grummle Convoy", 32, 32, 0.607422, 0.638672, 0.267578, 0.330078 },
		{ "Hammer Gold 1", 32, 32, 0.607422, 0.638672, 0.400391, 0.462891 },
		{ "Hammer Gold 2", 32, 32, 0.607422, 0.638672, 0.466797, 0.529297 },
		{ "Hammer Gold 3", 32, 32, 0.607422, 0.638672, 0.533203, 0.595703 },
		{ "Hammer Gold", 32, 32, 0.607422, 0.638672, 0.333984, 0.396484 },
		{ "Mine Cart", 32, 32, 0.607422, 0.638672, 0.798828, 0.861328 },
		{ "Mine Cart Blue", 32, 32, 0.607422, 0.638672, 0.865234, 0.927734 },
		{ "Mine Cart Red", 32, 32, 0.607422, 0.638672, 0.931641, 0.994141 },
		{ "Mogu", 32, 32, 0.607422, 0.638672, 0.666016, 0.728516 },
		{ "Trap Gold", 32, 32, 0.773438, 0.804688, 0.267578, 0.330078 },
		{ "Trap Grey", 32, 32, 0.806641, 0.837891, 0.267578, 0.330078 },
		{ "Trap Red", 32, 32, 0.839844, 0.871094, 0.267578, 0.330078 },
	},
	["Warfront Alliance"] = {
		path = "Interface/Minimap/ObjectIconsAtlas",
		x = 1024,
		y = 512,
		{ "Constructed" },
		{ "Altar", 37, 35, 0.28418, 0.320312, 0.0742188, 0.142578 },
		{ "Armory", 37, 35, 0.246094, 0.282227, 0.00195312, 0.0703125 },
		{ "Banner", 37, 35, 0.398438, 0.43457, 0.291016, 0.359375 },
		{ "Barracks", 37, 35, 0.246094, 0.282227, 0.146484, 0.214844 },
		{ "Keep", 37, 35, 0.28418, 0.320312, 0.21875, 0.287109 },
		{ "LumberMill", 37, 35, 0.398438, 0.43457, 0.435547, 0.503906 },
		{ "Mine", 37, 35, 0.398438, 0.43457, 0.580078, 0.648438 },
		{ "Tower", 37, 35, 0.28418, 0.320312, 0.363281, 0.431641 },
		{ "Workshop", 37, 35, 0.28418, 0.320312, 0.507812, 0.576172 },
		{ "Under Construction" },
		{ "Altar", 37, 35, 0.246094, 0.282227, 0.580078, 0.648438 },
		{ "Armory", 37, 35, 0.246094, 0.282227, 0.291016, 0.359375 },
		{ "Barracks", 37, 35, 0.246094, 0.282227, 0.435547, 0.503906 },
		{ "Keep", 37, 35, 0.246094, 0.282227, 0.724609, 0.792969 },
		{ "Workshop", 37, 35, 0.246094, 0.282227, 0.869141, 0.9375 },
	},
	["Warfront Horde"] = {
		path = "Interface/Minimap/ObjectIconsAtlas",
		x = 1024,
		y = 512,
		{ "Constructed" },
		{ "Altar", 37, 35, 0.360352, 0.396484, 0.652344, 0.720703 },
		{ "Armory", 37, 35, 0.322266, 0.358398, 0.580078, 0.648438 },
		{ "Banner", 37, 35, 0.436523, 0.472656, 0.21875, 0.287109 },
		{ "Barracks", 37, 35, 0.322266, 0.358398, 0.724609, 0.792969 },
		{ "Keep", 37, 35, 0.360352, 0.396484, 0.796875, 0.865234 },
		{ "Lumber Mill", 37, 35, 0.436523, 0.472656, 0.363281, 0.431641 },
		{ "Mine", 37, 35, 0.436523, 0.472656, 0.507812, 0.576172 },
		{ "Tower", 37, 35, 0.398438, 0.43457, 0.00195312, 0.0703125 },
		{ "Workshop", 37, 35, 0.398438, 0.43457, 0.146484, 0.214844 },
		{ "Under Construction" },
		{ "Altar", 37, 35, 0.360352, 0.396484, 0.21875, 0.287109 },
		{ "Armory", 37, 35, 0.322266, 0.358398, 0.869141, 0.9375 },
		{ "Barracks", 37, 35, 0.360352, 0.396484, 0.0742188, 0.142578 },
		{ "Keep", 37, 35, 0.360352, 0.396484, 0.363281, 0.431641 },
		{ "Workshop", 37, 35, 0.360352, 0.396484, 0.507812, 0.576172 },
	},
	["Warfront Neutral"] = {
		path = "Interface/Minimap/ObjectIconsAtlas",
		x = 1024,
		y = 512,
		{ "Empty" },
		{ "Altar", 37, 35, 0.322266, 0.358398, 0.00195312, 0.0703125 },
		{ "Armory", 37, 35, 0.28418, 0.320312, 0.652344, 0.720703 },
		{ "Banner", 37, 35, 0.398438, 0.43457, 0.724609, 0.792969 },
		{ "Barracks", 37, 35, 0.28418, 0.320312, 0.796875, 0.865234 },
		{ "Keep", 37, 35, 0.322266, 0.358398, 0.146484, 0.214844 },
		{ "Lumber Mill", 37, 35, 0.398438, 0.43457, 0.869141, 0.9375 },
		{ "Mine", 37, 35, 0.436523, 0.472656, 0.0742188, 0.142578 },
		{ "Tower", 37, 35, 0.322266, 0.358398, 0.291016, 0.359375 },
		{ "Workshop", 37, 35, 0.322266, 0.358398, 0.435547, 0.503906 },
		{ "Neutral" },
		{ "Banner", 37, 35, 0.436523, 0.472656, 0.652344, 0.720703 },
		{ "Mine", 37, 35, 0.436523, 0.472656, 0.796875, 0.865234 },
	},
	["Alliance Garrison (Tier 1)"] = {
		path = "Interface/Garrison/AllianceGarrisonTier1",
		x = 512,
		y = 256,
		{ "Arena 1", 45, 52, 0.509766, 0.597656, 0.191406, 0.394531 },
		{ "Arena 2", 53, 43, 0.621094, 0.724609, 0.00390625, 0.171875 },
		{ "Armory 1", 63, 79, 0.00195312, 0.125, 0.304688, 0.613281 },
		{ "Armory 2", 69, 75, 0.00195312, 0.136719, 0.00390625, 0.296875 },
		{ "Barn 1", 50, 48, 0.404297, 0.501953, 0.652344, 0.839844 },
		{ "Barn 2", 49, 39, 0.728516, 0.824219, 0.00390625, 0.15625 },
		{ "Barracks", 52, 54, 0.404297, 0.505859, 0.222656, 0.433594 },
		{ "Barracks 1", 52, 54, 0.404297, 0.505859, 0.00390625, 0.214844 },
		{ "Barracks 2", 51, 52, 0.404297, 0.503906, 0.441406, 0.644531 },
		{ "Farm", 29, 37, 0.601562, 0.658203, 0.53125, 0.675781 },
		{ "Fishing", 36, 30, 0.404297, 0.474609, 0.847656, 0.964844 },
		{ "Inn 1", 56, 57, 0.271484, 0.380859, 0.457031, 0.679688 },
		{ "Inn 2", 43, 47, 0.509766, 0.59375, 0.402344, 0.585938 },
		{ "Lumber 1", 58, 61, 0.140625, 0.253906, 0.265625, 0.503906 },
		{ "Lumber 2", 55, 63, 0.140625, 0.248047, 0.75, 0.996094 },
		{ "Mage 1", 53, 57, 0.271484, 0.375, 0.6875, 0.910156 },
		{ "Mage 2", 58, 58, 0.271484, 0.384766, 0.222656, 0.449219 },
		{ "Menagery", 42, 39, 0.509766, 0.591797, 0.59375, 0.746094 },
		{ "Mine", 55, 46, 0.509766, 0.617188, 0.00390625, 0.183594 },
		{ "Professions", 38, 43, 0.509766, 0.583984, 0.753906, 0.921875 },
		{ "Professions 2", 38, 43, 0.601562, 0.675781, 0.191406, 0.359375 },
		{ "Stables 1", 59, 59, 0.140625, 0.255859, 0.511719, 0.742188 },
		{ "Stables 2", 68, 66, 0.00195312, 0.134766, 0.621094, 0.878906 },
		{ "TownHall", 41, 40, 0.914062, 0.994141, 0.00390625, 0.160156 },
		{ "Trading 1", 42, 43, 0.828125, 0.910156, 0.00390625, 0.171875 },
		{ "Trading 2", 37, 40, 0.601562, 0.673828, 0.367188, 0.523438 },
		{ "Workshop 1", 66, 54, 0.271484, 0.400391, 0.00390625, 0.214844 },
		{ "Workshop 2", 65, 65, 0.140625, 0.267578, 0.00390625, 0.257812 },
		
	},
	["Alliance Garrison (Tier 2)"] = {
		path = "Interface/Garrison/AllianceGarrisonTier2",
		x = 512,
		y = 256,
		{ "Arena 1", 58, 58, 0.761719, 0.875, 0.289062, 0.515625 },
		{ "Arena 2", 60, 50, 0.00195312, 0.119141, 0.800781, 0.996094 },
		{ "Armory 1", 84, 99, 0.00195312, 0.166016, 0.00390625, 0.390625 },
		{ "Armory 2", 80, 101, 0.00195312, 0.158203, 0.398438, 0.792969 },
		{ "Barn 1", 48, 48, 0.646484, 0.740234, 0.535156, 0.722656 },
		{ "Barn 2", 44, 37, 0.908203, 0.994141, 0.00390625, 0.148438 },
		{ "Barracks 1", 70, 74, 0.505859, 0.642578, 0.00390625, 0.292969 },
		{ "Barracks 2", 73, 75, 0.341797, 0.484375, 0.316406, 0.609375 },
		{ "Inn 1", 63, 63, 0.505859, 0.628906, 0.300781, 0.546875 },
		{ "Inn 2", 69, 56, 0.505859, 0.640625, 0.554688, 0.773438 },
		{ "Lumber 1", 59, 61, 0.789062, 0.904297, 0.00390625, 0.242188 },
		{ "Lumber 2", 59, 47, 0.878906, 0.994141, 0.289062, 0.472656 },
		{ "Mage 1", 72, 75, 0.341797, 0.482422, 0.617188, 0.910156 },
		{ "Mage 2", 71, 71, 0.646484, 0.785156, 0.00390625, 0.28125 },
		{ "Stables 1", 73, 76, 0.169922, 0.3125, 0.695312, 0.992188 },
		{ "Stables 2", 82, 78, 0.341797, 0.501953, 0.00390625, 0.308594 },
		{ "Trading 1", 57, 61, 0.646484, 0.757812, 0.289062, 0.527344 },
		{ "Trading 2", 54, 55, 0.505859, 0.611328, 0.78125, 0.996094 },
		{ "Workshop 1", 81, 84, 0.169922, 0.328125, 0.359375, 0.6875 },
		{ "Workshop 2", 86, 89, 0.169922, 0.337891, 0.00390625, 0.351562 },
	},
	["Alliance Garrison (Tier 3)"] = {
		path = "Interface/Garrison/AllianceGarrisonTier3",
		x = 512,
		y = 512,
		{ "Arena 1", 66, 73, 0.201172, 0.330078, 0.482422, 0.625 },
		{ "Arena 2", 72, 60, 0.345703, 0.486328, 0.189453, 0.306641 },
		{ "Armory 1", 83, 95, 0.00195312, 0.164062, 0.384766, 0.570312 },
		{ "Armory 2", 76, 96, 0.00195312, 0.150391, 0.574219, 0.761719 },
		{ "Barn 1", 62, 67, 0.345703, 0.466797, 0.578125, 0.708984 },
		{ "Barn 2", 63, 67, 0.345703, 0.46875, 0.443359, 0.574219 },
		{ "Barracks 1", 92, 90, 0.431641, 0.611328, 0.00195312, 0.177734 },
		{ "Barracks 2", 100, 98, 0.00195312, 0.197266, 0.189453, 0.380859 },
		{ "Inn 1", 74, 74, 0.00195312, 0.146484, 0.765625, 0.910156 },
		{ "Inn 2", 70, 63, 0.201172, 0.337891, 0.763672, 0.886719 },
		{ "Mage 1", 72, 75, 0.201172, 0.341797, 0.189453, 0.335938 },
		{ "Mage 2", 70, 71, 0.201172, 0.337891, 0.339844, 0.478516 },
		{ "Lumber 1", 66, 67, 0.201172, 0.330078, 0.628906, 0.759766 },
		{ "Lumber 2", 66, 54, 0.201172, 0.330078, 0.890625, 0.996094 },
		{ "Stables 1", 117, 94, 0.00195312, 0.230469, 0.00195312, 0.185547 },
		{ "Stables 2", 99, 92, 0.234375, 0.427734, 0.00195312, 0.181641 },
		{ "Trading 2", 56, 63, 0.476562, 0.585938, 0.310547, 0.433594 },
		{ "Trading 1", 65, 66, 0.345703, 0.472656, 0.310547, 0.439453 },
		{ "Workshop 1", 81, 78, 0.783203, 0.941406, 0.00195312, 0.154297 },
		{ "Workshop 2", 84, 87, 0.615234, 0.779297, 0.00195312, 0.171875 },
	},
	["Horde Garrison (Tier 1)"] = {
		path = "Interface/Garrison/HordeGarrisonTier1",
		x = 512,
		y = 256,
		{ "Arena1", 45, 51, 0.371094, 0.458984, 0.777344, 0.976562 },
		{ "Arena2", 43, 45, 0.488281, 0.572266, 0.00390625, 0.179688 },
		{ "Armory1", 57, 57, 0.136719, 0.248047, 0.484375, 0.707031 },
		{ "Armory2", 56, 55, 0.257812, 0.367188, 0.00390625, 0.21875 },
		{ "Barn1", 51, 51, 0.257812, 0.357422, 0.4375, 0.636719 },
		{ "Barn2", 53, 46, 0.371094, 0.474609, 0.199219, 0.378906 },
		{ "Barracks1", 65, 70, 0.00195312, 0.128906, 0.285156, 0.558594 },
		{ "Barracks2", 67, 70, 0.00195312, 0.132812, 0.00390625, 0.277344 },
		{ "Farm1", 58, 48, 0.371094, 0.484375, 0.00390625, 0.191406 },
		{ "Fishing1", 42, 44, 0.488281, 0.570312, 0.1875, 0.359375 },
		{ "Inn1", 50, 48, 0.371094, 0.46875, 0.386719, 0.574219 },
		{ "Inn2", 50, 48, 0.371094, 0.46875, 0.582031, 0.769531 },
		{ "Lumber1", 45, 43, 0.00195312, 0.0898438, 0.820312, 0.988281 },
		{ "Lumber2", 37, 48, 0.488281, 0.560547, 0.714844, 0.902344 },
		{ "Mage1", 51, 50, 0.257812, 0.357422, 0.644531, 0.839844 },
		{ "Mage2", 52, 52, 0.257812, 0.359375, 0.226562, 0.429688 },
		{ "Mine1", 52, 36, 0.257812, 0.359375, 0.847656, 0.988281 },
		{ "Profession1", 40, 38, 0.658203, 0.736328, 0.00390625, 0.152344 },
		{ "Profession2", 42, 43, 0.488281, 0.570312, 0.539062, 0.707031 },
		{ "Profession3", 43, 42, 0.488281, 0.572266, 0.367188, 0.53125 },
		{ "Stables1", 57, 55, 0.136719, 0.248047, 0.714844, 0.929688 },
		{ "Stables2", 62, 63, 0.00195312, 0.123047, 0.566406, 0.8125 },
		{ "Trading1", 37, 37, 0.740234, 0.8125, 0.00390625, 0.148438 },
		{ "Trading2", 40, 39, 0.576172, 0.654297, 0.00390625, 0.15625 },
		{ "Workshop1", 60, 60, 0.136719, 0.253906, 0.00390625, 0.238281 },
		{ "Workshop2", 56, 59, 0.136719, 0.246094, 0.246094, 0.476562 },
	},
	["Horde Garrison (Tier 2)"] = {
		path = "Interface/Garrison/HordeGarrisonTier2",
		x = 512,
		y = 256,
		{ "Arena1", 59, 55, 0.5625, 0.677734, 0.238281, 0.453125 },
		{ "Arena2", 54, 55, 0.451172, 0.556641, 0.511719, 0.726562 },
		{ "Armory1", 64, 68, 0.173828, 0.298828, 0.578125, 0.84375 },
		{ "Armory2", 65, 61, 0.320312, 0.447266, 0.00390625, 0.242188 },
		{ "Barn1", 59, 58, 0.683594, 0.798828, 0.00390625, 0.230469 },
		{ "Barn2", 53, 45, 0.5625, 0.666016, 0.664062, 0.839844 },
		{ "Barracks1", 61, 60, 0.320312, 0.439453, 0.25, 0.484375 },
		{ "Barracks2", 61, 60, 0.320312, 0.439453, 0.492188, 0.726562 },
		{ "Inn1", 60, 57, 0.802734, 0.919922, 0.00390625, 0.226562 },
		{ "Inn2", 60, 58, 0.5625, 0.679688, 0.00390625, 0.230469 },
		{ "Lumber1", 55, 66, 0.451172, 0.558594, 0.00390625, 0.261719 },
		{ "Lumber2", 54, 60, 0.451172, 0.556641, 0.269531, 0.503906 },
		{ "Mage1", 76, 76, 0.00195312, 0.150391, 0.652344, 0.949219 },
		{ "Mage2", 73, 74, 0.173828, 0.316406, 0.00390625, 0.292969 },
		{ "Stables1", 62, 59, 0.320312, 0.441406, 0.734375, 0.964844 },
		{ "Stables2", 65, 69, 0.173828, 0.300781, 0.300781, 0.570312 },
		{ "Trading1", 54, 52, 0.451172, 0.556641, 0.734375, 0.9375 },
		{ "Trading2", 54, 50, 0.5625, 0.667969, 0.460938, 0.65625 },
		{ "Workshop1", 79, 77, 0.00195312, 0.15625, 0.34375, 0.644531 },
		{ "Workshop2", 86, 85, 0.00195312, 0.169922, 0.00390625, 0.335938 },
	},
	["Horde Garrison (Tier 3)"] = {
		path = "Interface/Garrison/HordeGarrisonTier3",
		x = 512,
		y = 512,
		{ "Arena1", 70, 65, 0.476562, 0.613281, 0.00390625, 0.257812 },
		{ "Arena2", 55, 69, 0.736328, 0.84375, 0.265625, 0.535156 },
		{ "Armory1", 65, 71, 0.322266, 0.449219, 0.613281, 0.890625 },
		{ "Armory2", 65, 63, 0.605469, 0.732422, 0.265625, 0.511719 },
		{ "Barn1", 64, 65, 0.476562, 0.601562, 0.265625, 0.519531 },
		{ "Barn2", 72, 50, 0.847656, 0.988281, 0.265625, 0.460938 },
		{ "Barracks1", 76, 88, 0.00195312, 0.150391, 0.335938, 0.679688 },
		{ "Barracks2", 82, 76, 0.00195312, 0.162109, 0.6875, 0.984375 },
		{ "Inn1", 70, 65, 0.617188, 0.753906, 0.00390625, 0.257812 },
		{ "Inn2", 60, 67, 0.476562, 0.59375, 0.527344, 0.789062 },
		{ "Lumber1", 68, 62, 0.757812, 0.890625, 0.00390625, 0.246094 },
		{ "Lumber2", 59, 51, 0.476562, 0.591797, 0.796875, 0.996094 },
		{ "Mage1", 76, 75, 0.169922, 0.318359, 0.679688, 0.972656 },
		{ "Mage2", 73, 73, 0.322266, 0.464844, 0.320312, 0.605469 },
		{ "Stables1", 77, 79, 0.322266, 0.472656, 0.00390625, 0.3125 },
		{ "Stables2", 76, 83, 0.169922, 0.318359, 0.347656, 0.671875 },
		{ "Trading1", 66, 54, 0.736328, 0.865234, 0.542969, 0.753906 },
		{ "Trading2", 63, 63, 0.605469, 0.728516, 0.519531, 0.765625 },
		{ "Workshop1", 76, 86, 0.169922, 0.318359, 0.00390625, 0.339844 },
		{ "Workshop2", 84, 83, 0.00195312, 0.166016, 0.00390625, 0.328125 },
	},
	["World Markers"] = {
		{ "Star", "Interface/TargetingFrame/UI-RaidTargetingIcon_1" },
		{ "Circle", "Interface/TargetingFrame/UI-RaidTargetingIcon_2" },
		{ "Diamond", "Interface/TargetingFrame/UI-RaidTargetingIcon_3" },
		{ "Triangle", "Interface/TargetingFrame/UI-RaidTargetingIcon_4" },
		{ "Moon", "Interface/TargetingFrame/UI-RaidTargetingIcon_5" },
		{ "Square", "Interface/TargetingFrame/UI-RaidTargetingIcon_6" },
		{ "X", "Interface/TargetingFrame/UI-RaidTargetingIcon_7" },
		{ "Skull", "Interface/TargetingFrame/UI-RaidTargetingIcon_8" },
	},
	["Other"] = {
		path = "Interface/Minimap/ObjectIconsAtlas",
		x = 1024,
		y = 512,
		{ "Doors" },
		{ "Door", 25, 24, 0.133789, 0.158203, 0.574219, 0.621094 },
		{ "Door Locked", 32, 32, 0.806641, 0.837891, 0.400391, 0.462891 },
		{ "Door Down", 25, 24, 0.133789, 0.158203, 0.625, 0.671875 },
		{ "Door Left", 25, 24, 0.133789, 0.158203, 0.675781, 0.722656 },
		{ "Door Right", 25, 24, 0.133789, 0.158203, 0.726562, 0.773438 },
		{ "Door Up", 25, 24, 0.133789, 0.158203, 0.777344, 0.824219 },
		{ "Quests" },
		{ "Quest Normal", 32, 32, 0.574219, 0.605469, 0.267578, 0.330078 },
		{ "Quest Daily", 32, 32, 0.873047, 0.904297, 0.134766, 0.197266 },
		{ "Quest Legendary", 32, 32, 0.939453, 0.970703, 0.134766, 0.197266 },
		{ "Quest Flight Path", 32, 32, 0.839844, 0.871094, 0.134766, 0.197266 },
		{ "Quest Objective", 32, 32, 0.574219, 0.605469, 0.333984, 0.396484 },
		{ "Quest Normal Turnin", 32, 32, 0.574219, 0.605469, 0.599609, 0.662109 },
		{ "Quest Daily Turnin", 32, 32, 0.574219, 0.605469, 0.400391, 0.462891 },
		{ "Quest Legendary Turnin", 32, 32, 0.574219, 0.605469, 0.201172, 0.263672 },
		{ "Flight Paths" },
		{ "Flight Path Alliance", 18, 18, 0.322266, 0.339844, 0.941406, 0.976562 },
		{ "Flight Path Horde", 18, 18, 0.360352, 0.37793, 0.941406, 0.976562 },
		{ "Flight Path Neutral", 18, 18, 0.398438, 0.416016, 0.941406, 0.976562 },
		{ "Flight Path Boat Alliance", 27, 27, 0.133789, 0.160156, 0.349609, 0.402344 },
		{ "Flight Path Boat Horde", 27, 27, 0.133789, 0.160156, 0.40625, 0.458984 },
		{ "Flight Path Boat Neutral", 27, 27, 0.133789, 0.160156, 0.462891, 0.515625 },
		{ "Flight Path Argus", 32, 32, 0.807617, 0.838867, 0.00195312, 0.0644531 },
		{ "Flight Path Ferry", 32, 32, 0.84082, 0.87207, 0.00195312, 0.0644531 },
		{ "Portals" },
		{ "Mage Portal Alliance", 32, 32, 0.507812, 0.539062, 0.865234, 0.927734 },
		{ "Mage Portal Horde", 32, 32, 0.507812, 0.539062, 0.931641, 0.994141 },
		{ "Warlock Portal Alliance", 32, 32, 0.673828, 0.705078, 0.666016, 0.728516 },
		{ "Warlock Portal Horde", 32, 32, 0.673828, 0.705078, 0.732422, 0.794922 },
		{ "Shadowlands" },
		{ "Soul Spirit Ghost", 32, 34, 0.474609, 0.505859, 0.00195312, 0.0683594 },
		{ "Torghast", 27, 31, 0.0693359, 0.125977, 0.646484, 0.767578 },
	},
	["Ember Court"] = {
		path = "Interface/Minimap/ObjectIconsAtlas",
		x = 1024,
		y = 512,
		{ " Alexandros Mograine", 36, 36, 0.166016, 0.201172, 0.0917969, 0.162109 },
		{ " Baroness Vashj", 36, 36, 0.166016, 0.201172, 0.166016, 0.236328 },
		{ " Choofa", 36, 36, 0.166016, 0.201172, 0.240234, 0.310547 },
		{ " Countess", 36, 36, 0.166016, 0.201172, 0.314453, 0.384766 },
		{ " Cryptkeeper Kassir", 36, 36, 0.166016, 0.201172, 0.388672, 0.458984 },
		{ " Droman Aliothe", 36, 36, 0.166016, 0.201172, 0.462891, 0.533203 },
		{ " Grandmaster Vole", 36, 36, 0.166016, 0.201172, 0.537109, 0.607422 },
		{ " Hunt Captain Korayn", 36, 36, 0.166016, 0.201172, 0.611328, 0.681641 },
		{ " Kleia", 36, 36, 0.166016, 0.201172, 0.685547, 0.755859 },
		{ " Lady Moonberry", 36, 36, 0.166016, 0.201172, 0.759766, 0.830078 },
		{ " Mikanikos", 36, 36, 0.166016, 0.201172, 0.833984, 0.904297 },
		{ " Plague Deviser Marileth", 36, 36, 0.166016, 0.201172, 0.908203, 0.978516 },
		{ " Polemarch Adrestes", 36, 36, 0.203125, 0.238281, 0.154297, 0.224609 },
		{ " Prince Renathal", 36, 36, 0.203125, 0.238281, 0.228516, 0.298828 },
		{ " Rendle", 36, 36, 0.203125, 0.238281, 0.302734, 0.373047 },
		{ " Sika", 36, 36, 0.203125, 0.238281, 0.376953, 0.447266 },
		{ " Stonehead", 36, 36, 0.203125, 0.238281, 0.451172, 0.521484 },
	},
}

StaticPopupDialogs["DICEMASTER4_CLEARNOTES"] = {
  text = "Do you want to clear the notes field?",
  button1 = "Yes",
  button2 = "No",
  OnAccept = function (self, data)
	if Me.IsLeader() then
		DiceMasterDMNotesDMNotes.EditBox:SetText("")
		DiceMasterDMNotesDMNotes.EditBox:ClearFocus()
	end
  end,
  timeout = 0,
  whileDead = true,
  hideOnEscape = true,
  preferredIndex = 3,
}

StaticPopupDialogs["DICEMASTER4_GRANTEXPERIENCE"] = {
  text = "Experience Amount:",
  button1 = "Accept",
  button2 = "Cancel",
  OnShow = function (self, data)
    self.editBox:SetText("10")
	self.editBox:HighlightText()
  end,
  OnAccept = function (self, data)
    local text = tonumber(self.editBox:GetText()) or 0
	if text == "" or ( tonumber(text) > 100 ) or text == 0 then
		UIErrorsFrame:AddMessage( "Invalid amount.", 1.0, 0.0, 0.0, 53, 5 );
	else
		local msg = Me:Serialize( "EXP", {
			v = tonumber( text );
		})
		if data and UnitExists( data ) and UnitIsPlayer( data ) and UnitIsConnected( data ) then
			-- Grant a specific player experience.
			Me:SendCommMessage( "DCM4", msg, "WHISPER", data, "ALERT" )
		elseif not data and IsInGroup( LE_PARTY_CATEGORY_HOME ) then
			-- Grant all players experience.
			Me:SendCommMessage( "DCM4", msg, "RAID", nil, "ALERT" )
		else
			UIErrorsFrame:AddMessage( "Player not found.", 1.0, 0.0, 0.0, 53, 5 );
		end
	end
  end,
  hasEditBox = true,
  timeout = 0,
  whileDead = true,
  hideOnEscape = true,
  preferredIndex = 3,
}

StaticPopupDialogs["DICEMASTER4_GRANTLEVEL"] = {
  text = "Level Amount:",
  button1 = "Accept",
  button2 = "Cancel",
  OnShow = function (self, data)
    self.editBox:SetText("1")
	self.editBox:HighlightText()
  end,
  OnAccept = function (self, data)
    local text = tonumber(self.editBox:GetText()) or 0
	if text == "" or ( tonumber(text) > 100 ) or text == 0 then
		UIErrorsFrame:AddMessage( "Invalid amount.", 1.0, 0.0, 0.0, 53, 5 );
	else
		local msg = Me:Serialize( "EXP", {
			l = tonumber( text );
		})
		if data and UnitExists( data ) and UnitIsPlayer( data ) and UnitIsConnected( data ) then
			-- Grant a specific player level(s).
			Me:SendCommMessage( "DCM4", msg, "WHISPER", data, "ALERT" )
		elseif not data and IsInGroup( LE_PARTY_CATEGORY_HOME ) then
			-- Grant all players level(s).
			Me:SendCommMessage( "DCM4", msg, "RAID", nil, "ALERT" )
		else
			UIErrorsFrame:AddMessage( "Player not found.", 1.0, 0.0, 0.0, 53, 5 );
		end
	end
  end,
  hasEditBox = true,
  timeout = 0,
  whileDead = true,
  hideOnEscape = true,
  preferredIndex = 3,
}

StaticPopupDialogs["DICEMASTER4_LEVELRESETATTEMPT"] = {
  text = "Do you want to reset levels to 1? Players will lose all experience gained so far.|n|nType \"RESET\" into the field to confirm.",
  button1 = "Yes",
  button2 = "No",
  OnShow = function (self, data)
	self.button1:Disable()
	self.button1:SetScript("OnUpdate", function(self)
		if self:GetParent().editBox:GetText() == "RESET" then
			self:Enable()
		else
			self:Disable()
		end
	end)
  end,
  OnAccept = function (self, data)
	self.button1:SetScript("OnUpdate", nil)
    local msg = Me:Serialize( "EXP", {
			r = true;
		})
	if data and UnitExists( data ) and UnitIsPlayer( data ) and UnitIsConnected( data ) then
		-- Reset a specific player's level.
		Me:SendCommMessage( "DCM4", msg, "WHISPER", data, "ALERT" )
	elseif not data and IsInGroup( LE_PARTY_CATEGORY_HOME ) then
		-- Reset all players' level.
		Me:SendCommMessage( "DCM4", msg, "RAID", nil, "ALERT" )
	else
		UIErrorsFrame:AddMessage( "Player not found.", 1.0, 0.0, 0.0, 53, 5 );
	end
  end,
  hasEditBox = true,
  showAlert = true,
  timeout = 0,
  whileDead = true,
  hideOnEscape = true,
  preferredIndex = 3,
}

function Me.DiceMasterRollFrame_OnLoad(self)
	self:SetClampedToScreen( true )
	self:SetMovable(true)
	self:EnableMouse(true)
	self:RegisterForDrag( "LeftButton" )
	self:SetScript( "OnDragStart", self.StartMoving )
	self:SetScript( "OnDragStop", self.StopMovingOrSizing )
	self:SetScale(0.8)
	self:SetUserPlaced( true )
	
	self.portrait:SetTexture( "Interface/AddOns/DiceMaster/Texture/logo" )
	self.TitleText:SetText("DM Manager")
	--self.Inset:SetPoint("TOPLEFT", 4, -80);
	
	for i = 2, 17 do
		local button = CreateFrame("Button", "DiceMasterRollTrackerButton"..i, DiceMasterRollTracker, "DiceMasterRollTrackerButtonTemplate");
		button:SetID(i)
		button:SetPoint("TOP", _G["DiceMasterRollTrackerButton"..(i-1)], "BOTTOM");
	end
	
	for i = 3, 9, 2 do
		local button = CreateFrame("Button", "DiceMasterDMRosterButton"..i, DiceMasterDMRoster, "DiceMasterDMRosterButtonTemplate");
		button:SetID(i)
		button:SetPoint("TOP", _G["DiceMasterDMRosterButton"..(i-2)], "BOTTOM", 0, -2);
	end
	
	for i = 4, 10, 2 do
		local button = CreateFrame("Button", "DiceMasterDMRosterButton"..i, DiceMasterDMRoster, "DiceMasterDMRosterButtonTemplate");
		button:SetID(i)
		button:SetPoint("TOP", _G["DiceMasterDMRosterButton"..(i-2)], "BOTTOM", 0, -2);
	end
	
	for i = 2, 7 do
		local button = CreateFrame("Button", "DiceMasterMapNodesButton"..i, DiceMasterMapNodes, "DiceMasterMapNodesButtonTemplate");
		button:SetID(i)
		button:SetPoint("TOP", _G["DiceMasterMapNodesButton"..(i-1)], "BOTTOM");
	end
	
	Me.DiceMasterRollFrame_Update()
	--Me.UpdateAllMapNodes()
	
	local chat_events = { 
		"WHISPER";
		"PARTY";
		"PARTY_LEADER";
		"RAID";
		"RAID_LEADER";
	}
	
	local f = CreateFrame("Frame")
	for i, event in ipairs(chat_events) do
		f:RegisterEvent( "CHAT_MSG_" .. event )
		f:RegisterEvent( "GROUP_ROSTER_UPDATE" )
		f:RegisterEvent( "UNIT_CONNECTION" )
		f:RegisterEvent( "PARTY_LEADER_CHANGED" )
	end
	f:SetScript( "OnEvent", function( self, event, msg, sender )
		if event:match("CHAT_MSG_") then
			Me.OnChatMessage( msg, sender )
		elseif event == "GROUP_ROSTER_UPDATE" then
			if IsInGroup( LE_PARTY_CATEGORY_HOME ) and not IsInGroup( LE_PARTY_CATEGORY_INSTANCE ) then
				DiceMasterDMNotesAllowAssistants:Hide()
				DiceMasterDMNotesDMNotes.EditBox:Disable()
				if Me.IsLeader() then
					DiceMasterDMNotesAllowAssistants:Show()
					if not DiceMasterDMNotesDMNotes.EditBox.previewShown then
						DiceMasterDMNotesDMNotes.EditBox:Enable()
					end
					Me.RollTracker_ShareNoteWithParty( true )
				end
				for i = 1, GetNumGroupMembers(1) do
					-- Get level and experience data from players.
					local name, rank = GetRaidRosterInfo(i)
					if name then
						Me.Inspect_UpdatePlayer( name )
					end
				end
				Me.DiceMasterRollDetailFrame_Update()
				Me.DMRosterFrame_Update()
			end
			Me.UpdateAllMapNodes();
		elseif event == "UNIT_CONNECTION" or event == "PARTY_LEADER_CHANGED" then
			Me.DiceMasterRollDetailFrame_Update()
			Me.DMRosterFrame_Update()
			Me.RollTracker_ShareMapNodesWithParty()
		end
	end)
	
	if Me.IsLeader() then
		DiceMasterDMNotesAllowAssistants:Show()
		if not DiceMasterDMNotesDMNotes.EditBox.previewShown then
			DiceMasterDMNotesDMNotes.EditBox:Enable()
		end
		Me.RollTracker_ShareNoteWithParty()
	elseif IsInGroup( LE_PARTY_CATEGORY_HOME ) and not Me.IsLeader( false ) and not IsInGroup( LE_PARTY_CATEGORY_INSTANCE ) then
		for i = 1, GetNumGroupMembers(1) do
			local name, rank = GetRaidRosterInfo(i)
			if rank == 2 then
				local msg = Me:Serialize( "NOTREQ", {
					me = true;
				})
				Me:SendCommMessage( "DCM4", msg, "WHISPER", name, "NORMAL" )
				local msg = Me:Serialize( "MAPREQ", {
					me = true;
				})
				Me:SendCommMessage( "DCM4", msg, "WHISPER", name, "NORMAL" )
				break
			end
		end
	end
end

function Me.RollTargetDropDown_OnClick(self, arg1)
	if arg1 > 0 then
		UIDropDownMenu_SetText(DiceMasterRollTracker.selectTarget, "|TInterface/TARGETINGFRAME/UI-RaidTargetingIcon_"..arg1..":16|t")
	else
		UIDropDownMenu_SetText(DiceMasterRollTracker.selectTarget, "") 
	end
	
	if IsInGroup( LE_PARTY_CATEGORY_INSTANCE ) then
		return
	end
	
	local msg = Me:Serialize( "TARGET", {
		ta = tonumber( arg1 );
	})
	Me:SendCommMessage( "DCM4", msg, "RAID", nil, "ALERT" )
	
	if not IsInGroup( LE_PARTY_CATEGORY_HOME ) then
		if arg1 > 0 then 
			Me.OnChatMessage( "{rt"..arg1.."}", UnitName("player") ) 
		else
			for i=1,#Me.SavedRolls do
				if Me.SavedRolls[i].name == UnitName("player") then
					Me.SavedRolls[i].target = 0
					Me.DiceMasterRollFrame_Update()
					break
				end
			end
		end
	end
end

function Me.RollTargetDropDown_OnLoad(frame, level, menuList)
	local info = UIDropDownMenu_CreateInfo()
	
	info.text = "|cFFffd100Select a Target:"
	info.notClickable = true;
	info.notCheckable = true;
	UIDropDownMenu_AddButton(info, level)
	info.notClickable = false;
	info.disabled = false;
	
	for i = 1, 8 do
	   info.text = WORLD_MARKER_NAMES[i];
	   info.arg1 = i;
	   info.notCheckable = true;
	   info.func = Me.RollTargetDropDown_OnClick;
	   UIDropDownMenu_AddButton(info, level)
	end
	
	info.text = "No World Marker";
	info.arg1 = 0;
	info.notCheckable = true;
	info.func = Me.RollTargetDropDown_OnClick;
	UIDropDownMenu_AddButton(info, level)
end

function DiceMasterRollTrackerButton_OnClick(self, button)
	if ( button == "LeftButton" ) then
		DiceMasterRollTracker.selected = self.rollIndex
		Me.DiceMasterRollFrame_Update()
		Me.DiceMasterRollFrameDisplayDetail( self.rollIndex )
	end
end

function Me.SortRolls( self, reversed, sortKey, sortType )
	local sort_func = function( a,b )
		if not a then
			a = 0
		end 
		if not b then
			b = 0 
		end
		if sortType == "number" then
			return tonumber( a[sortKey] ) or 0 < tonumber( b[sortKey] ) or 0
		else
			return tostring( a[sortKey] ) < tostring( b[sortKey] )
		end
	end
	if not reversed then
		self.reversed = true
	else
		sort_func = function( a,b ) 
		if not a then
			a = 0 
		end 
		if not b then 
			b = 0 
		end 
		if sortType == "number" then
			return tonumber( a[sortKey] ) > tonumber( b[sortKey] )
		else
			return tostring( a[sortKey] ) > tostring( b[sortKey] )
		end		
	end
		self.reversed = false
	end
	table.sort( Me.SavedRolls, sort_func)
	DiceMasterRollTracker.selected = nil
	
	Me.DiceMasterRollFrame_Update()
end

function Me.SortNodes( self, reversed, sortKey, sortType )
	local sort_func = function( a,b )
		if not a then
			a = 0
		end 
		if not b then
			b = 0 
		end
		if sortType == "number" then
			return tonumber( a[sortKey] ) < tonumber( b[sortKey] )
		else
			return tostring( a[sortKey] ) < tostring( b[sortKey] )
		end
	end
	if not reversed then
		self.reversed = true
	else
		sort_func = function( a,b ) 
		if not a then
			a = 0 
		end 
		if not b then 
			b = 0 
		end 
		if sortType == "number" then
			return tonumber( a[sortKey] ) > tonumber( b[sortKey] )
		else
			return tostring( a[sortKey] ) > tostring( b[sortKey] )
		end		
	end
		self.reversed = false
	end
	table.sort( Me.Profile.mapNodes, sort_func)
	DiceMasterMapNodes.selected = nil
	
	Me.UpdateAllMapNodes();
	Me.DiceMasterMapNodes_Update();
	Me.RollTracker_ShareMapNodesWithParty()
end

function Me.ColourRolls( roll )
	local r, g, b = 1, 1, 1
	local dc = tonumber(DiceMasterRollTrackerDCThreshold:GetText()) or nil
	if not roll or not dc then return r, g, b end
	
	if roll > dc then
		r, g, b = 0, 1, 0
	elseif roll < dc then
		r, g, b = 1, 0, 0
	elseif roll == dc then
		r, g, b = 1, 1, 0
	end
	return r, g, b
end

function Me.Format_TimeStamp( timestamp )
	if not timestamp then return end
	
	local hour = tonumber(timestamp:match("(%d+)%:%d+%:%d+"))
	if hour > 12 then
		timestamp = string.gsub(timestamp, hour, hour-12)
	elseif hour < 1 then
		timestamp = string.gsub(timestamp, "00", 12)
	end
	
	return timestamp
end

function Me.ColourHistoryRolls( roll )
	local r, g, b = 1, 1, 1
	local dc = tonumber(DiceMasterRollTrackerDCThreshold:GetText()) or nil
	if not tonumber(roll) or not dc then return r, g, b end
	
	g = ( roll / dc )
	r = ( dc / roll )
	b = 0
	
	return r, g, b
end

function Me.DiceMasterRollFrame_Update()
	local name, roll, rollType, time, timestamp, target;
	local rollIndex;
	if #Me.SavedRolls > 0 then
		DiceMasterRollTrackerTotals:Hide()
	else
		DiceMasterRollTrackerTotals:Show()
		DiceMasterRollTrackerTotals:SetText("No Recent Rolls")
	end
	
	if DiceMasterRollTracker.selected then
		DiceMasterRollTracker.selectedName = Me.SavedRolls[DiceMasterRollTracker.selected].name;
	end
	
	local rollOffset = FauxScrollFrame_GetOffset(DiceMasterRollTrackerScrollFrame);
	
	for i=1,17,1 do
		rollIndex = rollOffset + i;
		local button = _G["DiceMasterRollTrackerButton"..i];
		button.rollIndex = rollIndex
		local info = Me.SavedRolls[rollIndex];
		if ( info ) then
			name = info.name;
			roll = info.roll;
			rollType = info.rollType;
			time = info.time;
			timestamp = info.timestamp;
			target = info.target;			
		end
		local buttonText = _G["DiceMasterRollTrackerButton"..i.."Name"];
		buttonText:SetText(name)
		if name and UnitClass(name) then
			className, classFile, classID = UnitClass(name)
			buttonText:SetText("|TInterface/Icons/ClassIcon_"..classFile..":16|t "..name)
			buttonText:SetTextColor(RAID_CLASS_COLORS[classFile].r, RAID_CLASS_COLORS[classFile].g, RAID_CLASS_COLORS[classFile].b)
		elseif name and UnitIsPlayer(name) and not UnitIsConnected(name) then
			buttonText:SetTextColor(0.5, 0.5, 0.5)
		else
			-- It's probably a Unit Frame.
			buttonText:SetTextColor( 1, 1, 1 )
		end
		local buttonText = _G["DiceMasterRollTrackerButton"..i.."Roll"];
		buttonText:SetText(roll or "--")
		buttonText:SetTextColor(Me.ColourRolls( roll ))
		local buttonText = _G["DiceMasterRollTrackerButton"..i.."RollType"];
		if rollType == 0 or not rollType then
			buttonText:SetText("--")
		else
			buttonText:SetText(rollType)
		end
		local buttonText = _G["DiceMasterRollTrackerButton"..i.."Timestamp"];
		buttonText:SetText(Me.Format_TimeStamp( timestamp ))
		local buttonText = _G["DiceMasterRollTrackerButton"..i.."Target"];
		if target == 0 or not target then
			buttonText:SetText("")
		else
			buttonText:SetText("|TInterface/TARGETINGFRAME/UI-RaidTargetingIcon_"..target..":16|t")
		end
		
		-- Highlight the correct who
		if ( DiceMasterRollTracker.selected == rollIndex ) then
			button:LockHighlight();
		elseif DiceMasterRollFrame.DetailFrame:IsShown() and DiceMasterRollTracker.selectedName == name then
			button:LockHighlight();
		else
			button:UnlockHighlight();
		end
		
		if ( rollIndex > #Me.SavedRolls ) then
			button:Hide();
		else
			button:Show();
		end
		
	end
	
	FauxScrollFrame_Update(DiceMasterRollTrackerScrollFrame, #Me.SavedRolls, 17, 16, nil, nil, nil, nil, nil, nil, true );
end

function Me.RollTrackerColumn_SetWidth(index, width)
	_G["DiceMasterRollTrackerButton"..index.."Highlight"]:SetWidth(width);
end

function Me.DiceMasterRollDetailFrame_Update()
	local roll, rollType, time, timestamp, dice;
	local rollIndex;
	local frame = DiceMasterRollFrame.DetailFrame
	
	if Me.db.global.trackerAnchor == "RIGHT" then
		frame:ClearAllPoints()
		frame:SetPoint( "TOPLEFT", DiceMasterRollFrame, "TOPRIGHT", -8, -26 )
	else
		frame:ClearAllPoints()
		frame:SetPoint( "TOPRIGHT", DiceMasterRollFrame, "TOPLEFT", 8, -46 )
	end
	
	if ( not frame:IsShown() ) then
		return;
	end
	
	local name = DiceMasterRollTracker.selectedName or nil
	
	local numGroupMembers = GetNumGroupMembers(1)
	local found = false;
	local isUnitFrame = false;
	local unitFrameData
	
	local playerName, rank, subgroup, level, class, fileName, zone, online;
	if numGroupMembers > 1 then
		for i = 1, numGroupMembers do
			playerName, rank, subgroup, level, class, fileName, zone, online = GetRaidRosterInfo( i )
			if name == playerName then
				frame.PortraitFrame:SetAttribute( "unit", name )
				frame.PortraitFrame:SetAttribute( "type1", "target" )
				if UnitIsUnit( name, "player" ) then
					SetPortraitTexture( frame.PortraitFrame.Portrait, "player" )
				elseif UnitInRaid( name ) or UnitInParty( name ) then
					SetPortraitTexture( frame.PortraitFrame.Portrait, name )
				end
				found = true;
				break;
			end
		end
	elseif UnitIsUnit( name, "player" ) then
		frame.PortraitFrame:SetAttribute( "unit", name )
		frame.PortraitFrame:SetAttribute( "type1", "target" )
		SetPortraitTexture( frame.PortraitFrame.Portrait, "player" )
		found = true;
	elseif not found and not Me.db.char.unitframes.enable then
		-- Maybe it's a Unit Frame...?
		-- Here's where things get fun...
		
		SetPortraitTexture( frame.PortraitFrame.Portrait, "none" )
		
		local unitframes = DiceMasterUnitsPanel.unitframes
		for i=1,#unitframes do
			-- Strip the name of markers.
			local unitName = name:gsub( ".*|t ", "" )
			if unitName == unitframes[i].name:GetText() then
				frame.PortraitFrame:SetAttribute( "unit", "none" )
				frame.PortraitFrame:SetAttribute( "type1", "target" )
				SetPortraitTextureFromCreatureDisplayID( frame.PortraitFrame.Portrait, unitframes[i]:GetDisplayInfo() )
				found = true;
				isUnitFrame = true;
				unitFrameData = unitframes[i]:GetData()
				break;
			end
		end
	end
	
	if name and UnitIsPlayer( name ) then
		if rank == 2 then
			-- Group Leader Icon
			frame.PortraitFrame.Rank:SetTexture( "Interface/GROUPFRAME/UI-Group-LeaderIcon" )
		elseif rank == 1 then
			-- Group Assist Icon
			frame.PortraitFrame.Rank:SetTexture( "Interface/GROUPFRAME/UI-GROUP-ASSISTANTICON" )
		else
			frame.PortraitFrame.Rank:SetTexture( nil )
		end
		if Me.inspectData[name] then
			local store = Me.inspectData[name]
		
			if not store.experience or not store.level then
				frame.PortraitFrame.Level:SetText( 1 )
				frame.xpBar.rankText:SetText( "XP: 0/100" )
				frame.xpBar:SetValue( 0 )
				return
			end
			
			frame.PortraitFrame.Level:SetText( store.level )
			frame.PortraitFrame.Level:Show()
			frame.PortraitFrame.LevelBG:Show()
			frame.xpBar.rankText:SetText( "XP: " .. store.experience .. "/100" )
			frame.xpBar:SetValue( store.experience )
			
			if not store.health or not store.healthMax then
				frame.healthFrame.healthValue:SetText( "10/10" );
				return
			end
			
			local healthValue, healthMax, armorValue = store.health, store.healthMax, store.armor
			frame.healthFrame.healthValue:SetText( healthValue .. "/" .. healthMax );
			
			if armorValue and armorValue > 0 then
				frame.healthFrame.healthValue:SetText( healthValue.." (+"..armorValue..")/"..healthMax )
			end
		else
			frame.healthFrame.healthValue:SetText( "10/10" );
			frame.PortraitFrame.Level:SetText( 1 )
			frame.xpBar.rankText:SetText( "XP: 0/100" )
			frame.xpBar:SetValue( 0 )
		end
	elseif isUnitFrame and unitFrameData then
		frame.PortraitFrame.Level:SetText( nil )
		frame.xpBar.rankText:SetText( "XP: 0/100" )
		frame.xpBar:SetValue( 0 )
		frame.PortraitFrame.Level:Hide()
		frame.PortraitFrame.LevelBG:Hide()
		
		local healthValue, healthMax, armorValue = unitFrameData.healthCurrent, unitFrameData.healthMax, unitFrameData.armor
		frame.healthFrame.healthValue:SetText( healthValue .. "/" .. healthMax );
		
		if armorValue and armorValue > 0 then
			frame.healthFrame.healthValue:SetText( healthValue.." (+"..armorValue..")/"..healthMax )
		end
	end
	
	if not online and numGroupMembers > 1 and not isUnitFrame then
		SetDesaturation( frame.PortraitFrame.Portrait, true )
		frame.PortraitFrame.Disconnect:Show()
		frame.Name:SetTextColor(0.5, 0.5, 0.5)
	else
		SetDesaturation( frame.PortraitFrame.Portrait, false )
		frame.PortraitFrame.Disconnect:Hide()
	end
	
	if Me.HistoryRolls[name] and #Me.HistoryRolls[name] > 0 then
		frame.ListInset.Totals:Hide()
	else
		frame.ListInset.Totals:Show()
		frame.ListInset.Totals:SetText("No Recent Rolls")
		for i=1,9,1 do
			local button = _G["DiceMasterRollTrackerHistoryButton"..i];
			button:Hide()
		end
		frame.AverageText:SetText( "--" );
		frame.AverageText:SetTextColor( 1, 1, 1 )
		FauxScrollFrame_Update(DiceMasterRollFrameDetailScrollFrame, 0, 9, 16 );
		return
	end
	
	local rollOffset = FauxScrollFrame_GetOffset(DiceMasterRollFrameDetailScrollFrame);
	
	local showScrollBar = nil;
	if ( #Me.HistoryRolls[name] > 9 ) then
		showScrollBar = 1;
	end
	
	local divider = 0
	local sum = 0
	for i=1,#Me.HistoryRolls[name] do
		divider = divider + 1
		sum = sum + Me.HistoryRolls[name][i].roll
	end
	if sum == 0 then 
		sum = "--"
	else
		sum = math.floor( sum / divider )
	end
	frame.AverageText:SetText(sum);
	frame.AverageText:SetTextColor(Me.ColourHistoryRolls( sum ))
	
	for i=1,9,1 do
		rollIndex = rollOffset + i;
		local button = _G["DiceMasterRollTrackerHistoryButton"..i];
		button.rollIndex = rollIndex
		local info = Me.HistoryRolls[name][rollIndex];
		if ( info ) then
			roll = info.roll;
			rollType = info.rollType;
			time = info.time;
			timestamp = info.timestamp;
			dice = info.dice;			
		end
		local buttonText = _G["DiceMasterRollTrackerHistoryButton"..i.."Roll"];
		buttonText:SetText(roll.." ("..dice..")")
		buttonText:SetTextColor(Me.ColourHistoryRolls( roll ))
		local buttonText = _G["DiceMasterRollTrackerHistoryButton"..i.."Timestamp"];
		buttonText:SetText(Me.Format_TimeStamp( timestamp ))
		local buttonText = _G["DiceMasterRollTrackerHistoryButton"..i.."Type"];
		if rollType == 0 or not rollType then
			buttonText:SetText("--")
		else
			buttonText:SetText(rollType)
		end
		
		-- If need scrollbar resize columns
		if ( showScrollBar ) then
			buttonText:SetWidth(65);
		else
			buttonText:SetWidth(90);
		end
		
		if ( rollIndex > #Me.HistoryRolls[name] ) then
			button:Hide();
		else
			button:Show();
		end
	end
	
	FauxScrollFrame_Update(DiceMasterRollFrameDetailScrollFrame, #Me.HistoryRolls[name], 9, 16 );
end

function Me.DMRosterFrame_OnShow()		
	Me.DMRosterFrame_Update()	
end

function Me.DMRosterButton_OnClick(self, button)
	if ( button == "LeftButton" ) then		
		local name, rank, subgroup, level, class, fileName, zone, online = GetRaidRosterInfo( self.entryIndex )
		
		DiceMasterRollTracker.selected = nil
		for i = 1, #Me.SavedRolls do
			if Me.SavedRolls[i].name == name then
				DiceMasterRollTracker.selected = i;
				break;
			end
		end
		
		DiceMasterRollTracker.selectedName = name;
		Me.DiceMasterRollFrameDisplayDetail( nil, name )
		Me.DMRosterFrame_Update()
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	end
end

function Me.DMRosterFrame_Update()
	if ( not DiceMasterDMRoster:IsShown() ) then
		return;
	end
	
	DiceMasterDMRosterInset.Text:Hide()
	
	local name;
	local numGroupMembers = GetNumGroupMembers(1)
	if numGroupMembers < 1 then
		DiceMasterDMRosterInset.Text:Show()
		for i = 1, 10 do
			local button = _G["DiceMasterDMRosterButton"..i];
			button:Hide()
		end
		FauxScrollFrame_Update(DiceMasterDMRosterScrollFrame, numGroupMembers, 10, 16 );
		return
	end
	local entryIndex;
	
	local entryOffset = FauxScrollFrame_GetOffset(DiceMasterDMRosterScrollFrame);
	
	for i=1,10,1 do
		entryIndex = entryOffset + i;
		local button = _G["DiceMasterDMRosterButton"..i];
		button.entryIndex = entryIndex
		local name, rank, subgroup, level, class, fileName, zone, online = GetRaidRosterInfo(entryIndex)
		
		local buttonText = _G["DiceMasterDMRosterButton"..i.."Name"];
		buttonText:SetText(name)
		if name and UnitClass(name) then
			className, classFile, classID = UnitClass(name)
			buttonText:SetTextColor(RAID_CLASS_COLORS[classFile].r, RAID_CLASS_COLORS[classFile].g, RAID_CLASS_COLORS[classFile].b)
			button.Class:SetAtlas( "GarrMission_ClassIcon-" .. classFile )
			button.PortraitFrame:SetAttribute( "unit", name )
			button.PortraitFrame:SetAttribute( "type1", "target" )
			if UnitIsUnit( name, "player" ) then
				SetPortraitTexture( button.PortraitFrame.Portrait, "player" )
			elseif UnitInRaid( name ) or UnitInParty( name ) then
				SetPortraitTexture( button.PortraitFrame.Portrait, name )
			end
			if rank == 2 then
				-- Group Leader Icon
				button.PortraitFrame.Rank:SetTexture( "Interface/GROUPFRAME/UI-Group-LeaderIcon" )
			elseif rank == 1 then
				-- Group Assist Icon
				button.PortraitFrame.Rank:SetTexture( "Interface/GROUPFRAME/UI-GROUP-ASSISTANTICON" )
			else
				button.PortraitFrame.Rank:SetTexture( nil )
			end
		end
		
		if not online then
			SetDesaturation( button.PortraitFrame.Portrait, true )
			button.PortraitFrame.Disconnect:Show()
			buttonText:SetTextColor(0.5, 0.5, 0.5)
		else
			SetDesaturation( button.PortraitFrame.Portrait, false )
			button.PortraitFrame.Disconnect:Hide()
		end
		
		if name and Me.inspectData[name] and online then
			local store = Me.inspectData[name]
			
			if not store.experience or not store.level then
				button.PortraitFrame.Level:SetText( 1 )
				button.XPBar:SetWidth( 0 )
				return
			end
			
			button.PortraitFrame.Level:SetText( store.level )
			button.XPBar:SetWidth( 103 * ( store.experience / 100 ) )
			
			if not store.health or not store.healthMax then
				button.healthFrame.healthValue:SetText( "10/10" );
				button.healthFrame.healthBar:SetMinMaxValues( 0, 10 );
				button.healthFrame.healthBar:SetValue( 10 );
				button.healthFrame.armourBar:SetMinMaxValues( 0, 10 );
				button.healthFrame.armourBar:SetValue( 0 )
				return
			end
			
			local healthValue, healthMax, armorValue = store.health, store.healthMax, store.armor
			button.healthFrame.healthValue:SetText( healthValue .. "/" .. healthMax );
			button.healthFrame.healthBar:SetMinMaxValues( 0, healthMax );
			button.healthFrame.healthBar:SetValue( healthValue );
			
			if armorValue then
				button.healthFrame.armourBar:SetMinMaxValues( 0, healthMax );
				button.healthFrame.armourBar:SetValue( healthValue + armorValue )
			end
		elseif name and not Me.inspectData[name] and online then
			-- Request player data.
			local request_data = {
				ts = {};
				ss = {};
				bs = {};
			}
			
			local msg = Me:Serialize( "INSP", request_data )
			
			Me:SendCommMessage( "DCM4", msg, "WHISPER", name, "ALERT" )
		else
			button.PortraitFrame.Level:SetText( 1 )
			button.XPBar:SetWidth( 0 )
			button.healthFrame.healthValue:SetText( "10/10" );
			button.healthFrame.healthBar:SetMinMaxValues( 0, 10 );
			button.healthFrame.healthBar:SetValue( 10 );
			button.healthFrame.armourBar:SetMinMaxValues( 0, 10 );
			button.healthFrame.armourBar:SetValue( 0 )
		end
		
		if DiceMasterRollTracker.selectedName == name and DiceMasterRollFrame.DetailFrame:IsShown() then
			button.Selected:Show();
		else
			button.Selected:Hide();
		end
		
		if ( entryIndex > numGroupMembers ) then
			button:Hide();
		else
			button:Show();
		end
	end
	
	FauxScrollFrame_Update(DiceMasterDMRosterScrollFrame, numGroupMembers, 10, 16, nil, nil, nil, nil, nil, nil, true);
end

function Me.DiceMasterRollFrameDisplayDetail( rollIndex, name )
	local frame = DiceMasterRollFrame.DetailFrame
	
	if ( rollIndex == nil or Me.SavedRolls[rollIndex] == nil ) and not name then
		frame:Hide()
		return;
	end
	
	if not name then
		name = Me.SavedRolls[rollIndex].name
	end
	
	frame.name = name
	
	frame.Name:SetText(name);
	if name and UnitClass(name) then
		className, classFile, classID = UnitClass(name)
		frame.Name:SetText( name )
		frame.Name:SetTextColor(RAID_CLASS_COLORS[classFile].r, RAID_CLASS_COLORS[classFile].g, RAID_CLASS_COLORS[classFile].b)
		frame.Class:SetAtlas( "GarrMission_ClassIcon-" .. classFile )
		frame.Class:Show()
	elseif name and UnitIsPlayer( name ) and not UnitIsConnected(name) then
		frame.Name:SetTextColor(0.5, 0.5, 0.5)
		frame.Class:Hide()
	else
		-- It's probably a Unit Frame.
		frame.Name:SetTextColor( 1, 1, 1 )
		frame.Class:Hide()
	end
	
	Me.DiceMasterRollDetailFrame_Update()
	frame:Show()
end

local function FormatNoteField( sanitize )
	local TEXT_SUBS = {
		{"{star}", "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_1:12|t"},
		{"{circle}", "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_2:12|t"},
		{"{diamond}", "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_3:12|t"},
		{"{triangle}", "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_4:12|t"},
		{"{moon}", "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_5:12|t"},
		{"{square}", "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_6:12|t"},
		{"{x}", "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_7:12|t"},
		{"{skull}", "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_8:12|t"},
		{"<rule>", " |TInterface/Buttons/WHITE8X8:1:335|t"},
		{"<HP>", "|TInterface/AddOns/DiceMaster/Texture/health-heart:12|t"},
		{"<AR>", "|TInterface/AddOns/DiceMaster/Texture/armour-icon:12|t"},
		{"%<food%>", "|TInterface/AddOns/DiceMaster/Texture/resources:16:16:0:0:128:32:0:24:0:24|t" },
		{"%<wood%>",      "|TInterface/AddOns/DiceMaster/Texture/resources:16:16:0:0:128:32:24:48:0:24|t" },
		{"%<iron%>",      "|TInterface/AddOns/DiceMaster/Texture/resources:16:16:0:0:128:32:48:72:0:24|t" },
		{"%<leather%>",      "|TInterface/AddOns/DiceMaster/Texture/resources:16:16:0:0:128:32:72:96:0:24|t" },
		{ "%<%*%>", "|TInterface/Transmogrify/transmog-tooltip-arrow:8|t" },
	}
	
	local text = DiceMasterDMNotesDMNotes.EditBox:GetText()
	
	if not sanitize then
		for i = 1, #TEXT_SUBS do
			text = gsub( text, TEXT_SUBS[i][1], TEXT_SUBS[i][2] )
		end
		
		-- <img> </img>
		text = gsub( text, "<img>","|T" )
		text = gsub( text, "</img>",":12|t" )
		
		-- <color=rrggbb> </color>
		text = gsub( text, "<color=(.-)>","|cFF%1" )
		text = gsub( text, "</color>","|r" )
	else
		for i = 1, #TEXT_SUBS do
			text = gsub( text, TEXT_SUBS[i][2], TEXT_SUBS[i][1] )
		end
		
		-- <img> </img>
		text = gsub( text, "|T","<img>" )
		text = gsub( text, ":12|t","</img>" )
		
		-- <color=rrggbb> </color>
		text = gsub( text, "|cFF(%w%w%w%w%w%w)","<color=%1>" )
		text = gsub( text, "|r","</color>" )
	end
	
	DiceMasterDMNotesDMNotes.EditBox:SetText( text )
end

function DiceMasterNotesEditBox_OnEditFocusGained(self)
	self.Instructions:Hide()
end

function DiceMasterNotesEditBox_OnEditFocusLost(self)	
	if self:GetText() == "" then
		self.Instructions:Show()
	else
		self.Instructions:Hide()
	end
	
	if Me.IsLeader( true ) then
		Me.RollTracker_ShareNoteWithParty()
	end
end

function DiceMasterNotesEditBox_OnTextChanged(self, userInput)
	local parent = self:GetParent()
	ScrollingEdit_OnTextChanged(self, parent)
	local text = self:GetText()
	if text == "" then
		text = nil
	end
	if not userInput and not self:HasFocus() then
		DiceMasterNotesEditBox_OnEditFocusLost(self)
	end
end

function DiceMasterNotesEditBox_UpdatePreview( sanitize )
	FormatNoteField( sanitize )
	if not sanitize then
		DiceMasterDMNotesDMNotes.EditBox.previewShown = true;
		DiceMasterDMNotesDMNotes.EditBox:Disable()
	else
		DiceMasterDMNotesDMNotes.EditBox.previewShown = false;
		DiceMasterDMNotesDMNotes.EditBox:Enable()
	end
end

function DiceMasterMapNodesButton_OnClick( self, button )
	if ( button == "LeftButton" ) then
		DiceMasterMapNodes.selected = self.nodeIndex
		Me.DiceMasterMapNodes_Update()
	end
end

function Me.DiceMasterMapNodes_Update()
	local name, roll, rollType, time, timestamp, target;
	local nodeIndex;
	if #Me.Profile.mapNodes > 0 then
		DiceMasterMapNodesTotals:Hide()
	else
		DiceMasterMapNodesTotals:Show()
		DiceMasterMapNodesTotals:SetText("No Map Nodes")
		DiceMasterMapNodes.selected = nil
	end
	
	local nodeOffset = FauxScrollFrame_GetOffset(DiceMasterMapNodesScrollFrame);
	
	for i=1,7,1 do
		nodeIndex = nodeOffset + i;
		local button = _G["DiceMasterMapNodesButton"..i];
		button.nodeIndex = nodeIndex
		local info = Me.Profile.mapNodes[nodeIndex];
		if ( info ) then
			title 		= info.title;
			icon 		= info.icon;
			iconName	= info.iconName;
			description = info.description;
			coordX 		= info.coordX;
			coordY 		= info.coordY;
			mapID 		= info.mapID;
			zone		= info.zone;
			hidden		= info.hidden;
		end
		local buttonText = _G["DiceMasterMapNodesButton"..i.."Icon"];
		if type( icon ) == "table" then
			if icon[1] then
				buttonText:SetTexCoord( icon[1], icon[2], icon[3], icon[4] )
			else
				buttonText:SetTexCoord( 0, 1, 0, 1 )
			end
			buttonText:SetTexture( icon[5] )
		else
			buttonText:SetTexCoord( 0, 1, 0, 1 )
			buttonText:SetTexture( icon )
		end
		local buttonText = _G["DiceMasterMapNodesButton"..i.."Title"];
		buttonText:SetText( title )
		local buttonText = _G["DiceMasterMapNodesButton"..i.."Zone"];
		buttonText:SetText( zone )
		
		-- Highlight the correct who
		if ( DiceMasterMapNodes.selected == nodeIndex ) then
			button:LockHighlight();
		else
			button:UnlockHighlight();
		end
		
		if ( nodeIndex > #Me.Profile.mapNodes ) then
			button:Hide();
		else
			button:Show();
		end		
	end
	
	local frame = DiceMasterMapNodesInset2;
		
	if DiceMasterMapNodes.selected then
		local selectedIcon = Me.Profile.mapNodes[ DiceMasterMapNodes.selected ].icon
		local selectedIconName = Me.Profile.mapNodes[ DiceMasterMapNodes.selected ].iconName
		
		UIDropDownMenu_SetSelectedValue( frame.nodeIcon, selectedIcon )
		UIDropDownMenu_SetText( frame.nodeIcon, selectedIconName )
		frame.nodeName:SetText( Me.Profile.mapNodes[ DiceMasterMapNodes.selected ].title );
		frame.nodeDesc.EditBox:SetText( Me.Profile.mapNodes[ DiceMasterMapNodes.selected ].description );
		frame.nodeHidden:SetChecked( Me.Profile.mapNodes[ DiceMasterMapNodes.selected ].hidden );
	else
		UIDropDownMenu_SetSelectedValue( frame.nodeIcon, nil )
		UIDropDownMenu_SetText( frame.nodeIcon, "" )
		frame.nodeName:SetText( "" );
		frame.nodeDesc.EditBox:SetText( "" );
		frame.nodeHidden:SetChecked(false)
	end
	
	FauxScrollFrame_Update(DiceMasterMapNodesScrollFrame, #Me.Profile.mapNodes, 7, 16, nil, nil, nil, nil, nil, nil, true );
end

function Me.DiceMasterMapNodesDropDown_OnClick( self )
	UIDropDownMenu_SetSelectedValue( DiceMasterMapNodesInset2.nodeIcon, self.value )
end

local function CreateIconMenu( dropdown, level, title )
	local info = UIDropDownMenu_CreateInfo();
	info.text = title;
	info.value = title;
	info.notCheckable = true;
	info.hasArrow = true;
	info.keepShownOnClick = true;
	info.menuList = title;
	UIDropDownMenu_AddButton(info, level);
end

local function GetPOITexCoordsFromInteger( integer )
	integer = integer - 1
	local columns = 14
	local l = ( mod( integer, columns ) * 0.0703125 )
	local r = l + 0.0703125
	local t = floor( integer / columns ) * 0.03515625
	local b = t + 0.03515625
	return l, r, t, b;
end

local function ConvertTexCoords( l, r, t, b, width, height )
	l = l * width; 
	r = r * width;
	t = t * height;
	b = b * height;
	return l, r, t, b;
end

local function GetIconEscapeSequence( infoTable )
	local l, r, t, b, path, x, y = unpack( infoTable )
	return tostring( "|T"..path..":16:16:0:0:"..x..":"..y..":"..l..":"..r..":"..t..":"..b.."|t" )
end 

function Me.DiceMasterMapNodesDropDown_OnLoad( frame, level, menuList )
	local info = UIDropDownMenu_CreateInfo()
	
	if level == 1 then
		local tkeys = {}
		for k in pairs( MAP_NODE_ICONS ) do
			table.insert( tkeys, k )
		end
		table.sort( tkeys )
		for _, k in ipairs( tkeys ) do
			CreateIconMenu( frame, level, k );
		end
	elseif level == 2 then
		for i = 1, #MAP_NODE_ICONS[menuList] do
			local info = UIDropDownMenu_CreateInfo()
			if not MAP_NODE_ICONS[menuList][i][2] then
				info.text = MAP_NODE_ICONS[menuList][i][1]
				info.isTitle = true;
			elseif type( MAP_NODE_ICONS[menuList][i][2] ) == "number" then
				local nodeIcon = MAP_NODE_ICONS[menuList]
				local w, h, l, r, t, b, x, y, path;
				
				if #nodeIcon[i] > 2 then
					path = nodeIcon.path
					x, y = nodeIcon.x, nodeIcon.y
					w, h, l, r, t, b = nodeIcon[i][2], nodeIcon[i][3], nodeIcon[i][4], nodeIcon[i][5], nodeIcon[i][6], nodeIcon[i][7]
				else
					path = "Interface/MINIMAP/POIICONS"
					w, h = 24, 24
					x, y = 256, 512
					l, r, t, b = GetPOITexCoordsFromInteger( nodeIcon[i][2] )
				end
				
				local l2, r2, t2, b2 = ConvertTexCoords( l, r, t, b, x, y )
				
				local iconString = GetIconEscapeSequence( { l2, r2, t2, b2, path, x, y } )
				info.value = { l, r, t, b, path, x, y, w, h, iconString };
				info.text = iconString .. " " .. nodeIcon[i][1];
			else
				info.text = "|T" .. MAP_NODE_ICONS[menuList][i][2] .. ":16|t " .. MAP_NODE_ICONS[menuList][i][1];
				info.value = MAP_NODE_ICONS[menuList][i][2];
			end
			info.func = Me.DiceMasterMapNodesDropDown_OnClick;
			UIDropDownMenu_AddButton( info, level )
		end
	end
end

-- Delete the map node selected from the list.

function Me.DiceMasterMapNodes_Delete()	
	if not DiceMasterMapNodes.selected then
		return
	end
	
	if type( icon ) == "table" then
		local icon = Me.Profile.mapNodes[DiceMasterMapNodes.selected].icon
		Me.PrintMessage( icon[10] .. " ".. title .." has been deleted.", "SYSTEM");
	else
		Me.PrintMessage("|T".. Me.Profile.mapNodes[DiceMasterMapNodes.selected].icon ..":16|t ".. Me.Profile.mapNodes[DiceMasterMapNodes.selected].title .." has been deleted.", "SYSTEM");
	end

	tremove( Me.Profile.mapNodes, DiceMasterMapNodes.selected );
	
	DiceMasterMapNodes.selected = nil
	
	Me.UpdateAllMapNodes();
	Me.DiceMasterMapNodes_Update()
	Me.RollTracker_ShareMapNodesWithParty()
end

-- Create a new map node and add it to the list.

function Me.DiceMasterMapNodes_New()
	local x, y, map = HBD:GetPlayerZonePosition( true );
	local zone = GetZoneText();
	
	local newMapNode = {
		icon = "Interface/MINIMAP/TRACKING/Target";
		iconName = "Target";
		title = "New Map Node";
		description = "";
		coordX = x;
		coordY = y;
		mapID = map;
		zone = zone;
		hidden = false;
	}

	tinsert( Me.Profile.mapNodes, newMapNode );
	
	Me.PrintMessage("|TInterface/MINIMAP/TRACKING/Target:16|t New Map Node has been added to your map.", "SYSTEM");
	
	DiceMasterMapNodes.selected = #Me.Profile.mapNodes
	
	Me.UpdateAllMapNodes();
	Me.DiceMasterMapNodes_Update();
	Me.RollTracker_ShareMapNodesWithParty()
end

-- Save changes made to an existing map node.

function Me.DiceMasterMapNodes_Save()
	if not DiceMasterMapNodes.selected then
		return
	end
	
	local node = Me.Profile.mapNodes[ DiceMasterMapNodes.selected ]
	local frame = DiceMasterMapNodesInset2;
	
	local icon = UIDropDownMenu_GetSelectedValue( DiceMasterMapNodesInset2.nodeIcon )
	local iconName = UIDropDownMenu_GetText( DiceMasterMapNodesInset2.nodeIcon )
	
	local title = frame.nodeName:GetText();
	local description = frame.nodeDesc.EditBox:GetText();
	
	local hidden = frame.nodeHidden:GetChecked()
	
	node.icon = icon;
	node.iconName = iconName;
	node.title = title;
	node.description = description;
	node.hidden = hidden;
	
	if type( icon ) == "table" then
		local icon = Me.Profile.mapNodes[DiceMasterMapNodes.selected].icon
		Me.PrintMessage( icon[10] .. " ".. title .." has been saved.", "SYSTEM");
	else
		Me.PrintMessage("|T".. icon ..":16|t ".. title .." has been saved.", "SYSTEM");
	end
	
	Me.UpdateAllMapNodes();
	Me.DiceMasterMapNodes_Update()
	Me.RollTracker_ShareMapNodesWithParty()
end

function Me.DiceMasterMapNodes_View( self )
	local nodeIndex = self:GetParent().nodeIndex;
	local info = Me.Profile.mapNodes[nodeIndex];
	
	local mapID = info.mapID;
	
	OpenWorldMap( mapID )
	--WorldMapFrame:SetMapID( mapID );
end

-------------------------------------------------------------------------------
-- Send a NOTES message to the party.
--
function Me.RollTracker_ShareNoteWithParty()
	if not Me.IsLeader( true ) or not IsInGroup( LE_PARTY_CATEGORY_HOME ) or IsInGroup( LE_PARTY_CATEGORY_INSTANCE ) then
		return
	end
	
	FormatNoteField()
	
	local msg = Me:Serialize( "NOTES", {
		no = DiceMasterDMNotesDMNotes.EditBox:GetText() or "";
		al = DiceMasterDMNotesDMNotes.EditBox:GetJustifyH() or "LEFT";
		ra = DiceMasterDMNotesAllowAssistants:GetChecked();
	})
	
	Me:SendCommMessage( "DCM4", msg, "RAID", nil, "NORMAL" )
end

-------------------------------------------------------------------------------
-- Record a DiceMaster roll.

function Me.OnRollMessage( name, you, count, sides, mod, roll, rollType ) 
	
	if not count or not sides or not mod or not roll then
		return
	end
	
	if you then
		name = UnitName("player")
	end
	
	if not rollType then
		rollType = "--"
	end
	
	local dice = Me.FormatDiceType( count, sides, mod )
	
	if roll and UnitIsPlayer( name ) then
		roll = roll + mod
		if not Me.HistoryRolls[name] then
			Me.HistoryRolls[name] = {}
		end
		local exists = false;
		for i=1,#Me.SavedRolls do
			if Me.SavedRolls[i].name == name then
				Me.SavedRolls[i].roll = tonumber(roll)
				Me.SavedRolls[i].rollType = rollType
				Me.SavedRolls[i].time = date("%H%M%S")
				Me.SavedRolls[i].timestamp = date("%H:%M:%S")
				exists = true;
			end
		end
		
		if not exists then
			local data = {}
			data.roll = tonumber(roll)
			data.rollType = rollType
			data.time = date("%H%M%S")
			data.timestamp = date("%H:%M:%S")
			data.target = 0
			data.name = name
			tinsert(Me.SavedRolls, data)
		end
		
		local data = {}
		data.roll = tonumber(roll)
		data.rollType = rollType
		data.time = date("%H%M%S")
		data.timestamp = date("%H:%M:%S")
		data.dice = dice
		tinsert(Me.HistoryRolls[name], 1, data)
		
		Me.DiceMasterRollFrame_Update()
		
		if DiceMasterRollTracker.selectedName then
			Me.DiceMasterRollDetailFrame_Update()
		end
	end
end

-------------------------------------------------------------------------------
-- Record a vanilla roll.

function Me.OnVanillaRollMessage( name, roll, min, max ) 
	
	if not name or not roll or not min or not max then
		return
	end
	
	local dice = ( min .. "-" .. max )
	
	if roll and UnitIsPlayer( name ) then
		if not Me.HistoryRolls[name] then
			Me.HistoryRolls[name] = {}
		end
		local exists = false;
		for i=1,#Me.SavedRolls do
			if Me.SavedRolls[i].name == name then
				Me.SavedRolls[i].roll = tonumber(roll)
				Me.SavedRolls[i].rollType = "--"
				Me.SavedRolls[i].time = date("%H%M%S")
				Me.SavedRolls[i].timestamp = date("%H:%M:%S")
				exists = true;
			end
		end
		
		if not exists then
			local data = {}
			data.roll = tonumber(roll)
			data.rollType = "--"
			data.time = date("%H%M%S")
			data.timestamp = date("%H:%M:%S")
			data.target = 0
			data.name = name
			tinsert(Me.SavedRolls, data)
		end
		
		local data = {}
		data.roll = tonumber(roll)
		data.rollType = "--"
		data.time = date("%H%M%S")
		data.timestamp = date("%H:%M:%S")
		data.dice = dice
		tinsert(Me.HistoryRolls[name], 1, data)
		
		Me.DiceMasterRollFrame_Update()
		
		if DiceMasterRollTracker.selectedName then
			Me.DiceMasterRollDetailFrame_Update()
		end
	end
end

function Me.OnChatMessage( message, sender ) 
	local icons = {
		{"gold", "star", "rt1"},
		{"orange", "circle", "coin", "rt2"},
		{"purple", "diamond", "rt3"},
		{"green", "triangle", "rt4"},
		{"silver", "moon", "rt5"},
		{"blue", "square", "rt6"},
		{"red", "cross", "x", "rt7"},
		{"white", "skull", "rt8"}
	}
	
	if sender:find("-") then
		-- this is the best xrealm support ur gonna get :)
		sender = sender:match( "(.+)%-")
	end
	
	local found = false
	local icon = message:match("%{(%w+)%}") or 0
	for x=1,#icons do
		for y=1,#icons[x] do
			if icons[x][y] == icon then
				icon = x
				found = true
				break
			end
		end
	end
	
	if icon and found then
		local exists = false;
		for i=1,#Me.SavedRolls do
			if Me.SavedRolls[i].name == sender then
				--Me.SavedRolls[i].time = date("%H%M%S")
				--Me.SavedRolls[i].timestamp = date("%H:%M:%S")
				Me.SavedRolls[i].roll = Me.SavedRolls[i].roll or "--"
				Me.SavedRolls[i].rollType = Me.SavedRolls[i].rollType or "--"
				Me.SavedRolls[i].target = icon
				exists = true;
			end
		end
		
		if not exists then
			local data = {}
			data.name = sender
			data.roll = "--"
			data.rollType = "--"
			data.time = date("%H%M%S")
			data.timestamp = date("%H:%M:%S")
			data.target = icon
			tinsert(Me.SavedRolls, data)
		end
		
		if sender == UnitName("player") then
			UIDropDownMenu_SetText(DiceMasterRollTracker.selectTarget, "|TInterface/TARGETINGFRAME/UI-RaidTargetingIcon_"..icon..":16|t")
		end
	
		Me.DiceMasterRollFrame_Update()
	elseif sender == UnitName("player") then
		UIDropDownMenu_SetText(DiceMasterRollTracker.selectTarget, "") 
	end
end

---------------------------------------------------------------------------
-- Received a NOTES message.
--	no = note							string
--  al = text alignment					string
--  ra = raid assistants allowed		boolean

function Me.RollTracker_OnNoteMessage( data, dist, sender )	

	if sender == UnitName("player") then
		return
	end
 
	-- Only the party leader and raid assistants can send us these.
	if not UnitIsGroupLeader(sender, 1) and not UnitIsGroupAssistant(sender, 1) then 
		return 
	end
	
	-- sanitize message
	if not data.no then
	   
		return
	end
	
	data.no = tostring(data.no)	
	DiceMasterDMNotesDMNotes.EditBox:SetText( data.no )
	
	if data.al then
		data.al = tostring( data.al )
		DiceMasterDMNotesDMNotes.EditBox:SetJustifyH( data.al )
	end
	
	if Me.IsLeader( true ) and data.ra then
		if not DiceMasterDMNotesDMNotes.EditBox.previewShown then
			DiceMasterDMNotesDMNotes.EditBox:Enable()
		end
	else
		DiceMasterDMNotesDMNotes.EditBox:Disable()
	end
	
end


---------------------------------------------------------------------------
-- Received NOTREQ data.
-- 

function Me.RollTracker_OnStatusRequest( data, dist, sender )

	-- Ignore our own data.
	if sender == UnitName( "player" ) or IsInGroup( LE_PARTY_CATEGORY_INSTANCE ) then 
		return
	end
 
	if Me.IsLeader( false ) then
		local msg = Me:Serialize( "NOTES", {
			no = DiceMasterDMNotesDMNotes.EditBox:GetText() or "";
			ra = DiceMasterDMNotesAllowAssistants:GetChecked();
		})
		
		Me:SendCommMessage( "DCM4", msg, "RAID", nil, "NORMAL" )
		
		-- Update roll options as well.
		msg = Me:Serialize( "RTYPE", {
			rt = Me.db.char.rollOptions;
		})
		
		Me:SendCommMessage( "DCM4", msg, "RAID", nil, "ALERT" )
	end
end

---------------------------------------------------------------------------
-- Received a target update.
--	ta = target							number

function Me.RollTracker_OnTargetMessage( data, dist, sender )	
 
	-- sanitize message
	if not data.ta then
	   
		return
	end
	
	local icon = tonumber( data.ta )
	
	local exists = false;
	for i=1,#Me.SavedRolls do
		if Me.SavedRolls[i].name == sender then
			--Me.SavedRolls[i].time = date("%H%M%S")
			--Me.SavedRolls[i].timestamp = date("%H:%M:%S")
			Me.SavedRolls[i].roll = Me.SavedRolls[i].roll or "--"
			Me.SavedRolls[i].rollType = Me.SavedRolls[i].rollType or "--"
			Me.SavedRolls[i].target = icon
			exists = true;
		end
	end
	
	if not exists then
		local msg = {}
		msg.name = sender
		msg.roll = "--"
		msg.time = date("%H%M%S")
		msg.timestamp = date("%H:%M:%S")
		msg.rollType = "--"
		msg.target = icon
		tinsert(Me.SavedRolls, msg)
	end
	Me.DiceMasterRollFrame_Update()
end

-------------------------------------------------------------------------------
-- Send a MAPNODES message to the party.
--
function Me.RollTracker_ShareMapNodesWithParty()
	if not Me.IsLeader( false ) or not IsInGroup( LE_PARTY_CATEGORY_HOME ) or IsInGroup( LE_PARTY_CATEGORY_INSTANCE ) then
		return
	end
	
	local mapNodes = {}
	
	if Profile.mapNodes and #Profile.mapNodes > 0 then
	
		for i = 1, #Profile.mapNodes do
			
			if not Profile.mapNodes[i].hidden then
				local data = {
					icon = Profile.mapNodes[i].icon;
					title = Profile.mapNodes[i].title;
					description = Profile.mapNodes[i].description;
					coordX = Profile.mapNodes[i].coordX;
					coordY = Profile.mapNodes[i].coordY;
					mapID = Profile.mapNodes[i].mapID;
					zone = Profile.mapNodes[i].zone;
				}
				
				tinsert( mapNodes, data )
			end
		end
		
	end
	
	local msg = Me:Serialize( "MAPNODES", {
		nodes = mapNodes;
	})
	
	Me:SendCommMessage( "DCM4", msg, "RAID", nil, "NORMAL" )
end

---------------------------------------------------------------------------
-- Received MAPNODES data.
-- 

function Me.RollTracker_OnMapNodesMessage( data, dist, sender )

	-- Ignore our own data.
	if sender == UnitName( "player" ) then return end
	
	-- Only the party leader can send us these.
	if not UnitIsGroupLeader(sender, 1) then 
		return 
	end
	
	-- sanitize message
	if not data.nodes or not type( data.nodes ) == "table" then
	   
		-- cover all those bases . . .
		return 
	end
	
	-- store in database
	Me.inspectData[sender].mapNodes = data.nodes
	
	Me.UpdateAllMapNodes();
end

---------------------------------------------------------------------------
-- Received MAPREQ data.
-- 

function Me.RollTracker_OnMapNodesRequest( data, dist, sender )

	-- Ignore our own data.
	if sender == UnitName( "player" ) or IsInGroup( LE_PARTY_CATEGORY_INSTANCE ) then 
		return
	end
 
	if Me.IsLeader( false ) then
		local mapNodes = {}
		
		if Profile.mapNodes and #Profile.mapNodes > 0 then
		
			for i = 1, #Profile.mapNodes do
				
				if not Profile.mapNodes[i].hidden then
					local data = {
						icon = Profile.mapNodes[i].icon;
						title = Profile.mapNodes[i].title;
						description = Profile.mapNodes[i].description;
						coordX = Profile.mapNodes[i].coordX;
						coordY = Profile.mapNodes[i].coordY;
						mapID = Profile.mapNodes[i].mapID;
						zone = Profile.mapNodes[i].zone;
					}
					
					tinsert( mapNodes, data )
				end
			end
			
		end
		
		local msg = Me:Serialize( "MAPNODES", {
			nodes = mapNodes;
		})
		
		Me:SendCommMessage( "DCM4", msg, "WHISPER", sender, "NORMAL" )
	end
end