-------------------------------------------------------------------------------
-- Dice Master (C) 2019 <The League of Lordaeron> - Moon Guard
-------------------------------------------------------------------------------

--
-- Talking head frame for dynamic dialogue.
--

local Me = DiceMaster4

Me.soundKitID = nil

function Me.DMSAY_Init()
	SLASH_DMSAY1       = '/dmsay';
	SLASH_DMSOUND1	   = '/dmsound';
end

-------------------------------------------------------------------------------
-- /dmsay
--
function SlashCmdList.DMSAY( msg, editBox )
	
	if msg == "" then
		-- show usage
		Me.PrintMessage("/dmsay (message)", "SYSTEM")
		Me.PrintMessage("Ctrl+Left Click a unit to choose who is talking. Then use the '/dmsay' command to make them speak.", "SYSTEM")
		return
	end
	
	if Me.IsLeader( true ) then
		DiceMasterTalkingHeadFrame_Init( msg )
	end
end 

-------------------------------------------------------------------------------
-- /dmsound
--
function SlashCmdList.DMSOUND( msg, editBox )
	
	if msg == "" then
		-- show usage
		Me.PrintMessage("/dmsound (soundKitID)", "SYSTEM")
		Me.PrintMessage("/dmsound clear", "SYSTEM")
		Me.PrintMessage("Assign a sound kit to play when the '/dmsay' command is used.", "SYSTEM")
		return
	end
	
	if DiceMaster4.IsLeader( false ) then
		if msg == "clear" then
			Me.PrintMessage("Sound kit cleared.", "SYSTEM")
			Me.soundKitID = nil
		else
			Me.PrintMessage("Sound kit loaded: |cFFFFFFFF" .. msg, "SYSTEM")
			Me.soundKitID = tonumber(msg)
		end
	end
end 

function DiceMasterTalkingHeadFrame_OnLoad(self)
	self:SetClampedToScreen( true )
	self:SetMovable(true)
	self:EnableMouse(true)
	self:RegisterForDrag( "LeftButton" )
	self:SetScript( "OnDragStart", self.StartMoving )
	self:SetScript( "OnDragStop", self.StopMovingOrSizing )
	self:SetScale(0.8)
	self:SetUserPlaced( true )
	self:RegisterForClicks("RightButtonUp");

	self.NameFrame.Name:SetPoint("TOPLEFT", self.PortraitFrame.Portrait, "TOPRIGHT", 2, -19);
	self.TextFrame.Text:SetFontObjectsToTry(SystemFont_Shadow_Large, SystemFont_Shadow_Med2, SystemFont_Shadow_Med1);
	
	local alertSystem = AlertFrame:AddExternallyAnchoredSubSystem(self);
	AlertFrame:SetSubSystemAnchorPriority(alertSystem, 0);
end

function DiceMasterTalkingHeadFrame_OnShow(self)
	UIParent_ManageFramePositions();
end

function DiceMasterTalkingHeadFrame_OnHide(self)
	UIParent_ManageFramePositions();
end

function DiceMasterTalkingHeadFrame_CloseImmediately()
	local frame = DiceMasterTalkingHeadFrame;
	if (frame.finishTimer) then
		frame.finishTimer:Cancel();
		frame.finishTimer = nil;
	end
	frame:Hide();
	if (frame.closeTimer) then
		frame.closeTimer:Cancel();
		frame.closeTimer = nil;
	end
end

function DiceMasterTalkingHeadFrame_OnClick(self, button)
	if ( button == "RightButton" ) then
		DiceMasterTalkingHeadFrame_CloseImmediately();
		return true;
	end

	return false;
end

function DiceMasterTalkingHeadFrame_FadeinFrames()
	local frame = DiceMasterTalkingHeadFrame
	frame.MainFrame.TalkingHeadsInAnim:Play();
	C_Timer.After(0.5, function()
		frame.NameFrame.Fadein:Play();
	end);
	C_Timer.After(0.75, function()
		frame.TextFrame.Fadein:Play();
	end);
	frame.BackgroundFrame.Fadein:Play();
	frame.PortraitFrame.Fadein:Play();
end

function DiceMasterTalkingHeadFrame_FadeoutFrames()
	local frame = DiceMasterTalkingHeadFrame
	frame.MainFrame.Close:Play();
	frame.NameFrame.Close:Play();
	frame.TextFrame.Close:Play();
	frame.BackgroundFrame.Close:Play();
	frame.PortraitFrame.Close:Play();
end

function DiceMasterTalkingHeadFrame_Reset(frame, text, name)
	-- set alpha for all animating textures
	frame:StopAnimating();
	frame.BackgroundFrame.TextBackground:SetAlpha(0.01);
	frame.NameFrame.Name:SetAlpha(0.01);
	frame.TextFrame.Text:SetAlpha(0.01);
	frame.MainFrame.Sheen:SetAlpha(0.01);
	frame.MainFrame.TextSheen:SetAlpha(0.01);

	frame.MainFrame.Model:SetAlpha(0.01);
	frame.MainFrame.Model.PortraitBg:SetAlpha(0.01);
	frame.PortraitFrame.Portrait:SetAlpha(0.01);
	frame.MainFrame.Overlay.Glow_LeftBar:SetAlpha(0.01);
	frame.MainFrame.Overlay.Glow_RightBar:SetAlpha(0.01);
	frame.MainFrame.CloseButton:SetAlpha(0.01);

	frame.MainFrame:SetAlpha(1);
	frame.NameFrame.Name:SetText(name);
	frame.TextFrame.Text:SetText(text);
end

function DiceMasterTalkingHeadFrame_SetUnit(modelID, name, sound)
	local frame = DiceMasterTalkingHeadFrame;
	local model = frame.MainFrame.Model;
	model.PortraitImage:Hide()
	
	if type(modelID) == "number" then 
		model:SetDisplayInfo(modelID)
		model:SetPortraitZoom(1)
	elseif type(modelID) == "string" then
		model:SetDisplayInfo(1)
		model.PortraitImage:Show()
		model.PortraitImage:SetTexture(modelID)
	end
	frame.soundKitID = sound or nil;
	frame.NameFrame.Name:SetText(name or "Unknown")
end

function DiceMasterTalkingHeadFrame_PlayCurrent(message)
	if not DiceMasterTalkingHeadFrame:IsShown() then
		local unitframes = DiceMasterUnitsPanel.unitframes; 
		local frame = DiceMasterTalkingHeadFrame;
		local model = frame.MainFrame.Model;
		model.sequence = nil;
		DiceMasterTalkingHeadFrame.animations = {}
		local animIndex = {["."]=60,["!"]=64,["?"]=65}
		
		message:gsub("%p",function(c) table.insert(DiceMasterTalkingHeadFrame.animations,animIndex[c]) end)

		frame:Show();
		
		if not DiceMasterTalkingHeadFrame.animations[1] or model:HasAnimation(DiceMasterTalkingHeadFrame.animations[1])==false then DiceMasterTalkingHeadFrame.animations[1] = 60 end;
		model:SetAnimation(DiceMasterTalkingHeadFrame.animations[1])
		frame.TextFrame.Text:SetText(message)
		local stringHeight = frame.TextFrame.Text:GetStringHeight()/16
		
		Me.PrintMessage("|cFFE6E68E"..(frame.NameFrame.Name:GetText() or "Unknown").." says: "..message, "RAID")
		
		if DiceMasterTalkingHeadFrame.soundKitID then
			PlaySound(DiceMasterTalkingHeadFrame.soundKitID, "Dialog")
		end
		
		DiceMasterTalkingHeadFrame_FadeinFrames()
		frame.finishTimer = C_Timer.After(5+(2*stringHeight), function()
				model:SetAnimation(0)
				DiceMasterTalkingHeadFrame_FadeoutFrames()
				frame.finishTimer = nil;
			end
		);
		frame.closeTimer = C_Timer.After(6+(2*stringHeight), function()
				DiceMasterTalkingHeadFrame:Hide();
				frame.closeTimer = nil;
			end
		);
	end
end

function DiceMasterTalkingHeadFrame_Init(message)
	local unitframes = DiceMasterUnitsPanel.unitframes; 
	
	for i=1,#unitframes do
		if unitframes[i].speaker then
			local framedata = unitframes[i]:GetData()
			local model = framedata.model
			if framedata.name=="" then framedata.name = "Unknown" end;
			local name = framedata.name
			local sound = Me.soundKitID
			DiceMasterTalkingHeadFrame_SetUnit(model, name, sound);
			DiceMasterTalkingHeadFrame_PlayCurrent(message)
			
			local msg = Me:Serialize( "DMSAY", {
				na = tostring( name );
				md = tonumber( model );
				ms = tostring( message );
				so = tonumber( sound );
			})
			
			Me:SendCommMessage( "DCM4", msg, "RAID", nil, "ALERT" )
			break
		end
	end
end
