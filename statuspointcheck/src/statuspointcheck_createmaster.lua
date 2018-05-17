--ライブラリ読み込み
local acutil = require('acutil');

-- フレーム内文字

local nameX=20;
local resultX=400;
local pointX=440;
local mapX=550;

function STATUSPOINTCHECK_MASTER_QUEST_LIST(master_gbox)
	local masterquest = GET_CHILD(master_gbox, "masterquest_list", "ui::CGroupBox");
	masterquest = tolua.cast(masterquest, "ui::CGroupBox");

	--quest for master quest
	STATUSPOINTCHECK_MASTER_QUEST_CHECK(masterquest)

end

function STATUSPOINTCHECK_MASTER_QUEST_CHECK(masterquest)
	local questList = {
		"72151", "72152", "72165", "72166", "72131", "72135", "72137", "72139", "72170", "72172", "72149", "72168", "72143", "72147", "72167", "72150", "72153", "72161", "72154", "72155", "72156", "72157", "72158", "72159", "72160", "72162", "72163", "72164"
	}
	local titleBody = "Quest List For Master Quest";
	local body = "";
	local getPoint = 0;
	local sumPoint = #questList;
	local ypos = 20;
	local title = masterquest:CreateOrGetControl("richtext", "masterquestcheck_questcheck_title"  , 0, 0, 0, 0);
	for k, questNo in pairs(questList) do
		local name   = masterquest:CreateOrGetControl("richtext", "masterquestcheck_questcheck_name"..k  , nameX  , ypos, 0, 0);
		local result = masterquest:CreateOrGetControl("richtext", "masterquestcheck_questcheck_result"..k, resultX, ypos, 0, 0);
		local map    = masterquest:CreateOrGetControl("richtext", "masterquestcheck_questcheck_map"..k   , mapX   , ypos, 0, 0);
		local nameBody = "";
		local resultBody = "";
		local mapBody = "";
		local color = "";
		name = tolua.cast(name, "ui::CRichText");
		result = tolua.cast(result, "ui::CRichText");
		map = tolua.cast(map, "ui::CRichText");

		local questCls = GetClassByType('QuestProgressCheck', questNo);
		local questDetail = GetClassByType('QuestProgressCheck_Auto', questNo);
		-- questDetail.Success_ItemName1 is Clear Item(Point_Stone_100_Q)
		nameBody = questCls.Name;
		if STATUSPOINTCHECK_QUESTCLEARCHECK(questNo) then
			color = "{#FF3333}{ol}{b}{s16}";
			resultBody = "OK"
			mapBody = ""
			getPoint = getPoint + 1;
		else
			local mapprop = geMapTable.GetMapProp(questCls.StartMap);
			local mapName = tostring(dictionary.ReplaceDicIDInCompStr(mapprop:GetName()));
			color = "{#666666}{ol}{b}{s16}";
			resultBody = "NO"
			mapBody = mapName.."[Level:"..tostring(questCls.Level).."]"
		end
		name:SetText(color..nameBody.."{/}{/}{/}{/}")
		result:SetText(color..resultBody.."{/}{/}{/}{/}")
		map:SetText(color..mapBody.."{/}{/}{/}{/}")

		name:SetEventScript(ui.LBUTTONUP, "STATUSPOINTCHECK_QUEST_REQUEST");
		name:SetEventScriptArgString(ui.LBUTTONUP, questNo);

		ypos = ypos + name:GetHeight();
		masterquest:Resize(masterquest:GetWidth(),ypos)
	end
	title:SetText("{#000000}{s16}"..titleBody.."("..getPoint.."/"..sumPoint.."){/}{/}")
end

