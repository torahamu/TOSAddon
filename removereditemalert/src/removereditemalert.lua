--アドオン名（大文字）
local addonName = "REMOVEREDITEMALERT";
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

-- 読み込みフラグ
g.loaded=false

--マップ読み込み時処理（1度だけ）
function REMOVEREDITEMALERT_ON_INIT(addon, frame)
	-- 初期設定項目は1度だけ行う
	if g.loaded==false then
		g.addon = addon;
		g.frame = frame;

		-- 元関数封印
		if nil == REMOVEREDITEMALERT_EXPIREDITEM_ALERT_OPEN_OLD then
			REMOVEREDITEMALERT_EXPIREDITEM_ALERT_OPEN_OLD = EXPIREDITEM_ALERT_OPEN;
			EXPIREDITEM_ALERT_OPEN = REMOVEREDITEMALERT_EXPIREDITEM_ALERT_OPEN;
		end

		g.loaded = true;
	end

end

function REMOVEREDITEMALERT_EXPIREDITEM_ALERT_OPEN(frame, argStr)
	frame:SetUserValue("TimerType", argStr);
    local timerType = argStr;
    local gameexitpopup = ui.GetFrame('gameexitpopup');
    if timerType ~= "None" then
        gameexitpopup:SetUserValue('EXIT_TYPE', timerType);
    end
    ON_GAMEEXIT_TIMER_END(gameexitpopup);
end
