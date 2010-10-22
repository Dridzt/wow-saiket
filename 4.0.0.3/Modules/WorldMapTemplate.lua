--[[****************************************************************************
  * _NPCScan.Overlay by Saiket                                                 *
  * Modules/WorldMapTemplate.lua - Template module for WorldMap-like canvases. *
  ****************************************************************************]]


local Overlay = select( 2, ... );
local me = {};
Overlay.Modules.WorldMapTemplate = me;




do
	--- Callback to draw a single NPC's paths for a zone.
	local function PaintPath ( self, PathData, FoundX, FoundY, R, G, B, NpcID )
		Overlay.DrawPath( self, PathData, "ARTWORK", R, G, B );
		if ( FoundX ) then
			Overlay.DrawFound( self, FoundX, FoundY,
				Overlay.DetectionRadius / Overlay.GetMapSize( Overlay.GetNPCMapID( NpcID ) ),
				"OVERLAY", R, G, B );
		end
	end
	--- Draws paths for the given map on this canvas.
	-- Must be viewing Map using the WorldMap API.
	-- @param Map  AreaID to draw paths for.
	function me:Paint ( Map )
		Overlay.TextureRemoveAll( self );
		Overlay.ApplyZone( self, Map, PaintPath );
	end
end
local MapUpdate;
do
	--- Repaints at most once per frame, and only when the displayed zome changes.
	local function OnUpdate ( self )
		self:SetScript( "OnUpdate", nil );

		local Map = GetCurrentMapAreaID();
		if ( Map ~= self.MapLast ) then
			self.MapLast = Map;

			return self:Paint( Map );
		end
	end
	--- Throttles calls to the Paint method.
	-- @param Force  Forces an update even if the map hasn't changed.
	function MapUpdate ( self, Force )
		if ( Force ) then
			self.MapLast = nil;
		end
		self:SetScript( "OnUpdate", OnUpdate );
	end
end




--- Update the map if the viewed zone changes.
function me:WORLD_MAP_UPDATE ()
	MapUpdate( self );
end
--- Immediately update the map when shown.
function me:OnShow ()
	MapUpdate( self );
end




--- Force an update if shown paths change.
-- @param Map  AreaID that changed, or nil if all zones must update.
function me:OnMapUpdate ( Map )
	if ( not Map or Map == self.MapLast ) then
		MapUpdate( self, true );
	end
end
--- Shows the canvas when enabled.
function me:OnEnable ()
	self:RegisterEvent( "WORLD_MAP_UPDATE" );
	self:Show();
end
--- Hides the canvas when disabled.
function me:OnDisable ()
	self:UnregisterEvent( "WORLD_MAP_UPDATE" );
	self:Hide();
	Overlay.TextureRemoveAll( self );
end
--- Initializes the canvas after its dependencies load.
function me:OnLoad ()
	self:Hide();
	self:SetAllPoints();
	self:SetScript( "OnShow", self.OnShow );
	self:SetScript( "OnEvent", Overlay.Modules.OnEvent );
end
--- Clears all methods and scripts to be garbage collected.
function me:OnUnload ()
	self:SetScript( "OnShow", nil );
	self:SetScript( "OnEvent", nil );
	self:SetScript( "OnUpdate", nil );
end
do
	local Preserve = {
		[ 0 ] = true; -- Frame UserData
		Name = true;
		Config = true;
		OnSynchronize = true;
	};
	--- Clears most module data to be garbage collected.
	function me:OnUnregister ()
		for Key in pairs( self ) do
			if ( not Preserve[ Key ] ) then
				self[ Key ] = nil;
			end
		end
	end
end




do
	local Inherit = {
		"Paint",
		"WORLD_MAP_UPDATE",
		"OnShow",
		"OnMapUpdate",
		"OnEnable",
		"OnDisable",
		"OnLoad",
		"OnUnload",
		"OnUnregister"
	};
	--- Implements WorldMapTemplate for a given canvas module frame.
	function me:Embed ()
		for _, Method in ipairs( Inherit ) do
			self[ Method ] = me[ Method ];
		end
		self.super = me;
		return self;
	end
end