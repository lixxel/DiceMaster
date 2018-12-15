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
	[9] = {
		icon  = "Interface/PvPRankBadges/PvPRankAlliance";
		title = "Recruit",
		desc  = "Recruits are those who have just joined the order and who have not yet proved their pledge to Lordaeron. They are encouraged to wear the colors, participate in missions, and form connections with enlisted members of the League to prove their worth and establish their belonging."
	};
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

local TRAIT_RULES = {
	[1] = "When designing your traits, avoid overpowered or unreasonable abilities that grant you an unfair advantage.|n|nIf a trait seems too powerful, you can balance it by adding a drawback, such as a negative modifier or built-in consequence.|n|n|TInterface/Icons/ThumbsUp:14|t |cFF00FF00\"charName rolls D40 this turn, but sustains twice as severe an injury if the roll fails.\"|n|n|TInterface/Icons/ThumbsDown:14|t |cFFFF0000\"charName rolls D40 for the next three rounds.\"",
	[2] = "Traits cannot decide their own |cFFFFd100Difficulty Class|r, or the number set by the DM that you must score in order to succeed.|n|n|TInterface/Icons/ThumbsDown:14|t |cFFFF0000\"This trait succeeds with a roll of at least 10.\"",
	[3] = "Active trait modifiers may not exceed |cFF00FF00+5|r.|n|nPassive trait modifiers may not exceed |cFF00FF00+3|r, or |cFF00FF00+5|r if they target specific effects or creatures (e.g. Undead, Demons, Beasts).|n|nTraits that use |cFFFFd100Charges|r are exempt from this rule.|n|nTraits that grant other players a bonus may not exceed a modifier of |cFF00FF00+2|r.|n|n|TInterface/Icons/ThumbsUp:14|t |cFF00FF00\"charName gains +5 to attacks made against the Undead.\"|n|n|TInterface/Icons/ThumbsDown:14|t |cFFFF0000\"charName gains +7 for the next attack.\"",
	[4] = "|cFFFFd100Advantage|r cannot be used for passive traits and cannot be granted to more than one target at a time.|n|n|TInterface/Icons/ThumbsUp:14|t |cFF00FF00\"charName grants a chosen ally Advantage this turn.\"|n|n|TInterface/Icons/ThumbsDown:14|t |cFFFF0000\"All players gain Advantage this turn.\"",
	[5] = "Avoid giving a trait too many modifiers or effects.|n|nIf each effect can stand alone, it is probably best to separate them into multiple traits.|n|n|TInterface/Icons/ThumbsUp:14|t |cFF00FF00\"charName benefits from +3 to attack this turn.\"|n|n|TInterface/Icons/ThumbsDown:14|t |cFFFF0000\"charName gains +3 to attack, +3 to defence, +3 to perception, and +3 to stealth checks.\"",
	[6] = "Traits may not assign their own critical threshold. Only the DM can determine which rolls are critical.|n|n|TInterface/Icons/ThumbsDown:14|t |cFFFF0000\"This ability critically strikes with a roll of at least 15.\"",
	[7] = "Traits may not decide the action of any unit controlled by the DM, and may not decide the DM's dice. Traits can sometimes affect an enemy's modifiers, but this is left up to the DM's discretion.|n|n|TInterface/Icons/ThumbsUp:14|t |cFF00FF00\"Reduces the target's attack attempts by -3 for the next turn.\"|n|n|TInterface/Icons/ThumbsDown:14|t |cFFFF0000\"charName forces the enemy to roll with a D10 for the rest of combat.\"",
	[8] = "Traits that grant a player |cFFFFd100Immunity|r, or bypass a failed roll to spare a player from the consequences, should be limited to one or two uses and can only target a single player at a time.|n|n|TInterface/Icons/ThumbsUp:14|t |cFF00FF00\"charName spares a single chosen ally from failure this turn.\"|n|n|TInterface/Icons/ThumbsDown:14|t |cFFFF0000\"charName spares all players from failure this turn.\"",
	[9] = "An |cFFFFd100Ultimate|r trait, or a powerful, single-use slot four trait, may sometimes bend or break these rules, however they must still obey Rule I and require officer approval. An |cFFFFd100Ultimate|r is intended to give a character a short moment of heroic action - not to guarantee success or overshadow the actions of others.",
	[10] = "Your traits |cFFFF0000must|r be approved by two ranking officers before they are considered \"legal\" and allowed to be used in guild events. Please reach out to an officer when you are ready to have your traits reviewed.",
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

		local x = 60 + 35*(i-1)
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
	Me.buffeditor:Hide()
	Me.removebuffeditor:Hide()
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
	Me.buffeditor:Hide()
	Me.removebuffeditor:Hide()
end

-------------------------------------------------------------------------------
-- When a trait button is clicked.
--
function Me.TraitEditor_OnTraitClicked( self, button )
	if not self.traitIndex then return end -- this handler is only for the player's traits
	
	if button == "LeftButton" then
		if IsShiftKeyDown() then
			local channels = {
				"PARTY",
				"RAID",
				"GUILD",
				"WHISPER",
			}
			local channelName = tostring(LAST_ACTIVE_CHAT_EDIT_BOX:GetAttribute("chatType")) or nil
			local dist = "GUILD"
			for i = 1, #channels do
				if channels[i] == channelName then
					dist = channels[i]
					break;
				end
			end
			local channel = nil
			if dist == "WHISPER" then
				channel = ACTIVE_CHAT_EDIT_BOX:GetAttribute("tellTarget") or nil
			end
			Me.Inspect_SendTrait( self.traitIndex, dist, channel )
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
			if not self.noteditable then
				Me.TraitEditor_StartEditing( self.traitIndex ) 
				if Me.buffeditor:IsShown() then
					Me.buffeditor:Hide()
				end
				if Me.removebuffeditor:IsShown() then
					Me.removebuffeditor:Hide()
				end
			end
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
	
	for i = 1, 5 do
		Me.editor.trait_buttons[i]:Refresh()
		Me.editor.trait_buttons[i]:Select( false )
	end
	Me.editor.trait_buttons[Me.editing_trait]:Select( true )
	
	local buff = Profile.buffs[Me.editing_trait]
end

-------------------------------------------------------------------------------
-- Call this after changing a trait's data.
--
local function TraitUpdated()

	local trait = Profile.traits[Me.editing_trait]
	Me.BumpSerial( Me.db.char.traitSerials, Me.editing_trait )
	Me.Inspect_OnTraitUpdated( UnitName("player"), Me.editing_trait )
	Me.UpdatePanelTraits()
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
	trait.approved = 0;
	trait.officers = nil;
	TraitUpdated()
end

-------------------------------------------------------------------------------
-- Load the help tooltip text.
--
function Me.TraitEditor_HelpTooltipLoad()
	--get name, race, class
	local charName, charRace, charClass, charColor = Me.GetCharInfo()
	local tooltip = DiceMasterTraitEditorHelpTooltip

	DiceMasterTraitEditorHelpTooltip.Text:SetText( TRAIT_RULES[tooltip.rulesid]:gsub("charName",charName))
	DiceMasterTraitEditorHelpTooltip:SetHeight(DiceMasterTraitEditorHelpTooltip.Text:GetHeight()+60);
end

-------------------------------------------------------------------------------
-- Change the help tooltip page.
--
function Me.TraitEditor_ChangePage( self, delta )
	--get name, race, class
	local charName, charRace, charClass, charColor = Me.GetCharInfo()
	local tooltip = DiceMasterTraitEditorHelpTooltip
	tooltip.rulesid = tooltip.rulesid + 1*delta
	tooltip.Text:SetText(TRAIT_RULES[tooltip.rulesid]:gsub("charName",charName))
	tooltip:SetHeight(tooltip.Text:GetHeight()+60);
	if tooltip.rulesid == 1 then
		tooltip.PrevPageButton:Disable()
	elseif tooltip.rulesid == #TRAIT_RULES then
		tooltip.NextPageButton:Disable()
	else
		tooltip.PrevPageButton:Enable()
		tooltip.NextPageButton:Enable()
	end
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
	if not Me.PermittedUse() then
		DiceMasterTraitEditorHelpPlateButton:Hide()
	end
	Me.editor:Show()
end
 
