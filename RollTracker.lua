-------------------------------------------------------------------------------
-- Dice Master (C) 2019 <The League of Lordaeron> - Moon Guard
-------------------------------------------------------------------------------

--
-- Roll tracker interface.
--

local Me = DiceMaster4
local Profile = Me.Profile

if not Me.SavedRolls then
	Me.SavedRolls = {}
end
Me.HistoryRolls = {}

local ROLL_ROUND_TYPES = {
	["Attack"] = "Roll to attempt a combat action of your choosing.",
	["Bluff"] = "Roll to deceive, trick, or lie to someone.",
	["Defence"] = "Roll to defend yourself from enemy damage.",
	["Defense"] = "Roll to defend yourself from enemy damage.",
	-- You're welcome, America.
	["Diplomacy"] = "Roll to persuade or win favour with someone.",
	["Fortitude"] = "Roll to resist physical punishment or pain.",
	["Heal"] = "Roll to restore health to yourself or others.",
	["Insight"] = "Roll to discern intent and decipher body language during social interactions.",
	["Intimidat"] = "Roll to coerce or frighten someone.",
	-- Matches "Intimidate" and "Intimidation"
	["Magical Perception"] = "Roll to detect magic in the area.",
	-- Magical Perception has to go first to satisfy the str:find function.
	["Perception"] = "Roll to gain information about the area.",
	["Reflex"] = "Roll to avoid or prevent an unexpected action.",
	["Research"] = "Roll to gather information about a topic.",
	["Sleight of Hand"] = "Roll to plant an object on someone or conceal an object on your person.",
	["Stealth"] = "Roll to conceal yourself from detection.",
	["Surviv"] = "Roll to keep yourself safe and fed in the wild.",
	-- Matches "Survival" and "Survive"
	["Will"] = "Roll to resist mental influence.",
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

StaticPopupDialogs["DICEMASTER4_ROLLBANNER"] = {
  text = "Enter a title for the banner, or use one of the default prompts below:|n|n|cFFFFD100Attack|r, |cFFFFD100Bluff|r, |cFFFFD100Defence|r, |cFFFFD100Diplomacy|r, |cFFFFD100Fortitude Save|r, |cFFFFD100Healing|r, |cFFFFD100Intimidation|r, |cFFFFD100Insight|r, |cFFFFD100Perception|r, |cFFFFD100Magical Perception|r, |cFFFFD100Reflex Save|r, |cFFFFD100Research|r, |cFFFFD100Sleight of Hand|r, |cFFFFD100Stealth|r, |cFFFFD100Survival|r, |cFFFFD100Will Save|r",
  button1 = "Accept",
  button2 = "Cancel",
  OnShow = function (self, data)
    self.editBox:SetText("Attack")
	self.editBox:HighlightText()
  end,
  OnAccept = function (self, data)
    local text = self.editBox:GetText()
	local channel = "RAID";
	local name = nil;
	if data and UnitIsPlayer( data ) then
		channel = "WHISPER";
		name = data;
	end
	if GetNumGroupMembers() == 0 then
		channel = "WHISPER";
		name = UnitName("player")
	end
	if text == "" then
		UIErrorsFrame:AddMessage( "Invalid name: too short.", 1.0, 0.0, 0.0, 53, 5 );
	elseif strlen(text) > 30 then
		UIErrorsFrame:AddMessage( "Invalid name: too long.", 1.0, 0.0, 0.0, 53, 5 );
	else
		local msg = Me:Serialize( "BANNER", {
			na = tostring( UnitName("player") );
			tp = tostring( text );
		})
		Me:SendCommMessage( "DCM4", msg, channel, name or nil, "ALERT" )
	end
  end,
  hasEditBox = true,
  timeout = 0,
  whileDead = true,
  hideOnEscape = true,
  preferredIndex = 3,
}

StaticPopupDialogs["DICEMASTER4_GRANTEXPERIENCE"] = {
  text = "Experience Amount:",
  button1 = "Accept",
  button2 = "Cancel",
  OnShow = function (self, data)
    self.editBox:SetText("10")
	self.editBox:HighlightText()
  end,
  OnAccept = function (self, data)
    local text = tonumber(self.editBox:GetText()) or 0
	if text == "" or ( tonumber(text) > 100 ) or text == 0 then
		UIErrorsFrame:AddMessage( "Invalid amount.", 1.0, 0.0, 0.0, 53, 5 );
	else
		local msg = Me:Serialize( "EXP", {
			v = tonumber( text );
		})
		for i = 1, #DiceMasterDMExp.selected do
			local name, rank = GetRaidRosterInfo(DiceMasterDMExp.selected[i])
			if not name then return end
			Me:SendCommMessage( "DCM4", msg, "WHISPER", name, "ALERT" )
		end
	end
  end,
  hasEditBox = true,
  timeout = 0,
  whileDead = true,
  hideOnEscape = true,
  preferredIndex = 3,
}

StaticPopupDialogs["DICEMASTER4_GRANTLEVEL"] = {
  text = "Level Amount:",
  button1 = "Accept",
  button2 = "Cancel",
  OnShow = function (self, data)
    self.editBox:SetText("1")
	self.editBox:HighlightText()
  end,
  OnAccept = function (self, data)
    local text = tonumber(self.editBox:GetText()) or 0
	if text == "" or ( tonumber(text) > 100 ) or text == 0 then
		UIErrorsFrame:AddMessage( "Invalid amount.", 1.0, 0.0, 0.0, 53, 5 );
	else
		local msg = Me:Serialize( "EXP", {
			l = tonumber( text );
		})
		for i = 1, #DiceMasterDMExp.selected do
			local name, rank = GetRaidRosterInfo(DiceMasterDMExp.selected[i])
			if not name then return end
			Me:SendCommMessage( "DCM4", msg, "WHISPER", name, "ALERT" )
		end
	end
  end,
  hasEditBox = true,
  timeout = 0,
  whileDead = true,
  hideOnEscape = true,
  preferredIndex = 3,
}

StaticPopupDialogs["DICEMASTER4_LEVELRESETATTEMPT"] = {
  text = "Do you want to reset levels to 1? Players will lose all experience gained so far.|n|nType \"RESET\" into the field to confirm.",
  button1 = "Yes",
  button2 = "No",
  OnShow = function (self, data)
	self.button1:Disable()
	self.button1:SetScript("OnUpdate", function(self)
		if self:GetParent().editBox:GetText() == "RESET" then
			self:Enable()
		else
			self:Disable()
		end
	end)
  end,
  OnAccept = function (self, data)
	self.button1:SetScript("OnUpdate", nil)
    local msg = Me:Serialize( "EXP", {
			r = true;
		})
	for i = 1, #DiceMasterDMExp.selected do
		local name, rank = GetRaidRosterInfo(DiceMasterDMExp.selected[i])
		if not name then return end
		Me:SendCommMessage( "DCM4", msg, "WHISPER", name, "ALERT" )
	end
  end,
  hasEditBox = true,
  showAlert = true,
  timeout = 0,
  whileDead = true,
  hideOnEscape = true,
  preferredIndex = 3,
}

function Me.DiceMasterRollFrame_OnLoad(self)
	self:SetClampedToScreen( true )
	self:SetMovable(true)
	self:EnableMouse(true)
	self:RegisterForDrag( "LeftButton" )
	self:SetScript( "OnDragStart", self.StartMoving )
	self:SetScript( "OnDragStop", self.StopMovingOrSizing )
	self:SetScale(0.8)
	self:SetUserPlaced( true )
	
	self.portrait:SetTexture( "Interface/AddOns/DiceMaster/Texture/logo" )
	self.TitleText:SetText("DM Manager")
	--self.Inset:SetPoint("TOPLEFT", 4, -80);
	
	for i = 2, 17 do
		local button = CreateFrame("Button", "DiceMasterRollTrackerButton"..i, DiceMasterRollTracker, "DiceMasterRollTrackerButtonTemplate");
		button:SetID(i)
		button:SetPoint("TOP", _G["DiceMasterRollTrackerButton"..(i-1)], "BOTTOM");
	end
	
	for i = 2, 13 do
		local button = CreateFrame("Button", "DiceMasterDMExpButton"..i, DiceMasterDMExp, "DiceMasterDMExperienceButtonTemplate");
		button:SetID(i)
		button:SetPoint("TOP", _G["DiceMasterDMExpButton"..(i-1)], "BOTTOM", 0, -2);
	end
	
	DiceMasterDMExp.selected = {}
	Me.DiceMasterRollFrame_Update()
	
	local chat_events = { 
		"WHISPER";
		"PARTY";
		"PARTY_LEADER";
		"RAID";
		"RAID_LEADER";
	}
	
	local f = CreateFrame("Frame")
	for i, event in ipairs(chat_events) do
		f:RegisterEvent( "CHAT_MSG_" .. event )
		f:RegisterEvent( "GROUP_ROSTER_UPDATE" )
	end
	f:SetScript( "OnEvent", function( self, event, msg, sender )
		if event:match("CHAT_MSG_") then
			Me.OnChatMessage( msg, sender )
		elseif event == "GROUP_ROSTER_UPDATE" then
			DiceMasterDMNotesAllowAssistants:Hide()
			DiceMasterDMNotesDMNotes.EditBox:Disable()
			if Me.IsLeader() then
				DiceMasterDMNotesAllowAssistants:Show()
				DiceMasterDMNotesDMNotes.EditBox:Enable()
				Me.RollTracker_ShareNoteWithParty( true )
			end
			for i = 1, GetNumGroupMembers(1) do
				-- Get level and experience data from players.
				local name, rank = GetRaidRosterInfo(i)
				if name then
					Me.Inspect_UpdatePlayer( name )
				end
			end
			if GetNumGroupMembers(1) == 0 then
				DiceMasterDMExp.checkAll:SetChecked( false )
				DiceMasterDMExp.selected = {}
			end
			Me.DMExperienceFrame_Update()
		end
	end)
	
	if Me.IsLeader() then
		DiceMasterDMNotesAllowAssistants:Show()
		DiceMasterDMNotesDMNotes.EditBox:Enable()
		Me.RollTracker_ShareNoteWithParty()
	elseif IsInGroup(1) and not Me.IsLeader( false ) then
		for i = 1, GetNumGroupMembers(1) do
			local name, rank = GetRaidRosterInfo(i)
			if rank == 2 then
				local msg = Me:Serialize( "NOTREQ", {
					me = true;
				})
				Me:SendCommMessage( "DCM4", msg, "WHISPER", name, "NORMAL" )
				break
			end
		end
	end
end

function Me.RollTargetDropDown_OnClick(self, arg1)
	if arg1 > 0 then
		UIDropDownMenu_SetText(DiceMasterRollTracker.selectTarget, "|TInterface/TARGETINGFRAME/UI-RaidTargetingIcon_"..arg1..":16|t")
	else
		UIDropDownMenu_SetText(DiceMasterRollTracker.selectTarget, "") 
	end
	local msg = Me:Serialize( "TARGET", {
		ta = tonumber( arg1 );
	})
	Me:SendCommMessage( "DCM4", msg, "RAID", nil, "ALERT" )
	
	if not IsInGroup(1) then
		Me.OnChatMessage( "{rt"..arg1.."}", UnitName("player") ) 
	end
end

function Me.RollTargetDropDown_OnLoad(frame, level, menuList)
	local info = UIDropDownMenu_CreateInfo()
	
	info.text = "|cFFffd100Select a Target:"
	info.notClickable = true;
	info.notCheckable = true;
	UIDropDownMenu_AddButton(info, level)
	info.notClickable = false;
	info.disabled = false;
	
	for i = 1, 8 do
	   info.text = WORLD_MARKER_NAMES[i];
	   info.arg1 = i;
	   info.notCheckable = true;
	   info.func = Me.RollTargetDropDown_OnClick;
	   UIDropDownMenu_AddButton(info, level)
	end
	
	info.text = "No World Marker";
	info.arg1 = 0;
	info.notCheckable = true;
	info.func = Me.RollTargetDropDown_OnClick;
	UIDropDownMenu_AddButton(info, level)
end

function DiceMasterRollTrackerButton_OnClick(self, button)
	if ( button == "LeftButton" ) then
		DiceMasterRollTracker.selected = self.rollIndex
		Me.DiceMasterRollFrame_Update()
		Me.DiceMasterRollFrameDisplayDetail( self.rollIndex )
	end
end

function Me.SortRolls( self, reversed, sortKey )
	local sort_func = function( a,b ) return a[sortKey] < b[sortKey] end
	if not reversed then
		self.reversed = true
	else
		sort_func = function( a,b ) return a[sortKey] > b[sortKey] end
		self.reversed = false
	end
	table.sort( Me.SavedRolls, sort_func)
	DiceMasterRollTracker.selected = nil
	
	Me.DiceMasterRollFrame_Update()
end

function Me.ColourRolls( roll )
	local r, g, b = 1, 1, 1
	local dc = tonumber(DiceMasterRollTrackerDCThreshold:GetText()) or nil
	if not roll or not dc then return r, g, b end
	
	if roll > dc then
		r, g, b = 0, 1, 0
	elseif roll < dc then
		r, g, b = 1, 0, 0
	elseif roll == dc then
		r, g, b = 1, 1, 0
	end
	return r, g, b
end

function Me.Format_TimeStamp( timestamp )
	if not timestamp then return end
	
	local hour = tonumber(timestamp:match("(%d+)%:%d+%:%d+"))
	if hour > 12 then
		timestamp = string.gsub(timestamp, hour, hour-12)
	elseif hour < 1 then
		timestamp = string.gsub(timestamp, "00", 12)
	end
	
	return timestamp
end

function Me.ColourHistoryRolls( roll )
	local r, g, b = 1, 1, 1
	local dc = tonumber(DiceMasterRollTrackerDCThreshold:GetText()) or nil
	if not tonumber(roll) or not dc then return r, g, b end
	
	g = ( roll / dc )
	r = ( dc / roll )
	b = 0
	
	return r, g, b
end

function Me.DiceMasterRollFrame_Update()
	local name, roll, rollType, time, timestamp, target;
	local rollIndex;
	if #Me.SavedRolls > 0 then
		DiceMasterRollTrackerTotals:Hide()
	else
		DiceMasterRollTrackerTotals:Show()
		DiceMasterRollTrackerTotals:SetText("No Recent Rolls")
	end
	
	local rollOffset = FauxScrollFrame_GetOffset(DiceMasterRollTrackerScrollFrame);
	
	local showScrollBar = nil;
	if ( #Me.SavedRolls > 17 ) then
		showScrollBar = 1;
	end
	
	for i=1,17,1 do
		rollIndex = rollOffset + i;
		local button = _G["DiceMasterRollTrackerButton"..i];
		button.rollIndex = rollIndex
		local info = Me.SavedRolls[rollIndex];
		if ( info ) then
			name = info.name;
			roll = info.roll;
			rollType = info.rollType;
			time = info.time;
			timestamp = info.timestamp;
			target = info.target;			
		end
		local buttonText = _G["DiceMasterRollTrackerButton"..i.."Name"];
		buttonText:SetText(name)
		local buttonText = _G["DiceMasterRollTrackerButton"..i.."Roll"];
		buttonText:SetText(roll or "--")
		buttonText:SetTextColor(Me.ColourRolls( roll ))
		local buttonText = _G["DiceMasterRollTrackerButton"..i.."RollType"];
		if rollType == 0 or not rollType then
			buttonText:SetText("--")
		else
			buttonText:SetText(rollType)
		end
		local buttonText = _G["DiceMasterRollTrackerButton"..i.."Timestamp"];
		buttonText:SetText(Me.Format_TimeStamp( timestamp ))
		local buttonText = _G["DiceMasterRollTrackerButton"..i.."Target"];
		if target == 0 or not target then
			buttonText:SetText("")
		else
			buttonText:SetText("|TInterface/TARGETINGFRAME/UI-RaidTargetingIcon_"..target..":16|t")
		end
		
		-- Highlight the correct who
		if ( DiceMasterRollTracker.selected == rollIndex ) then
			button:LockHighlight();
		else
			button:UnlockHighlight();
		end
		
		if ( rollIndex > #Me.SavedRolls ) then
			button:Hide();
		else
			button:Show();
		end
		
		-- If need scrollbar resize columns
		if ( showScrollBar ) then
			Me.RollTrackerColumn_SetWidth(i, 225);
		else
			Me.RollTrackerColumn_SetWidth(i, 256);
		end
	end
	
	if DiceMasterRollTracker.selected then
		DiceMasterRollTracker.selectedName = Me.SavedRolls[DiceMasterRollTracker.selected].name;
	end
	
	FauxScrollFrame_Update(DiceMasterRollTrackerScrollFrame, #Me.SavedRolls, 17, 16 );
end

function Me.RollTrackerColumn_SetWidth(index, width)
	_G["DiceMasterRollTrackerButton"..index.."Highlight"]:SetWidth(width);
end

function Me.DiceMasterRollDetailFrame_Update()
	local roll, rollType, time, timestamp, dice;
	local rollIndex;
	local frame = DiceMasterRollFrame.DetailFrame
	local name = DiceMasterRollTracker.selectedName or nil
	if not Me.HistoryRolls[name] then return end
	if #Me.HistoryRolls[name] > 0 then
		frame.ListInset.Totals:Hide()
	else
		frame.ListInset.Totals:Show()
		frame.ListInset.Totals:SetText("No Recent Rolls")
	end
	
	local rollOffset = FauxScrollFrame_GetOffset(DiceMasterRollFrameDetailScrollFrame);
	
	local showScrollBar = nil;
	if ( #Me.HistoryRolls[name] > 9 ) then
		showScrollBar = 1;
	end
	
	local divider = 0
	local sum = 0
	for i=1,#Me.HistoryRolls[name] do
		divider = divider + 1
		sum = sum + Me.HistoryRolls[name][i].roll
	end
	if sum == 0 then 
		sum = "--"
	else
		sum = math.floor( sum / divider )
	end
	frame.AverageText:SetText(sum);
	frame.AverageText:SetTextColor(Me.ColourHistoryRolls( sum ))
	
	for i=1,9,1 do
		rollIndex = rollOffset + i;
		local button = _G["DiceMasterRollTrackerHistoryButton"..i];
		button.rollIndex = rollIndex
		local info = Me.HistoryRolls[name][rollIndex];
		if ( info ) then
			roll = info.roll;
			rollType = info.rollType;
			time = info.time;
			timestamp = info.timestamp;
			dice = info.dice;			
		end
		local buttonText = _G["DiceMasterRollTrackerHistoryButton"..i.."Roll"];
		buttonText:SetText(roll.." ("..dice..")")
		buttonText:SetTextColor(Me.ColourHistoryRolls( roll ))
		local buttonText = _G["DiceMasterRollTrackerHistoryButton"..i.."Timestamp"];
		buttonText:SetText(Me.Format_TimeStamp( timestamp ))
		local buttonText = _G["DiceMasterRollTrackerHistoryButton"..i.."Type"];
		if rollType == 0 or not rollType then
			buttonText:SetText("--")
		else
			buttonText:SetText(rollType)
		end
		
		-- If need scrollbar resize columns
		if ( showScrollBar ) then
			buttonText:SetWidth(40);
		else
			buttonText:SetWidth(50);
		end
		
		if ( rollIndex > #Me.HistoryRolls[name] ) then
			button:Hide();
		else
			button:Show();
		end
	end
	
	FauxScrollFrame_Update(DiceMasterRollFrameDetailScrollFrame, #Me.HistoryRolls[name], 9, 16 );
end

function Me.DMExperienceFrame_OnShow()		
	Me.DMExperienceFrame_Update()	
end

function Me.DMExperienceButton_OnClick(self, all)
	if self:GetChecked() then
		if all then
			for i = 1, 40 do
				tinsert(DiceMasterDMExp.selected, i)
			end
			Me.DMExperienceFrame_Update()
		else
			tinsert(DiceMasterDMExp.selected, self:GetParent().entryIndex)
		end
	else
		if all then
			DiceMasterDMExp.selected = {}
			Me.DMExperienceFrame_Update()
		else
			for i = 1, #DiceMasterDMExp.selected do
				if DiceMasterDMExp.selected[i] == self:GetParent().entryIndex then
					tremove(DiceMasterDMExp.selected, i)
					break;
				end
			end
		end
	end
end

function Me.DMExperienceFrame_Update()
	if ( not DiceMasterDMExp:IsShown() ) then
		return;
	end
	
	DiceMasterDMExpInset.Text:Hide()
	
	local name;
	local numGroupMembers = GetNumGroupMembers(1)
	if numGroupMembers < 1 then
		DiceMasterDMExpInset.Text:Show()
		for i = 1, 13 do
			local button = _G["DiceMasterDMExpButton"..i];
			button:Hide()
		end
		FauxScrollFrame_Update(DiceMasterDMExpScrollFrame, numGroupMembers, 13, 16 );
		return
	end
	local entryIndex;
	
	local entryOffset = FauxScrollFrame_GetOffset(DiceMasterDMExpScrollFrame);
	
	local showScrollBar = nil;
	if ( numGroupMembers > 13 ) then
		showScrollBar = 1;
	end
	
	for i=1,13,1 do
		entryIndex = entryOffset + i;
		local button = _G["DiceMasterDMExpButton"..i];
		button.entryIndex = entryIndex
		local name, rank, subgroup, level, class, fileName, zone, online = GetRaidRosterInfo(entryIndex)
		local buttonText = _G["DiceMasterDMExpButton"..i.."Name"];
		buttonText:SetText(name)
		
		if name and Me.inspectData[name] then
			local store = Me.inspectData[name]
			local buttonText =  _G["DiceMasterDMExpButton"..i.."ExperienceBarText"];
			button.level = store.level
			buttonText:SetText("Level ".. button.level);
			local buttonBar = _G["DiceMasterDMExpButton"..i.."ExperienceBar"];
			buttonBar:SetValue(store.experience)
		end
		
		if ( entryIndex > numGroupMembers ) then
			button:Hide();
		else
			button:Show();
		end
		
		local found = false;
		for i = 1, #DiceMasterDMExp.selected do
			if DiceMasterDMExp.selected[i] == button.entryIndex then
				found = true;
				break
			end
		end
		local checkBox = _G["DiceMasterDMExpButton"..i.."Check"];
		if name == UnitName("player") or not online then
			_G["DiceMasterDMExpButton"..i.."Name"]:SetVertexColor(0.5,0.5,0.5)
			checkBox:SetChecked( false )
			checkBox:Disable()
		else
			_G["DiceMasterDMExpButton"..i.."Name"]:SetVertexColor(1,0.81,0)
			checkBox:SetChecked( found )
			checkBox:Enable()
		end			
		
		-- If need scrollbar resize columns
		if ( showScrollBar ) then
			button:SetWidth(220);
		else
			button:SetWidth(240);
		end
	end
	
	FauxScrollFrame_Update(DiceMasterDMExpScrollFrame, numGroupMembers, 13, 16 );
end

function Me.DiceMasterRollFrameDisplayDetail( rollIndex )
	local frame = DiceMasterRollFrame.DetailFrame
	
	if rollIndex == nil or Me.SavedRolls[rollIndex] == nil then
		frame:Hide()
		return;
	end
	
	frame.Name:SetText(Me.SavedRolls[rollIndex].name);
	
	Me.DiceMasterRollDetailFrame_Update()
	frame:Show()
end 

function DiceMasterNotesEditBox_OnEditFocusGained(self)
	self.Instructions:Hide()
end

function DiceMasterNotesEditBox_OnEditFocusLost(self)
	if self:GetText() == "" then
		self.Instructions:Show()
	else
		self.Instructions:Hide()
	end
	
	if Me.IsLeader( true ) then
		Me.RollTracker_ShareNoteWithParty()
	end
end

function DiceMasterNotesEditBox_OnTextChanged(self, userInput)
	local parent = self:GetParent()
	ScrollingEdit_OnTextChanged(self, parent)
	local text = self:GetText()
	if text == "" then
		text = nil
	end
	if not userInput and not self:HasFocus() then
		DiceMasterNotesEditBox_OnEditFocusLost(self)
	end
end

-------------------------------------------------------------------------------
-- Send a NOTES message to the party.
--
function Me.RollTracker_ShareNoteWithParty( shareRollOptions )
	if not Me.IsLeader( true ) or not IsInGroup(1) then
		return
	end
	
	local msg = Me:Serialize( "NOTES", {
		no = DiceMasterDMNotesDMNotes.EditBox:GetText() or "";
		ra = DiceMasterDMNotesAllowAssistants:GetChecked();
	})
	
	Me:SendCommMessage( "DCM4", msg, "RAID", nil, "NORMAL" )
	
	if not shareRollOptions then return end
	
	-- Update roll options as well.
	msg = Me:Serialize( "RTYPE", {
		rt = Me.db.char.rollOptions;
	})
	
	Me:SendCommMessage( "DCM4", msg, "RAID", nil, "ALERT" )
end

-------------------------------------------------------------------------------
-- Record a DiceMaster roll.

function Me.OnRollMessage( name, you, count, sides, mod, roll, rollType ) 
	
	if not count or not sides or not mod or not roll then
		return
	end
	
	if you then
		name = UnitName("player")
	end
	
	if not rollType then
		rollType = 0
	end
	
	local dice = Me.FormatDiceType( count, sides, mod )
	
	if roll then
		roll = roll + mod
		if not Me.HistoryRolls[name] then
			Me.HistoryRolls[name] = {}
		end
		local exists = false;
		for i=1,#Me.SavedRolls do
			if Me.SavedRolls[i].name == name then
				Me.SavedRolls[i].roll = tonumber(roll)
				Me.SavedRolls[i].rollType = rollType
				Me.SavedRolls[i].time = date("%H%M%S")
				Me.SavedRolls[i].timestamp = date("%H:%M:%S")
				exists = true;
			end
		end
		
		if not exists then
			local data = {}
			data.roll = tonumber(roll)
			data.rollType = rollType
			data.time = date("%H%M%S")
			data.timestamp = date("%H:%M:%S")
			data.target = 0
			data.name = name
			tinsert(Me.SavedRolls, data)
		end
		
		local data = {}
		data.roll = tonumber(roll)
		data.rollType = rollType
		data.time = date("%H%M%S")
		data.timestamp = date("%H:%M:%S")
		data.dice = dice
		tinsert(Me.HistoryRolls[name], 1, data)
		
		Me.DiceMasterRollFrame_Update()
		
		if DiceMasterRollTracker.selectedName then
			Me.DiceMasterRollDetailFrame_Update()
		end
	end
end

-------------------------------------------------------------------------------
-- Record a vanilla roll.

function Me.OnVanillaRollMessage( name, roll, min, max ) 
	
	if not name or not roll or not min or not max then
		return
	end
	
	local dice = ( "(" .. min .. "-" .. max .. ")" )
	
	if roll then
		if not Me.HistoryRolls[name] then
			Me.HistoryRolls[name] = {}
		end
		local exists = false;
		for i=1,#Me.SavedRolls do
			if Me.SavedRolls[i].name == name then
				Me.SavedRolls[i].roll = tonumber(roll)
				Me.SavedRolls[i].rollType = 0
				Me.SavedRolls[i].time = date("%H%M%S")
				Me.SavedRolls[i].timestamp = date("%H:%M:%S")
				exists = true;
			end
		end
		
		if not exists then
			local data = {}
			data.roll = tonumber(roll)
			data.rollType = 0
			data.time = date("%H%M%S")
			data.timestamp = date("%H:%M:%S")
			data.target = 0
			data.name = name
			tinsert(Me.SavedRolls, data)
		end
		
		local data = {}
		data.roll = tonumber(roll)
		data.rollType = 0
		data.time = date("%H%M%S")
		data.timestamp = date("%H:%M:%S")
		data.dice = dice
		tinsert(Me.HistoryRolls[name], 1, data)
		
		Me.DiceMasterRollFrame_Update()
		
		if DiceMasterRollTracker.selectedName then
			Me.DiceMasterRollDetailFrame_Update()
		end
	end
end

function Me.OnChatMessage( message, sender ) 
	local icons = {
		{"star", "rt1"},
		{"circle", "coin", "rt2"},
		{"diamond", "rt3"},
		{"triangle", "rt4"},
		{"moon", "rt5"},
		{"square", "rt6"},
		{"cross", "x", "rt7"},
		{"skull", "rt8"}
	}
	
	if sender:find("-") then
		-- this is the best xrealm support ur gonna get :)
		sender = sender:match( "(.+)%-")
	end
	
	local found = false
	local icon = message:match("%{(%w+)%}") or 0
	for x=1,#icons do
		for y=1,#icons[x] do
			if icons[x][y] == icon then
				icon = x
				found = true
				break
			end
		end
	end
	
	if icon and found then
		local exists = false;
		for i=1,#Me.SavedRolls do
			if Me.SavedRolls[i].name == sender then
				Me.SavedRolls[i].time = date("%H%M%S")
				Me.SavedRolls[i].timestamp = date("%H:%M:%S")
				Me.SavedRolls[i].target = icon
				exists = true;
			end
		end
		
		if not exists then
			local data = {}
			data.name = sender
			data.time = date("%H%M%S")
			data.timestamp = date("%H:%M:%S")
			data.target = icon
			tinsert(Me.SavedRolls, data)
		end
		Me.DiceMasterRollFrame_Update()
	end
end

---------------------------------------------------------------------------
-- Received a NOTES message.
--	no = note							string
--  ra = raid assistants allowed		boolean

function Me.RollTracker_OnNoteMessage( data, dist, sender )	

	if sender == UnitName("player") then
		return
	end
 
	-- Only the party leader and raid assistants can send us these.
	if not UnitIsGroupLeader(sender, 1) and not UnitIsGroupAssistant(sender, 1) then 
		return 
	end
	
	-- sanitize message
	if not data.no then
	   
		return
	end
	
	data.no = tostring(data.no)
	DiceMasterDMNotesDMNotes.EditBox:SetText( data.no )
	
	if Me.IsLeader( true ) and data.ra then
		DiceMasterDMNotesDMNotes.EditBox:Enable()
	else
		DiceMasterDMNotesDMNotes.EditBox:Disable()
	end
	
end


---------------------------------------------------------------------------
-- Received NOTREQ data.
-- 

function Me.RollTracker_OnStatusRequest( data, dist, sender )

	-- Ignore our own data.
	if sender == UnitName( "player" ) then return end
 
	if Me.IsLeader( false ) then
		local msg = Me:Serialize( "NOTES", {
			no = DiceMasterDMNotesDMNotes.EditBox:GetText() or "";
			ra = DiceMasterDMNotesAllowAssistants:GetChecked();
		})
		
		Me:SendCommMessage( "DCM4", msg, "RAID", nil, "NORMAL" )
		
		-- Update roll options as well.
		msg = Me:Serialize( "RTYPE", {
			rt = Me.db.char.rollOptions;
		})
		
		Me:SendCommMessage( "DCM4", msg, "RAID", nil, "ALERT" )
	end
end

---------------------------------------------------------------------------
-- Received a target update.
--	ta = target							number

function Me.RollTracker_OnTargetMessage( data, dist, sender )	
 
	-- sanitize message
	if not data.ta then
	   
		return
	end
	
	local icon = tonumber( data.ta )
	
	local exists = false;
	for i=1,#Me.SavedRolls do
		if Me.SavedRolls[i].name == sender then
			Me.SavedRolls[i].time = date("%H%M%S")
			Me.SavedRolls[i].timestamp = date("%H:%M:%S")
			Me.SavedRolls[i].target = icon
			exists = true;
		end
	end
	
	if not exists then
		local msg = {}
		msg.name = sender
		msg.time = date("%H%M%S")
		msg.timestamp = date("%H:%M:%S")
		msg.target = icon
		tinsert(Me.SavedRolls, msg)
	end
	Me.DiceMasterRollFrame_Update()
end

---------------------------------------------------------------------------
-- Received a banner request.
--  na = name							string
--	tp = type							string

function Me.RollTracker_OnBanner( data, dist, sender )	
	-- Only the party leader can send us these.
	if not UnitIsGroupLeader(sender, 1) and not Me.IsLeader( false ) then return end
 
	-- sanitize message
	if not data.na or not data.tp then
	   
		return
	end
	
	if not DiceMasterRollBanner:IsShown() then
		
		-- if banners are off, just show the message.
		if not Me.db.global.enableRoundBanners then
			Me.PrintMessage("|TInterface/AddOns/DiceMaster/Texture/logo:12|t "..data.tp, "RAID")
			return
		end
		
		-- Look for punctuation at the end of the string
		if not data.tp:match("%p$") then
			data.tp = data.tp.."!"
		end
		
		DiceMasterRollBanner.Title:SetText( data.tp )
		
		local found = false;
		for k,v in pairs(ROLL_ROUND_TYPES) do
			if data.tp:find(k) then
				
				Me.PrintMessage("|TInterface/AddOns/DiceMaster/Texture/logo:12|t "..data.tp.." "..v)
				
				DiceMasterRollBanner.SubTitle:SetText(v)
				
				found = true;
				break;
			end
		end
		
		if not found then
			DiceMasterRollBanner.SubTitle:SetText("")
			Me.PrintMessage("|TInterface/AddOns/DiceMaster/Texture/logo:12|t "..data.tp, "RAID")
		end
		
		DiceMasterRollBanner.AnimIn:Play()
		local timer = C_Timer.NewTimer(5, function()
			if DiceMasterRollBanner:IsShown() then
				DiceMasterRollBanner.AnimOut:Play()
			end
		end)
		
	end
end