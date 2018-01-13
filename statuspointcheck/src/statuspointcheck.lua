--アドオン名（大文字）
local addonName = "STATUSPOINTCHECK";
local addonNameLower = string.lower(addonName);
--作者名
local author = "torahamu";

--アドオン内で使用する領域を作成。以下、ファイル内のスコープではグローバル変数gでアクセス可
_G["ADDONS"] = _G["ADDONS"] or {};
_G["ADDONS"][author] = _G["ADDONS"][author] or {};
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {};
local g = _G["ADDONS"][author][addonName];

--ライブラリ読み込み
local acutil = require('acutil');

-- フレーム内文字
if option.GetCurrentCountry()=="Japanese" then
	buttontxt = "クエスト確認";
	tooltiptxt = "ステータスポイントがもらえるクエストを{nl}クリアしているかどうか確認できます";
	weighttxt = "所持量"
else
	buttontxt = "Check Quest";
	tooltiptxt = "Check whether you are clearing quests{nl}that receive status points";
	weighttxt = "Weight"
end

local nameX=20;
local resultX=400;
local pointX=440;
local mapX=550;

--マップ読み込み時処理（1度だけ）
function STATUSPOINTCHECK_ON_INIT(addon, frame)
	local frame = ui.GetFrame("status");
	local statuspoint_button = frame:CreateOrGetControl("button", "STATUSPOINT_BUTTON", 350, 140, 120, 40);
	statuspoint_button = tolua.cast(statuspoint_button, "ui::CButton");
	statuspoint_button:SetFontName("white_16_ol");
	statuspoint_button:SetText(buttontxt);
	statuspoint_button:SetTextTooltip(tooltiptxt);
	statuspoint_button:SetClickSound("button_click_big");
	statuspoint_button:SetOverSound("button_over");
	statuspoint_button:SetAnimation("MouseOnAnim", "btn_mouseover");
	statuspoint_button:SetAnimation("MouseOffAnim", "btn_mouseoff");
	statuspoint_button:SetEventScript(ui.LBUTTONDOWN, "STATUSPOINTCHECK_TOGGLE_FRAME");
end

function STATUSPOINTCHECK_TOGGLE_FRAME()
	local frame = ui.GetFrame("statuspointcheck");
	if frame:IsVisible() == 1 then
		ui.CloseFrame("statuspointcheck");
		return;
	end

	local bg_gbox = GET_CHILD(frame, "bg", "ui::CGroupBox");
	local text_gbox = GET_CHILD(bg_gbox, "text_gbox", "ui::CGroupBox");
	text_gbox = tolua.cast(text_gbox, "ui::CGroupBox");
	text_gbox:SetScrollBar(text_gbox:GetHeight());
	STATUSPOINTCHECK_QUESTLIST(text_gbox);

	local statusframe = ui.GetFrame("status");
	local statuspoint_button = GET_CHILD_RECURSIVELY(statusframe, "STATUSPOINT_BUTTON", "ui::CButton");
	local x = statuspoint_button:GetGlobalX() + 150;
	local y = statuspoint_button:GetGlobalY() - 100;
	frame:SetOffset(x,y);

	local closebtn = frame:CreateOrGetControl("button", "STATUSPOINTCHECK_CLOSE_BUTTON", 0, 0, 44, 44);
	closebtn = tolua.cast(closebtn, "ui::CButton");
	closebtn:SetImage("testclose_button");
	closebtn:SetGravity(ui.RIGHT, ui.TOP);
	closebtn:SetClickSound("button_click_big");
	closebtn:SetOverSound("button_over");
	closebtn:SetAnimation("MouseOnAnim", "btn_mouseover");
	closebtn:SetAnimation("MouseOffAnim", "btn_mouseoff");
	closebtn:SetEventScript(ui.LBUTTONDOWN, "STATUSPOINTCHECK_CLOSE_FRAME");

	frame:ShowWindow(1);
end

function STATUSPOINTCHECK_CLOSE_FRAME()
	ui.CloseFrame("statuspointcheck");
end

function STATUSPOINTCHECK_QUESTLIST(text_gbox)
	local textlist = "";
	local statuspoint = GET_CHILD(text_gbox, "statuspoint_list", "ui::CGroupBox");
	local status = GET_CHILD(text_gbox, "status_list", "ui::CGroupBox");
	local stamina = GET_CHILD(text_gbox, "stamina_list", "ui::CGroupBox");
	local weight = GET_CHILD(text_gbox, "weight_list", "ui::CGroupBox");
	local zemina = GET_CHILD(text_gbox, "zemina_list", "ui::CGroupBox");
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
	local questList = {
		"20050", "8537", "20275", "8392", "20201", "8728", "8752", "80047", "20219", "8458", "8498", "20341", "30194", "90217", "60278", "50369"
	}
	local titleBody = "Quest List For Status Point";
	local body = "";
	local getPoint = 0;
	local sumPoint = 0;
	local ypos = 20;
	local title = statuspoint:CreateOrGetControl("richtext", "statuspointcheck_questcheck_title"  , 0, 0, 0, 0);
	for k, questNo in pairs(questList) do
		local name   = statuspoint:CreateOrGetControl("richtext", "statuspointcheck_questcheck_name"..k  , nameX  , ypos, 0, 0);
		local result = statuspoint:CreateOrGetControl("richtext", "statuspointcheck_questcheck_result"..k, resultX, ypos, 0, 0);
		local point  = statuspoint:CreateOrGetControl("richtext", "statuspointcheck_questcheck_point"..k , pointX , ypos, 0, 0);
		local map    = statuspoint:CreateOrGetControl("richtext", "statuspointcheck_questcheck_map"..k   , mapX   , ypos, 0, 0);
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
		ypos = ypos + name:GetHeight();
		statuspoint:Resize(statuspoint:GetWidth(),ypos)
	end
	title:SetText("{#000000}{s16}"..titleBody.."("..getPoint.."/"..sumPoint.."){/}{/}")
end

function STATUSPOINTCHECK_STATUSQUESTCHECK(status)
	local questList = {
		-- 19101 and 9109 is not active
		--"19051", "9105", "9110", "9106", "19112", "19021", "19101", "9102", "9103", "9109", "19071"
		"19051", "9105", "9110", "9106", "19112", "19021", "9102", "9103", "19071"
	}
	local titleBody = "Quest List For Status";
	local body = "";
	local ypos = 20;
	local title = status:CreateOrGetControl("richtext", "statuscheck_questcheck_title"  , 0, 0, 0, 0);
	for k, questNo in pairs(questList) do
		local name   = status:CreateOrGetControl("richtext", "statuscheck_questcheck_name"..k  , nameX  , ypos, 0, 0);
		local result = status:CreateOrGetControl("richtext", "statuscheck_questcheck_result"..k, resultX, ypos, 0, 0);
		local point  = status:CreateOrGetControl("richtext", "statuscheck_questcheck_point"..k , pointX , ypos, 0, 0);
		local map    = status:CreateOrGetControl("richtext", "statuscheck_questcheck_map"..k   , mapX   , ypos, 0, 0);
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
		local name   = stamina:CreateOrGetControl("richtext", "staminacheck_questcheck_name"..k  , nameX  , ypos, 0, 0);
		local result = stamina:CreateOrGetControl("richtext", "staminacheck_questcheck_result"..k, resultX, ypos, 0, 0);
		local point  = stamina:CreateOrGetControl("richtext", "staminacheck_questcheck_point"..k , pointX , ypos, 0, 0);
		local map    = stamina:CreateOrGetControl("richtext", "staminacheck_questcheck_map"..k   , mapX   , ypos, 0, 0);
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
		ypos = ypos + name:GetHeight();
		stamina:Resize(stamina:GetWidth(),ypos)
	end
	title:SetText("{#000000}{s16}"..titleBody.."("..getPoint.."/"..sumPoint.."){/}{/}")
end

function STATUSPOINTCHECK_WHIGHTSQUESTCHECK(weight)
	local questList = {
		"9107", "9111", "19041", "19081", "19091", "8487", "20212"
	}
	local titleBody = "Quest List For Weight";
	local body = "";
	local getPoint = 0;
	local sumPoint = 0;
	local ypos = 20;
	local title = weight:CreateOrGetControl("richtext", "weightcheck_questcheck_title"  , 0, 0, 0, 0);
	for k, questNo in pairs(questList) do
		local name   = weight:CreateOrGetControl("richtext", "weightcheck_questcheck_name"..k  , nameX  , ypos, 0, 0);
		local result = weight:CreateOrGetControl("richtext", "weightcheck_questcheck_result"..k, resultX, ypos, 0, 0);
		local point  = weight:CreateOrGetControl("richtext", "weightcheck_questcheck_point"..k , pointX , ypos, 0, 0);
		local map    = weight:CreateOrGetControl("richtext", "weightcheck_questcheck_map"..k   , mapX   , ypos, 0, 0);
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
		ypos = ypos + name:GetHeight();
		weight:Resize(weight:GetWidth(),ypos)
	end
	title:SetText("{#000000}{s16}"..titleBody.."("..getPoint.."/"..sumPoint.."){/}{/}")
end

function STATUSPOINTCHECK_QUESTCLEARCHECK(questNo)
	local questCls = GetClassByType('QuestProgressCheck', questNo);
	local pc = GetMyPCObject();
	local result = SCR_QUEST_CHECK(pc, questCls.ClassName)
	if result == 'PROGRESS' or result == 'SUCCESS' or result == 'COMPLETE' then
		return true
	end
	return false
end

function STATUSPOINTCHECK_ZEMINACHECK(zemina)
	local mapList = {
		"f_siauliai_west", "f_siauliai_out", "f_siauliai_16", "d_underfortress_59_2", "f_rokas_31", "f_flash_64", "f_katyn_14", "f_whitetrees_22_2", "f_3cmlake_26_2", "d_startower_76_2"
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
	local mapprop = geMapTable.GetMapProp(mapClassName);
	local idspace = 'GenType_'..mapClassName;
	local npcState = session.GetMapNPCState(mapClassName);
	if nil == npcState then
		return false;
	end
	local idcount = GetClassCount(idspace)
	local flg = true;
	for i = 0, idcount -1 do
		local classIES = GetClassByIndex(idspace, i);
		if classIES.ClassType == "statue_zemina" then
			if npcState:FindAndGet(classIES.GenType) == 20 then
				return true;
			else
				return false;
			end
		end
	end
end
