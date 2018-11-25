-------------------------------------------------------------------------------
-- Dice Master (C) 2017 <The League of Lordaeron> - Moon Guard
-------------------------------------------------------------------------------

--
-- Roll tracker interface.
--

local Me = DiceMaster4

Me.SavedRolls = {}
Me.HistoryRolls = {}

function Me.DiceMasterRollFrame_OnLoad(self)
	self:SetClampedToScreen( true )
	self:SetMovable(true)
	self:EnableMouse(true)
	self:RegisterForDrag( "LeftButton" )
	self:SetScript( "OnDragStart", self.StartMoving )
	self:SetScript( "OnDragStop", self.StopMovingOrSizing )
	self:SetScale(0.8)
	self:SetUserPlaced( true )
	
	SetPortraitToTexture( self.portrait, "Interface/Icons/Ability_Tracking" )
	self.TitleText:SetText("Roll Tracker")
	self.Inset:SetPoint("TOPLEFT", 4, -80);
	
	for i = 2, 17 do
		local button = CreateFrame("Button", "DiceMasterRollTrackerButton"..i, DiceMasterRollTracker, "DiceMasterRollTrackerButtonTemplate");
		button:SetID(i)
		button:SetPoint("TOP", _G["DiceMasterRollTrackerButton"..(i-1)], "BOTTOM");
	end
	
	Me.DiceMasterRollFrame_Update()
	
	local hooks = {};
	
	local function AddMessage(self, message, ...)
		Me.OnRollMessage( message )
	 
		return hooks[self](self, message, ...)
	end
	
	for index = 1, NUM_CHAT_WINDOWS do
		if(index ~= 2) then
			local frame = _G['ChatFrame'..index]
			hooks[frame] = frame.AddMessage
			frame.AddMessage = AddMessage
		end
	end
	
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
	end
	f:SetScript( "OnEvent", function( self, event, msg, sender )
		if event then
			Me.OnChatMessage( msg, sender )
		end
	end)
end

function Me.RollListDropDown_OnClick(self, arg1)
	local dc = tonumber(DiceMasterRollTrackerDCThreshold:GetText()) or nil
	local list = nil
	if not dc then return end
	
	if arg1 == "success" then
		for i=1,#Me.SavedRolls do
			if Me.SavedRolls[i].roll > dc then
				if not list then 
					list = Me.SavedRolls[i].name
				else
					list = list..", "..Me.SavedRolls[i].name
				end
			end
		end
	elseif arg1 == "tie" then
		for i=1,#Me.SavedRolls do
			if Me.SavedRolls[i].roll == dc then
				if not list then 
					list = Me.SavedRolls[i].name
				else
					list = list..", "..Me.SavedRolls[i].name
				end
			end
		end
	elseif arg1 == "failure" then
		for i=1,#Me.SavedRolls do
			if Me.SavedRolls[i].roll < dc then
				if not list then 
					list = Me.SavedRolls[i].name
				else
					list = list..", "..Me.SavedRolls[i].name
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
		buttonText:SetText(roll)
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
	end
	
	if DiceMasterRollTracker.selected then
		DiceMasterRollTracker.selectedName = Me.SavedRolls[DiceMasterRollTracker.selected].name;
	end
	
	FauxScrollFrame_Update(DiceMasterRollTrackerScrollFrame, #Me.SavedRolls, 17, 16 );
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

function Me.DiceMasterRollFrame_AddRoll( roll )
	local roll, dice = message:match("You roll %|*[CcFf0]*(%d+)%|*%a*%p* %((%d*[dD]%d+[+-]?%d*)%)")
	if IsInGroup() then
		roll, dice = message:match(UnitName("player").." rolls %|*[CcFf0]*(%d+)%|*%a*%p* %((%d*[dD]%d+[+-]?%d*)%)")
	end
end

------------------------------------------------------------------------------- Find enchant roll in chat.

function Me.OnRollMessage( message ) 
	local name = UnitName("player")
	local roll, dice = message:match("You roll.* %|*[CcFf0]*([-]?%d+)%|*%a*%p* (%(%d*[dD]%d+[+-]?%d*%))")
	if IsInGroup() then
		name, roll, dice = message:match("(.+) rolls %|*[CcFf0]*([-]?%d+)%|*%a*%p* (%(%d*[dD]%d+[+-]?%d*%))")
	end
	if not roll then
		name, roll, dice = message:match("(.+) rolls (%d+) (%(%d+[-]%d+%))")
	end
	
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

function Me.DiceMasterRollFrameScrollBar_Update()
   FauxScrollFrame_Update(DiceMasterRollTrackerScrollFrame, #Me.SavedRolls, 17, 16 );
end


