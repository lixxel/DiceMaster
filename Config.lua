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
	};
	
	char = { 
		minimapicon = {
			hide = false;
		};
		hidepanel     = false;
		uiScale       = 1;
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
			symbol	= "charge-orb";
		};
		health       = 5;
		healthMax    = 5;
		traits       = {};
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
			enchant = "";										-- trait enchantment
			icon   = "Interface/Icons/inv_misc_questionmark";   -- trait icon texture path
		}
		
		DB_DEFAULTS.char.traitSerials[i] = 1 -- used to optimize out duplicate requests
	end
	DB_DEFAULTS.profile.traits[5].name = "Command Trait"
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
			desc      = "The size of the DiceMaster panel and trait editor.";
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
			desc  = "Hide the trait inspect frame when the DiceMaster panel is hidden.";
			type  = "toggle";
			width = "full";
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
			width = "full";
			set = function( info, val )
				Me.db.global.hideTips = val
			end;
			get = function( info ) return Me.db.global.hideTips end;
		};
		
		hideTracker = {
			order = 7;
			name  = "Enable Roll Tracker";
			desc  = "Enable the Roll Tracker frame to keep track of your group's rolls.";
			type  = "toggle";
			width = "full";
			set = function( info, val )
				Me.db.global.hideTracker = val
				if val == true then
					DiceMasterRollFrame:Show()
				else
					DiceMasterRollFrame:Hide()
				end
			end;
			get = function( info ) return Me.db.global.hideTracker end;
		};
	
		enableCharges = {
			order = 10;
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
			order    = 11;
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
				
				chargesSymbol = {
					order = 50;
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
	
	AceConfigDialog:AddToBlizOptions( "DiceMaster", "DiceMaster" )
	AceConfigDialog:AddToBlizOptions( "DiceMaster Profiles", "Profiles", "DiceMaster" )
end

local interfaceOptionsNeedsInit = true
-------------------------------------------------------------------------------
-- Open the configuration panel.
--
function Me.OpenConfig() 
	Me.configOptions.args.chargesGroup.hidden = not Me.db.profile.charges.enable
	
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
end
