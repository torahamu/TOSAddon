--******************************************
-- CHAT_EXTENDS
-- チャットフレームを拡張したアドオン
-- なるべく遅くに読み込んでほしいので、z始まりにしている
--******************************************

--アドオン名（大文字）
local addonName = "CHATEXTENDS";
local addonNameLower = string.lower(addonName);
--作者名
local author = "torahamu";

--アドオン内で使用する領域を作成。以下、ファイル内のスコープではグローバル変数gでアクセス可
_G["ADDONS"] = _G["ADDONS"] or {};
_G["ADDONS"][author] = _G["ADDONS"][author] or {};
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {};
local g = _G["ADDONS"][author][addonName];

--設定ファイル保存先
g.settingsDirLoc = string.format("../addons/%s", addonNameLower);
g.settingsFileLoc = string.format("%s/settings.json", g.settingsDirLoc);
g.SAVE_DIR = "../release/screenshot";

--デフォルト設定
if not g.loaded then
  g.settings = {
	-- システムメッセージを全体フレームのみに表示するフラグ
	SYSTEM_TOTAL_FLG=true;
	-- 発言をニコニコ風に表示するフラグ
	NICO_CHAT_FLG=false;
	-- 発言を記録していくフラグ
	REC_CHAT_FLG=false;
	-- 吹き出し表示フラグ
	BALLON_FLG=false;
	-- タイプ表示フラグ
	ENABLE_TYPE_FLG=true;
  };
end

-- 実際に使うフォント設定
g.usefontsettings = {
	COLOR_GRO_MY="FF7cd8ff";
	COLOR_GRO="FFb4ddef";
	COLOR_WHI_MY="FF7cd8ff";
	COLOR_WHI_TO="FFb4ddef";
	COLOR_SYSTEM_MY="FFffe86a";
	COLOR_SYSTEM="FFFFFFFF";
	COLOR_NORMAL_MY="FFffe86a";
	COLOR_NORMAL="FFFFFFFF";
	COLOR_SHOUT_MY="FFff7c0f";
	COLOR_SHOUT="FFffa800";
	COLOR_PARTY_MY="FF93c95a";
	COLOR_PARTY="FFbceb89";
	COLOR_PARTY_INFO="FFbceb89";
	COLOR_GUILD_INFO="FFA566FF";
	COLOR_GUILD_MY="FFDC99FF";
	COLOR_GUILD="FFbe80ce";
	COLOR_GUILD_NOTICE_MY="FFFF44FF";
	COLOR_GUILD_NOTICE="FFFF44FF";
	BALLONCHAT_FONTSTYLE="{#050505}";
	BALLONCHAT_FONTSTYLE_SYSTEM="{#DD0000}";
	BALLONCHAT_FONTSTYLE_MEMBER="{#000000}";
	TEXTCHAT_FONTSTYLE_NORMAL_MY="{#FFFAB8}{b}{ol}{ds}";
	TEXTCHAT_FONTSTYLE_SHOUT_MY="{#FFD03F}{b}{ol}{ds}";
	TEXTCHAT_FONTSTYLE_PARTY_MY="{#73FF97}{b}{ol}{ds}";
	TEXTCHAT_FONTSTYLE_GUILD_MY="{#DC99FF}{b}{ol}{ds}";
	TEXTCHAT_FONTSTYLE_WHISPER_MY="{#8EEBFF}{b}{ol}{ds}";
	TEXTCHAT_FONTSTYLE_GROUP_MY="{#8EEBFF}{b}{ol}{ds}";
	TEXTCHAT_FONTSTYLE_GUILD_NOTICE_MY="{#FF44FF}{b}{ol}";
	TEXTCHAT_FONTSTYLE_GUILD_NOTICE="{#FF44FF}{b}{ol}";
	TEXTCHAT_FONTSTYLE_NORMAL="{#FFFFFF}{ol}";
	TEXTCHAT_FONTSTYLE_SHOUT="{#da6e0f}{ol}";
	TEXTCHAT_FONTSTYLE_PARTY="{#86E57F}{ol}";
	TEXTCHAT_FONTSTYLE_GUILD="{#A566FF}{ol}";
	TEXTCHAT_FONTSTYLE_WHISPER="{#2ec2d4}{ol}";
	TEXTCHAT_FONTSTYLE_GROUP="{#2ec2d4}{ol}";
	TEXTCHAT_FONTSTYLE_NOTICE="{#FF0000}{ol}";
	TEXTCHAT_FONTSTYLE_SYSTEM="{#FFE400}{ol}";
}

--ライブラリ読み込み
local acutil = require('acutil');
--Lua 5.2+ migration
if not _G['unpack'] and (table and table.unpack) then _G['unpack'] = table.unpack end

-- 読み込みフラグ
g.loaded=false

-- チャットタイプ
g.chattype=0

--lua読み込み時のメッセージ
CHAT_SYSTEM(string.format("%s.lua is loaded", addonName));

-- フレーム内文字
if option.GetCurrentCountry()=="Japanese" then
	headertxt = "拡張設定";
	systemtxt = "システムメッセージを{nl}全体フレームのみに表示する";
	nicotxt = "チャット内容をニコニコ動画{nl}のように表示する";
	rectxt = "チャット内容を記録し続ける";
	ballontxt = "吹き出しで表示する";
	enable_type_txt = "簡易表示の時に{nl}発言の種類を表示する"
	auto_read_txt = "チャットを常に更新する"
	sounds_txt = "チャットサウンド設定"
else
	headertxt = "extends setting";
	systemtxt = "Display system messages{nl}only in the total frame";
	nicotxt = "Chat contents{nl}flow from the right";
	rectxt = "Record Chat Content";
	ballontxt = "Ballon Chat";
	enable_type_txt = "Display the type of remark{nl}at the time of simple chat"
	auto_read_txt = "Always update chat"
	sounds_txt = "Chat Sounds Setting"
end

function CHATEXTENDS_SAVE_SETTINGS()
	acutil.saveJSON(g.settingsFileLoc, g.settings);
end

--マップ読み込み時処理（1度だけ）
function ZCHATEXTENDS_ON_INIT(addon, frame)
	-- 初期設定項目は1度だけ行う
	if not g.loaded then
		local mainchatFrame = ui.GetFrame("chatframe")
		if mainchatFrame ~= nil then
			local groupbox = GET_CHILD(mainchatFrame, "chatgbox_TOTAL");
			if groupbox ~= nil then
				groupbox = tolua.cast(groupbox, "ui::CGroupBox");
				groupbox:SetSkinName("chat_Whisper_talkskin_cusoron");
			end
		end
		g.addon = addon;
		g.frame = frame;

		-- 元関数封印
		if nil == CHATEXTENDS_DRAW_CHAT_MSG_OLD then
			CHATEXTENDS_DRAW_CHAT_MSG_OLD = DRAW_CHAT_MSG;
			DRAW_CHAT_MSG = CHATEXTENDS_DRAW_CHAT_MSG;
		end
		if nil == CHATEXTENDS_CHAT_CHAT_SET_TO_TITLENAME_OLD then
			CHATEXTENDS_CHAT_CHAT_SET_TO_TITLENAME_OLD = CHAT_SET_TO_TITLENAME;
			CHAT_SET_TO_TITLENAME = CHATEXTENDS_CHAT_CHAT_SET_TO_TITLENAME;
		end
		if nil == CHATEXTENDS_CHAT_OPEN_INIT_OLD then
			CHATEXTENDS_CHAT_OPEN_INIT_OLD = CHAT_OPEN_INIT;
			CHAT_OPEN_INIT = CHATEXTENDS_CHAT_OPEN_INIT;
		end

		if nil == CHATEXTENDS_CHAT_SET_FONTSIZE_N_COLOR_OLD then
			CHATEXTENDS_CHAT_SET_FONTSIZE_N_COLOR_OLD = CHAT_SET_FONTSIZE_N_COLOR;
			CHAT_SET_FONTSIZE_N_COLOR = CHATEXTENDS_CHAT_SET_FONTSIZE_N_COLOR;
		end

		if nil == CHATEXTENDS_CHAT_ADD_GBOX_OPTION_FOR_CHATFRAME_OLD then
			CHATEXTENDS_CHAT_ADD_GBOX_OPTION_FOR_CHATFRAME_OLD = _ADD_GBOX_OPTION_FOR_CHATFRAME;
			_ADD_GBOX_OPTION_FOR_CHATFRAME = CHATEXTENDS_CHAT_ADD_GBOX_OPTION_FOR_CHATFRAME;
		end

		if nil == CHATEXTENDS_CHAT_TOGGLE_BOTTOM_CHAT_OLD then
			CHATEXTENDS_CHAT_TOGGLE_BOTTOM_CHAT_OLD = TOGGLE_BOTTOM_CHAT;
			TOGGLE_BOTTOM_CHAT = CHATEXTENDS_CHAT_TOGGLE_BOTTOM_CHAT;
		end

		-- 表示種類変えるたびに割と重いので、処理だけ残して実際には呼ばれないように
		-- 使いたい場合は、↓のコメントアウトしているところのコメント消してやってください
		--if nil == CHATEXTENDS_CHAT_TAB_BTN_CLICK_OLD then
		--	CHATEXTENDS_CHAT_TAB_BTN_CLICK_OLD = CHAT_TAB_BTN_CLICK;
		--	CHAT_TAB_BTN_CLICK = CHATEXTENDS_CHAT_TAB_BTN_CLICK;
		--end

		if nil == CHATEXTENDS_SetChatType_OLD then
			CHATEXTENDS_SetChatType_OLD = _G['ui'].SetChatType;
			_G['ui'].SetChatType = CHATEXTENDS_SetChatType;
		end

		if nil == CHATEXTENDS_ProcessTabKey_OLD then
			CHATEXTENDS_ProcessTabKey_OLD = _G['ui'].ProcessTabKey;
			_G['ui'].ProcessTabKey = CHATEXTENDS_ProcessTabKey;
		end

--		if nil == CHATEXTENDS_ProcessReturnKey_OLD then
--			CHATEXTENDS_ProcessReturnKey_OLD = _G['ui'].ProcessReturnKey;
--			_G['ui'].ProcessReturnKey = CHATEXTENDS_ProcessReturnKey;
--		end

		if nil == CHATEXTENDS_WhisperTo_OLD then
			CHATEXTENDS_WhisperTo_OLD = _G['ui'].WhisperTo;
			_G['ui'].WhisperTo = CHATEXTENDS_WhisperTo;
		end

		--コマンド登録
		acutil.slashCommand("/savechat", CHATEXTENDS_SAVE_CHAT);

		-- 設定読み込み
		if not g.loaded then
			local t, err = acutil.loadJSON(g.settingsFileLoc, g.settings);
			-- 読み込めない = ファイルがない
			if err then
				-- ファイル作る
				CHATEXTENDS_SAVE_SETTINGS();
			else
				-- 読み込めたら読み込んだ値使う
				g.settings = t;
				CHATEXTENDS_SAVE_SETTINGS();
			end
			-- savechatフォルダあればそっちをデフォルトに
			if CHATEXTENDS_CHECK_DIR("../release/savechat") then
				g.SAVE_DIR = "../release/savechat";
			else
				g.SAVE_DIR = "../release/screenshot";
			end
			g.loaded = true;
		end
	end
	-- イベント登録
	acutil.setupEvent(addon, "DRAW_CHAT_MSG", "CHATEXTENDS_SOUND_DRAW_CHAT_MSG_EVENT");
	acutil.setupEvent(addon, "DRAW_CHAT_MSG", "CHATEXTENDS_NICO_CHAT_DRAW");
	acutil.setupEvent(addon, "DRAW_CHAT_MSG", "CHATEXTENDS_CHAT_REC");
	if TPCHATSYS_HOOK_CHAT_SYSTEM ~= nil then
		acutil.setupEvent(addon, "TPCHATSYS_ON_MSG", "CHATEXTENDS_SOUND_TPCHATSYS_HOOK_CHAT_SYSTEM_EVENT");
	end

	-- チャット入力を変更
	CHATEXTENDS_UPDATE_CHAT_FRAME()
	-- 設定項目をチャットオプションに追加
	CHATEXTENDS_CREATE_CHATOPTION_FRAME();

end

-- チャット入力を変更
function CHATEXTENDS_UPDATE_CHAT_FRAME()
	local chat_frame = ui.GetFrame("chat");
	chat_frame:Resize(750,chat_frame:GetOriginalHeight());
	chat_frame:SetOffset(chat_frame:GetX(),chat_frame:GetY() + 100);
	chat_frame:EnableMove(0);
	local edit_bg=GET_CHILD(chat_frame,"edit_bg");
	edit_bg:Resize(732,36);
	local mainchat=GET_CHILD(chat_frame,"mainchat");
	local titleCtrl = GET_CHILD(chat_frame,'edit_to_bg');
	titleCtrl:SetGravity(ui.LEFT, ui.TOP);
	local btn_ChatType = GET_CHILD(chat_frame,'button_type');
	local offsetX = btn_ChatType:GetWidth();
	mainchat:SetGravity(ui.LEFT, ui.TOP);
	mainchat:Resize(585 - titleCtrl:GetWidth() - offsetX + 17, mainchat:GetOriginalHeight())
	mainchat:SetOffset(titleCtrl:GetWidth() + offsetX + 7, mainchat:GetOriginalY());

	local now_button = chat_frame:CreateOrGetControl("button", "CHATEXTENDS_NOW_BUTTON", 72, 0, 36, 36);
	tolua.cast(now_button, "ui::CButton");
	now_button:SetGravity(ui.RIGHT, ui.TOP);
	now_button:SetOffset(72, -1);
	now_button:SetClickSound("button_click");
	now_button:SetOverSound("button_cursor_over_2");
	now_button:SetAnimation("MouseOnAnim", "btn_mouseover");
	now_button:SetAnimation("MouseOffAnim", "btn_mouseoff");
	now_button:SetEventScript(ui.LBUTTONDOWN, "CHATEXTENDS_MY_POS");
	now_button:SetImage("button_pos_img");
	now_button:Resize(37, 37);

	local party_button = chat_frame:CreateOrGetControl("button", "CHATEXTENDS_PARTY_BUTTON", 107, 0, 36, 36);
	tolua.cast(party_button, "ui::CButton");
	party_button:SetGravity(ui.RIGHT, ui.TOP);
	party_button:SetOffset(107, 0);
	party_button:SetClickSound("button_click");
	party_button:SetOverSound("button_cursor_over_2");
	party_button:SetAnimation("MouseOnAnim", "btn_mouseover");
	party_button:SetAnimation("MouseOffAnim", "btn_mouseoff");
	party_button:SetEventScript(ui.LBUTTONDOWN, "LINK_PARTY_INVITE");
	party_button:SetImage("btn_partyshare");
	party_button:Resize(33, 33);

	local button_emo=GET_CHILD(chat_frame,"button_emo");
	button_emo:SetOffset(39,0);

	local button_option = chat_frame:CreateOrGetControl("button", "CHATEXTENDS_BUTTON_OPTION", 6, 0, 36, 36);
	tolua.cast(button_option, "ui::CButton");
	button_option:SetGravity(ui.RIGHT, ui.TOP);
	button_option:SetOffset(3, 0);
	button_option:SetClickSound("button_click");
	button_option:SetOverSound("button_cursor_over_2");
	button_option:SetAnimation("MouseOnAnim", "btn_mouseover");
	button_option:SetAnimation("MouseOffAnim", "btn_mouseoff");
	button_option:SetEventScript(ui.LBUTTONDOWN, "CHAT_OPEN_OPTION");
	button_option:SetImage("button_chat_option");
	button_option:Resize(36, 36);
end

-- 現在値を挿入
function CHATEXTENDS_MY_POS()
	-- mapフレームの子供のmapがマップ画像　ややこしいわ
	local map_frame = ui.GetFrame("map");
	local map_pic = GET_CHILD(map_frame,"map");
	-- 自分の座標
	local myposition = GET_CHILD(map_frame,"my");
	local x, y= GET_C_XY(myposition);
	x = x + (myposition:GetWidth()/2) - map_pic:GetX();
	y = y + (myposition:GetHeight()/2) - map_pic:GetY();
	local mapName = session.GetMapName();
	local mapprop = geMapTable.GetMapProp(mapName);
	local worldPos = mapprop:MinimapPosToWorldPos(x, y, map_pic:GetWidth(), map_pic:GetHeight());
	LINK_MAP_POS(mapName, worldPos.x ,worldPos.y);
end

-- チャットオプションフレームに設定追加
function CHATEXTENDS_CREATE_CHATOPTION_FRAME()
	local chat_option_frame = ui.GetFrame("chat_option");
	chat_option_frame:Resize(950,chat_option_frame:GetHeight());

	local battleTextBgBox = GET_CHILD(chat_option_frame ,"battleTextBgBox");
	battleTextBgBox:Resize(300,battleTextBgBox:GetHeight());

	local headerGBox = chat_option_frame:CreateOrGetControl("picture", "CHATEXTENDS_HEADER_GBOX", 650, 47, 300, 30);
	tolua.cast(headerGBox, "ui::CPicture");
	headerGBox:SetImage("test_partyquest_slot")

	local header = chat_option_frame:CreateOrGetControl("richtext", "CHATEXTENDS_HEADER", 660, 52, 120, 34);
	tolua.cast(header, 'ui::CRichText');
	header:SetFontName("white_16_ol");
	header:SetText(headertxt);
	--header:SetText("{@st42}"..headertxt.."{/}");

	local nico_chat_flg_chk = chat_option_frame:CreateOrGetControl('checkbox', "CHATEXTENDS_NICO_CHAT_FLG", 650, 85, 300, 35);
	nico_chat_flg_chk = tolua.cast(nico_chat_flg_chk, "ui::CCheckBox");
	nico_chat_flg_chk:SetFontName("brown_16_b");
	nico_chat_flg_chk:SetText(nicotxt);
	nico_chat_flg_chk:SetClickSound('button_click_big');
	nico_chat_flg_chk:SetAnimation("MouseOnAnim", "btn_mouseover");
	nico_chat_flg_chk:SetAnimation("MouseOffAnim", "btn_mouseoff");
	nico_chat_flg_chk:SetOverSound('button_over');
	nico_chat_flg_chk:SetEventScript(ui.LBUTTONUP, "CHATEXTENDS_TOGGLE_NICO_CHAT_FLG");
	if g.settings.NICO_CHAT_FLG then
		nico_chat_flg_chk:SetCheck(1);
	else
		nico_chat_flg_chk:SetCheck(0);
	end

	local rec_chat_flg_chk = chat_option_frame:CreateOrGetControl('checkbox', "CHATEXTENDS_REC_CHAT_FLG", 650, 120, 300, 35);
	rec_chat_flg_chk = tolua.cast(rec_chat_flg_chk, "ui::CCheckBox");
	rec_chat_flg_chk:SetFontName("brown_16_b");
	rec_chat_flg_chk:SetText(rectxt);
	rec_chat_flg_chk:SetClickSound('button_click_big');
	rec_chat_flg_chk:SetAnimation("MouseOnAnim", "btn_mouseover");
	rec_chat_flg_chk:SetAnimation("MouseOffAnim", "btn_mouseoff");
	rec_chat_flg_chk:SetOverSound('button_over');
	rec_chat_flg_chk:SetEventScript(ui.LBUTTONUP, "CHATEXTENDS_TOGGLE_REC_CHAT_FLG");
	if g.settings.REC_CHAT_FLG then
		rec_chat_flg_chk:SetCheck(1);
	else
		rec_chat_flg_chk:SetCheck(0);
	end

	local ballon_flg_chk = chat_option_frame:CreateOrGetControl('checkbox', "CHATEXTENDS_BALLON_FLG", 650, 155, 300, 35);
	ballon_flg_chk = tolua.cast(ballon_flg_chk, "ui::CCheckBox");
	ballon_flg_chk:SetFontName("brown_16_b");
	ballon_flg_chk:SetText(ballontxt);
	ballon_flg_chk:SetClickSound('button_click_big');
	ballon_flg_chk:SetAnimation("MouseOnAnim", "btn_mouseover");
	ballon_flg_chk:SetAnimation("MouseOffAnim", "btn_mouseoff");
	ballon_flg_chk:SetOverSound('button_over');
	ballon_flg_chk:SetEventScript(ui.LBUTTONUP, "CHATEXTENDS_TOGGLE_BALLON_FLG");
	if g.settings.BALLON_FLG then
		ballon_flg_chk:SetCheck(1);
	else
		ballon_flg_chk:SetCheck(0);
	end

	local enable_type_flg_chk = chat_option_frame:CreateOrGetControl('checkbox', "CHATEXTENDS_ENABLE_TYPE_FLG", 650, 190, 300, 35);
	enable_type_flg_chk = tolua.cast(enable_type_flg_chk, "ui::CCheckBox");
	enable_type_flg_chk:SetFontName("brown_16_b");
	enable_type_flg_chk:SetText(enable_type_txt);
	enable_type_flg_chk:SetClickSound('button_click_big');
	enable_type_flg_chk:SetAnimation("MouseOnAnim", "btn_mouseover");
	enable_type_flg_chk:SetAnimation("MouseOffAnim", "btn_mouseoff");
	enable_type_flg_chk:SetOverSound('button_over');
	enable_type_flg_chk:SetEventScript(ui.LBUTTONUP, "CHATEXTENDS_TOGGLE_ENABLE_TYPE_FLG");
	if g.settings.ENABLE_TYPE_FLG then
		enable_type_flg_chk:SetCheck(1);
	else
		enable_type_flg_chk:SetCheck(0);
	end

	local auto_read_flg_chk = chat_option_frame:CreateOrGetControl('checkbox', "CHATEXTENDS_AUTO_READ_FLG", 650, 225, 300, 35);
	auto_read_flg_chk = tolua.cast(auto_read_flg_chk, "ui::CCheckBox");
	auto_read_flg_chk:SetFontName("brown_16_b");
	auto_read_flg_chk:SetText(auto_read_txt);
	auto_read_flg_chk:SetClickSound('button_click_big');
	auto_read_flg_chk:SetAnimation("MouseOnAnim", "btn_mouseover");
	auto_read_flg_chk:SetAnimation("MouseOffAnim", "btn_mouseoff");
	auto_read_flg_chk:SetOverSound('button_over');
	auto_read_flg_chk:SetEventScript(ui.LBUTTONUP, "TOGGLE_BOTTOM_CHAT");
	auto_read_flg_chk:SetCheck(config.GetXMLConfig("ToggleBottomChat"));

	local soundbtn = chat_option_frame:CreateOrGetControl("button", "CHATEXTENDS_SOUNDS_BUTTON", 650, 300, 150, 30);
	soundbtn = tolua.cast(soundbtn, "ui::CButton");
	soundbtn:SetFontName("white_16_ol");
	soundbtn:SetText(sounds_txt);
	soundbtn:SetClickSound("button_click");
	soundbtn:SetOverSound("button_cursor_over_2");
	soundbtn:SetAnimation("MouseOnAnim", "btn_mouseover");
	soundbtn:SetAnimation("MouseOffAnim", "btn_mouseoff");
	soundbtn:SetEventScript(ui.LBUTTONDOWN, "CHATEXTENDS_SOUND_FRAME_OPEN");

end

-- チャットオープン処理
function CHATEXTENDS_CHAT_OPEN_INIT()
	-- 元関数呼び出し
	CHATEXTENDS_CHAT_OPEN_INIT_OLD();
	-- チャット入力を変更
	local chat_frame = ui.GetFrame("chat");
	local mainchat=GET_CHILD(chat_frame,"mainchat");
	local titleCtrl = GET_CHILD(chat_frame,'edit_to_bg');
	local btn_ChatType = GET_CHILD(chat_frame,'button_type');
	local offsetX = btn_ChatType:GetWidth();
	mainchat:SetGravity(ui.LEFT, ui.TOP);
	mainchat:Resize(585 - titleCtrl:GetWidth() - offsetX + 17, mainchat:GetOriginalHeight())
	mainchat:SetOffset(titleCtrl:GetWidth() + offsetX + 7, mainchat:GetOriginalY());
end

-- チェックボックスのイベント
function CHATEXTENDS_TOGGLE_SYSTEM_TOTAL_FLG(frame, ctrl, argStr, argNum)
	if ctrl:IsChecked() == 1 then
		g.settings.SYSTEM_TOTAL_FLG = true;
	else
		g.settings.SYSTEM_TOTAL_FLG = false;
	end
	CHATEXTENDS_SAVE_SETTINGS();
end

-- チェックボックスのイベント
function CHATEXTENDS_TOGGLE_NICO_CHAT_FLG(frame, ctrl, argStr, argNum)
	if ctrl:IsChecked() == 1 then
		g.settings.NICO_CHAT_FLG = true;
	else
		g.settings.NICO_CHAT_FLG = false;
	end
	CHATEXTENDS_SAVE_SETTINGS();
end

-- チェックボックスのイベント
function CHATEXTENDS_TOGGLE_REC_CHAT_FLG(frame, ctrl, argStr, argNum)
	if ctrl:IsChecked() == 1 then
		g.settings.REC_CHAT_FLG = true;
	else
		g.settings.REC_CHAT_FLG = false;
	end
	CHATEXTENDS_SAVE_SETTINGS();
end

-- チェックボックスのイベント
function CHATEXTENDS_TOGGLE_BALLON_FLG(frame, ctrl, argStr, argNum)
	if ctrl:IsChecked() == 1 then
		g.settings.BALLON_FLG = true;
	else
		g.settings.BALLON_FLG = false;
	end
	CHATEXTENDS_SAVE_SETTINGS();
	local mainchatFrame = ui.GetFrame("chatframe");
	local retbit = CHAT_FRAME_GET_NOW_SELECT_VALUE(mainchatFrame);
	local groupboxname = "chatgbox_"..retbit;
	if retbit == MAX_CHAT_CONFIG_VALUE then
		groupboxname = "chatgbox_TOTAL";
	end
	local groupbox = GET_CHILD(mainchatFrame, groupboxname);
	DESTROY_CHILD_BYNAME(groupbox, 'cluster_');
	ui.ReDrawAllChatMsg();
end

-- チェックボックスのイベント
function CHATEXTENDS_TOGGLE_ENABLE_TYPE_FLG(frame, ctrl, argStr, argNum)
	if ctrl:IsChecked() == 1 then
		g.settings.ENABLE_TYPE_FLG = true;
	else
		g.settings.ENABLE_TYPE_FLG = false;
	end
	CHATEXTENDS_SAVE_SETTINGS();
	if g.settings.BALLON_FLG == false then
		local mainchatFrame = ui.GetFrame("chatframe");
		local retbit = CHAT_FRAME_GET_NOW_SELECT_VALUE(mainchatFrame);
		local groupboxname = "chatgbox_"..retbit;
		if retbit == MAX_CHAT_CONFIG_VALUE then
			groupboxname = "chatgbox_TOTAL";
		end
		local groupbox = GET_CHILD(mainchatFrame, groupboxname);
		DESTROY_CHILD_BYNAME(groupbox, 'cluster_');
		ui.ReDrawAllChatMsg();
	end
end

-- チェックボックスとチャット左下矢印のイベント
function CHATEXTENDS_CHAT_TOGGLE_BOTTOM_CHAT()
	local IsBottomChat = config.GetXMLConfig("ToggleBottomChat")

	local frame = ui.GetFrame("chatframe")
	local bottomlockbtn = GET_CHILD_RECURSIVELY(frame,"bottomlockbtn")

	if IsBottomChat == 1 then
		config.ChangeXMLConfig("ToggleBottomChat",0)
		bottomlockbtn:SetImage("chat_down_btn");
	else
		config.ChangeXMLConfig("ToggleBottomChat",1)
		bottomlockbtn:SetImage("chat_down_btn2");
	end

	local chat_option_frame = ui.GetFrame("chat_option");
	local auto_read_flg_chk = GET_CHILD(chat_option_frame, "CHATEXTENDS_AUTO_READ_FLG");
	auto_read_flg_chk = tolua.cast(auto_read_flg_chk, "ui::CCheckBox");
	auto_read_flg_chk:SetCheck(config.GetXMLConfig("ToggleBottomChat"));

end

-- チャットサイズの設定
-- タイプを変えたりささやき相手の名前表示したりしたら、入力フレームがリサイズされるので、その対策
function CHATEXTENDS_CHAT_CHAT_SET_TO_TITLENAME(chatType, targetName, count)
	CHATEXTENDS_CHAT_CHAT_SET_TO_TITLENAME_OLD(chatType, targetName, count)
	local chat_frame = ui.GetFrame('chat');
	local mainchat = GET_CHILD(chat_frame, 'mainchat');
	local titleCtrl = GET_CHILD(chat_frame,'edit_to_bg');
	local btn_ChatType = GET_CHILD(chat_frame,'button_type');
	local offsetX = btn_ChatType:GetWidth();

	mainchat:Resize(585 - titleCtrl:GetWidth() - offsetX + 17, mainchat:GetOriginalHeight())
	mainchat:SetOffset(titleCtrl:GetWidth() + offsetX + 7, mainchat:GetOriginalY());

end

-- チャットタイプ選択フック
function CHATEXTENDS_SetChatType(typeIvalue)
	-- 一度チャット内容を取得
	local str = GET_CHAT_TEXT();
	-- この命令でチャット内容が消える
	CHATEXTENDS_SetChatType_OLD(typeIvalue);
	-- チャット内容復旧
	SET_CHAT_TEXT(str);
	g.chattype = ui.GetChatType();
end

-- タブキー押下時のフック
function CHATEXTENDS_ProcessTabKey()
	-- 一度チャット内容を取得
	local str = GET_CHAT_TEXT();
	-- この命令でチャット内容が消える
	CHATEXTENDS_ProcessTabKey_OLD();
	-- チャット内容復旧
	if str ~= "" then
		SET_CHAT_TEXT(str);
	end
	g.chattype = ui.GetChatType();
end


-- エンターキー押下時のフック
-- 発言種類設定
function CHATEXTENDS_ProcessReturnKey()
	CHATEXTENDS_ProcessReturnKey_OLD();
	if keyboard.IsKeyPressed("LALT") == 1 or keyboard.IsKeyPressed("LCTRL") == 1 then
		g.chattype = ui.GetChatType();
		return;
	end
	local frame = ui.GetFrame('chat');
	local chatEditCtrl = frame:GetChild('mainchat');
	if chatEditCtrl:IsHaveFocus() == 1 then
		ui.SetChatType(g.chattype)
	end
end

function CHATEXTENDS_WhisperTo(familyName)
	CHATEXTENDS_WhisperTo_OLD(familyName)
	g.chattype = ui.GetChatType();
end

-- チャット表示種類ボタン押下時
-- 表示種類変えるたびに割と重いので、処理だけ残して実際には呼ばれないように
-- 使いたい場合は、ON_INIT処理内のコメントアウトしているところのコメント消してやってください
function CHATEXTENDS_CHAT_TAB_BTN_CLICK(parent, ctrl)
	CHATEXTENDS_CHAT_TAB_BTN_CLICK_OLD(parent, ctrl);
	local frame = parent:GetTopParentFrame();
	local retbit = CHAT_FRAME_GET_NOW_SELECT_VALUE(frame);
	local groupboxname = "chatgbox_"..retbit;
	if retbit == MAX_CHAT_CONFIG_VALUE then
		groupboxname = "chatgbox_TOTAL";
	end
	local groupbox = GET_CHILD(frame, groupboxname);
	DESTROY_CHILD_BYNAME(groupbox, 'cluster_');
	ui.ReDrawAllChatMsg();
end

--************************************************
-- DRAW_CHAT_MSGのフック
-- 　引数：String groupboxname
-- 　　　　処理対象のgbox名
-- 　　　　gboxはframe:chatframe内のframeオブジェクト
-- 　引数：int startindex
-- 　　　　チャット配列の表示処理開始index
-- 　引数：String framename
-- 　　　　処理対象フレーム名
--************************************************
function CHATEXTENDS_DRAW_CHAT_MSG(groupboxname, startindex, chatframe, removeChatIDList)
	local mainchatFrame = ui.GetFrame("chatframe");
	local groupbox = GET_CHILD(chatframe, groupboxname);
	local size = session.ui.GetMsgInfoSize(groupboxname);

	if groupbox == nil then
		return 1;
	end
	
	if groupbox:IsVisible() == 0 or chatframe:IsVisible() == 0 then
		return 1;
	end

	CHATEXTENDS_CHAT_SET_OPACITY(groupbox);

	if removeChatIDList ~= nil then
		for i = 1, #removeChatIDList do
			groupbox:RemoveChild("cluster_" .. removeChatIDList[i]);
		end
	end

	local marginLeft = 20;
	local marginRight = 0;
	local ypos = 0;
	for i = startindex, size - 1 do
		local beforeclusterinfo = nil
		if i ~= 0 then
			beforeclusterinfo = session.ui.GetChatMsgInfo(groupboxname, i-1)
			if beforeclusterinfo ~= nil then
				local beforechildname = "cluster_"..beforeclusterinfo:GetMsgInfoID()
				local beforechild = GET_CHILD(groupbox, beforechildname);
				if beforechild ~= nil then
					ypos = beforechild:GetY() + beforechild:GetHeight();
				end
			end
		end
		local clusterinfo = session.ui.GetChatMsgInfo(groupboxname, i);
		if clusterinfo == nil then
			return 0;
		end

		local clustername = "cluster_" .. clusterinfo:GetMsgInfoID();
		local chatCtrl = GET_CHILD(groupbox, clustername);

		if i > 0 then
			local prevClusterInfo = session.ui.GetChatMsgInfo(groupboxname, i - 1);
			if prevClusterInfo ~= nil then
				local precClusterName = "cluster_" .. prevClusterInfo:GetMsgInfoID();
				precCluster = GET_CHILD(groupbox, precClusterName);
				if precCluster ~= nil then
					ypos = precCluster:GetY() + precCluster:GetHeight();
				else
					-- ui가 다 날아갔는데, 메시지가 들어온 경우
					-- 재접할때 발생한다.
					return DRAW_CHAT_MSG(groupboxname, 0, chatframe, removeChatIDList);
				end
			end
		end

		local offsetX = chatframe:GetUserConfig("CTRLSET_OFFSETX");

		if startindex == 0 and chatCtrl ~= nil then
			if g.settings.BALLON_FLG then
				local commnderName = clusterinfo:GetCommanderName();
				local tempCommnderName = string.gsub(commnderName,"( %[.+%])", "");
				local label = chatCtrl:GetChild('bg');
				local txt = GET_CHILD(label, "text", "ui::CRichText");
				local timeBox = GET_CHILD(chatCtrl, "timebox", "ui::CGroupBox");
				CHATEXTENDS_RESIZE_CHAT_CTRL_BALLON(chatCtrl, label, txt, timeBox, tempCommnderName)
			else
				chatCtrl:SetOffset(marginLeft, ypos);
				local label = chatCtrl:GetChild('bg');
				local txt = GET_CHILD(chatCtrl, "text");
				local timeCtrl = GET_CHILD(chatCtrl, "time");
				RESIZE_CHAT_CTRL(groupbox, chatCtrl, label, txt, timeCtrl, offsetX);
			end
		end

		if chatCtrl == nil then
			local msgType = clusterinfo:GetMsgType();
			local commnderName = clusterinfo:GetCommanderName();
			local tempCommnderName = string.gsub(commnderName,"( %[.+%])", "");
			local colorType = session.chat.GetRoomConfigColorType(clusterinfo:GetRoomID())
			local colorCls = GetClassByType("ChatColorStyle", colorType)

			local fontSize = GET_CHAT_FONT_SIZE();
			local tempfontSize = string.format("{s%s}", fontSize);
			
			if g.settings.BALLON_FLG then
				CHATEXTENDS_BALLON_DRAW(groupboxname, groupbox, clustername, clusterinfo, commnderName, msgType, marginRight, marginLeft, ypos, fontSize, beforeclusterinfo)
			else
				local spinePic = nil;
				
				local tempMsg = clusterinfo:GetMsg()
				if config.GetXMLConfig("EnableChatFrameMotionEmoticon") == 1 and string.find(tempMsg, "{spine motion_") ~= nil then
					chatCtrl = groupbox:CreateOrGetControlSet('chatSpineVer', clustername, ui.LEFT, ui.TOP, marginLeft, ypos , marginRight, 1);
					
					local strlist = StringSplit(tempMsg, ' ');
					local emoCls = GetClass('chat_emoticons', strlist[2]);
					if emoCls == nil then
						return;
					end
					
					local spineToolTip = emoCls.IconSpine;
					local spineInfo = geSpine.GetSpineInfo(spineToolTip);
					
					spinePic = GET_CHILD(chatCtrl, "spinePic");
					spinePic:SetIsDurationTime(true);
					spinePic:SetDurationTime(emoCls.IconSpineDurationTime);
					spinePic:SetScaleFactor(emoCls.IconSpineScale);
					spinePic:SetOffsetX(spineInfo:GetOffsetX());
					spinePic:SetOffsetY(spineInfo:GetOffsetY());
					spinePic:CreateSpineActor(spineInfo:GetRoot(), spineInfo:GetAtlas(), spineInfo:GetJson(), "", spineInfo:GetAnimation());
					spinePic:SetUserValue("EMOTICON_CLASSNAME", strlist[2]);
					if startindex == 0 and size ~= 0 then
						spinePic:SetIsStopAnim(true);	-- 존 이동 시 이전 모션 이모티콘 들은 정지 상태로 변경		
					end
									
					chatframe:RunUpdateScript("CHAT_FRAME_UPDATE");
				else
					chatCtrl = groupbox:CreateOrGetControlSet('chatTextVer', clustername, ui.LEFT, ui.TOP, marginLeft, ypos , marginRight, 1);
				end

				chatCtrl:EnableHitTest(1);
				chatCtrl:EnableAutoResize(true,false);
			
				if tempCommnderName ~= GETMYFAMILYNAME() then
					chatCtrl:SetSkinName("")
				end
				local commnderNameUIText = commnderName .. " : "
				
				local label = chatCtrl:GetChild('bg');
				local txt = GET_CHILD(chatCtrl, "text");
				local timeCtrl = GET_CHILD(chatCtrl, "time");

				local msgFront = "";
				local msgString = "";	
				local fontStyle = nil;
				local msgIsMine = false;

				if tempCommnderName == GETMYFAMILYNAME() then
					msgIsMine = true;
					label:SetColorTone("FF000000");
					label:SetAlpha(60);
				else
					label:SetAlpha(0);
				end

				-- タグなし発言でも右クリック出来るようにする
				label:EnableHitTest(0)

				if msgType == "friendmem" then

					fontStyle = mainchatFrame:GetUserConfig("TEXTCHAT_FONTSTYLE_SYSTEM");
					msgFront = "#86E57F";

				elseif msgType == "guildmem" then

					fontStyle = mainchatFrame:GetUserConfig("TEXTCHAT_FONTSTYLE_SYSTEM");
					msgFront = "#A566FF";
				elseif msgType == "partymem" then

					fontStyle = mainchatFrame:GetUserConfig("TEXTCHAT_FONTSTYLE_SYSTEM");
					msgFront = "#86E57F";
				elseif msgType == "Battle" then
					fontStyle = '';			
				elseif msgType ~= "System" then
					chatCtrl:SetEventScript(ui.RBUTTONDOWN, 'CHAT_RBTN_POPUP');
					chatCtrl:SetUserValue("TARGET_NAME", commnderName);

					txt:SetEventScript(ui.RBUTTONDOWN, 'CHAT_RBTN_POPUP');
					txt:SetUserValue("TARGET_NAME", commnderName);
						
					if msgType == "Normal" then

						fontStyle = CHATEXTENDS_CHAT_TEXT_IS_MINE_AND_SETFONT(msgIsMine, "TEXTCHAT_FONTSTYLE_NORMAL");
						msgFront = CHATEXTENDS_GET_TYPE_CHARNAME(ScpArgMsg("ChatType_1"), commnderNameUIText);

					elseif msgType == "Shout" then

						fontStyle = CHATEXTENDS_CHAT_TEXT_IS_MINE_AND_SETFONT(msgIsMine, "TEXTCHAT_FONTSTYLE_SHOUT");
						msgFront = CHATEXTENDS_GET_TYPE_CHARNAME(ScpArgMsg("ChatType_2"), commnderNameUIText);

					elseif msgType == "Party" then

						fontStyle = CHATEXTENDS_CHAT_TEXT_IS_MINE_AND_SETFONT(msgIsMine, "TEXTCHAT_FONTSTYLE_PARTY");
						msgFront = CHATEXTENDS_GET_TYPE_CHARNAME(ScpArgMsg("ChatType_3"), commnderNameUIText);

					elseif msgType == "Guild" then

						fontStyle = CHATEXTENDS_CHAT_TEXT_IS_MINE_AND_SETFONT(msgIsMine, "TEXTCHAT_FONTSTYLE_GUILD");
						msgFront = CHATEXTENDS_GET_TYPE_CHARNAME(ScpArgMsg("ChatType_4"), commnderNameUIText);

					elseif msgType == "GuildNotice" then
						fontStyle = g.usefontsettings.TEXTCHAT_FONTSTYLE_GUILD_NOTICE;
						msgFront = CHATEXTENDS_GET_TYPE_CHARNAME(ScpArgMsg("ChatType_4"), commnderNameUIText);

						local guild = GET_MY_GUILD_INFO();
						if guild ~= nil then
							local leaderName = guild.info:GetLeaderName();
							if commnderName ~= leaderName then
								local memberInfo = session.party.GetPartyMemberInfoByName(PARTY_GUILD, commnderName);
								GetPlayerClaims("CHATEXTENDS_GUILD_NOTICE_MSG_CHECK", memberInfo:GetAID(), chatframe:GetName()..";"..groupboxname..";"..clusterinfo:GetMsgInfoID());
							end
						end

					elseif msgType == "Notice" then

						fontStyle = CHATEXTENDS_CHAT_TEXT_IS_MINE_AND_SETFONT(msgIsMine, "TEXTCHAT_FONTSTYLE_NOTICE");
						msgFront = string.format("[%s]", ScpArgMsg("ChatType_8"));

					elseif msgType == "Whisper" then

						chatCtrl:SetEventScript(ui.LBUTTONDOWN, 'CHAT_GBOX_LBTN_DOWN');
						chatCtrl:SetEventScriptArgString(ui.LBUTTONDOWN, clusterinfo:GetRoomID());

						txt:SetUserValue("ROOM_ID", clusterinfo:GetRoomID());
						if colorCls ~= nil then
							fontStyle = (msgIsMine and "{#"..colorCls.TextColor.."}{b}{ol}{ds}") or ("{#"..colorCls.TextColor.."}{ol}")
						else
							fontStyle = CHATEXTENDS_CHAT_TEXT_IS_MINE_AND_SETFONT(msgIsMine, "TEXTCHAT_FONTSTYLE_WHISPER");
						end

						msgFront = CHATEXTENDS_GET_TYPE_CHARNAME(ScpArgMsg("ChatType_5"), commnderNameUIText);

					elseif msgType == "Group" then

						chatCtrl:SetEventScript(ui.LBUTTONDOWN, 'CHAT_GBOX_LBTN_DOWN');
						chatCtrl:SetEventScriptArgString(ui.LBUTTONDOWN, clusterinfo:GetRoomID());

						txt:SetUserValue("ROOM_ID", clusterinfo:GetRoomID());
						if colorCls ~= nil then
							fontStyle = (msgIsMine and "{#"..colorCls.TextColor.."}{b}{ol}{ds}") or ("{#"..colorCls.TextColor.."}{ol}")
						else
							fontStyle = CHATEXTENDS_CHAT_TEXT_IS_MINE_AND_SETFONT(msgIsMine, "TEXTCHAT_FONTSTYLE_GROUP");
						end

						msgFront = CHATEXTENDS_GET_TYPE_CHARNAME(ScpArgMsg("ChatType_6"), commnderNameUIText);
					else
						chatCtrl:SetEventScript(ui.LBUTTONDOWN, 'CHAT_GBOX_LBTN_DOWN');
						chatCtrl:SetEventScriptArgString(ui.LBUTTONDOWN, clusterinfo:GetRoomID());

						txt:SetUserValue("ROOM_ID", clusterinfo:GetRoomID());
				
						if colorCls ~= nil then
							fontStyle = "{#"..colorCls.TextColor.."}{ol}"
						end

						msgFront = commnderNameUIText;
					end

				elseif msgType == "System" then
					fontStyle = mainchatFrame:GetUserConfig("TEXTCHAT_FONTSTYLE_SYSTEM");
					local colorOverride = clusterinfo:GetColor();
					if colorOverride ~= '' then
						fontStyle = string.gsub(fontStyle, '{#%x+}', '{#'..colorOverride..'}');
					end

					msgFront = g.settings.ENABLE_TYPE_FLG and string.format("[%s]", ScpArgMsg("ChatType_7")) or "";
				end	

				local tempMsg = clusterinfo:GetMsg()
				if msgType == "friendmem" or  msgType == "guildmem" or msgType == "partymem" then
					msgString = string.format("{%s}%s{nl}",msgFront, tempMsg);		
				else			
					msgString = string.format("%s%s{nl}", msgFront, tempMsg);		
				end

				local tempfontSize = string.format("{s%s}", fontSize);

				msgString = string.gsub(msgString, "({img emoticon.-}){/}{/}", "%1");
				msgString = string.format("%s%s{/}{/}{nl}", tempfontSize, msgString);
				txt:SetTextByKey("font", fontStyle);
				txt:SetTextByKey("size", fontSize);
				txt:SetTextByKey("text", CHAT_TEXT_LINKCHAR_FONTSET(mainchatFrame, msgString));
				timeCtrl:SetTextByKey("time", clusterinfo:GetTimeStr());	

				txt:EnableHitTest(1);

				if spinePic ~= nil then
					spinePic:SetMargin(txt:GetWidth() - 110, 0, 0, 0);
				end

				RESIZE_CHAT_CTRL(groupbox, chatCtrl, label, txt, timeCtrl, offsetX);
			end
		end
	end

	local scrollend = false
	if groupbox:GetLineCount() == groupbox:GetCurLine() + groupbox:GetVisibleLineCount() then
		scrollend = true;
	end

	local beforeLineCount = groupbox:GetLineCount();	
	groupbox:UpdateData();
	
	local afterLineCount = groupbox:GetLineCount();
	local changedLineCount = afterLineCount - beforeLineCount;
	local curLine = groupbox:GetCurLine();

	if (config.GetXMLConfig("ToggleBottomChat") == 1) or (scrollend == true) then
		groupbox:SetScrollPos(99999);
	else 
		groupbox:SetScrollPos(curLine + changedLineCount);
	end

	local gboxtype = string.sub(groupboxname,string.len("chatgbox_") + 1)
	local tonumberret = tonumber(gboxtype)

    if tonumberret ~= nil and tonumberret > MAX_CHAT_CONFIG_VALUE then
		UPDATE_READ_FLAG_BY_GBOX_NAME("chatgbox_" .. gboxtype)
	end
	
	return 1;
end

-- ***************************************
-- 簡易表示のメッセージ色
-- ***************************************
function CHATEXTENDS_CHAT_TEXT_IS_MINE_AND_SETFONT(msgIsMine, fontName)
	local result = fontName;
	if true == msgIsMine then
		result = fontName .. "_MY";
	end
	return g.usefontsettings[result];
end


-- ***************************************
-- 簡易表示のタイプ：キャラ名の部分の取得
-- ***************************************
function CHATEXTENDS_GET_TYPE_CHARNAME(type, charname)
	if g.settings.ENABLE_TYPE_FLG then
		return string.format("[%s]%s", type, charname);
	else
		return string.format("%s", charname);
	end
end

-- ***************************************
-- ニコニコ表示用
-- ***************************************
function CHATEXTENDS_NICO_CHAT_DRAW(frame, msg)
	local groupboxname, startindex, chatframe = acutil.getEventArgs(msg);

	-- 設定のニコフラグがOFFなら終了
	if g.settings.NICO_CHAT_FLG == false then
		return;
	end

	-- 再描画とかで開始インデックスが0以下なら終了
	if startindex <= 0 then
		return;
	end
	-- メインのチャットフレームの文言のみ
	if chatframe ~= ui.GetFrame("chatframe") then
		return;
	end
	-- メインの全体発言のみ
	if groupboxname ~= "chatgbox_TOTAL" then
		return;
	end

	local groupbox = GET_CHILD(chatframe,groupboxname);
	-- 取れなかったら(ありえるのか？)終了
	if groupbox == nil then
		return;
	end

	local clusterinfo = session.ui.GetChatMsgInfo(groupboxname, startindex)
	-- 取れなかったら(ありえるのか？)終了
	if clusterinfo == nil then
		return;
	end
	local msgType = clusterinfo:GetMsgType();

	-- 発言はシステムメッセージではない
	if (msgType ~= "Notice") and (msgType ~= "System") and (msgType ~= "Battle") then
		-- 内容
		local nicoMsg = string.gsub(clusterinfo:GetMsg(), "({/}{/})", "%1{@st64}");
		CHATEXTENDS_NICO_CHAT(string.format("[%s] : %s", clusterinfo:GetCommanderName(), nicoMsg));
	end
end

-- ***************************************
-- 発言レコード保存
-- ***************************************
function CHATEXTENDS_CHAT_REC(frame, msg)
	local groupboxname, startindex, chatframe = acutil.getEventArgs(msg);

	-- 設定の録画フラグがOFFなら終了
	if g.settings.REC_CHAT_FLG == false then
		return;
	end

	-- 再描画とかで開始インデックスが0以下なら終了
	if startindex <= 0 then
		return;
	end
	-- メインのチャットフレームの文言のみ
	if chatframe ~= ui.GetFrame("chatframe") then
		return;
	end
	-- メインの全体発言のみ
	if groupboxname ~= "chatgbox_TOTAL" then
		return;
	end

	local groupbox = GET_CHILD(chatframe,groupboxname);
	-- 取れなかったら(ありえるのか？)終了
	if groupbox == nil then
		return;
	end

	local clusterinfo = session.ui.GetChatMsgInfo(groupboxname, startindex)
	-- 取れなかったら(ありえるのか？)終了
	if clusterinfo == nil then
		return;
	end
	local msgType = clusterinfo:GetMsgType();

	-- 設定の録画フラグがON
	-- 発言はシステムメッセージではない
	if (msgType ~= "Notice") and (msgType ~= "System") then
		-- ファイル名に使用する時間
		local time = geTime.GetServerSystemTime();
		local year = string.format("%04d",time.wYear);
		local month = string.format("%02d",time.wMonth);
		local day = string.format("%02d",time.wDay);

		-- ファイル名は recchat_YYYYMMDD_cid.txt
		local logfile=string.format("recchat_%s%s%s_%s.txt", year,month,day,CHATEXTENDS_GET_LOGFILE_CHARNAME());

		-- ファイル追記モード
		local file,err = io.open(g.SAVE_DIR.."/"..logfile, "a");
		file:write(CHATEXTENDS_GET_MSGBODY(clusterinfo,clusterinfo:GetMsg()));
		file:close();
	end
end

-- ***************************************
-- 吹き出し表示
-- ***************************************
function CHATEXTENDS_BALLON_DRAW(groupboxname, groupbox, clustername, clusterinfo, commnderName, msgType, marginRight, marginLeft, ypos, fontSize, beforeclusterinfo)
	local tempfontSize = string.format("{s%s}", fontSize);
	local tempCommnderName = string.gsub(commnderName,"( %[.+%])", "");

	local chatCtrlName = 'chatu';
	if tempCommnderName == GETMYFAMILYNAME() then
		chatCtrlName = 'chati';
	end
	local horzGravity = ui.LEFT;
	if chatCtrlName == 'chati' then
		horzGravity = ui.RIGHT;
	end

	local chatCtrl = nil;
	if chatCtrlName == 'chati' then
		chatCtrl = groupbox:CreateOrGetControl('groupbox', clustername, 400, 100, horzGravity, ui.TOP, marginLeft, ypos + 5, marginRight, 0);
		AUTO_CAST(chatCtrl);
		chatCtrl:EnableHitTest(1);
		chatCtrl:SetSkinName("NONE");
		chatCtrl:EnableScrollBar(0);

		local labelBox = chatCtrl:CreateOrGetControl("groupbox", "bg", 380, 40, horzGravity, ui.TOP, 0, 0, 2, 0);
		AUTO_CAST(labelBox);
		labelBox:SetSkinName("textballoon");

		local text = labelBox:CreateOrGetControl("richtext", "text", 320, 20, ui.CENTER_HORZ, ui.CENTER_VERT, 0, 0, 0, 0);
		AUTO_CAST(text);
		text:SetUseOrifaceRect(true);
		text:EnableResizeByText(1);
		text:SetTextMaxWidth(320);
		text:SetTextFixWidth(0);
		text:SetTextAlign("left", "top");
		text:EnableSplitBySpace(0);
		text:SetFormat("%s{s%s}%s");
		text:AddParamInfo("font", "{#050505}");
		text:AddParamInfo("size", "16");
		text:AddParamInfo("text", "AAA");

		local timebox = chatCtrl:CreateOrGetControl("groupbox", "timebox", 70, 18, ui.LEFT, ui.TOP, 0, 7, 0, 0);
		AUTO_CAST(timebox);
		timebox:EnableHitTest(0);
		timebox:SetSkinName("chat_time_bg2");
		timebox:EnableScrollBar(0);

		local time = timebox:CreateOrGetControl("richtext", "time", 70, 18, ui.CENTER_HORZ, ui.CENTER_VERT, 0, 0, 0, 0);
		AUTO_CAST(time);
		time:SetUseOrifaceRect(true);
		time:EnableResizeByText(1);
		time:SetTextMaxWidth(0);
		time:SetTextFixWidth(0);
		time:SetTextAlign("center", "center");
		time:SetFontName('white_14_ol')
		time:AddParamInfo("time", "PM 16:16");
	else
		chatCtrl = groupbox:CreateOrGetControl('groupbox', clustername, 400, 100, horzGravity, ui.TOP, marginLeft, ypos + 5, marginRight, 0);
		AUTO_CAST(chatCtrl);
		chatCtrl:EnableHitTest(1);
		chatCtrl:SetSkinName("NONE");
		chatCtrl:EnableScrollBar(0);

		local labelBox = chatCtrl:CreateOrGetControl("groupbox", "bg", 380, 40, horzGravity, ui.TOP, 0, 18, 0, 0);
		AUTO_CAST(labelBox);
		labelBox:SetSkinName("textballoon_reflect");

		local text = labelBox:CreateOrGetControl("richtext", "text", 330, 20, ui.CENTER_HORZ, ui.CENTER_VERT, 0, 0, 0, 0);
		AUTO_CAST(text);
		text:SetUseOrifaceRect(true);
		text:EnableResizeByText(1);
		text:SetTextMaxWidth(330);
		text:SetTextFixWidth(0);
		text:SetTextAlign("left", "top");
		text:EnableSplitBySpace(0);
		text:SetFormat("%s{s%s}%s");
		text:AddParamInfo("font", "{#050505}{b}");
		text:AddParamInfo("size", "16");
		text:AddParamInfo("text", "AAA");

		local name = chatCtrl:CreateOrGetControl("richtext", "name", 319, 22, ui.LEFT, ui.TOP, 10, 0, 0, 0);
		AUTO_CAST(name);
		name:SetUseOrifaceRect(true);
		name:EnableResizeByText(1);
		name:SetTextMaxWidth(200);
		name:SetTextFixWidth(0);
		name:SetTextAlign("left", "top");
		name:SetFormat("{@st42b}%s");
		name:AddParamInfo("name", "AAAAAAABBBBBBBCCCCCC");

		local timebox = chatCtrl:CreateOrGetControl("groupbox", "timebox", 70, 18, ui.LEFT, ui.TOP, 50, 25, 0, 0);
		AUTO_CAST(timebox);
		timebox:EnableHitTest(0);
		timebox:SetSkinName("chat_time_bg2");
		timebox:EnableScrollBar(0);

		local time = timebox:CreateOrGetControl("richtext", "time", 70, 18, ui.CENTER_HORZ, ui.CENTER_VERT, 0, 0, 0, 0);
		AUTO_CAST(time);
		time:SetUseOrifaceRect(true);
		time:EnableResizeByText(1);
		time:SetTextMaxWidth(0);
		time:SetTextFixWidth(0);
		time:SetTextAlign("center", "center");
		time:SetFontName('white_14_ol')
		time:AddParamInfo("time", "PM 16:16");
	end
	if chatCtrl == nil then
		return
	end
	local label = chatCtrl:GetChild('bg');
	local fontStyle = g.usefontsettings.BALLONCHAT_FONTSTYLE;

	if msgType == "friendmem" then
		fontStyle = g.usefontsettings.BALLONCHAT_FONTSTYLE_MEMBER;
	elseif msgType == "guildmem" then
		fontStyle = g.usefontsettings.BALLONCHAT_FONTSTYLE_MEMBER;
	elseif msgType ~= "System" then
		chatCtrl:SetEventScript(ui.RBUTTONDOWN, 'CHAT_RBTN_POPUP');
		chatCtrl:SetUserValue("TARGET_NAME", commnderName);
	elseif msgType == "System" then
		fontStyle = g.usefontsettings.BALLONCHAT_FONTSTYLE_SYSTEM;
	end

	local myColor, targetColor = CHATEXTENDS_GET_CHAT_COLOR(msgType, clusterinfo:GetRoomID());
	local txt = GET_CHILD(label, "text", "ui::CRichText");
	local timeBox = GET_CHILD(chatCtrl, "timebox", "ui::CGroupBox");
	local timeCtrl = GET_CHILD(timeBox, "time", "ui::CRichText");
	local nameText = GET_CHILD(chatCtrl, "name", "ui::CRichText");

	txt:SetUserValue("ROOM_ID", clusterinfo:GetRoomID());

	local msgString = clusterinfo:GetMsg();
	msgString = string.gsub(msgString, "({img emoticon.-}){/}{/}", "%1");
	msgString = string.format("%s%s{/}{/}", tempfontSize, msgString);
	txt:SetTextByKey("font", fontStyle);
	txt:SetTextByKey("size", fontSize);
	txt:SetTextByKey("text", msgString);
	local labelMarginX = 0
	local labelMarginY = 0

	if chatCtrlName == 'chati' then
		label:SetSkinName('textballoon_i');
		label:SetColorTone(myColor);
	else
		label:SetColorTone(targetColor);
		if commnderName == "guildmem" or commnderName == "friendmem" then
			chatCtrl:RemoveChild("name");
		elseif commnderName == 'System' then
			nameText:SetText('{img chat_system_icon 65 18 }{/}');
		else
			nameText:SetText('{@st61}'..commnderName..'{/}');
			nameText:SetEventScript(ui.RBUTTONDOWN, 'CHAT_RBTN_POPUP');
			nameText:SetUserValue("TARGET_NAME", commnderName);
		end
	end

	timeCtrl:SetTextByKey("time", clusterinfo:GetTimeStr());

	local slflag = string.find(clusterinfo:GetMsg(),'a SL%a')
	if slflag == nil then
		label:EnableHitTest(0)
	else
		label:EnableHitTest(1)
	end
	UPDATE_READ_FLAG_BY_GBOX_NAME(groupboxname);
	CHATEXTENDS_RESIZE_CHAT_CTRL_BALLON(chatCtrl, label, txt, timeBox, tempCommnderName);
end

function CHATEXTENDS_GET_CHAT_COLOR(msgType, roomID)

	local myColor = g.usefontsettings.COLOR_WHI_MY;
	local targetColor = g.usefontsettings.COLOR_WHI_TO;

	local colorType = session.chat.GetRoomConfigColorType(roomID)
	local colorCls = GetClassByType("ChatColorStyle", colorType)

	if colorCls ~= nil then
		myColor = "FF"..colorCls.TextColor;
		targetColor = "FF"..colorCls.TextColor;
	elseif msgType == 'Normal' then
		myColor = g.usefontsettings.COLOR_NORMAL_MY;
		targetColor = g.usefontsettings.COLOR_NORMAL;
	elseif msgType == 'Shout' then
		myColor = g.usefontsettings.COLOR_SHOUT_MY;
		targetColor = g.usefontsettings.COLOR_SHOUT;
	elseif msgType == 'Party' then
		myColor = g.usefontsettings.COLOR_PARTY_MY;
		targetColor = g.usefontsettings.COLOR_PARTY;	
	elseif msgType == 'Guild' then
		myColor = g.usefontsettings.COLOR_GUILD_MY;
		targetColor = g.usefontsettings.COLOR_GUILD;
	elseif msgType == 'GuildNotice' then
		myColor = g.usefontsettings.COLOR_GUILD_NOTICE_MY;
		targetColor = g.usefontsettings.COLOR_GUILD_NOTICE;
	elseif msgType == "friendmem" then
		targetColor = g.usefontsettings.COLOR_PARTY_INFO;
	elseif msgType == "guildmem" then
		targetColor = g.usefontsettings.COLOR_GUILD_INFO;
	elseif msgType == "System" then
		myColor = g.usefontsettings.COLOR_SYSTEM_MY;
		targetColor = g.usefontsettings.COLOR_SYSTEM;
	elseif msgType == "Group" then
		myColor = g.usefontsettings.COLOR_GRO_MY;
		targetColor = g.usefontsettings.COLOR_GRO;
	end

	return myColor, targetColor;

end

--************************************************
-- 吹き出しの表示位置調整
--************************************************
function CHATEXTENDS_RESIZE_CHAT_CTRL_BALLON(chatCtrl, label, txt, timeBox, tempCommnderName)
	local lablWidth = txt:GetWidth() + 40;
	local chatWidth = chatCtrl:GetWidth();
	label:Resize(lablWidth, txt:GetHeight() + 20);

	chatCtrl:Resize(chatWidth, label:GetY() + label:GetHeight() + 10);

	local chatCtrlName = 'chatu';
	if tempCommnderName == GETMYFAMILYNAME() then
		chatCtrlName = 'chati';
	end
	if chatCtrlName == 'chati' then
		local offsetX = label:GetX() + txt:GetWidth() - 60;
		if 35 > offsetX then
			offsetX = offsetX + 40;
		end
		if timeBox ~= nil then
			if label:GetWidth() < timeBox:GetWidth() + 20 then
				offsetX = math.min(offsetX, label:GetX() - timeBox:GetWidth()/2);
			end
			timeBox:SetOffset(offsetX, label:GetY() + label:GetHeight() - 10);
		end
	else
		if timeBox ~= nil then
			local offsetX = label:GetX() + txt:GetWidth() - 60;
			if 35 > offsetX then
				offsetX = offsetX + 40;
			end
			timeBox:SetOffset(offsetX, label:GetY() + label:GetHeight() - 10);
		end
	end
end

--************************************************
-- 保存処理
--************************************************
function CHATEXTENDS_SAVE_CHAT()
	local groupboxname = "chatgbox_TOTAL";
	local chatframe = ui.GetFrame("chatframe");
	local groupbox = GET_CHILD(chatframe,groupboxname);
	local cnt = groupbox:GetChildCount();
	local clusterinfo = nil;

	-- ファイル名に使用する時間
	local time = geTime.GetServerSystemTime();
	local year = string.format("%04d",time.wYear);
	local month = string.format("%02d",time.wMonth);
	local day = string.format("%02d",time.wDay);
	local hour = string.format("%02d",time.wHour);
	local min = string.format("%02d",time.wMinute);
	local sec = string.format("%02d",time.wSecond);

	-- ファイル名は YYYYMMDD_HHMISS_cid.txt
	local logfile=string.format("savechat_%s%s%s_%s%s%s_%s.txt", year,month,day,hour,min,sec,CHATEXTENDS_GET_LOGFILE_CHARNAME());

	-- ファイル書き込みモード
	local file,err = io.open(g.SAVE_DIR.."/"..logfile, "w")
	if err then
		if option.GetCurrentCountry()=="Japanese" then
			ui.SysMsg("チャットの保存に失敗しました(フォルダがない？)");
		else
			ui.SysMsg("SAVE CHAT FAILED.(NOT DIRECTORY?)");
		end
	else
		for i = 0 , cnt - 2 do
			clusterinfo = session.ui.GetChatMsgInfo(groupboxname, i);
			file:write(CHATEXTENDS_GET_MSGBODY(clusterinfo,clusterinfo:GetMsg()));
		end
		file:close();
		if option.GetCurrentCountry()=="Japanese" then
			ui.SysMsg("チャットを保存しました");
		else
			ui.SysMsg("SAVE CHAT");
		end
	end
end

function CHATEXTENDS_GET_LOGFILE_CHARNAME()
    return session.GetMySession():GetCID()
end

--************************************************
-- ファイル書き込めるか確認
--************************************************
function CHATEXTENDS_CHECK_DIR(dirname)
	local file,err = io.open(dirname.."/test.tmp", "w")
	if err then
		return false
	else
		file:close();
		os.remove(dirname.."/test.tmp");
		return true
	end
end

--************************************************
-- ファイル出力内容
--************************************************
function CHATEXTENDS_GET_MSGBODY(clusterinfo,msgbody)
	local logbody="";
	local tempstr="";
	logbody=string.format("%s %s %s:%s{nl}", clusterinfo:GetTimeStr(), CHATEXTENDS_GET_MSGTYPE_TXT(clusterinfo:GetMsgType()),clusterinfo:GetCommanderName(),msgbody);
	logbody=string.gsub(logbody,"{nl}", "\n");
	logbody=string.gsub(logbody,"{.-}", "");

	-- stinrg.gsub内で直接dictionary.ReplaceDicIDInCompStr("%1")とやったが使えなかった
	-- ので、一時変数に入れる
	tempstr=string.match(logbody, "(@dicID.+%*%^)");
	if tempstr ~= nil then
		tempstr = dictionary.ReplaceDicIDInCompStr(tempstr);
		logbody=string.gsub(logbody,"(@dicID.+%*%^)", tempstr);
	end
	return logbody;
end

--************************************************
-- ファイル出力時のメッセージタイプの文言
--************************************************
function CHATEXTENDS_GET_MSGTYPE_TXT(msgType)
	if option.GetCurrentCountry()=="Japanese" then
		if (msgType == "friendmem") or (msgType == "guildmem") then
			return "[システム　]";
		elseif msgType == "Normal" then
			return "[一般　　　]";
		elseif msgType == "Shout" then
			return "[シャウト　]";
		elseif msgType == "Party" then
			return "[パーティー]";
		elseif msgType == "Guild" then
			return "[ギルド　　]";
		elseif msgType == "Notice" then
			return "[お知らせ　]";
		elseif msgType == "System" then
			return "[システム　]";
		elseif msgType == "Whisper" then
			return "[ささやき　]";
		elseif msgType == "Group" then
			return "[グループ　]";
		end
	else
		return "["..msgType.."]";
	end
end

--************************************************
-- サイズ変更
--************************************************
function CHATEXTENDS_CHAT_SET_FONTSIZE_N_COLOR(chatframe) 

	if chatframe == nil then
		return;
	end

	local offsetX = chatframe:GetUserConfig("CTRLSET_OFFSETX");
	local targetSize = GET_CHAT_FONT_SIZE();
	local count = chatframe:GetChildCount();
	for  i = 0, count-1 do 
		local groupBox  = chatframe:GetChildByIndex(i);
		local childName = groupBox:GetName();

		if string.sub(childName, 1, 9) == "chatgbox_" then
			if groupBox:GetClassName() == "groupbox" then
				groupBox = AUTO_CAST(groupBox);
				local beforeHeight = 1;
				local lastChild = nil;
				local ctrlSetCount = groupBox:GetChildCount();
				for j = 0 , ctrlSetCount - 1 do
					local clusterinfo = session.ui.GetChatMsgInfo(childName, j);
					local commnderName = "";
					local tempCommnderName = "";
					--if clusterinfo ~= nil then
					--	commnderName = clusterinfo:GetCommanderName();
					--	tempCommnderName = string.gsub(commnderName,"( %[.+%])", "");
					--end
				
					local chatCtrl = groupBox:GetChildByIndex(j);
					if chatCtrl:GetClassName() == "controlset" then
						local label = chatCtrl:GetChild('bg');
						if g.settings.BALLON_FLG then
							local txt = GET_CHILD(label, "text", "ui::CRichText");

							if txt == nil then
								txt = GET_CHILD(chatCtrl, "text", "ui::CRichText");
							end;	

							local msgString = CHAT_TEXT_CHAR_RESIZE(txt:GetTextByKey("text"), targetSize);
							txt:SetTextByKey("text", msgString);
							txt:SetTextByKey("size", targetSize);

							local roomid = txt:GetUserValue("ROOM_ID")

							if roomid ~= "None" then

								local colorType = session.chat.GetRoomConfigColorType(roomid)
								local colorCls = GetClassByType("ChatColorStyle", colorType)

								if colorCls ~= nil then
									label:SetColorTone("FF".. colorCls.TextColor);
								end
							end

							local timeBox = GET_CHILD(chatCtrl, "timebox", "ui::CGroupBox");
							CHATEXTENDS_RESIZE_CHAT_CTRL_BALLON(chatCtrl, label, txt, timeBox, tempCommnderName)
						else

							local txt = GET_CHILD(chatCtrl, "text", "ui::CRichText");
							local msgString = CHAT_TEXT_CHAR_RESIZE(txt:GetTextByKey("text"), targetSize);
							
							
							local roomid = txt:GetUserValue("ROOM_ID")

							if roomid ~= "None" then

								local colorType = session.chat.GetRoomConfigColorType(roomid)
								local colorCls = GetClassByType("ChatColorStyle", colorType)

								if colorCls ~= nil then
									fontStyle = "{#"..colorCls.TextColor.."}{b}{ol}"
									txt:SetTextByKey("font", fontStyle);
								end
							end

							txt:SetTextByKey("text", msgString);
							txt:SetTextByKey("size", targetSize);	
							local timeBox = GET_CHILD(chatCtrl, "time");
							RESIZE_CHAT_CTRL(chatframe, chatCtrl, label, txt, timeBox, offsetX)
						end
							
						beforeHeight = chatCtrl:GetY() + chatCtrl:GetHeight();
						lastChild = chatCtrl;
					end
				end

				GBOX_AUTO_ALIGN(groupBox, 0, 0, 0, true, false);
				if lastChild ~= nil then
					local afterHeight = lastChild:GetY() + lastChild:GetHeight();					
					local heightRatio = afterHeight / beforeHeight;
					
					groupBox:UpdateData();
					groupBox:SetScrollPos(groupBox:GetCurLine() * (heightRatio * 1.1));
				end
			end
		end
	end

    if string.find(chatframe:GetName(),"chatpopup") ~= nil then
           CHATPOPUP_FOLD_BY_SIZE(chatframe)
    end

	chatframe:Invalidate();

end

--************************************************
-- フレームスキン変更
--************************************************
function CHATEXTENDS_CHAT_ADD_GBOX_OPTION_FOR_CHATFRAME(gbox)
	gbox = AUTO_CAST(gbox)
	
	local parentframe = gbox:GetParent()

	gbox:SetLeftScroll(1)
	-- skin change
--	gbox:SetSkinName("chat_window")
	gbox:SetSkinName("chat_Whisper_talkskin_cusoron")
	gbox:EnableVisibleVector(true);
	gbox:EnableHitTest(1);
	gbox:EnableHittestGroupBox(true);
	gbox:LimitChildCount(500);
	gbox:SetEventScript(ui.SCROLL, "SCROLL_CHAT");
	gbox:EnableAutoResize(true,true);

	if string.find(parentframe:GetName(),"chatpopup_") == nil then
		gbox:ShowWindow(0)
		gbox:SetScrollBarBottomMargin(26)
	else
		gbox:SetScrollBarBottomMargin(0)
		gbox:ShowWindow(1)
	end

	CHATEXTENDS_CHAT_SET_OPACITY(gbox)

end

--************************************************
-- 背景色設定
--************************************************
function CHATEXTENDS_CHAT_SET_OPACITY(gbox)
	local parentframe = gbox:GetParent()

    local opacity = session.chat.GetChatUIOpacity();

	local colorToneStr = string.format("%02X", opacity);
	colorToneStr = colorToneStr .. "FFFFFF";

	CHAT_SET_CHAT_FRAME_OPACITY(parentframe, colorToneStr)

end

--************************************************
-- NICO_CHAT独自用
--************************************************
function CHATEXTENDS_NICO_CHAT(msg)

	local x = ui.GetClientInitialWidth();
	local factor;
	if IMCRandom(0, 1) == 1 then
		factor = IMCRandomFloat(0.05, 0.4);
	else
		factor = IMCRandomFloat(0.6, 0.9);
	end

	local y = ui.GetClientInitialHeight() * factor;
	local spd = -IMCRandom(150, 200);

	-- change
	local frame = ui.GetFrame("fieldui");
	local name = UI_EFFECT_GET_NAME(frame, "NICO_");
	local ctrl = frame:CreateControl("richtext", name, x, y, 200, 20);
	
	ctrl:ShowWindow(1);
	ctrl = tolua.cast(ctrl, "ui::CRichText");
	ctrl:EnableResizeByText(1);
	ctrl:SetText("{@st64}" .. msg);
	ctrl:RunUpdateScript("NICO_MOVING");
	ctrl:SetUserValue("NICO_SPD", spd);
	ctrl:SetUserValue("NICO_START_X", x);

	frame:RunUpdateScript("INVALIDATE_NICO");
end

local json = require "json_imc"
function CHATEXTENDS_GUILD_NOTICE_MSG_CHECK(code, ret_json, argStr)
	if code ~= 200 then
		return;
	end
	
	local guild = GET_MY_GUILD_INFO();
	if guild == nil then
		return;
	end

	local ret = false;
    local parsed_json = json.decode(ret_json)
	for k, v in pairs(parsed_json) do
		if v == 208 then -- 메시지 강조 권한
			ret = true;
			break;
		end
    end

	if ret == true then 
		return;
	end

	local argStrlist = StringSplit(argStr, ";");
	local frame = ui.GetFrame(argStrlist[1]);
	local groupbox = GET_CHILD(frame, argStrlist[2]);
	local clustername = "cluster_" .. argStrlist[3];
	local chatCtrl = GET_CHILD(groupbox, clustername);
	if chatCtrl == nil then
		return;
	end

	local mainchatFrame = ui.GetFrame("chatframe");
	local fontStyle = mainchatFrame:GetUserConfig("TEXTCHAT_FONTSTYLE_GUILD");

	local txt = GET_CHILD(chatCtrl, "text");
	txt:SetTextByKey("font", fontStyle);
	groupbox:Invalidate();

end
