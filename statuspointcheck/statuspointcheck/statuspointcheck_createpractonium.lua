--ライブラリ読み込み
local acutil = require('acutil');

-- フレーム内文字

local nameX=20;
local resultX=400;
local pointX=440;
local mapX=550;

function STATUSPOINTCHECK_PRACTONIUM_LIST(practonium_gbox)
	local practonium = GET_CHILD(practonium_gbox, "practonium_list", "ui::CGroupBox");
	local mystical = GET_CHILD(practonium_gbox, "mystical_list", "ui::CGroupBox");
	local absidium = GET_CHILD(practonium_gbox, "absidium_list", "ui::CGroupBox");
	practonium = tolua.cast(practonium, "ui::CGroupBox");
	mystical = tolua.cast(mystical, "ui::CGroupBox");
	absidium = tolua.cast(absidium, "ui::CGroupBox");

	--quest for practonium
	STATUSPOINTCHECK_PRACTONIUM_CHECK(practonium)
	--quest for mystical cube recipe
	mystical:SetOffset(20,practonium:GetY()+practonium:GetHeight());
	STATUSPOINTCHECK_MYSTICAL_CHECK(mystical)
	--quest for mystical absidium
	absidium:SetOffset(20,practonium:GetY()+practonium:GetHeight()+mystical:GetHeight());
	STATUSPOINTCHECK_ABSIDIUM_CHECK(absidium)

end

function STATUSPOINTCHECK_PRACTONIUM_CHECK(practonium)
	local questList = {
		"50257", "60305"
	}
	local titleBody = "Quest List For Practonium";
	local body = "";
	local getPoint = 0;
	local sumPoint = 3;
	local ypos = 20;
	local title = practonium:CreateOrGetControl("richtext", "practoniumcheck_questcheck_title"  , 0, 0, 0, 0);
	for k, questNo in pairs(questList) do
		local gbox   = practonium:CreateOrGetControl("groupbox", "practoniumcheck_questcheck_group"..k , 0  , ypos, 885, ypos);
		tolua.cast(gbox, "ui::CGroupBox");
		gbox:SetSkinName("none");
		local name   = gbox:CreateOrGetControl("richtext", "practoniumcheck_questcheck_name"..k  , nameX  , 0, 0, 0);
		local result = gbox:CreateOrGetControl("richtext", "practoniumcheck_questcheck_result"..k, resultX, 0, 0, 0);
		local point  = gbox:CreateOrGetControl("richtext", "practoniumcheck_questcheck_point"..k , pointX , 0, 0, 0);
		local map    = gbox:CreateOrGetControl("richtext", "practoniumcheck_questcheck_map"..k   , mapX   , 0, 0, 0);
		local nameBody = "";
		local resultBody = "";
		local mapBody = "";
		local color = "";
		name = tolua.cast(name, "ui::CRichText");
		result = tolua.cast(result, "ui::CRichText");
		point = tolua.cast(point, "ui::CRichText");
		map = tolua.cast(map, "ui::CRichText");

		local tempPoint = 1;
		if questNo == "60305" then
			tempPoint = 2;
		end

		local questCls = GetClassByType('QuestProgressCheck', questNo);
		local questDetail = GetClassByType('QuestProgressCheck_Auto', questNo);
		-- questDetail.Success_ItemName1 is Clear Item(Point_Stone_100_Q)
		nameBody = questCls.Name;
		pointBody = " x "..tempPoint
		if STATUSPOINTCHECK_QUESTCLEARCHECK(questNo) then
			color = "{#FF3333}{ol}{b}{s16}";
			resultBody = "OK"
			mapBody = ""
			getPoint = getPoint + tempPoint;
		else
			local mapprop = geMapTable.GetMapProp(questCls.StartMap);
			local mapName = tostring(dictionary.ReplaceDicIDInCompStr(mapprop:GetName()));
			color = "{#666666}{ol}{b}{s16}";
			resultBody = "NO"
			mapBody = mapName.."[Level:"..tostring(questCls.Level).."]"
		end
		name:SetText(color..nameBody.."{/}{/}{/}{/}")
		result:SetText(color..resultBody.."{/}{/}{/}{/}")
		point:SetText(color..pointBody.."{/}{/}{/}{/}")
		map:SetText(color..mapBody.."{/}{/}{/}{/}")

		gbox:SetEventScript(ui.LBUTTONUP, "STATUSPOINTCHECK_QUEST_REQUEST");
		gbox:SetEventScriptArgString(ui.LBUTTONUP, questNo);
		name:SetEventScript(ui.LBUTTONUP, "STATUSPOINTCHECK_QUEST_REQUEST");
		name:SetEventScriptArgString(ui.LBUTTONUP, questNo);
		result:SetEventScript(ui.LBUTTONUP, "STATUSPOINTCHECK_QUEST_REQUEST");
		result:SetEventScriptArgString(ui.LBUTTONUP, questNo);
		point:SetEventScript(ui.LBUTTONUP, "STATUSPOINTCHECK_QUEST_REQUEST");
		point:SetEventScriptArgString(ui.LBUTTONUP, questNo);
		map:SetEventScript(ui.LBUTTONUP, "STATUSPOINTCHECK_QUEST_REQUEST");
		map:SetEventScriptArgString(ui.LBUTTONUP, questNo);

		ypos = ypos + name:GetHeight();
		practonium:Resize(practonium:GetWidth(),ypos)
	end
	title:SetText("{#000000}{s16}"..titleBody.."("..getPoint.."/"..sumPoint.."){/}{/}")
end

function STATUSPOINTCHECK_MYSTICAL_CHECK(mystical)
	local questList = {
		"50258", "50263", "50278", "50261", "50273", "50274", "50275", "50260", "50267", "50259", "90179"
	}
	local titleBody = "Quest List For Mystical Cube Recipe";
	local body = "";
	local getPoint = 0;
	local sumPoint = #questList;
	local ypos = 20;
	local title = mystical:CreateOrGetControl("richtext", "mysticalcheck_questcheck_title"  , 0, 0, 0, 0);
	for k, questNo in pairs(questList) do
		local gbox   = mystical:CreateOrGetControl("groupbox", "mysticalcheck_questcheck_group"..k , 0  , ypos, 885, ypos);
		tolua.cast(gbox, "ui::CGroupBox");
		gbox:SetSkinName("none");
		local name   = gbox:CreateOrGetControl("richtext", "mysticalcheck_questcheck_name"..k  , nameX  , 0, 0, 0);
		local result = gbox:CreateOrGetControl("richtext", "mysticalcheck_questcheck_result"..k, resultX, 0, 0, 0);
		local map    = gbox:CreateOrGetControl("richtext", "mysticalcheck_questcheck_map"..k   , mapX   , 0, 0, 0);
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

		gbox:SetEventScript(ui.LBUTTONUP, "STATUSPOINTCHECK_QUEST_REQUEST");
		gbox:SetEventScriptArgString(ui.LBUTTONUP, questNo);
		name:SetEventScript(ui.LBUTTONUP, "STATUSPOINTCHECK_QUEST_REQUEST");
		name:SetEventScriptArgString(ui.LBUTTONUP, questNo);
		result:SetEventScript(ui.LBUTTONUP, "STATUSPOINTCHECK_QUEST_REQUEST");
		result:SetEventScriptArgString(ui.LBUTTONUP, questNo);
		map:SetEventScript(ui.LBUTTONUP, "STATUSPOINTCHECK_QUEST_REQUEST");
		map:SetEventScriptArgString(ui.LBUTTONUP, questNo);

		ypos = ypos + name:GetHeight();
		mystical:Resize(mystical:GetWidth(),ypos)
	end
	title:SetText("{#000000}{s16}"..titleBody.."("..getPoint.."/"..sumPoint.."){/}{/}")
end

function STATUSPOINTCHECK_ABSIDIUM_CHECK(absidium)
	local questList = {
		"90172", "90173", "90174", "90175", "90177", "90178", "90179", "90180", "90181", "90182", "90183", "90184", "90185", "90186", "90187", "90165", "90167", "90168", "90169", "90170", "90171"
	}
	local titleBody = "Quest List For Absidium";
	local body = "";
	local getPoint = 0;
	local sumPoint = 32;
	local ypos = 20;
	local title = absidium:CreateOrGetControl("richtext", "absidiumcheck_questcheck_title"  , 0, 0, 0, 0);
	for k, questNo in pairs(questList) do
		local gbox   = absidium:CreateOrGetControl("groupbox", "absidiumcheck_questcheck_group"..k , 0  , ypos, 885, ypos);
		tolua.cast(gbox, "ui::CGroupBox");
		gbox:SetSkinName("none");
		local name   = gbox:CreateOrGetControl("richtext", "absidiumcheck_questcheck_name"..k  , nameX  , 0, 0, 0);
		local result = gbox:CreateOrGetControl("richtext", "absidiumcheck_questcheck_result"..k, resultX, 0, 0, 0);
		local point  = gbox:CreateOrGetControl("richtext", "absidiumcheck_questcheck_point"..k , pointX , 0, 0, 0);
		local map    = gbox:CreateOrGetControl("richtext", "absidiumcheck_questcheck_map"..k   , mapX   , 0, 0, 0);
		local nameBody = "";
		local resultBody = "";
		local pointBody = "";
		local mapBody = "";
		local color = "";
		name = tolua.cast(name, "ui::CRichText");
		result = tolua.cast(result, "ui::CRichText");
		point = tolua.cast(point, "ui::CRichText");
		map = tolua.cast(map, "ui::CRichText");

		local tempPoint = 1;
		if questNo == "90173" or questNo == "90174" or questNo == "90181" or questNo == "90183" or questNo == "90184" or questNo == "90185" or questNo == "90187" or questNo == "90165" or questNo == "90168" then
			tempPoint = 2;
		elseif questNo == "90175" then
			tempPoint = 3;
		end
		local questCls = GetClassByType('QuestProgressCheck', questNo);
		local questDetail = GetClassByType('QuestProgressCheck_Auto', questNo);
		-- questDetail.Success_ItemName1 is Clear Item(Point_Stone_100_Q)
		nameBody = questCls.Name;
		pointBody = " x "..tempPoint
		if STATUSPOINTCHECK_QUESTCLEARCHECK(questNo) then
			color = "{#FF3333}{ol}{b}{s16}";
			resultBody = "OK"
			mapBody = ""
			getPoint = getPoint + tempPoint;
		else
			local mapprop = geMapTable.GetMapProp(questCls.StartMap);
			local mapName = tostring(dictionary.ReplaceDicIDInCompStr(mapprop:GetName()));
			color = "{#666666}{ol}{b}{s16}";
			resultBody = "NO"
			mapBody = mapName.."[Level:"..tostring(questCls.Level).."]"
		end
		name:SetText(color..nameBody.."{/}{/}{/}{/}")
		result:SetText(color..resultBody.."{/}{/}{/}{/}")
		point:SetText(color..pointBody.."{/}{/}{/}{/}")
		map:SetText(color..mapBody.."{/}{/}{/}{/}")

		gbox:SetEventScript(ui.LBUTTONUP, "STATUSPOINTCHECK_QUEST_REQUEST");
		gbox:SetEventScriptArgString(ui.LBUTTONUP, questNo);
		name:SetEventScript(ui.LBUTTONUP, "STATUSPOINTCHECK_QUEST_REQUEST");
		name:SetEventScriptArgString(ui.LBUTTONUP, questNo);
		result:SetEventScript(ui.LBUTTONUP, "STATUSPOINTCHECK_QUEST_REQUEST");
		result:SetEventScriptArgString(ui.LBUTTONUP, questNo);
		point:SetEventScript(ui.LBUTTONUP, "STATUSPOINTCHECK_QUEST_REQUEST");
		point:SetEventScriptArgString(ui.LBUTTONUP, questNo);
		map:SetEventScript(ui.LBUTTONUP, "STATUSPOINTCHECK_QUEST_REQUEST");
		map:SetEventScriptArgString(ui.LBUTTONUP, questNo);

		ypos = ypos + name:GetHeight();
		absidium:Resize(absidium:GetWidth(),ypos)
	end
	title:SetText("{#000000}{s16}"..titleBody.."("..getPoint.."/"..sumPoint.."){/}{/}")
end

