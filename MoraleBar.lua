-------------------------------------------------------------------------------
-- Dice Master (C) 2017 <The League of Lordaeron> - Moon Guard
-------------------------------------------------------------------------------

--
-- Morale bar interface.
--

local Me = DiceMaster4
local Profile = Me.Profile

local altPowerBars = {
	["Air"] = {
		path = "Interface/UNITPOWERBARALT/Air_Horizontal_";
		frame = true;
		background = false;
		fill = false;
		spark = false;
		flash = false;
		inset = 0.14;
	},
	["Alliance"] = {
		path = "Interface/UNITPOWERBARALT/Alliance_Horizontal_";
		frame = true;
		background = false;
		fill = false;
		spark = false;
		flash = false;
		inset = 0.14;
	},
	["Amber"] = {
		path = "Interface/UNITPOWERBARALT/Amber_Horizontal_";
		frame = true;
		background = true;
		fill = true;
		spark = false;
		flash = true;
		inset = 0.14;
	},
	["Arsenal"] = {
		path = "Interface/UNITPOWERBARALT/Arsenal_Horizontal_";
		frame = false;
		background = true;
		fill = true;
		spark = false;
		flash = true;
		inset = 0.135;
	},
	["Azerite"] = {
		path = "Interface/UNITPOWERBARALT/Azerite_Horizontal_";
		frame = false;
		background = true;
		fill = true;
		spark = true;
		flash = true;
		inset = 0.14;
	},
	["Bamboo"] = {
		path = "Interface/UNITPOWERBARALT/Bamboo_Horizontal_";
		frame = true;
		background = false;
		fill = false;
		spark = false;
		flash = false;
		inset = 0.12;
	},
	["BrewingStorm"] = {
		path = "Interface/UNITPOWERBARALT/BrewingStorm_Horizontal_";
		frame = true;
		background = true;
		fill = true;
		spark = true;
		flash = true;
		inset = 0.135;
	},
	["BulletBar"] = {
		path = "Interface/UNITPOWERBARALT/BulletBar_Horizontal_";
		frame = true;
		background = true;
		fill = true;
		spark = false;
		flash = true;
		inset = 0.14;
	},
	["Chogall"] = {
		path = "Interface/UNITPOWERBARALT/Chogall_Horizontal_";
		frame = true;
		background = true;
		fill = true;
		spark = true;
		flash = true;
		inset = 0.23;
	},
	["Darkmoon"] = {
		path = "Interface/UNITPOWERBARALT/Darkmoon_Horizontal_";
		frame = true;
		background = true;
		fill = true;
		spark = true;
		flash = true;
		inset = 0.21;
	},
	["DeathwingBlood"] = {
		path = "Interface/UNITPOWERBARALT/DeathwingBlood_Horizontal_";
		frame = false;
		background = true;
		fill = true;
		spark = true;
		flash = true;
		inset = 0.14;
	},
	["Druid"] = {
		path = "Interface/UNITPOWERBARALT/Druid_Horizontal_";
		frame = true;
		background = false;
		fill = true;
		spark = false;
		flash = false;
		inset = 0.14;
	},
	["FancyPanda"] = {
		path = "Interface/UNITPOWERBARALT/FancyPanda_Horizontal_";
		frame = true;
		background = false;
		fill = false;
		spark = false;
		flash = false;
		inset = 0.135;
	},
	["FelCorruption"] = {
		path = "Interface/UNITPOWERBARALT/FelCorruption_Horizontal_";
		frame = false;
		background = true;
		fill = true;
		spark = true;
		flash = true;
		inset = 0.14;
	},
	["Fire"] = {
		path = "Interface/UNITPOWERBARALT/Fire_Horizontal_";
		frame = true;
		background = false;
		fill = false;
		spark = false;
		flash = false;
		inset = 0.14;
	},
	["FuelGauge"] = {
		path = "Interface/UNITPOWERBARALT/FuelGauge_Horizontal_";
		frame = true;
		background = true;
		fill = true;
		spark = true;
		flash = true;
		inset = 0.135;
	},
	["GarroshEnergy"] = {
		path = "Interface/UNITPOWERBARALT/GarroshEnergy_Horizontal_";
		frame = false;
		background = true;
		fill = true;
		spark = true;
		flash = true;
		inset = 0.2;
	},
	["Generic1Player"] = {
		path = "Interface/UNITPOWERBARALT/Generic1Player_Horizontal_";
		frame = true;
		background = true;
		fill = true;
		spark = true;
		flash = true;
		inset = 0.135;
	},
	["Horde"] = {
		path = "Interface/UNITPOWERBARALT/Horde_Horizontal_";
		frame = true;
		background = false;
		fill = false;
		spark = false;
		flash = false;
		inset = 0.14;
	},
	["Ice"] = {
		path = "Interface/UNITPOWERBARALT/Ice_Horizontal_";
		frame = true;
		background = false;
		fill = false;
		spark = false;
		flash = false;
		inset = 0.14;
	},
	["InquisitionTorment"] = {
		path = "Interface/UNITPOWERBARALT/InquisitionTorment_Horizontal_";
		frame = true;
		background = true;
		fill = true;
		spark = true;
		flash = true;
		inset = 0.18;
	},
	["Jaina"] = {
		path = "Interface/UNITPOWERBARALT/Jaina_Horizontal_";
		frame = false;
		background = true;
		fill = true;
		spark = true;
		flash = true;
		inset = 0.14;
	},
	["Map"] = {
		path = "Interface/UNITPOWERBARALT/Map_Horizontal_";
		frame = true;
		background = true;
		fill = true;
		spark = false;
		flash = true;
		inset = 0.1;
		insetRight = 0.125;
	},
	["Meat"] = {
		path = "Interface/UNITPOWERBARALT/Meat_Horizontal_";
		frame = true;
		background = false;
		fill = false;
		spark = false;
		flash = true;
		inset = 0.14;
	},
	["Mechanical"] = {
		path = "Interface/UNITPOWERBARALT/Mechanical_Horizontal_";
		frame = true;
		background = false;
		fill = false;
		spark = false;
		flash = false;
		inset = 0.14;
	},
	["Meditation"] = {
		path = "Interface/UNITPOWERBARALT/Meditation_Horizontal_";
		frame = true;
		background = false;
		fill = false;
		spark = true;
		flash = false;
		inset = 0.14;
	},
	["MoltenRock"] = {
		path = "Interface/UNITPOWERBARALT/MoltenRock_Horizontal_";
		frame = true;
		background = false;
		fill = false;
		spark = false;
		flash = false;
		inset = 0.14;
	},
	["morale-bar"] = {
		path = "Interface/AddOns/DiceMaster/Texture/morale_";
		frame = false;
		background = false;
		fill = true;
		spark = true;
		flash = false;
		inset = 0.14;
	},
	["Murozond"] = {
		path = "Interface/UNITPOWERBARALT/Murozond_Horizontal_";
		frame = false;
		background = true;
		fill = true;
		spark = false;
		flash = false;
		inset = 0.05;
	},
	["NaaruCharge"] = {
		path = "Interface/UNITPOWERBARALT/NaaruCharge_Horizontal_";
		frame = false;
		background = true;
		fill = true;
		spark = true;
		flash = true;
		inset = 0.15;
	},
	["Onyxia"] = {
		path = "Interface/UNITPOWERBARALT/Onyxia_Horizontal_";
		frame = true;
		background = false;
		fill = true;
		spark = true;
		flash = true;
		inset = 0.135;
	},
	["Pride"] = {
		path = "Interface/UNITPOWERBARALT/Pride_Horizontal_";
		frame = true;
		background = true;
		fill = true;
		spark = true;
		flash = true;
		inset = 0.15;
	},
	["Rock"] = {
		path = "Interface/UNITPOWERBARALT/Rock_Horizontal_";
		frame = true;
		background = false;
		fill = false;
		spark = false;
		flash = false;
		inset = 0.14;
	},
	["ShadowPaladinBar"] = {
		path = "Interface/UNITPOWERBARALT/ShadowPaladinBar_Horizontal_";
		frame = false;
		background = true;
		fill = true;
		spark = false;
		flash = false;
		inset = 0.2;
	},
	["StoneDesign"] = {
		path = "Interface/UNITPOWERBARALT/StoneDesign_Horizontal_";
		frame = true;
		background = false;
		fill = false;
		spark = false;
		flash = false;
		inset = 0.14;
	},
	["UndeadMeat"] = {
		path = "Interface/UNITPOWERBARALT/UndeadMeat_Horizontal_";
		frame = true;
		background = false;
		fill = false;
		spark = false;
		flash = false;
		inset = 0.14;
	},
	["Water"] = {
		path = "Interface/UNITPOWERBARALT/Water_Horizontal_";
		frame = true;
		background = false;
		fill = false;
		spark = false;
		flash = false;
		inset = 0.14;
	},
	["WoodPlank"] = {
		path = "Interface/UNITPOWERBARALT/WoodPlank_Horizontal_";
		frame = true;
		background = false;
		fill = false;
		spark = false;
		flash = false;
		inset = 0.14;
	},
	["WoodWithMetal"] = {
		path = "Interface/UNITPOWERBARALT/WoodWithMetal_Horizontal_";
		frame = true;
		background = false;
		fill = false;
		spark = false;
		flash = false;
		inset = 0.14;
	},
	["WoWUI"] = {
		path = "Interface/UNITPOWERBARALT/WoWUI_Horizontal_";
		frame = true;
		background = false;
		fill = false;
		spark = false;
		flash = false;
		inset = 0.14;
	},
	["Xavius"] = {
		path = "Interface/UNITPOWERBARALT/Xavius_Horizontal_";
		frame = false;
		background = true;
		fill = true;
		spark = true;
		flash = true;
		inset = 0.2;
	},
}

local altPowerBarTextures = {
	frame = "Frame",
	background = "Bgnd",
	fill = "Fill",
	spark = "Spark",
	flash = "Flash",
}

function Me.MoraleBar_OnClick(self, button)

	if not Me.IsLeader( true ) then
		return
	end

	local delta = 0
	if button == "LeftButton" then
		delta = Profile.morale.step
	elseif button == "RightButton" then
		delta = -1 * ( Profile.morale.step )
	else
		return
	end

	if Me.OutOfRange( self.displayedValue + delta, 0, 100 ) then
		return
	end
	self.displayedValue = self.displayedValue + delta
	self.text:SetText(self.powerName.." "..self.displayedValue.."%")
	
	self:UpdateFill();
	Me.MoraleBar_ShareStatusWithParty()
end

function Me.MoraleBar_OnEnter(self)
	if not self.powerName then return end
	GameTooltip:SetOwner(self.fill, "ANCHOR_RIGHT")
	GameTooltip:SetText(self.powerName, 1, 1, 1);
	GameTooltip:AddLine(self.powerTooltip, nil, nil, nil, true);
	if Me.IsLeader( true ) then
		GameTooltip:AddLine("|cFF707070<Left/Right Click to Add/Remove "..self.powerName..">")
	end
	GameTooltip:Show();
	self.text:SetText(self.powerName.." "..self.displayedValue.."%")
	self.text:Show()
end

function Me.MoraleBar_OnLeave(self)
	GameTooltip:Hide();
	self.text:Hide()
end

-------------------------------------------------------------------------------
-- Update the UI for the morale bar frame.
--
function Me.RefreshMoraleFrame( reset )
	
	if not Me.db.char.hidepanel and Profile.morale.enable then
		DiceMasterMoraleBar:Show()
	else
		DiceMasterMoraleBar:Hide()
	end
	
	if Me.IsLeader( false ) then
		Me.MoraleBar_ApplyTextures(Profile.morale.symbol, Profile.morale.name, Profile.morale.tooltip, reset, Profile.morale.color)
		Me.MoraleBar_ShareStatusWithParty()
	end
end

function Me.MoraleBar_ApplyTextures(texturePath, powerName, powerTooltip, displayedValue, color)
	Me.MoraleBar_ClearTextures()
	
	DiceMasterMoraleBar.powerName = powerName;
	DiceMasterMoraleBar.powerTooltip = powerTooltip;
	if displayedValue then
		DiceMasterMoraleBar.displayedValue = displayedValue;
	end
	DiceMasterMoraleBar.startInset = altPowerBars[texturePath].inset or 0;
	DiceMasterMoraleBar.endInset = altPowerBars[texturePath].inset or 0;
	
	if altPowerBars[texturePath].insetRight then
		DiceMasterMoraleBar.endInset = altPowerBars[texturePath].insetRight
	end
	
	DiceMasterMoraleBar.background:SetTexture("Interface/UNITPOWERBARALT/Generic1Player_Horizontal_Bgnd")
	DiceMasterMoraleBar.fill:SetTexture("Interface/UNITPOWERBARALT/Generic1_Horizontal_Fill")
	DiceMasterMoraleBar.fill:SetVertexColor( 1, 1, 1 )
	
	for textureName, textureIndex in pairs(altPowerBarTextures) do
		local texture = DiceMasterMoraleBar[textureName];
		if altPowerBars[texturePath][textureName] then 
			texture:SetTexture(altPowerBars[texturePath].path .. textureIndex); 
		end
		if not altPowerBars[texturePath].fill and color then
			DiceMasterMoraleBar.fill:SetVertexColor( color[1], color[2], color[3] )
		end
	end
	
	if texturePath == "morale-bar" then
		DiceMasterMoraleBar.customframe:Show()
		DiceMasterMoraleBar.background:SetTexture(nil)
	else
		DiceMasterMoraleBar.customframe:Hide()
	end
	
	DiceMasterMoraleBar:UpdateFill();
end

function Me.MoraleBar_ClearTextures()
	DiceMasterMoraleBar.flashAnim:Stop()
	DiceMasterMoraleBar.flashOutAnim:Stop()
	
	for textureName, textureIndex in pairs(altPowerBarTextures) do
		local texture = DiceMasterMoraleBar[textureName];
		texture:SetTexture(nil);
		--texture:Hide();
	end
	DiceMasterMoraleBar:UpdateFill();
end

function Me.MoraleBar_SetMinMaxPower(minPower, maxPower)	
	DiceMasterMoraleBar.range = maxPower - minPower;
	DiceMasterMoraleBar.maxPower = maxPower;
	DiceMasterMoraleBar.minPower = minPower;
end

function Me.MoraleBar_SetUp(self)
	self.Title = "Progress Bar"
	self:SetClampedToScreen( true )
	self:SetMovable(true)
	self:EnableMouse(true)
	--self:RegisterForDrag( "LeftButton" )
	self:SetScript( "OnDragStart", self.StartMoving )
	self:SetScript( "OnDragStop", self.StopMovingOrSizing )
	self:SetUserPlaced( true )
	self:RegisterEvent( "GROUP_ROSTER_UPDATE" )
	self:SetScript( "OnEvent", function( self, event )
		if event and Me.IsLeader( false ) then
			Me.MoraleBar_ShareStatusWithParty()
		end
	end)
		
	self.startInset = 0;
	self.endInset = 0;
	
	self.frame:Show();
	self.background:Show();
	self.fill:Show();
	self.spark:Show();
	
	--self.spark:SetBlendMode("ADD");
	self.spark:ClearAllPoints();
	self.spark:SetHeight(self:GetHeight());
	self.spark:SetWidth(self:GetHeight()/8);
	self.spark:SetPoint("LEFT", self.fill, "RIGHT", -5, 0);
	
	self.fill:ClearAllPoints();
	self.fill:SetPoint("TOPLEFT");
	self.fill:SetPoint("BOTTOMLEFT");
	self.fill:SetWidth(self:GetWidth());
	
	self.UpdateFill = Me.MoraleBar_UpdateFill;
	
	Me.MoraleBar_SetMinMaxPower(0, 100)
	
	if IsInGroup(1) and not Me.IsLeader( false ) then
		for i = 1, GetNumGroupMembers(1) do
			local name, rank = GetRaidRosterInfo(i)
			if rank == 2 then
				local msg = Me:Serialize( "MORREQ", {
					me = true;
				})
				Me:SendCommMessage( "DCM4", msg, "WHISPER", name, "NORMAL" )
				break
			end
		end
	end
end


function Me.MoraleBar_UpdateFill(self)
	if ( not self.range or self.range == 0 or not self.displayedValue ) then
		return;
	end
	local ratio = self.displayedValue / self.range;
	local fillAmount = self.startInset + ratio * ((1 - self.endInset) - self.startInset);
	self.fill:SetWidth(max(self:GetWidth() * fillAmount, 1));
	self.fill:SetTexCoord(0, fillAmount, 0, 1);
	
	if self.displayedValue == 100 then
		self.spark:Hide();
		if ( not self.flash:IsShown() ) then
			self.flash:Show();
			self.flash:SetAlpha(1);
			self.flashAnim:Play();
		elseif ( not self.flashAnim:IsPlaying() ) then
			self.flash:SetAlpha(1);
		end
	else
		if self.displayedValue == 0 then
			self.spark:Hide();
		else
			self.spark:Show();
		end
		self.flashAnim:Stop();
		if ( self.flash:IsShown() and not self.flashOutAnim:IsPlaying() ) then
			self.flashOutAnim:Play();
		end
	end
end

-------------------------------------------------------------------------------
-- Send a MORALE message to the party.
--
function Me.MoraleBar_ShareStatusWithParty()
	if not Me.IsLeader( true ) or not IsInGroup(1) then
		return
	end
	
	if Me.IsLeader( false ) then
		-- This is from the raid leader.
		local msg = Me:Serialize( "MORALE", {
			me = Profile.morale.enable;
			mn = Profile.morale.name;
			mv = DiceMasterMoraleBar.displayedValue;
			mt = Profile.morale.tooltip;
			ms = Profile.morale.symbol;
			mc = Profile.morale.color;
		})
		Me:SendCommMessage( "DCM4", msg, "RAID", nil, "NORMAL" )
	elseif DiceMasterMoraleBar:IsShown() then
		-- This is from a raid assistant.
		local msg = Me:Serialize( "MORALE", {
			me = true;
			mv = DiceMasterMoraleBar.displayedValue;
		})
		Me:SendCommMessage( "DCM4", msg, "RAID", nil, "NORMAL" )
	end
end

---------------------------------------------------------------------------
-- Received MORALE data.
-- 

function Me.MoraleBar_OnStatusMessage( data, dist, sender )

	-- Ignore our own data.
	if sender == UnitName( "player" ) then return end
 
	if data.me and data.mv then
		DiceMasterMoraleBar.displayedValue = tonumber(data.mv or 0);
		DiceMasterMoraleBar:UpdateFill();
	end
	
	-- sanitize message
	if not data.mn or not data.mv or not data.mt or not data.ms or not data.mc then
	   
		-- cover all those bases . . .
		return 
	end
	
	data.me = data.me or false; -- enabled
	data.mn = tostring(data.mn) -- name
	data.mv = tonumber(data.mv) -- value
	data.mt = tostring(data.mt) -- tooltip
	data.ms = tostring(data.ms) -- texture
	if #data.mc ~= 3 then data.mc = {1, 1, 1} end -- colour
	
	if not data.mn or not data.mv or not data.mt or not data.ms or not data.mc then
	   
		-- cover all those bases . . .
		return 
	end
	
	if not Me.db.char.hidepanel and data.me then
		Profile.morale.enable = true
		DiceMasterMoraleBar:Show()
	else
		Profile.morale.enable = false
		DiceMasterMoraleBar:Hide()
	end
	
	Me.MoraleBar_ApplyTextures(data.ms, data.mn, data.mt, data.mv, data.mc)
end

---------------------------------------------------------------------------
-- Received MORREQ data.
-- 

function Me.MoraleBar_OnStatusRequest( data, dist, sender )

	-- Ignore our own data.
	if sender == UnitName( "player" ) then return end
 
	if Me.IsLeader( false ) then
		local msg = Me:Serialize( "MORALE", {
			me = Profile.morale.enable;
			mn = Profile.morale.name;
			mv = DiceMasterMoraleBar.displayedValue;
			mt = Profile.morale.tooltip;
			ms = Profile.morale.symbol;
			mc = Profile.morale.color;
		})
		Me:SendCommMessage( "DCM4", msg, "WHISPER", sender, "NORMAL" )
	end
end