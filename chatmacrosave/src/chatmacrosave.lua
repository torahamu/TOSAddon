--アドオン名（大文字）
local addonName = "CHATMACROSAVE";
local addonNameLower = string.lower(addonName);
--作者名
local author = "torahamu";

--アドオン内で使用する領域を作成。以下、ファイル内のスコープではグローバル変数gでアクセス可
_G["ADDONS"] = _G["ADDONS"] or {};
_G["ADDONS"][author] = _G["ADDONS"][author] or {};
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {};
local g = _G["ADDONS"][author][addonName];
g.settings = {}
g.settings.poseID = {}
g.settings.text = {}
g.settings.load = false

--設定ファイル保存先
g.settingsDirLoc = string.format("../addons/%s", addonNameLower);
g.settingsFileLoc = string.format("%s/settings.json", g.settingsDirLoc);

local acutil = require('acutil');
local readFlg = false

function CHATMACROSAVE_ON_INIT(addon, frame)
	if nil == CHATMACROSAVE_SAVE_CHAT_MACRO_OLD then
		CHATMACROSAVE_SAVE_CHAT_MACRO_OLD = SAVE_CHAT_MACRO;
		SAVE_CHAT_MACRO = CHATMACROSAVE_SAVE_CHAT_MACRO;
	end
	if nil == CHATMACROSAVE_APPS_TRY_LEAVE_OLD then
		CHATMACROSAVE_APPS_TRY_LEAVE_OLD = APPS_TRY_LEAVE;
		APPS_TRY_LEAVE = CHATMACROSAVE_APPS_TRY_LEAVE;
	end

	if readFlg then
	else
		local t, err = acutil.loadJSON(g.settingsFileLoc, g.settings);
		-- 読み込めない = ファイルがない
		if err then
		else
			-- 読み込めたら読み込んだ値使う
			g.settings = t;
			g.settings.load = true;
			CHATMACROSAVE_LOAD()
		end
		readFlg = true;
	end
end

function CHATMACROSAVE_SAVE_CHAT_MACRO(macroGbox, isclose)
	-- とりあえず定型文保存
	CHATMACROSAVE_SAVE_CHAT_MACRO_OLD(macroGbox, isclose)
	if g.settings.load then
		-- 設定ファイルとかあるなら共通セーブにもセーブ
		CHATMACROSAVE_SAVE()
	else
		-- 初回時は確認する
		local yesscp = "CHATMACROSAVE_SAVE()";
		local country=string.lower(option.GetCurrentCountry());
		local msg = ""
		if country=="japanese" then
			msg = "この定型文の設定を全キャラクターで統一しますか？{nl}今後はどのキャラクターで定型文を変更しても全キャラクター変更されます。"
		else
			msg = "Would you like to unify this macro with all the characters?{nl}All characters will be changed in any future character even if you change the macro."
		end
		ui.MsgBox(msg, yesscp, "None")
	end
end

function CHATMACROSAVE_SAVE()
	local frame = ui.GetFrame("chatmacro");
	local macroGbox = frame:GetChild('macroGroupbox');
	local ctrl = macroGbox:GetChild("CHAT_MACRO_1");
	-- frame内のコントロールがnilなら、セッション情報から取得してセーブ
	if nil == ctrl then
		CHATMACROSAVE_SAVE_FOR_SESSION()
	else
		CHATMACROSAVE_SAVE_FOR_FRAME()
	end
	g.settings.load = true
	acutil.saveJSON(g.settingsFileLoc, g.settings);
end

function CHATMACROSAVE_SAVE_FOR_FRAME()
	local frame = ui.GetFrame("chatmacro");
	local macroGbox = frame:GetChild('macroGroupbox');
	for i = 1 , MAX_MACRO_CNT do
		local ctrl = macroGbox:GetChild("CHAT_MACRO_" .. i);
		local text = ctrl:GetText();
		local slot = macroGbox:GetChild("CHAT_MACRO_SLOT_" .. i);
		local poseID = tonumber( slot:GetUserValue('POSEID') );
		g.settings.poseID[i]=poseID;
		g.settings.text[i]=text;
	end
end

function CHATMACROSAVE_SAVE_FOR_SESSION()

	local frame = ui.GetFrame("chatmacro");
	local macroGbox = frame:GetChild('macroGroupbox');
	local clslist = GetClassList("Pose");
	local list = session.GetChatMacroList();
	local cnt = list:Count();
	
	for i = 0 , cnt - 1 do
		local info = list:PtrAt(i);
		local text = tostring(info.macro);
		local poseID = tonumber( info.poseID );
		g.settings.poseID[i+1]=poseID;
		g.settings.text[i+1]=text;
	end
end

function CHATMACROSAVE_LOAD()
	local frame = ui.GetFrame("chatmacro");
	-- フレーム作ってもらわないと困るので
	UPDATE_CHAT_MACRO(frame)
	local macroGbox = frame:GetChild('macroGroupbox');
	local clslist = GetClassList("Pose");
	for i = 1 , MAX_MACRO_CNT do
		local poseID = g.settings.poseID[i];
		local text = g.settings.text[i];
		local ctrl = macroGbox:GetChild("CHAT_MACRO_" .. i);
		ctrl:SetText(text);
		ctrl:ShowWindow(1);
		local slot = macroGbox:GetChild("CHAT_MACRO_SLOT_" .. i);
		tolua.cast(slot, "ui::CSlot");
		slot:SetUserValue("POSEID", poseID)
		local cls = GetClassByTypeFromList(clslist, poseID);
		if cls ~= nil then			
			local icon = slot:GetIcon();
			icon:SetImage(cls.Icon);
			icon:SetColorTone("FFFFFFFF");
		end
		-- 読み込んだ値をサーバに送信しないとマクロ設定出来ない
		packet.ReqSaveChatMacro(i, poseID, text);
	end
end

function CHATMACROSAVE_APPS_TRY_LEAVE(type)
	-- キャラやログアウトなど、今のキャラから変更する時にフラグオフ
	readFlg = false
	CHATMACROSAVE_APPS_TRY_LEAVE_OLD(type)
end
