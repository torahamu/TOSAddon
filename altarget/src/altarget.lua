local addonName = "ALTARGET";
local addonNameLower = string.lower(addonName);

_G['ADDONS'] = _G['ADDONS'] or {};
_G['ADDONS']['MONOGUSA'] = _G['ADDONS']['MONOGUSA'] or {};
_G['ADDONS']['MONOGUSA'][addonName] = _G['ADDONS']['MONOGUSA'][addonName] or {};

local g = _G['ADDONS']['MONOGUSA'][addonName];
local acutil = require('acutil');

if not g.loaded then
	g.ctrlLock = false;

	g.settings = {
		soundflg = true;
		hitflg = true;
		avoidflg = true;
		criflg = true;
		gematriaflg = true;
		notarikonflg = true;
	};

end
-- フレーム内文字
if option.GetCurrentCountry()=="Japanese" then
	hittxt = "命中率："
	avoidtxt = "回避率："
	critxt = "クリ率："
	gematriatxt = "ゲマトリア："
	notarikontxt = "ノタリコン："
else
	hittxt = "Accuracy:"
	avoidtxt = "Evasion:"
	critxt = "Critical:"
	gematriatxt = "Gematria:"
	notarikontxt = "Notarikon:"
end

g.settingsFileLoc = "../addons/"..addonNameLower.."/settings.json";

function ALTARGET_ON_INIT(addon, frame)
	local g = _G['ADDONS']['MONOGUSA']['ALTARGET'];
	local acutil = require('acutil');

	g.addon = addon;
	g.frame = frame;
	--frame:RunUpdateScript("ALTARGET_UPDATE");
	frame:ShowWindow(0);
	frame:EnableHitTest(0);
	if not g.loaded then
		local t, err = acutil.loadJSON(g.settingsFileLoc, g.settings);
		if err then
			acutil.saveJSON(g.settingsFileLoc, g.settings);
		else
			g.settings = t;
		end
		CHAT_SYSTEM('ALTARGET読み込み完了');
		g.loaded = true;
	end

	--acutil.slashCommand("/al", g.processCommand);
	acutil.slashCommand("/al", AL_COMMAND);
	acutil.setupHook(AL_LOCKTARGET, 'CTRLTARGETUI_OPEN');
	acutil.setupHook(AL_UNLOCKTARGET, 'CTRLTARGETUI_CLOSE');
	addon:RegisterMsg('TARGET_SET', 'AL_ON_TARGET');
	addon:RegisterMsg('TARGET_UPDATE', 'AL_ON_TARGET_UPDATE');
	addon:RegisterMsg('BUFF_ADD', 'AL_ON_TARGET_UPDATE')
	addon:RegisterMsg('BUFF_REMOVE', 'AL_ON_TARGET_UPDATE')
	addon:RegisterMsg('TARGET_BUFF_ADD', 'AL_ON_TARGET_UPDATE')
	addon:RegisterMsg('TARGET_BUFF_REMOVE', 'AL_ON_TARGET_UPDATE')
--	addon:RegisterMsg('TARGET_CLEAR', 'AL_ON_TARGET_CLEAR');

end

function AL_COMMAND(command)
	local cmd = "";
	local flg = "";

	if #command > 1 then
			cmd = string.lower(table.remove(command, 1));
			flg = string.lower(table.remove(command, 1));
	else
		local msg = '';
		msg = msg.. '/al sound [on or off]{nl}';
		msg = msg.. 'Target sound setting{nl}';
		msg = msg.. '-----------{nl}';
		msg = msg.. '/al hit [on or off]{nl}';
		msg = msg.. '/al accuracy [on or off]{nl}';
		msg = msg.. 'Show accuracy setting{nl}';
		msg = msg.. '-----------{nl}';
		msg = msg.. '/al avoid [on or off]{nl}';
		msg = msg.. '/al evasion [on or off]{nl}';
		msg = msg.. 'Show evasion setting{nl}';
		msg = msg.. '-----------{nl}';
		msg = msg.. '/al cri [on or off]{nl}';
		msg = msg.. 'Show critical setting{nl}';
		msg = msg.. '-----------{nl}';
		msg = msg.. '/al gematria [on or off]{nl}';
		msg = msg.. 'Show gematria setting{nl}';
		msg = msg.. '-----------{nl}';
		msg = msg.. '/al notarikon [on or off]{nl}';
		msg = msg.. 'Show notarikon setting{nl}';
		return ui.MsgBox(msg,"","Nope")
	end

	if cmd == "sound" then
		if flg == "on" then
			g.settings.soundflg = true;
		elseif flg == "off" then
			g.settings.soundflg = false;
		end
	elseif (cmd == "hit") or (cmd == "accuracy") then
		if flg == "on" then
			g.settings.hitflg = true;
		elseif flg == "off" then
			g.settings.hitflg = false;
		end
	elseif (cmd == "avoid") or (cmd == "evasion") then
		if flg == "on" then
			g.settings.avoidflg = true;
		elseif flg == "off" then
			g.settings.avoidflg = false;
		end
	elseif cmd == "cri" then
		if flg == "on" then
			g.settings.criflg = true;
		elseif flg == "off" then
			g.settings.criflg = false;
		end
	elseif cmd == "gematria" then
		if flg == "on" then
			g.settings.gematriaflg = true;
		elseif flg == "off" then
			g.settings.gematriaflg = false;
		end
	elseif cmd == "notarikon" then
		if flg == "on" then
			g.settings.notarikonflg = true;
		elseif flg == "off" then
			g.settings.notarikonflg = false;
		end
	end

	acutil.saveJSON(g.settingsFileLoc, g.settings);
end

function AL_LOCKTARGET()
	local g = _G['ADDONS']['MONOGUSA']['ALTARGET'];
	g.ctrlLock = true;
	local frame = g.frame;
	local itemimg = GET_CHILD_RECURSIVELY(frame, "itemimg");
	itemimg:ShowWindow(1);
	return CTRLTARGETUI_OPEN_OLD();
end

function AL_UNLOCKTARGET()
	local g = _G['ADDONS']['MONOGUSA']['ALTARGET'];
	g.ctrlLock = false;
	local frame = g.frame;
	local itemimg = GET_CHILD_RECURSIVELY(frame, "itemimg");
	itemimg:ShowWindow(0);
	return CTRLTARGETUI_CLOSE_OLD();
end

function AL_ON_TARGET()
	local g = _G['ADDONS']['MONOGUSA']['ALTARGET'];
	
	local frame = g.frame;
	local handle = session.GetTargetHandle();
	local actor = world.GetActor(handle);

	if actor == nil then
		return;
	end

	if frame:GetUserIValue("CurrentTarget") ~= nil then
		local prevHandle = frame:GetUserIValue("CurrentTarget");
		frame:SetUserValue("PrevTarget", prevHandle);
	end

	frame:SetUserValue("CurrentTarget", handle);
	--frame:ShowWindow(1);
	
	local monCls = GetClassByType("Monster", actor:GetType());
	local monRank = monCls.MonRank;
	
	if monCls == nil then
		return;
	end

	if monRank == "Material" then
		frame:ShowWindow(0);
		return;
	end

	local itembgimg = GET_CHILD_RECURSIVELY(frame, "itembgimg");
	local itemimg = GET_CHILD_RECURSIVELY(frame, "itemimg");
	local title = GET_CHILD_RECURSIVELY(frame, "title");
	local hit = GET_CHILD_RECURSIVELY(frame, "hit");
	local avoid = GET_CHILD_RECURSIVELY(frame, "avoid");
	local crirate = GET_CHILD_RECURSIVELY(frame, "crirate");
	local gematoria = GET_CHILD_RECURSIVELY(frame, "gematoria");
	local notaricon = GET_CHILD_RECURSIVELY(frame, "notaricon");
	tolua.cast(title, "ui::CRichText");
	tolua.cast(hit, "ui::CRichText");
	tolua.cast(avoid, "ui::CRichText");
	tolua.cast(crirate, "ui::CRichText");
	tolua.cast(gematoria, "ui::CRichText");
	tolua.cast(notaricon, "ui::CRichText");

	itemimg:SetImage("questmap");
	itembgimg:SetImage("questmap");
	itemimg:SetAngleLoop(-3);
	itembgimg:SetAngleLoop(3);

	if g.ctrlLock then
		itemimg:ShowWindow(1);
	else
		itemimg:ShowWindow(0);
	end

	local y = -50;
	local scale = 1;
	scale,y = AL_ON_TARGET_UPDATE();

	if frame:IsVisible() == 0 then
		CHAT_SYSTEM("invisible");
		return;
	end
	
	if g.settings.soundflg then
		imcSound.PlaySoundEvent("button_click");
	end
	FRAME_AUTO_POS_TO_OBJ(frame, handle, - frame:GetWidth() / 2, y, 3, 1);
end

function AL_ON_TARGET_UPDATE()
	local g = _G['ADDONS']['MONOGUSA']['ALTARGET'];
	
	local frame = g.frame;
	local handle = session.GetTargetHandle();
	local actor = world.GetActor(handle);

	if actor == nil then
		return;
	end

	local monCls = GetClassByType("Monster", actor:GetType());
	local monRank = monCls.MonRank;
	
	if	monRank == "Material" then
		frame:ShowWindow(0);
		return;
	end

	local itembgimg = GET_CHILD_RECURSIVELY(frame, "itembgimg");
	local itemimg = GET_CHILD_RECURSIVELY(frame, "itemimg");
	local title = GET_CHILD_RECURSIVELY(frame, "title");
	local hit = GET_CHILD_RECURSIVELY(frame, "hit");
	local avoid = GET_CHILD_RECURSIVELY(frame, "avoid");
	local cri = GET_CHILD_RECURSIVELY(frame, "cri");
	local gematoria = GET_CHILD_RECURSIVELY(frame, "gematoria");
	local notaricon = GET_CHILD_RECURSIVELY(frame, "notaricon");
	hit:SetText("");
	avoid:SetText("");
	cri:SetText("");
	gematoria:SetText("");
	notaricon:SetText("");

	local scale = 1;
	local y = -50;
	local color = "CCFFFFFF";
	--title:SetText("{#00FF33}{@st40}"..monRank.."{/}{/}");

	if monRank == "NPC" or monRank == "MISC" then
		color = "DD00FF33";
		y = -10;
		--title:SetText("{#00FF33}{@st40}"..monRank.."{/}{/}");

	else
		if monCls.Size == "S" then
			scale = 1;
		elseif monCls.Size == "M" then
			scale = 1.2;
		elseif monCls.Size == "L" then
			scale = 1.5;
		elseif monCls.Size == "XL" then
			scale = 2;
		end
		y = -(120) * scale /2;
		local stat = info.GetStat(handle);

		--local color = "CCFFFFFF";

		if stat ~= nil then
			local cA = "CC";
			local cR = "FF";
			local cG = string.format("%02x", math.floor(stat.HP / stat.maxHP * 255));
			if cG == "0" then cG = "00" end
			local cB = "00";
			color = cA..cR..cG..cB;
			local pc = GetMyPCObject();
			local gema,nota = GEMANOTA_CALC(monCls);
			monCls.Lv = monCls.Level

			local hitrate = SCR_Get_MON_DR(monCls) - pc.HR;
			if hitrate < 0 then
				hitrate = 0;
			end
			hitrate = math.floor(100-(hitrate^0.65));

			local avoidrate = pc.DR - SCR_Get_MON_HR(monCls);
			if avoidrate < 0 then
				avoidrate = 0;
			end
			avoidrate = math.floor(avoidrate^0.65);

			local crirate = pc.CRTHR - SCR_Get_MON_CRTDR(monCls);
			if crirate < 0 then
				crirate = 0;
			end
			crirate = math.floor(crirate^0.6);

			--title:SetText("{@st42}{#FFCC66}"..tostring(handle)..":"..tostring(handle).."{/}{/}");
			if g.settings.hitflg then
				hit:SetText("{@st42}{#6666FF}"..hittxt..tostring(hitrate).."%{/}{/}");
			else
				hit:SetText("");
			end
			if g.settings.avoidflg then
				avoid:SetText("{@st42}{#FFCC66}"..avoidtxt..tostring(avoidrate).."%{/}{/}");
			else
				avoid:SetText("");
			end
			if g.settings.criflg then
				cri:SetText("{@st42}{#66FF66}"..critxt..tostring(crirate).."%{/}{/}");
			else
				cri:SetText("");
			end
			if g.settings.gematriaflg then
				gematoria:SetText("{@st42}{#FF66FF}"..gematriatxt..tostring(gema).."{/}{/}");
			else
				gematoria:SetText("");
			end
			if g.settings.notarikonflg then
				notaricon:SetText("{@st42}{#FFFF66}"..notarikontxt..tostring(nota).."{/}{/}");
			else
				notaricon:SetText("");
			end
		end
	end

	itemimg:SetColorTone(color);
	itembgimg:SetColorTone(color);
	AL_CHANGE_SCALE(frame, scale);
	
	if frame:IsVisible() == 0 then frame:ShowWindow(1); end
	return scale, y;
end

function GEMANOTA_CALC(monCls)
	local gema = 0;
	local nota = 0;
	local set = monCls.SET;
	local len = string.len(set);

	-- ゲマトリアはSET内の文字を数字にして全部足した1桁目
	for i = 1, len do
		gema = gema + string.byte(string.sub(set,i,i))
	end
	gema = gema % 10

	-- ノタリコンは最初と最後の文字を数字にして足した1桁目
	nota = nota + string.byte(string.sub(set,1,1));
	nota = nota + string.byte(string.sub(set,len,len));
	nota = nota % 10

	return gema,nota
end


function AL_CHANGE_SCALE(frame, scale)
	if not scale then scale = 1 end
	
	local itembgimg = GET_CHILD_RECURSIVELY(frame, "itembgimg");
	local itemimg = GET_CHILD_RECURSIVELY(frame, "itemimg");
	
	frame:Resize(120*scale, 120*scale);
	itembgimg:Resize(120*scale, 120*scale);
	itemimg:Resize(75*scale, 75*scale);
	itemimg:Move(0, 0);
	local offset = (itembgimg:GetWidth()-itemimg:GetWidth())/2
	itemimg:SetOffset(0, offset);

end


function AL_ON_TARGET_CLEAR(msgFrame, msg, argStr, handle)
	local g = _G['ADDONS']['MONOGUSA']['ALTARGET'];
	local frame= g.frame;
	frame:ShowWindow(0);
end
