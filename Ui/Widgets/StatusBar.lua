-------------------------------------------------------------------------------
-- Dice Master (C) 2017 <The League of Lordaeron> - Moon Guard
-------------------------------------------------------------------------------

local Me = DiceMaster4

-------------------------------------------------------------------------------
local function UpdateFilled( self )
	if self.filled == 0 then
		self.bar:Hide()
	else
		self.bar:Show()
		self.bar:SetWidth( self.filled * self:GetHeight() )
	end
end

-------------------------------------------------------------------------------
local methods = {
	SetMax = function( self, max )
		if max < 0 or max > 20 then error( "Invalid max value." ) end
		
		self.filled_max = max  
		self.filled     = math.min( self.filled, max )
		
		self:RefreshFrame()
	end;
	
	SetFilled = function( self, filled )
		self.filled = math.min( self.filled_max, filled )
		UpdateFilled( self )
	end;
	
	RefreshFrame = function( self )
		self:SetWidth( self.filled_max * self:GetHeight() )
		UpdateFilled( self )
	end;
	
	SetTexture = function( self, tex, r, g, b )
		self.bar:SetTexture( tex, true, false )
		self.bar:SetVertexColor( r or 1, g or 1, b or 1, 1 )
		
		self.barback:SetTexture( tex, true, false  )
		self.barback:SetVertexColor( r or 1, g or 1, b or 1, 0.3 ) 
	end;
}

-------------------------------------------------------------------------------
function Me.StatusBar_Init( self )

	for k, v in pairs( methods ) do
		self[k] = v
	end
	
	self.bar:SetHorizTile( true )
	self.barback:SetHorizTile( true )
	
	self.filled = 1
	self:SetMax(1) 
end

