-------------------------------------------------------------------------------
-- Dice Master (C) 2019 <The League of Lordaeron> - Moon Guard
-------------------------------------------------------------------------------

-- comm message handling

local Me = DiceMaster4 

-------------------------------------------------------------------------------
-- Routing table for DCM4 addon messages.
--
local MessageHandlers = {
 
	INSP    = "Inspect_OnInspectMessage";
	TRAIT   = "Inspect_OnTraitMessage";
	STATUS  = "Inspect_OnStatusMessage";
	STATS   = "Inspect_OnStatsMessage";
	APPROVE = "Inspect_OnTraitApprove";
	EXP     = "Inspect_OnExperience";
	SETHP   = "Inspect_OnSetHPMessage";
	
	R       = "Dice_OnRollMessage";
	ROLL    = "Dice_OnRollMessage";
	
	ITEM    = "LootToast_OnToast";
	
	TYPE    = "PostTracker_OnTyping";
	
	TARGET  = "RollTracker_OnTargetMessage";
	NOTES   = "RollTracker_OnNoteMessage";
	NOTREQ  = "RollTracker_OnStatusRequest";
	MAPNODES  = "RollTracker_OnMapNodesMessage";
	MAPREQ  = "RollTracker_OnMapNodesRequest";
	
	BANNER  = "RollBanner_OnBanner";
	
	BUFF    = "BuffFrame_OnBuffMessage";
	REMOVE  = "BuffFrame_OnRemoveBuffMessage";
	
	SOUND   = "SoundPicker_OnSoundMessage";
	EFFECT  = "OnFullscreenEffectMessage";
	
	MORALE  = "MoraleBar_OnStatusMessage";
	MORREQ  = "MoraleBar_OnStatusRequest";
	
	UFANIM  = "UnitFrame_OnAnimationMessage";
	DMSAY   = "UnitFrame_OnDMSAY";
	UFSTAT  = "UnitFrame_OnStatusMessage";
	UFREQ   = "UnitFrame_OnStatusRequest";
	UFBUFF	= "UnitFrame_OnBuffMessage";
	UFREMOVE = "UnitFrame_OnRemoveBuffMessage";
}

-------------------------------------------------------------------------------
-- Comm Handler for when an DCM4 message is received.
--
function Me:OnCommMessage( prefix, packed_message, dist, sender )
	local success, msgtype, data = Me:Deserialize( packed_message )
	
	if not success then return end
	
	if sender:find("-") then
		-- this is the best xrealm support ur gonna get :)
		sender = sender:match( "(.+)%-")
	end
	
	if dist == "RAID" and IsInGroup( LE_PARTY_CATEGORY_INSTANCE ) and IsInGroup( LE_PARTY_CATEGORY_HOME ) then
		-- Prevents "You are not in a raid group" spam.
		dist = "PARTY";
	end
	
	local handler = MessageHandlers[msgtype]
	if Me[handler] then
		Me[handler]( data, dist, sender )
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
	if not data.na and not data.md and not data.ms then
	   
		return
	end
	
	if ( UnitIsGroupLeader( sender ) or UnitIsGroupAssistant( sender ) ) and not DiceMasterTalkingHeadFrame then
		Me.PrintMessage("|cFFE6E68E"..(data.na or "Unknown").." says: "..data.ms, "RAID")
	end
end

---------------------------------------------------------------------------
-- Received a fullscreen effect request.
--	sv = spellVisualKitID				number
--	po = position ( x, y, z )			table
--  so = sound							number

function Me.ResetFullscreenEffect()
	local model = DiceMasterFullscreenEffectFrame.Model
	model:ClearModel()
	model:SetDisplayInfo( 6908 )
	model:SetPosition( -20, 9.7, 1 )
	model:SetLight( true, true, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 );
end

function Me.OnFullscreenEffectMessage( data, dist, sender )
	-- sanitize message
	if not data.sv or not Me.db.global.allowEffects then
	   
		return
	end
	
	if ( UnitIsGroupLeader( sender ) or UnitIsGroupAssistant( sender ) or Me.IsLeader( false ) ) then
		Me.ResetFullscreenEffect()
		DiceMasterFullscreenEffectFrame.Model:SetSpellVisualKit( data.sv );
		if ( data.po and data.po.x and data.po.y and data.po.z ) then
			DiceMasterFullscreenEffectFrame.Model:SetPosition( data.po.x, data.po.y, data.po.z );
		else
			DiceMasterFullscreenEffectFrame.Model:SetPosition( -20, 9.7, 1 );
		end
		if ( data.so ) then
			PlaySound( data.so )
		end
	end
end

-------------------------------------------------------------------------------
function Me.Comm_Init() 
	Me:RegisterComm( "DCM4", "OnCommMessage" ) 
end
