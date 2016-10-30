CHAT_SYSTEM("TREASUREMAP loaded!");


function TREASUREMAP_ON_INIT(addon, frame)
	local acutil = require("acutil");

	addon:RegisterMsg("FPS_UPDATE", "TREASUREMAP_UPDATE");
end

function TREASUREMAP_UPDATE(frame, msg, argStr, argNum)
	DRAW_TREASUREMAP();
end

function DRAW_TREASUREMAP()


	local mapClassName = session.GetMapName();
	local mapprop = geMapTable.GetMapProp(mapClassName);

	local mapframe = ui.GetFrame("map");

	local mongens = mapprop.mongens;

	if mongens == nil then
		return nil;
	end

	local cnt = mongens:Count();

	for i = 0 , cnt - 1 do
		local MonProp = mongens:Element(i);

		if string.find(MonProp:GetClassType(),"treasure") then
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
