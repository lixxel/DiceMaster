-------------------------------------------------------------------------------
-- Dice Master (C) 2017 <The League of Lordaeron> - Moon Guard
-------------------------------------------------------------------------------

--
-- Trait Editing Panel
--


-------------------------------------------------------------------------------
-- Ranks and information of the LEAGUE OF LORDAERON
-------------------------------------------------------------------------------
local LEAGUE_RANKS = {
	[8] = {
		icon  = "Interface/PvPRankBadges/PvPRankAlliance";
		title = "Auxiliary";
		desc  = "Auxiliaries represent those that are associated with the League, but are not officially a part of its command structure. This includes mercenary attachments, liaisons with other orders, or civilian aids such as healers, administrators, and craftsmen."
	};
    [7] = {
		icon  = "Interface/PvPRankBadges/PvPRank06",
		title = "Advisor",
		desc  = "Advisors are former officers or Auxiliaries that have held their associate rank for an extended period of time and proven themselves to be especially valuable assets to the officer corps and the order as a whole."
	};
    [6] = {
		icon  = "Interface/PvPRankBadges/PvPRank01",
		title = "Private",
		desc  = "Privates are the lowest ranked members of the League; they have much to prove, but even more to gain. They are expected to follow orders dutifully and to the letter, and to maintain a sense of decency while representing the League."
	};
    [5] = {
		icon  = "Interface/PvPRankBadges/PvPRank02";
		title = "Corporal";
		desc  = "Corporals are members that have demonstrated loyalty and aptitude, and are promoted both to reward service and to help groom them for potential further promotion. They can and are entrusted with minor tasks if requested, such as leading small units individually.";
	};
    [4] = {
		icon  = "Interface/PvPRankBadges/PvPRank03";
		title = "Sergeant";
		desc  = "Sergeants are those that have proven a high level of loyalty and dedication to the League and its goals, but have either not been with the League for a sufficient period to merit promotion, or have not yet shown sufficient aptitude or potential for leadership.";
	};
    [3] = {
		icon  = "Interface/PvPRankBadges/PvPRank07";
		title = "Lieutenant";
		desc  = "Lieutenants are the most junior officer rank within the League, and handle most of the day-to-day administration of the order.";
	};
    [2] = {
		icon  = "Interface/PvPRankBadges/PvPRank08";
		title = "Captain";
		desc  = "The Captains of the League are entrusted with the care and well-being of its members; hardened veterans, most have been with the League for a great span of time and have proven themselves capable of sound judgment and quality in leadership.";
	};
    [1] = {
		icon  = "Interface/PvPRankBadges/PvPRank09";
		title = "Major";
		desc  = "The Major is the High Commander's right hand in all matters concerning the League of Lordaeron. When the High Commander is not available, leadership of the League defaults to the Major.";
	};
    [0] = {
		icon  = "Interface/PvPRankBadges/PvPRank11";
		title = "High Commander";
		desc  = "The High Commander is the ultimate authority within the League of Lordaeron, and should be respected as such. Whomever holds this office remains as the defining voice of the League, overseeing any and all decisions made for and by the organization.";
	};
}


local Me      = DiceMaster4
local Profile = Me.Profile

Me.editing_trait = 1

-------------------------------------------------------------------------------
-- OnLoad handler
--
-- Be careful in here because it's run before the addon is loaded.
--
function Me.TraitEditor_OnLoad( self )
	Me.editor = self
	
	self:SetClampedToScreen( true )
	self:RegisterForDrag( "LeftButton" )
	self:SetScript( "OnDragStart", self.StartMoving )
	self:SetScript( "OnDragStop", self.StopMovingOrSizing )
	
	self.trait_buttons = {}
	
	-- create trait buttons
	for i = 1,5 do
		self.trait_buttons[i] = CreateFrame( "DiceMasterTraitButton", "DiceMasterTraitButton" .. i, self )

		local x = 72 + 37*(i-1)
		-- if i == 5 then x = 206 end

		self.trait_buttons[i]:SetPoint( "TOPLEFT", x, -26 ) 
		self.trait_buttons[i].editable_trait = true
	  
		self.trait_buttons[i]:SetScript( "OnMouseDown", function( self, button )
			Me.TraitEditor_OnTraitClicked( self, button )
		end)
	end
	 
end

-------------------------------------------------------------------------------
-- When the trait editor's close button is pressed.
--
function Me.TraitEditor_OnCloseClicked() 
	PlaySound(840); 
	Me.IconPicker_Close()
	Me.editor:Hide()
end

-------------------------------------------------------------------------------
-- Change current trait being edited.
--
function Me.TraitEditor_StartEditing( index )
	EditBox_ClearFocus( Me.editor.scrollFrame.descEditor )
	EditBox_ClearFocus( Me.editor.traitName )
	Me.editing_trait = index
	
--	DiceMasterIconSelect_Hide() todo
	PlaySound(54130)
	
	Me.TraitEditor_Refresh() 
end

-------------------------------------------------------------------------------
-- When a trait button is clicked.
--
function Me.TraitEditor_OnTraitClicked( self, button )
	if not self.traitIndex then return end -- this handler is only for the player's traits
	
	if button == "LeftButton" then
		if IsShiftKeyDown() then
			-- Create chat link.
			
			-- We convert ability names' spaces to U+00A0 No-Break Space
			-- so that chat addons that split up messages see the link as 
			-- a whole word and have a lesser chance to screw up
			--
			-- We could use something another symbol that would be more secure
			-- but then people without the addon would see that ugly symbol
			--
			local name = Profile.traits[self.traitIndex].name:gsub( " ", " " )
			--                                                       |    |
			--                                                space -'    |
			--                                            no-break-space -'
			
			ChatEdit_InsertLink(
				string.format( "[DiceMaster4:%s:%d:%s]", UnitName("player"), self.traitIndex, name ) ) 
			
		else 
			Me.TraitEditor_StartEditing( self.traitIndex ) 
		end
	end
end

-------------------------------------------------------------------------------
-- Reload trait data and update the UI.
--
function Me.TraitEditor_Refresh()
	local trait = Profile.traits[Me.editing_trait]
	Me.editor.traitIcon:SetTexture( trait.icon )
	Me.editor.traitName:SetText( trait.name )
	Me.editor.traitUsage.text:SetText( Me.FormatUsage( trait.usage ) )
	Me.editor.scrollFrame.descEditor:SetText( trait.desc )
	if trait.enchant and trait.enchant~="" then
		Me.editor.traitIcon.ants:Show()
	else
		Me.editor.traitIcon.ants:Hide()
	end
	
	for i = 1, 5 do
		Me.editor.trait_buttons[i]:Refresh()
		Me.editor.trait_buttons[i]:Select( false )
	end
	Me.editor.trait_buttons[Me.editing_trait]:Select( true )
	
end

-------------------------------------------------------------------------------
-- Call this after changing a trait's data.
--
local function TraitUpdated()

	local trait = Profile.traits[Me.editing_trait]
	Me.BumpSerial( Me.db.char.traitSerials, Me.editing_trait )
	Me.Inspect_OnTraitUpdated( UnitName("player"), Me.editing_trait )
end	

-------------------------------------------------------------------------------
-- Change the usage of the currently edited trait
--
-- @param button Mouse button that was pressed
--               "LeftButton" = use next usage
--               "RightButton" = use previous usage
--
function Me.TraitEditor_ChangeUsage( button )
	local trait = Profile.traits[Me.editing_trait]
	
	local delta
	if button == "LeftButton" then
		delta = 1
	elseif button == "RightButton" then
		delta = -1
	else
		return
	end
	
	local usage_index
	for k,v in ipairs( Me.TRAIT_USAGE_MODES ) do
		if trait.usage == v then
			usage_index = k
			break
		end
	end

	if not usage_index then
		-- reset
		usage_index = 1
		
	else 
		-- find a new valid usage...
		while true do
			usage_index = usage_index + delta
			
			if not Me.TRAIT_USAGE_MODES[usage_index] then
				-- past the boundary
				if delta == 1 then
					usage_index = 1
				else
					usage_index = #Me.TRAIT_USAGE_MODES
				end
			end
			
			if Profile.charges.enable then
				break
			elseif not Me.TRAIT_USAGE_MODES[usage_index]:find( "CHARGE" ) then
				break
			end
			
			-- infinite loops always scare me
		end 
	end
	
	trait.usage = Me.TRAIT_USAGE_MODES[usage_index]
	
	-- update text
	Me.editor.traitUsage.text:SetText( Me.FormatUsage( trait.usage ) )
	TraitUpdated()
end

-------------------------------------------------------------------------------
-- Set the texture of the currently edited trait.
--
-- @param texture Path to texture file to use for the current trait.
--
function Me.TraitEditor_SelectIcon( texture )
	local trait = Profile.traits[Me.editing_trait]
	trait.icon = texture or "Interface/Icons/inv_misc_questionmark"
	Me.editor.trait_buttons[Me.editing_trait]:Refresh()
	Me.editor.traitIcon:SetTexture( texture )
	
	TraitUpdated()
end

-------------------------------------------------------------------------------
-- Handler for when the name editor loses focus.
--
function Me.TraitEditor_SaveName()
	local trait = Profile.traits[Me.editing_trait]
	trait.name = Me.editor.traitName:GetText()
	TraitUpdated()
end

-------------------------------------------------------------------------------
-- Handler for when the text editor loses focus.
--
function Me.TraitEditor_SaveDescription()
	local trait = Profile.traits[Me.editing_trait]
	trait.desc = Me.editor.scrollFrame.descEditor:GetText()
	TraitUpdated()
end

-------------------------------------------------------------------------------
-- Handler for when the text editor loses focus.
--

function Me.TraitEditor_SaveEnchantDescription()
	local trait = Profile.traits[Me.editing_trait]
	trait.altdesc = DICEMASTER_ENCHANT_OPTIONS[enchantName].func(trait.desc)
	TraitUpdated()
end

-------------------------------------------------------------------------------
-- Show the trait editor.
--
function Me.TraitEditor_Open()
	
	for i = 1,5 do
		Me.editor.trait_buttons[i]:SetPlayerTrait( UnitName( "player" ), i ) 
	end
	 
	local guildName, guildRankName, guildRankIndex = GetGuildInfo( "player" )
	if guildName ~= "The League of Lordaeron" then
		guildRankIndex = 8
	end
	--get name, race, class
	local charName, charRace, charClass, charColor = Me.GetCharInfo()
	
	SetPortraitTexture( Me.editor.portrait, "player" )
	
	Me.editor.TitleText:SetText( charName )
	
	Me.editor.CloseButton:SetScript("OnClick",Me.TraitEditor_OnCloseClicked)
	
	if Me.PermittedUse() then
		Me.editor.rankIcon.icon:SetTexture( LEAGUE_RANKS[guildRankIndex].icon )
		Me.SetupTooltip( Me.editor.rankIcon, nil, LEAGUE_RANKS[guildRankIndex].title, nil, nil, nil, LEAGUE_RANKS[guildRankIndex].desc )
	end
   
	Me.TraitEditor_Refresh()
	Me.editor:Show()
end
 
