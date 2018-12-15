-------------------------------------------------------------------------------
-- Dice Master (C) 2017 <The League of Lordaeron> - Moon Guard
-------------------------------------------------------------------------------

local Me = DiceMaster4

local DICEMASTER_TERMS = {
	["Advantage"] = "Allows the character to roll the same dice twice, and take the greater of the two resulting numbers.",
	["Disadvantage"] = "Allows the character to roll the same dice twice, and take the lesser of the two resulting numbers.",
	["Double or Nothing"] = "An unmodified D40 roll. If the roll succeeds, the character is rewarded with a critical success; however, if the roll fails, the character suffers critically failure.",
	["Reload"] = "Grants the character's active trait another use.",
	["Revive"] = "Allows a character with |cFFFFFFFF0|r|TInterface/AddOns/DiceMaster/Texture/health-heart:12|t remaining to return to battle with diminished health.",
	["Poison"] = "Causes additional damage to a target each round.",
	["Control"] = "Allows the character to take command of a target until the effect expires.",
	["Stun"] = "Incapacitates a target, preventing them from performing any action next round.",
	["NAT1"] = "A roll of 1 that is achieved before dice modifiers are applied that results in critical failure.",
	["NAT20"] = "A roll of 20 that is achieved before dice modifiers are applied that results in critical success.",
	["Immunity"] = "Prevents a character from suffering the effects of a failure this round.",
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
	
	if trait.approved and trait.approved > 0 and Me.PermittedUse() then
		if trait.approved == 1 then
			DiceMasterTooltipApproved.icon:SetTexture("Interface/AddOns/DiceMaster/Texture/trait-unapproved")
		elseif trait.approved == 2 then
			DiceMasterTooltipApproved.icon:SetTexture("Interface/AddOns/DiceMaster/Texture/trait-approved")
		end
		DiceMasterTooltipApproved:Show()
	end
	 
    GameTooltip:AddLine( nil, 1, 1, 1, true )
	
	if trait.desc then
		local desc = Me.FormatDescTooltip( trait.desc )
		if Me.db.global.hideTips then
			Me.CheckTooltipForTerms( desc )
		end
		GameTooltip:AddLine( desc, 1, 0.81, 0, true )
	end
	
	local usable = ""
	local guildName, guildRankName, guildRankIndex = GetGuildInfo( "player" )
	
	if owner:GetParent():GetName() == "DiceMasterInspectFrame" and not UnitIsUnit("target", "player") and Me.IsOfficer() then
		local found = false;
		if trait.officers then
			for i=1,#trait.officers do
				if trait.officers[i] == UnitName("player") then	
					found = true;
					break;
				end
			end
		end
		if not found then
			usable = "<Right Click to Approve>|n"
		else
			usable = "<Right Click to Remove Approval>|n"
		end
	end
	
	if owner and owner.editable_trait then
		if Me.Profile.buffs[ index ] and owner:GetParent():GetName() == "DiceMasterPanel" then
			if Me.Profile.buffs[ index ].blank == false then
				usable = usable .. "<Right Click to Use>|n"
			end
		end
		if Me.Profile.removebuffs[ index ] and owner:GetParent():GetName() == "DiceMasterPanel" then
			if Me.Profile.removebuffs[ index ].blank == false then
				usable = usable .. "<Right Click to Use>|n"
			end
		end
		usable = usable .. "<Left Click to Edit>|n"
	end
	GameTooltip:AddLine( usable .. "<Shift-Click to Link to Chat>", 0.44, 0.44, 0.44, true )
	
    GameTooltip:Show()
end

-------------------------------------------------------------------------------
function Me.CloseTraitTooltip()
	Me.playerTraitTooltipOpen = false
    GameTooltip:Hide()
	DiceMasterTooltipApproved:Hide()
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
	DiceMasterTooltipApproved:Hide()
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
		elseif self.traitPlayer then
			self.icon:SetTexture( Me.inspectData[self.traitPlayer].traits[self.traitIndex].icon )
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

