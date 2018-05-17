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

	STATUSPOINTCHECK_CREATE_FRAME(frame)

	local statusframe = ui.GetFrame("status");
	local statuspoint_button = GET_CHILD_RECURSIVELY(statusframe, "STATUSPOINT_BUTTON", "ui::CButton");
	local x = statuspoint_button:GetGlobalX() + 150;
	local y = statuspoint_button:GetGlobalY() - 100;
	frame:SetOffset(x,y);

	frame:ShowWindow(1);
end

function STATUSPOINTCHECK_CLOSE_FRAME()
	ui.CloseFrame("statuspointcheck");
end

function STATUSPOINTCHECK_CREATE_FRAME(frame)

	local bg_gbox = GET_CHILD(frame, "bg", "ui::CGroupBox");

	local closebtn = frame:CreateOrGetControl("button", "STATUSPOINTCHECK_CLOSE_BUTTON", 0, 0, 44, 44);
	closebtn = tolua.cast(closebtn, "ui::CButton");
	closebtn:SetImage("testclose_button");
	closebtn:SetGravity(ui.RIGHT, ui.TOP);
	closebtn:SetClickSound("button_click_big");
	closebtn:SetOverSound("button_over");
	closebtn:SetAnimation("MouseOnAnim", "btn_mouseover");
	closebtn:SetAnimation("MouseOffAnim", "btn_mouseoff");
	closebtn:SetEventScript(ui.LBUTTONDOWN, "STATUSPOINTCHECK_CLOSE_FRAME");

	local footer = GET_CHILD(bg_gbox, "footer", "ui::CGroupBox");
	footer = tolua.cast(footer, "ui::CGroupBox");
	local statusquest_button = footer:CreateOrGetControl("button", "STATUSPOINT_STATUS_BUTTON", 80, 0, 150, 40);
	statusquest_button = tolua.cast(statusquest_button, "ui::CButton");
	statusquest_button:SetFontName("white_16_ol");
	statusquest_button:SetText("Status");
	statusquest_button:SetClickSound("button_click_big");
	statusquest_button:SetOverSound("button_over");
	statusquest_button:SetAnimation("MouseOnAnim", "btn_mouseover");
	statusquest_button:SetAnimation("MouseOffAnim", "btn_mouseoff");
	statusquest_button:SetEventScript(ui.LBUTTONDOWN, "STATUSPOINT_OPEN_STATUS");

	local practonium_button = footer:CreateOrGetControl("button", "STATUSPOINT_PRACTONIUM_BUTTON", 280, 0, 150, 40);
	practonium_button = tolua.cast(practonium_button, "ui::CButton");
	practonium_button:SetFontName("white_16_ol");
	practonium_button:SetText("Practonium");
	practonium_button:SetClickSound("button_click_big");
	practonium_button:SetOverSound("button_over");
	practonium_button:SetAnimation("MouseOnAnim", "btn_mouseover");
	practonium_button:SetAnimation("MouseOffAnim", "btn_mouseoff");
	practonium_button:SetEventScript(ui.LBUTTONDOWN, "STATUSPOINT_OPEN_PRACTONIUM");

	local masterquest_button = footer:CreateOrGetControl("button", "STATUSPOINT_MASTERQUEST_BUTTON", 480, 0, 150, 40);
	masterquest_button = tolua.cast(masterquest_button, "ui::CButton");
	masterquest_button:SetFontName("white_16_ol");
	masterquest_button:SetText("Master Quest");
	masterquest_button:SetClickSound("button_click_big");
	masterquest_button:SetOverSound("button_over");
	masterquest_button:SetAnimation("MouseOnAnim", "btn_mouseover");
	masterquest_button:SetAnimation("MouseOffAnim", "btn_mouseoff");
	masterquest_button:SetEventScript(ui.LBUTTONDOWN, "STATUSPOINT_OPEN_MASTERQUEST");

	local vakarine_button = footer:CreateOrGetControl("button", "STATUSPOINT_VAKARINE_BUTTON", 680, 0, 150, 40);
	vakarine_button = tolua.cast(vakarine_button, "ui::CButton");
	vakarine_button:SetFontName("white_16_ol");
	vakarine_button:SetText("Vakarine");
	vakarine_button:SetClickSound("button_click_big");
	vakarine_button:SetOverSound("button_over");
	vakarine_button:SetAnimation("MouseOnAnim", "btn_mouseover");
	vakarine_button:SetAnimation("MouseOffAnim", "btn_mouseoff");
	vakarine_button:SetEventScript(ui.LBUTTONDOWN, "STATUSPOINT_OPEN_VAKARINE");

	local status_gbox = GET_CHILD(bg_gbox, "status_gbox", "ui::CGroupBox");
	status_gbox = tolua.cast(status_gbox, "ui::CGroupBox");
	status_gbox:SetScrollBar(status_gbox:GetHeight());
	STATUSPOINTCHECK_QUESTLIST(status_gbox);

	local practonium_gbox = GET_CHILD(bg_gbox, "practonium_gbox", "ui::CGroupBox");
	practonium_gbox = tolua.cast(practonium_gbox, "ui::CGroupBox");
	practonium_gbox:SetScrollBar(practonium_gbox:GetHeight());
	STATUSPOINTCHECK_PRACTONIUM_LIST(practonium_gbox)

	local master_gbox = GET_CHILD(bg_gbox, "master_gbox", "ui::CGroupBox");
	master_gbox = tolua.cast(master_gbox, "ui::CGroupBox");
	master_gbox:SetScrollBar(master_gbox:GetHeight());
	STATUSPOINTCHECK_MASTER_QUEST_LIST(master_gbox)

	local vakarine_gbox = GET_CHILD(bg_gbox, "vakarine_gbox", "ui::CGroupBox");
	vakarine_gbox = tolua.cast(vakarine_gbox, "ui::CGroupBox");
	vakarine_gbox:SetScrollBar(vakarine_gbox:GetHeight());
	STATUSPOINTCHECK_WARP_LIST(vakarine_gbox)

	local title = GET_CHILD(bg_gbox, "title", "ui::CRichText");
	title:SetText("{@st68b}{s18}bonus point{/}{/}");
	status_gbox:ShowWindow(1);
	practonium_gbox:ShowWindow(0);
	master_gbox:ShowWindow(0);
	vakarine_gbox:ShowWindow(0);
end

function STATUSPOINT_OPEN_STATUS()
	local frame = ui.GetFrame("statuspointcheck");
	local bg_gbox = GET_CHILD(frame, "bg", "ui::CGroupBox");
	local status_gbox = GET_CHILD(bg_gbox, "status_gbox", "ui::CGroupBox");
	local practonium_gbox = GET_CHILD(bg_gbox, "practonium_gbox", "ui::CGroupBox");
	local master_gbox = GET_CHILD(bg_gbox, "master_gbox", "ui::CGroupBox");
	local vakarine_gbox = GET_CHILD(bg_gbox, "vakarine_gbox", "ui::CGroupBox");
	local title = GET_CHILD(bg_gbox, "title", "ui::CRichText");
	title:SetText("{@st68b}{s18}bonus point{/}{/}");
	status_gbox:ShowWindow(1);
	practonium_gbox:ShowWindow(0);
	master_gbox:ShowWindow(0);
	vakarine_gbox:ShowWindow(0);
end

function STATUSPOINT_OPEN_PRACTONIUM()
	local frame = ui.GetFrame("statuspointcheck");
	local bg_gbox = GET_CHILD(frame, "bg", "ui::CGroupBox");
	local status_gbox = GET_CHILD(bg_gbox, "status_gbox", "ui::CGroupBox");
	local practonium_gbox = GET_CHILD(bg_gbox, "practonium_gbox", "ui::CGroupBox");
	local master_gbox = GET_CHILD(bg_gbox, "master_gbox", "ui::CGroupBox");
	local vakarine_gbox = GET_CHILD(bg_gbox, "vakarine_gbox", "ui::CGroupBox");
	local title = GET_CHILD(bg_gbox, "title", "ui::CRichText");
	title:SetText("{@st68b}{s18}Practonium list{/}{/}");
	status_gbox:ShowWindow(0);
	practonium_gbox:ShowWindow(1);
	master_gbox:ShowWindow(0);
	vakarine_gbox:ShowWindow(0);
end

function STATUSPOINT_OPEN_MASTERQUEST()
	local frame = ui.GetFrame("statuspointcheck");
	local bg_gbox = GET_CHILD(frame, "bg", "ui::CGroupBox");
	local status_gbox = GET_CHILD(bg_gbox, "status_gbox", "ui::CGroupBox");
	local practonium_gbox = GET_CHILD(bg_gbox, "practonium_gbox", "ui::CGroupBox");
	local master_gbox = GET_CHILD(bg_gbox, "master_gbox", "ui::CGroupBox");
	local vakarine_gbox = GET_CHILD(bg_gbox, "vakarine_gbox", "ui::CGroupBox");
	local title = GET_CHILD(bg_gbox, "title", "ui::CRichText");
	title:SetText("{@st68b}{s18}Master Quest list{/}{/}");
	status_gbox:ShowWindow(0);
	practonium_gbox:ShowWindow(0);
	master_gbox:ShowWindow(1);
	vakarine_gbox:ShowWindow(0);
end

function STATUSPOINT_OPEN_VAKARINE()
	local frame = ui.GetFrame("statuspointcheck");
	local bg_gbox = GET_CHILD(frame, "bg", "ui::CGroupBox");
	local status_gbox = GET_CHILD(bg_gbox, "status_gbox", "ui::CGroupBox");
	local practonium_gbox = GET_CHILD(bg_gbox, "practonium_gbox", "ui::CGroupBox");
	local master_gbox = GET_CHILD(bg_gbox, "master_gbox", "ui::CGroupBox");
	local vakarine_gbox = GET_CHILD(bg_gbox, "vakarine_gbox", "ui::CGroupBox");
	local title = GET_CHILD(bg_gbox, "title", "ui::CRichText");
	title:SetText("{@st68b}{s18}Vakarine list{/}{/}");
	status_gbox:ShowWindow(0);
	practonium_gbox:ShowWindow(0);
	master_gbox:ShowWindow(0);
	vakarine_gbox:ShowWindow(1);
end

function STATUSPOINTCHECK_QUESTCLEARCHECK(questNo)
	local questCls = GetClassByType('QuestProgressCheck', questNo);
	local pc = GetMyPCObject();
	local result = SCR_QUEST_CHECK(pc, questCls.ClassName)
	if result == 'SUCCESS' or result == 'COMPLETE' then
		return true
	end
	return false
end

function STATUSPOINTCHECK_QUEST_REQUEST(frame, ctrl, argStr, argNum)
	local questClassID = argStr;
	ADVENTURE_BOOK_QUEST_INIT_DETAIL(questClassID);
	ReqQuestCompleteCharacterList(questClassID);
end
