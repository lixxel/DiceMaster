-------------------------------------------------------------------------------
-- Dice Master (C) 2020 <The League of Lordaeron> - Moon Guard
-------------------------------------------------------------------------------

--
-- Loot Toast interface.
--

local Me = DiceMaster4

local DICEMASTER_LOOT_BORDERS = {
	[1] = nil,
	[2] = "loottoast-itemborder-green",
	[3] = "loottoast-itemborder-blue",
	[4] = "loottoast-itemborder-purple",
	[5] = "loottoast-itemborder-orange",
	[6] = "loottoast-itemborder-artifact",
	[7] = "loottoast-itemborder-heirloom",
}

function Me.LootToastFrame_OnEnter( self )
	GameTooltip:SetOwner( self, "ANCHOR_RIGHT" )
	-- TODO: Set item tooltip
	GameTooltip:Show();
	
	self.MouseIsOver = true;
	
	if self.waitAndAnimOut:IsPlaying() then
		self.waitAndAnimOut:Stop()
	end
end

function Me.LootToastFrame_OnLeave( self )
	
	self.MouseIsOver = false;
	
	if self:IsShown() and not ( self.animIn:IsPlaying() or self.waitAndAnimOut:IsPlaying() ) then
		self.waitAndAnimOut:Play()
	end
end

function Me.LootToastFrame_SetUp( self, item, index )
	if type(item) == "string" then
		item = Me.inspectData[item].inventory[index]
	end

	local windowInfo = LOOTWONALERTFRAME_VALUES.Default;
	
	-- other options include...
	-- WonRoll, Default, Upgraded, LessAwesome, GarrisonCache, Horde, Alliance, RatedHorde, RatedAlliance, Azerite, Corrupted
	
	if ( windowInfo.bgAtlas ) then
		self.Background:Hide();
		self.BGAtlas:Show();
		self.BGAtlas:SetAtlas(windowInfo.bgAtlas);
		self.BGAtlas:SetPoint("CENTER", windowInfo.bgOffsetX, windowInfo.bgOffsetY);
	else
		self.Background:SetPoint("CENTER", windowInfo.bgOffsetX, windowInfo.bgOffsetY);
		self.Background:Show();
		self.BGAtlas:Hide();
	end
	if windowInfo.glowAtlas then
		self.glow:SetAtlas(windowInfo.glowAtlas);
		self.glow.suppressGlow = nil;
	else
		self.glow.suppressGlow = true;
	end

	self.Label:SetText(YOU_RECEIVED_LABEL or windowInfo.labelText);
	self.Label:SetPoint("TOPLEFT", self.lootItem.Icon, "TOPRIGHT", windowInfo.labelOffsetX, windowInfo.labelOffsetY);

	self.ItemName:SetText( item.name );
	local color = ITEM_QUALITY_COLORS[ item.quality ];
	self.ItemName:SetVertexColor(color.r, color.g, color.b);
	
	if DICEMASTER_LOOT_BORDERS[ item.quality ] then
		self.lootItem.IconBorder:SetAtlas( DICEMASTER_LOOT_BORDERS[ item.quality ] );
		self.lootItem.IconBorder:Show()
	else
		self.lootItem.IconBorder:Hide()
	end
	self.lootItem.Icon:SetTexture( item.icon );
	
	--TODO: Set up the item tooltip.
	--self.lootItem:Init(itemLink, originalQuantity, specID, isCurrency, isUpgraded, isIconBorderShown, isIconBorderDropShadowShown, iconDrawLayer);
	
	PlaySound(SOUNDKIT.UI_EPICLOOT_TOAST);
	Me.LootToastFrame_Play( self )
end

function Me.LootToastFrame_Play( self )
	self.animIn:Play()
	self.glow:Show()
	self.glow.animIn:Play()
	self.shine:Show()
	self.shine.animIn:Play()
	C_Timer.After( 3, function() 
		self.waitAndAnimOut:Play()
	end)
end

function Me.LootToastFrame_OnLoad( self )
	self:SetClampedToScreen( true )
	self:SetMovable(true)
	self:EnableMouse(true)
	self:RegisterForDrag( "LeftButton" )
	self:SetScript( "OnDragStart", self.StartMoving )
	self:SetScript( "OnDragStop", self.StopMovingOrSizing )
	self:SetUserPlaced( true )
end

---------------------------------------------------------------------------
--  Receive a Loot Toast request.
--  na = name							string
--  ii = item index						number

function Me.LootToast_OnToast( data, dist, sender )	
	-- Ignore our own data.
	if sender == UnitName( "player" )  then return end
 
	-- sanitize message
	if not data.na or not data.ii then
	   
		return
	end
	
	Me.LootToastFrame_SetUp( DiceMasterItemToastAlertFrame, data.na, data.ii )
end
