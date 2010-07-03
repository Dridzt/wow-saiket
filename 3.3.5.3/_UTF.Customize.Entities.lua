--[[****************************************************************************
  * _UTF by Saiket                                                             *
  * _UTF.Customize.Entities.lua - Options sub-pane for custom entities.        *
  ****************************************************************************]]


local _UTF = select( 2, ... );
local L = _UTF.L;
local me = CreateFrame( "Frame" );
_UTF.Customize.Entities = me;

me.Key = L.CUSTOMIZE_ENTITIES_NAME;
me.Value = L.CUSTOMIZE_ENTITIES_VALUE;




--- Rebuilds the table of entities.
function me.Update ()
	local Table = _UTF.Customize.Table;
	Table:SetHeader( L.CUSTOMIZE_ENTITIES_GLYPH, L.CUSTOMIZE_ENTITIES_NAME, L.CUSTOMIZE_ENTITIES_VALUE );
	Table:SetSortHandlers( false, true, true );
	Table:SetSortColumn( 2 ); -- Default sort by name

	for Name, ID in pairs( _UTFOptions.CharacterEntities ) do
		Table:AddRow( Name, _UTF.IntToUTF( ID ), Name, ID );
	end
end
--- Callback that specifies new edit box text when a table entry is selected.
function me.OnSelect ( Name )
	return Name, _UTFOptions.CharacterEntities[ Name ];
end


--- Adds an entity name and value to the data set.
-- @return True if added successfully.
function me.Add ( Key, Value )
	if ( me.CanAdd( Key, Value ) ) then
		_UTFOptions.CharacterEntities[ Key ] = tonumber( Value );
		return true;
	end
end
--- Removes an entity by key from the data set.
-- @return True if removed successfully.
function me.Remove ( Key )
	if ( me.CanRemove( Key ) ) then
		_UTFOptions.CharacterEntities[ Key ] = nil;
		return true;
	end
end


--- Validates that a key is present and can be removed.
-- @return The unique identifier that can be used to select this removable value in the table.
function me.CanRemove ( Key )
	if ( _UTFOptions.CharacterEntities[ Key ] ) then
		return Key;
	end
end
--- Validates that a key/value pair can be added.
-- @return True if the values can be added successfully.
function me.CanAdd ( Key, Value )
	Value = tonumber( Value );
	if ( Value and Key:match( "^%w+$" )
		and _UTFOptions.CharacterEntities[ Key ] ~= Value
		and _UTF.Min <= Value and Value <= _UTF.Max
	) then
		return true;
	end
end


--- Initializes the value editbox to numeric mode when opening this pane.
function me:OnShow ()
	_UTF.Customize.Value:SetNumeric( true );
end
--- Restores the value editbox back to text mode when this pane is closed.
function me:OnHide ()
	_UTF.Customize.Value:SetNumeric( false );
end




me:SetScript( "OnShow", me.OnShow );
me:SetScript( "OnHide", me.OnHide );

_UTF.Customize.AddPane( me, L.CUSTOMIZE_ENTITIES_TITLE );