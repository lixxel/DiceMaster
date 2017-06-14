-------------------------------------------------------------------------------
-- Dice Master (C) 2017 <The League of Lordaeron> - Moon Guard
-------------------------------------------------------------------------------

--
-- Dice rolling code.
--

-------------------------------------------------------------------------------
local Me = DiceMaster4 

local ROLL_TIMEOUT = 1.5   -- timeout before printing rolls normally
local CLEAN_TIME   = 5     -- timeout before we throw data away

-- english is "%s rolls %d (%d-%d)";
local SYSTEM_ROLL_PATTERN = RANDOM_ROLL_RESULT 

SYSTEM_ROLL_PATTERN = SYSTEM_ROLL_PATTERN:gsub( "%%s", "(%%S+)" )
SYSTEM_ROLL_PATTERN = SYSTEM_ROLL_PATTERN:gsub( "%%d", "(%%d+)" )
SYSTEM_ROLL_PATTERN = SYSTEM_ROLL_PATTERN:gsub( "%(%(%%d%+%)%-%(%%d%+%)%)", "%%((%%d+)%%-(%%d+)%%)" ) -- this is what we call voodoo?
-- RESULT: (%S+) rolls (%d+) %((%d+)%-(%d+)%)

local doingDiceMasterRoll = false

local playerServerRolls = {}  --    (\_/)
local playerRollInfo    = {}  --   (='.'=)
local playerCleanTime   = {}  --   (")_(")

-------------------------------------------------------------------------------
-- Print a system message to chat.
--
-- @param msg Text to print.
--
local function PrintSystemMessage( msg )

	local info = ChatTypeInfo["SYSTEM"]
	for i = 1, NUM_CHAT_WINDOWS do
		local frame = _G["ChatFrame" .. i]
		
		if frame then
		
			-- well this seems fairly nasty
			local registered = {GetChatWindowMessages(i)}
			 
			for _,v in ipairs(registered) do
				if v == "SYSTEM" then
				 
					frame:AddMessage( msg, info.r, info.g, info.b )
					break
				end
			end
		end
	end
end

-------------------------------------------------------------------------------
-- Format and print a Dice Master roll.
--
-- @param name      Name of player.
-- @param count     Number of dice.
-- @param sides     Number of sides on dice.
-- @param mod       Roll modifier (signed integer).
-- @param rolls     Table of rolls to sum up. (Usually just one.)
-- @param broadcast Broadcast result to party/raid, but only if name is YOU.
--
local function PrintDiceMasterRoll( name, count, sides, mod, rolls, broadcast )

	local sum = 0
	for k,v in pairs( rolls ) do 
		sum = sum + v
	end
	
	sum = sum + mod 
	
	local rollstring = ""
	if count == 1 then
		rollstring = sum
	else
		rollstring = rolls[1]
		for i = 2,count do
			if i == count then
				if count > 2 then
					rollstring = rollstring .. ", and " .. rolls[i]
				else
					rollstring = rollstring .. " and " .. rolls[i]
				end
			else
				rollstring = rollstring .. ", " .. rolls[i]
			end
		end
		rollstring = rollstring .. " = " .. sum
	end
	
	local dice = "D" .. sides;
	if count ~= 1 then
		dice = count .. dice
	end
	if mod ~= 0 then
		if mod > 0 then
			dice = dice .. "+" .. mod
		else
			dice = dice .. mod
		end
	end
	
	rollstring = rollstring .. " (" .. dice .. ")"
	
	if IsInGroup() then
		local channel = IsInRaid() and "RAID" or "PARTY"
		
		if broadcast and UnitName("player") == name then
			SendChatMessage( "<DiceMaster> " .. name .. " rolls " .. rollstring, channel )
		end
		
		local msg =  name .. " rolls " .. rollstring
		
		PrintSystemMessage( msg )
		Me:SendMessage( "DiceMaster4_Roll", name, msg )
		
	else
		local msg = "You roll " .. rollstring
		PrintSystemMessage( msg )
		Me:SendMessage( "DiceMaster4_Roll", name, msg )
	end 
end

-------------------------------------------------------------------------------
-- Print a vanilla roll.
--
-- @param data serverRoll entry.
--
local function PrintRoll( data )
	if data.handled then 
		-- this roll was handled by the Dice Master system, so we don't print it.
		return
	end
	data.handled = true
	
	local msg = string.format( RANDOM_ROLL_RESULT, data.name, data.roll, data.min, data.max )
	PrintSystemMessage( msg )
	Me:SendMessage( "DiceMaster4_Roll", data.name, msg )
end

-------------------------------------------------------------------------------
-- Purge anything that's gotten too old in a player roll data table.
-- (either serverRolls or rollInfo)
--
local function CleanRollTable( t )
	
	if not t then return end
	
	local time = GetTime()
	
	while t[1] and time > t[1].time + CLEAN_TIME do
		table.remove( t, 1 )
	end
end

-------------------------------------------------------------------------------
-- Scan through roll data and see if we have a match between addon roll hints
-- and server rolls.
--
-- @param name Name of player to check.
--
local function CheckRolls( name )

	local rollInfo    = playerRollInfo[name]
	local serverRolls = playerServerRolls[name]
	
	-- purge anything older than the cleaning time
	CleanRollTable( rollInfo  )
	CleanRollTable( serverRolls )
	
	if not rollInfo or not rollInfo[1] then return end
	if not serverRolls or not serverRolls[1] then return end
	 
	while rollInfo[1] do
		local r = rollInfo[1]
		local rolls = {} -- this is a collection of the server roll values
		
		for i = 1, r.count do
			if not serverRolls[i] then 
				return  -- we need to wait for more rolls
			end 
			
			table.insert( rolls, serverRolls[i].roll )
			
			if serverRolls[i].min ~= r.min or serverRolls[i].max ~= r.max then
				-- mismatch in expected data, throw it away
				for i2 = 1, i do
					PrintRoll( serverRolls[1] )
					table.remove( serverRolls, 1 )
				end
				
				rolls = nil
				break -- and then start over.
			end
		end
		
		if rolls then
			-- got our rolls!
			
			-- remove from the table and print
			if r.v then
				-- vanilla roll
				PrintRoll( serverRolls[1] )
				table.remove( serverRolls, 1 )
			else
				
				for i = 1, r.count do
					serverRolls[1].handled = true
					table.remove( serverRolls, 1 )
				end
				table.remove( rollInfo, 1 )
				
				PrintDiceMasterRoll( name, r.count, r.max, r.mod, rolls, true )
			end
		end
	end
end

-------------------------------------------------------------------------------
-- Record player roll info from a Dice Master roll command. (Locally or
--   over the network.)
--
local function AddRollInfo( name, count, min, max, mod, vanilla )
	playerRollInfo[name] = playerRollInfo[name] or {}
	
	local data = {
		count = count or 1;
		min   = min or 1;
		max   = max or 100;
		mod   = mod or 0;
		v     = vanilla;
		time  = GetTime();
	}
	
	table.insert( playerRollInfo[name], data ) 
	CheckRolls( name ) 
end

-------------------------------------------------------------------------------
-- Record a server /roll command result.
--
local function AddServerRoll( name, roll, min, max )
	playerServerRolls[name] = playerServerRolls[name] or {}
	 
	local data = {
		name    = name;
		roll    = roll;
		min     = min;
		max     = max;
		time    = GetTime();
		handled = false;
	}

	C_Timer.After( ROLL_TIMEOUT, function()
		PrintRoll( data )
	end)
	
	table.insert( playerServerRolls[name], data )
	CheckRolls( name )  
end

local function SendRollMessage( count, min, max, mod, vanilla )


	if IsInGroup()  then
		local data = {}
		if count and count ~= 1 then data.c = count end
		if min and min ~= 1 then data.a = min end
		if max and max ~= 100 then data.b = max end
		if mod and mod ~= 0 then data.m = mod end
		if vanilla then data.v = true end
		
		local msg = Me:Serialize( "R", data )
		
		-- We don't use AceComm here because this is really sensitive on timing
		-- The message is small so it shouldn't cause connection instability.

		SendAddonMessage( "DCM4", msg, "RAID" )
	end
	
	AddRollInfo( UnitName("player"), count, min, max, mod, vanilla )
end
 
-------------------------------------------------------------------------------
-- Do a roll.
--
-- @param dice Dice format, e.g. 2d6+1, d20, 4D4-2
--
function Me.Roll( dice )
	
	local function UIError( msg )
		-- helper function to throw errors.
		UIErrorsFrame:AddMessage( msg, 1.0, 0.0, 0.0, 53, 5 ); 
	end
	
	if type( dice ) ~= "string" then 
		return UIError( "Invalid dice format." )
	end
	
	local count, sides, modtype, mod = dice:match("^%s*(%d*)[dD](%d+)([+-]?)(%d*)%s*$")
	
	if not count then return UIError( "Invalid dice format." ) end
	
	-- some sanitizing
	count   = count   == "" and 1 or tonumber(count)
	sides   = sides   == "" and 20 or tonumber(sides)
	modtype = modtype == "" and "+" or modtype
	mod     = mod     == "" and 0 or tonumber(mod)
	
	if count == 0 then    return UIError( "You must have at least one die." )              end 
	if count > 10 then    return UIError( "You can only roll 10 dice at a time." )         end 
	if sides < 2 then     return UIError( "Must have at least two sides." )                end 
	if sides > 13476 then return UIError( "Dice cannot have more than 13476 sides." ) end
	
	if modtype == "-" then
		mod = -mod
	end
	
	SendRollMessage( count, 1, sides, mod )
	
	doingDiceMasterRoll = true
	
	-- Request rolls from server . . .
	--
	for i = 1, count do
		RandomRoll( 1, sides )
	end
	 
	doingDiceMasterRoll = false
end
 
-- test results:
-- addon messages are received independently from roll order

-------------------------------------------------------------------------------
local function RollFilter( self, event, msg, sender, ... )
	-- Filter out system roll messages
	-- They're added again later if we know that they're not associated
	-- with a Dice Master ROLL message.
	 
	if msg:match( SYSTEM_ROLL_PATTERN ) then
		return true
	end 
	
	return false
end

-------------------------------------------------------------------------------
local function RollPartyFilter( self, event, msg, ... )
	-- If we have Dice Master installed, hide all roll raid messages
	--
	if msg:match( "^<DiceMaster> %S+ rolls" ) then
	
		if Me.db.char.showRaidRolls then
			msg = "|cffffff00" .. msg:sub( 15 ) .. "|r"
			return false, msg, ...
		end
		return true
	end
	
	return false
end

-------------------------------------------------------------------------------
local function OnSystemMessage( message ) 
	
	local sender, roll, min, max = message:match( SYSTEM_ROLL_PATTERN )
	
	if sender then
		-- this is a roll message
		
		AddServerRoll( sender, tonumber(roll), tonumber(min), tonumber(max) )

		return true
	end 
end

-------------------------------------------------------------------------------
-- Hook for /roll command.
--
local function OnRandomRoll( min, max )
 
	if not doingDiceMasterRoll then
		-- we want to create a ROLL message for direct usage too.
		SendRollMessage( 1, min, max, 0, true )
	end
end

-------------------------------------------------------------------------------
-- Handler for ROLL messages.
--
function Me.Dice_OnRollMessage( data, dist, sender )

	if sender == UnitName("player") then return end
	AddRollInfo( sender, data.c, data.a, data.b, data.m, data.v )
end

-------------------------------------------------------------------------------
function Me.Dice_Init()
	ChatFrame_AddMessageEventFilter( "CHAT_MSG_SYSTEM",       RollFilter )
	ChatFrame_AddMessageEventFilter( "CHAT_MSG_PARTY",        RollPartyFilter )
	ChatFrame_AddMessageEventFilter( "CHAT_MSG_PARTY_LEADER", RollPartyFilter )
	ChatFrame_AddMessageEventFilter( "CHAT_MSG_RAID",         RollPartyFilter )
	ChatFrame_AddMessageEventFilter( "CHAT_MSG_RAID_LEADER",  RollPartyFilter )
	
	local f = CreateFrame("Frame")
	f:RegisterEvent( "CHAT_MSG_SYSTEM" )
	f:SetScript( "OnEvent", function( self, event, msg )

		if event == "CHAT_MSG_SYSTEM" then
			OnSystemMessage( msg )
		end
	end)
	
	hooksecurefunc( "RandomRoll", OnRandomRoll ) 
end
