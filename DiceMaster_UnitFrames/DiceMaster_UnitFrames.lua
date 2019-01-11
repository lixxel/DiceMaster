-------------------------------------------------------------------------------
-- Dice Master (C) 2017 <The League of Lordaeron> - Moon Guard
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Main module.
--

local VERSION = GetAddOnMetadata( "DiceMaster", "Version" )
local Me = DiceMaster4
Me.version = VERSION
Me.Profile = {}

-------------------------------------------------------------------------------
-- Profile is a shortcut to Me.db.profile
setmetatable( Me.Profile, { 

	__index = function( table, key ) 
		return Me.db.profile[key]
	end;
	
	__newindex = function( table, key, value )
		Me.db.profile[key] = value
	end;
})

local Profile = Me.Profile
local wasLeader = false;

------------------------------------------------------------------------

local frame = CreateFrame("FRAME");
frame:RegisterEvent("ADDON_LOADED");
frame:RegisterEvent("GROUP_ROSTER_UPDATE");
frame:RegisterEvent("GROUP_LEFT");
frame:RegisterEvent("ZONE_CHANGED_NEW_AREA");

function frame:OnEvent(event, arg1, ...)
	if event == "ADDON_LOADED" and arg1 == "DiceMaster_UnitFrames" then
		DiceMaster4UF_Saved = DiceMaster4UF_Saved or {}
		if DiceMaster4UF_Saved.VisibleFrames == 0 then DiceMaster4UF_Saved.VisibleFrames = 1 end

		if IsInGroup(1) and not Me.IsLeader( false ) then
			DiceMasterUnitsPanel:Hide()
			for i=1, MAX_RAID_MEMBERS do
				local name, rank = GetRaidRosterInfo(i)
				if UnitIsGroupLeader( name ) then
					local msg = Me:Serialize( "UFREQ", "request")
					Me:SendCommMessage( "DCM4", msg, "WHISPER", name, "ALERT" )
					break
				end
			end
		else
			Me.UpdateUnitFrames(1)
		end
		
		Me.DMSAY_Init()
	end
	if event == "GROUP_ROSTER_UPDATE" and IsInGroup(1) and UnitIsGroupLeader("player") then
		wasLeader = true;
		Me.UpdateUnitFrames()
	end
	if event == "GROUP_LEFT" and not IsInGroup(1) and Me.IsLeader( false ) then
		if wasLeader then
			wasLeader = false;
			return
		end
		local unitframes = DiceMasterUnitsPanel.unitframes
		for i=1,#unitframes do
			unitframes[i]:ClearModel()
			unitframes[i]:Reset()
			unitframes[i]:Hide()
		end
		Me.UpdateUnitFrames(1)
		Me.enableMessageUF = true;
		Me.PrintMessage("|TInterface/AddOns/DiceMaster/Texture/logo:12|t Unit Frames disabled.", "SYSTEM")
	end
	if event == "ZONE_CHANGED_NEW_AREA" then
		for i=1,#DiceMasterUnitsPanel.unitframes do
			DiceMasterUnitsPanel.unitframes[i]:SetBackground()
		end
	end
end

frame:SetScript("OnEvent", frame.OnEvent);

function Me.ApplyUiScaleUF()
	DiceMasterUnitsPanel:SetScale( Me.db.char.unitframes.scale * 1.4 )
	DiceMasterAffixEditor:SetScale( Me.db.char.unitframes.scale * 1.4 )
	DiceMasterUnitPicker:SetScale( Me.db.char.unitframes.scale * 1.4 )
	
	for i = 1,#DiceMasterUnitsPanel.unitframes do
		DiceMasterUnitsPanel.unitframes[i]:Collapse( Me.db.global.miniFrames )
	end
end

function Me.ShowUnitPanel( show )
	Me.db.char.unitframes.enable = not show
	
	if not show then
		DiceMasterUnitsPanel:Hide()
		if Me.IsLeader( true ) then
			Me.UnitFrame_SendStatus( 0, 1 )
		end
	else
		DiceMasterUnitsPanel:Show()
		if Me.IsLeader( true ) then
			Me.UpdateUnitFrames()
		end
	end

end
