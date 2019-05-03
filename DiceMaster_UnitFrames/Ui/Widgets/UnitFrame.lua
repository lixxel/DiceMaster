-------------------------------------------------------------------------------
-- Dice Master (C) 2019 <The League of Lordaeron> - Moon Guard
-------------------------------------------------------------------------------

local Me = DiceMaster4
Me.UnitFrameTargeted = nil;

local EASTERN_KINGDOM_ZONES = {
	"Arathi Highlands",
	"Badlands",
	"Blasted Lands",
	"Burning Steppes",
	"Deadwind Pass",
	"Dun Morogh",
	"Duskwood",
	"Eastern Plaguelands",
	"Elwynn Forest",
	"Eversong Woods",
	"Ghostlands",
	"Gilneas", -- Ruins of Gilneas, Gilneas City, etc.
	"Hillsbrad Foothills",
	"Isle of Quel'Danas",
	"Vashj'ir",
	"Loch Modan",
	"Stranglethorn", -- Cape of Stranglethorn, Northern Stranglethorn, etc.
	"Redridge Mountains",
	"Searing Gorge",
	"Silverpine Forest",
	"Swamp of Sorrows",
	"Hinterlands",
	"Tirisfal Glades",
	"Tol Barad", -- Tol Barad, Tol Barad Peninsula, etc.
	"Twilight Highlands",
	"Western Plaguelands",
	"Westfall",
	"Wetlands",
}

local KALIMDOR_ZONES = {
	"Ahn'Qiraj",
	"Ashenvale",
	"Azshara",
	"Azuremyst Isle",
	"Bloodmyst Isle",
	"Darkshore",
	"Desolace",
	"Durotar",
	"Dustwallow Marsh",
	"Echo Isles",
	"Felwood",
	"Feralas",
	"Moonglade",
	"Mount Hyjal",
	"Mulgore",
	"Barrens", -- Northern Barrens, Southern Barrens, etc.
	"Silithus",
	"Stonetalon Mountains",
	"Tanaris",
	"Teldrassil",
	"Thousand Needles",
	"Uldum",
	"Un'goro Crater",
	"Winterspring",
}

local OTHER_ZONES = {
	-- Outland
	"Blade's Edge Mountains",
	"Hellfire Peninsula",
	"Nagrand",
	"Netherstorm",
	"Shadowmoon Valley",
	"Terokkar Forest",
	"Zangarmarsh",
	--Northrend
	"Borean Tundra",
	"Crystalsong Forest",
	"Dragonblight",
	"Grizzly Hills",
	"Howling Fjord",
	"Icecrown",
	"Sholazar Basin",
	"Storm Peaks",
	"Zul'Drak",
	--Pandaria
	"Dread Wastes",
	"Krasarang Wilds",
	"Kun-Lai Summit",
	"Jade Forest",
	"Townlong Steppes",
	"Vale of Eternal Blossoms",
	"Valley of the Four Winds",
}

local OTHER_ZONES_2 = {
	-- Broken Isles
	"Azsuna",
	"Broken Shore",
	"Dalaran",
	"Highmountain",
	"Stormheim",
	"Suramar",
	"Val'sharah",
	"Argus",
	-- BFA
	"Drustvar",
	"Nazmir",
	"Stormsong Valley",
	"Tiragarde Sound",
	"Vol'dun",
	"Zuldazar",
	"Boralus",
	"Dazar'alor",
	"Northgarde",
}

local HEALTH_EFFECTS = {
	["healthbuff"] = { soundKit = 32877, anim = 54, altAnim = 32 },
	["healthdebuff"] = { soundKit = 32878, anim = 8, altAnim = 9 },
	["defensebuff"] = { soundKit = 32882, anim = 54, altAnim = 32 },
	["defensedebuff"] = { soundKit = 32881, anim = 20, altAnim = 30 },
}

local WORLD_MARKER_NAMES = {
	"|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_1:14:14|t |cffffff00Yellow|r World Marker"; -- [1]
	"|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_2:14:14|t |cffff7f3fOrange|r World Marker"; -- [2]
	"|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_3:14:14|t |cffa335eePurple|r World Marker"; -- [3]
	"|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_4:14:14|t |cff1eff00Green|r World Marker"; -- [4]
	"|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_5:14:14|t |cffaaaaddSilver|r World Marker"; -- [5]
	"|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_6:14:14|t |cff0070ddBlue|r World Marker"; -- [6]
	"|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_7:14:14|t |cffff2020Red|r World Marker"; -- [7]
	"|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_8:14:14|t |cffffffffWhite|r World Marker"; -- [8]
}

local function getContinent( continentString, zone )
	if continentString == "Eastern Kingdoms" then
		return EASTERN_KINGDOM_ZONES, "DiceMaster_UnitFrames/Texture/eastern-kingdom-zones"
	elseif continentString == "Kalimdor" then
		return KALIMDOR_ZONES, "DiceMaster_UnitFrames/Texture/kalimdor-zones"
	elseif continentString == "Outland" or continentString == "Northrend" or continentString == "Pandaria" or continentString == "Draenor" then
		return OTHER_ZONES, "DiceMaster_UnitFrames/Texture/other-zones"
	elseif continentString == "Broken Isles" or continentString == "Argus" or continentString == "Kul Tiras" or continentString == "Zandalar" then
		return OTHER_ZONES_2, "DiceMaster_UnitFrames/Texture/other-zones-2"
	elseif continentString and zone~="Unknown" and Me.DICEMASTER_CUSTOM_UNIT_TEXTURES then
		-- For custom backdrops.
		return Me.DICEMASTER_BACKDROP_ZONES[continentString], Me.DICEMASTER_CUSTOM_UNIT_TEXTURES[continentString]
	end
	return OTHER_ZONES_2, "DiceMaster_UnitFrames/Texture/other-zones-2"
end

local methods = {
	---------------------------------------------------------------------------
	-- Reset the unit frame data.
	--
	Reset = function( self )
		self:SetDisplayInfo(1)
		self.name:SetText("Unit Name")
		self.symbol.State = 9;
		self.symbol:SetNormalTexture(nil)
		self.healthCurrent = 3
		self.healthMax = 3
		self.armor = 0
		Me.RefreshHealthbarFrame( self.health, self.healthCurrent, self.healthMax, self.armor )
		self.buffsAllowed = true
		self.buffsActive = {}
		self.buffFrame:Hide()
		self.animation = 0
		self.rotation = 0
		self.zoomLevel = 0.7
		self.cameraX = 0
		self.cameraY = 0
		self.cameraZ = 0
		self.scrollposition = nil
		if Me.IsLeader( false ) then
			DiceMaster4.SetupTooltip( self, nil, "Unit Frame", nil, nil, nil, "Represents a custom unit.|n|cFF707070<Left Click to Edit>|n<Shift+Left/Right Click to Add/Remove>" )
			DiceMaster4.SetupTooltip( self.symbol, nil, "World Marker Icon", nil, nil, nil, "A unique icon to represent the location of this unit in the game world.|n|cFF707070<Left/Right Click to Toggle>" )
			 DiceMaster4.SetupTooltip( self.health, nil, "Health", nil, nil, nil, "Represents this unit's health.|n|cFF707070<Left/Right Click to Add/Remove>|n<Shift+Left Click to Set Max>|n<Ctrl+Left Click to Set Value>" )
		else
			DiceMaster4.SetupTooltip( self )
			DiceMaster4.SetupTooltip( self.symbol )
			DiceMaster4.SetupTooltip( self.health, nil, "Health", nil, nil, nil, "Represents this unit's health." )
		end
		self.state = false
		self.zone = "Unknown"
		self.continent = "Unknown"
		self.visibleIcon:Hide()
		self.highlight:Hide()
		self.SetBackground( self )
	end;
	---------------------------------------------------------------------------
	-- Get unit frame data.
	--
	GetData = function( self )
		local framedata = {}
		framedata.name = self.name:GetText() or ""
		framedata.model = self:GetDisplayInfo()
		framedata.symbol = self.symbol.State or 9;
		framedata.healthCurrent = self.healthCurrent or 3
		framedata.healthMax = self.healthMax or 3
		framedata.armor = self.armor or 0
		framedata.visible = self:IsVisible()
		framedata.buffsAllowed = self.buffsAllowed
		framedata.buffs = self.buffsActive or {}
		framedata.animation = self.animation or 0;
		framedata.modelData = {}
		framedata.modelData.px = self.cameraX
		framedata.modelData.py = self.cameraY
		framedata.modelData.pz = self.cameraZ
		framedata.modelData.ro = self.rotation
		framedata.modelData.zl = self.zoomLevel
		framedata.state = self.state
		framedata.zone = self.zone
		framedata.continent = self.continent
		return framedata;
	end;
	---------------------------------------------------------------------------
	-- Set unit frame data.
	--
	SetData = function( self, framedata )
		local modelChanged = false;
		
		-- Check if it's a new model or not
		if framedata.md and self:GetDisplayInfo() ~= framedata.md then		
			self:SetDisplayInfo(framedata.md)
			modelChanged = true;
		elseif not framedata.md then
			self:SetDisplayInfo(1)
		end
		
		-- Set the rotation, zoomLevel, position
		if framedata.mx and not self.collapsed then
			self.rotation = framedata.mx.ro
			self.zoomLevel = framedata.mx.zl
			self.cameraX = framedata.mx.px
			self.cameraY = framedata.mx.py
			self.cameraZ = framedata.mx.pz
			
			self:SetRotation( self.rotation )
			self:SetPortraitZoom( self.zoomLevel )
			self:SetPosition( self.cameraX, self.cameraY, self.cameraZ )
		end
		
		-- Check if model and name have changed
		if self:GetDisplayInfo() == framedata.md and self.name:GetText() == framedata.na then
			if framedata.hc < self.healthCurrent then
				self:SetEffect( "healthdebuff" )
			elseif framedata.hc > self.healthCurrent then
				self:SetEffect( "healthbuff" )
			elseif framedata.ar < self.armor then
				self:SetEffect( "defensedebuff" )
			elseif framedata.ar > self.armor then
				self:SetEffect( "defensebuff" )
			end
		end
		
		-- Handle DM functions
		if not Me.IsLeader( false ) then
			DiceMaster4.SetupTooltip( self, nil, framedata.na, nil, nil, nil, "|cFF707070<Left Click to Target>|r" )
			if framedata.sy ~= 9 then
				DiceMaster4.SetupTooltip( self.symbol, nil, "World Marker Icon", nil, nil, nil, "This unit is currently located at the "..WORLD_MARKER_NAMES[framedata.sy] .. "|r." )
			else
				DiceMaster4.SetupTooltip( self.symbol, nil )
			end
		end
		if framedata.st and Me.IsLeader( false ) then
			self.state = true
			self.visibleIcon:Show()
		else
			self.state = false
			self.visibleIcon:Hide()
		end
		
		-- Set name, World Marker symbol
		self.name:SetText(framedata.na)
		self.symbol.State = framedata.sy
		self.symbol:SetNormalTexture("Interface/TARGETINGFRAME/UI-RaidTargetingIcon_" .. self.symbol.State )
		if self.symbol.State == 9 then self.symbol:SetNormalTexture(nil) end
		
		-- Handle death animation.
		if framedata.an == 6 and framedata.hc == 0 then
			-- unit is already "dead"
			self.dead = true;
			self:SetAnimation(6)
		elseif framedata.hc == 0 then
			-- unit is "dying"
			self.dead = true;
			self:SetAnimation(1)
		elseif modelChanged or self.animation ~= framedata.an or self.dead then
			-- unit is "alive"
			self.dead = false;
			self.animation = framedata.an or 0
			self:SetAnimation(self.animation)
		end
		
		-- Set visibility
		if framedata.vs then self:Show() else self:Hide() end
		
		-- Allow buffs?
		if framedata.ba then self.buffsAllowed = framedata.ba end
		
		-- Set health, healthMax, armour
		self.healthCurrent = framedata.hc
		self.healthMax = framedata.hm
		self.armor = framedata.ar or 0
		Me.RefreshHealthbarFrame( self.health, self.healthCurrent, self.healthMax, self.armor )
		
		-- Set unit frame backdrop
		if framedata.zo then
			self.zone = framedata.zo
			self.continent = framedata.co
		end
		self:SetBackground( self )
		
		-- Handle buffs
		if framedata.buffs then
			self.buffsActive = framedata.buffs
			for i = 1, #self.buffs do
				Me.UnitFrames_UpdateBuffButton( self, i)
			end
			if #self.buffsActive > 0 then
				self.buffFrame:Show()
			else
				self.buffFrame:Hide()
			end
		end
		
		-- Handle highlight if frame is selected
		if self.highlight:IsShown() then
			local target = self.symbol.State
			if target == 9 then target = 0 end
			if target > 0 then
				UIDropDownMenu_SetText(DiceMasterRollTracker.selectTarget, "|TInterface/TARGETINGFRAME/UI-RaidTargetingIcon_"..target..":16|t")
			else
				UIDropDownMenu_SetText(DiceMasterRollTracker.selectTarget, "") 
			end
			local msg = Me:Serialize( "TARGET", {
				ta = tonumber( target );
			})
			Me:SendCommMessage( "DCM4", msg, "RAID", nil, "ALERT" )
		end
	end;
	---------------------------------------------------------------------------
	-- Set unit frame tooltip.
	--
	
	SetCustomTooltip = function( self, text )
		self.customTooltip = text
	end;
	---------------------------------------------------------------------------
	-- Collapse/expand unit frame.
	--
	
	Collapse = function( self, collapse )
		if collapse then
			self.collapsed = true;
			self.border:SetTexture("Interface/AddOns/DiceMaster_UnitFrames/Texture/unitframe-small")
			self.highlight:SetTexture("Interface/AddOns/DiceMaster_UnitFrames/Texture/unitframe-small-highlight")
			self.bg:SetHeight(80)
			self:SetHeight(80)
			self.symbol:SetPoint("CENTER", 0, 60)
			self.name:SetPoint("BOTTOM", 0, -13)
			self.health:SetPoint("BOTTOM", 0, -36)
			self.expand.Arrow:SetTexCoord(0.767, 1, 0.25, 0.327)
			DiceMaster4.SetupTooltip( self.expand, nil, "Expand", nil, nil, nil, "Expand the frame to a larger size.|n|cFF707070<Left Click to Expand>" )
		else
			self.collapsed = false;
			self.border:SetTexture("Interface/AddOns/DiceMaster_UnitFrames/Texture/unitframe")
			self.highlight:SetTexture("Interface/AddOns/DiceMaster_UnitFrames/Texture/unitframe-highlight")
			self.bg:SetHeight(200)
			self:SetHeight(182)
			self.symbol:SetPoint("CENTER", 0, 110)
			self.name:SetPoint("BOTTOM", 0, -15)
			self.health:SetPoint("BOTTOM", 0, -38)
			self.expand.Arrow:SetTexCoord(0.767, 1, 0.327, 0.402)
			DiceMaster4.SetupTooltip( self.expand, nil, "Collapse", nil, nil, nil, "Collapse the frame to a smaller size.|n|cFF707070<Left Click to Collapse>" )
		end
		self:SetBackground( self )
	end;
	---------------------------------------------------------------------------
	-- Set unit frame backdrop.
	--
	
	SetBackground = function( self )
		local zone = self.zone or "Unknown"
		local continent, texture = getContinent( self.continent, zone );
		local zoneID = false;
		for i=1,#continent do
			if zone:find(continent[i]) then
				zoneID = i - 1
				break
			end
		end
		
		if not zoneID then
			zoneID = 17;
			texture = "DiceMaster_UnitFrames/Texture/other-zones-2"
		end
		
		-- proxy image for Northgarde
		if zone == "Dustwallow Marsh" and Me.PermittedUse() then
			zoneID = 16;
			texture = "DiceMaster_UnitFrames/Texture/other-zones-2"
		end

		local columns = 6
		local l = mod(zoneID, columns) * 0.14844
		local r = l + 0.14844
		local t = floor(zoneID/columns) * 0.19531
		local b = t + 0.19531
		
		if self.collapsed then
			t = floor(zoneID/columns) * 0.2344
			b = t + 0.0781
		end
		self.bg:SetTexture("Interface/AddOns/"..texture)
		self.bg:SetTexCoord(l, r, t, b)
	end;
	---------------------------------------------------------------------------
	-- Set unit frame data.
	--
	
	SetEffect = function( self, effect )
		if self.buffEffect.IsPlaying then return end
		
		self.buffEffect.IsPlaying = true;
		self.buffEffect:SetModel("spells\\pb_"..effect.."_impact");
		if self:HasAnimation( HEALTH_EFFECTS[ effect ].anim ) then
			self:SetAnimation( HEALTH_EFFECTS[ effect ].anim )
		else
			self:SetAnimation( HEALTH_EFFECTS[ effect ].altAnim )
		end
		self.buffEffect:Show()
		PlaySound( HEALTH_EFFECTS[ effect ].soundKit )
	end;
}

-------------------------------------------------------------------------------
-- StaticPopupDialogs
--

StaticPopupDialogs["DICEMASTER4_SETUNITHEALTHVALUE"] = {
  text = "Set Health value:",
  button1 = "Accept",
  button2 = "Cancel",
  OnShow = function (self, data)
    self.editBox:SetText(data.healthCurrent)
	self.editBox:HighlightText()
  end,
  OnAccept = function (self, data)
    local text = tonumber(self.editBox:GetText()) or data.healthCurrent
	if Me.OutOfRange( text, 0, data.healthMax ) then
		return
	end
	data.healthCurrent = text
	Me.RefreshHealthbarFrame( data.health, data.healthCurrent, data.healthMax, data.armor )
	Me.UpdateUnitFrames()
  end,
  hasEditBox = true,
  timeout = 0,
  whileDead = true,
  hideOnEscape = true,
  preferredIndex = 3,
}

StaticPopupDialogs["DICEMASTER4_SETUNITHEALTHMAX"] = {
  text = "Set maximum Health value:",
  button1 = "Accept",
  button2 = "Cancel",
  OnShow = function (self, data)
    self.editBox:SetText(data.healthMax)
	self.editBox:HighlightText()
  end,
  OnAccept = function (self, data)
    local text = tonumber(self.editBox:GetText()) or data.healthMax
	if Me.OutOfRange( text, 1, 1000 ) then
		return
	end
	data.healthMax = text
	if data.healthCurrent > text then
		data.healthCurrent = text
	end
	Me.RefreshHealthbarFrame( data.health, data.healthCurrent, data.healthMax, data.armor )
	Me.UpdateUnitFrames()
  end,
  hasEditBox = true,
  timeout = 0,
  whileDead = true,
  hideOnEscape = true,
  preferredIndex = 3,
}

-------------------------------------------------------------------------------
-- When the healthbar frame is clicked.
--
function Me.OnUnitBarHealthClicked( self, button )
	if Me.IsLeader( false ) then
		local unit = self:GetParent()

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
			StaticPopup_Show("DICEMASTER4_SETUNITHEALTHMAX", nil, nil, self:GetParent())
		elseif IsControlKeyDown() and button == "LeftButton" then
			-- Open dialog for custom value.
			StaticPopup_Show("DICEMASTER4_SETUNITHEALTHVALUE", nil, nil, self:GetParent())
		elseif IsAltKeyDown() then
			if Me.OutOfRange( unit.armor+delta, 0, 1000 ) then
				return
			end
			if delta == -1 then
				unit:SetEffect( "defensedebuff" )
			elseif delta == 1 then
				unit:SetEffect( "defensebuff" )
			end
			unit.armor = unit.armor + delta;
		else
			if Me.OutOfRange( unit.healthCurrent+delta, 0, unit.healthMax ) then
				return
			end
			if delta == -1 then
				unit:SetEffect( "healthdebuff" )
			elseif delta == 1 then
				unit:SetEffect( "healthbuff" )
			end
			unit.healthCurrent = Me.Clamp( unit.healthCurrent + delta, 0, unit.healthMax )
		end
		
		Me.RefreshHealthbarFrame( self, unit.healthCurrent, unit.healthMax, unit.armor )
		
		if unit.healthCurrent == 0 then
			unit.dead = true;
			unit:SetAnimation(1)
		elseif unit.dead then
			unit.dead = false;
			unit:SetAnimation(unit.animation)
		end
		
		Me.UpdateUnitFrames()
	end
end

-------------------------------------------------------------------------------
-- Initialize a new unit frame.
--
function Me.UnitFrame_Init( self )

	for k, v in pairs( methods ) do
		self[k] = v
	end
	 
	self:SetScript( "OnEnter", OnEnter )
	self:SetScript( "OnLeave", OnLeave )
end
-------------------------------------------------------------------------------
-- Add another unit frame to the panel.
--
function Me.CreateUnitFrame()
	if Me.IsLeader( false ) then
		local unitframes = DiceMasterUnitsPanel.unitframes
		local visibleframes = DiceMaster4UF_Saved.VisibleFrames
		
		for i=1,#unitframes do
			if not unitframes[i]:IsVisible() then
				unitframes[i]:Show()
				unitframes[i].visible = true;
				DiceMaster4UF_Saved.VisibleFrames = DiceMaster4UF_Saved.VisibleFrames + 1
				break;
			end
		end
		
		Me.UpdateUnitFrames()
		Me.AffixEditor_RefreshSlots()
	end
end
-------------------------------------------------------------------------------
-- Remove a unit frame from the panel.
--
function Me.DeleteUnitFrame( frame )
	if Me.IsLeader( false ) then
		if DiceMaster4UF_Saved.VisibleFrames == 1 then return end;
		local unitframes = DiceMasterUnitsPanel.unitframes
		
		frame:Hide()
		for i=1,#unitframes do
			if unitframes[i]==frame then
				unitframes[i]:Reset()
				tremove( unitframes, i )
				tinsert( unitframes, frame)
				unitframes[i].visible = false;
			end
		end
		DiceMaster4UF_Saved.VisibleFrames = DiceMaster4UF_Saved.VisibleFrames - 1
		
		if Me.UnitEditing == frame and DiceMasterAffixEditor:IsShown() then
			Me.AffixEditor_Close()
		end
		
		Me.UpdateUnitFrames()
		Me.AffixEditor_RefreshSlots()
	end
end

-------------------------------------------------------------------------------
-- Select a unit frame as the target (for buffs, etc).
--
function Me.SelectUnitFrame( frame )
	local unitframes = DiceMasterUnitsPanel.unitframes
	local target = 0;
	Me.UnitFrameTargeted = nil;
	
	if frame.highlight:IsShown() then
		frame.highlight:Hide()
		PlaySound(684)
	else
		frame.highlight:Show()
		PlaySound(101)
		if frame.symbol.State < 9 then
			target = frame.symbol.State;
		end
	end
	
	for i=1,#unitframes do
		if unitframes[i] ~= frame then
			unitframes[i].highlight:Hide()
		elseif frame.highlight:IsShown() then
			Me.UnitFrameTargeted = i;
		end
	end
	
	if target > 0 then
		UIDropDownMenu_SetText(DiceMasterRollTracker.selectTarget, "|TInterface/TARGETINGFRAME/UI-RaidTargetingIcon_"..target..":16|t")
	else
		UIDropDownMenu_SetText(DiceMasterRollTracker.selectTarget, "") 
	end
	local msg = Me:Serialize( "TARGET", {
		ta = tonumber( target );
	})
	Me:SendCommMessage( "DCM4", msg, "RAID", nil, "ALERT" )
end

-------------------------------------------------------------------------------
-- Update visibility/position of unit frames in use.
--
function Me.UpdateUnitFrames( number )
	local unitframes = DiceMasterUnitsPanel.unitframes
	if not DiceMaster4UF_Saved.VisibleFrames then DiceMaster4UF_Saved.VisibleFrames = 1 end
	if number then 
		DiceMaster4UF_Saved.VisibleFrames = number
	end
	if number == 0 then
		for i=1,#unitframes do
			unitframes[i]:Hide()
		end
		if DiceMasterAffixEditor:IsShown() then
			Me.AffixEditor_Close()
		end
	end
	local visibleframes = DiceMaster4UF_Saved.VisibleFrames
	local shareableframes = {}
	
	for i=1,visibleframes do
		
		-- Calculate how many frames are shareable with the group.
		if Me.IsLeader( false ) then
			local status = DiceMasterUnitsPanel.unitframes[i]:GetData()
			if status.state then
				tinsert(shareableframes, status)
			end
		end
			
		unitframes[i]:Show()
		unitframes[i]:SetPoint( "CENTER", (visibleframes*85-85)-170*(i-1), 0 )
	end
	
	if Me.IsLeader( false ) and not number then
		for i=1,#shareableframes do
			-- Share frame changes with the rest of the group.
			if Me.IsLeader( false ) then
				local status = shareableframes[i]
				Me.UnitFrame_SendStatus( #shareableframes, i, status )
			end
		end
		
		if #shareableframes == 0 then
			-- If all our frames are in the "hidden" state, share 0.
			Me.UnitFrame_SendStatus( 0, 1 )
		end
	end
end
