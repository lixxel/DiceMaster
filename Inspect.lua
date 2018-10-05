-------------------------------------------------------------------------------
-- Dice Master (C) 2017 <The League of Lordaeron> - Moon Guard
-------------------------------------------------------------------------------

local Me = DiceMaster4
local Profile = Me.Profile

local DEFAULT_ICON = "Interface/Icons/inv_misc_questionmark"

--
-- Requesting and reading trait data for other players.
-- Also can be used seamlessly for the player's own traits.
--

-------------------------------------------------------------------------------
Me.inspectData = {}
Me.inspectName = nil

Me.inspectQueue   = {}    -- Map of players that we want to inspect
Me.inspectStarted = false -- We are going to inspect players soon

-------------------------------------------------------------------------------
-- A special case for the player, where we just mirror their saved data.
--
local self_inspect = {
	hasDM4 = true;
}
setmetatable( self_inspect, {
	__index = function( table, key )
		if key == "statusSerial" then
			return Me.db.char.statusSerial
		else
			return Profile[key]
		end
	end;
})

Me.inspectData[UnitName("player")] = self_inspect

-------------------------------------------------------------------------------
-- Placeholder trait for data transfers.
--
local WAITING_FOR_TRAIT = {
	icon    = DEFAULT_ICON;
	name    = "";
	serial  = 0; 
	desc    = "Waiting for data from player.";
	enchant = "";
}

-------------------------------------------------------------------------------
local function PrimeInspectData( name )
	
	Me.inspectData[name] = {
		traits = {};
		statusSerial  = 0;
		charges = {
			enable    = false;
			name      = "Charges";
			color     = {1, 1, 1};
			count     = 0;
			max       = 0;
		};
		health        = 5;
		healthMax     = 5;
		follower = {};
		hasDM4        = false;
	}
	
	for i = 1, Me.traitCount do
		Me.inspectData[name].traits[i] = WAITING_FOR_TRAIT;
	end
end

-------------------------------------------------------------------------------
-- This little metatable adds some magic so that if you reference a name
-- without data yet, it primes it first with default values.
--
setmetatable( Me.inspectData, {
	__index = function( table, key )
		
		PrimeInspectData( key )
		return table[key]
	end;
})

-------------------------------------------------------------------------------
-- Refresh the inspect panel.
--
-- @param status Refresh the status bars.
-- @param trait  Refresh the trait displays, may be "all" to refresh all or
--               a trait index to refresh one.
--
function Me.Inspect_Refresh( status, trait )
	local store = Me.inspectData[Me.inspectName]
	if status then
		local ourChargesHack = Me.inspectName == UnitName("player") and not Profile.charges.enable
		
		if store.charges.max > 0 and not ourChargesHack then
			DiceMasterInspectFrame.charges:SetMax( store.charges.max )
			DiceMasterInspectFrame.charges:SetFilled( store.charges.count )
			DiceMasterInspectFrame.charges2:SetMinMaxValues( 0 , store.charges.max ) 
			DiceMasterInspectFrame.charges2:SetValue( store.charges.count )
			
			local symbol = store.charges.symbol or "charge-orb"
			
			DiceMasterInspectFrame.charges:SetTexture( 
				"Interface/AddOns/DiceMaster/Texture/"..symbol, 
				store.charges.color[1], store.charges.color[2], store.charges.color[3] )
			DiceMasterInspectFrame.charges2:SetStatusBarColor( store.charges.color[1], store.charges.color[2], store.charges.color[3] )
				
			-- Check for an Interface path.
			if not symbol:find("charge") then
				DiceMasterInspectFrame.charges2.frame:SetTexture("Interface/UNITPOWERBARALT/"..symbol.."_Horizontal_Frame")
				DiceMasterInspectFrame.charges2.text:SetText( store.charges.count.."/"..store.charges.max )
				DiceMasterInspectFrame.charges:Hide()
				DiceMasterInspectFrame.charges2:Show()
			else
				DiceMasterInspectFrame.charges:Show()
				DiceMasterInspectFrame.charges2:Hide()
			end
				
			local chargesPlural = store.charges.name:gsub( "/.*", "" )
			Me.SetupTooltip( DiceMasterInspectFrame.charges, nil, 
				chargesPlural, nil, nil, nil, 
				"Represents the amount of "..chargesPlural.." the player has accumulated for certain traits." )
			Me.SetupTooltip( DiceMasterInspectFrame.charges2, nil, 
				chargesPlural, nil, nil, nil, 
				"Represents the amount of "..chargesPlural.." the player has accumulated for certain traits." )
				
			DiceMasterInspectFrame.health:SetPoint( "CENTER", 0, 64 )
		else
			DiceMasterInspectFrame.charges:Hide()
			DiceMasterInspectFrame.charges2:Hide()
			DiceMasterInspectFrame.health:SetPoint( "CENTER", 0, 42 )
		end
		DiceMasterInspectFrame.health:SetMax( store.healthMax )
		DiceMasterInspectFrame.health:SetFilled( store.health )
		
		
	end
	
	if trait == "all" then
		for i = 1, Me.traitCount do
			DiceMasterInspectFrame.traits[i]:SetPlayerTrait( Me.inspectName, i )
		end
	elseif trait then
		DiceMasterInspectFrame.traits[trait]:SetPlayerTrait( Me.inspectName, trait )
	end 
	
	if not Me.db.char.hidepanel or not Me.db.global.hideInspect then
		if store.hasDM4 then
			DiceMasterInspectFrame:Show()
		end
	end
end

-------------------------------------------------------------------------------
-- Show the inspect panel and update a player's data.
--
-- @param name Name of player that we want to inspect.
--             If nil, the inspect panel will be closed instead.
--
function Me.Inspect_Open( name )
	Me.inspectName = name
	DiceMasterInspectFrame:Hide() 
	if name == nil then return end
	
	Me.Inspect_UpdatePlayer( name )
	Me.Inspect_Refresh( true, "all" ) 
end

-------------------------------------------------------------------------------
-- This is essentially meant to stop multiple requests per frame.
--
-- A simple queue to bundle up requests and discard duplicates, and then run
-- them a little later.
--
local function StartQueue()
	if Me.inspectStarted then return end
	Me.inspectStarted = true
	
	C_Timer.After( 0.025, function()
		Me.inspectStarted = false
		
		for name, _ in pairs( Me.inspectQueue ) do
			
			local store = Me.inspectData[name]
			
			-- build request
			-- see PROTOCOL.TXT
			local request_data = {
				ts = {};
				ss = store.statusSerial;
			}
			
			for i = 1, Me.traitCount do
				request_data.ts[i] = store.traits[i].serial
			end
			
			local msg = Me:Serialize( "INSP", request_data )
			
			Me:SendCommMessage( "DCM4", msg, "WHISPER", name, "ALERT" )
		end
		
		Me.inspectQueue = {}
	end)
end

-------------------------------------------------------------------------------
-- Update a player's data in the background.
--
-- @param name Name of player. Must be home-realm.
--
function Me.Inspect_UpdatePlayer( name )
	  
	if name ~= UnitName( "player" ) then
	
		Me.inspectQueue[ name ] = true
		StartQueue() 
	end
end

-------------------------------------------------------------------------------
-- Called when a player's trait is updated.
-- 
-- @param name  Name of player who was updated.
-- @param index Index of trait that was updated.
--
function Me.Inspect_OnTraitUpdated( name, index )
	if name == Me.inspectName then
		Me.Inspect_Refresh( nil, index )
	end
	
	-- If the user is viewing this trait, update their item ref tooltip.
	Me.UpdateTraitItemRef( name, index )
	
	-- If the user is mousing over this trait, via this inspect panel,
	-- then we update it IN FRONT OF THEIR VERY EYES.
	Me.UpdateTraitTooltip( name, index )
end

-------------------------------------------------------------------------------
-- When a trait button is clicked.
--
function Me.Inspect_OnTraitClicked( self, button )
	if not self.traitIndex then return end -- this handler is only for the target's traits
	
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
			local name = DiceMaster4.inspectData[UnitName("target")].traits[self.traitIndex].name:gsub( " ", " " )
			--                                                       |    |
			--                                                space -'    |
			--                                            no-break-space -'
			
			ChatEdit_InsertLink(
				string.format( "[DiceMaster4:%s:%d:%s]", UnitName("target"), self.traitIndex, name ) ) 
		end
	end
end

-------------------------------------------------------------------------------
-- Called when a player's Status is updated.
--
-- @param name Name of player that was updated.
--
function Me.Inspect_OnStatusUpdated( name )
	if name == Me.inspectName then
		Me.Inspect_Refresh( true )
	end
end

-------------------------------------------------------------------------------
-- Simple tonumber wrapper for 0 as failure.
--
local function ToNumber2( expr )
	return tonumber( expr ) or 0
end

-------------------------------------------------------------------------------
-- Convert 6-digit hex color to {r,g,b} decimal values.
--
local function FromHex( hex ) 
	return {
		ToNumber2("0x"..hex:sub(1,2))/255, 
		ToNumber2("0x"..hex:sub(3,4))/255, 
		ToNumber2("0x"..hex:sub(5,6))/255
	}
end

-------------------------------------------------------------------------------
-- Convert {r,g,b} decimal values to 6-digit hex code.
--
local function ToHex( col )
	return string.format( "%2x%2x%2x", 
		Me.Clamp( math.floor(col[1] * 255+0.5), 0, 255 ), 
		Me.Clamp( math.floor(col[2] * 255+0.5), 0, 255 ), 
		Me.Clamp( math.floor(col[3] * 255+0.5), 0, 255 ))
end

-------------------------------------------------------------------------------
-- Send data for one of your traits.
--
-- @param index   Index of Me.traits
-- @param dist    Addon message distribution.
-- @param channel Whisper target or channel name.
--
function Me.Inspect_SendTrait( index, dist, channel )
	local trait = Profile.traits[index]
	
	local msg = Me:Serialize( "TRAIT", {
		i = index;
		s = Me.db.char.traitSerials[index];
		n = trait.name;
		u = trait.usage;
		d = trait.desc;
		e = trait.enchant;
		t = trait.icon;
		l = Profile.follower.level;
		f = Profile.follower.name;
	})
	
	if (channel and (not type(channel) == "number")) then channel = tostring(channel) end
    Me:SendCommMessage( "DCM4", msg, dist, channel, "NORMAL" )
end

local sendStatusQueue   = {}
local sendStatusStarted = false

local function DoSendStatus()
	
	sendStatusStarted = false
	
	for k, v in pairs( sendStatusQueue ) do
	
		-- parse message parameters and send
		local dist, channel = k:match( "(.*)%.(.*)" )
		if channel == "" then channel = nil end
		 
		local msg = {
			s  = Me.db.char.statusSerial;
			h  = Profile.health;
			hm = Profile.healthMax;
			c  = Profile.charges.count;
			cm = Profile.charges.max;
			cn = Profile.charges.name;
			cs = Profile.charges.symbol;
			cc = ToHex(Profile.charges.color);
			fn = Profile.follower.name;
			fl = Profile.follower.level;
		}
		if not Profile.charges.enable then
			msg.c  = 0
			msg.cm = 0
		end
		
		local msg = Me:Serialize( "STATUS", msg )
		
		Me:SendCommMessage( "DCM4", msg, dist, channel, "ALERT" )
	end
	
	sendStatusQueue = {}
end

-------------------------------------------------------------------------------
-- Send data of your status.
--
-- @param dist    Addon message distribution.
-- @param channel Whisper target or channel name.
--
function Me.Inspect_SendStatus( dist, channel )

	-- we want to buffer up these calls too
	-- for example, if you're in the config panel and scrolling the color
	-- wheel for charges, you're going to generate a lot of sendstatus messages
	-- we'll wait a second and ignore any duplicate requests during that timeframe
	--
	sendStatusQueue[ dist .. "." .. (channel or "") ] = true
	if not sendStatusStarted then
		sendStatusStarted = true
		C_Timer.After( 1.0, DoSendStatus )
	end

end

-------------------------------------------------------------------------------
-- Send a STATUS message to the party.
--
function Me.Inspect_ShareStatusWithParty()
	if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
		return
	elseif not IsInGroup() then
		return
	end
	
	Me.Inspect_SendStatus( "RAID" )
	Me.Inspect_OnStatusUpdated( UnitName( "player" ) )
end

---------------------------------------------------------------------------
-- Received an INSPECT request.
--
function Me.Inspect_OnInspectMessage( data, dist, sender )
	
	if data.ts then
		-- they're requesting traits, see which ones.
		for i = 1, Me.traitCount do
			if data.ts[i] and Me.db.char.traitSerials[i] ~= data.ts[i] then
				-- their serial doesn't match, so we send them this trait
				Me.Inspect_SendTrait( i, "WHISPER", sender )
			end
		end
	end
	
	if data.ss and data.ss ~= Me.db.char.statusSerial then
		-- their status serial mismatches, so we send them our status
		Me.Inspect_SendStatus( "WHISPER", sender )
	end
end
	
---------------------------------------------------------------------------
-- Received TRAIT data.
--
function Me.Inspect_OnTraitMessage( data, dist, sender )
	
	-- Ignore our own data.
	if sender == UnitName( "player" ) then return end
	
	-- sanitize message
	if not data.i or not data.s then
		-- we require index and serial in message
		return
	end
	
	data.i = tonumber( data.i )
	data.s = tonumber( data.s )
	data.u = tostring( data.u or "UNKNOWN" ) 
	data.n = tostring( data.n or "<Unknown name.>" )
	data.d = tostring( data.d or "" )
	data.e = tostring( data.e or "" )
	data.t = tostring( data.t or DEFAULT_ICON )
	data.l = tonumber( data.l or 0 )
	data.f = tostring( data.f or "" )
	
	if not data.i or not data.s or data.i < 1 or data.i > Me.traitCount then 
		-- another pass after number sanitization
		return 
	end
	
	-- store in database
	Me.inspectData[sender].traits[data.i] = {
		serial  = data.s;
		name    = data.n;
		usage   = data.u;
		desc    = data.d;
		enchant = data.e;
		icon    = data.t;
	}
	
	if data.l then 
	Me.inspectData[sender].follower = {
		name	= data.f;
		level	= data.l;
	}
	end
	
	-- we flag them as having dicemaster once we receive their first message
	-- if they don't have this set, then the inspect panel isn't shown
	Me.inspectData[sender].hasDM4 = true
	
	Me.Inspect_OnTraitUpdated( sender, data.i )
end

---------------------------------------------------------------------------
-- Received STATUS data.
--
function Me.Inspect_OnStatusMessage( data, dist, sender )

	-- Ignore our own data.
	if sender == UnitName( "player" )  then return end
 
	-- sanitize message
	if not data.s or not data.h or not data.hm or not data.c or not data.cm
	   or not data.cn or not data.cc then
	   
		return
	end
	
	data.s  = tonumber(data.s)
	data.h  = tonumber(data.h)
	data.hm = tonumber(data.hm)
	data.fn = tostring(data.fn)
	data.fl = tonumber(data.fl)
	data.c  = tonumber(data.c)
	data.cm = tonumber(data.cm)
	data.cn = tostring(data.cn)
	if data.cs then data.cs = tostring(data.cs) end
	if #data.cc ~= 6 then data.cc = "FFFFFF" end
	
	if not data.s or not data.h or not data.hm or not data.c 
	   or not data.cm or not data.cn or data.cm < 0
	   or data.cm > 10 or data.hm < 1 or data.hm > 10 
	   or data.h < 0 or data.h > data.hm or data.c < 0 
	   or data.c > data.cm then
	   
		-- cover all those bases . . .
		return 
	end

	local store = Me.inspectData[sender]
	store.statusSerial   = data.s
	store.charges.enable = data.cm > 0
	store.charges.count  = data.c
	store.charges.max    = data.cm
	store.charges.name   = data.cn
	store.charges.color  = FromHex( data.cc )
	if data.cs then store.charges.symbol = data.cs end
	store.health         = data.h
	store.healthMax      = data.hm
	if data.fn then
	store.follower.level  = data.fl
	store.follower.name	 = data.fn
	end
	store.hasDM4         = true
	
	Me.Inspect_OnStatusUpdated( sender )
end

---------------------------------------------------------------------------
-- Received LEVEL data.
--

local FOLLOWER_DATA = {
	["Witch Hunter"] = {
		path = "Interface/AddOns/DiceMaster_UnitFrames/Texture/portrait-witch-hunter",
		sounds = {
			"Well fought.",
			"I feel stronger.",
			"Nothing will stop me now.",
			"Together we are unstoppable.",
			"My hunt continues.",
		},
	},
	["Inquisitor"] = {
		path = "Interface/AddOns/DiceMaster_UnitFrames/Texture/portrait-inquisitor",
		sounds = {
			"Impressive work.",
			"Perhaps I underestimated you.",
			"You make for an admirable ally.",
			"Now you I can count on.",
			"You are a valuable ally.",
		},
	}
}

function Me.Inspect_OnLevelMessage( data, dist, sender )
 
	-- make sure only the raid leader can grant us a level.
	--if not UnitIsGroupLeader( sender ) then return end
 
	-- make sure we're using a follower.
	if not Profile.follower.name then return end
	
	-- Level up the follower we're currently using.
	local level = Profile.follower.level or 0
	Profile.follower.level = level + 1
	print("|cFFFFFF00Your |cff71d5ff|HDiceMaster4:"..UnitName("player")..":5|h["..Profile.follower.name.."]|h|r|cFFFFFF00 has reached level "..Profile.follower.level.."!")
	
	local sound = random(5)
	local prefix = Profile.follower.name:gsub("%s+", "")
	PlaySound(46893)
	PlaySoundFile("Interface/AddOns/DiceMaster/Sounds/"..prefix.."_LevelUp00"..sound..".ogg")
	
	--Talking Heads integration
	if DiceMasterUnitsPanel and Me.db.global.talkingHeads then
		DiceMasterTalkingHeadFrame_SetUnit(FOLLOWER_DATA[Profile.follower.name].path, Profile.follower.name)
		DiceMasterTalkingHeadFrame_PlayCurrent(FOLLOWER_DATA[Profile.follower.name].sounds[sound])
	end
	
	Me.Inspect_SendStatus( "RAID" )
	Me.Inspect_OnStatusUpdated( UnitName( "player" ) )
end

-------------------------------------------------------------------------------
-- ADDON_LOADED handler
--
function Me.Inspect_Init()
	-- listen for messages
	
end


