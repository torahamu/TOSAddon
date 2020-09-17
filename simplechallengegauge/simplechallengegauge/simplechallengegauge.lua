--アドオン名（大文字）
local addonName = "SIMPLECHALLENGEGAUGE";
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

g.settings = {
	--X座標、Y座標
	xPos = 0,
	yPos = 0,
};
g.langText = {
	["jp"] = {
		label = {
			title      = "チャレンジ Lv%d",
			kill_count = "%s / %s  %s%%",
			rest_count = "残り%s体",
		}
	},
	["en"] = {
		label = {
			title      = "Challenge Lv%d",
			kill_count = "%s / %s  %s%%",
			rest_count = "%s Enemy left",
		}
	}
}

function g.SAVE_JSON()
	acutil.saveJSON(g.settingsFileLoc, g.settings);
end

--マップ読み込み時処理（1度だけ）
function SIMPLECHALLENGEGAUGE_ON_INIT(addon, frame)
	g.addon = addon;
	g.frame = frame;
	frame:SetEventScript(ui.LBUTTONUP, "SIMPLECHALLENGEGAUGE_END_DRAG");

	--hook
	acutil.setupHook(SIMPLECHALLENGEGAUGE_CHALLENGE_MODE_TOTAL_KILL_COUNT, 'ON_CHALLENGE_MODE_TOTAL_KILL_COUNT')

	local t, err = acutil.loadJSON(g.settingsFileLoc, g.settings);
	-- 読み込めない = ファイルがない
	if err then
		-- ファイル作る
		g.SAVE_JSON();
	else
		-- 読み込めたら読み込んだ値使う
		g.settings = t;
		g.SAVE_JSON();
	end

end

function g.GET_LANG_MESSAGE()
	if option.GetCurrentCountry()=="Japanese" then
		return g.langText.jp
	else
		return g.langText.en
	end
end

function g.JPTitle(langText)
	if option.GetCurrentCountry()~="Japanese" then
		return langText.label.title
	end
	return math.random(5) > 4 and "茶練痔猛怒 Lv%d" or langText.label.title
end

function SIMPLECHALLENGEGAUGE_END_DRAG(addon, frame)
	g.settings.xPos = g.frame:GetX();
	g.settings.yPos = g.frame:GetY();
	g.SAVE_JSON();
end

-- Notice Hook
function SIMPLECHALLENGEGAUGE_CHALLENGE_MODE_TOTAL_KILL_COUNT(frame, msg, str, arg)
	local msgList = StringSplit(str, '#');
	if #msgList < 1 then
		return;
	end

	frame=ui.GetFrame("simplechallengegauge");
	local gbox = GET_CHILD_RECURSIVELY(frame, "simplegbox");
	local title = GET_CHILD_RECURSIVELY(gbox, "title");
	local kill_gauge = GET_CHILD_RECURSIVELY(gbox, "kill_gauge");
	local kill_count = GET_CHILD_RECURSIVELY(gbox, "kill_count");
	local rest_count = GET_CHILD_RECURSIVELY(gbox, "rest_count");
	local challenge_timer = GET_CHILD_RECURSIVELY(gbox, "challenge_timer");
	local langText = g.GET_LANG_MESSAGE();

	if msgList[1] == "SHOW" then
		frame:ShowWindow(1);
		frame:SetOffset(g.settings.xPos, g.settings.yPos);

		title:SetText(string.format(g.JPTitle(langText),1));
		kill_count:SetText(string.format(langText.label.kill_count,0,0,0));
		rest_count:SetText(string.format(langText.label.rest_count,0));
		challenge_timer:SetTextByKey('time', "00:00");
		kill_gauge:SetMaxPointWithTime(0, 1, 0.1, 0.5);

	elseif msgList[1] == "HIDE" then
		frame:ShowWindow(0);
		
	elseif msgList[1] == "GAUGERESET" then
		frame:ShowWindow(1);

		local level = tonumber(msgList[2]);

		title:SetText(string.format(g.JPTitle(langText),level));
		kill_count:SetText(string.format(langText.label.kill_count,0,0,0));
		rest_count:SetText(string.format(langText.label.rest_count,0));
		kill_gauge:SetMaxPointWithTime(0, 1, 0.1, 0.5);

		challenge_timer:SetTextByKey('time', "00:00");
		challenge_timer:StopUpdateScript("SIMPLECHALLENGEGAUGE_CHALLENGE_MODE_TIMER");

	elseif msgList[1] == "START_CHALLENGE_TIMER" then
		frame:ShowWindow(1);

		challenge_timer:StopUpdateScript("SIMPLECHALLENGEGAUGE_CHALLENGE_MODE_TIMER");
		challenge_timer:RunUpdateScript("SIMPLECHALLENGEGAUGE_CHALLENGE_MODE_TIMER");

		challenge_timer:SetUserValue("CHALLENGE_MODE_START_TIME", tostring(imcTime.GetAppTimeMS()));
		challenge_timer:SetUserValue("CHALLENGE_MODE_LIMIT_TIME", msgList[2]);

	elseif msgList[1] == "REFRESH" then
		frame:ShowWindow(1);

		local killCount = tonumber(msgList[2]);
		local targetKillCount = tonumber(msgList[3]);
		local restCount = targetKillCount - killCount;
		local percent = math.floor(killCount / targetKillCount * 100);
		if percent > 100 then
			percent = 100;
		end

		local progressGauge = GET_CHILD(frame, "challenge_gauge_lv", "ui::CGauge");

		kill_gauge:SetMaxPointWithTime(killCount, targetKillCount, 0.1, 0.5);
		kill_gauge:ShowWindow(1);
		kill_count:SetText(string.format(langText.label.kill_count,g.LeftPadding(killCount, 4),g.LeftPadding(targetKillCount, 4),g.LeftPadding(percent, 4)));
		rest_count:SetText(string.format(langText.label.rest_count,g.LeftPadding(restCount, 4)));

	elseif msgList[1] == "MONKILLMAX" then
		frame:ShowWindow(1);
	end
end

function g.LeftPadding(arg, padCount)
	local str = tostring(arg)
	if #str > padCount then
		return str
	end
	local space = "";
	for i = 1, padCount do
		space = space.." ";
	end
	return string.sub(space..tostring(str), -padCount)
end

function SIMPLECHALLENGEGAUGE_CHALLENGE_MODE_TIMER(textTimer)
	local startTime = textTimer:GetUserValue("CHALLENGE_MODE_START_TIME");
	if startTime == nil then
		return 0;
	end

	local limitTime = textTimer:GetUserValue("CHALLENGE_MODE_LIMIT_TIME");
	if limitTime == nil then
		return 0;
	end

	limitTime = limitTime / 1000;

	local nowTime = imcTime.GetAppTimeMS();

	local diffTime = (nowTime - startTime) / 1000;
	local remainTime = tonumber(limitTime) - diffTime;
	if remainTime < 0 then
		textTimer:SetTextByKey('time', "00:00");
		return 0;
	end

	local remainMin = math.floor(remainTime / 60);
	local remainSec = remainTime % 60;
	local remainTimeStr = string.format('%d:%02d', remainMin, remainSec);
	textTimer:SetTextByKey('time', remainTimeStr);
	return 1;
end
