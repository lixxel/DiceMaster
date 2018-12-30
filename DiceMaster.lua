-------------------------------------------------------------------------------
-- Dice Master (C) 2017 <The League of Lordaeron> - Moon Guard
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Main module.
--

local MAX_MAXHEALTH = 1000

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
local Sticky = LibStub("LibSimpleSticky-1.0")

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
	{ "Reload[edsing]*",             "|cFFFFFFFFReload|r" };                                                       -- "reload"
	{ "(Reviv[edsing]*)",             "|cFFFFFFFF%1|r" };                                                       -- "revive"
	{ "(%d+)%sHealth",      "|cFFFFFFFF%1|r|TInterface/AddOns/DiceMaster/Texture/health-heart:12|t" };                -- e.g. "1 health"
	{ "(%d+)%sHP",      "|cFFFFFFFF%1|r|TInterface/AddOns/DiceMaster/Texture/health-heart:12|t" };                -- e.g. "1 hp"
	{ "(%d+)%sArmo[u]*r",      "|cFFFFFFFF%1|r|TInterface/AddOns/DiceMaster/Texture/armour-icon:12|t" };			-- e.g. "1 armour"
	{ "Immunity",             "|cFFFFFFFFImmunity|r" };                                                       -- "immunity"
	{ "Advantage",          "|cFFFFFFFFAdvantage|r" };                                                    -- "advantage"
	{ "Disadvantage",       "|cFFFFFFFFDisadvantage|r" };                                                 -- "disadvantage"
	{ "(Stun[snedig]*)",    "|cFFFFFFFF%1|r" };   -- "stun"
	{ "(Poison[seding]*)",   "|cFFFFFFFF%1|r" };   -- "poison"
	{ "(Control[sleding]*)", "|cFFFFFFFF%1|r" };	  -- "control"
	{ "(NAT1)", "|cFFFFFFFF%1|r" };	  -- "NAT1"
	{ "(NAT20)", "|cFFFFFFFF%1|r" };	  -- "NAT20"
	{ "%s?[+]%d+",           "|cFF00FF00%1|r" };                                                           -- e.g. "+1"
	{ "%s?[-]%d+",           "|cFFFF0000%1|r" };                                                           -- e.g. "-3"
	{ "%s?%d*[dD]%d+[+-]?%d*", "|cFFFFFFFF%1|r" };                                                           -- dice rolls e.g. "1d6" 
}

StaticPopupDialogs["DICEMASTER4_SETHEALTHVALUE"] = {
  text = "Set Health value:",
  button1 = "Accept",
  button2 = "Cancel",
  OnShow = function (self, data)
    self.editBox:SetText(Profile.health)
	self.editBox:SetNumeric()
	self.editBox:HighlightText()
  end,
  OnAccept = function (self, data)
    local text = tonumber(self.editBox:GetText() or Profile.health)
	if Me.OutOfRange( text, 0, Profile.healthMax ) then
		return
	end
	Profile.health = text
	Me.RefreshHealthbarFrame( DiceMasterChargesFrame.healthbar, Profile.health, Profile.healthMax, Profile.armor )
	
	Me.BumpSerial( Me.db.char, "statusSerial" )
	Me.Inspect_ShareStatusWithParty() 
  end,
  hasEditBox = true,
  timeout = 0,
  whileDead = true,
  hideOnEscape = true,
  preferredIndex = 3,
}

StaticPopupDialogs["DICEMASTER4_SETHEALTHMAX"] = {
  text = "Set maximum Health value:",
  button1 = "Accept",
  button2 = "Cancel",
  OnShow = function (self, data)
    self.editBox:SetText(Profile.healthMax)
	self.editBox:SetNumeric()
	self.editBox:HighlightText()
  end,
  OnAccept = function (self, data)
    local text = tonumber(self.editBox:GetText() or Profile.healthMax)
	if Me.OutOfRange( text, 1, 1000 ) then
		return
	end
	if Profile.health > Profile.healthMax then 
		Profile.health = Profile.healthMax 
	end
	Profile.healthMax = text
	Me.RefreshHealthbarFrame( DiceMasterChargesFrame.healthbar, Profile.health, Profile.healthMax, Profile.armor )
	
	Me.BumpSerial( Me.db.char, "statusSerial" )
	Me.Inspect_ShareStatusWithParty() 
  end,
  hasEditBox = true,
  timeout = 0,
  whileDead = true,
  hideOnEscape = true,
  preferredIndex = 3,
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
-- Check to see if the player is an officer.
--
-- @returns true if the player is an officer.
--
function Me.IsOfficer()
	local guildName, guildRankName, guildRankIndex = GetGuildInfo( "player" )
	
	if Me.PermittedUse() and guildRankIndex < 4 then
		return true
	end
end

-------------------------------------------------------------------------------
-- Check to see if the player is the group leader.
--
-- @returns true if the player is the leader.
--
function Me.IsLeader( allowAssistant )
	if allowAssistant and UnitIsGroupAssistant("player", 1) then
		return true
	end
	
	if not IsInGroup(1) then
		return true
	end
	
	if UnitIsGroupLeader("player", 1) then
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
	r = tonumber(r) or 0
	g = tonumber(g) or 0
	b = tonumber(b) or 0
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
-- Add color codes to a trait description tooltip.
--
-- @param text Text to format.
-- @returns formatted text.
--
function Me.FormatDescTooltip( text )
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

	return text
end

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
	  	
	if IsShiftKeyDown() and button == "LeftButton" then
		-- Open dialog for custom value.
		StaticPopup_Show("DICEMASTER4_SETHEALTHMAX")
	elseif IsControlKeyDown() and button == "LeftButton" then
		-- Open dialog for custom value.
		StaticPopup_Show("DICEMASTER4_SETHEALTHVALUE")
	elseif IsAltKeyDown() then
		if Me.OutOfRange( Profile.armor+delta, 0, Profile.healthMax ) then
			return
		end
		Profile.armor = Profile.armor + delta;
	else
		if Me.OutOfRange( Profile.health+delta, 0, Profile.healthMax ) then
			return
		end
		Profile.health = Me.Clamp( Profile.health + delta, 0, Profile.healthMax )
	end
	
    Me.RefreshHealthbarFrame( DiceMasterChargesFrame.healthbar, Profile.health, Profile.healthMax, Profile.armor )
	
	Me.BumpSerial( Me.db.char, "statusSerial" )
	Me.Inspect_ShareStatusWithParty()  
end

-------------------------------------------------------------------------------
-- Update the UI for the healthbar frame.
--
function Me.RefreshHealthbarFrame( self, healthValue, healthMax, armorValue )
	--DiceMasterChargesFrame.healthbar:SetMinMaxValues( 0, Profile.healthMax )
	--DiceMasterChargesFrame.healthbar:SetValue( Profile.health )
	
	local ratio = healthValue / healthMax;
	local startInset = 0.12
	local endInset = 0.05
	local fillAmount = startInset + ratio * ((1 - endInset) - startInset);
	self.fill:SetWidth(max(self:GetWidth() * fillAmount, 1));
	self.fill:SetTexCoord(0, fillAmount, 0.5, 0.75);
	
	self.text:SetText( healthValue.."/"..healthMax )
	
	if armorValue and armorValue > 0 then
		self.text:SetText( healthValue.." (+"..armorValue..")/"..healthMax )
	
		armorValue = healthValue + armorValue
		ratio = armorValue / healthMax;
		fillAmount = startInset + ratio * ((1 - endInset) - startInset);
		self.armor:SetWidth(max(self:GetWidth() * fillAmount, 1));
		self.armor:SetTexCoord(0, fillAmount, 0.75, 1);
		self.armor:Show()
	else
		self.armor:Hide()
	end
	
	if healthValue < healthMax and healthValue > 0 then
		self.spark:Show()
	else
		self.spark:Hide()
	end
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
			DiceMasterChargesFrame.healthbar:SetPoint("CENTER", 0, 20)
		else
			DiceMasterChargesFrame.bar:Hide()
			DiceMasterChargesFrame.bar2:Hide()
			DiceMasterChargesFrame.healthbar:SetPoint("CENTER", 0, 0)
		end
	else
		DiceMasterChargesFrame:Hide()
	end
	
	if tooltip then
		local chargesPlural = Profile.charges.name:gsub( "/.*", "" )
		Me.SetupTooltip( DiceMasterChargesFrame.bar, nil, chargesPlural, 
			nil, nil, nil, 
			Profile.charges.tooltip.."|n|cFF707070<Left Click to Add "..chargesPlural..">|n"
			.."<Right Click to Remove "..chargesPlural..">")
		Me.SetupTooltip( DiceMasterChargesFrame.bar2, nil, chargesPlural, 
			nil, nil, nil, 
			Profile.charges.tooltip.."|n|cFF707070<Left Click to Add "..chargesPlural..">|n"
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

function Me.BarOnDragStart( self )
	if Me.db.global.snapping then
		local offset = 0
		Sticky:StartMoving(self, Me.snapBars, offset, offset, offset, offset)
	else
		self:StartMoving()
	end
	self.isMoving = true
end

function Me.BarOnDragStop( self )
	if self.isMoving then
		if Me.db.global.snapping then
			local sticky, stickTo = Sticky:StopMoving(self)
		else
			self:StopMovingOrSizing()
		end
		self.isMoving = nil
	end
end

function Me.UnlockFrames()
	DiceMasterUnlockDialog:Show()
	if Me.db.global.hideTypeTracker then
		if DiceMasterPostTrackerFrame.Message:GetText() ~= nil then
			DiceMasterPostTrackerFrame.Message:SetText("No one is typing.")
		end
		DiceMasterPostTrackerFrame.Message:Show()
		DiceMasterPostTrackerFrame.Background:Show()
		DiceMasterPostTrackerFrameDragFrame:Show()
	end
	if IsAddOnLoaded("DiceMaster_UnitFrames") and not Me.db.char.unitframes.enable then
		DiceMasterUnitsPanelDragFrame:Show()
	end
	DiceMasterPanelDragFrame:Show()
	DiceMasterInspectFrame:Show()
	DiceMasterInspectFrameDragFrame:Show()
	DiceMasterBuffFrameDragFrame:Show()
	DiceMasterInspectBuffFrameDragFrame:Show()
	DiceMasterChargesFrameDragFrame:Show()
	DiceMasterMoraleBarDragFrame:Show()
end

function Me.LockFrames()
	DiceMasterUnlockDialog:Hide()
	if DiceMaster4.db.global.hideTypeTracker then
		DiceMasterPostTrackerFrameDragFrame:Hide()
		if #DiceMaster4.WhoIsTyping == 0 then
			DiceMasterPostTrackerFrame.Message:Hide()
			DiceMasterPostTrackerFrame.Background:Hide()
		end
	end
	if IsAddOnLoaded("DiceMaster_UnitFrames") and not Me.db.char.unitframes.enable then
		DiceMasterUnitsPanelDragFrame:Hide()
	end
	DiceMasterPanelDragFrame:Hide()
	DiceMasterInspectFrameDragFrame:Hide()
	DiceMaster4.Inspect_Open( UnitName("target") )
	DiceMasterBuffFrameDragFrame:Hide()
	DiceMasterInspectBuffFrameDragFrame:Hide()
	DiceMasterChargesFrameDragFrame:Hide()
	DiceMasterMoraleBarDragFrame:Hide()
end

function Me.ApplyUiScale()
	DiceMasterPanel:SetScale( Me.db.char.uiScale * 1.4 )
	DiceMasterTraitEditor:SetScale( Me.db.char.uiScale * 1.4 )
	DiceMasterInspectFrame:SetScale( Me.db.char.uiScale * 1.2 )
	DiceMasterBuffEditor:SetScale( Me.db.char.uiScale * 1.4 )
	DiceMasterRemoveBuffEditor:SetScale( Me.db.char.uiScale * 1.4 )
	DiceMasterChargesFrame:SetScale( Me.db.char.uiScale * 1.2 )
	DiceMasterRollFrame:SetScale( Me.db.char.trackerScale * 1.4 )
	DiceMasterMoraleBar:SetScale( Me.db.profile.morale.scale * 1.2 )
	
	if IsAddOnLoaded("DiceMaster_UnitFrames") then
		Me.ApplyUiScaleUF()
		Me.ShowUnitPanel( not Me.db.char.unitframes.enable )
	end
end

function Me.ShowPanel( show )
	Me.db.char.hidepanel = not show
	
	if not show then
		DiceMasterPanel:Hide()
		DiceMasterChargesFrame:Hide()
		DiceMasterRollFrame:Hide()
		DiceMasterMoraleBar:Hide()
		if IsAddOnLoaded("DiceMaster_UnitFrames") then
			DiceMasterUnitsPanel:Hide()
		end
	else
		DiceMasterPanel:Show()
		DiceMasterChargesFrame:Show()
		if Me.db.global.hideTracker then
			DiceMasterRollFrame:Show()
		end
		if Profile.morale.enable then
			DiceMasterMoraleBar:Show()
		end
		if IsAddOnLoaded("DiceMaster_UnitFrames") and not Me.db.char.unitframes.enable then
			DiceMasterUnitsPanel:Show()
		end
	end
	
	Me.RefreshChargesFrame( true, true )
	Me.Inspect_Open( UnitName( "target" ))
end

-------------------------------------------------------------------------------
-- Call when you change the charges settings.
--
function Me.OnChargesChanged()
	Me.RefreshChargesFrame( true, true )
	Me.BumpSerial( Me.db.char, "statusSerial" )
	Me.Inspect_ShareStatusWithParty()
	Me.Inspect_Open( UnitName( "target" ))
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
	Me.RefreshHealthbarFrame( DiceMasterChargesFrame.healthbar, Profile.health, Profile.healthMax, Profile.armor )
	Me.RefreshMoraleFrame( Me.db.profile.morale.count )
	
	Me.Inspect_ShareStatusWithParty()
	
	Me.SetupWorldClickDetection()
end

