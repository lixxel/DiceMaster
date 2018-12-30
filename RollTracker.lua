-------------------------------------------------------------------------------
-- Dice Master (C) 2017 <The League of Lordaeron> - Moon Guard
-------------------------------------------------------------------------------

--
-- Roll tracker interface.
--

local Me = DiceMaster4

Me.SavedRolls = {}
Me.HistoryRolls = {}

local ROLL_ROUND_TYPES = {
	["Attack"] = "Roll to attempt a combat action of your choosing.",
	["Defence"] = "Roll to defend yourself from enemy damage.",
	["Healing"] = "Roll to restore health to yourself or others.",
	["Perception"] = "Roll to gain information about the area.",
	["Magical Perception"] = "Roll to detect magic in the area.",
	["Stealth"] = "Roll to conceal yourself from detection.",
}

StaticPopupDialogs["DICEMASTER4_ROLLBANNER"] = {
  text = "What type of round is your group rolling for?|n(Attack, Defence, Healing, etc.)",
  button1 = "Accept",
  button2 = "Cancel",
  OnShow = function (self, data)
    self.editBox:SetText("Attack")
	self.editBox:HighlightText()
  end,
  OnAccept = function (self, data, data2)
	local name = UnitName("player")
    local text = self.editBox:GetText()
	if text == "" then
		UIErrorsFrame:AddMessage( "Invalid name: too short.", 1.0, 0.0, 0.0, 53, 5 );
	elseif strlen(text) > 30 then
		UIErrorsFrame:AddMessage( "Invalid name: too long.", 1.0, 0.0, 0.0, 53, 5 );
	else
		local msg = Me:Serialize( "BANNER", {
			na = tostring( name );
			tp = tostring( text );
		})
		Me:SendCommMessage( "DCM4", msg, "RAID", nil, "ALERT" )
	end
  end,
  hasEditBox = true,
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
	self.Inset:SetPoint("TOPLEFT", 4, -80);
	
	for i = 2, 17 do
		local button = CreateFrame("Button", "DiceMasterRollTrackerButton"..i, DiceMasterRollTracker, "DiceMasterRollTrackerButtonTemplate");
		button:SetID(i)
		button:SetPoint("TOP", _G["DiceMasterRollTrackerButton"..(i-1)], "BOTTOM");
	end
	
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
				Me.RollTracker_ShareNoteWithParty()
			end
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
	UIDropDownMenu_SetText(DiceMasterRollTracker.selectTarget, self:GetText()) 
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

	for i = 1, 8 do
	   info.text = "|TInterface/TARGETINGFRAME/UI-RaidTargetingIcon_"..i..":16|t"
	   info.arg1 = i
	   info.notCheckable = true;
	   info.func = Me.RollTargetDropDown_OnClick;
	   UIDropDownMenu_AddButton(info, level)
	end
end

function Me.RollListDropDown_OnClick(self, arg1)
	local dc = tonumber(DiceMasterRollTrackerDCThreshold:GetText()) or nil
	local list = nil
	if not dc then return end
	
	if arg1 == "success" then
		for i=1,#Me.SavedRolls do
			if Me.SavedRolls[i].roll > dc then
				if not list then 
					list = Me.SavedRolls[i].name.." ("..Me.SavedRolls[i].roll..")"
				else
					list = list..", "..Me.SavedRolls[i].name.." ("..Me.SavedRolls[i].roll..")"
				end
			end
		end
	elseif arg1 == "tie" then
		for i=1,#Me.SavedRolls do
			if Me.SavedRolls[i].roll == dc then
				if not list then 
					list = Me.SavedRolls[i].name.." ("..Me.SavedRolls[i].roll..")"
				else
					list = list..", "..Me.SavedRolls[i].name.." ("..Me.SavedRolls[i].roll..")"
				end
			end
		end
	elseif arg1 == "failure" then
		for i=1,#Me.SavedRolls do
			if Me.SavedRolls[i].roll < dc then
				if not list then 
					list = Me.SavedRolls[i].name.." ("..Me.SavedRolls[i].roll..")"
				else
					list = list..", "..Me.SavedRolls[i].name.." ("..Me.SavedRolls[i].roll..")"
				end
			end
		end
	end
	
	if list then
		ChatFrame1EditBox:SetFocus()
		ChatEdit_InsertLink( list ) 
	end
end

function Me.RollListDropDown_OnLoad(frame, level, menuList)
	local dc = DiceMasterRollTrackerDCThreshold:GetText() or ""
	local info = UIDropDownMenu_CreateInfo()
    info.text = "|cFF00FF00Success|r (>"..dc..")"
    info.arg1 = "success"
    info.notCheckable = true;
    info.func = Me.RollListDropDown_OnClick;
    UIDropDownMenu_AddButton(info, level)
	info.text = "|cFFFFFF00Tie|r ("..dc..")"
    info.arg1 = "tie"
    info.notCheckable = true;
    info.func = Me.RollListDropDown_OnClick;
    UIDropDownMenu_AddButton(info, level)
	info.text = "|cFFFF0000Failure|r (<"..dc..")"
    info.arg1 = "failure"
    info.notCheckable = true;
    info.func = Me.RollListDropDown_OnClick;
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
	
	local period = "AM";
	local hour = tonumber(timestamp:match("(%d+)%:%d+%:%d+"))
	if hour > 12 then
		period = "PM";
		timestamp = string.gsub(timestamp, hour, hour-12)
	end
	
	return (timestamp.." "..period)
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
	local name, roll, time, timestamp, target;
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
			time = info.time;
			timestamp = info.timestamp;
			target = info.target;			
		end
		local buttonText = _G["DiceMasterRollTrackerButton"..i.."Name"];
		buttonText:SetText(name)
		local buttonText = _G["DiceMasterRollTrackerButton"..i.."Roll"];
		buttonText:SetText(roll or "--")
		buttonText:SetTextColor(Me.ColourRolls( roll ))
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
	local roll, time, timestamp, dice;
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
			time = info.time;
			timestamp = info.timestamp;
			dice = info.dice;			
		end
		local buttonText = _G["DiceMasterRollTrackerHistoryButton"..i.."Roll"];
		buttonText:SetText(roll)
		buttonText:SetTextColor(Me.ColourHistoryRolls( roll ))
		local buttonText = _G["DiceMasterRollTrackerHistoryButton"..i.."Timestamp"];
		buttonText:SetText(Me.Format_TimeStamp( timestamp ))
		local buttonText = _G["DiceMasterRollTrackerHistoryButton"..i.."Dice"];
		buttonText:SetText(dice)
		
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
function Me.RollTracker_ShareNoteWithParty()
	if not Me.IsLeader( true ) or not IsInGroup(1) then
		return
	end
	
	local msg = Me:Serialize( "NOTES", {
		no = DiceMasterDMNotesDMNotes.EditBox:GetText() or "";
		ra = DiceMasterDMNotesAllowAssistants:GetChecked();
	})
	
	Me:SendCommMessage( "DCM4", msg, "RAID", nil, "NORMAL" )
end

-------------------------------------------------------------------------------
-- Record a DiceMaster roll.

function Me.OnRollMessage( name, you, count, sides, mod, roll ) 
	
	if not count or not sides or not mod or not roll then
		return
	end
	
	if you then
		name = UnitName("player")
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
				Me.SavedRolls[i].time = date("%H%M%S")
				Me.SavedRolls[i].timestamp = date("%H:%M:%S")
				exists = true;
			end
		end
		
		if not exists then
			local data = {}
			data.roll = tonumber(roll)
			data.time = date("%H%M%S")
			data.timestamp = date("%H:%M:%S")
			data.target = 0
			data.name = name
			tinsert(Me.SavedRolls, data)
		end
		
		local data = {}
		data.roll = tonumber(roll)
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
				Me.SavedRolls[i].time = date("%H%M%S")
				Me.SavedRolls[i].timestamp = date("%H:%M:%S")
				exists = true;
			end
		end
		
		if not exists then
			local data = {}
			data.roll = tonumber(roll)
			data.time = date("%H%M%S")
			data.timestamp = date("%H:%M:%S")
			data.target = 0
			data.name = name
			tinsert(Me.SavedRolls, data)
		end
		
		local data = {}
		data.roll = tonumber(roll)
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
	if not Me.db.global.enableRoundBanners or not UnitIsGroupLeader(sender, 1) then return end
 
	-- sanitize message
	if not data.na or not data.tp then
	   
		return
	end
	
	if Me.PermittedUse() and not DiceMasterRollBanner:IsShown() then
		
		DiceMasterRollBanner.Title:SetText( data.tp )
		
		if ROLL_ROUND_TYPES[ data.tp ] then
			DiceMasterRollBanner.Title:SetText( data.tp .. " Round!" )
			DiceMasterRollBanner.SubTitle:SetText(ROLL_ROUND_TYPES[ data.tp ])
		else
			DiceMasterRollBanner.SubTitle:SetText("")
		end
		
		DiceMasterRollBanner.AnimIn:Play()
		local timer = C_Timer.NewTimer(5, function()
			if DiceMasterRollBanner:IsShown() then
				DiceMasterRollBanner.AnimOut:Play()
			end
		end)
		
	end
end


