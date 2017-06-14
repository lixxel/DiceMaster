-------------------------------------------------------------------------------
-- Dice Master (C) 2017 <The League of Lordaeron> - Moon Guard
-------------------------------------------------------------------------------

-- comm message handling

local Me = DiceMaster4 

-------------------------------------------------------------------------------
-- Routing table for DCM4 addon messages.
--
local MessageHandlers = {
 
	INSP   = "Inspect_OnInspectMessage";
	TRAIT  = "Inspect_OnTraitMessage";
	STATUS = "Inspect_OnStatusMessage";
	
	R      = "Dice_OnRollMessage";
	ROLL   = "Dice_OnRollMessage";
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
	
	local handler = MessageHandlers[msgtype]
	if Me[handler] then
		Me[handler]( data, dist, sender )
	end
end

-------------------------------------------------------------------------------
function Me.Comm_Init() 
	Me:RegisterComm( "DCM4", "OnCommMessage" ) 
end