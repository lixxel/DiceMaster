-------------------------------------------------------------------------------
-- Dice Master (C) 2017 <The League of Lordaeron> - Moon Guard
-------------------------------------------------------------------------------

--
-- Post tracker interface.
--

local Me = DiceMaster4
Me.WhoIsTyping = {}

local trackTypes = {
	["Say: "] = true,
	["Party: "] = true,
	["Raid: "] = true,
	[UnitName("player").." "] = true,
}

function Me.PostTracker_SendUpdate( typing )
	local data = {}
	data.na = UnitName("player")
	data.tp = typing
	local msg = Me:Serialize( "TYPE", data )
	C_ChatInfo.SendAddonMessage( "DCM4", msg, "RAID" )
end

function Me.PostTracker_Typing( self )
	local chatType = ChatFrame1EditBoxHeader:GetText()
	local msg = self:GetText()
	if string.len(msg) > 0 and not msg:match("%/%.*") then 
		msg = true
	else 
		msg = false 
	end
	
	if msg and trackTypes[chatType] and ChatFrame1EditBox:HasFocus() then
		if not self.Typing then
			self.Typing = true;
			Me.PostTracker_SendUpdate( self.Typing )
		end
	else
		self.Typing = false;
		Me.PostTracker_SendUpdate( self.Typing )
	end
end

function Me.PostTracker_OnLoad( self )
	ChatFrame1EditBox:HookScript("OnTextChanged", Me.PostTracker_Typing)
	ChatFrame1EditBox:HookScript("OnEditFocusLost", Me.PostTracker_Typing)
end

---------------------------------------------------------------------------
-- Someone is typing...
--  na = name							string
--	tp = typing | not typing			boolean

function Me.PostTracker_OnTyping( data, dist, sender )	
	-- Ignore our own data.
	if sender == UnitName( "player" )  then return end
 
	-- sanitize message
	if not data.na or not Me.db.global.hideTypeTracker then
	   
		return
	end
	
	if data.tp then
		tinsert(Me.WhoIsTyping, data.na)
	else
		for i=1,#Me.WhoIsTyping do
			if Me.WhoIsTyping[i] == data.na then
				tremove(Me.WhoIsTyping, i)
				break
			end
		end
	end
	
	if #Me.WhoIsTyping > 0 then
		local text = Me.WhoIsTyping[1]
		local plural = " is"
		
		if #Me.WhoIsTyping > 4 then
			text = "Several people"
			plural = " are"
		elseif #Me.WhoIsTyping > 1 then 
			plural = " are"
			for i = 2, #Me.WhoIsTyping do
				if i == #Me.WhoIsTyping then
					if #Me.WhoIsTyping > 2 then
						text = text .. ", and " .. Me.WhoIsTyping[i]
					else
						text = text .. " and " .. Me.WhoIsTyping[i]
					end
				else
					text = text .. ", " .. Me.WhoIsTyping[i]
				end
			end
		end
		
		if text then 
			text = "|TInterface/GossipFrame/ChatBubbleGossipIcon:16|t "..text..plural.." typing..."
			DiceMasterPostTrackerFrame.Message:SetText( text )
		end
		DiceMasterPostTrackerFrame.Message:Show()
	else
		DiceMasterPostTrackerFrame.Message:Hide()
	end
	
	-- ElvUI peasants...
	if ElvUI then
		DiceMasterPostTrackerFrame.Message:SetPoint("BOTTOMLEFT", "ChatFrame1EditBox", "BOTTOMLEFT", 4, -20)
	end
end