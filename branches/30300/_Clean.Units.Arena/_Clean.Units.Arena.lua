--[[****************************************************************************
  * _Clean.Units.Arena by Saiket                                               *
  * _Clean.Units.Arena.lua - Adds arena frames when entering a match.          *
  ****************************************************************************]]


--------------------------------------------------------------------------------
-- Function Hooks / Execution
-----------------------------

do
	local _Clean = _Clean;
	local me = _Clean.Units.oUF;
	assert( me.StyleMeta.__call, "_Clean.Units.oUF Initializer already destroyed!" );

	oUF:RegisterStyle( "_CleanUnitsArena", setmetatable( {
		[ "initial-width" ] = 110;
		[ "initial-height" ] = 36;
		HealthText = "Tiny";
		PowerText  = "Tiny";
		NameFont = me.FontTiny;
		CastTime = false;
		Auras = false;
		DebuffHighlight = false;
		PowerHeight = 0.2;
		ProgressHeight = 0.2;
	}, me.StyleMeta ) );
	oUF:RegisterStyle( "_CleanUnitsArenaTarget", setmetatable( {
		[ "initial-width" ] = 80;
		[ "initial-height" ] = 36;
		PortraitSide = "LEFT";
		HealthText = false;
		PowerText  = false;
		NameFont = me.FontTiny;
		CastTime = false;
		Auras = false;
		PowerHeight = 0.2;
		ProgressHeight = 0.2;
	}, me.StyleMeta ) );


	local LastFrame;
	for Index = 1, 5 do
		oUF:SetActiveStyle( "_CleanUnitsArena" );
		local Frame = oUF:Spawn( "arena"..Index, "_CleanUnitsArena"..Index );
		if ( LastFrame ) then
			Frame:SetPoint( "TOPLEFT", LastFrame, "BOTTOMLEFT", 0, -_Clean.Backdrop.Padding * 2 );
		else
			Frame:SetPoint( "LEFT", UIParent );
			Frame:SetPoint( "TOP", me.Pet, "BOTTOM", 0, -185 );
		end
		LastFrame = Frame;

		-- Arena target
		oUF:SetActiveStyle( "_CleanUnitsArenaTarget" );
		local Target = oUF:Spawn( Frame.unit.."target", Frame:GetName().."Target" );
		Target:SetPoint( "TOPLEFT", Frame, "TOPRIGHT", _Clean.Backdrop.Padding * 2, 0 );
		-- Show only when target is friendly
		UnregisterUnitWatch( Target );
		RegisterStateDriver( Target, "visibility", "[target="..Target.unit..",help]show;hide" );
	end

	-- Garbage collect _Clean.Units.oUF's initialization code
	me.StyleMeta.__call = nil;
end

