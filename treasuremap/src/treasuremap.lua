local acutil = require("acutil");
CHAT_SYSTEM("TREASUREMAP 1.1.0 loaded!");

function TREASUREMAP_ON_INIT(addon, frame)
	acutil.setupEvent(addon, "UI_TOGGLE_MAP", "DRAW_TREASUREMAP")
	addon:RegisterMsg("NPC_STATE_UPDATE", "DRAW_TREASUREMAP");
end

function DRAW_TREASUREMAP()

	local mapframe = ui.GetFrame("map");
	if mapframe:IsVisible() == 0 then
		return;
	end

	local mapClassName = session.GetMapName();
	local mapprop = geMapTable.GetMapProp(mapClassName);
	local idspace = 'GenType_'..mapClassName;
	if GetClassByIndex(idspace, 0) == nil then
		return;
	end

	DESTROY_CHILD_BYNAME(mapframe, "_TOREASURE_GEN_");
	DESTROY_CHILD_BYNAME(mapframe, "_QUESTINFOMAP_");
	local npcState = session.GetMapNPCState(mapClassName);

	local idcount = GetClassCount(idspace)
	local treasureCnt = 0;
	local hideTreasureCnt = 0;

	for i = 0, idcount -1 do
		local classIES = GetClassByIndex(idspace, i);
		if string.find(string.lower(tostring(classIES.ArgStr2)),string.lower("ITEM:")) then
			if string.find(string.lower(tostring(classIES.ClassType)),string.lower("Skl_ScanTrigger")) then
				hideTreasureCnt = hideTreasureCnt + 1;
			end
			treasureCnt = treasureCnt + 1;
			local treasureName = tostring(classIES.Name);
			local treasureGenType = tostring(classIES.GenType);
			local treasureContents = "";
			if "None" ~= tostring(classIES.ArgStr2) then
				treasureContents = GetClass("Item",string.gsub(tostring(classIES.ArgStr2),".+:(.+):.+","%1")).Name;
			end
			local anchor = 'Anchor_'..mapClassName;
			local anchorcount = GetClassCount(anchor)

			for j = 0, anchorcount -1 do
				local anchorClassIES = GetClassByIndex(anchor, j);
				if tostring(anchorClassIES.GenType) == treasureGenType then
					local treasureXpos = anchorClassIES.PosX;
					local treasureZpos = anchorClassIES.PosZ;


					local MapPos = mapprop:WorldPosToMinimapPos(treasureXpos, treasureZpos, m_mapWidth, m_mapHeight);
					local XC = m_offsetX + MapPos.x - 50 / 2;
					local YC = m_offsetY + MapPos.y - 50 / 2;

					local PictureC = mapframe:CreateOrGetControl('picture', string.format( "_TOREASURE_GEN_%d", treasureGenType), XC, YC, 50, 50);
					tolua.cast(PictureC, "ui::CPicture");
					PictureC:SetEnableStretch(1);
					SET_PICTURE_QUESTMAP(PictureC, 0);

					local textC = mapframe:CreateOrGetControl('richtext', string.format( "_QUESTINFOMAP_%d", treasureGenType), XC, YC, 50, 50);
					tolua.cast(textC, "ui::CRichText");
					textC:SetTextAlign("left", "bottom");
					textC:ShowWindow(1);
					textC:SetUserValue("EXTERN", "YES");
					if npcState:FindAndGet(classIES.GenType) ~= -1 then
						PictureC:SetColorTone("FF00FF00");
						textC:SetText("{@st42b}" .. treasureName .. "{nl}" .. treasureContents);
					else
						PictureC:SetColorTone("FFCCCCCC");
						textC:SetText("{@st42b}OPENED!!");
					end

				end
			end

		end
	end

	local rateObj = GET_CHILD(mapframe, "rate", 'ui::CRichText');
	local xPos = rateObj:GetX() + rateObj:GetWidth();
	local yPos = rateObj:GetY() -15;

	local treasureText = mapframe:CreateOrGetControl('richtext', string.format("TREASURE_COUNT"), xPos, yPos, 50, 50);
	tolua.cast(treasureText, "ui::CRichText");
	treasureText:SetTextAlign("left", "center");
	if hideTreasureCnt == 0 then
		treasureText:SetText("{@st66d_y}This Map Treasures Count:" .. treasureCnt);
	else
		treasureText:SetText("{@st66d_y}This Map Treasures Count:" .. treasureCnt .. "{nl}" .. "Hidden Treasures Count:" .. hideTreasureCnt);
	end
	treasureText:ShowWindow(1);
	treasureText:SetUserValue("EXTERN", "YES");

end
