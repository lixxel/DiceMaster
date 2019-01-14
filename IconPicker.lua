-------------------------------------------------------------------------------
-- Dice Master (C) 2019 <The League of Lordaeron> - Moon Guard
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
function Me.IconPickerButton_OnClick( self )
	-- Apply the icon to the edited trait and close the picker. 
	if self:GetParent():GetParent():GetParent() == DiceMasterBuffEditor then
		Me.BuffEditor_SelectIcon( self:GetNormalTexture():GetTexture() ) 
	else
		Me.TraitEditor_SelectIcon( self:GetNormalTexture():GetTexture() ) 
	end
	PlaySound(54129)
	Me.IconPicker_Close()
end

-------------------------------------------------------------------------------
-- OnEnter handler, to magnify the icon and show the texture path.
--
function Me.IconPickerButton_ShowTooltip( self )
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	
	local texture = self:GetNormalTexture():GetTexture()
    GameTooltip:AddLine( "|T"..texture..":64|t", 1, 1, 1, true )
    GameTooltip:AddLine( texture, 1, 0.81, 0, true )
    GameTooltip:Show()
end

-------------------------------------------------------------------------------
-- When the mousewheel is used on the icon map.
--
function Me.IconPicker_MouseScroll( delta )

	local a = DiceMasterIconPicker.selectorFrame.scroller:GetValue() - delta
	-- todo: do we need to clamp?
	DiceMasterIconPicker.selectorFrame.scroller:SetValue( a )
end
   
-------------------------------------------------------------------------------
-- When the scrollbar's value is changed.
--
function Me.IconPicker_ScrollChanged( value )
	
	-- Our "step" is 6 icons, which is one line.
	startOffset = math.floor(value) * 6
	Me.IconPicker_RefreshGrid()
end

-------------------------------------------------------------------------------
-- Set the textures of the icon grid from the icons in the list at the
-- current offset.
--
function Me.IconPicker_RefreshGrid()
	local list = filteredList or Me.iconList
	for k,v in ipairs( DiceMasterIconPicker.icons ) do
		 
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
function Me.IconPicker_FilterChanged()
	local filter = DiceMasterIconPicker.search:GetText():lower()
	if #filter < 3 then
		-- Ignore filters less than three characters
		if filteredList then
			filteredList = nil
			Me.IconPicker_RefreshScroll()
			Me.IconPicker_RefreshGrid()
		end
	else
		-- build new list
		filteredList = {}
		for k,v in ipairs( Me.iconList ) do
			if v:lower():find( filter ) then
				table.insert( filteredList, v )
			end	
		end
		Me.IconPicker_RefreshScroll()
	end
end

-------------------------------------------------------------------------------
-- When we change the size of the list, update the scroll bar range.
--
-- @param reset Reset the scroll bar to the beginning.
--
function Me.IconPicker_RefreshScroll( reset )
	local list = filteredList or Me.iconList 
	local max = math.floor((#list - 24) / 6)
	if max < 0 then max = 0 end
	DiceMasterIconPicker.selectorFrame.scroller:SetMinMaxValues( 0, max )
	
	if reset then
		DiceMasterIconPicker.selectorFrame.scroller:SetValue( 0 )
	end
	-- todo: does scroller auto clamp value?
	
	Me.IconPicker_ScrollChanged( DiceMasterIconPicker.selectorFrame.scroller:GetValue() )
end
    
-------------------------------------------------------------------------------
-- Close the icon picker window. Use this instead of a direct Hide()
--
function Me.IconPicker_Close()

	-- unhighlight the traitIcon button.
	Me.editor.scrollFrame.Container.traitIcon:Select( false )
	DiceMasterBuffEditor.buffIcon:Select( false )
	DiceMasterIconPicker:Hide()
end
    
-------------------------------------------------------------------------------
-- Open the icon picker window.
--
function Me.IconPicker_Open( parent )
	DiceMasterIconPicker:SetParent( parent )
	DiceMasterIconPicker:SetPoint("TOPRIGHT", parent, "TOPLEFT", -48, -60)
	if parent == Me.editor then
		parent.scrollFrame.Container.traitIcon:Select( true )
	else
		parent.buffIcon:Select( true )
	end
	filteredList = nil
	
	Me.IconPicker_RefreshScroll( true )
	DiceMasterIconPicker.search:SetText("")
	DiceMasterIconPicker:Show()
end
