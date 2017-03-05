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
g.saveChatDir = "../release/savechat";

--デフォルト設定
if not g.loaded then
  g.settings = {
	-- システムメッセージを全体フレームのみに表示するフラグ
	SYSTEM_TOTAL_FLG=true;
	-- 発言をニコニコ風に表示するフラグ
	NICO_CHAT_FLG=true;
	-- 発言を記録していくフラグ
	REC_CHAT_FLG=false;
  };
end

--ライブラリ読み込み
local acutil = require('acutil');

-- 開始インデックス チャット削除したら変更
g.CHATEXTENDS_BASE_INDEX = 0;

-- チャットフレームのボタン押下のフラグ
g.CHATEXTENDS_TOTAL_FLG=true;
g.CHATEXTENDS_GENERAL_FLG=false;
g.CHATEXTENDS_SHOUT_FLG=false;
g.CHATEXTENDS_PARTY_FLG=false;
g.CHATEXTENDS_GUILD_FLG=false;
g.CHATEXTENDS_WHISPER_FLG=false;

-- チャットフレームのオープンクローズフラグ
g.CHATEXTENDS_FRAME_OPEN_FLG=true;

-- 読み込みフラグ
g.loaded=false

--lua読み込み時のメッセージ
CHAT_SYSTEM(string.format("%s.lua is loaded", addonName));

-- フレーム内文字
if option.GetCurrentCountry()=="Japanese" then
	headertxt = "拡張設定";
	systemtxt = "システムメッセージを{nl}全体フレームのみに表示する";
	nicotxt = "チャット内容をニコニコ動画{nl}のように表示する";
	rectxt = "チャット内容を記録し続ける";
else
	headertxt = "extends setting";
	systemtxt = "Display system messages{nl}only in the total frame";
	nicotxt = "Chat contents{nl}flow from the right";
	rectxt = "Record Chat Content";
end


function CHATEXTENDS_SAVE_SETTINGS()
	acutil.saveJSON(g.settingsFileLoc, g.settings);
end

--マップ読み込み時処理（1度だけ）
function ZCHATEXTENDS_ON_INIT(addon, frame)
	-- 初期設定項目は1度だけ行う
	if g.loaded==false then
		g.addon = addon;
		g.frame = frame;

		-- ファッキン封印
		if nil ~= FKSYSTEMMSG_ON_INIT then
			FKSYSTEMMSG_ON_INIT = nil;
			DRAW_CHAT_MSG_HOOKED = nil;
			DRAW_CHAT_MSG_MAIN = nil;
			DRAW_CHAT_MSG = DRAW_CHAT_MSG_OLD;
		end

		-- 元関数封印
		if nil == CHATEXTENDS_DRAW_CHAT_MSG_OLD then
			CHATEXTENDS_DRAW_CHAT_MSG_OLD = DRAW_CHAT_MSG;
			DRAW_CHAT_MSG = CHATEXTENDS_DRAW_CHAT_MSG_LOAD;
		end
		if nil == CHATEXTENDS_REDRAW_CHAT_MSG_OLD then
			CHATEXTENDS_REDRAW_CHAT_MSG_OLD = REDRAW_CHAT_MSG;
			REDRAW_CHAT_MSG = CHATEXTENDS_REDRAW_CHAT_MSG_LOAD;
		end
		if nil == CHATEXTENDS_CHAT_TOTAL_ON_BTN_UP_OLD then
			CHATEXTENDS_CHAT_TOTAL_ON_BTN_UP_OLD = CHAT_TOTAL_ON_BTN_UP;
			CHAT_TOTAL_ON_BTN_UP = CHATEXTENDS_CHAT_TOTAL_ON_BTN_UP;
		end
		if nil == CHATEXTENDS_CHAT_GENERAL_ON_BTN_UP_OLD then
			CHATEXTENDS_CHAT_GENERAL_ON_BTN_UP_OLD = CHAT_GENERAL_ON_BTN_UP;
			CHAT_GENERAL_ON_BTN_UP = CHATEXTENDS_CHAT_GENERAL_ON_BTN_UP;
		end
		if nil == CHATEXTENDS_CHAT_SHOUT_ON_BTN_UP_OLD then
			CHATEXTENDS_CHAT_SHOUT_ON_BTN_UP_OLD = CHAT_SHOUT_ON_BTN_UP;
			CHAT_SHOUT_ON_BTN_UP = CHATEXTENDS_CHAT_SHOUT_ON_BTN_UP;
		end
		if nil == CHATEXTENDS_CHAT_PARTY_ON_BTN_UP_OLD then
			CHATEXTENDS_CHAT_PARTY_ON_BTN_UP_OLD = CHAT_PARTY_ON_BTN_UP;
			CHAT_PARTY_ON_BTN_UP = CHATEXTENDS_CHAT_PARTY_ON_BTN_UP;
		end
		if nil == CHATEXTENDS_CHAT_GUILD_ON_BTN_UP_OLD then
			CHATEXTENDS_CHAT_GUILD_ON_BTN_UP_OLD = CHAT_GUILD_ON_BTN_UP;
			CHAT_GUILD_ON_BTN_UP = CHATEXTENDS_CHAT_GUILD_ON_BTN_UP;
		end
		if nil == CHATEXTENDS_CHAT_WHISPER_ON_BTN_UP_OLD then
			CHATEXTENDS_CHAT_WHISPER_ON_BTN_UP_OLD = CHAT_WHISPER_ON_BTN_UP;
			CHAT_WHISPER_ON_BTN_UP = CHATEXTENDS_CHAT_WHISPER_ON_BTN_UP;
		end
		if nil == CHATEXTENDS_CHAT_FRAME_NOW_BTN_SKN_OLD then
			CHATEXTENDS_CHAT_FRAME_NOW_BTN_SKN_OLD = CHAT_FRAME_NOW_BTN_SKN;
			CHAT_FRAME_NOW_BTN_SKN = CHATEXTENDS_CHAT_FRAME_NOW_BTN_SKN;
		end
		if nil == CHATEXTENDS_CHAT_SET_FROM_TITLENAME_OLD then
			CHATEXTENDS_CHAT_SET_FROM_TITLENAME_OLD = CHAT_SET_FROM_TITLENAME;
			CHAT_SET_FROM_TITLENAME = CHATEXTENDS_CHAT_SET_FROM_TITLENAME;
		end
		if nil == CHATEXTENDS_CHAT_CHAT_SET_TO_TITLENAME_OLD then
			CHATEXTENDS_CHAT_CHAT_SET_TO_TITLENAME_OLD = CHAT_SET_TO_TITLENAME;
			CHAT_SET_TO_TITLENAME = CHATEXTENDS_CHAT_CHAT_SET_TO_TITLENAME;
		end

		--コマンド登録
		acutil.slashCommand("/deletechat", CHATEXTENDS_DELETE_CHAT);
		acutil.slashCommand("/savechat", CHATEXTENDS_SAVE_CHAT);

		-- 初期フラグ
		g.CHATEXTENDS_TOTAL_FLG=true;
		g.CHATEXTENDS_GENERAL_FLG=false;
		g.CHATEXTENDS_SHOUT_FLG=false;
		g.CHATEXTENDS_PARTY_FLG=false;
		g.CHATEXTENDS_GUILD_FLG=false;
		g.CHATEXTENDS_WHISPER_FLG=false;

		-- 設定読み込み
		if not g.loaded then
			local t, err = acutil.loadJSON(g.settingsFileLoc, g.settings);
			-- 読み込めない = ファイルがない
			if err then
				-- フォルダ作ってファイル作る
				CHATEXTENDS_CREATE_DIR(g.settingsDirLoc);
				CHATEXTENDS_SAVE_SETTINGS();
			else
				-- 読み込めたら読み込んだ値使う
				g.settings = t;
			end
			g.loaded = true;
		end
		-- 必要フォルダ作る
		CHATEXTENDS_CREATE_DIR(g.saveChatDir);
	end

	--イベント登録
	acutil.setupEvent(addon, "DRAW_CHAT_MSG", "CHATEXTENDS_DRAW_CHAT_MSG_POPUP_EVENT")
	acutil.setupEvent(addon, "REDRAW_CHAT_MSG", "CHATEXTENDS_REDRAW_CHAT_MSG_POPUP_EVENT")

	-- フレーム制御はマップ移動毎に行う

	-- チャット入力を変更
	CHATEXTENDS_UPDATE_CHAT_FRAME();

	-- 設定項目をチャットオプションに追加
	CHATEXTENDS_CREATE_CHATOPTION_FRAME();
end

-- チャット入力を変更
function CHATEXTENDS_UPDATE_CHAT_FRAME()
	local chat_frame = ui.GetFrame("chat");
	chat_frame:Resize(750,chat_frame:GetHeight());
	chat_frame:SetOffset(chat_frame:GetX(),chat_frame:GetY()+100);
	chat_frame:EnableMove(0);
	local edit_bg=GET_CHILD(chat_frame,"edit_bg");
	edit_bg:Resize(742,36);
	local mainchat=GET_CHILD(chat_frame,"mainchat");
	local titleCtrl = GET_CHILD(chat_frame,'edit_to_bg');
	titleCtrl:SetGravity(ui.LEFT, ui.TOP);
	local offsetX = 100;
	mainchat:SetGravity(ui.LEFT, ui.TOP);
	mainchat:Resize(600 - titleCtrl:GetWidth() - offsetX + 10, mainchat:GetOriginalHeight())
	mainchat:SetOffset(titleCtrl:GetWidth() + offsetX, mainchat:GetOriginalY());

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
	party_button:SetOffset(107, -1);
	party_button:SetClickSound("button_click");
	party_button:SetOverSound("button_cursor_over_2");
	party_button:SetAnimation("MouseOnAnim", "btn_mouseover");
	party_button:SetAnimation("MouseOffAnim", "btn_mouseoff");
	party_button:SetEventScript(ui.LBUTTONDOWN, "LINK_PARTY_INVITE");
	party_button:SetImage("link_party");
	party_button:SetImage("button_party");
	party_button:Resize(37, 37);
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
	chat_option_frame:Resize(600,chat_option_frame:GetHeight());
	local header = chat_option_frame:CreateOrGetControl("richtext", "CHATEXTENDS_HEADER", 300, 43, 120, 34);
	tolua.cast(header, 'ui::CRichText');
	header:SetFontName("white_16_ol");
	header:SetText("{@st42}"..headertxt.."{/}");

	local system_total_flg_chk = chat_option_frame:CreateOrGetControl('checkbox', "CHATEXTENDS_SYSTEM_TOTAL_FLG", 315, 65, 120, 24);
	system_total_flg_chk = tolua.cast(system_total_flg_chk, "ui::CCheckBox");
	system_total_flg_chk:SetFontName("white_16_ol");
	system_total_flg_chk:SetText(systemtxt);
	system_total_flg_chk:SetClickSound('button_click_big');
	system_total_flg_chk:SetAnimation("MouseOnAnim", "btn_mouseover");
	system_total_flg_chk:SetAnimation("MouseOffAnim", "btn_mouseoff");
	system_total_flg_chk:SetOverSound('button_over');
	system_total_flg_chk:SetEventScript(ui.LBUTTONUP, "CHATEXTENDS_TOGGLE_SYSTEM_TOTAL_FLG");
	if g.settings.SYSTEM_TOTAL_FLG then
		system_total_flg_chk:SetCheck(1);
	else
		system_total_flg_chk:SetCheck(0);
	end

	local nico_chat_flg_chk = chat_option_frame:CreateOrGetControl('checkbox', "CHATEXTENDS_NICO_CHAT_FLG", 315, 115, 120, 24);
	nico_chat_flg_chk = tolua.cast(nico_chat_flg_chk, "ui::CCheckBox");
	nico_chat_flg_chk:SetFontName("white_16_ol");
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

	local rec_chat_flg_chk = chat_option_frame:CreateOrGetControl('checkbox', "CHATEXTENDS_REC_CHAT_FLG", 315, 165, 120, 24);
	rec_chat_flg_chk = tolua.cast(rec_chat_flg_chk, "ui::CCheckBox");
	rec_chat_flg_chk:SetFontName("white_16_ol");
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

-- チャットサイズの設定
-- タイプを変えたりささやき相手の名前表示したりしたら、入力フレームがリサイズされるので、その対策
function CHATEXTENDS_CHAT_CHAT_SET_TO_TITLENAME(chatType, targetName, count)
	CHATEXTENDS_CHAT_CHAT_SET_TO_TITLENAME_OLD(chatType, targetName, count)
	local chat_frame = ui.GetFrame('chat');
	local mainchat = GET_CHILD(chat_frame, 'mainchat');
	local titleCtrl = GET_CHILD(chat_frame,'edit_to_bg');
	local offsetX = 100;

	mainchat:Resize(600 - titleCtrl:GetWidth() - offsetX + 10, mainchat:GetOriginalHeight())
	mainchat:SetOffset(titleCtrl:GetWidth() + offsetX, mainchat:GetOriginalY());

end

-- チャット表示処理のフック処理
function CHATEXTENDS_DRAW_CHAT_MSG_LOAD(groupboxname, size, startindex, framename)
	CHATEXTENDS_MAIN(groupboxname, size, startindex, "chatframe", true, true)
end

-- チャット表示処理(ささやきなどのポップアップウィンドウ)のイベント
function CHATEXTENDS_DRAW_CHAT_MSG_POPUP_EVENT(frame, msg, argStr, argNum)
	local groupboxname, size, startindex, framename = acutil.getEventArgs(msg);
	local popupframename = "chatpopup_" ..string.sub(groupboxname, 10, string.len(groupboxname));
	if ui.GetFrame(popupframename) == nil then
		return;
	end
	CHATEXTENDS_MAIN(groupboxname, size, startindex, popupframename, true, true)
end

-- チャット再表示処理のフック処理
function CHATEXTENDS_REDRAW_CHAT_MSG_LOAD(groupboxname, size, roomId)
	CHATEXTENDS_REDRAW_CHAT_MSG_MAIN(groupboxname, size, roomId)
end

-- チャット再表示メイン
function CHATEXTENDS_REDRAW_CHAT_MSG_MAIN(groupboxname, size, roomId)
	local framename = "chatframe";
	local chatframe = ui.GetFrame(framename)
	if chatframe == nil then
		return
	end

	if "chatgbox_TOTAL" == groupboxname then
		CREATE_DEF_CHAT_GROUPBOX(chatframe);
	end;

	CHATEXTENDS_MAIN(groupboxname, size, 0, framename, false, false);
end

-- チャット再表示処理(ささやきなどのポップアップウィンドウ)のイベント
function CHATEXTENDS_REDRAW_CHAT_MSG_POPUP_EVENT(frame, msg, argStr, argNum)
	local groupboxname, size, roomId = acutil.getEventArgs(msg);
	if roomId ~= nil then
		local framename = "chatpopup_" .. roomId;
		local chatpopup_frame = ui.GetFrame(framename);
		if chatpopup_frame ~= nil then
			CREATE_DEF_CHAT_GROUPBOX(chatpopup_frame);
			CHATEXTENDS_MAIN(groupboxname, size, 0, framename, false, false);
		else
			return
		end
	end
end

--************************************************
-- メイン
-- DRAW_CHAT_MSGの拡張
-- 　引数：String groupboxname
-- 　　　　処理対象のgbox名
-- 　　　　gboxはframe:chatframe内のframeオブジェクト
-- 　引数：int endindex (元関数ではsize)
-- 　　　　チャット配列の表示処理終了index
-- 　　　　C側から呼ばれる度に+1されて呼ばれている
-- 　引数：int startindex
-- 　　　　チャット配列の表示処理開始index
-- 　　　　startindex ～ endindex のチャット配列に対して表示処理を行う 
-- 　引数：String framename
-- 　　　　処理対象フレーム名
-- 　引数：boolean nicoflg
-- 　　　　この処理時にはニコニコ風に出すかどうかのフラグ
-- 　　　　通常はtrue
-- 　　　　全体や一般やパーティーなどの切り替えだけでは出さない(false)
-- 　引数：boolean recflg
-- 　　　　この処理時にはチャットを記録し続けるか(録画するか)のフラグ
-- 　　　　通常はtrue
-- 　　　　全体や一般やパーティーなどの切り替えだけでは出さない(false)
--************************************************
function CHATEXTENDS_MAIN(groupboxname, endindex, startindex, framename, nicoflg, recflg)

	-- 全体フレームの発言以外終了
	if (groupboxname == "chatgbox_1") or (groupboxname == "chatgbox_2") or (groupboxname == "chatgbox_3") or (groupboxname == "chatgbox_4")
	 or (groupboxname == "chatgbox_5") or (groupboxname == "chatgbox_6") or (groupboxname == "chatgbox_7") or (groupboxname == "chatgbox_8")
	  or (groupboxname == "chatgbox_9") or (groupboxname == "chatgbox_10") or (groupboxname == "chatgbox_11") or (groupboxname == "chatgbox_12")
	   or (groupboxname == "chatgbox_13") or (groupboxname == "chatgbox_14") or (groupboxname == "chatgbox_15") then
		return;
	end
	-- 開始indexがおかしかったら0から表示
	if startindex < 0 then
		startindex = 0
	end
	-- フレーム初期化
	local chatframe = ui.GetFrame(framename)
	local groupbox = GET_CHILD(chatframe,groupboxname);
	if groupbox == nil then
		local gboxleftmargin = chatframe:GetUserConfig("GBOX_LEFT_MARGIN")
		local gboxrightmargin = chatframe:GetUserConfig("GBOX_RIGHT_MARGIN")
		local gboxtopmargin = chatframe:GetUserConfig("GBOX_TOP_MARGIN")
		local gboxbottommargin = chatframe:GetUserConfig("GBOX_BOTTOM_MARGIN")
		groupbox = chatframe:CreateControl("groupbox", groupboxname, chatframe:GetWidth() - (gboxleftmargin + gboxrightmargin), 
										chatframe:GetHeight() - (gboxtopmargin + gboxbottommargin), ui.RIGHT, ui.BOTTOM, 0, 0, gboxrightmargin, gboxbottommargin);
		-- addon.ipf/chatframe/chatframe.lua function
		_ADD_GBOX_OPTION_FOR_CHATFRAME(groupbox)
	end

	-- 開始indexが0と一緒なら、既に表示されているチャットを全て削除
	if startindex == 0 then
		-- ui.ipf/uiscp/lib_ui.lua function
		-- 対象フレーム内の、指定した名前で始まるフレームを全て削除
		DESTROY_CHILD_BYNAME(groupbox, "cluster_");
		-- ニコフラグもオフ
		nicoflg = false;
		-- 録画フラグもオフ
		recflg = false;
	end

	-- メイン表示
	for i = startindex , endindex - 1 do
		CHATEXTENDS_DRAW_CHAT(chatframe, groupboxname, groupbox, i, nicoflg, recflg);
	end
	CHATEXTENDS_CHAT_AFTER(groupbox);
end

--************************************************
-- 表示処理
--************************************************
function CHATEXTENDS_DRAW_CHAT(chatframe, groupboxname, groupbox, index, nicoflg, recflg)

	-- 消してる発言ならフラグオフ
	if index < g.CHATEXTENDS_BASE_INDEX then
		nicoflg = false;
		recflg = false;
	end

	-- 発言フレームのY座標
	local ypos = CHATEXTENDS_GET_YPOS(groupboxname, groupbox, index);

	-- clusterinfoがチャット発言内容などが詰まってる
	local clusterinfo = session.ui.GetChatMsgClusterInfo(groupboxname, index)
	if clusterinfo == nil then
		return;
	end
	-- チャット内容のフレーム取得
	local cluster = CHATEXTENDS_GET_CLUSTER(chatframe,groupbox,clusterinfo,ypos);

	-- チャット表示
	CHATEXTENDS_DRAW_CHAT_FRAME(chatframe,clusterinfo,cluster, nicoflg, recflg);

	-- サイズ調整
	CHATEXTENDS_RESIZE_CHAT_CTRL(chatframe, cluster, groupboxname, groupbox, index);

end

--************************************************
-- チャット発言表示
--************************************************
function CHATEXTENDS_DRAW_CHAT_FRAME(chatframe, clusterinfo, cluster, nicoflg, recflg)

	-- チャット表示方法（吹き出しか簡易か）
	local textVer = IS_TEXT_VER_CHAT();
	-- メッセージタイプ
	local msgType = clusterinfo:GetMsgType();

	local fontStyle, msgFront = CHATEXTENDS_GET_CHATEXTENDS_PROP(clusterinfo,cluster);
	local fontSize = GET_CHAT_FONT_SIZE();
	local tempfontSize = string.format("{s%s}", fontSize);
	local label,txt = CHATEXTENDS_GET_LABEL_TXT(cluster);
	txt:SetTextByKey("font", fontStyle);
	txt:SetTextByKey("size", fontSize);
	-- 発言内容
	if textVer == 0 then
		local tempMsg = string.gsub(clusterinfo:GetMsg(), "({/}{/})", "%1" .. fontStyle .. tempfontSize);
		local tempstr=string.match(tempMsg, "(@dicID.+\*\^)");
		if tempstr ~= nil then
			tempstr = dictionary.ReplaceDicIDInCompStr(tempstr);
			tempMsg=string.gsub(tempMsg,"(@dicID.+\*\^)", tempstr);
		end
		txt:SetTextByKey("text", tempMsg);
	else
		-- 簡易表示のが編集ややこい
		local msgString = "";
		for i = 1 , clusterinfo:GetMsgItemCount() do
			local tempMsg = string.gsub(clusterinfo:GetMsgItembyIndex(i-1), "({/}{/}{/}{/}{/})", "%1" .. fontStyle .. tempfontSize);
			local tempstr=string.match(tempMsg, "(@dicID.+\*\^)");
			if tempstr ~= nil then
				tempstr = dictionary.ReplaceDicIDInCompStr(tempstr);
				tempMsg=string.gsub(tempMsg,"(@dicID.+\*\^)", tempstr);
			end
			local msgStingAdd = ' ';
			if msgType == "friendmem" or  msgType == "guildmem" then
				msgStingAdd = string.format("{%s}%s{nl}",msgFront, tempMsg);
			else
				msgStingAdd = string.format("%s : %s{nl}", msgFront, tempMsg);
			end
			msgString = msgString .. msgStingAdd;
		end;	
		msgString = string.format("%s{/}", CHAT_TEXT_LINKCHAR_FONTSET(chatframe, msgString));
		txt:SetTextByKey("text", msgString);
	end

	-- 発言はニコニコ風に出していい、かつ設定のニコフラグがON、かつシステムメッセージではない、かつささやき窓ではない
	if (nicoflg) and (g.settings.NICO_CHAT_FLG) and (msgType ~= "Notice") and (msgType ~= "System") and (msgType ~= clusterinfo:GetRoomID()) then
		-- チャット発言者
		local commnderName = clusterinfo:GetCommanderName();
		-- 内容
		local tempMsg = clusterinfo:GetMsgItembyIndex(clusterinfo:GetMsgItemCount()-1);
		tempMsg = string.gsub(tempMsg, "({/}{/})", "%1{@st64}");
		NICO_CHAT(string.format("[%s] : %s", commnderName, tempMsg));
	end

	-- 発言は録画していい、かつ設定の録画フラグがON、かつシステムメッセージではない、かつささやき窓ではない
	if (recflg) and (g.settings.REC_CHAT_FLG) and (msgType ~= "Notice") and (msgType ~= "System") and (msgType ~= clusterinfo:GetRoomID()) then
		-- ファイル名に使用する時間
		local time = geTime.GetServerSystemTime();
		local year = string.format("%04d",time.wYear);
		local month = string.format("%02d",time.wMonth);
		local day = string.format("%02d",time.wDay);

		-- ファイル名は recchat_YYYYMMDD_キャラ名.txt
		local logfile=string.format("recchat_%s%s%s_%s.txt", year,month,day,GETMYPCNAME());

		-- ファイル追記モード
		file,err = io.open(g.saveChatDir.."/"..logfile, "a");
		local tempMsg = clusterinfo:GetMsgItembyIndex(clusterinfo:GetMsgItemCount()-1);
		file:write(CHATEXTENDS_GET_MSGBODY(clusterinfo,tempMsg));
		file:close();
	end

	-- 他人の発言なら触れる、自分の発言なら触れないようにする
	local slflag = string.find(clusterinfo:GetMsg(),'a SL%a')
	if slflag == nil then
		label:EnableHitTest(0)
	else
		label:EnableHitTest(1)
	end

end

--************************************************
-- サイズ調整
--************************************************
function CHATEXTENDS_RESIZE_CHAT_CTRL(chatframe, cluster, groupboxname, groupbox, index)

	if index < g.CHATEXTENDS_BASE_INDEX then
		cluster:Resize( cluster:GetWidth() , 0);
		cluster:ShowWindow(0);
		return;
	end

	if CHATEXTENDS_GET_CLUSTER_DISPLAY_FLG(cluster) then
		local textVer = IS_TEXT_VER_CHAT();
		local label,txt = CHATEXTENDS_GET_LABEL_TXT(cluster);
		txt:SetTextFixWidth(0);
		txt:SetTextFixHeight(false);

		-- 発言フレームのY座標
		local ypos = CHATEXTENDS_GET_YPOS(groupboxname, groupbox, index);

		if textVer == 0  then
			local lablWidth = txt:GetWidth() + 40;
			local chatWidth = cluster:GetWidth();
			label:Resize(lablWidth, txt:GetHeight() + 20);
			cluster:Resize(chatWidth, label:GetY() + label:GetHeight() + 10);
			if cluster:GetX() == 0 then
				cluster:SetPos(0, ypos);
			else
				cluster:SetPos(33, ypos);
			end

			local offsetX = label:GetX() + txt:GetWidth() - 60;
			if 35 > offsetX then
				offsetX = offsetX + 40;
			end
			local timeBox = GET_CHILD(cluster, "timebox", "ui::CGroupBox");
			timeBox:SetOffset(offsetX, label:GetY() + label:GetHeight() - 10);
		else

			local chatWidth = chatframe:GetWidth();
			local offsetX = chatframe:GetUserConfig("CTRLSET_OFFSETX");
			label:Resize(chatWidth - offsetX, txt:GetHeight());
			cluster:Resize(chatWidth, label:GetHeight());
--			cluster:SetOffset(0, cluster:GetY()-2);
			cluster:SetPos(cluster:GetX(), ypos-2);

			local timeCtrl = GET_CHILD(cluster, "time", "ui::CRichText");
			timeCtrl:SetOffset(label:GetWidth() - 60, 2);
		end
	else
		cluster:Resize( cluster:GetWidth() , 0);
		cluster:ShowWindow(0);
	end

end

--************************************************
-- チャット表示フラグ取得
--************************************************
function CHATEXTENDS_GET_CLUSTER_DISPLAY_FLG(cluster)
	-- 全体フレームは問答無用でtrue
	if g.CHATEXTENDS_TOTAL_FLG then
		return true;
	end
	-- メッセージタイプ
	local msgType = cluster:GetUserValue("MSG_TYPE");
	if (msgType == "friendmem") or (msgType == "guildmem") then
		return true;
	elseif (msgType == "Normal") and g.CHATEXTENDS_GENERAL_FLG then
		return true;
	elseif (msgType == "Shout") and g.CHATEXTENDS_SHOUT_FLG then
		return true;
	elseif (msgType == "Party") and g.CHATEXTENDS_PARTY_FLG then
		return true;
	elseif (msgType == "Guild") and g.CHATEXTENDS_GUILD_FLG then
		return true;
	elseif (msgType == "Notice") or (msgType == "System") then
		-- システムメッセージならフラグによって全体表示のみかどうか判断
		if g.settings.SYSTEM_TOTAL_FLG then
			return false;
		else
			return true;
		end
	end
	-- msgTypeがどれでもない=ささやき
	-- 一応フラグ見る
	if g.CHATEXTENDS_WHISPER_FLG then
		return true;
	else
		return false;
	end
end

--************************************************
-- チャット設定
--************************************************
function CHATEXTENDS_GET_CHATEXTENDS_PROP(clusterinfo,cluster)
	-- チャットフレーム
	-- メインでもポップアップでもこのフレームの値を使うため、引数とかじゃなくてここで明示的に取得
	local chatframe = ui.GetFrame("chatframe");
	-- チャット表示方法（吹き出しか簡易か）
	local textVer = IS_TEXT_VER_CHAT();
	-- チャット発言者
	local commnderName = clusterinfo:GetCommanderName();
	-- メッセージタイプ
	local msgType = clusterinfo:GetMsgType();
	-- 戻り値
	local fontStyle = "";
	local msgFront = "";

	if textVer == 0 then
		if msgType == "System" then
			fontStyle = chatframe:GetUserConfig("BALLONCHAT_FONTSTYLE_SYSTEM");
		elseif (msgType == "friendmem") or (msgType == "guildmem") then
			fontStyle = chatframe:GetUserConfig("BALLONCHAT_FONTSTYLE_MEMBER");
		else
			fontStyle = chatframe:GetUserConfig("BALLONCHAT_FONTSTYLE");
		end
	else
		if msgType == "friendmem" then
			fontStyle = chatframe:GetUserConfig("TEXTCHAT_FONTSTYLE_SYSTEM");
			msgFront = "#86E57F";
		elseif msgType == "guildmem" then
			fontStyle = chatframe:GetUserConfig("TEXTCHAT_FONTSTYLE_SYSTEM");
			msgFront = "#A566FF";
		elseif msgType == "Normal" then
			fontStyle = CHAT_TEXT_IS_MINE_AND_SETFONT(chatframe, ui.IsMyChatCluster(clusterinfo), "TEXTCHAT_FONTSTYLE_NORMAL");
			msgFront = string.format("[%s]", commnderName);
		elseif msgType == "Shout" then
			fontStyle = CHAT_TEXT_IS_MINE_AND_SETFONT(chatframe, ui.IsMyChatCluster(clusterinfo), "TEXTCHAT_FONTSTYLE_SHOUT");
			msgFront = string.format("[%s][%s]", ScpArgMsg("ChatType_2"), commnderName);
		elseif msgType == "Party" then
			fontStyle = CHAT_TEXT_IS_MINE_AND_SETFONT(chatframe, ui.IsMyChatCluster(clusterinfo), "TEXTCHAT_FONTSTYLE_PARTY");
			msgFront = string.format("[%s][%s]", ScpArgMsg("ChatType_3"), commnderName);
		elseif msgType == "Guild" then
			fontStyle = CHAT_TEXT_IS_MINE_AND_SETFONT(chatframe, ui.IsMyChatCluster(clusterinfo), "TEXTCHAT_FONTSTYLE_GUILD");
			msgFront = string.format("[%s][%s]", ScpArgMsg("ChatType_4"), commnderName);
		elseif msgType == "Notice" then
			fontStyle = chatframe:GetUserConfig("TEXTCHAT_FONTSTYLE_NOTICE");
			msgFront = string.format("[%s]", ScpArgMsg("ChatType_6"));
		elseif msgType == "System" then
			fontStyle = chatframe:GetUserConfig("TEXTCHAT_FONTSTYLE_SYSTEM");
			msgFront = string.format("[%s]", ScpArgMsg("ChatType_7"));
		else
			fontStyle = CHAT_TEXT_IS_MINE_AND_SETFONT(chatframe, ui.IsMyChatCluster(clusterinfo), "TEXTCHAT_FONTSTYLE_WHISPER");
			msgFront = string.format("[%s][%s]", ScpArgMsg("ChatType_5"), commnderName);
		end
	end

	return fontStyle, msgFront;
end

--************************************************
-- クラスター取得
--************************************************
function CHATEXTENDS_GET_CLUSTER(chatframe,groupbox,clusterinfo,ypos)
	-- チャット表示方法（吹き出しか簡易か）
	local textVer = IS_TEXT_VER_CHAT();
	-- チャット発言内容フレーム名
	local clustername = "cluster_"..clusterinfo:GetClusterID();
	local cluster = nil;
	-- チャットマージン共通
	local marginLeft = 0;
	local marginRight = 25;

	-- 吹き出し表示なら同一時間の同一発言者のクラスター名が一致するので、あればそれ返す
	if textVer == 0 then
		cluster = GET_CHILD(groupbox, clustername);
		if cluster ~= nil then
			return cluster;
		end
	end

	local chatCtrlName = "chatTextVer";
	local horzGravity = ui.LEFT;
	if textVer == 0 then
		-- 自分の発言かどうか
		if true == ui.IsMyChatCluster(clusterinfo) then
			chatCtrlName = "chati";
			horzGravity = ui.RIGHT;
		else
			chatCtrlName = "chatu";
		end
	end
	cluster = groupbox:CreateOrGetControlSet(chatCtrlName, clustername, horzGravity, ui.TOP, marginLeft, ypos , marginRight, 0);
	cluster:EnableHitTest(1);
	-- メッセージによるフラグ設定
	CHATEXTENDS_SET_CLUSTER_FLG(clusterinfo,cluster);
	if textVer == 0 then
		CHATEXTENDS_SET_CLUSTER_INFRAME_BALLON(clusterinfo,cluster)
		-- 場所
		if cluster:GetHorzGravity() == ui.RIGHT then
			cluster:SetOffset( marginRight , cluster:GetY());
		else
			cluster:SetOffset( marginLeft , cluster:GetY()); 
		end

	else
		CHATEXTENDS_SET_CLUSTER_INFRAME_SIMPLE(chatframe,clusterinfo,cluster)
	end
	return cluster
end

--************************************************
-- クラスター内部のフレームのフラグ設定
-- 表示処理に使用
--************************************************
function CHATEXTENDS_SET_CLUSTER_FLG(clusterinfo,cluster)
	-- メッセージタイプ
	local msgType = clusterinfo:GetMsgType();
	cluster:SetUserValue("MSG_TYPE", msgType);
end

--************************************************
-- クラスター内部のフレーム設定　吹き出し
--************************************************
function CHATEXTENDS_SET_CLUSTER_INFRAME_BALLON(clusterinfo,cluster)
	-- メッセージタイプ
	local msgType = clusterinfo:GetMsgType();

	local label,txt = CHATEXTENDS_GET_LABEL_TXT(cluster);
	local myColor, targetColor = GET_CHAT_COLOR(msgType);
	if true == ui.IsMyChatCluster(clusterinfo) then
		label:SetSkinName('textballoon_i');
		label:SetColorTone(myColor);
	else
		local nameText = GET_CHILD(cluster, "name", "ui::CRichText");
		label:SetColorTone(targetColor);

		if msgType == "guildmem" or msgType == "friendmem" then
			cluster:RemoveChild("name");
		elseif msgType == 'System' then
			nameText:SetText('{img chat_system_icon 65 18 }{/}');
		else
			-- チャット発言者
			local commnderName = clusterinfo:GetCommanderName();
			cluster:SetEventScript(ui.RBUTTONDOWN, 'CHAT_RBTN_POPUP');
			cluster:SetUserValue("TARGET_NAME", commnderName);
			nameText:SetText('{@st61}'..commnderName..'{/}');
			nameText:SetEventScript(ui.RBUTTONDOWN, 'CHAT_RBTN_POPUP');
			nameText:SetUserValue("TARGET_NAME", commnderName);
		end
		local iconPicture = GET_CHILD(cluster, "iconPicture", "ui::CPicture");
		iconPicture:ShowWindow(0);
	end
	local timeBox = GET_CHILD(cluster, "timebox", "ui::CGroupBox");
	local timeCtrl = GET_CHILD(timeBox, "time", "ui::CRichText");
	timeCtrl:SetTextByKey("time", clusterinfo:GetTimeStr());

end

--************************************************
-- クラスター内部のフレーム設定　簡易
--************************************************
function CHATEXTENDS_SET_CLUSTER_INFRAME_SIMPLE(chatframe,clusterinfo,cluster)

	local label,txt = CHATEXTENDS_GET_LABEL_TXT(cluster);
	local timeCtrl = GET_CHILD(cluster, "time", "ui::CRichText");
	timeCtrl:SetTextByKey("time", clusterinfo:GetTimeStr());
	timeCtrl:SetOffset(10, 10);
	if true == ui.IsMyChatCluster(clusterinfo) then
		label:SetColorTone("FF000000");
		label:SetAlpha(60);
	else
		-- メッセージタイプ
		local msgType = clusterinfo:GetMsgType();
		if msgType == "System" then
			label:SetColorTone("FF000000");
			label:SetAlpha(80);
		else
			label:SetAlpha(0);
			if (msgType ~= "System") and (msgType ~= "friendmem") and (msgType ~= "guildmem") then
				-- チャット発言者
				local commnderName = clusterinfo:GetCommanderName();
				cluster:SetEventScript(ui.RBUTTONDOWN, 'CHAT_RBTN_POPUP');
				cluster:SetUserValue("TARGET_NAME", commnderName);
				txt:SetEventScript(ui.RBUTTONDOWN, 'CHAT_RBTN_POPUP');
				txt:SetUserValue("TARGET_NAME", commnderName);
			end
		end
	end
	-- テキストフィックスは文字入れる前にやる必要があるので、最初から調整しとく
	local offsetX = chatframe:GetUserConfig("CTRLSET_OFFSETX");
	local chatWidth = chatframe:GetWidth();
	txt:SetTextMaxWidth(chatWidth - (offsetX + 60));
end


--************************************************
-- クラスターのラベルオブジェクトとテキストオブジェクト取得
-- 吹き出しと簡易でテキストオブジェクトの取得元のフレームが異なる
--************************************************
function CHATEXTENDS_GET_LABEL_TXT(cluster)
	-- チャット表示方法（吹き出しか簡易か）
	local textVer = IS_TEXT_VER_CHAT();
	local label = nil;
	local txt = nil;
	if textVer == 0 then
		label = cluster:GetChild('bg');
		txt = GET_CHILD(label, "text", "ui::CRichText");
	else
		label = cluster:GetChild('bg');
		txt = GET_CHILD(cluster, "text", "ui::CRichText");
	end
	return label,txt
end

--************************************************
-- 新しいクラスターを作成するY座標を取得する
--************************************************
function CHATEXTENDS_GET_YPOS(groupboxname, groupbox, index)
	local ypos = 0;
	if index ~= 0 then
		local clusterinfo = session.ui.GetChatMsgClusterInfo(groupboxname, index-1)
		if clusterinfo ~= nil then
			local beforechildname = "cluster_"..clusterinfo:GetClusterID()
			local beforechild = GET_CHILD(groupbox, beforechildname);
			if beforechild ~= nil then
				ypos = beforechild:GetY() + beforechild:GetHeight();
			end
		end
	end

	return ypos;
end

--************************************************
-- 終了処理
--************************************************
function CHATEXTENDS_CHAT_AFTER(groupbox)
	local scrollend = false
	if groupbox:GetLineCount() == groupbox:GetCurLine() + groupbox:GetVisibleLineCount() then
		scrollend = true;
	end

	local beforeLineCount = groupbox:GetLineCount();
	groupbox:UpdateData();

	local afterLineCount = groupbox:GetLineCount();
	local changedLineCount = afterLineCount - beforeLineCount;
	local curLine = groupbox:GetCurLine();

	if (IS_BOTTOM_CHAT() == 1) or (scrollend == true) then
		groupbox:SetScrollPos(99999);
	else 
		groupbox:SetScrollPos(curLine + changedLineCount);
	end

	chat.UpdateAllReadFlag();
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

	-- ファイル名は YYYYMMDD_HHMISS_キャラ名.txt
	local logfile=string.format("savechat_%s%s%s_%s%s%s_%s.txt", year,month,day,hour,min,sec,GETMYPCNAME());

	-- ファイル書き込みモード
	file,err = io.open(g.saveChatDir.."/"..logfile, "w")
	local msgbody="";
	for i = 0 , cnt - 2 do
		clusterinfo = session.ui.GetChatMsgClusterInfo(groupboxname, i);
		for j = 1 , clusterinfo:GetMsgItemCount() do
			msgbody = clusterinfo:GetMsgItembyIndex(j-1);
			file:write(CHATEXTENDS_GET_MSGBODY(clusterinfo,msgbody));
		end
	end
	file:close();
	if option.GetCurrentCountry()=="Japanese" then
		ui.SysMsg("チャットを保存しました");
	else
		ui.SysMsg("SAVE CHAT");
	end
end

--************************************************
-- ディレクトリ作成
--************************************************
function CHATEXTENDS_CREATE_DIR(dirname)
	if option.GetCurrentCountry()=="Japanese" then
		local tempDirStr = string.gsub(dirname, "/", "\\");
		os.execute("mkdir "..tempDirStr)
	else
		os.execute("mkdir "..dirname);
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
	tempstr=string.match(logbody, "(@dicID.+\*\^)");
	if tempstr ~= nil then
		tempstr = dictionary.ReplaceDicIDInCompStr(tempstr);
		logbody=string.gsub(logbody,"(@dicID.+\*\^)", tempstr);
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
		else
			return "[ささやき　]";
		end
	else
		return "["..msgType.."]";
	end
end

--************************************************
-- 削除処理
--************************************************
function CHATEXTENDS_DELETE_CHAT()
	local groupboxname = "chatgbox_TOTAL";
	local chatframe = ui.GetFrame("chatframe");
	local groupbox = GET_CHILD(chatframe,groupboxname);
	local cnt = groupbox:GetChildCount();
	-- 対象フレーム内の、指定した名前で始まるフレームを全て削除
	DESTROY_CHILD_BYNAME(groupbox, "cluster_");
	g.CHATEXTENDS_BASE_INDEX = cnt - 2;
	-- メイン表示
	CHATEXTENDS_MAIN(groupboxname, cnt-1, 0, "chatframe");
end

--************************************************
-- 押されたボタンに対する表示
--************************************************
function CHATEXTENDS_DISPLAY_CHAT()
	local groupboxname = "chatgbox_TOTAL";
	local chatframe = ui.GetFrame("chatframe");
	local groupbox = GET_CHILD(chatframe,groupboxname);
	local cnt = groupbox:GetChildCount();
	-- 対象フレーム内の、指定した名前で始まるフレームを全て削除
	DESTROY_CHILD_BYNAME(groupbox, "cluster_");
	-- メイン表示
	CHATEXTENDS_MAIN(groupboxname, cnt-1, 0, "chatframe");
end

--************************************************
-- 全体ボタン押下
--************************************************
function CHATEXTENDS_CHAT_TOTAL_ON_BTN_UP()
	g.CHATEXTENDS_TOTAL_FLG=true;
	g.CHATEXTENDS_GENERAL_FLG=false;
	g.CHATEXTENDS_SHOUT_FLG=false;
	g.CHATEXTENDS_PARTY_FLG=false;
	g.CHATEXTENDS_GUILD_FLG=false;
	g.CHATEXTENDS_WHISPER_FLG=false;
	ui.SetChatGroupBox(CT_TOTAL);
	CHATEXTENDS_DISPLAY_CHAT();
end

--************************************************
-- 一般ボタン押下
--************************************************
function CHATEXTENDS_CHAT_GENERAL_ON_BTN_UP()
	g.CHATEXTENDS_TOTAL_FLG=false;
	g.CHATEXTENDS_WHISPER_FLG=false;
	if g.CHATEXTENDS_GENERAL_FLG and (g.CHATEXTENDS_SHOUT_FLG or g.CHATEXTENDS_PARTY_FLG or g.CHATEXTENDS_GUILD_FLG) then
		g.CHATEXTENDS_GENERAL_FLG=false;
	else
		g.CHATEXTENDS_GENERAL_FLG=true;
	end
	ui.SetChatGroupBox(CT_TOTAL);
	CHATEXTENDS_DISPLAY_CHAT();
end

--************************************************
-- シャウトボタン押下
--************************************************
function CHATEXTENDS_CHAT_SHOUT_ON_BTN_UP()
	g.CHATEXTENDS_TOTAL_FLG=false;
	g.CHATEXTENDS_WHISPER_FLG=false;
	if g.CHATEXTENDS_SHOUT_FLG and (g.CHATEXTENDS_GENERAL_FLG or g.CHATEXTENDS_PARTY_FLG or g.CHATEXTENDS_GUILD_FLG) then
		g.CHATEXTENDS_SHOUT_FLG=false;
	else
		g.CHATEXTENDS_SHOUT_FLG=true;
	end
	ui.SetChatGroupBox(CT_TOTAL);
	CHATEXTENDS_DISPLAY_CHAT();
end

--************************************************
-- パーティーボタン押下
--************************************************
function CHATEXTENDS_CHAT_PARTY_ON_BTN_UP()
	g.CHATEXTENDS_TOTAL_FLG=false;
	g.CHATEXTENDS_WHISPER_FLG=false;
	if g.CHATEXTENDS_PARTY_FLG and (g.CHATEXTENDS_GENERAL_FLG or g.CHATEXTENDS_SHOUT_FLG or g.CHATEXTENDS_GUILD_FLG) then
		g.CHATEXTENDS_PARTY_FLG=false;
	else
		g.CHATEXTENDS_PARTY_FLG=true;
	end
	ui.SetChatGroupBox(CT_TOTAL);
	CHATEXTENDS_DISPLAY_CHAT();
end

--************************************************
-- ギルドボタン押下
--************************************************
function CHATEXTENDS_CHAT_GUILD_ON_BTN_UP()
	g.CHATEXTENDS_TOTAL_FLG=false;
	g.CHATEXTENDS_WHISPER_FLG=false;
	if g.CHATEXTENDS_GUILD_FLG and (g.CHATEXTENDS_GENERAL_FLG or g.CHATEXTENDS_SHOUT_FLG or g.CHATEXTENDS_PARTY_FLG) then
		g.CHATEXTENDS_GUILD_FLG=false;
	else
		g.CHATEXTENDS_GUILD_FLG=true;
	end
	ui.SetChatGroupBox(CT_TOTAL);
	CHATEXTENDS_DISPLAY_CHAT();
end

--************************************************
-- ささやきボタン押下
--************************************************
function CHATEXTENDS_CHAT_WHISPER_ON_BTN_UP()
	g.CHATEXTENDS_TOTAL_FLG=false;
	g.CHATEXTENDS_GENERAL_FLG=false;
	g.CHATEXTENDS_SHOUT_FLG=false;
	g.CHATEXTENDS_PARTY_FLG=false;
	g.CHATEXTENDS_GUILD_FLG=false;
	g.CHATEXTENDS_WHISPER_FLG=true;
	ui.SetChatGroupBox(CT_WHISPER);
end

--************************************************
-- チャットフレームのボタンの表示
--************************************************
function CHATEXTENDS_CHAT_FRAME_NOW_BTN_SKN()

	local frame = ui.GetFrame('chatframe')

	local btn_total = GET_CHILD_RECURSIVELY(frame,'btn_total')
	local btn_general = GET_CHILD_RECURSIVELY(frame,'btn_general')
	local btn_shout = GET_CHILD_RECURSIVELY(frame,'btn_shout')
	local btn_party = GET_CHILD_RECURSIVELY(frame,'btn_party')
	local btn_guild = GET_CHILD_RECURSIVELY(frame,'btn_guild')
	local btn_whisper = GET_CHILD_RECURSIVELY(frame,'btn_whisper')

	local btn_total_pic = GET_CHILD_RECURSIVELY(frame,'btn_total_pic')
	local btn_general_pic = GET_CHILD_RECURSIVELY(frame,'btn_general_pic')
	local btn_shout_pic = GET_CHILD_RECURSIVELY(frame,'btn_shout_pic')
	local btn_party_pic = GET_CHILD_RECURSIVELY(frame,'btn_party_pic')
	local btn_guild_pic = GET_CHILD_RECURSIVELY(frame,'btn_guild_pic')
	local btn_whisper_pic = GET_CHILD_RECURSIVELY(frame,'btn_whisper_pic')

	btn_total_pic:ShowWindow(0)
	btn_general_pic:ShowWindow(0)
	btn_shout_pic:ShowWindow(0)
	btn_party_pic:ShowWindow(0)
	btn_guild_pic:ShowWindow(0)
	btn_whisper_pic:ShowWindow(0)

	btn_total:ShowWindow(1)
	btn_general:ShowWindow(1)
	btn_shout:ShowWindow(1)
	btn_party:ShowWindow(1)
	btn_guild:ShowWindow(1)
	btn_whisper:ShowWindow(1)

	if g.CHATEXTENDS_TOTAL_FLG then
		btn_total_pic:ShowWindow(1)
		btn_total:ShowWindow(0)
	end
	if g.CHATEXTENDS_GENERAL_FLG then
		btn_general_pic:ShowWindow(1)
		btn_general:ShowWindow(0)
	end
	if g.CHATEXTENDS_SHOUT_FLG then
		btn_shout_pic:ShowWindow(1)
		btn_shout:ShowWindow(0)
	end
	if g.CHATEXTENDS_PARTY_FLG then
		btn_party_pic:ShowWindow(1)
		btn_party:ShowWindow(0)
	end
	if g.CHATEXTENDS_GUILD_FLG then
		btn_guild_pic:ShowWindow(1)
		btn_guild:ShowWindow(0)
	end
	if g.CHATEXTENDS_WHISPER_FLG then
		btn_whisper_pic:ShowWindow(1)
		btn_whisper:ShowWindow(0)
	end
	frame:Invalidate()
end

--************************************************
-- チャットフレームのタイトル設定
--************************************************
function CHATEXTENDS_CHAT_SET_FROM_TITLENAME(targetName, roomid)

	local chatFrame = ui.GetFrame('chatframe');
	
	local titleText = "";

	-- 通常チャット
	if targetName ~= "" and targetName ~= nil then
		if g.CHATEXTENDS_TOTAL_FLG then
			-- 全体
			titleText = dictionary.ReplaceDicIDInCompStr("@dicID_^*$ETC_20150317_002652$*^")
		else
			if g.CHATEXTENDS_GENERAL_FLG then
				-- 一般
				titleText = titleText..dictionary.ReplaceDicIDInCompStr("@dicID_^*$ETC_20150317_004718$*^")..","
			end
			if g.CHATEXTENDS_SHOUT_FLG then
				-- シャウト
				titleText = titleText..dictionary.ReplaceDicIDInCompStr("@dicID_^*$ETC_20150317_002664$*^")..","
			end
			if g.CHATEXTENDS_PARTY_FLG then
				-- パーティー
				titleText = titleText..dictionary.ReplaceDicIDInCompStr("@dicID_^*$ETC_20150317_004719$*^")..","
			end
			if g.CHATEXTENDS_GUILD_FLG then
				-- ギルド
				titleText = titleText..dictionary.ReplaceDicIDInCompStr("@dicID_^*$ETC_20151223_019203$*^")..","
			end
		end

	-- ささやき
	elseif roomid ~= "" and roomid ~= nil then

		local info = session.chat.GetByStringID(roomid);
		local memberString = GET_GROUP_TITLE(info);
		titleText = 'From. '..memberString;

	end

	local name = chatFrame:GetChild("group_titlebar"):GetChild("name");
	name:SetTextByKey("title", titleText);

	-- ささやきポップアップ
	local popupframename = "chatpopup_" .. roomid;
	local popupframe = ui.GetFrame(popupframename);
	if popupframe ~= nil and popupframe:IsVisible() == 1 then
		local popupname = GET_CHILD_RECURSIVELY(popupframe,"name");
		popupname:SetTextByKey("title", titleText);
	end
end
