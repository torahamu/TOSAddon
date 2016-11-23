isTreasuremapLoad = false;
CHAT_SYSTEM("TREASUREMAP 1.0.3 loaded!");

function TREASUREMAP_ON_INIT(addon, frame)
	if (isTreasuremapLoad ~= true) then
		_G["MAKE_MAP_NPC_ICONS_OLD"] = MAKE_MAP_NPC_ICONS;
		_G["MAKE_MAP_NPC_ICONS"] = MAKE_MAP_NPC_ICONS_HOOKS;
		isTreasuremapLoad = true;
	end

end

function MAKE_MAP_NPC_ICONS_HOOKS(frame, mapname, mapWidth, mapHeight, offsetX, offsetY)
	MAKE_MAP_NPC_ICONS_OLD(frame, mapname, mapWidth, mapHeight, offsetX, offsetY);
	DRAW_TREASUREMAP();
end

function DRAW_TREASUREMAP()

	local mapframe = ui.GetFrame("map");
	if mapframe:IsVisible() == 0 then
		return;
	end
	local mapClassName = session.GetMapName();
	local mapprop = geMapTable.GetMapProp(mapClassName);

	local mongens = mapprop.mongens;

	if mongens == nil then
		return nil;
	end

	local cnt = mongens:Count();

	for i = 0 , cnt - 1 do
		local MonProp = mongens:Element(i);

		if string.find(string.lower(MonProp:GetClassType()),"treasure") then
			monCls = GetClassByType("Monster", MonProp:GetType());

			local GenList = MonProp.GenList;
			local GenCnt = GenList:Count();

			for j = 0 , GenCnt - 1 do
				WorldPos = GenList:Element(j);

				local MapPos = mapprop:WorldPosToMinimapPos(WorldPos.x, WorldPos.z, m_mapWidth, m_mapHeight);
				local XC = m_offsetX + MapPos.x - 50 / 2;
				local YC = m_offsetY + MapPos.y - 50 / 2;

				local PictureC = mapframe:CreateOrGetControl('picture', string.format( "_NPC_GEN_%d", MonProp.GenType), XC, YC, 50, 50);
				tolua.cast(PictureC, "ui::CPicture");
				PictureC:SetEnableStretch(1);
				PictureC:SetColorTone("FF00FF00");
				SET_PICTURE_QUESTMAP(PictureC, 0);

				local textC = mapframe:CreateOrGetControl('richtext', string.format( "_QUESTINFOMAP_%d", MonProp.GenType), XC, YC, 50, 50);
				tolua.cast(textC, "ui::CRichText");
				textC:SetTextAlign("center", "bottom");
				textC:SetText("{@st42b}" .. monCls.Name);
				textC:ShowWindow(1);
				textC:SetUserValue("EXTERN", "YES");
			end

		end
	end

end
