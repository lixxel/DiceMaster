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

-- Message shown when a non-guildie tries to use it.
local NOT_PERMITTED_MESSAGE = "|cFFFFFF00DiceMaster is for use by members of <|rThe League of Lordaeron|cFFFFFF00> only. Visit our website at leagueoflordaeron.enjin.com to join!"

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
	{ "Reload",             "|TInterface/AddOns/DiceMaster/Texture/icon-reload:12|t |cFFFFFFFFReload|r" };                                                       -- "reload"
	{ "(%d+)%sHealth",      "%1|TInterface/AddOns/DiceMaster/Texture/health-heart:12|t" };                -- e.g. "1 health"
	{ "Rescue",             "|TInterface/AddOns/DiceMaster/Texture/icon-rescue:12|t |cFFFFFFFFRescue|r" };                                                       -- "rescue"
	{ "Advantage",          "|cFFFFFFFFAdvantage|r" };                                                    -- "advantage"
	{ "Disadvantage",       "|cFFFFFFFFDisadvantage|r" };                                                 -- "disadvantage"
	{ "%s(Stun[snedig]*)",    " |TInterface/AddOns/DiceMaster/Texture/icon-stun:12|t |cFFFFFFFF%1|r" };   -- "stun"
	{ "%s(Poison[sedig]*)",   " |TInterface/AddOns/DiceMaster/Texture/icon-poison:12|t |cFFFFFFFF%1|r" };   -- "poison"
	{ "%s(Control[sledig]*)", " |TInterface/AddOns/DiceMaster/Texture/icon-control:12|t |cFFFFFFFF%1|r" };	  -- "control"
	{ "%s[+]%d+",           "|cFF00FF00%1|r" };                                                           -- e.g. "+1"
	{ "%s[-]%d+",           "|cFFFF0000%1|r" };                                                           -- e.g. "-3"
	{ "%d*[dD]%d+[+-]?%d*", "|cFFFFFFFF%1|r" };                                                           -- dice rolls e.g. "1d6" 
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
-- Update enchant duration for a trait description tooltip.
--
-- @param text Text to format.
-- @returns formatted text.
--

function Me.FormatEnchantTooltip( altdesc )
	local reference = altdesc
	local daysfrom = difftime(time(), reference) / (24 * 60 * 60)
	local wholedays = math.floor(daysfrom)
	local unit = "days"
	if wholedays == 1 then unit = "day" end
	if wholedays > 14 then wholedays = 0 end;
	if wholedays > 13 then wholedays = 2; unit = "weeks" end
	wholedays = math.abs(wholedays)
	
	local duration = "("..wholedays.." "..unit..")"
	return duration
end

-------------------------------------------------------------------------------
-- Add color codes to a trait description tooltip.
--
-- @param text Text to format.
-- @returns formatted text.
--
function Me.FormatDescTooltip( text )
	for k, v in ipairs( TOOLTIP_DESC_SUBS ) do
		text = gsub( text, v[1], v[2] )
	end
	return text
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
	["CHARGE7"] = "7 &cp"; ["CHARGE8"] = "8 &cp";
}

function Me.FormatUsage( usage, name )
	name = name or UnitName("player")
	
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
	return text
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
	DiceMasterChargesFrame.bar:SetMax( Profile.charges.max ) 
	DiceMasterChargesFrame.bar:SetFilled( Profile.charges.count ) 
	
	if not Me.db.char.hidepanel then
		DiceMasterChargesFrame:Show()
		if Profile.charges.enable then
			DiceMasterChargesFrame.bar:Show()
		else
			DiceMasterChargesFrame.bar:Hide()
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
	end
	
	if color then
		DiceMasterChargesFrame.bar:SetTexture( 
			"Interface/AddOns/DiceMaster/Texture/charge-orb", 
			Profile.charges.color[1], Profile.charges.color[2], Profile.charges.color[3] )
	end
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
	 
	Me.RefreshChargesFrame( true, true ) 
	Me.RefreshHealthbarFrame ( true, true )
	
	Me.Inspect_ShareStatusWithParty()
	
	Me.SetupWorldClickDetection()
end

