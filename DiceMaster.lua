-------------------------------------------------------------------------------
-- Dice Master (C) 2017 <The League of Lordaeron> - Moon Guard
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Main module.
--

local MAX_MAXHEALTH = 10

local VERSION = GetAddOnMetadata( "DiceMaster", "Version" )
DiceMaster4 = LibStub("AceAddon-3.0"):NewAddon( "DiceMaster", 
	             		  "AceEvent-3.0", "AceComm-3.0", "AceSerializer-3.0" ) 
local Me = DiceMaster4 
Me.version = VERSION
Me.Profile = {}

-------------------------------------------------------------------------------
-- Profile is a shortcut to Me.db.profile
setmetatable( Me.Profile, { 

	__index = function( table, key ) 
		return Me.db.profile[key]
	end;
	
	__newindex = function( table, key, value )
		Me.db.profile[key] = value
	end;
})

local Profile = Me.Profile

-------------------------------------------------------------------------------
-- Constants/Options
--

-- Guilds that may use this addon
local GUILDS_ALLOWED = {
	["The League of Lordaeron"] = true;
}

-------------------------------------------------------------------------------
-- Trait.usage modes.
--
local TRAIT_USAGE_MODES = {
	"USE1", "USE2", "USE3", "PASSIVE", 
	"CHARGE1", "CHARGE2", "CHARGE3", "CHARGE4", "CHARGE5", "CHARGE6", "CHARGE7", "CHARGE8"
}

-- tuples for subbing text in description tooltips
local TOOLTIP_DESC_SUBS = {
	{ "[dD]ouble [oO]r [nN]othing", "|cFFFFFFFFDouble or Nothing|r" };                                    -- "double or nothing"
	{ "Reload",             "|cFFFFFFFFReload|r" };                                                       -- "reload"
	{ "(%d+)%sHealth",      "|cFFFFFFFF%1|r|TInterface/AddOns/DiceMaster/Texture/health-heart:12|t" };                -- e.g. "1 health"
	{ "Rescue",             "|cFFFFFFFFRescue|r" };                                                       -- "rescue"
	{ "Advantage",          "|cFFFFFFFFAdvantage|r" };                                                    -- "advantage"
	{ "Disadvantage",       "|cFFFFFFFFDisadvantage|r" };                                                 -- "disadvantage"
	{ "(Stun[sneding]*)",    "|cFFFFFFFF%1|r" };   -- "stun"
	{ "(Poison[sneding]*)",   "|cFFFFFFFF%1|r" };   -- "poison"
	{ "(Control[sleding]*)", "|cFFFFFFFF%1|r" };	  -- "control"
	{ "(NAT1)", "|cFFFFFFFF%1|r" };	  -- "NAT1"
	{ "(NAT20)", "|cFFFFFFFF%1|r" };	  -- "NAT20"
	{ "%s?[+]%d+",           "|cFF00FF00%1|r" };                                                           -- e.g. "+1"
	{ "%s?[-]%d+",           "|cFFFF0000%1|r" };                                                           -- e.g. "-3"
	{ "%s?%d*[dD]%d+[+-]?%d*", "|cFFFFFFFF%1|r" };                                                           -- dice rolls e.g. "1d6" 
}
 
-------------------------------------------------------------------------------
 
Me.traitCount  = 5
Me.TRAIT_USAGE_MODES = TRAIT_USAGE_MODES
 
-------------------------------------------------------------------------------
-- Misc helper functions
-------------------------------------------------------------------------------
function Me.Clamp( a, min, max )
	return math.min( math.max( a, min ), max )
end

-------------------------------------------------------------------------------
function Me.OutOfRange( a, min, max )
	return a < min or a > max
end

-------------------------------------------------------------------------------
-- Check to see if the player is in the League of Lordaeron.
--
-- @returns true if the player is in the League.
--
function Me.PermittedUse() 
	
	if Me.backdoor then 
		-- if you're reading this, you can probably bypass this just as easily :)
		return true 
	end
	
	local guildName = GetGuildInfo("player")
	if GUILDS_ALLOWED[guildName] then
		return true
	end
end


-------------------------------------------------------------------------------
-- Handler for showing tooltips for frames that have used SetupTooltip.
--
local function OnEnterTippedButton(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")

	-- Standard DICEMASTER tooltip layout:
	--
	-- [Icon] Name
	--
	-- Cost         Range
	--
	-- Cast Time
	--
	-- Description
	--
	
    if self.tooltipTexture then
		-- icon with name
        GameTooltip:AddLine("|T"..self.tooltipTexture..":32|t "..self.tooltipText, 1, 1, 1, true)
    else
        GameTooltip:AddLine(self.tooltipText, 1, 1, 1, true)
    end
	 
    GameTooltip:AddDoubleLine(self.tooltipText2a, self.tooltipText2b, 1, 1, 1, 1, 1, 1, true)
	 
    GameTooltip:AddLine(self.tooltipText3, 1, 1, 1, true)
	 
	if self.tooltipText4 then
		GameTooltip:AddLine( Me.FormatDescTooltip( self.tooltipText4 ), 1, 0.81, 0, true)
	end
	
    GameTooltip:Show()
end

-------------------------------------------------------------------------------
-- "Leave" handler for tool tipped frame.
--
local function OnLeaveTippedButton()
    GameTooltip:Hide()
end

-------------------------------------------------------------------------------
-- Setup the enter/leave scripts for a frame.
--
-- @param texture     Icon to use next to tooltip name.
-- @param spellname   Name of spell or generic text at the top.
-- @param cost        Cost of spell or generic text under the name.
-- @param range       Range of spell or generic text under the name to the right.
-- @param casttime    Cast time of spell or generic text under cost.
-- @param description Description of spell or generic tooltip description.
--
-- In essence, the tooltip is layed out like a normal spell tooltip.
--
function Me.SetupTooltip(self, texture, spellname, cost, range, 
                        casttime, description)
						
    if spellname then
	
        self.tooltipTexture = texture
        self.tooltipText = spellname
        self.tooltipText2a = cost
        self.tooltipText2b = range
        self.tooltipText3 = casttime
        self.tooltipText4 = description
        self:SetScript( "OnEnter", OnEnterTippedButton )
        self:SetScript( "OnLeave", OnLeaveTippedButton )
    else
        self:SetScript("OnEnter", nil)
        self:SetScript("OnLeave", nil)
    end
end

-------------------------------------------------------------------------------
-- Increment a serial number.
--
-- @param table Table that houses the serial, e.g. Me or a trait
-- @param key   Name of the serial number, e.g. "serial" or "statusSerial"
--
function Me.BumpSerial( table, key )
	table[key] = (table[key] % 32768) + 1
end


-------------------------------------------------------------------------------
-- Convert trait usage number into text.
--
-- @param usage Usage index.
-- @param name  Name of person this is associated to. It's used to get the name
--              of their charges. Default=player's name
--
local TRAIT_USAGE = {
	["USE1"] = "1 Use"; ["USE2"] = "2 Uses"; ["USE3"] = "3 Uses";
	["PASSIVE"] = "Passive";
	["CHARGE1"] = "1 &cs"; ["CHARGE2"] = "2 &cp"; ["CHARGE3"] = "3 &cp";
	["CHARGE4"] = "4 &cp"; ["CHARGE5"] = "5 &cp"; ["CHARGE6"] = "6 &cp";
	["CHARGE7"] = "7 &cp"; ["CHARGE8"] = "8 &cp"; ["LEVEL"] = "Level &fl Follower";
}

function Me.FormatUsage( usage, name )
	name = name or UnitName("player")
	local level = Me.inspectData[name].follower.level or 0
	
	local text = TRAIT_USAGE[usage] or "<Unknown Usage>"
	
	local plural_charges, singular_charges = Me.inspectData[name].charges.name:match( "^%s*(.*)/(.*)%s*$" )
	if not singular_charges then
		plural_charges   = Me.inspectData[name].charges.name
		singular_charges = plural_charges
		singular_charges = singular_charges:gsub( "[Ss]$", "" ) -- clip off an S :)
	end
	-- sub charges
	text = text:gsub( "&cs", singular_charges )
	text = text:gsub( "&cp", plural_charges )
	text = text:gsub( "&fl", level )
	return text
end

-------------------------------------------------------------------------------
-- Add custom icons and colors for a trait description tooltip.
--
-- @param text Text to format.
-- @returns formatted text.
--

function Me.FormatTooltipIcons( text )
	local a, b = strfind(text, "<img>");
	-- find the icon in the text
	if a and b then
		local c, d = strfind(text, "</img>");
		if c then
			local data = string.sub(text, b + 1, c - 1);
			if data then
				text = string.gsub(text, "<img>"..data.."</img>", "|T"..data..":16|t")
			else
				text = string.gsub(text, "<img>"..data.."</img>", "")
			end
		end
	end
	return text
end

-------------------------------------------------------------------------------
-- Convert decimals to RGB colors.
--

local function RGBPercToHex(r, g, b)
	r = tonumber(r)
	g = tonumber(g)
	b = tonumber(b)
	r = r <= 1 and r >= 0 and r or 0
	g = g <= 1 and g >= 0 and g or 0
	b = b <= 1 and b >= 0 and b or 0
	return string.format("%02x%02x%02x", r*255, g*255, b*255)
end

-------------------------------------------------------------------------------
-- Add custom colors for a trait description tooltip.
--
-- @param text Text to format.
-- @returns formatted text.
--

function Me.FormatTooltipColors( text )
	local a, b = strfind(text, "<color=");
	-- find the color tag in the text
	if a and b then
		local c, d = strfind(text, ">", b);
		local data = string.sub(text, b + 1, c - 1);
		local r, g, b = strsplit(",", data);
		local hexCode = "|cff"..RGBPercToHex(r,g,b)
		local colorTag = string.sub(text,a,d)
		text = string.gsub(text,colorTag,hexCode)	
	end
	text = string.gsub(text,"</color>","|r")
	return text
end

-------------------------------------------------------------------------------
-- Add follower upgrades for a trait description tooltip.
--
-- @param text Text to format.
-- @returns formatted text.
--

local FOLLOWER_UPGRADES = {
	["Witch Hunter"] = {
		{name="|TInterface/AddOns/DiceMaster/Icons/diablo3_groundstomp:16|t Fleetfoot Boots", desc="You are unable to critically fail any defence roll."},
		{name="|TInterface/AddOns/DiceMaster/Icons/diablo3_impale:16|t Stakethrowers", desc="You may forego any defence round of your choosing and roll with Double or Nothing."},
		{name="|TInterface/AddOns/DiceMaster/Icons/Valla_Master:16|t Witchfinder", desc="Reduces the DC against witches by -3 and allows you to plainly see who is controlling Bewitched monsters."},
		},
	["Inquisitor"] = {
		{name="|TInterface/AddOns/DiceMaster/Icons/Varian_TwinBladesOfFury:16|t Silver Armaments", desc="Your successful attacks may now strike Phantasmal monsters."},
		{name="|TInterface/AddOns/DiceMaster/Icons/Valeera_Cripplingpoison:16|t Alchemical Fire", desc="Reduces the DC against Wicker monsters by -5 for you, but your failed defence rolls cost you twice as much health."},
		{name="|TInterface/AddOns/DiceMaster/Icons/TheButcher_FurnaceBlast_Fire:16|t Inquisition", desc="You have Advantage against all witches until you lose a defence roll."},
		},
}

function Me.FormatTooltipFollowers( text, player )
	player = player or UnitName("player")
	local level = Me.inspectData[player].follower.level or 0
	local follower = Me.inspectData[player].follower.name or nil
	
	if follower then
		local tierOne = "|cff9d9d9d- Unlocked at Follower Level 2|r"
		local tierTwo = "|cff9d9d9d- Unlocked at Follower Level 3|r"
		local tierThree = "|cff9d9d9d- Unlocked at Follower Level 5|r"
		
		local upgrades = 0;
		
		if level >= 2 then 
			tierOne = "|cFFFFFFFF"..FOLLOWER_UPGRADES[follower][1].name.."|r|n|cFF00FF00"..FOLLOWER_UPGRADES[follower][1].desc.."|r"
			upgrades = upgrades + 1
		end
		if level >= 3 then 
			tierTwo = "|cFFFFFFFF"..FOLLOWER_UPGRADES[follower][2].name.."|r|n|cFF00FF00"..FOLLOWER_UPGRADES[follower][2].desc.."|r"
			upgrades = upgrades + 1
		end
		if level >= 5 then 
			tierThree = "|cFFFFFFFF"..FOLLOWER_UPGRADES[follower][3].name.."|r|n|cFF00FF00"..FOLLOWER_UPGRADES[follower][3].desc.."|r"
			upgrades = upgrades + 1
		end
		
		local upgradeData = "Follower Upgrades ("..upgrades.."/3):|n"..tierOne.."|n"..tierTwo.."|n"..tierThree
		text = string.gsub(text,"Follower Upgrades",upgradeData)
	end
	
	return text
end

-------------------------------------------------------------------------------
-- Add color codes to a trait description tooltip.
--
-- @param text Text to format.
-- @returns formatted text.
--
function Me.FormatDescTooltip( text, name )
	name = name or UnitName("player")
	for k, v in ipairs( TOOLTIP_DESC_SUBS ) do
		text = gsub( text, v[1], v[2] )
	end
	
	-- <img> </img>
	local imgCount = 0
		for w in string.gmatch(text, "<img>") do
			imgCount = imgCount + 1
	end
	
	for i = 1, imgCount do
		text = Me.FormatTooltipIcons( text )
	end
	
	-- <color=r,g,b> </color>
	local colorCount = 0
		for w in string.gmatch(text, "<color=") do
			colorCount = colorCount + 1
	end
	
	for i = 1, colorCount do
		text = Me.FormatTooltipColors( text )
	end
	
	text = Me.FormatTooltipFollowers( text, name )

	return text
end

-------------------------------------------------------------------------------
-- Confirmation prompt for switching followers.
--

local FOLLOWER_DATA = {
	["inquisitor"] = {
		name = "Inquisitor",
		icon = "Interface/AddOns/DiceMaster/Icons/Followers_Inquisitor",
		desc = "The Order of Embers has trained hard to steel their mettle and resist the forces of witchcraft, granting you an extra 2 Health at the start of every event.|n|nFollower Upgrades|n|n\"The monster has many forms. You must know them all.\"",
		sound = "Interface/AddOns/DiceMaster/Sounds/Inquisitor_Intro.ogg",
		text = "Our foes will rue this day.",
		path = "Interface/AddOns/DiceMaster_UnitFrames/Texture/portrait-inquisitor",
	},
	["witch hunter"] = {
		name = "Witch Hunter",
		icon = "Interface/AddOns/DiceMaster/Icons/Followers_WitchHunter",
		desc = "The Witch Hunters hone the darkness of their enemies into a formidable weapon, increasing all of the modifiers on your traits by +1.|n|nFollower Upgrades|n|n\"The shadows are the hunter's greatest weapon.\"",
		sound = "Interface/AddOns/DiceMaster/Sounds/WitchHunter_Intro.ogg",
		text = "Our enemies will beg for mercy.",
		path = "Interface/AddOns/DiceMaster_UnitFrames/Texture/portrait-witch-hunter",
	},
}

StaticPopupDialogs["DICEMASTER_CHANGE_FOLLOWERS"] = {
  text = "Changing followers will wipe out your existing Command Trait and reset your follower's level to 1. Are you sure you wish to continue?",
  button1 = "Yes",
  button2 = "No",
  OnAccept = function(self, data)
    if data == "inquisitor" or data == "witch hunter" then
		Profile.follower.name = FOLLOWER_DATA[data].name
		Profile.follower.level = 1
		Profile.traits[5].name = FOLLOWER_DATA[data].name
		Profile.traits[5].icon = FOLLOWER_DATA[data].icon
		Profile.traits[5].usage = "LEVEL"
		Profile.traits[5].desc = FOLLOWER_DATA[data].desc
		PlaySound(44296)
		PlaySoundFile(FOLLOWER_DATA[data].sound)
		
		print("|cff71d5ff|HDiceMaster4:"..UnitName("player")..":5|h["..FOLLOWER_DATA[data].name.."]|h|r|cFFFFFF00 is now your follower.")
		
		--Talking Heads integration
		if DiceMasterUnitsPanel and Me.db.global.talkingHeads then
			DiceMasterTalkingHeadFrame_SetUnit(FOLLOWER_DATA[data].path, Profile.follower.name)
			DiceMasterTalkingHeadFrame_PlayCurrent(FOLLOWER_DATA[data].text)
		end
	elseif data == "clear" then
		Profile.follower.name = nil
		Profile.follower.level = 0
		Profile.traits[5].name = "Command Trait"
		Profile.traits[5].icon = "Interface/Icons/inv_misc_questionmark"
		Profile.traits[5].usage = Me.TRAIT_USAGE_MODES[1]
		Profile.traits[5].desc = "Type a description for your trait here."
	end
	Me.UpdatePanelTraits()
  end,
  OnCancel = function ()
  end,
  showAlert = true,
  timeout = 30,
  whileDead = true,
  hideOnEscape = true,
}

-------------------------------------------------------------------------------
-- Setup the trait buttons on the dice panel.
--

function Me.UpdatePanelTraits()
	local traits = DiceMasterPanel.traits
	for i=1,#traits do
		traits[i]:SetPlayerTrait( UnitName( "player" ), i ) 
	end
end

-------------------------------------------------------------------------------
-- Setup the enter/leave scripts for a trait button.
--
function Me.SetupTraitTooltip( button, trait, editable )
	button.tooltip_trait = trait
	button.tooltip_trait_edit = true
	button:SetScript( "OnEnter", OnEnterTraitButton )
	button:SetScript( "OnLeave", OnLeaveTippedButton )
end

-------------------------------------------------------------------------------
-- When the healthbar frame is clicked.
--
function Me.OnHealthClicked( button )

	local delta = 0
	if button == "LeftButton" then
		delta = 1
	elseif button == "RightButton" then
		delta = -1
	else
		return
	end
	  	
	if IsShiftKeyDown() then
		-- shift: adjust max health
		if Me.OutOfRange( Profile.healthMax+delta, 1, MAX_MAXHEALTH ) then
			return
		end
		
		Profile.healthMax = Profile.healthMax + delta
		Profile.health = Me.Clamp( Profile.health, 0, Profile.healthMax ) 
		PlaySound(54131)
		
	else
		if Me.OutOfRange( Profile.health+delta, 0, Profile.healthMax ) then
			return
		end
		Profile.health = Me.Clamp( Profile.health + delta, 0, Profile.healthMax )
	end
	
    DiceMasterChargesFrame.healthbar:SetMax( Profile.healthMax )
	DiceMasterChargesFrame.healthbar:SetFilled( Profile.health )
	
	Me.BumpSerial( Me.db.char, "statusSerial" )
	Me.Inspect_ShareStatusWithParty()  
end

-------------------------------------------------------------------------------
-- Update the UI for the healthbar frame.
--
function Me.RefreshHealthbarFrame()
	DiceMasterChargesFrame.healthbar:SetMax( Profile.healthMax )
	DiceMasterChargesFrame.healthbar:SetFilled( Profile.health )
end

-------------------------------------------------------------------------------
-- When the charges frame is clicked.
--
function Me.OnChargesClicked( button )
	if button == "LeftButton" then
		if Profile.charges.count == Profile.charges.max then return end
		Profile.charges.count = Profile.charges.count + 1
	elseif button == "RightButton" then
		if Profile.charges.count == 0 then return end
		Profile.charges.count = Profile.charges.count - 1
	end
	
	Me.BumpSerial( Me.db.char, "statusSerial" )
	
	Me.RefreshChargesFrame()
	Me.Inspect_ShareStatusWithParty() 
end

-------------------------------------------------------------------------------
-- Update the UI for the charges frame.
--
function Me.RefreshChargesFrame( tooltip, color )
	
	if not Me.db.char.hidepanel then
		DiceMasterChargesFrame:Show()
		if Profile.charges.enable then
			if not Profile.charges.symbol:find("charge") then
				DiceMasterChargesFrame.bar:Hide()
				DiceMasterChargesFrame.bar2:Show()
			else
				DiceMasterChargesFrame.bar:Show()
				DiceMasterChargesFrame.bar2:Hide()
			end
			DiceMasterChargesFrame.healthbar:SetPoint("CENTER", 0, 36)
		else
			DiceMasterChargesFrame.bar:Hide()
			DiceMasterChargesFrame.bar2:Hide()
			DiceMasterChargesFrame.healthbar:SetPoint("CENTER", 0, 12)
		end
	else
		DiceMasterChargesFrame:Hide()
	end
	
	if tooltip then
		local chargesPlural = Profile.charges.name:gsub( "/.*", "" )
		Me.SetupTooltip( DiceMasterChargesFrame.bar, nil, chargesPlural, 
			nil, nil, nil, 
			"Represents the amount of "..chargesPlural.." you have accumulated for certain traits.|n"
			.."|cFF707070<Left Click to Add "..chargesPlural..">|n"
			.."<Right Click to Remove "..chargesPlural..">")
		Me.SetupTooltip( DiceMasterChargesFrame.bar2, nil, chargesPlural, 
			nil, nil, nil, 
			"Represents the amount of "..chargesPlural.." you have accumulated for certain traits.|n"
			.."|cFF707070<Left Click to Add "..chargesPlural..">|n"
			.."<Right Click to Remove "..chargesPlural..">")
	end
	
	if color then
		DiceMasterChargesFrame.bar:SetTexture( 
			"Interface/AddOns/DiceMaster/Texture/"..Profile.charges.symbol or "Interface/AddOns/DiceMaster/Texture/charge-orb", 
			Profile.charges.color[1], Profile.charges.color[2], Profile.charges.color[3] )
		DiceMasterChargesFrame.bar2:SetStatusBarColor( Profile.charges.color[1], Profile.charges.color[2], Profile.charges.color[3] )
	end
	
	-- Check for an Interface path.
	if not Profile.charges.symbol:find("charge") then
		DiceMasterChargesFrame.bar2.frame:SetTexture("Interface/UNITPOWERBARALT/"..Profile.charges.symbol.."_Horizontal_Frame")
		DiceMasterChargesFrame.bar2.text:SetText( Profile.charges.count.."/"..Profile.charges.max )
	end
	
	DiceMasterChargesFrame.bar:SetMax( Profile.charges.max ) 
	DiceMasterChargesFrame.bar:SetFilled( Profile.charges.count ) 
	DiceMasterChargesFrame.bar2:SetMinMaxValues( 0 , Profile.charges.max ) 
	DiceMasterChargesFrame.bar2:SetValue( Profile.charges.count ) 
end

-------------------------------------------------------------------------------
function Me.TraitButtonClicked()
	Me.TraitEditor_Open()
end

-------------------------------------------------------------------------------
function Me.RollButtonClicked()
	Me.Roll( DiceMasterPanelDice:GetText() ) 
	if DiceMasterPanelDice:HasFocus() then
		DiceMasterPanelDice:ClearFocus()
	end
end

function Me.ApplyUiScale()
	DiceMasterPanel:SetScale( Me.db.char.uiScale * 1.4 )
	DiceMasterTraitEditor:SetScale( Me.db.char.uiScale * 1.4 )
	DiceMasterInspectFrame:SetScale( Me.db.char.uiScale * 1.2 )
	DiceMasterChargesFrame:SetScale( Me.db.char.uiScale * 1.2 )
end

function Me.ShowPanel( show )
	Me.db.char.hidepanel = not show
	
	if not show then
		DiceMasterPanel:Hide()
		DiceMasterChargesFrame:Hide()
	else
		DiceMasterPanel:Show()
		DiceMasterChargesFrame:Show()
	end
	
	Me.RefreshChargesFrame( true, true )
end

-------------------------------------------------------------------------------
-- Call when you change the charges settings.
--
function Me.OnChargesChanged()
	Me.RefreshChargesFrame( true, true )
	Me.BumpSerial( Me.db.char, "statusSerial" )
	Me.Inspect_ShareStatusWithParty()
end

-------------------------------------------------------------------------------
function Me.OnWorldClicked()
	if DiceMasterPanelDice:HasFocus() then
		DiceMasterPanelDice:ClearFocus()
	end
end

-------------------------------------------------------------------------------
function Me.SetupWorldClickDetection()
	
	WorldFrame:HookScript( "OnMouseDown", function()
		Me.OnWorldClicked()
		
	end)
end

-------------------------------------------------------------------------------
Me.frame = Me.frame or CreateFrame( "Frame" )
Me.frame:UnregisterAllEvents()

function Me:OnEnable()
	Me.SetupDB()
	Me.MinimapButton_Init()
	
	-- Load settings and initialize stuff
	Me.Events_Init()
	Me.Inspect_Init()
	Me.Console_Init()
	Me.ChatLinks_Init()
	Me.Dice_Init()
	Me.Comm_Init()
	Me.MinimapButton:OnLoad()
	Me.ImportDM3Saved()
	
	Me.ApplyUiScale()
	Me.ShowPanel( not Me.db.char.hidepanel )
	
	Me.UpdatePanelTraits()
	 
	Me.RefreshChargesFrame( true, true ) 
	Me.RefreshHealthbarFrame ( true, true )
	
	Me.Inspect_ShareStatusWithParty()
	
	Me.SetupWorldClickDetection()
end

