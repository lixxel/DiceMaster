-------------------------------------------------------------------------------
-- Dice Master (C) 2019 <The League of Lordaeron> - Moon Guard
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
		showUses    = true;
		hideInspect = false; -- hide inspect frame when panel is hidden
		hideStats   = false; -- hide stats button from inspect frame.
		hidePet   = false; -- hide pet portrait frame from inspect frame.
		hideTips	= true; -- turn enhanced tooltips on for newbies
		hideTracker = false; -- hide the roll tracker.
		trackerAnchor = "RIGHT";
		hideTypeTracker = false;
		allowSounds = true;
		enableRoundBanners = true;
		enableMapNodes = true;
		enableTurnTracker = true;
		talkingHeads = true;
		allowSounds = true;
		allowEffects = true;
		allowAssistantTalkingHeads = true;
		allowBuffs = true;
		bloodEffects = true;
		miniFrames = false;
		snapping = false;
	};
	
	char = { 
		minimapicon = {
			hide = false;
		};
		hidepanel     = false;
		uiScale       = 0.75;
		trackerScale  = 0.6;
		trackerKeybind = nil;
		showRaidRolls = false;
		healthPos    = false;
		dm3Imported   = false;
		statusSerial  = 1;
		traitSerials  = {};
		unitframes = {
			enable  = true;
			scale   = 0.5;
		};
		rollOptions = {};
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
			flash   = true;
			pos		= false;
		};
		morale = {
			enable  = false;
			name    = "Morale";
			count   = 100;
			step    = 5;
			tooltip = "Measures the overall mental and emotional condition of the group while facing a challenge. Low morale can result in negative consequences.";
			color   = {1,1,0};
			symbol  = "WoWUI";
			scale   = 0.75;
		};
		health       = 5;
		healthMax    = 5;
		armor        = 0;
		traits       = {};
		pet	= {
			enable  = false;
			name 	= "Pet Name";
			type    = "Pet";
			icon 	= "Interface/Icons/inv_misc_questionmark";
			model 	= 0;
			health       = 5;
			healthMax    = 5;
			armor        = 0;
		};
		inventory	 = {};
		shop		 = {};
		currency     = {
			{
				name = "DiceMaster Coins";
				icon = "Interface/AddOns/DiceMaster/Texture/token";
				value = 0;
				guid = 0;
			};
		};
		currencyActive = 1;
		buffs			 = {};
		removebuffs 	 = {};
		playsounds  	 = {};
		setdice     	 = {};
		visualeffects	 = {};
		buffsActive  	 = {};
		stats = {
		};
		level        = 1;
		experience   = 0;
		dice 		 = "1D20+0";
		mapNodes	 = {};
	} 
}

-- Initialize traits.
do
	local numbers = { "One", "Two", "Three", "Four", "Five" }
	for i = 1, 5 do
		 
		DB_DEFAULTS.profile.traits[i] = {
			name   = "Trait " .. numbers[i];                    -- name of trait
			usage  = Me.TRAIT_USAGE_MODES[1];                   -- usage, see USAGE_MODES
			range  = Me.TRAIT_RANGE_MODES[1];                   -- usage, see RANGE_MODES
			castTime = Me.TRAIT_CAST_TIME_MODES[1];				-- cast time, see CAST_TIME_MODES
			cooldown = Me.TRAIT_COOLDOWN_MODES[1];				-- cooldown time, see COOLDOWN_MODES
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
		header = {
			order = 0;
			name  = "Configure the core settings for DiceMaster.";
			type  = "description";
		};
		
		mmicon = {
			order = 1;
			name  = "Enable Minimap Icon";
			desc  = "Enable the DiceMaster minimap icon.";
			type  = "toggle";
			set   = function( info, val ) Me.MinimapButton:Show( val ) end;
			get   = function( info ) return not Me.db.char.minimapicon.hide end;
		};
 
		uiScale = {
			order     = 4;
			name      = "UI Scale";
			desc      = "Change the size of the Dice Panel, Trait Editor, Charges, Inspect, and Progress Bar frames.";
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
		
		showUses = {
			order = 5;
			name  = "Show Remaining Uses on Dice Panel";
			desc  = "Show the number of remaining uses on the Dice Panel.";
			type  = "toggle";
			width = "double";
			set = function( info, val )
				Me.db.global.showUses = val
				Me.UpdatePanelTraits()
			end;
			get = function( info ) return Me.db.global.showUses end;
		};
		
		hideInspect = {
			order = 6;
			name  = "Hide Inspect Frame When Hidden";
			desc  = "Hide the Inspect Frame when the Dice Panel is hidden.";
			type  = "toggle";
			width = "double";
			set = function( info, val )
				Me.db.global.hideInspect = val
				Me.Inspect_Open( Me.inspectName )
				-- refresh hidden status.
			end;
			get = function( info ) return Me.db.global.hideInspect end;
		};
		
		hideStats = {
			order = 7;
			name  = "Hide Statistics Button on Inspect Frame";
			desc  = "Hide the Statistics button from the Inspect Frame.";
			type  = "toggle";
			width = "double";
			set = function( info, val )
				Me.db.global.hideStats = val
				Me.Inspect_Open( Me.inspectName )
				-- refresh hidden status.
			end;
			get = function( info ) return Me.db.global.hideStats end;
		};
		
		hidePet = {
			order = 8;
			name  = "Hide Pet Frame on Inspect Frame";
			desc  = "Hide the Pet Portrait Frame from the Inspect Frame.";
			type  = "toggle";
			width = "double";
			set = function( info, val )
				Me.db.global.hidePet = val
				Me.Inspect_Open( Me.inspectName )
				-- refresh hidden status.
			end;
			get = function( info ) return Me.db.global.hidePet end;
		};
		
		hideTips = {
			order = 9;
			name  = "Enable Enhanced Tooltips";
			desc  = "Enable helpful DiceMaster term definitions next to trait tooltips.";
			type  = "toggle";
			width = "double";
			set = function( info, val )
				Me.db.global.hideTips = val
			end;
			get = function( info ) return Me.db.global.hideTips end;
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
		
		enableTurnTracker = {
			order = 11;
			name  = "Enable Combat Turn Tracker";
			desc  = "Displays the Turn Tracker frame when turn-based combat begins.";
			width = "full";
			type  = "toggle";
			set = function( info, val ) 
				Me.db.global.enableTurnTracker = val
				if not val then
					DiceMasterTurnTracker:Hide()
				end
			end;
			get = function( info ) return Me.db.global.enableTurnTracker end;
		};
		
		allowSounds = {
			order = 12;
			name  = "Allow Sounds from Other Players";
			desc  = "Allow other players to play sound effects.";
			type  = "toggle";
			width = "double";
			set = function( info, val )
				Me.db.global.allowSounds = val
			end;
			get = function( info ) return Me.db.global.allowSounds end;
		};
		
		allowEffects = {
			order = 13;
			name  = "Allow Effects from Other Players";
			desc  = "Allow the group leader to send you fullscreen visual effects.";
			type  = "toggle";
			width = "double";
			set = function( info, val )
				Me.db.global.allowEffects = val
			end;
			get = function( info ) return Me.db.global.allowEffects end;
		};
		
		enableRoundBanners = {
			order = 15;
			name  = "Allow Roll Prompt Banners";
			desc  = "Allow the group leader to send you visual prompts when it's your turn to roll.";
			type  = "toggle";
			width = "double";
			set = function( info, val )
				Me.db.global.enableRoundBanners = val
			end;
			get = function( info ) return Me.db.global.enableRoundBanners end;
		};
		
		enableMapNodes = {
			order = 16;
			name  = "Display Group Leader's Map Nodes";
			desc  = "Display the group leader's map nodes when you're in a party or raid.";
			type  = "toggle";
			width = "double";
			set = function( info, val )
				Me.db.global.enableMapNodes = val
				Me.UpdateAllMapNodes()
			end;
			get = function( info ) return Me.db.global.enableMapNodes end;
		};
		
		headerFrames = {
			order = 17;
			name  = " ";
			type  = "description";
		};
		
		unlockFrames = {
			order = 18;
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
			order = 19;
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
			order = 20;
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
				DiceMasterInspectPetFrame:SetPoint("LEFT", DiceMasterInspectFrame, "RIGHT", 0, 0)
				DiceMasterChargesFrame:SetPoint("CENTER", 0, 0)
				DiceMasterPetChargesFrame:SetPoint("BOTTOM", DiceMasterChargesFrame, "TOP", 0, 0)
				DiceMasterMoraleBar:SetPoint("TOP", DiceMasterPanel, "BOTTOM", 0, -20)
				if IsAddOnLoaded("DiceMaster_UnitFrames") then
					DiceMasterUnitsPanel:SetPoint("TOP", 0, -200)
				end
			end;
		};
		
		curseLink = {
			order = 21;
			name  = "Curse Forge";
			type  = "input";
			width = "double";
			get   = function( info ) return "https://www.curseforge.com/wow/addons/dicemaster" end;
		};
		
		discordLink = {
			order = 22;
			name  = "Discord";
			type  = "input";
			width = "double";
			get   = function( info ) return "https://discord.gg/zCRJVQj" end;
		};
	};
}

Me.configOptionsCharges = {
	type  = "group";
	order = 1;
	args = { 
		-----------------------------------------------------------------------
		header = {
			order = 0;
			name  = "Configure the Health and Charges bar.";
			type  = "description";
		};
		
		healthGroup = {
			name     = "Health";
			inline   = true;
			order    = 12;
			type     = "group";
			args = {
				healthCurrent = {
					order = 10;
					name  = "Current Health";
					desc  = "The current amount of Health that this character has.";
					type  = "range"; 
					min   = 0;
					max   = 1000;
					step  = 1;
					set   = function( info, val ) 
						Me.db.profile.health = val
						Me.RefreshHealthbarFrame( DiceMasterChargesFrame.healthbar, Me.db.profile.health, Me.db.profile.healthMax, Me.db.profile.armor )
	
						Me.BumpSerial( Me.db.char, "statusSerial" )
						Me.Inspect_ShareStatusWithParty() 
					end;
					get   = function( info ) return Me.db.profile.health end;
				}; 
			  
				healthMax = {
					order = 20;
					name  = "Maximum Health";
					desc  = "The maximum amount of Health that this character can have.";
					type  = "range"; 
					min   = 1;
					max   = 1000;
					step  = 1;
					set   = function( info, val ) 
						Me.db.profile.healthMax = val
						Me.configOptionsCharges.args.healthGroup.args.healthCurrent.max = val
						if Me.db.profile.health > Me.db.profile.healthMax then
							Me.db.profile.health = Me.db.profile.healthMax
						end
						Me.RefreshHealthbarFrame( DiceMasterChargesFrame.healthbar, Me.db.profile.health, Me.db.profile.healthMax, Me.db.profile.armor )
	
						Me.BumpSerial( Me.db.char, "statusSerial" )
						Me.Inspect_ShareStatusWithParty() 
					end;
					get   = function( info ) return Me.db.profile.healthMax end;
				}; 
				
				healthPos = {
					order = 30;
					name  = "Anchor Health Bar Below Traits on Inspect Frame";
					desc  = "Move the health bar on the Inspect Frame so that it's positioned beneath the traits bar.";
					width = "full";
					type  = "toggle";
					set = function( info, val ) 
						Me.db.char.healthPos = val
						Me.Inspect_Open( UnitName( "target" ))
					end;
					get = function( info ) return Me.db.char.healthPos end;
				};
			};
		};
	
		enableCharges = {
			order = 13;
			name  = "Enable Charges";
			desc  = "Enable usage of the charges system for this character.";
			width = "full";
			type  = "toggle";
			set = function( info, val ) 
				Me.db.profile.charges.enable = val 
				Me.configOptionsCharges.args.chargesGroup.hidden = not val
				Me.OnChargesChanged() 
			end;
			get = function( info ) return Me.db.profile.charges.enable end;
		};

		chargesGroup = {
			name     = "Charges";
			inline   = true;
			order    = 14;
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
					hidden = false;
					min   = 1;
					max   = 8;
					step  = 1;
					set   = function( info, val ) 
						Me.db.profile.charges.max = val
						Me.OnChargesChanged()
					end;
					get   = function( info ) return Me.db.profile.charges.max end;
				}; 
				
				chargesMaxTwo = {
					order = 50;
					name  = "Maximum Charges";
					desc  = "The maximum amount of charges that this character can accumulate.";
					type  = "range";
					hidden = true;
					min   = 1;
					max   = 100;
					step  = 1;
					set   = function( info, val ) 
						Me.db.profile.charges.max = val
						if Me.db.profile.charges.count > Me.db.profile.charges.max then
							Me.db.profile.charges.count = Me.db.profile.charges.max
						end
						Me.OnChargesChanged()
					end;
					get   = function( info ) return Me.db.profile.charges.max end;
				}; 
				
				chargesTooltip = {
					order = 60;
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
					order = 70;
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
						["Rhyolith"] = "Rhyolith",
						["KargathRoarCrowd"] = "Ogre",
						["Meditation"] = "Meditation",
						["Jaina"] = "Jaina",
						["NZoth"] = "N'zoth",
						["sanctum-bar"] = "Arcane Sanctum",
						["warden-bar"] = "Warden",
						["RevendrethAnima"] = "Revendreth",
						["BastionAnima"] = "Bastion",
						["MaldraxxusAnima"] = "Maldraxxus",
						["ArdenwealdAnima"] = "Ardenweald",
					};
					set   = function( info, val ) 
						Me.db.profile.charges.symbol = val
						if val:find("charge") then
							if Me.db.profile.charges.max > 8 then
								Me.db.profile.charges.max = 8;
							end
							
							if Me.db.profile.charges.count > 8 then
								Me.db.profile.charges.count = 8
							end
							Me.configOptionsCharges.args.chargesGroup.args.chargesMax.hidden = false
							Me.configOptionsCharges.args.chargesGroup.args.chargesMaxTwo.hidden = true
						else
							Me.configOptionsCharges.args.chargesGroup.args.chargesMax.hidden = true
							Me.configOptionsCharges.args.chargesGroup.args.chargesMaxTwo.hidden = false
						end
						Me.OnChargesChanged()
					end;
					get   = function( info ) return Me.db.profile.charges.symbol end;
				};
				
				chargesFlash = {
					order = 80;
					name  = "Enable Flash When Bar is Full";
					desc  = "Toggle whether your charges bar flashes when filled.";
					width = "full";
					type  = "toggle";
					set = function( info, val ) 
						Me.db.profile.charges.flash = val
						Me.OnChargesChanged() 
					end;
					get = function( info ) return Me.db.profile.charges.flash end;
				};
				
				chargesPos = {
					order = 90;
					name  = "Anchor Charges Bar Below Health Bar";
					desc  = "Move your charges bar so that it's positioned beneath your health bar.";
					width = "full";
					type  = "toggle";
					set = function( info, val ) 
						Me.db.profile.charges.pos = val
						Me.OnChargesChanged()
					end;
					get = function( info ) return Me.db.profile.charges.pos end;
				};
			};
		};
	};
}

Me.configOptionsProgressBar = {
	type  = "group";
	order = 1;
	args = { 
		-----------------------------------------------------------------------
		header = {
			order = 0;
			name  = "Configure the Progress Bar frame.";
			type  = "description";
		};
		
		enableMorale = {
			order = 15;
			name  = "Enable Progress Bar";
			desc  = "Enable usage of a group-wide progress bar when you are leader.";
			width = "full";
			type  = "toggle";
			set = function( info, val ) 
				Me.db.profile.morale.enable = val 
				Me.RefreshMoraleFrame() 
			end;
			get = function( info ) return Me.db.profile.morale.enable end;
		};
		
		moraleGroup = {
			name     = "Dungeon Master Settings";
			inline   = true;
			order    = 16;
			type     = "group";
			args = {
				header = {
					order = 0;
					name  = "These settings only take effect when you are the leader of your party or raid.";
					type  = "description";
				};
			
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
				
				moraleSymbol = {
					order = 40;
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
						["Rhyolith"] = "Rhyolith",
						["KargathRoarCrowd"] = "Ogre",
						["Meditation"] = "Meditation",
						["Jaina"] = "Jaina",
						["NZoth"] = "N'zoth",
						["sanctum-bar"] = "Arcane Sanctum",
						["warden-bar"] = "Warden",
						["RevendrethAnima"] = "Revendreth",
						["BastionAnima"] = "Bastion",
						["MaldraxxusAnima"] = "Maldraxxus",
						["ArdenwealdAnima"] = "Ardenweald",
					};
					set   = function( info, val ) 
						Me.db.profile.morale.symbol = val
						Me.RefreshMoraleFrame()
					end;
					get   = function( info ) return Me.db.profile.morale.symbol end;
				}; 
				
				moraleTooltip = {
					order = 50;
					name  = "Progress Bar Description";
					desc  = "A description for the progress bar tooltip.";
					type  = "input";
					multiline = 3;
					width = "full";
					set = function( info, val ) 
						Me.db.profile.morale.tooltip = val
						Me.RefreshMoraleFrame()
					end;
					get = function( info ) return Me.db.profile.morale.tooltip end;
				};
				
				moraleCount = {
					order = 60;
					name  = "Default Value";
					desc  = "The default value of the progress bar.";
					type  = "range"; 
					min   = 0;
					max   = 100;
					step  = 1;
					set   = function( info, val ) 
						Me.db.profile.morale.count = val
						Me.RefreshMoraleFrame( val )
					end;
					get   = function( info ) return Me.db.profile.morale.count end;
				}; 
				
				moraleStep = {
					order = 70;
					name  = "Increase/Decrease Value";
					desc  = "The amount that is added/removed when the progress bar is clicked.";
					type  = "range"; 
					min   = 1;
					max   = 100;
					step  = 1;
					set   = function( info, val ) 
						Me.db.profile.morale.step = val
						Me.RefreshMoraleFrame()
					end;
					get   = function( info ) return Me.db.profile.morale.step end;
				}; 
				
				moraleScale = {
					order     = 80;
					name      = "Progress Bar Scale";
					desc      = "Change the size of the Progress Bar frame.";
					type      = "range";
					min       = 0.25;
					max       = 10;
					softMax   = 4;
					isPercent = true;
					set = function( info, val ) 
						Me.db.profile.morale.scale = val;
						Me.ApplyUiScale()
					end;
					get = function( info ) return Me.db.profile.morale.scale end;
				}; 
			};
		};
	};
}

Me.configOptionsManager = {
	type  = "group";
	order = 1;
	args = { 
		-----------------------------------------------------------------------
		header = {
			order = 0;
			name  = "Configure the DM Manager settings.";
			type  = "description";
		};
		
		hideTracker = {
			order = 10;
			name  = "Enable DM Manager";
			desc  = "Enable the DM Manager frame to keep track of your group's rolls and view group-wide notes.";
			type  = "toggle";
			width = "double";
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
		
		trackerScale = {
			order     = 20;
			name      = "DM Manager Scale";
			desc      = "The size of the DM Manager frame.";
			type      = "range";
			min       = 0.25;
			max       = 10;
			softMax   = 4;
			isPercent = true;
			set = function( info, val ) 
				Me.db.char.trackerScale = val;
				Me.ApplyUiScale()
			end;
			get = function( info ) return Me.db.char.trackerScale end;
		};
		
		trackerAnchor = {
			order = 30;
			name  = "Details Frame Anchor";
			desc  = "Choose whether the Detail Frame anchors to the left or right.";
			type  = "select"; 
			style = "radio";
			values = {
				["LEFT"] = "Left",
				["RIGHT"] = "Right",
			};
			set   = function( info, val ) 
				Me.db.global.trackerAnchor = val
				Me.DiceMasterRollDetailFrame_Update()
			end;
			get   = function( info ) return Me.db.global.trackerAnchor end;
		};
		
		trackerKeybind = {
			order     = 40;
			name	  = "Toggle Key";
			desc      = "Set a keybinding for the DM Manager frame.";
			type      = "keybinding";
			set = function( info, val ) 
				Me.db.char.trackerKeybind = val;
				Me.ApplyKeybindings()
			end;
			get = function( info ) return Me.db.char.trackerKeybind end;
		};
	};
}

Me.configOptionsUF = {
	type  = "group";
	order = 1;
	args = { 
		-----------------------------------------------------------------------
		header = {
			order = 0;
			name  = "Configure the Unit Frames settings.";
			type  = "description";
		};
		
		enable = {
			order = 1;
			name  = "Enable Unit Frames";
			desc  = "Toggle display of the unit frames.";
			type  = "toggle";
			set   = function( info, val ) 
				if IsAddOnLoaded("DiceMaster_UnitFrames") then
					if val then
						Me.PrintMessage("|TInterface/AddOns/DiceMaster/Texture/logo:12|t Unit Frames enabled.", "SYSTEM")
					else
						Me.PrintMessage("|TInterface/AddOns/DiceMaster/Texture/logo:12|t Unit Frames disabled.", "SYSTEM")
					end
					Me.ShowUnitPanel( val )
				else
					Me.PrintMessage("|TInterface/AddOns/DiceMaster/Texture/logo:12|t DiceMaster Unit Frames module not found. Enable the module from your AddOns list.", "SYSTEM")
				end
			end;
			get   = function( info ) return not Me.db.char.unitframes.enable end;
		};
 
		uiScale = {
			order     = 5;
			name      = "UI Scale";
			desc      = "The size of the Unit Frames panel.";
			type      = "range";
			min       = 0.25;
			max       = 10;
			softMax   = 4;
			isPercent = true;
			set = function( info, val ) 
				Me.db.char.unitframes.scale = val;
				if IsAddOnLoaded("DiceMaster_UnitFrames") then
					Me.ApplyUiScaleUF()
				end
			end;
			get = function( info ) return Me.db.char.unitframes.scale end;
		};
		
		miniFrames = {
			order = 10;
			name  = "Use Smaller Frames by Default";
			desc  = "Unit Frames appear smaller by default unless manually expanded.";
			type  = "toggle";
			width = "full";
			set = function( info, val )
				Me.db.global.miniFrames = val
				if IsAddOnLoaded("DiceMaster_UnitFrames") then
					Me.ApplyUiScaleUF()
				end
			end;
			get = function( info ) return Me.db.global.miniFrames end;
		};
		
		talkingHeads = {
			order = 15;
			name  = "Enable Talking Heads";
			desc  = "Allow the party leader to send dynamic Talking Head messages to you.";
			type  = "toggle";
			width = "full";
			set = function( info, val )
				Me.db.global.talkingHeads = val
			end;
			get = function( info ) return Me.db.global.talkingHeads end;
		};
		
		soundEffects = {
			order = 20;
			name  = "Enable Sound Effects";
			desc  = "Allow the party leader to use sound effects with Unit Frames.";
			type  = "toggle";
			width = "full";
			set = function( info, val )
				Me.db.global.soundEffects = val
			end;
			get = function( info ) return Me.db.global.soundEffects end;
		};
		
		dungeonMasterGroup = {
			name     = "Dungeon Master Settings";
			inline   = true;
			order    = 30;
			type     = "group";
			args = {
				header = {
					order = 0;
					name  = "These settings only take effect when you are the leader of your party or raid.";
					type  = "description";
				};
				
				allowAssistantTalkingHeads = {
					order = 10;
					name  = "Allow Raid Assistants to Send Talking Heads";
					desc  = "Toggle whether raid assistants are allowed to send Talking Heads.";
					width = "full";
					type  = "toggle";
					set = function( info, val ) 
						Me.db.global.allowAssistantTalkingHeads = val
						if Me.IsLeader( false ) then
							for i = 1, #DiceMasterUnitsPanel.unitframes do
								DiceMasterUnitsPanel.unitframes[i].allowRaidAssistant = val
							end
							Me.UpdateUnitFrames()
						end
					end;
					get = function( info ) return Me.db.global.allowAssistantTalkingHeads end;
				};
				
				allowBuffs = {
					order = 20;
					name  = "Allow Players to Buff Unit Frames";
					desc  = "Toggle whether players can apply buffs to Unit Frames.";
					width = "full";
					type  = "toggle";
					set = function( info, val ) 
						Me.db.global.allowBuffs = val
						if Me.IsLeader( false ) then
							for i = 1, #DiceMasterUnitsPanel.unitframes do
								DiceMasterUnitsPanel.unitframes[i].allowBuffs = val
							end
						end
					end;
					get = function( info ) return Me.db.global.allowBuffs end;
				};
				
				bloodEffects = {
					order = 30;
					name  = "Enable Blood Effects on Unit Frames";
					desc  = "Toggle whether Unit Frames display blood spray effects when they lose health.";
					width = "full";
					type  = "toggle";
					set = function( info, val ) 
						Me.db.global.bloodEffects = val
						if Me.IsLeader( false ) then
							for i = 1, #DiceMasterUnitsPanel.unitframes do
								DiceMasterUnitsPanel.unitframes[i].bloodEnabled = val
							end
						end
					end;
					get = function( info ) return Me.db.global.bloodEffects end;
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
	local charges = Me.configOptionsCharges
	local progressbar = Me.configOptionsProgressBar
	local dmmanager = Me.configOptionsManager
	local unitframes = Me.configOptionsUF
	local profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable( Me.db )
	profiles.order = 500
	 
	AceConfig:RegisterOptionsTable( "DiceMaster", options )	
	AceConfig:RegisterOptionsTable( "Charges", charges )	
	AceConfig:RegisterOptionsTable( "Progress Bar", progressbar )	
	AceConfig:RegisterOptionsTable( "DM Manager", dmmanager )	
	AceConfig:RegisterOptionsTable( "Unit Frames", unitframes )	
	AceConfig:RegisterOptionsTable( "DiceMaster Profiles", profiles )
	
	Me.config = AceConfigDialog:AddToBlizOptions( "DiceMaster", "DiceMaster" )
	Me.configCharges = AceConfigDialog:AddToBlizOptions( "Charges", "Charges", "DiceMaster" )
	Me.configProgressBar = AceConfigDialog:AddToBlizOptions( "Progress Bar", "Progress Bar", "DiceMaster" )
	Me.configManager = AceConfigDialog:AddToBlizOptions( "DM Manager", "DM Manager", "DiceMaster" )
	Me.configUnitFrames = AceConfigDialog:AddToBlizOptions( "Unit Frames", "Unit Frames", "DiceMaster" )
	Me.configProfiles = AceConfigDialog:AddToBlizOptions( "DiceMaster Profiles", "Profiles", "DiceMaster" )
	
	local function CreateLogo( frame )
		local logo = CreateFrame('Frame', nil, frame, BackdropTemplateMixin and "BackdropTemplate")
		logo:SetFrameLevel(4)
		logo:SetSize(64, 64)
		logo:SetPoint('TOPRIGHT', 8, 24)
		logo:SetBackdrop({bgFile = "Interface/AddOns/DiceMaster/Texture/logo"})
		frame.logo = logo
	end
	
	CreateLogo( Me.config )
	CreateLogo( Me.configCharges )
	CreateLogo( Me.configProgressBar )
	CreateLogo( Me.configManager )
	CreateLogo( Me.configUnitFrames )
	CreateLogo( Me.configProfiles )
end

local interfaceOptionsNeedsInit = true
-------------------------------------------------------------------------------
-- Open the configuration panel.
--
function Me.OpenConfig() 
	Me.configOptionsCharges.args.chargesGroup.hidden = not Me.db.profile.charges.enable
	Me.configOptionsCharges.args.healthGroup.args.healthCurrent.max = Me.db.profile.healthMax
	
	if Me.db.profile.charges.enable and Me.db.profile.charges.symbol:find("charge") then
		if Me.db.profile.charges.max > 8 then
			Me.db.profile.charges.max = 8;
		end
		if Me.db.profile.charges.count > 8 then
			Me.db.profile.charges.count = 8
		end
		Me.configOptionsCharges.args.chargesGroup.args.chargesMax.hidden = false
		Me.configOptionsCharges.args.chargesGroup.args.chargesMaxTwo.hidden = true
	else
		Me.configOptionsCharges.args.chargesGroup.args.chargesMax.hidden = true
		Me.configOptionsCharges.args.chargesGroup.args.chargesMaxTwo.hidden = false
	end
	
	if Me.db.profile.health > Me.db.profile.healthMax then
		Me.db.profile.health = Me.db.profile.healthMax
	end
	
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
	Me.configOptionsCharges.args.chargesGroup.hidden = not Me.db.profile.charges.enable
	Me.configOptionsCharges.args.healthGroup.args.healthCurrent.max = Me.db.profile.healthMax
	
	-- bump all serials, everything is considered dirty
	Me.BumpSerial( Me.db.char, "statusSerial" )
	for i = 1, 5 do
		Me.BumpSerial( Me.db.char.traitSerials, i )
	end
	Me.Inspect_ShareStatusWithParty()
	
	Me.ApplyUiScale()
	Me.RefreshHealthbarFrame( DiceMasterChargesFrame.healthbar, Me.db.profile.health, Me.db.profile.healthMax, Me.db.profile.armor )
	Me.RefreshChargesFrame( true, true )  
	Me.TraitEditor_Refresh()
	Me.UpdatePanelTraits()
end
