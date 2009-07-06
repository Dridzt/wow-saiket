--[[****************************************************************************
  * _NPCScan.Overlay by Saiket                                                 *
  * _NPCScan.Overlay.WorldMap.lua - Canvas for the WorldMap.                   *
  ****************************************************************************]]


local L = _NPCScanLocalization.OVERLAY;
local Overlay = _NPCScan.Overlay;
local me = CreateFrame( "Frame", nil, WorldMapDetailFrame );
Overlay.WorldMap = me;

me.Label = L.MODULE_WORLDMAP;

me.Key = CreateFrame( "Frame", nil, me );
local Key = me.Key;

me.AchievementNPCNames = {};




--[[****************************************************************************
  * Function: _NPCScan.Overlay.WorldMap.Key:OnEnter                            *
  ****************************************************************************]]
do
	local Points = { "BOTTOMLEFT", "BOTTOMRIGHT", "TOPRIGHT" };
	local Point = 0;
	function Key:OnEnter ()
		self:ClearAllPoints();
		self:SetPoint( Points[ Point % #Points + 1 ] );
		Point = Point + 1;
	end
end




--[[****************************************************************************
  * Function: _NPCScan.Overlay.WorldMap:Repaint                                *
  ****************************************************************************]]
do
	local Count, Height, Width;
	local NPCNames = {};
	local function PaintPathAndKey ( ID, PolyData, R, G, B )
		Overlay.PolygonAdd( me, ID, PolyData, "OVERLAY", R, G, B, 0.55 );

		Count = Count + 1;
		local Line = Key[ Count ];
		if ( not Line ) then
			Line = Key.Body:CreateFontString( nil, "OVERLAY", "ChatFontNormal" );
			Line:SetPoint( "TOPLEFT", Count == 1 and Key.Title or Key[ Count - 1 ], "BOTTOMLEFT" );
			Line:SetPoint( "RIGHT", Key.Title );
			Line:SetJustifyH( "LEFT" );
			Key[ Count ] = Line;
		else
			Line:Show();
		end

		Line:SetText( L.MODULE_WORLDMAP_KEY_FORMAT:format( me.AchievementNPCNames[ ID ] or NPCNames[ ID ] or ID ) );
		Line:SetTextColor( R, G, B );

		Width = max( Width, Line:GetStringWidth() );
		Height = Height + Line:GetStringHeight();
	end
	local function MapHasNPCs ( Map )
		local Zone = Overlay.PathData[ Map ];
		if ( Zone ) then
			for ID in pairs( Zone ) do
				if ( Overlay.NPCsEnabled[ ID ] ) then
					return true;
				end
			end
		end
	end
	function me:Repaint ( Map )
		if ( MapHasNPCs( Map ) ) then
			Width = Key.Title:GetStringWidth();
			Height = Key.Title:GetStringHeight();
			Count = 0;

			-- Cache custom mob names
			for Name, ID in pairs( _NPCScan.OptionsCharacter.NPCs ) do
				NPCNames[ ID ] = Name;
			end
			Overlay.ApplyZone( Map, PaintPathAndKey );
			wipe( NPCNames );

			for Index = Count + 1, #Key do
				Key[ Index ]:Hide();
			end
			Key:SetWidth( Width + 32 );
			Key:SetHeight( Height + 32 );
			Key:Show();
		else
			Key:Hide();
		end
	end
end


--[[****************************************************************************
  * Function: local MapUpdate                                                  *
  ****************************************************************************]]
local MapUpdate;
do
	local function OnUpdate ( self )
		self:SetScript( "OnUpdate", nil );

		local Map = GetMapInfo();
		if ( Map ~= self.MapLast ) then
			self.MapLast = Map;

			Overlay.PolygonRemoveAll( self );
			self:Repaint( Map );
		end
	end
	function MapUpdate ( self, Force )
		if ( Force ) then
			self.MapLast = nil;
		end
		self:SetScript( "OnUpdate", OnUpdate );
	end
end


--[[****************************************************************************
  * Function: _NPCScan.Overlay.WorldMap:OnShow                                 *
  ****************************************************************************]]
function me:OnShow ()
	MapUpdate( self );
end
--[[****************************************************************************
  * Function: _NPCScan.Overlay.WorldMap:OnEvent                                *
  ****************************************************************************]]
function me:OnEvent ()
	MapUpdate( self ); -- WORLD_MAP_UPDATE
end
--[[****************************************************************************
  * Function: _NPCScan.Overlay.WorldMap:OnLoad                                 *
  ****************************************************************************]]
function me:OnLoad ()
	self:Hide();
	self:SetAllPoints();
	self:SetScript( "OnShow", me.OnShow );
	self:SetScript( "OnEvent", me.OnEvent );
end


--[[****************************************************************************
  * Function: _NPCScan.Overlay.WorldMap:Update                                 *
  ****************************************************************************]]
function me:Update ( Map )
	if ( not Map or Map == self.MapLast ) then
		MapUpdate( self, true );
	end
end
--[[****************************************************************************
  * Function: _NPCScan.Overlay.WorldMap:Disable                                *
  ****************************************************************************]]
function me:Disable ()
	self:UnregisterEvent( "WORLD_MAP_UPDATE" );
	self:Hide();
	Overlay.PolygonRemoveAll( self );
end
--[[****************************************************************************
  * Function: _NPCScan.Overlay.WorldMap:Enable                                 *
  ****************************************************************************]]
function me:Enable ()
	self:RegisterEvent( "WORLD_MAP_UPDATE" );
	self:Show();
end




--------------------------------------------------------------------------------
-- Function Hooks / Execution
-----------------------------

do
	Key:SetScript( "OnEnter", Key.OnEnter );
	Key:OnEnter();
	Key:EnableMouse( true );
	Key:SetAlpha( 0.8 );
	Key:SetBackdrop( {
		edgeFile = [[Interface\AchievementFrame\UI-Achievement-WoodBorder]]; edgeSize = 48;
	} );
	Key.Body = CreateFrame( "Frame", nil, Key );
	Key.Body:SetPoint( "BOTTOMLEFT", 10, 10 );
	Key.Body:SetPoint( "TOPRIGHT", -10, -10 );
	Key.Body:SetBackdrop( {
		bgFile = [[Interface\AchievementFrame\UI-Achievement-AchievementBackground]];
		edgeFile = [[Interface\Tooltips\UI-Tooltip-Border]]; edgeSize = 16;
		insets = { left = 3; right = 3; top = 3; bottom = 3; };
	} );
	Key.Body:SetBackdropBorderColor( 0.8, 0.4, 0.2 ); -- Light brown

	local TitleBackground = Key.Body:CreateTexture( nil, "BORDER" );
	TitleBackground:SetTexture( [[Interface\AchievementFrame\UI-Achievement-Title]] );
	TitleBackground:SetPoint( "TOPRIGHT", -5, -5 );
	TitleBackground:SetPoint( "LEFT", 5, 0 );
	TitleBackground:SetHeight( 18 );
	TitleBackground:SetTexCoord( 0, 0.9765625, 0, 0.3125 );
	TitleBackground:SetAlpha( 0.8 );

	local Title = Key.Body:CreateFontString( nil, "OVERLAY", "GameFontHighlightMedium" );
	Key.Title = Title;
	Title:SetAllPoints( TitleBackground );
	Title:SetText( L.MODULE_WORLDMAP_KEY );

	me:OnLoad();
	Overlay.ModuleRegister( "WorldMap", me );

	-- Cache achievement NPC names
	for AchievementID, Achievement in pairs( _NPCScan.Achievements ) do
		for CriteriaID, NPCID in pairs( Achievement.Criteria ) do
			me.AchievementNPCNames[ NPCID ] = GetAchievementCriteriaInfo( CriteriaID );
		end
	end
end
