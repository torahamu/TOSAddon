--アドオン名（大文字）
local addonName = "JOBCHANGECOMMAND";
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

--lua読み込み時のメッセージ
CHAT_SYSTEM("JOB CHANGE COMMAND LOADED");

--マップ読み込み時処理（1度だけ）
function JOBCHANGECOMMAND_ON_INIT(addon, frame)
	-- 初期設定項目は1度だけ行う
	if g.loaded==false then
		g.addon = addon;
		g.frame = frame;

		--コマンド登録
		acutil.slashCommand("/job", JOB_OPEN);

		g.loaded = true;
	end

end

function JOB_OPEN()
	ui.OpenFrame("changejob");
end
