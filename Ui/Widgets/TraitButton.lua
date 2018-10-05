-------------------------------------------------------------------------------
-- Dice Master (C) 2017 <The League of Lordaeron> - Moon Guard
-------------------------------------------------------------------------------

local Me = DiceMaster4

local DICEMASTER_TERMS = {
	["Advantage"] = "Allows the player to roll the same dice twice, and take the greater of the two resulting numbers.",
	["Disadvantage"] = "Allows the player to roll the same dice twice, and take the lesser of the two resulting numbers.",
	["Double or Nothing"] = "An unmodified D40 roll. If the roll succeeds, the player is rewarded with a critical success; however, if the roll fails, the player suffers critically failure.",
	["Reload"] = "Grants the player's active trait another use.",
	["Poison"] = "Causes additional damage to a target each round.",
	["Control"] = "Allows the player to take command of a target until the effect expires.",
	["Stun"] = "Incapacitates a target, preventing them from performing any action next round.",
	["Rescue"] = "Allows the player to spare another player from failure.",
	["NAT1"] = "A roll of 1 that is achieved before dice modifiers are applied that results in critical failure.",
	["NAT20"] = "A roll of 20 that is achieved before dice modifiers are applied that results in critical success.",
}

-------------------------------------------------------------------------------
Me.playerTraitTooltipOpen = false
Me.playerTraitTooltipName = nil
Me.playerTraitTooltipIndex = nil

-------------------------------------------------------------------------------

function Me.CheckTooltipForTerms( text )
	local termsString = ""
	for k,v in pairs( DICEMASTER_TERMS ) do
		if string.match( text, k ) then
			if termsString~="" then 
				termsString = termsString .. "|n|n"
			end
			termsString = termsString .. "|cFFFFFFFF" .. k .. "|r|n|cFFffd100" .. DICEMASTER_TERMS[k] .. "|r"
		end
	end
	if termsString~="" then
		DiceMasterTooltip.TextLeft1:SetText( termsString )
		DiceMasterTooltip:Show()
	end
end

-------------------------------------------------------------------------------
function Me.UpdateTraitTooltip( name, index )
	
	if Me.playerTraitTooltipOpen and Me.playerTraitTooltipName == name and Me.playerTraitTooltipIndex == index then
		Me.OpenTraitTooltip( nil, name, index )
	end
end

-------------------------------------------------------------------------------
function Me.OpenTraitTooltip( owner, trait, index )
	local playername = nil
	
	if type(trait) == "string" then
		-- player trait
		
		playername = trait
		
		Me.playerTraitTooltipOpen  = true
		Me.playerTraitTooltipName  = trait
		Me.playerTraitTooltipIndex = index
		trait = Me.inspectData[trait].traits[index]
	end
	
	if owner then
		
		GameTooltip:SetOwner( owner, "ANCHOR_RIGHT" )
	end
	
	GameTooltip:ClearLines()
	
	if trait.name then
		if trait.icon then
			-- icon with name
			GameTooltip:AddLine( "|T"..trait.icon..":32|t "..trait.name, 1, 1, 1, true )
		else
			GameTooltip:AddLine( trait.name, 1, 1, 1, true )
		end
	end
	 
	if trait.usage then
		local usage = Me.FormatUsage( trait.usage, playername )
		GameTooltip:AddDoubleLine( usage, nil, 1, 1, 1, 1, 1, 1, true )
	end
	 
    GameTooltip:AddLine( nil, 1, 1, 1, true )
	
	if trait.desc then
		local desc = Me.FormatDescTooltip( trait.desc, playername )
		if Me.db.global.hideTips then
			Me.CheckTooltipForTerms( desc )
		end
		GameTooltip:AddLine( desc, 1, 0.81, 0, true )
	end
	
	if owner and owner.editable_trait then
		GameTooltip:AddLine( "<Left Click to Edit>|n<Shift-Click to Link to Chat>", 0.44, 0.44, 0.44, true )
	else
		GameTooltip:AddLine( "<Shift-Click to Link to Chat>", 0.44, 0.44, 0.44, true )
	end
	
    GameTooltip:Show() 
end

-------------------------------------------------------------------------------
function Me.CloseTraitTooltip()
	Me.playerTraitTooltipOpen = false
    GameTooltip:Hide()
	DiceMasterTooltip:Hide()
end

-------------------------------------------------------------------------------
-- Handler for trait tooltips.
--
local function OnEnter( self )
	
	self.highlight:Show()
	
	if self.customTooltip then
		GameTooltip:SetOwner( self, "ANCHOR_RIGHT" )
		GameTooltip:ClearLines()
		GameTooltip:AddLine( self.customTooltip, 1, 1, 1, true )
		GameTooltip:Show()
		return
	end
	
	if not self.trait and not self.traitPlayer then return end
	
	if self.trait then
		Me.OpenTraitTooltip( self, self.trait )
	elseif self.traitPlayer then 
		Me.OpenTraitTooltip( self, self.traitPlayer, self.traitIndex )
	else
		return
	end
	 
end

local function OnLeave( self )
	if not self.selected then
		self.highlight:Hide()
	end
	if self.traitPlayer then
		Me.playerTraitTooltipOpen = false
	end
    GameTooltip:Hide()
	DiceMasterTooltip:Hide()
end

-------------------------------------------------------------------------------
local methods = {
	---------------------------------------------------------------------------
	-- Set a static texture for this button.
	--
	-- Overrides SetTrait.
	--
	SetTexture = function( self, tex )
		self.trait       = nil
		self.traitPlayer = nil
		self.traitIndex  = nil
		self.icon:SetTexture( tex )
	end;
	
	---------------------------------------------------------------------------
	-- Hook this button up to a direct trait.
	--
	SetTrait = function( self, trait )
		self.trait = trait
		self:Refresh()
	end;
	
	---------------------------------------------------------------------------
	-- Hook this button up to a player trait.
	--
	SetPlayerTrait = function( self, player, index )
		self.trait = nil
		self.traitPlayer = player
		self.traitIndex  = index
		-- Add the gold dragon border if this is the command trait.
		if self.traitIndex == 5 then
			self.border:SetTexture("Interface/AddOns/DiceMaster/Texture/elite-trait-border")
			local bx, by = self:GetSize()
			self.border:SetSize( bx*3 ,by*3 )
		end
		self:Refresh()
	end;
	
	---------------------------------------------------------------------------
	-- Refresh after a trait changes.
	--
	Refresh = function( self )
		if self.trait then
			self.icon:SetTexture( self.trait.icon )
			local IsEnchanted = self.trait.enchant
			if isEnchanted and isEnchanted~="" then
				self.ants:Show()
			else
				self.ants:Hide()
			end
		elseif self.traitPlayer then
			self.icon:SetTexture( Me.inspectData[self.traitPlayer].traits[self.traitIndex].icon )
			local isEnchanted = Me.inspectData[self.traitPlayer].traits[self.traitIndex].enchant
			if isEnchanted and isEnchanted~="" then
				self.ants:Show()
			else
				self.ants:Hide()
			end
		end
	end;
	
	---------------------------------------------------------------------------
	-- "Select" this trait, i.e. make it glow.
	--
	Select = function( self, selected )
		self.selected = selected
		if selected then
			self.highlight:SetTexture( "Interface/Addons/DiceMaster/Texture/trait-highlight" )
			self.highlight:Show()
		else
			self.highlight:SetTexture( "Interface/Addons/DiceMaster/Texture/trait-select" )
			self.highlight:Hide()
		end
	end;
	
	SetCustomTooltip = function( self, text )
		self.customTooltip = text
	end;
}

-------------------------------------------------------------------------------
-- Initialize a new trait button.
--
function Me.TraitButton_Init( self )

	for k, v in pairs( methods ) do
		self[k] = v
	end
	 
	self:SetScript( "OnEnter", OnEnter )
	self:SetScript( "OnLeave", OnLeave ) 
	self.editable_trait = false 
end

function Me.TraitButton_OverlayGlowOnUpdate(self, elapsed)
	AnimateTexCoords(self.ants, 256, 256, 48, 48, 25, elapsed, 0.01);
end

