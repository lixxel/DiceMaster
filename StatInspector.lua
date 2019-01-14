-------------------------------------------------------------------------------
-- Dice Master (C) 2019 <The League of Lordaeron> - Moon Guard
-------------------------------------------------------------------------------

--
-- Trait Editing Panel
--

local Me      = DiceMaster4
local Profile = Me.Profile

local StatsListEntries = { };

-------------------------------------------------------------------------------
-- Refresh the statistics list.
--
--
function Me.StatInspector_Update()

	SetPortraitTexture( Me.statinspector.portrait, "target" )
	Me.statinspector.TitleText:SetText( UnitName("target") )

	if not Me.inspectName then
		return
	end
	
	local store = Me.inspectData[Me.inspectName]
	local stats = store.stats

	if ( not Me.statinspector:IsShown() ) then
		return;
	end
	
	Me.statinspector.experienceBar.level:SetText(store.level or 1)
	Me.statinspector.experienceBar:SetValue(store.experience or 0)

	local addButtonIndex = 0;
	local totalButtonHeight = 0;
	local function AddButtonInfo(id)
		addButtonIndex = addButtonIndex + 1;
		if ( not StatsListEntries[addButtonIndex] ) then
			StatsListEntries[addButtonIndex] = { };
		end
		StatsListEntries[addButtonIndex].id = id;
		totalButtonHeight = totalButtonHeight + 24
	end
	
	if #stats == 0 then
		Me.statinspector.scrollFrame.totals:Show()
	else
		Me.statinspector.scrollFrame.totals:Hide()
	end

	-- saved statistics
	for i = 1, #stats do
		AddButtonInfo(i);
	end

	Me.statinspector.scrollFrame.totalStatsListEntriesHeight = totalButtonHeight;
	Me.statinspector.scrollFrame.numStatsListEntries = addButtonIndex;

	Me.StatInspector_UpdateStats();
end

-------------------------------------------------------------------------------
-- Update the stat buttons.
--
--
function Me.StatInspector_UpdateStats()
	local scrollFrame = Me.statinspector.scrollFrame;
	local offset = HybridScrollFrame_GetOffset(scrollFrame);
	local buttons = scrollFrame.buttons;
	local numButtons = #buttons;
	local numStatButtons = scrollFrame.numStatsListEntries;

	local usedHeight = 0;

	for i = 1, numButtons do
		local button = buttons[i];
		local index = offset + i;
		if ( index <= numStatButtons ) then
			button.index = index;
			local height = Me.StatInspector_UpdateStatButton(button)
			button:SetHeight(height);
			usedHeight = usedHeight + height;
			
			button:Show()
		else
			button.index = nil;
			button:Hide();
		end
	end
	HybridScrollFrame_Update(scrollFrame, scrollFrame.totalStatsListEntriesHeight, usedHeight);
end

function Me.StatInspector_UpdateStatButton(button)
	local index = button.index;
	button.id = StatsListEntries[index].id;
	local stats = Me.inspectData[Me.inspectName].stats
	local stat = stats[StatsListEntries[index].id]
	
	-- finish setting up button if it's not a header
	if ( stat ) then
	
		if stat.value then
			button.name:SetText(stat.name .. ":");
			button.title:SetText("");
			button.value:Show()
			button.value:SetText(stat.value);
		else
			button.name:SetText("");
			button.title:SetText(stat.name);
			button.value:Hide()
		end
		
		button:Show();
	else
		button:Hide();
	end
	return 24;
end

function Me.StatInspector_GetScrollFrameTopButton(offset)
	local usedHeight = 0;
	for i = 1, #StatsListEntries do
		local buttonHeight = 24
		if ( usedHeight + buttonHeight >= offset ) then
			return i - 1, offset - usedHeight;
		else
			usedHeight = usedHeight + buttonHeight;
		end
	end
end

-------------------------------------------------------------------------------
-- OnLoad handler
--
-- Be careful in here because it's run before the addon is loaded.
--
function Me.StatInspector_OnLoad( self )
	Me.statinspector = self
		
	self:SetClampedToScreen( true )
	self:RegisterForDrag( "LeftButton" )
	self:SetScript( "OnDragStart", self.StartMoving )
	self:SetScript( "OnDragStop", self.StopMovingOrSizing )	 
end

-------------------------------------------------------------------------------
-- When the stat inspector's close button is pressed.
--
function Me.StatInspector_OnCloseClicked() 
	PlaySound(840); 
	DiceMasterStatInspector:Hide()
end

-------------------------------------------------------------------------------
-- Show the stat inspector.
--
function Me.StatInspector_Open()
	
	SetPortraitTexture( Me.statinspector.portrait, "target" )
	
	Me.statinspector.TitleText:SetText( UnitName( "target" ) )
	
	Me.statinspector.CloseButton:SetScript("OnClick",Me.StatInspector_OnCloseClicked)

	Me.StatInspector_Update()
	Me.statinspector:Show()
end
 
