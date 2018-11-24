-------------------------------------------------------------------------------
-- Dice Master (C) 2017 <The League of Lordaeron> - Moon Guard
-------------------------------------------------------------------------------

--
-- Chat commands.
--

local Me = DiceMaster4
local Profile = Me.Profile

-------------------------------------------------------------------------------
function Me.Console_Init()
	SLASH_DICE1       = '/dice';
	SLASH_DICEMASTER1 = '/dicemaster';
end

-------------------------------------------------------------------------------
-- /dice
--
function SlashCmdList.DICE( msg, editBox )
	
	if msg == "" then
		-- show usage
		print("|cFFFFFF00/dice XDY[+/-]Z");
		print("|cFFFFFF00- X is how many dice to roll.");
		print("|cFFFFFF00- Y is how many sides those dice have.");
		print("|cFFFFFF00- Z is how much you add/subtract from the total after adding up all the dice.");
		return
	end
	
	Me.Roll( msg ) 
end 

-------------------------------------------------------------------------------
-- /dicemaster
--
function SlashCmdList.DICEMASTER(msg, editbox)
	local command, rest = msg:match("^(%S*)%s*(.-)$");
	command = command:lower()
	
	
	if command == "config" then
	
		Me.OpenConfig()
		
	elseif command == "scale" then
	
		rest = tonumber(rest)
		if rest then
			rest = Me.Clamp( rest, 0.25, 10 )
			Me.db.char.uiScale = rest
			Me.ApplyUiScale() 
		end
		
	elseif command == "show" then
	
		Me.ShowPanel( true )
		
	elseif command == "hide" then
	
		Me.ShowPanel( false )
		
	elseif command == "reset" then
	
		DiceMasterInspectFrame:ClearAllPoints()
		DiceMasterInspectFrame:SetPoint( "CENTER", 0, 0 )
		
	elseif command == "charges" then
	
		if rest:lower() == "show" then
			Profile.charges.enable = true;
			Me.OnChargesChanged()
		elseif rest:lower() == "hide" then
			Profile.charges.enable = false;
			Me.OnChargesChanged()
		end
		
	elseif command == "chargesname" and rest ~= "" then
	
		Profile.charges.name = rest
		Me.OnChargesChanged()
		
		Me.TraitEditor_Refresh()
		
	elseif command == "maxcharges" then
		
		rest = tonumber(rest)
		if not rest or rest < 1 or rest > 8 then return end
		
		Profile.charges.max = rest
		Profile.charges.count = math.min( Profile.charges.count, Profile.charges.max )
		Me.OnChargesChanged()
		 
	elseif command == "chargescolor" then
	
		local r, g, b = string.match( rest, "(%d+%.?%d*)%s+(%d+%.?%d*)%s+(%d+%.?%d*)")
		r = tonumber(r)
		g = tonumber(g)
		b = tonumber(b)
		
		if r and g and b then
			Profile.charges.color = { r, g, b }
			Me.OnChargesChanged()
		end
	elseif command == "showraidrolls" then
		if rest:lower() == "true" then
			Me.db.char.showRaidRolls = true
		else
			Me.db.char.showRaidRolls = false
		end
	elseif command == "tracker" then
	
		if rest:lower() == "show" then
			Me.db.global.hideTracker = true
			DiceMasterRollFrame:Show()
		elseif rest:lower() == "hide" then
			Me.db.global.hideTracker = false
			DiceMasterRollFrame:Hide()
		end
	else
		print("|cFFFFFF00- /dicemaster config");
		print("|cFFFFFF00- /dicemaster scale (number)");
		print("|cFFFFFF00- /dicemaster (show || hide)");
		print("|cFFFFFF00- /dicemaster charges (show || hide)");
		print("|cFFFFFF00- /dicemaster chargesname (name)");
		print("|cFFFFFF00- /dicemaster maxcharges (number)");
		print("|cFFFFFF00- /dicemaster chargescolor (r g b)");
		print("|cFFFFFF00- /dicemaster showraidrolls (true || false)");
		print("|cFFFFFF00- /dicemaster tracker (show || hide)");
		print("|cFFFFFF00- /dicemaster reset");
	end
end 
