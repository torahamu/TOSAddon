--アドオン名（大文字）
local addonName = "BUGFIX_MATTING";
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

--マップ読み込み時処理（1度だけ）
function BUGFIX_MATTING_ON_INIT(addon, frame)
	-- 初期設定項目は1度だけ行う
	if g.loaded==false then
		g.addon = addon;
		g.frame = frame;

		--フック
		_G["INDUNENTER_MAKE_PARTY_CONTROLSET_OLD"] = INDUNENTER_MAKE_PARTY_CONTROLSET;
		_G["INDUNENTER_MAKE_PARTY_CONTROLSET"] = INDUNENTER_MAKE_PARTY_CONTROLSET_HOOKED;

		g.loaded = true;

		CHAT_SYSTEM("マッチング表示修正　読み込み完了！");
	end

end

function INDUNENTER_MAKE_PARTY_CONTROLSET_HOOKED(pcCount, memberTable)
	local frame = ui.GetFrame('indunenter');
	local partyLine = GET_CHILD_RECURSIVELY(frame, 'partyLine');
	local memberBox = GET_CHILD_RECURSIVELY(frame, 'memberBox');
	local memberCnt = #memberTable / 3;

	if pcCount < 1 then
		memberCnt = 0;
	end

	local prevPcCnt = frame:GetUserIValue('UI_PC_COUNT');
	frame:SetUserValue('UI_PC_COUNT', pcCount);
	if prevPcCnt < pcCount then
		local MEMBER_FINDED_SOUND = frame:GetUserConfig('MEMBER_FINDED_SOUND');
		imcSound.PlaySoundEvent(MEMBER_FINDED_SOUND);
	end

	if memberCnt > 1 then 
		partyLine:Resize(58 * (memberCnt - 1), 15);
		partyLine:ShowWindow(1);
	else
		partyLine:ShowWindow(0);
	end
	DESTROY_CHILD_BYNAME(memberBox, 'MEMBER_');

	for i = 1, INDUN_AUTOMATCHING_PCCOUNT do
		local memberCtrlSet = memberBox:CreateOrGetControlSet('indunMember', 'MEMBER_'..tostring(i), 10 * i + 58 * (i - 1), 0);
		memberCtrlSet:ShowWindow(1);

		-- default setting
		local leaderImg = memberCtrlSet:GetChild('leader_img');
		local levelText = memberCtrlSet:GetChild('level_text');
		local jobIcon = GET_CHILD_RECURSIVELY(memberCtrlSet, 'jobportrait');
		local matchedIcon = GET_CHILD_RECURSIVELY(memberCtrlSet, 'matchedIcon');
		local NO_MATCH_SKIN = frame:GetUserConfig('NO_MATCH_SKIN');

		levelText:ShowWindow(0);
		leaderImg:ShowWindow(0);
		jobIcon:SetImage(NO_MATCH_SKIN);
		matchedIcon:ShowWindow(0);

		if i <= pcCount then
			if i * 3 <= #memberTable then
				-- show leader
				local aid = memberTable[i * 3 - 2];
				local pcparty = session.party.GetPartyInfo(PARTY_NORMAL);
				if pcparty ~= nil and pcparty.info:GetLeaderAID() == aid then
					leaderImg:ShowWindow(1);
				end
				-- show job icon
				local jobCls = GetClassByType("Job", tonumber(memberTable[i * 3 - 1]));
				local jobIconData = TryGetProp(jobCls, 'Icon');
				if jobIconData ~= nil then
					jobIcon:SetImage(jobIconData);
				end
				-- ここで使用している「PARTY_JOB_TOOLTIP_BY_AID」はJTOSには存在しない
				-- そのため、ここでぬるぽで落ちている
				-- ITOSなどではpartyinfo.luaに処理があるが、JTOSではこの処理だけ抜けている
				-- また「PARTY_JOB_TOOLTIP_BY_AID」内で使われている「session.otherPC.GetByStrAID」もない
				-- よって、この処理をコメントアウト
				--local ret = PARTY_JOB_TOOLTIP_BY_AID(aid, jobIcon, jobCls);

				-- show level
				local lv = memberTable[i * 3];
				levelText:SetText(lv);
				levelText:ShowWindow(1);
			else
				jobIcon:ShowWindow(0);
				matchedIcon:ShowWindow(1);
			end		
		end
	end
end
