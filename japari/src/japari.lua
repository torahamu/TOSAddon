--******************************************
-- ようこそジャパリパークへ
--******************************************

--アドオン名（大文字）
local addonName = "JAPARI";
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

-- オートフラグ
g.JAPARI_SABAL_FLG=false;
g.JAPARI_TOS_FLG=false;
g.JAPARI_SABAL_COUNT=0;
g.JAPARI_TOS_COUNT=0;

-- 読み込みフラグ
g.loaded=false

--lua読み込み時のメッセージ
CHAT_SYSTEM("ようこそジャパリパークへ");

--マップ読み込み時処理（1度だけ）
function JAPARI_ON_INIT(addon, frame)
	-- 初期設定項目は1度だけ行う
	if g.loaded==false then
		g.addon = addon;
		g.frame = frame;

		--コマンド登録
		acutil.slashCommand("/japari", JAPARI_COMMAND);
		acutil.slashCommand("/tos", TOS_COMMAND);

		g.loaded = true;
		addon:RegisterMsg('FPS_UPDATE', 'JAPARI_AUTO');
		addon:RegisterMsg('FPS_UPDATE', 'TOS_AUTO');
	end

end

function JAPARI_AUTO()
	if g.JAPARI_SABAL_FLG then
		g.JAPARI_SABAL_COUNT = g.JAPARI_SABAL_COUNT + 1;
		if g.JAPARI_SABAL_COUNT == 3 then
			g.JAPARI_SABAL_COUNT = 0;
			JAPARI();
		end
	end
end

function TOS_AUTO()
	if g.JAPARI_TOS_FLG then
		g.JAPARI_TOS_COUNT = g.JAPARI_TOS_COUNT + 1;
		if g.JAPARI_TOS_COUNT == 3 then
			g.JAPARI_TOS_COUNT = 0;
			TOS_SAIKO();
		end
	end
end


function JAPARI_COMMAND(command)
    if #command > 0 then
        cmd = table.remove(command, 1);
    else
		JAPARI();
	end
	if cmd == "auto" then
		if g.JAPARI_SABAL_FLG then
			g.JAPARI_SABAL_FLG=false;
			NICO_CHAT("{@st64}黙ってるよ！")
		else
			g.JAPARI_SABAL_FLG=true;
			NICO_CHAT("{@st64}どんどん喋っちゃうよ！")
		end
	else
		local tmp = tonumber(cmd);
		if tmp ~= nil then
			for i = 0 , tmp do
				JAPARI();
			end
		end
	end
end

function TOS_COMMAND(command)
    if #command > 0 then
        cmd = table.remove(command, 1);
    else
		TOS_SAIKO();
	end
	if cmd == "auto" then
		if g.JAPARI_TOS_FLG then
			g.JAPARI_TOS_FLG=false;
			NICO_CHAT("{@st55_a}TOS褒めるのやめます")
		else
			g.JAPARI_TOS_FLG=true;
			NICO_CHAT("{@st55_a}TOSをどんどん褒めます")
		end
	else
		local tmp = tonumber(cmd);
		if tmp ~= nil then
			for i = 0 , tmp do
				TOS_SAIKO()
			end
		end
	end
end

function JAPARI()
	SWITCH(IMCRandom(1, 7)) {
		[1] = function() NICO_CHAT("{@st64}わーい！") end,
		[2] = function() NICO_CHAT("{@st64}すっごーい！") end,
		[3] = function() NICO_CHAT("{@st64}たーのしー！") end,
		[4] = function() NICO_CHAT("{@st64}君は"..GETMYPCNAME().."って名前のフレンズなんだね！") end,
		[5] = function() NICO_CHAT("{@st64}すごいすごーい！！") end,
		[6] = function() NICO_CHAT("{@st64}なにこれー！") end,
		default = function() NICO_CHAT("{@st64}うぅーい！") end,
	}
end

function TOS_SAIKO()
	SWITCH(IMCRandom(1, 3)) {
		[1] = function() NICO_CHAT("{@st55_a}Tree of Savior最高！") end,
		[2] = function() NICO_CHAT("{@st55_a}ありがとうIMCGames！") end,
		default = function() NICO_CHAT("{@st55_a}Nexon大好き！") end,
	}
end
