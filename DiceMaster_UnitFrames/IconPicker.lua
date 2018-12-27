-------------------------------------------------------------------------------
-- Dice Master (C) 2017 <The League of Lordaeron> - Moon Guard
-------------------------------------------------------------------------------

--
-- Icon picker interface.
--

local Me = DiceMaster4

local startOffset = 0
local filteredList = nil

-------------------------------------------------------------------------------
-- When one of the icon buttons are clicked.
--
function Me.UFIconPickerButton_OnClick( self )

	-- Apply the icon to the edited affix and close the picker. 
	Me.AffixEditor_SelectIcon( self:GetNormalTexture():GetTexture() ) 
	PlaySound(54129)
	Me.UFIconPicker_Close()
end

-------------------------------------------------------------------------------
-- OnEnter handler, to magnify the icon and show the texture path.
--
function Me.UFIconPickerButton_ShowTooltip( self )
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	
	local texture = self:GetNormalTexture():GetTexture()
    GameTooltip:AddLine( "|T"..texture..":64|t", 1, 1, 1, true )
    GameTooltip:AddLine( texture, 1, 0.81, 0, true )
    GameTooltip:Show()
end

-------------------------------------------------------------------------------
-- When the mousewheel is used on the icon map.
--
function Me.UFIconPicker_MouseScroll( delta )

	local a = DiceMasterUFIconPicker.selectorFrame.scroller:GetValue() - delta
	-- todo: do we need to clamp?
	DiceMasterUFIconPicker.selectorFrame.scroller:SetValue( a )
end
   
-------------------------------------------------------------------------------
-- When the scrollbar's value is changed.
--
function Me.UFIconPicker_ScrollChanged( value )
	
	-- Our "step" is 6 icons, which is one line.
	startOffset = math.floor(value) * 6
	Me.UFIconPicker_RefreshGrid()
end

-------------------------------------------------------------------------------
-- Set the textures of the icon grid from the icons in the list at the
-- current offset.
--
function Me.UFIconPicker_RefreshGrid()
	local list = filteredList or Me.iconList
	for k,v in ipairs( DiceMasterUFIconPicker.icons ) do
		 
		local tex = list[startOffset + k]
		if tex then
			v:Show()
			if tex:find( "AddOns/" ) then
				tex = "Interface/" .. tex
			else
				tex = "Interface/Icons/" .. tex
			end
			
			v:SetNormalTexture( tex )
				
		else
			v:Hide()
		end
	end
end

-------------------------------------------------------------------------------
-- Called when the user types into the search box.
--
function Me.UFIconPicker_FilterChanged()
	local filter = DiceMasterUFIconPicker.search:GetText():lower()
	if #filter < 3 then
		-- Ignore filters less than three characters
		if filteredList then
			filteredList = nil
			Me.UFIconPicker_RefreshScroll()
			Me.UFIconPicker_RefreshGrid()
		end
	else
		-- build new list
		filteredList = {}
		for k,v in ipairs( Me.iconList ) do
			if v:lower():find( filter ) then
				table.insert( filteredList, v )
			end	
		end
		Me.UFIconPicker_RefreshScroll()
	end
end

-------------------------------------------------------------------------------
-- When we change the size of the list, update the scroll bar range.
--
-- @param reset Reset the scroll bar to the beginning.
--
function Me.UFIconPicker_RefreshScroll( reset )
	local list = filteredList or Me.iconList 
	local max = math.floor((#list - 24) / 6)
	if max < 0 then max = 0 end
	DiceMasterUFIconPicker.selectorFrame.scroller:SetMinMaxValues( 0, max )
	
	if reset then
		DiceMasterUFIconPicker.selectorFrame.scroller:SetValue( 0 )
	end
	-- todo: does scroller auto clamp value?
	
	Me.UFIconPicker_ScrollChanged( DiceMasterUFIconPicker.selectorFrame.scroller:GetValue() )
end
    
-------------------------------------------------------------------------------
-- Close the icon picker window. Use this instead of a direct Hide()
--
function Me.UFIconPicker_Close()

	-- unhighlight the traitIcon button.
	--Me.editor.traitIcon:Select( false )
	DiceMasterUFIconPicker:Hide()
end
    
-------------------------------------------------------------------------------
-- Open the icon picker window.
--
function Me.UFIconPicker_Open()
	--Me.editor.traitIcon:Select( true )
	filteredList = nil
	
	Me.UFIconPicker_RefreshScroll( true )
	DiceMasterUFIconPicker.search:SetText("")
	DiceMasterUFIconPicker:Show()
end
