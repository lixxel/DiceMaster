-------------------------------------------------------------------------------
-- Dice Master (C) 2018 <The League of Lordaeron> - Moon Guard
-------------------------------------------------------------------------------

-- comm message handling

local Me = DiceMaster4 

---------------------------------------------------------------------------
-- Send a status request.
--
-- @param channel Whisper target or channel name.
--

function Me.UnitFrame_SendStatus( visibleframes, id, status )
	local statusFrames = visibleframes
	local statusID	   = id
	local statusName   = status.name
	local statusModel  = status.model
	local statusAnim   = status.animation
	local statusSVK    = status.spellvisualkit
	local statusSymbol = status.symbol
	local statusHealth = status.healthCurrent
	local statusMaxHealth = status.healthMax
	local statusArmor = status.armor
	local statusVisible = status.visible
	local statusAffix	= status.affix
	
	local msg = Me:Serialize( "UFSTAT", {
		vf = tonumber( statusFrames );
		id = tonumber( statusID );
		na = tostring( statusName );
		md = tonumber( statusModel );
		an = tonumber( statusAnim );
		svk = tonumber( statusSVK );
		sy = tonumber( statusSymbol );
		hc = tonumber( statusHealth );
		hm = tonumber( statusMaxHealth );
		ar = tonumber( statusArmor );
		vs = tostring( statusVisible );
		fx = statusAffix;
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
--  svk = spell visual kit				number
--	sy = symbol							number
--	hc = current health					number
--  hm = max health						number
--  ar = armour							number
-- 	vs = visible						boolean
--  fx = monster affix					table

function Me.UnitFrame_OnStatusMessage( data, dist, sender )	
	-- Ignore our own data.
	if sender == UnitName( "player" )  then return end
 
	-- sanitize message
	if not data.vf and not data.id and not data.na and not data.md and not data.sy and not data.hc and not data.hm then
	   
		return
	end

	
	if UnitIsGroupLeader( sender ) or UnitIsGroupAssistant( sender ) then
		Me.ShowUnitPanel( true )
		local unitframes = DiceMasterUnitsPanel.unitframes
		
		unitframes[data.id]:SetData( data )
		
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
	if sender == UnitName( "player" )  then return end
	
	if Me.IsLeader( false ) and IsInGroup(1) then		
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
	if sender == UnitName( "player" )  then return end
 
	-- sanitize message
	if not data.na and not data.md and not data.ms then
	   
		return
	end

	
	if ( UnitIsGroupLeader( sender ) or UnitIsGroupAssistant( sender ) ) then
		if Me.db.global.talkingHeads then
			DiceMasterTalkingHeadFrame_SetUnit(data.md, data.na, data.so)
			DiceMasterTalkingHeadFrame_PlayCurrent(data.ms)
		else
			print("|cFFE6E68E"..(data.na or "Unknown").." says: "..data.ms)
		end
	end
end
