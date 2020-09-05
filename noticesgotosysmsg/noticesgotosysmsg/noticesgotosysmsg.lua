--アドオン名（大文字）
local addonName = "NOTICESGOTOSYSMSG";
local addonNameLower = string.lower(addonName);
--作者名
local author = "torahamu";

--アドオン内で使用する領域を作成。以下、ファイル内のスコープではグローバル変数gでアクセス可
_G["ADDONS"] = _G["ADDONS"] or {};
_G["ADDONS"][author] = _G["ADDONS"][author] or {};
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {};
local g = _G["ADDONS"][author][addonName];
g.settingsDirLoc = string.format("../addons/%s", addonNameLower);
g.settingsFileLoc = string.format("%s/settings.json", g.settingsDirLoc);

--ライブラリ読み込み
local acutil = require('acutil');

if not g.loaded then
	g.settings = {
		mode=0;
	};
	g.langText = {
		["jp"] = {
			label = {
				title   = "通知設定",
				body    = "指定した通知内容を{nl}システムメッセージに表示します",
				default = "デフォルト",
				gacha   = "ガチャ系とバイボラ",
				all     = "全ての通知"
			},
			message = {
				initwarning = "fucking global shoutと競合するので動作を停止します"
			}
		},
		["en"] = {
			label = {
				title   = "Notice",
				body    = "display selected notifications{nl}in system messages",
				default = "default",
				gacha   = "Gacha and Vibora",
				all     = "All Notice"
			},
			message = {
				initwarning = "Stops working as it conflicts with fucking global shout."
			}
		}
	}
end

function g.NOTICESGOTOSYSMSG_SAVE_JSON()
	acutil.saveJSON(g.settingsFileLoc, g.settings);
end

--マップ読み込み時処理（1度だけ）
function NOTICESGOTOSYSMSG_ON_INIT(addon, frame)
	if nil ~= FKGLOBALSHOUT_ON_MSG then
		local langText = g.GET_LANG_MESSAGE();
		CHAT_SYSTEM(langText.message.initwarning);
		return;
	end

	if not g.loaded then
		g.addon = addon;
		g.frame = frame;

		--hook
		acutil.setupHook(NOTICESGOTOSYSMSG_ON_MSG, 'NOTICE_ON_MSG')

		local t, err = acutil.loadJSON(g.settingsFileLoc, g.settings);
		-- 読み込めない = ファイルがない
		if err then
			-- ファイル作る
			g.NOTICESGOTOSYSMSG_SAVE_JSON();
		else
			-- 読み込めたら読み込んだ値使う
			g.settings = t;
			g.NOTICESGOTOSYSMSG_SAVE_JSON();
		end
		g.NOTICESGOTOSYSMSG_FRAME_CREATE();

		g.loaded = true;
	end

end

-- Notice Hook
function NOTICESGOTOSYSMSG_ON_MSG(frame, msg, argStr, argNum)
	if g.settings.mode == 0 then
		g.NOTICESGOTOSYSMSG_MODE_0(frame, msg, argStr, argNum)
	elseif g.settings.mode == 1 then
		g.NOTICESGOTOSYSMSG_MODE_1(frame, msg, argStr, argNum)
	elseif g.settings.mode == 2 then
		g.NOTICESGOTOSYSMSG_MODE_2(frame, msg, argStr, argNum)
	else
		-- default
		NOTICE_ON_MSG_OLD(frame, msg, argStr, argNum)
	end
end

-- Default
function g.NOTICESGOTOSYSMSG_MODE_0(frame, msg, argStr, argNum)
	NOTICE_ON_MSG_OLD(frame, msg, argStr, argNum)
end

-- Gacha Notice is SystemMsg
function g.NOTICESGOTOSYSMSG_MODE_1(frame, msg, argStr, argNum)
	if string.find(argStr, "GACHA") ~= nil then
		CHAT_SYSTEM(argStr)
	else
		NOTICE_ON_MSG_OLD(frame, msg, argStr, argNum)
	end
end

-- All Notice is SystemMsg
function g.NOTICESGOTOSYSMSG_MODE_2(frame, msg, argStr, argNum)
	CHAT_SYSTEM(argStr)
end

function g.GET_LANG_MESSAGE()
	if option.GetCurrentCountry()=="Japanese" then
		return g.langText.jp
	else
		return g.langText.en
	end
end

-- Create Frame in systemoption.
function g.NOTICESGOTOSYSMSG_FRAME_CREATE()
	local frame = ui.GetFrame("systemoption");
	local groupbox = GET_CHILD_RECURSIVELY(frame, "gameBox");
	local langText = g.GET_LANG_MESSAGE();
	
	local header = groupbox:CreateOrGetControl("richtext", "NoticeTitle", 270, 290, 200, 24);
	tolua.cast(header, "ui::CRichText");
	header:SetFontName("white_16_ol");
	header:SetText("{@st43}" .. langText.label.title .. "{/}");
	
	local body = groupbox:CreateOrGetControl("richtext", "NoticeBody", 280, 330, 200, 24);
	tolua.cast(body, "ui::CRichText");
	body:SetFontName("white_16_ol");
	body:SetText("{@st43}{s14}" .. langText.label.body .. "{/}");

	local defaultNotice = groupbox:CreateOrGetControl('radiobutton', 'Notice_0', 280, 370, 200, 24);
	tolua.cast(defaultNotice, "ui::CRadioButton");
	defaultNotice:SetFontName("brown_16_b")
	defaultNotice:SetText(langText.label.default)
	defaultNotice:SetGroupID("notice");
	local gachaNotice = groupbox:CreateOrGetControl('radiobutton', 'Notice_1', 280, 400, 200, 24);
	tolua.cast(gachaNotice, "ui::CRadioButton");
	gachaNotice:SetFontName("brown_16_b")
	gachaNotice:SetText(langText.label.gacha)
	gachaNotice:AddToGroup(defaultNotice);
	local allNotice = groupbox:CreateOrGetControl('radiobutton', 'Notice_2', 280, 430, 200, 24);
	tolua.cast(allNotice, "ui::CRadioButton");
	allNotice:SetFontName("brown_16_b")
	allNotice:SetText(langText.label.all)
	allNotice:AddToGroup(defaultNotice);
	allNotice:AddToGroup(gachaNotice);

	if g.settings.mode == 0 then
		defaultNotice:Select();
	elseif g.settings.mode == 1 then
		gachaNotice:Select();
	elseif g.settings.mode == 2 then
		allNotice:Select();
	end
	defaultNotice:SetEventScript(ui.LBUTTONUP, "NOTICESGOTOSYSMSG_SET");
	gachaNotice:SetEventScript(ui.LBUTTONUP, "NOTICESGOTOSYSMSG_SET");
	allNotice:SetEventScript(ui.LBUTTONUP, "NOTICESGOTOSYSMSG_SET");
end

-- Radio Button Event
function NOTICESGOTOSYSMSG_SET(frame, ctrl, argStr, argNum)
	g.settings.mode = GET_RADIOBTN_NUMBER(ctrl)
	g.NOTICESGOTOSYSMSG_SAVE_JSON();
end
