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
else
	buttontxt = "Check Quest";
	tooltiptxt = "Check whether you are clearing quests{nl}that receive status points";
end

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
	local statuspoint = GET_CHILD(text_gbox, "statuspoint_list", "ui::CRichText");
	local status = GET_CHILD(text_gbox, "status_list", "ui::CRichText");
	local stamina = GET_CHILD(text_gbox, "stamina_list", "ui::CRichText");
	local weight = GET_CHILD(text_gbox, "weight_list", "ui::CRichText");
	local zemina = GET_CHILD(text_gbox, "zemina_list", "ui::CRichText");
	--quest for status point
	statuspoint:SetTextByKey("value", STATUSPOINTCHECK_QUESTCHECK());
	--quest for status
	status:SetOffset(20,statuspoint:GetY()+statuspoint:GetHeight());
	status:SetTextByKey("value", STATUSPOINTCHECK_STATUSQUESTCHECK());
	--quest for stamina
	stamina:SetOffset(20,statuspoint:GetY()+statuspoint:GetHeight()+status:GetHeight());
	stamina:SetTextByKey("value", STATUSPOINTCHECK_STAMINAQUESTCHECK());
	--quest for weight
	weight:SetOffset(20,statuspoint:GetY()+statuspoint:GetHeight()+status:GetHeight()+stamina:GetHeight());
	weight:SetTextByKey("value", STATUSPOINTCHECK_WHIGHTSQUESTCHECK());
	--zemina
	zemina:SetOffset(20,statuspoint:GetY()+statuspoint:GetHeight()+status:GetHeight()+stamina:GetHeight()+weight:GetHeight());
	zemina:SetTextByKey("value", STATUSPOINTCHECK_ZEMINACHECK());

end

function STATUSPOINTCHECK_QUESTCHECK()
	local questList = {
		"20050", "8537", "20275", "8392", "20201", "8728", "8752", "80047", "20219", "8458", "8498", "20341", "30194", "90217", "60278", "50369"
	}
	local title = "Quest List For Status Point";
	local body = "";
	local getPoint = 0;
	local sumPoint = 0;
	for k, questNo in pairs(questList) do
		local tempPoint = 0;
		if questNo == "8458" or questNo == "8498" or questNo == "20341" then
			tempPoint = 1;
		end
		local questCls = GetClassByType('QuestProgressCheck', questNo);
		local cls = GetClassByType('QuestProgressCheck_Auto', questNo);
		sumPoint = sumPoint + tonumber(cls.Success_StatByBonus) + tempPoint;
		if STATUSPOINTCHECK_QUESTCLEARCHECK(questNo) then
			getPoint = getPoint + tonumber(cls.Success_StatByBonus) + tempPoint;
			body = body .. "  {#FF3333}{ol}{b}{s16}"..questCls.Name..":OK - ("..tonumber(cls.Success_StatByBonus).."Point){/}{/}{/}{/}{nl}"
		else
			local mapprop = geMapTable.GetMapProp(questCls.StartMap);
			local mapName = tostring(dictionary.ReplaceDicIDInCompStr(mapprop:GetName()));
			body = body .. "  {#666666}{ol}{b}{s16}"..questCls.Name..":NO - ("..tonumber(cls.Success_StatByBonus).."Point) - "..mapName.."[Level:"..tostring(questCls.Level).."]{/}{/}{/}{/}{nl}"
		end
	end
	title = title.."("..getPoint.."/"..sumPoint.."){nl}"
	return title..body
end

function STATUSPOINTCHECK_STATUSQUESTCHECK()
	local questList = {
		-- 19101 and 9109 is not active
		--"19051", "9105", "9110", "9106", "19112", "19021", "19101", "9102", "9103", "9109", "19071"
		"19051", "9105", "9110", "9106", "19112", "19021", "9102", "9103", "19071"
	}
	local title = "Quest List For Status";
	local body = "";
	for k, questNo in pairs(questList) do
		local questCls = GetClassByType('QuestProgressCheck', questNo);
		local pcProperty = GetClass('reward_property', questCls.ClassName)
		if STATUSPOINTCHECK_QUESTCLEARCHECK(questNo) then
			body = body .. "  {#FF3333}{ol}{b}{s16}"..questCls.Name..":OK - ("..ScpArgMsg(pcProperty.Property).."+"..pcProperty.Value.."){/}{/}{/}{/}{nl}"
		else
			local mapprop;
			if "None" == questCls.StartMap then
				-- "19021" is StartMap None
				mapprop = geMapTable.GetMapProp(questCls.ProgMap);
			else
				mapprop = geMapTable.GetMapProp(questCls.StartMap);
			end
			local mapName = tostring(dictionary.ReplaceDicIDInCompStr(mapprop:GetName()));
			body = body .. "  {#666666}{ol}{b}{s16}"..questCls.Name..":NO - ("..ScpArgMsg(pcProperty.Property).."+"..pcProperty.Value..") - "..mapName.."[Level:"..tostring(questCls.Level).."]{/}{/}{/}{/}{nl}"
		end
	end
	title = title.."{nl}"
	return title..body
end

function STATUSPOINTCHECK_STAMINAQUESTCHECK()
	local questList = {
		"9108", "9100", "19062", "9104"
	}
	local title = "Quest List For Stamina";
	local body = "";
	local getPoint = 0;
	local sumPoint = 0;
	for k, questNo in pairs(questList) do
		local questCls = GetClassByType('QuestProgressCheck', questNo);
		local pcProperty = GetClass('reward_property', questCls.ClassName)
		sumPoint = sumPoint + tonumber(pcProperty.Value);
		if STATUSPOINTCHECK_QUESTCLEARCHECK(questNo) then
			getPoint = getPoint + tonumber(pcProperty.Value);
			body = body .. "  {#FF3333}{ol}{b}{s16}"..questCls.Name..":OK - ("..ScpArgMsg(pcProperty.Property).."+"..pcProperty.Value.."){/}{/}{/}{/}{nl}"
		else
			if "None" == questCls.StartMap then
				body = body .. "  {#666666}{ol}{b}{s16}"..questCls.Name..":NO - ("..ScpArgMsg(pcProperty.Property).."+"..pcProperty.Value.."){/}{/}{/}{/}{nl}"
			else
				local mapprop = geMapTable.GetMapProp(questCls.StartMap);
				local mapName = tostring(dictionary.ReplaceDicIDInCompStr(mapprop:GetName()));
				body = body .. "  {#666666}{ol}{b}{s16}"..questCls.Name..":NO - ("..ScpArgMsg(pcProperty.Property).."+"..pcProperty.Value..") - "..mapName.."[Level:"..tostring(questCls.Level).."]{/}{/}{/}{/}{nl}"
			end
		end
	end
	title = title.."("..getPoint.."/"..sumPoint.."){nl}"
	return title..body
end

function STATUSPOINTCHECK_WHIGHTSQUESTCHECK()
	local questList = {
		"9107", "9111", "19041", "19081", "19091", "8487", "20212"
	}
	local title = "Quest List For Weight";
	local body = "";
	local getPoint = 0;
	local sumPoint = 0;
	for k, questNo in pairs(questList) do
		local questCls = GetClassByType('QuestProgressCheck', questNo);
		local pcProperty = GetClass('reward_property', questCls.ClassName)
		sumPoint = sumPoint + tonumber(pcProperty.Value);
		if STATUSPOINTCHECK_QUESTCLEARCHECK(questNo) then
			getPoint = getPoint + tonumber(pcProperty.Value);
			body = body .. "  {#FF3333}{ol}{b}{s16}"..questCls.Name..":OK - ("..ScpArgMsg(pcProperty.Property).."+"..pcProperty.Value.."){/}{/}{/}{/}{nl}"
		else
			if "None" == questCls.StartMap then
				body = body .. "  {#666666}{ol}{b}{s16}"..questCls.Name..":NO - ("..ScpArgMsg(pcProperty.Property).."+"..pcProperty.Value.."){/}{/}{/}{/}{nl}"
			else
				local mapprop = geMapTable.GetMapProp(questCls.StartMap);
				local mapName = tostring(dictionary.ReplaceDicIDInCompStr(mapprop:GetName()));
				body = body .. "  {#666666}{ol}{b}{s16}"..questCls.Name..":NO - ("..ScpArgMsg(pcProperty.Property).."+"..pcProperty.Value..") - "..mapName.."[Level:"..tostring(questCls.Level).."]{/}{/}{/}{/}{nl}"
			end
		end
	end
	title = title.."("..getPoint.."/"..sumPoint.."){nl}"
	return title..body
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


function STATUSPOINTCHECK_ZEMINACHECK()
	local questList = {
		"f_siauliai_west", "f_siauliai_out", "f_siauliai_16", "d_underfortress_59_2", "f_rokas_31", "f_flash_64", "f_katyn_14", "f_whitetrees_22_2", "f_3cmlake_26_2", "d_startower_76_2"
	}
	local title = "Zemina List";
	local body = "";
	local getPoint = 0;
	local sumPoint = 0;
	for k, mapClassName in pairs(questList) do
		local mapprop = geMapTable.GetMapProp(mapClassName);
		local mapName = tostring(dictionary.ReplaceDicIDInCompStr(mapprop:GetName()));
		sumPoint = sumPoint + 1;
		if STATUSPOINTCHECK_ZEMINACLEARCHECK(mapClassName) then
			getPoint = getPoint + tonumber(cls.Success_StatByBonus);
			body = body .. "  {#FF3333}{ol}{b}{s16}"..mapName..":OK{/}{/}{/}{/}{nl}"
		else
			body = body .. "  {#666666}{ol}{b}{s16}"..mapName..":NO{/}{/}{/}{/}{nl}"
		end
	end
	title = title.."("..getPoint.."/"..sumPoint.."){nl}"
	return title..body
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


function STATUSPOINTCHECK_ZEMINACHECK_bak(mapname)
	local mapClassName = mapname;
	local mapprop = geMapTable.GetMapProp(mapClassName);
	local mapName = tostring(dictionary.ReplaceDicIDInCompStr(mapprop:GetName()));
	local idspace = 'GenType_'..mapClassName;
	local npcState = session.GetMapNPCState(mapClassName);
	if nil == npcState then
		return "{#666666}{ol}{b}{s16}"..mapName..":NO{nl}{/}{/}{/}{/}"
	end
	local idcount = GetClassCount(idspace)
	local flg = true;
	for i = 0, idcount -1 do
		local classIES = GetClassByIndex(idspace, i);
		if classIES.ClassType == "statue_zemina" then
			if npcState:FindAndGet(classIES.GenType) ~= 20 then
				flg = false;
			end
		end
	end
	if flg then
		return "{#FF3333}{ol}{b}{s16}"..mapName..":OK{nl}{/}{/}{/}{/}"
	else
		return "{#666666}{ol}{b}{s16}"..mapName..":NO{nl}{/}{/}{/}{/}"
	end
end
