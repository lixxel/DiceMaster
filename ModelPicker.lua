-------------------------------------------------------------------------------
-- Dice Master (C) 2019 <The League of Lordaeron> - Moon Guard
-------------------------------------------------------------------------------

--
-- Model picker interface.
--

local Me = DiceMaster4

local startOffset = 0
local filteredList = nil

Me.unitList = #Me.modelList

-------------------------------------------------------------------------------
-- When one of the model buttons are clicked.
--
function Me.ModelPickerButton_OnClick( self )
	-- Apply the model and close the picker. 
	local value = math.floor(self:GetParent().scroller:GetValue())*4 + self.pickerIndex
	if filteredList then
		value = filteredList[value].displayID
	else
		value = Me.modelList[value].displayID
	end
		
	if Me.ModelEditing then
		Me.ModelEditing:ClearModel()
		Me.ModelEditing:SetDisplayInfo(value)
		PlaySound(83)
		
		Me.ModelEditing.checked = value;
		self.check:Show()
		
		Me.ModelEditing.scrollposition = DiceMasterModelPicker.selectorFrame.scroller:GetValue()
		Me.UpdateUnitFrames()
		Me.ModelPicker_RefreshGrid()
	end
end

-------------------------------------------------------------------------------
-- OnEnter handler, to magnify the model and show the texture path.
--
function Me.ModelPickerButton_ShowTooltip( self )
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	
	local value = math.floor(self:GetParent().scroller:GetValue())*4 + self.pickerIndex
	if filteredList then
		value = filteredList[value]
	else
		value = Me.modelList[value]
	end
    GameTooltip:AddLine( "ID: " .. value.displayID, 1, 1, 1, true )
	GameTooltip:AddLine( "Name: " .. value.model, 1, 1, 1, true )
    GameTooltip:Show()
end

-------------------------------------------------------------------------------
-- When the mousewheel is used on the model map.
--
function Me.ModelPicker_MouseScroll( delta )

	local a = DiceMasterModelPicker.selectorFrame.scroller:GetValue() - delta
	-- todo: do we need to clamp?
	DiceMasterModelPicker.selectorFrame.scroller:SetValue( a )
end
   
-------------------------------------------------------------------------------
-- When the scrollbar's value is changed.
--
function Me.ModelPicker_ScrollChanged( value )
	
	-- Our "step" is 4 models, which is one line.
	startOffset = math.floor(value) * 4
	Me.ModelPicker_RefreshGrid()
end

-------------------------------------------------------------------------------
-- Set the displayID of the model grid from the models in the list at the
-- current offset.
--
function Me.ModelPicker_RefreshGrid()
	local list = filteredList or Me.modelList
	for k,v in ipairs( DiceMasterModelPicker.icons ) do		
		local tex
		if list[startOffset + k] then
			tex = list[startOffset + k].displayID
		end
		if tex~= nil then
		
			v:Show()
			v:ClearModel()
			v:SetDisplayInfo(tex)
			
			if Me.ModelEditing.checked == tex then
				v.check:Show()
			else
				v.check:Hide()
			end
			
		else
			v:Hide()
		end
	end
end

-------------------------------------------------------------------------------
-- Called when the user types into the search box.
--
function Me.ModelPicker_FilterChanged()
	local filter = DiceMasterModelPicker.search:GetText():lower()
	if #filter < 3 then
		-- Ignore filters less than three characters
		if filteredList then
			filteredList = nil
			Me.ModelPicker_RefreshScroll( true )
			Me.ModelPicker_RefreshGrid()
		end
	else
		-- build new list
		filteredList = {}
		for i=1,Me.unitList do
			if strfind( Me.modelList[i].model, filter) then 
				tinsert( filteredList, Me.modelList[i] )
			end
		end
		Me.ModelPicker_RefreshScroll( true )
	end
end

-------------------------------------------------------------------------------
-- When we change the size of the list, update the scroll bar range.
--
-- @param reset Reset the scroll bar to the beginning.
--
function Me.ModelPicker_RefreshScroll( reset, value )
	local list = filteredList or Me.modelList 
	local max = math.floor((#list - 8) / 4)
	if max < 0 then max = 0 end
	DiceMasterModelPicker.selectorFrame.scroller:SetMinMaxValues( 0, max )
	
	if reset then
		DiceMasterModelPicker.selectorFrame.scroller:SetValue( 0 )
	elseif value then
		DiceMasterModelPicker.selectorFrame.scroller:SetValue( math.floor(value) )
	end
	
	Me.ModelPicker_ScrollChanged( DiceMasterModelPicker.selectorFrame.scroller:GetValue() )
end
    
-------------------------------------------------------------------------------
-- Close the model picker window. Use this instead of a direct Hide()
--
function Me.ModelPicker_Close()
	Me.ModelEditing = nil;
	DiceMasterModelPicker:Hide()
end
    
-------------------------------------------------------------------------------
-- Open the model picker window.
--
function Me.ModelPicker_Open( frame, model )
	DiceMasterModelPicker:SetPoint( "LEFT", frame, "RIGHT" )
	Me.ModelEditing = model
	filteredList = nil
	
	if Me.ModelEditing.scrollposition then
		Me.ModelPicker_RefreshScroll( nil, Me.ModelEditing.scrollposition )
	elseif DiceMasterModelPicker.scrollposition then
		Me.ModelPicker_RefreshScroll( nil, DiceMasterModelPicker.scrollposition )
	else
		Me.ModelPicker_RefreshScroll( true )
	end
	
	Me.ModelPicker_RefreshScroll( true )
	DiceMasterModelPicker.search:SetText("")
	DiceMasterModelPicker:Show()
end
