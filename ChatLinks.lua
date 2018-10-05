-------------------------------------------------------------------------------
-- Dice Master (C) 2017 <The League of Lordaeron> - Moon Guard
-------------------------------------------------------------------------------

--
-- Chat link code.
--
-- Custom link format: [DiceMaster4:<user>:<traitIndex>:<traitName>]
-- Chat link format: |cff71d5ff|HDiceMaster4:<user>:<traitIndex>|h<traitName>|h|r
--

local Me = DiceMaster4

-------------------------------------------------------------------------------
-- Which events we want to hook for filtering chat links.
--
local chat_events = { 
	"SAY";
	"YELL";
	"EMOTE";
	"GUILD";
	"OFFICER";
	"PARTY";
	"PARTY_LEADER";
	"RAID";
	"RAID_LEADER";
	"RAID_WARNING";
	"BATTLEGROUND";
	"BATTLEGROUND_LEADER";
	"WHISPER";
	"WHISPER_INFORM";
	"BN_WHISPER";
	"BN_WHISPER_INFORM";
	"BN_CONVERSATION"; 
	"CHANNEL";
}

local club_events = {
	"COMMUNITIES_CHANNEL";
}

-------------------------------------------------------------------------------
-- For public events, we have to request chat link data manually.
-- Otherwise, it's sent by the addon instantly along with the message
--   over the same channel.
--
local public_events = {
	["CHAT_MSG_SAY"] = true;
	["CHAT_MSG_YELL"] = true;
	["CHAT_MSG_EMOTE"] = true;
}

-------------------------------------------------------------------------------
-- Chat filter for processing DiceMaster4 links.
--
local function ChatFilter( self, event, msg, sender, ... )
	local sender_short = Ambiguate( sender, "all" )
	
	local found_links = false
	
	local clean = string.gsub(msg, "%[DiceMaster4:(.-):(.-):(.-)%]", function(name, guid, ability)
		
		found_links = true
		
		-- remove the special spaces that were inserted 
		-- (See trait editor code for a better explanation.)
		ability = ability:gsub( " ", " " )
		
		-- convert into chat link
        return string.format("|cff71d5ff|HDiceMaster4:"..name..":"..guid.."|h[%s]|h|r", ability);
	end);
	
	if public_events[event] and found_links then
		
		-- if we received this over a public channel; request inspect data
		Me.Inspect_UpdatePlayer( sender_short )
	end
	
	return false, clean, sender, ...;
end


Me.itemRefOpen   = nil -- we have control over the itemreftooltip
Me.itemRefTrait  = nil -- trait table pointer
Me.itemRefIndex  = nil -- index of the trait
Me.itemRefPlayer = nil -- player name that owns the trait

local function RefreshItemRef()
	
	local trait = Me.itemRefTrait
	
	local name = string.format( "|T%s:32\124t %s", trait.icon, trait.name )
	
	ItemRefTooltip:ClearLines();
	ItemRefTooltip:AddLine( name, 1,1,1,1 )
	ItemRefTooltip:AddLine( Me.FormatUsage( trait.usage, Me.itemRefPlayer ), 1,1,1,1 )
	
	local desc = Me.FormatDescTooltip( trait.desc, Me.itemRefPlayer )
	if trait.enchant and trait.enchant~="" then
		local enchant = Me.FormatDescTooltip( trait.enchant, Me.itemRefPlayer )
		desc = desc .. "|n|n|cFFFF00FF"..enchant
	end
	ItemRefTooltip:AddLine( desc, 1,0.83,0.09,1 )
	ItemRefTooltip:Show();
end
 
-------------------------------------------------------------------------------
-- Hook for clicking links.
--
local SetHyperlink = ItemRefTooltip.SetHyperlink
function ItemRefTooltip:SetHyperlink(link)
	
    if strsub(link, 1, 12) == "DiceMaster4:" then
		if IsModifiedClick("CHATLINK") then
			-- shift-clicked
			--ChatEdit_InsertLink("["..link.."]")
			-- this doesn't work anyway.
			-- this might be a TODO job.
			-- we need to hook the chatbox code for copying links
		else
			local linkType, name, guid = strsplit(":", link)
			guid = tonumber(guid) 
			if not guid or guid < 1 or guid > Me.traitCount then return end
			
			Me.itemRefOpen   = true
			Me.itemRefTrait  = Me.inspectData[ name ].traits[guid]
			Me.itemRefIndex  = guid
			Me.itemRefPlayer = name
			 
			--ShowUIPanel(ItemRefTooltip); -- todo: test without this
			if not ItemRefTooltip:IsVisible() then
				ItemRefTooltip:SetOwner(UIParent, "ANCHOR_PRESERVE");
			end
			
			RefreshItemRef()
			
			-- if trait data isn't loaded yet, the tooltip will be updated
			-- automatically
		end
    else
	
		-- release control over the tooltip if something else is clicked
		-- so that when we receive inspect data, we dont update over what
		-- theyre viewing
		if Me.itemRefOpen and not IsModifiedClick("CHATLINK") then
			Me.itemRefOpen = false
			ItemRefTooltip:Hide()
		end
        SetHyperlink(self, link)
    end
end

-------------------------------------------------------------------------------
-- Event handler for when we receive trait data from a player.
--
function Me.UpdateTraitItemRef( name, index )
	if Me.itemRefOpen and name == Me.itemRefPlayer and index == Me.itemRefIndex then
		Me.itemRefTrait = Me.inspectData[ name ].traits[index]
		RefreshItemRef()
	end
end

-------------------------------------------------------------------------------
-- This is called when we send traits to a public channel.
--
-- For example, if we send a message with links to traits 1 and 3 to the party,
--  then we also add addon data for those traits with our chat message so
--  people have the data immediately rather than having to make a request.
--
-- If we send to /say or something, then they make the request via WHISPER
--  to refresh the trait data, and it should usually be done before they can
--  click the link (unless there is some traffic going on and the trait's
--  description is somewhat sizeable.)
--
local function SendTraits( traits, dist, channel )
	for k,v in pairs( traits ) do
		Me.Inspect_SendTrait( k, dist, channel )
	end
end

-------------------------------------------------------------------------------
-- Channels that trigger the SendTraits call.
--
local BROADCAST_CHAT_TYPES = {
	["BATTLEGROUND"] = "BATTLEGROUND";
	["GUILD"]        = "GUILD";
	["OFFICER"]      = "OFFICER";
	["PARTY"]        = "PARTY";
	["RAID"]         = "RAID";
	["RAID_WARNING"] = "RAID"; -- map raid warning to raid channel
	["WHISPER"]      = "WHISPER";
	["CHANNEL"]      = "CHANNEL";
}

-------------------------------------------------------------------------------
local function OnSendChatMessage( text, chatType, lang, channel )
	chatType = chatType:upper()
	
	-- misspelled should really find a way to remove their stupid color codes
	-- BEFORE allowing sendchatmessage to fire
	if Misspelled then
		text = Misspelled:RemoveHighlighting( text )
	end
	
	local traits = nil
	local name = UnitName("player")
	for t in text:gmatch( "%[DiceMaster4:"..name..":(%d+):.-%]" ) do
		t = tonumber(t)
		
		if t and t >= 1 and t <= Me.traitCount then
			traits = traits or {}
			traits[t] = true
		end
	end
	
	if not traits then 
		-- no traits in this message
		-- nothing to worry about
		return 
	end 
	
	local bc = BROADCAST_CHAT_TYPES[chatType]
	if bc then
		SendTraits( traits, bc, channel )
	end
end

-- separate handling for 8.0
-- big thanks to Silvz - Moon Guard (US) for helping with this fix!! <3

local streamTypeTable = {
	[0] = "GENERAL",
	[1] = "GUILD",
	[2] = "OFFICER",
	[3] = "CLUB_CHANNEL"
}

local function OnSendClubMessage(clubId, streamId, message)
	local streamInfo = C_Club.GetStreamInfo(clubId, streamId)
		
	local channel = nil
    local chatType = streamTypeTable[streamInfo["streamType"]]
    if(chatType == "CLUB_CHANNEL") then
        channelName = string.format("Community:%s:%s", clubId, streamId)
        channelId, channelName, instanceId = GetChannelName(channelName)
        if(channelId) then
            chatType = "CHANNEL"
            channel = tonumber(channelId)
        end
    end
	
	OnSendChatMessage(message, chatType, nil, channel)
end

-------------------------------------------------------------------------------
-- ADDON_LOADED handler
--
function Me.ChatLinks_Init()
	
	-- We really want to wait until we're setup before we accept anything
	-- so we hook stuff in here
	
	hooksecurefunc( "SendChatMessage", OnSendChatMessage )
	for i, event in ipairs(chat_events) do
		ChatFrame_AddMessageEventFilter( "CHAT_MSG_" .. event, ChatFilter );
	end
	
	-- for 8.0, adds support for clubs
	if( C_Club ) then
		hooksecurefunc( C_Club, "SendMessage", OnSendClubMessage )
		for i, event in ipairs(club_events) do
			ChatFrame_AddMessageEventFilter( "CHAT_MSG_" .. event, ChatFilter );
		end
	end
end

