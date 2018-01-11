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

	STATUSPOINTCHECK_QUESTLIST(frame);
	local magictext = GET_CHILD(frame, "richtext_magic_list", "ui::CRichText");
	local magictitle = GET_CHILD(frame, "richtext_title", "ui::CRichText");
	magictext = tolua.cast(magictext, "ui::CRichText");
	magictitle = tolua.cast(magictitle, "ui::CRichText");

	local height = frame:GetUserConfig("TITLE_MARGIN_Y") * 2  + magictitle:GetHeight();
	height = height +frame:GetUserConfig("BODY_MARGIN_Y") * 2 + magictext:GetHeight();

	local statusframe = ui.GetFrame("status");
	local statuspoint_button = GET_CHILD_RECURSIVELY(statusframe, "STATUSPOINT_BUTTON", "ui::CButton");
	local x = statuspoint_button:GetGlobalX() + 150;
	local y = statuspoint_button:GetGlobalY() - 100;
	frame:SetOffset(x,y);
	local gbox_bg = GET_CHILD(frame, "bg", "ui::CGroupBox");
	if gbox_bg ~= nil then
		gbox_bg:Resize(magictext:GetWidth(), height);
	end

	frame:Resize(gbox_bg:GetWidth(), height);

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

function STATUSPOINTCHECK_QUESTLIST(frame)
	local textlist = "";
	local magictext = GET_CHILD(frame, "richtext_magic_list", "ui::CRichText");
	local magictitle = GET_CHILD(frame, "richtext_title", "ui::CRichText");
	--quest for status point
	textlist = textlist.."Quest List For Status Point{nl}";
	textlist = textlist.."  "..STATUSPOINTCHECK_QUESTCHECK("20050");
	textlist = textlist.."  "..STATUSPOINTCHECK_QUESTCHECK("8537");
	textlist = textlist.."  "..STATUSPOINTCHECK_QUESTCHECK("20275");
	textlist = textlist.."  "..STATUSPOINTCHECK_QUESTCHECK("8392");
	textlist = textlist.."  "..STATUSPOINTCHECK_QUESTCHECK("20201");
	textlist = textlist.."  "..STATUSPOINTCHECK_QUESTCHECK("8728");
	textlist = textlist.."  "..STATUSPOINTCHECK_QUESTCHECK("8752");
	textlist = textlist.."  "..STATUSPOINTCHECK_QUESTCHECK("80047");
	textlist = textlist.."  "..STATUSPOINTCHECK_QUESTCHECK("8498");
	textlist = textlist.."  "..STATUSPOINTCHECK_QUESTCHECK("20341");
	textlist = textlist.."  "..STATUSPOINTCHECK_QUESTCHECK("30194");
	textlist = textlist.."  "..STATUSPOINTCHECK_QUESTCHECK("90217");
	textlist = textlist.."  "..STATUSPOINTCHECK_QUESTCHECK("60278");
	textlist = textlist.."  "..STATUSPOINTCHECK_QUESTCHECK("50369");
	--quest for status
	textlist = textlist.."Quest List For Status{nl}";
	textlist = textlist.."  "..STATUSPOINTCHECK_QUESTCHECK("19051");
	textlist = textlist.."  "..STATUSPOINTCHECK_QUESTCHECK("9105");
	textlist = textlist.."  "..STATUSPOINTCHECK_QUESTCHECK("9110");
	textlist = textlist.."  "..STATUSPOINTCHECK_QUESTCHECK("9106");
	textlist = textlist.."  "..STATUSPOINTCHECK_QUESTCHECK("19112");
	--quest for stamina
	textlist = textlist.."Quest List For Stamina{nl}";
	textlist = textlist.."  "..STATUSPOINTCHECK_QUESTCHECK("9108");
	textlist = textlist.."  "..STATUSPOINTCHECK_QUESTCHECK("9100");
	textlist = textlist.."  "..STATUSPOINTCHECK_QUESTCHECK("19062");
	textlist = textlist.."  "..STATUSPOINTCHECK_QUESTCHECK("9104");
	--zemina
	textlist = textlist.."Zemina List{nl}";
	textlist = textlist.."  "..STATUSPOINTCHECK_ZEMINACHECK("f_siauliai_west");
	textlist = textlist.."  "..STATUSPOINTCHECK_ZEMINACHECK("f_siauliai_out");
	textlist = textlist.."  "..STATUSPOINTCHECK_ZEMINACHECK("f_siauliai_16");
	textlist = textlist.."  "..STATUSPOINTCHECK_ZEMINACHECK("d_underfortress_59_2");
	textlist = textlist.."  "..STATUSPOINTCHECK_ZEMINACHECK("f_rokas_31");
	textlist = textlist.."  "..STATUSPOINTCHECK_ZEMINACHECK("f_flash_64");
	textlist = textlist.."  "..STATUSPOINTCHECK_ZEMINACHECK("f_katyn_14");
	textlist = textlist.."  "..STATUSPOINTCHECK_ZEMINACHECK("f_whitetrees_22_2");
	textlist = textlist.."  "..STATUSPOINTCHECK_ZEMINACHECK("f_3cmlake_26_2");
	textlist = textlist.."  "..STATUSPOINTCHECK_ZEMINACHECK("d_startower_76_2");
	magictext:SetTextByKey("value", textlist);

end

function STATUSPOINTCHECK_QUESTCHECK(questNo)
	local questCls = GetClassByType('QuestProgressCheck', questNo);
	local pc = GetMyPCObject();
	local result = SCR_QUEST_CHECK(pc, questCls.ClassName)
	if result == 'PROGRESS' or result == 'SUCCESS' or result == 'COMPLETE' then
		return "{#FF3333}{ol}{b}{s16}"..questCls.Name..":OK{nl}{/}{/}{/}{/}"
	end
	local mapprop = geMapTable.GetMapProp(questCls.StartMap);
	local mapName = tostring(dictionary.ReplaceDicIDInCompStr(mapprop:GetName()));
	return "{#666666}{ol}{b}{s16}"..questCls.Name..":NO - "..mapName.."[Level:"..tostring(questCls.Level).."]{nl}{/}{/}{/}{/}"
end

function STATUSPOINTCHECK_ZEMINACHECK(mapname)
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
