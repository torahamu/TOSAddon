--ライブラリ読み込み
local acutil = require('acutil');

-- フレーム内文字
if option.GetCurrentCountry()=="Japanese" then
	weighttxt = "所持量"
else
	weighttxt = "Weight"
end

local nameX=20;
local resultX=400;
local pointX=440;
local mapX=550;

function STATUSPOINTCHECK_QUESTLIST(status_gbox)
	local textlist = "";
	local statuspoint = GET_CHILD(status_gbox, "statuspoint_list", "ui::CGroupBox");
	local status = GET_CHILD(status_gbox, "status_list", "ui::CGroupBox");
	local stamina = GET_CHILD(status_gbox, "stamina_list", "ui::CGroupBox");
	local weight = GET_CHILD(status_gbox, "weight_list", "ui::CGroupBox");
	local zemina = GET_CHILD(status_gbox, "zemina_list", "ui::CGroupBox");
	statuspoint = tolua.cast(statuspoint, "ui::CGroupBox");
	status = tolua.cast(status, "ui::CGroupBox");
	stamina = tolua.cast(stamina, "ui::CGroupBox");
	weight = tolua.cast(weight, "ui::CGroupBox");
	zemina = tolua.cast(zemina, "ui::CGroupBox");

	--quest for status point
	STATUSPOINTCHECK_QUESTCHECK(statuspoint)
	--quest for status
	status:SetOffset(20,statuspoint:GetY()+statuspoint:GetHeight());
	STATUSPOINTCHECK_STATUSQUESTCHECK(status)
	--quest for stamina
	stamina:SetOffset(20,statuspoint:GetY()+statuspoint:GetHeight()+status:GetHeight());
	STATUSPOINTCHECK_STAMINAQUESTCHECK(stamina)
	--quest for weight
	weight:SetOffset(20,statuspoint:GetY()+statuspoint:GetHeight()+status:GetHeight()+stamina:GetHeight());
	STATUSPOINTCHECK_WHIGHTSQUESTCHECK(weight)
	--zemina
	zemina:SetOffset(20,statuspoint:GetY()+statuspoint:GetHeight()+status:GetHeight()+stamina:GetHeight()+weight:GetHeight());
	STATUSPOINTCHECK_ZEMINACHECK(zemina)

end

function STATUSPOINTCHECK_QUESTCHECK(statuspoint)
	--questprogresscheck_auto.ies
	local questList = {
		"20050", "8537", "20275", "8392", "20201", "8728", "8752", "80047", "20219", "8458", "8498", "20341", "30194", "90217", "60278", "50369", "72214", "72235", "80437", "80460", "72264"
	}
	local titleBody = "Quest List For Status Point";
	local body = "";
	local getPoint = 0;
	local sumPoint = 0;
	local ypos = 20;
	local title = statuspoint:CreateOrGetControl("richtext", "statuspointcheck_questcheck_title"  , 0, 0, 0, 0);
	for k, questNo in pairs(questList) do
	
		local gbox   = statuspoint:CreateOrGetControl("groupbox", "statuspointcheck_questcheck_group"..k , 0  , ypos, 885, ypos);
		tolua.cast(gbox, "ui::CGroupBox");
		gbox:SetSkinName("none");
		local name   = gbox:CreateOrGetControl("richtext", "statuspointcheck_questcheck_name"..k  , nameX  , 0, 0, 0);
		local result = gbox:CreateOrGetControl("richtext", "statuspointcheck_questcheck_result"..k, resultX, 0, 0, 0);
		local point  = gbox:CreateOrGetControl("richtext", "statuspointcheck_questcheck_point"..k , pointX , 0, 0, 0);
		local map    = gbox:CreateOrGetControl("richtext", "statuspointcheck_questcheck_map"..k   , mapX   , 0, 0, 0);
		local nameBody = "";
		local resultBody = "";
		local pointBody = "";
		local mapBody = "";
		local color = "";
		name = tolua.cast(name, "ui::CRichText");
		result = tolua.cast(result, "ui::CRichText");
		point = tolua.cast(point, "ui::CRichText");
		map = tolua.cast(map, "ui::CRichText");

		local tempPoint = 0;
		if questNo == "8458" or questNo == "8498" or questNo == "20341" then
			tempPoint = 1;
		end
		local questCls = GetClassByType('QuestProgressCheck', questNo);
		local questDetail = GetClassByType('QuestProgressCheck_Auto', questNo);
		sumPoint = sumPoint + tonumber(questDetail.Success_StatByBonus) + tempPoint;
		nameBody = questCls.Name;
		pointBody = tonumber(questDetail.Success_StatByBonus) + tempPoint.."Point"
		if STATUSPOINTCHECK_QUESTCLEARCHECK(questNo) then
			color = "{#FF3333}{ol}{b}{s16}";
			resultBody = "OK"
			mapBody = ""
			getPoint = getPoint + tonumber(questDetail.Success_StatByBonus) + tempPoint;
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
		statuspoint:Resize(statuspoint:GetWidth(),ypos)
	end
	title:SetText("{#000000}{s16}"..titleBody.."("..getPoint.."/"..sumPoint.."){/}{/}")
end

function STATUSPOINTCHECK_STATUSQUESTCHECK(status)
	--reward_property.ies
	local questList = {
		-- 19101 and 9109 is not active
		--"19051", "9105", "9110", "9106", "19112", "19021", "19101", "9102", "9103", "9109", "19071", "70709", "90077", "80171", "50221", "40760", "16640", "30294", "60042", "60206", "50382", "50398", "50408"
		"19051", "9105", "9110", "9106", "19112", "19021", "9102", "9103", "19071", "70709", "90077", "80171", "50221", "40760", "16640", "30294", "60042", "60206", "50382", "50398", "50408"
	}
	local titleBody = "Quest List For Status";
	local body = "";
	local ypos = 20;
	local title = status:CreateOrGetControl("richtext", "statuscheck_questcheck_title"  , 0, 0, 0, 0);
	for k, questNo in pairs(questList) do
		local gbox   = status:CreateOrGetControl("groupbox", "statuscheck_questcheck_group"..k , 0  , ypos, 885, ypos);
		tolua.cast(gbox, "ui::CGroupBox");
		gbox:SetSkinName("none");
		local name   = gbox:CreateOrGetControl("richtext", "statuscheck_questcheck_name"..k  , nameX  , 0, 0, 0);
		local result = gbox:CreateOrGetControl("richtext", "statuscheck_questcheck_result"..k, resultX, 0, 0, 0);
		local point  = gbox:CreateOrGetControl("richtext", "statuscheck_questcheck_point"..k , pointX , 0, 0, 0);
		local map    = gbox:CreateOrGetControl("richtext", "statuscheck_questcheck_map"..k   , mapX   , 0, 0, 0);
		local nameBody = "";
		local resultBody = "";
		local pointBody = "";
		local mapBody = "";
		local color = "";
		name = tolua.cast(name, "ui::CRichText");
		result = tolua.cast(result, "ui::CRichText");
		point = tolua.cast(point, "ui::CRichText");
		map = tolua.cast(map, "ui::CRichText");


		local questCls = GetClassByType('QuestProgressCheck', questNo);
		local pcProperty = GetClass('reward_property', questCls.ClassName)

		nameBody = questCls.Name;
		pointBody = ScpArgMsg(pcProperty.Property).."+"..pcProperty.Value
		if STATUSPOINTCHECK_QUESTCLEARCHECK(questNo) then
			color = "{#FF3333}{ol}{b}{s16}";
			resultBody = "OK"
			mapBody = ""
		else
			local mapprop;
			if "None" == questCls.StartMap then
				-- "19021" is StartMap None
				mapprop = geMapTable.GetMapProp(questCls.ProgMap);
			else
				mapprop = geMapTable.GetMapProp(questCls.StartMap);
			end
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
		status:Resize(status:GetWidth(),ypos)
	end
	title:SetText("{#000000}{s16}"..titleBody.."{/}{/}")
end

function STATUSPOINTCHECK_STAMINAQUESTCHECK(stamina)
	local questList = {
		"9108", "9100", "19062", "9104"
	}
	local titleBody = "Quest List For Stamina";
	local body = "";
	local getPoint = 0;
	local sumPoint = 0;
	local ypos = 20;
	local title = stamina:CreateOrGetControl("richtext", "staminacheck_questcheck_title"  , 0, 0, 0, 0);
	for k, questNo in pairs(questList) do
		local gbox   = stamina:CreateOrGetControl("groupbox", "staminacheck_questcheck_group"..k , 0  , ypos, 885, ypos);
		tolua.cast(gbox, "ui::CGroupBox");
		gbox:SetSkinName("none");
		local name   = gbox:CreateOrGetControl("richtext", "staminacheck_questcheck_name"..k  , nameX  , 0, 0, 0);
		local result = gbox:CreateOrGetControl("richtext", "staminacheck_questcheck_result"..k, resultX, 0, 0, 0);
		local point  = gbox:CreateOrGetControl("richtext", "staminacheck_questcheck_point"..k , pointX , 0, 0, 0);
		local map    = gbox:CreateOrGetControl("richtext", "staminacheck_questcheck_map"..k   , mapX   , 0, 0, 0);
		local nameBody = "";
		local resultBody = "";
		local pointBody = "";
		local mapBody = "";
		local color = "";
		name = tolua.cast(name, "ui::CRichText");
		result = tolua.cast(result, "ui::CRichText");
		point = tolua.cast(point, "ui::CRichText");
		map = tolua.cast(map, "ui::CRichText");

		local questCls = GetClassByType('QuestProgressCheck', questNo);
		local pcProperty = GetClass('reward_property', questCls.ClassName)
		sumPoint = sumPoint + tonumber(pcProperty.Value);
		nameBody = questCls.Name;
		pointBody = ScpArgMsg(pcProperty.Property).."+"..pcProperty.Value
		if STATUSPOINTCHECK_QUESTCLEARCHECK(questNo) then
			color = "{#FF3333}{ol}{b}{s16}";
			resultBody = "OK"
			mapBody = ""
			getPoint = getPoint + tonumber(pcProperty.Value);
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
		stamina:Resize(stamina:GetWidth(),ypos)
	end
	title:SetText("{#000000}{s16}"..titleBody.."("..getPoint.."/"..sumPoint.."){/}{/}")
end

function STATUSPOINTCHECK_WHIGHTSQUESTCHECK(weight)
	local questList = {
		"9107", "9111", "19041", "19081", "19091", "8487", "20212", "30016"
	}
	local titleBody = "Quest List For Weight";
	local body = "";
	local getPoint = 0;
	local sumPoint = 0;
	local ypos = 20;
	local title = weight:CreateOrGetControl("richtext", "weightcheck_questcheck_title"  , 0, 0, 0, 0);
	for k, questNo in pairs(questList) do
		local gbox   = weight:CreateOrGetControl("groupbox", "weightcheck_questcheck_group"..k , 0  , ypos, 885, ypos);
		tolua.cast(gbox, "ui::CGroupBox");
		gbox:SetSkinName("none");
		local name   = gbox:CreateOrGetControl("richtext", "weightcheck_questcheck_name"..k  , nameX  , 0, 0, 0);
		local result = gbox:CreateOrGetControl("richtext", "weightcheck_questcheck_result"..k, resultX, 0, 0, 0);
		local point  = gbox:CreateOrGetControl("richtext", "weightcheck_questcheck_point"..k , pointX , 0, 0, 0);
		local map    = gbox:CreateOrGetControl("richtext", "weightcheck_questcheck_map"..k   , mapX   , 0, 0, 0);
		local nameBody = "";
		local resultBody = "";
		local pointBody = "";
		local mapBody = "";
		local color = "";
		name = tolua.cast(name, "ui::CRichText");
		result = tolua.cast(result, "ui::CRichText");
		point = tolua.cast(point, "ui::CRichText");
		map = tolua.cast(map, "ui::CRichText");

		local questCls = GetClassByType('QuestProgressCheck', questNo);
		local pcProperty = GetClass('reward_property', questCls.ClassName)
		sumPoint = sumPoint + tonumber(pcProperty.Value);
		nameBody = questCls.Name;
		pointBody = weighttxt.."+"..pcProperty.Value
		if STATUSPOINTCHECK_QUESTCLEARCHECK(questNo) then
			color = "{#FF3333}{ol}{b}{s16}";
			resultBody = "OK"
			mapBody = ""
			getPoint = getPoint + tonumber(pcProperty.Value);
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
		weight:Resize(weight:GetWidth(),ypos)
	end
	title:SetText("{#000000}{s16}"..titleBody.."("..getPoint.."/"..sumPoint.."){/}{/}")
end

function STATUSPOINTCHECK_ZEMINACHECK(zemina)
	local mapList = {
		"f_siauliai_west", 
		"f_siauliai_out", 
		"f_siauliai_16", 
		"d_underfortress_59_2", 
		"f_rokas_31", 
		"f_flash_64", 
		"f_katyn_14", 
		"f_whitetrees_22_2", 
		"f_3cmlake_26_2", 
		"d_startower_76_2", 
		"f_3cmlake_86", 
		"f_dcapital_105"
	}
	local titleBody = "Zemina List";
	local body = "";
	local getPoint = 0;
	local sumPoint = 0;
	local ypos = 20;
	local title = zemina:CreateOrGetControl("richtext", "zeminacheck_questcheck_title"  , 0, 0, 0, 0);
	for k, mapClassName in pairs(mapList) do
		local name   = zemina:CreateOrGetControl("richtext", "zeminacheck_questcheck_name"..k  , nameX  , ypos, 0, 0);
		local result = zemina:CreateOrGetControl("richtext", "zeminacheck_questcheck_result"..k, resultX, ypos, 0, 0);
		local nameBody = "";
		local resultBody = "";
		local color = "";
		name = tolua.cast(name, "ui::CRichText");
		result = tolua.cast(result, "ui::CRichText");

		local mapprop = geMapTable.GetMapProp(mapClassName);
		local mapName = tostring(dictionary.ReplaceDicIDInCompStr(mapprop:GetName()));
		sumPoint = sumPoint + 1;
		nameBody = mapName;
		if STATUSPOINTCHECK_ZEMINACLEARCHECK(mapClassName) then
			color = "{#FF3333}{ol}{b}{s16}";
			resultBody = "OK"
			getPoint = getPoint + 1;
		else
			color = "{#666666}{ol}{b}{s16}";
			resultBody = "NO"
		end
		name:SetText(color..nameBody.."{/}{/}{/}{/}")
		result:SetText(color..resultBody.."{/}{/}{/}{/}")
		ypos = ypos + name:GetHeight();
		zemina:Resize(zemina:GetWidth(),ypos)
	end
	title:SetText("{#000000}{s16}"..titleBody.."("..getPoint.."/"..sumPoint.."){/}{/}")
end

function STATUSPOINTCHECK_ZEMINACLEARCHECK(mapClassName)
	local idspace = 'GenType_'..mapClassName;
	local idcount = GetClassCount(idspace)
	local flg = true;
	for i = 0, idcount -1 do
		local classIES = GetClassByIndex(idspace, i);
		if classIES.ClassType == "statue_zemina" then
			local state = GetNPCState(mapClassName, classIES.GenType)
			if state == 20 or state == 1 then
				return true;
			else
				return false;
			end
		end
	end
end
