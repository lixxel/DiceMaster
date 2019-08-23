-------------------------------------------------------------------------------
-- Dice Master (C) 2019 <The League of Lordaeron> - Moon Guard
-------------------------------------------------------------------------------

-- comm message handling

local Me = DiceMaster4 

---------------------------------------------------------------------------
-- Send a status request.
--
-- @param channel Whisper target or channel name.
--

function Me.UnitFrame_SendStatus( visibleframes, id, status )
	
	if IsInGroup( LE_PARTY_CATEGORY_INSTANCE ) then
		return
	end
	
	if not status then
		local msg = Me:Serialize( "UFSTAT", {
			vf = tonumber( 0 );
		})
		
		Me:SendCommMessage( "DCM4", msg, "RAID", nil, "NORMAL" )
		return
	end
	
	local statusFrames = visibleframes
	local statusID	   = id
	local statusName   = status.name
	local statusModel  = status.model
	local statusAnim   = status.animation
	local statusModelData = status.modelData
	local statusSounds = status.sounds
	local statusSymbol = status.symbol
	local statusHealth = status.healthCurrent
	local statusMaxHealth = status.healthMax
	local statusArmor = status.armor
	local statusVisible = status.visible
	local statusBlood = status.bloodEnabled
	local statusBuffs = status.buffs
	local statusZone = status.zone
	local statusContinent = status.continent
	
	local msg = Me:Serialize( "UFSTAT", {
		vf = tonumber( statusFrames );
		id = tonumber( statusID );
		na = tostring( statusName );
		md = tonumber( statusModel );
		an = tonumber( statusAnim );
		mx = statusModelData;
		sd = statusSounds;
		sy = tonumber( statusSymbol );
		hc = tonumber( statusHealth );
		hm = tonumber( statusMaxHealth );
		ar = tonumber( statusArmor );
		vs = tostring( statusVisible );
		bl = statusBlood;
		buffs = statusBuffs;
		zo = tostring( statusZone );
		co = tostring( statusContinent );
	})
	
	Me:SendCommMessage( "DCM4", msg, "RAID", nil, "NORMAL" )
end

---------------------------------------------------------------------------
-- Received a status update.
--  vf = # of visible frames			number
--	id = id								number
--  na = name							string
--  st = visibility state				number
--	md = model							number
--  an = model animation				number
--  mx = {								table
--		mx.px = position x				number
--		mx.py = position y				number
--		mx.pz = position z				number
--		mx.ro = rotation				number
--		mx.zl = zoom level				number
--  }
--  sd = sounds							table
--  svk = spell visual kit				number
--	sy = symbol							number
--	hc = current health					number
--  hm = max health						number
--  ar = armour							number
-- 	vs = visible						boolean
--  buffs = buffs						table
--  zo = zone							string
--  co = continent						string

function Me.UnitFrame_OnStatusMessage( data, dist, sender )	
	-- Ignore our own data.
	if sender == UnitName( "player" ) or Me.db.char.unitframes.enable then return end
 
	if UnitIsGroupLeader( sender ) and data.vf and data.vf == 0 then
		local unitframes = DiceMasterUnitsPanel.unitframes
		
		DiceMasterUnitsPanel:Hide()
		for i=data.vf+1,#unitframes do
			unitframes[i]:ClearModel()
			unitframes[i]:Reset()
		end
		return
	end
 
	-- sanitize message
	if not data.vf and not data.id and not data.na and not data.md and not data.sy and not data.hc and not data.hm then
	   
		return
	end
	
	if UnitIsGroupLeader( sender ) then
		local unitframes = DiceMasterUnitsPanel.unitframes
		
		unitframes[data.id]:SetData( data )
		
		DiceMasterUnitsPanel:Show()
		for i=data.vf+1,#unitframes do
			unitframes[i]:ClearModel()
			unitframes[i]:Reset()
			unitframes[i]:Hide()
		end
		
		Me.UpdateUnitFrames( data.vf )
	end
end

---------------------------------------------------------------------------
-- Received a status request.

function Me.UnitFrame_OnStatusRequest( data, dist, sender )	
	-- Ignore our own data.
	if sender == UnitName( "player" ) then return end
	
	if Me.IsLeader( false ) and IsInGroup( LE_PARTY_CATEGORY_HOME ) and not IsInGroup( LE_PARTY_CATEGORY_INSTANCE ) and not Me.db.char.unitframes.enable then		
		Me.UpdateUnitFrames()
	end
end

---------------------------------------------------------------------------
-- Received a talking head request.
--  na = name							string
--	md = model							number
-- 	ms = message						string
--  so = sound							number

function Me.UnitFrame_OnDMSAY( data, dist, sender )	
	-- Ignore our own data.
	if sender == UnitName( "player" ) then return end
 
	-- sanitize message
	if not data.na or not data.md or not data.tk or not data.ms then
	   
		return
	end

	
	if ( UnitIsGroupLeader( sender ) or UnitIsGroupAssistant( sender ) ) then
		if Me.db.global.talkingHeads then
			DiceMasterTalkingHeadFrame_SetUnit(data.md, data.na, data.tk, data.so)
			DiceMasterTalkingHeadFrame_PlayCurrent(data.ms)
		else
			Me.PrintMessage("|cFFE6E68E"..(data.na or "Unknown").." says: "..data.ms, "RAID")
		end
	end
end

---------------------------------------------------------------------------
-- Received a buff request.
--  un = unitframe 						number
--  na = name							string
--	ic = icon							string
-- 	de = description					string
--  st = stackable						boolean
--  co = count							number
--  du = duration						number

function Me.UnitFrame_OnBuffMessage( data, dist, sender )
	-- Only accept buffs if we're the DM.
	if not Me.IsLeader( false ) or not IsInGroup( LE_PARTY_CATEGORY_HOME ) or IsInGroup( LE_PARTY_CATEGORY_INSTANCE ) then return end
 
	-- sanitize message
	if not data.un or data.un > 5 or data.un < 1 or not data.na or not data.ic or not data.de or not data.co then
	   
		return
	end
	
	if not DiceMasterUnitsPanel.unitframes[data.un] then return end
	
	local unitframe = DiceMasterUnitsPanel.unitframes[data.un]
	
	if not unitframe.buffsAllowed then return end
	
	-- search for duplicates
	local found = false
	for i = 1, #unitframe.buffsActive do
		local buff = unitframe.buffsActive[i]
		if buff.name == data.na and buff.sender == sender then
			-- check if buff is stackable
			if not data.st then
				tremove( unitframe.buffsActive, i )
			else
				found = true
				buff.count = buff.count + 1
				buff.expirationTime = (GetTime() + tonumber( data.du or 0 ))
			end
			break
		end		
	end
	
	-- if buff doesn't exist and we have less than 15, apply it
	if not found and #unitframe.buffsActive < 15 then
		local buff = {
			name = tostring(data.na),
			icon = tostring(data.ic),
			description = tostring(data.de),
			count = tonumber(data.co),
			duration = 0,
			sender = sender,
		}
		if data.du then
			buff.duration = tonumber(data.du)
			buff.expirationTime = (GetTime() + tonumber( data.du ))
		end
		tinsert( unitframe.buffsActive, buff )
	end
	for i = 1, #unitframe.buffs do
		Me.UnitFrames_UpdateBuffButton( unitframe, i)
	end
	unitframe.buffFrame:Show()
	Me.UpdateUnitFrames()
end

---------------------------------------------------------------------------
-- Received a buff removal request.
--  un = unitframe						number
--  na = name							string
--  co = count							number

function Me.UnitFrame_OnRemoveBuffMessage( data, dist, sender )
	-- Only accept buffs if we're the DM.
	if not Me.IsLeader( false ) or not IsInGroup( LE_PARTY_CATEGORY_HOME ) or IsInGroup( LE_PARTY_CATEGORY_INSTANCE ) then return end
 
	-- sanitize message
	if not data.un or data.un > 5 or data.un < 1 or not data.na or not data.co then
	   
		return
	end
	
	if not DiceMasterUnitsPanel.unitframes[data.un] then return end
	
	local unitframe = DiceMasterUnitsPanel.unitframes[data.un]
	
	if not unitframe.buffsAllowed then return end
	
	-- search for buff
	for i = 1, #unitframe.buffsActive do
		local buff = unitframe.buffsActive[i]
		if buff.name == data.na and buff.sender == sender then
			-- check if buff stacks
			if buff.count == 1 then
				tremove( unitframe.buffsActive, i )
			else
				buff.count = buff.count - 1
			end
		end		
	end
	for i = 1, #unitframe.buffs do
		Me.UnitFrames_UpdateBuffButton( unitframe, i)
	end
	Me.UpdateUnitFrames()
end