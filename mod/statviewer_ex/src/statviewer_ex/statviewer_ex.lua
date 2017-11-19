local acutil = require('acutil');

local label = {
	["PATK"]      = {name="物理攻撃: "   ;ename="PATK: "     ;kname="물리공격: "};
	["PATK_SUB"]  = {name="補助攻撃: "   ;ename="PATK_SUB: " ;kname="보조물공: "};
	["MATK"]      = {name="魔法攻撃: "   ;ename="MATK: "     ;kname="마법공격: "};
	["MHR"]       = {name="魔法増幅: "   ;ename="MHR: "      ;kname="마법증폭: "};
	["EATK"]      = {name="属性攻撃: "   ;ename="EATK: "     ;kname="속성공격: "};
	["CRTHR"]     = {name="クリ発　: "   ;ename="CRTHR: "    ;kname="치명확율: "};
	["CRTATK"]    = {name="クリ攻撃: "   ;ename="CRTATK: "   ;kname="치명공격: "};
	["HR"]        = {name="命中　　: "   ;ename="HR: "       ;kname="명중        : "};
	["BLK_BREAK"] = {name="ブロ貫通: "   ;ename="BLK_BREAK: ";kname="블록관통: "};
	["SR"]        = {name="ＡＯＥ　: "   ;ename="SR: "       ;kname="광공비    : "};
	["DEF"]       = {name="物理防御: "   ;ename="DEF: "      ;kname="물리방어: "};
	["MDEF"]      = {name="魔法防御: "   ;ename="MDEF: "     ;kname="마법방어: "};
	["DR"]        = {name="回避　　: "   ;ename="DR: "       ;kname="회피        : "};
	["BLK"]       = {name="ブロック: "   ;ename="BLK: "      ;kname="블록        : "};
	["CRTDR"]     = {name="クリ抵抗: "   ;ename="CRTDR: "    ;kname="치명저항: "};
	["SDR"]       = {name="広域防御: "   ;ename="SDR: "      ;kname="광역방어: "};
	["RHP"]       = {name="ＨＰ回復: "   ;ename="RHP: "      ;kname="HP획복   : "};
	["RSP"]       = {name="ＳＰ回復: "   ;ename="RSP: "      ;kname="SP회복   : "};
	["MSPD"]      = {name="スピード: "   ;ename="MSPD: "     ;kname="스피드    : "};
	["WHEIGHT"]   = {name="所持量　: "   ;ename="WHEIGHT: "  ;kname="소지량    : "};
};

function STATVIEWER_EX_ON_INIT(addon, frame)
	STATVIEWER_EX_LOAD_SETTINGS();
	STATVIEWER_EX_UPDATE(frame);
	addon:RegisterMsg("PC_PROPERTY_UPDATE", "STATVIEWER_EX_UPDATE");

	_G["STATVIEWER_EX"].isDragging = false;
	frame:SetEventScript(ui.LBUTTONDOWN, "STATVIEWER_EX_START_DRAG");
	frame:SetEventScript(ui.LBUTTONUP, "STATVIEWER_EX_END_DRAG");

	STATVIEWER_EX_UPDATE_POSITION();
end

function STATVIEWER_EX_START_DRAG()
	_G["STATVIEWER_EX"].isDragging = true;
end

function STATVIEWER_EX_END_DRAG()
	_G["STATVIEWER_EX"].isDragging = false;
	STATVIEWER_EX_SAVE_SETTINGS();
end

function STATVIEWER_EX_LOAD_SETTINGS()
	_G["STATVIEWER_EX"] = _G["STATVIEWER_EX"] or {};
	local settings, error = acutil.loadJSON("../addons/statviewer_ex/settings.json");

	if error then
		STATVIEWER_EX_SAVE_SETTINGS();
	else
		_G["STATVIEWER_EX"]["settings"] = settings;
	end

	local mySession = session.GetMySession();
	local cid = mySession:GetCID();
	local statsettings, error = acutil.loadJSON("../addons/statviewer_ex/"..cid..".json");

	if error then
		STATVIEWER_EX_SAVE_STATSETTINGS_INIT(cid, "statsettings");
	else
		_G["STATVIEWER_EX"]["statsettings"] = statsettings;
	end

	for i = 1 , 10 do
		STATVIEWER_EX_LOAD_COMMON_SETTINGS(i)
	end
end

function STATVIEWER_EX_LOAD_COMMON_SETTINGS(no)
	local statsettings, error = acutil.loadJSON("../addons/statviewer_ex/common"..no..".json");

	if error then
		STATVIEWER_EX_SAVE_STATSETTINGS_INIT("common"..no, "common"..no);
	else
		_G["STATVIEWER_EX"]["common"..no] = statsettings;
	end
end

function STATVIEWER_EX_SAVE_SETTINGS()
	_G["STATVIEWER_EX"] = _G["STATVIEWER_EX"] or {};

	if _G["STATVIEWER_EX"]["settings"] == nil then
		_G["STATVIEWER_EX"]["settings"] = {
			x = STATVIEWER_EX_GET_DEFAULT_X();
			y = STATVIEWER_EX_GET_DEFAULT_Y()
		};
	else
		local frame = ui.GetFrame("statviewer_ex");
		_G["STATVIEWER_EX"]["settings"].x = frame:GetX();
		_G["STATVIEWER_EX"]["settings"].y = frame:GetY();
	end

	acutil.saveJSON("../addons/statviewer_ex/settings.json", _G["STATVIEWER_EX"]["settings"]);
end

function STATVIEWER_EX_SAVE_STATSETTINGS_INIT(filename, statval)
	_G["STATVIEWER_EX"] = _G["STATVIEWER_EX"] or {};

	_G["STATVIEWER_EX"][statval] = {
		PATK = true;
		PATK_SUB = true;
		MATK = true;
		MHR = true;
		CRTHR = true;
		EATK = true;
		CRTATK = true;
		HR = true;
		BLK_BREAK = true;
		SR = true;
		DEF = true;
		MDEF = true;
		DR = true;
		BLK = true;
		CRTDR = true;
		SDR = true;
		RHP = true;
		RSP = true;
		MSPD = true;
		WHEIGHT = true;
		PATK_COLOR = "FFFFFF";
		PATK_SUB_COLOR = "FFFFFF";
		MATK_COLOR = "FFFFFF";
		MHR_COLOR = "FFFFFF";
		EATK_COLOR = "FFFFFF";
		CRTHR_COLOR = "FFFFFF";
		CRTATK_COLOR = "FFFFFF";
		HR_COLOR = "FFFFFF";
		BLK_BREAK_COLOR = "FFFFFF";
		SR_COLOR = "FFFFFF";
		DEF_COLOR = "FFFFFF";
		MDEF_COLOR = "FFFFFF";
		DR_COLOR = "FFFFFF";
		BLK_COLOR = "FFFFFF";
		CRTDR_COLOR = "FFFFFF";
		SDR_COLOR = "FFFFFF";
		RHP_COLOR = "FFFFFF";
		RSP_COLOR = "FFFFFF";
		MSPD_COLOR = "FFFFFF";
		WHEIGHT_COLOR = "FFFFFF";
		MEMO = "";
	};

	acutil.saveJSON("../addons/statviewer_ex/"..filename..".json", _G["STATVIEWER_EX"][statval]);
end

function STATVIEWER_EX_GET_DEFAULT_X()
	local frame = ui.GetFrame("statviewer_ex");

	return (option.GetClientWidth() / 2);
end

function STATVIEWER_EX_GET_DEFAULT_Y()
	local frame = ui.GetFrame("statviewer_ex");

	return (option.GetClientHeight() / 2);
end

function STATVIEWER_EX_UPDATE_POSITION()
	local frame = ui.GetFrame("statviewer_ex");

	if frame ~= nil and not _G["STATVIEWER_EX"].isDragging then
		frame:SetOffset(_G["STATVIEWER_EX"]["settings"].x, _G["STATVIEWER_EX"]["settings"].y);
	end
end

function STATVIEWER_EX_UPDATE(frame)
	local pc = GetMyPCObject();

	local dimensions = STATVIEWER_EX_GET_DIMENSIONS();

	--frame, statName, statString, yPosition
	if _G["STATVIEWER_EX"]["statsettings"].PATK then
		STATVIEWER_EX_UPDATE_STAT(frame, "PATK"     , pc["MINPATK"] .. "~" .. pc["MAXPATK"], dimensions, _G["STATVIEWER_EX"]["statsettings"].PATK_COLOR);
	end
	if _G["STATVIEWER_EX"]["statsettings"].PATK_SUB then
		STATVIEWER_EX_UPDATE_STAT(frame, "PATK_SUB" , pc["MINPATK_SUB"] .. "~" .. pc["MAXPATK_SUB"], dimensions, _G["STATVIEWER_EX"]["statsettings"].PATK_SUB_COLOR);
	end
	if _G["STATVIEWER_EX"]["statsettings"].MATK then
		STATVIEWER_EX_UPDATE_STAT(frame, "MATK"     , pc["MINMATK"] .. "~" .. pc["MAXMATK"], dimensions, _G["STATVIEWER_EX"]["statsettings"].MATK_COLOR);
	end
	if _G["STATVIEWER_EX"]["statsettings"].MHR then
		STATVIEWER_EX_UPDATE_STAT(frame, "MHR"      , pc["MHR"], dimensions, _G["STATVIEWER_EX"]["statsettings"].MHR_COLOR);
	end
	if _G["STATVIEWER_EX"]["statsettings"].EATK then
		local elementalAttack = STATVIEWER_EX_CALCULATE_ELEMENTAL_ATTACK(pc);
		STATVIEWER_EX_UPDATE_STAT(frame, "EATK"     , elementalAttack, dimensions, _G["STATVIEWER_EX"]["statsettings"].EATK_COLOR);
	end
	if _G["STATVIEWER_EX"]["statsettings"].CRTHR then
		STATVIEWER_EX_UPDATE_STAT(frame, "CRTHR"    , pc["CRTHR"], dimensions, _G["STATVIEWER_EX"]["statsettings"].CRTHR_COLOR);
	end
	if _G["STATVIEWER_EX"]["statsettings"].CRTATK then
		STATVIEWER_EX_UPDATE_STAT(frame, "CRTATK"   , pc["CRTATK"], dimensions, _G["STATVIEWER_EX"]["statsettings"].CRTATK_COLOR);
	end
	if _G["STATVIEWER_EX"]["statsettings"].HR then
		STATVIEWER_EX_UPDATE_STAT(frame, "HR"       , pc["HR"], dimensions, _G["STATVIEWER_EX"]["statsettings"].HR_COLOR);
	end
	if _G["STATVIEWER_EX"]["statsettings"].BLK_BREAK then
		STATVIEWER_EX_UPDATE_STAT(frame, "BLK_BREAK", pc["BLK_BREAK"], dimensions, _G["STATVIEWER_EX"]["statsettings"].BLK_BREAK_COLOR);
	end
	if _G["STATVIEWER_EX"]["statsettings"].SR then
		STATVIEWER_EX_UPDATE_STAT(frame, "SR"       , pc["SR"], dimensions, _G["STATVIEWER_EX"]["statsettings"].SR_COLOR);
	end
	if _G["STATVIEWER_EX"]["statsettings"].DEF then
		STATVIEWER_EX_UPDATE_STAT(frame, "DEF"      , pc["DEF"], dimensions, _G["STATVIEWER_EX"]["statsettings"].DEF_COLOR);
	end
	if _G["STATVIEWER_EX"]["statsettings"].MDEF then
		STATVIEWER_EX_UPDATE_STAT(frame, "MDEF"     , pc["MDEF"], dimensions, _G["STATVIEWER_EX"]["statsettings"].MDEF_COLOR);
	end
	if _G["STATVIEWER_EX"]["statsettings"].DR then
		STATVIEWER_EX_UPDATE_STAT(frame, "DR"       , pc["DR"], dimensions, _G["STATVIEWER_EX"]["statsettings"].DR_COLOR);
	end
	if _G["STATVIEWER_EX"]["statsettings"].BLK then
		STATVIEWER_EX_UPDATE_STAT(frame, "BLK"      , pc["BLK"], dimensions, _G["STATVIEWER_EX"]["statsettings"].BLK_COLOR);
	end
	if _G["STATVIEWER_EX"]["statsettings"].CRTDR then
		STATVIEWER_EX_UPDATE_STAT(frame, "CRTDR"    , pc["CRTDR"], dimensions, _G["STATVIEWER_EX"]["statsettings"].CRTDR_COLOR);
	end
	if _G["STATVIEWER_EX"]["statsettings"].SDR then
		STATVIEWER_EX_UPDATE_STAT(frame, "SDR"      , pc["SDR"], dimensions, _G["STATVIEWER_EX"]["statsettings"].SDR_COLOR);
	end
	if _G["STATVIEWER_EX"]["statsettings"].RHP then
		STATVIEWER_EX_UPDATE_STAT(frame, "RHP"      , pc["RHP"], dimensions, _G["STATVIEWER_EX"]["statsettings"].RHP_COLOR);
	end
	if _G["STATVIEWER_EX"]["statsettings"].RSP then
		STATVIEWER_EX_UPDATE_STAT(frame, "RSP"      , pc["RSP"], dimensions, _G["STATVIEWER_EX"]["statsettings"].RSP_COLOR);
	end
	if _G["STATVIEWER_EX"]["statsettings"].MSPD then
		STATVIEWER_EX_UPDATE_STAT(frame, "MSPD"     , pc["MSPD"], dimensions, _G["STATVIEWER_EX"]["statsettings"].MSPD_COLOR);
	end
	if _G["STATVIEWER_EX"]["statsettings"].WHEIGHT then
		STATVIEWER_EX_UPDATE_STAT(frame, "WHEIGHT"  , pc["NowWeight"] .."/".. pc["MaxWeight"].. "("..tostring(math.floor(pc.NowWeight*100/pc.MaxWeight)).."%)", dimensions, _G["STATVIEWER_EX"]["statsettings"].WHEIGHT_COLOR);
	end
	
	frame:Resize(dimensions.width, dimensions.height+1);
	STATVIEWER_EX_UPDATE_POSITION();
end

function STATVIEWER_EX_GET_DIMENSIONS()
	local dimensions = {};

	dimensions.x = 0;
	dimensions.y = 0;
	dimensions.width = 0;
	dimensions.height = 0;

	return dimensions;
end

function STATVIEWER_EX_CALCULATE_ELEMENTAL_ATTACK(pc)
	local elementalAttack = 0;

	elementalAttack = elementalAttack + pc["Fire_Atk"];
	elementalAttack = elementalAttack + pc["Ice_Atk"];
	elementalAttack = elementalAttack + pc["Lightning_Atk"];
	elementalAttack = elementalAttack + pc["Earth_Atk"];
	elementalAttack = elementalAttack + pc["Poison_Atk"];
	elementalAttack = elementalAttack + pc["Holy_Atk"];
	elementalAttack = elementalAttack + pc["Dark_Atk"];
	elementalAttack = elementalAttack + pc["Soul_Atk"];

	return elementalAttack;
end

function STATVIEWER_EX_GET_STATSTRING(statName)
	local country=option.GetCurrentCountry();
	if string.lower(country)=="japanese" then
		return label[statName].name
	elseif string.lower(country)=="korean" then
		return label[statName].kname
	else
		return label[statName].ename
	end
end

function STATVIEWER_EX_UPDATE_STAT(frame, statName, statString, dimensions, fontcolor)
	local statRichText = frame:CreateOrGetControl("richtext", statName .. "_text", dimensions.x, dimensions.y, 0, 25);
	tolua.cast(statRichText, "ui::CRichText");
	statRichText:SetGravity(ui.LEFT, ui.TOP);
	statRichText:SetTextAlign("left", "center");
	statRichText:SetText("{#"..fontcolor.."}{ol}{s16}"..STATVIEWER_EX_GET_STATSTRING(statName)..statString.."{/}{/}{/}");
	statRichText:EnableHitTest(0);
	statRichText:ShowWindow(1);

	dimensions.y = dimensions.y + statRichText:GetHeight()-7;

	if statRichText:GetWidth() > dimensions.width then
		dimensions.width = statRichText:GetWidth();
	end
	dimensions.height = dimensions.height + statRichText:GetHeight() -7 ;
	if statRichText:GetHeight() > dimensions.height then
		dimensions.height = statRichText:GetHeight();
	end
end
