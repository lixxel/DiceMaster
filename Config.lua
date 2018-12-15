-------------------------------------------------------------------------------
-- Dice Master (C) 2017 <The League of Lordaeron> - Moon Guard
-------------------------------------------------------------------------------

local Me = DiceMaster4

local AceConfig       = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local SharedMedia     = LibStub("LibSharedMedia-3.0")

local VERSION = 1

-------------------------------------------------------------------------------
local DB_DEFAULTS = {
	
	global = {
		version     = nil;
		hideInspect = false; -- hide inspect frame when panel is hidden
		hideTips	= true; -- turn enhanced tooltips on for newbies
		hideTracker = false; -- hide the roll tracker.
		hideTypeTracker = false;
		enableRoundBanners = true;
	};
	
	char = { 
		minimapicon = {
			hide = false;
		};
		hidepanel     = false;
		uiScale       = 1;
		trackerScale  = 1;
		showRaidRolls = false;
		dm3Imported   = false;
		statusSerial  = 1;
		traitSerials  = {};
	};
	
	profile = {
		charges = {
			enable  = false;
			name    = "Charges";
			color   = {1,1,1};
			count   = 0;
			max     = 3;
			tooltip = "Represents the amount of Charges you have accumulated for certain traits.";
			symbol	= "charge-orb";
		};
		morale = {
			enable  = false;
			name    = "Morale";
			count   = 100;
			step    = 5;
			tooltip = "Measures the overall mental and emotional condition of the group while facing a challenge. Low morale can result in negative consequences.";
			color   = {1,1,0};
			symbol  = "WoWUI";
		};
		health       = 5;
		healthMax    = 5;
		traits       = {};
		buffs		 = {};
		removebuffs  = {};
		buffsActive  = {};
	} 
}

-- Initialize traits.
do
	local numbers = { "One", "Two", "Three", "Four", "Five" }
	for i = 1, 5 do
		 
		DB_DEFAULTS.profile.traits[i] = {
			name   = "Trait " .. numbers[i];                    -- name of trait
			usage  = Me.TRAIT_USAGE_MODES[1];                   -- usage, see USAGE_MODES
			desc   = "Type a description for your trait here."; -- trait description
			approved = false;									-- trait approved
			officers = {};										-- approved by
			icon   = "Interface/Icons/inv_misc_questionmark";   -- trait icon texture path
		}
		
		DB_DEFAULTS.char.traitSerials[i] = 1 -- used to optimize out duplicate requests
	end
	DB_DEFAULTS.profile.traits[5].name = "Chapter Trait"
end

-------------------------------------------------------------------------------


-------------------------------------------------------------------------------
Me.configOptions = {
	type  = "group";
	order = 1;
	args = { 
		-----------------------------------------------------------------------
		mmicon = {
			order = 1;
			name  = "Minimap Icon";
			desc  = "Hide/Show the minimap icon.";
			type  = "toggle";
			set   = function( info, val ) Me.MinimapButton:Show( val ) end;
			get   = function( info ) return not Me.db.char.minimapicon.hide end;
		};
 
		uiScale = {
			order     = 5;
			name      = "UI Scale";
			desc      = "The size of the Dice Panel, Trait Editor, Charges, Inspect, and Progress Bar frames.";
			type      = "range";
			min       = 0.25;
			max       = 10;
			softMax   = 4;
			isPercent = true;
			set = function( info, val ) 
				Me.db.char.uiScale = val;
				Me.ApplyUiScale()
			end;
			get = function( info ) return Me.db.char.uiScale end;
		};
		
		hideInspect = {
			order = 6;
			name  = "Hide Inspect Frame When Hidden";
			desc  = "Hide the trait inspect frame when the Dice Panel is hidden.";
			type  = "toggle";
			width = "double";
			set = function( info, val )
				Me.db.global.hideInspect = val
				Me.Inspect_Open( Me.inspectName )
				-- refresh hidden status.
			end;
			get = function( info ) return Me.db.global.hideInspect end;
		};
		
		hideTips = {
			order = 7;
			name  = "Enable Enhanced Tooltips";
			desc  = "Enable helpful DiceMaster term definitions next to trait tooltips.";
			type  = "toggle";
			width = "double";
			set = function( info, val )
				Me.db.global.hideTips = val
			end;
			get = function( info ) return Me.db.global.hideTips end;
		};
		
		hideTracker = {
			order = 8;
			name  = "Enable Roll Tracker";
			desc  = "Enable the Roll Tracker frame to keep track of your group's rolls.";
			type  = "toggle";
			width = "double";
			set = function( info, val )
				Me.db.global.hideTracker = val
				Me.configOptions.args.trackerScale.hidden = not val
				if val == true then
					DiceMasterRollFrame:Show()
				else
					DiceMasterRollFrame:Hide()
				end
			end;
			get = function( info ) return Me.db.global.hideTracker end;
		};
		
		trackerScale = {
			order     = 9;
			name      = "Roll Tracker Scale";
			desc      = "The size of the Roll Tracker frame.";
			type      = "range";
			min       = 0.25;
			max       = 10;
			softMax   = 4;
			hidden   = true;
			isPercent = true;
			set = function( info, val ) 
				Me.db.char.trackerScale = val;
				Me.ApplyUiScale()
			end;
			get = function( info ) return Me.db.char.trackerScale end;
		};
		
		hideTypeTracker = {
			order = 10;
			name  = "Enable Typing Tracker";
			desc  = "Enable the Typing Tracker to alert you when group members are writing in say, emote, party, and raid.";
			type  = "toggle";
			width = "double";
			set = function( info, val )
				Me.db.global.hideTypeTracker = val
			end;
			get = function( info ) return Me.db.global.hideTypeTracker end;
		};
		
		enableRoundBanners = {
			order = 11;
			name  = "Enable Roll Prompt Banners";
			desc  = "Allow the group leader to send you visual prompts when it's your turn to roll.";
			type  = "toggle";
			width = "double";
			set = function( info, val )
				Me.db.global.enableRoundBanners = val
			end;
			get = function( info ) return Me.db.global.enableRoundBanners end;
		};
	
		enableCharges = {
			order = 12;
			name  = "Enable Charges";
			desc  = "Enable usage of the charges system for this character.";
			width = "full";
			type  = "toggle";
			set = function( info, val ) 
				Me.db.profile.charges.enable = val 
				Me.configOptions.args.chargesGroup.hidden = not val
				Me.OnChargesChanged() 
			end;
			get = function( info ) return Me.db.profile.charges.enable end;
		};
		
		chargesGroup = {
			name     = "Charges";
			inline   = true;
			order    = 13;
			type     = "group";
			hidden   = true;
			args = {
				chargesName = {
					order = 20;
					name  = "Charges Name";
					desc  = "Name of this character's charges. Examples: Holy Power, Rage, Adrenaline.";
					type  = "input";
					set = function( info, val ) 
						Me.db.profile.charges.name = val
						Me.OnChargesChanged()
					end;
					get = function( info ) return Me.db.profile.charges.name end;
				};
				
				chargesColor = {
					order = 30;
					name  = "Charges Color";
					desc  = "Color of this character's charges bar.";
					type  = "color";
					set = function( info, r, g, b ) 
						Me.db.profile.charges.color = {r,g,b}
						Me.OnChargesChanged()
					end;
					get = function( info ) 
						return Me.db.profile.charges.color[1],
							   Me.db.profile.charges.color[2],
							   Me.db.profile.charges.color[3]
					end;
				};
			  
				chargesMax = {
					order = 40;
					name  = "Maximum Charges";
					desc  = "The maximum amount of charges that this character can accumulate.";
					type  = "range"; 
					min   = 1;
					max   = 8;
					step  = 1;
					set   = function( info, val ) 
						Me.db.profile.charges.max = val
						Me.OnChargesChanged()
					end;
					get   = function( info ) return Me.db.profile.charges.max end;
				}; 
				
				chargesTooltip = {
					order = 50;
					name  = "Charges Description";
					desc  = "A description for the charges bar tooltip.";
					type  = "input";
					multiline = 3;
					set = function( info, val ) 
						Me.db.profile.charges.tooltip = val
						Me.OnChargesChanged()
					end;
					get = function( info ) return Me.db.profile.charges.tooltip end;
				};
				
				chargesSymbol = {
					order = 60;
					name  = "Charges Skin";
					desc  = "Custom skin for this character's charges bar.";
					type  = "select"; 
					style = "dropdown";
					values = {
						["charge-orb"] = "Charge Orbs",
						["charge-fire"] = "Burning Embers",
						["charge-rune"] = "Death Knight Runes",
						["charge-shadow"] = "Shadow Orbs",
						["charge-soulshards"] = "Soul Shards",
						["charge-hourglass"] = "Hourglasses",
						["Air"] = "Air",
						["Ice"] = "Ice",
						["Fire"] = "Fire",
						["Rock"] = "Rock",
						["Water"] = "Water",
						["Meat"] = "Meat",
						["UndeadMeat"] = "Undead Meat",
						["WowUI"] = "Generic",
						["WoodPlank"] = "Wood Plank",
						["WoodwithMetal"] = "Wood with Metal",
						["Darkmoon"] = "Darkmoon",
						["MoltenRock"] = "Molten Rock",
						["Alliance"] = "Alliance",
						["Horde"] = "Horde",
						["Amber"] = "Amber",
						["Druid"] = "Druid",
						["FancyPanda"] = "Pandaren",
						["Mechanical"] = "Mechanical",
						["Map"] = "Map",
						["InquisitionTorment"] = "Inquisitor",
						["Bamboo"] = "Bamboo",
						["Onyxia"] = "Onyxia",
						["StoneDesign"] = "Stone Design",
					};
					set   = function( info, val ) 
						Me.db.profile.charges.symbol = val
						Me.OnChargesChanged()
					end;
					get   = function( info ) return Me.db.profile.charges.symbol end;
				}; 
			};
		};
		
		enableMorale = {
			order = 14;
			name  = "Enable Progress Bar";
			desc  = "Enable usage of a group-wide progress bar when you are leader.";
			width = "full";
			type  = "toggle";
			set = function( info, val ) 
				Me.db.profile.morale.enable = val 
				Me.configOptions.args.moraleGroup.hidden = not val
				Me.RefreshMoraleFrame() 
			end;
			get = function( info ) return Me.db.profile.morale.enable end;
		};
		
		moraleGroup = {
			name     = "Progress Bar";
			inline   = true;
			order    = 15;
			type     = "group";
			hidden   = true;
			args = {
				moraleName = {
					order = 20;
					name  = "Progress Bar Name";
					desc  = "Name of the progress bar. Examples: Morale, Sanity, Shield Integrity.";
					type  = "input";
					set = function( info, val ) 
						Me.db.profile.morale.name = val
						Me.RefreshMoraleFrame()
					end;
					get = function( info ) return Me.db.profile.morale.name end;
				};
				
				moraleColor = {
					order = 30;
					name  = "Progress Bar Color";
					desc  = "Color of the progress bar.";
					type  = "color";
					set = function( info, r, g, b ) 
						Me.db.profile.morale.color = {r,g,b}
						Me.RefreshMoraleFrame()
					end;
					get = function( info ) 
						return Me.db.profile.morale.color[1],
							   Me.db.profile.morale.color[2],
							   Me.db.profile.morale.color[3]
					end;
				};
			  
				moraleCount = {
					order = 40;
					name  = "Start Value";
					desc  = "The starting value of the progress bar (either full, half, or empty).";
					type  = "range"; 
					min   = 0;
					max   = 100;
					step  = 50;
					set   = function( info, val ) 
						Me.db.profile.morale.count = val
						Me.RefreshMoraleFrame( val )
					end;
					get   = function( info ) return Me.db.profile.morale.count end;
				}; 
				
				moraleTooltip = {
					order = 50;
					name  = "Progress Bar Description";
					desc  = "A description for the progress bar tooltip.";
					type  = "input";
					multiline = 3;
					set = function( info, val ) 
						Me.db.profile.morale.tooltip = val
						Me.RefreshMoraleFrame()
					end;
					get = function( info ) return Me.db.profile.morale.tooltip end;
				};
				
				moraleStep = {
					order = 55;
					name  = "Increase/Decrease Value";
					desc  = "The amount that is added/removed when the progress bar is clicked.";
					type  = "range"; 
					min   = 1;
					max   = 10;
					step  = 1;
					set   = function( info, val ) 
						Me.db.profile.morale.step = val
						Me.RefreshMoraleFrame()
					end;
					get   = function( info ) return Me.db.profile.morale.step end;
				}; 
				
				moraleSymbol = {
					order = 60;
					name  = "Progress Bar Skin";
					desc  = "Custom skin for the progress bar.";
					type  = "select"; 
					style = "dropdown";
					values = {
						["morale-bar"] = "League of Lordaeron",
						["Air"] = "Air",
						["Ice"] = "Ice",
						["Fire"] = "Fire",
						["Rock"] = "Rock",
						["Water"] = "Water",
						["Meat"] = "Meat",
						["UndeadMeat"] = "Undead Meat",
						["WoWUI"] = "Generic",
						["WoodPlank"] = "Wood Plank",
						["WoodWithMetal"] = "Wood with Metal",
						["Darkmoon"] = "Darkmoon",
						["MoltenRock"] = "Molten Rock",
						["Alliance"] = "Alliance",
						["Horde"] = "Horde",
						["Amber"] = "Amber",
						["Druid"] = "Druid",
						["FancyPanda"] = "Fancy Pandaren",
						["Mechanical"] = "Mechanical",
						["Map"] = "Map",
						["InquisitionTorment"] = "Inquisitor",
						["Bamboo"] = "Bamboo",
						["Onyxia"] = "Onyxia",
						["StoneDesign"] = "Stone Design",
						["NaaruCharge"] = "Naaru",
						["ShadowPaladinBar"] = "Shadow Paladin",
						["Xavius"] = "Xavius Nightmare",
						["BulletBar"] = "Bullets",
						["Azerite"] = "Azerite",
						["Chogall"] = "Cho'gall",
						["FuelGauge"] = "Fuel Gauge",
						["FelCorruption"] = "Fel Corruption",
						["Murozond"] = "Murozond Hourglass",
						["Pride"] = "Pride",
						["Meditation"] = "Meditation",
						["Jaina"] = "Jaina",
					};
					set   = function( info, val ) 
						Me.db.profile.morale.symbol = val
						Me.RefreshMoraleFrame()
					end;
					get   = function( info ) return Me.db.profile.morale.symbol end;
				}; 
			};
		};
		
		unlockFrames = {
			order = 16;
			name  = "Unlock Frames";
			desc  = "Unlock all frames, allowing you to click and drag them around your UI.";
			type  = "execute";
			width = "normal";
			func  = function()
				InterfaceOptionsFrame_Show()
				Me.UnlockFrames()
			end;
		};
		
		lockFrames = {
			order = 17;
			name  = "Lock Frames";
			desc  = "Lock all frames so they can no longer be dragged.";
			type  = "execute";
			width = "normal";
			func  = function()
				InterfaceOptionsFrame_Show()
				Me.LockFrames()
			end;
		};
		
		resetFrames = {
			order = 18;
			name  = "Reset Frame Positions";
			desc  = "Resets all frames to their default positions.";
			type  = "execute";
			width = "normal";
			func  = function()
				InterfaceOptionsFrame_Show()
				DiceMasterPostTrackerFrame:SetPoint("BOTTOMLEFT", "ChatFrame1Tab", "TOPLEFT", 0, -2)
				DiceMasterInspectFrame:SetPoint("CENTER", 0, 0)
				DiceMasterBuffFrame:SetPoint("TOPRIGHT", BuffFrame, "TOPRIGHT", 0, 0)
				DiceMasterInspectBuffFrame:SetPoint("BOTTOM", DiceMasterInspectFrame, "TOP", 0, 0)
				DiceMasterChargesFrame:SetPoint("CENTER", 0, 0)
				DiceMasterMoraleBar:SetPoint("TOP", DiceMasterPanel, "BOTTOM", 0, -20)
			end;
		};
	};
}

-------------------------------------------------------------------------------
function Me.SetupDB()
	
	local acedb = LibStub( "AceDB-3.0" )
  
	Me.db = acedb:New( "DiceMaster4_Saved", DB_DEFAULTS )
	
	Me.db.RegisterCallback( Me, "OnProfileChanged", "ApplyConfig" )
	Me.db.RegisterCallback( Me, "OnProfileCopied",  "ApplyConfig" )
	Me.db.RegisterCallback( Me, "OnProfileReset",   "ApplyConfig" )
	 
	local options = Me.configOptions
	local profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable( Me.db )
	profiles.order = 500
	 
	AceConfig:RegisterOptionsTable( "DiceMaster", options )	
	AceConfig:RegisterOptionsTable( "DiceMaster Profiles", profiles )	
	
	Me.config = AceConfigDialog:AddToBlizOptions( "DiceMaster", "DiceMaster" )
	Me.configProfiles = AceConfigDialog:AddToBlizOptions( "DiceMaster Profiles", "Profiles", "DiceMaster" )
	
	local logo = CreateFrame('Frame', nil, Me.config)
	logo:SetFrameLevel(4)
	logo:SetSize(64, 64)
	logo:SetPoint('TOPRIGHT', 8, 24)
	logo:SetBackdrop({bgFile = "Interface/AddOns/DiceMaster/Texture/logo"})
	Me.config.logo = logo
	local logo = CreateFrame('Frame', nil, Me.configProfiles)
	logo:SetFrameLevel(4)
	logo:SetSize(64, 64)
	logo:SetPoint('TOPRIGHT', 8, 24)
	logo:SetBackdrop({bgFile = "Interface/AddOns/DiceMaster/Texture/logo"})
	Me.configProfiles.logo = logo
end

local interfaceOptionsNeedsInit = true
-------------------------------------------------------------------------------
-- Open the configuration panel.
--
function Me.OpenConfig() 
	Me.configOptions.args.chargesGroup.hidden = not Me.db.profile.charges.enable
	Me.configOptions.args.moraleGroup.hidden = not Me.db.profile.morale.enable
	
	-- the first time we open the options frame, it wont go to the right page
	if interfaceOptionsNeedsInit then
		InterfaceOptionsFrame_OpenToCategory( "DiceMaster" )
		interfaceOptionsNeedsInit = nil
	end
	InterfaceOptionsFrame_OpenToCategory( "DiceMaster" )
	LibStub("AceConfigRegistry-3.0"):NotifyChange( "DiceMaster" )
end

-------------------------------------------------------------------------------
function Me.ApplyConfig( onload )
	Me.configOptions.args.chargesGroup.hidden = not Me.db.profile.charges.enable
	Me.configOptions.args.moraleGroup.hidden = not Me.db.profile.morale.enable
	
	-- bump all serials, everything is considered dirty
	Me.BumpSerial( Me.db.char, "statusSerial" )
	for i = 1, 5 do
		Me.BumpSerial( Me.db.char.traitSerials, i )
	end
	Me.Inspect_ShareStatusWithParty()
	
	Me.ApplyUiScale()
	Me.RefreshChargesFrame( true, true )  
	Me.TraitEditor_Refresh()
	Me.UpdatePanelTraits()
	Me.configOptions.args.enableRoundBanners.hidden = not Me.PermittedUse()
end
