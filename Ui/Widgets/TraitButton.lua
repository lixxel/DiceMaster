-------------------------------------------------------------------------------
-- Dice Master (C) 2017 <The League of Lordaeron> - Moon Guard
-------------------------------------------------------------------------------

local Me = DiceMaster4

-------------------------------------------------------------------------------
Me.playerTraitTooltipOpen = false
Me.playerTraitTooltipName = nil
Me.playerTraitTooltipIndex = nil

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
		if trait.enchant and trait.enchant~="" then
			--usage = Me.FormatUsage( trait.altusage, playername )
		end
		GameTooltip:AddDoubleLine( usage, nil, 1, 1, 1, 1, 1, 1, true )
	end
	 
    GameTooltip:AddLine( nil, 1, 1, 1, true )
	
	if trait.desc then
		local desc = Me.FormatDescTooltip( trait.desc )
		if trait.enchant and trait.enchant~="" then
			local enchant = Me.FormatDescTooltip( trait.enchant )
			local duration = ""
			if trait.altdesc then
				duration = Me.FormatEnchantTooltip( trait.altdesc )
			end
			if not duration:find("(0 days)") then
				desc = desc .. "|n|n|cFFFF00FF"..enchant.." "..duration
			else
				duration = ""
				enchant = ""
				trait.enchant = "";
				trait:Refresh()
			end
		end
		GameTooltip:AddLine( desc, 1, 0.81, 0, true )
	end
	
	if owner and owner.editable_trait then
		GameTooltip:AddLine( "<Left Click to Edit>|n<Shift-Click to Link to Chat>", 0.44, 0.44, 0.44, true )
	end
	
    GameTooltip:Show() 
end

-------------------------------------------------------------------------------
function Me.CloseTraitTooltip()
	Me.playerTraitTooltipOpen = false
    GameTooltip:Hide()
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
			--self.border:SetTexture("Interface/AddOns/DiceMaster/Texture/elite-trait-border")
			--local bx, by = self:GetSize()
			--self.border:SetSize( bx*3 ,by*3 )
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

