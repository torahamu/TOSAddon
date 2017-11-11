--dofile("../data/addon_d/statviewer/statviewer.lua");

--ライブラリ読み込み
local acutil = require('acutil');

local label = {
	["PATK"]      = {name="物理攻撃: "   ;ename="PATK: "     };
	["PATK_SUB"]  = {name="補助攻撃: "   ;ename="PATK_SUB: " };
	["MATK"]      = {name="魔法攻撃: "   ;ename="MATK: "     };
	["MHR"]       = {name="魔法増幅: "   ;ename="MHR: "      };
	["EATK"]      = {name="属性攻撃: "   ;ename="EATK: "     };
	["CRTHR"]     = {name="クリ発　: "   ;ename="CRTHR: "    };
	["CRTATK"]    = {name="クリ攻撃: "   ;ename="CRTATK: "   };
	["HR"]        = {name="命中　　: "   ;ename="HR: "       };
	["BLK_BREAK"] = {name="ブロ貫通: "   ;ename="BLK_BREAK: "};
	["SR"]        = {name="ＡＯＥ　: "   ;ename="SR: "       };
	["DEF"]       = {name="物理防御: "   ;ename="DEF: "      };
	["MDEF"]      = {name="魔法防御: "   ;ename="MDEF: "     };
	["DR"]        = {name="回避　　: "   ;ename="DR: "       };
	["BLK"]       = {name="ブロック: "   ;ename="BLK: "      };
	["CRTDR"]     = {name="クリ抵抗: "   ;ename="CRTDR: "    };
	["SDR"]       = {name="広域防御: "   ;ename="SDR: "      };
	["RHP"]       = {name="ＨＰ回復: "   ;ename="RHP: "      };
	["RSP"]       = {name="ＳＰ回復: "   ;ename="RSP: "      };
	["MSPD"]      = {name="スピード: "   ;ename="MSPD: "     };
	["WHEIGHT"]   = {name="所持量　: "   ;ename="WHEIGHT: "  };
};

function STATVIEWER_ON_INIT(addon, frame)
	STATVIEWER_LOAD_SETTINGS();
	STATVIEWER_UPDATE(frame);
	addon:RegisterMsg("PC_PROPERTY_UPDATE", "STATVIEWER_UPDATE");

	_G["STATVIEWER"].isDragging = false;
	frame:SetEventScript(ui.LBUTTONDOWN, "STATVIEWER_START_DRAG");
	frame:SetEventScript(ui.LBUTTONUP, "STATVIEWER_END_DRAG");

	STATVIEWER_UPDATE_POSITION();
end

function STATVIEWER_START_DRAG()
	_G["STATVIEWER"].isDragging = true;
end

function STATVIEWER_END_DRAG()
	_G["STATVIEWER"].isDragging = false;
	STATVIEWER_SAVE_SETTINGS();
end

function STATVIEWER_LOAD_SETTINGS()
	_G["STATVIEWER"] = _G["STATVIEWER"] or {};
	local settings, error = acutil.loadJSON("../addons/statviewer/settings.json");

	if error then
		STATVIEWER_SAVE_SETTINGS();
	else
		_G["STATVIEWER"]["settings"] = settings;
	end

	local mySession = session.GetMySession();
	local cid = mySession:GetCID();
	local statsettings, error = acutil.loadJSON("../addons/statviewer/"..cid..".json");

	if error then
		STATVIEWER_SAVE_STATSETTINGS_INIT(cid);
	else
		_G["STATVIEWER"]["statsettings"] = statsettings;
	end
end

function STATVIEWER_SAVE_SETTINGS()
	_G["STATVIEWER"] = _G["STATVIEWER"] or {};

	if _G["STATVIEWER"]["settings"] == nil then
		_G["STATVIEWER"]["settings"] = {
			x = STATVIEWER_GET_DEFAULT_X();
			y = STATVIEWER_GET_DEFAULT_Y()
		};
	else
		local frame = ui.GetFrame("statviewer");
		_G["STATVIEWER"]["settings"].x = frame:GetX();
		_G["STATVIEWER"]["settings"].y = frame:GetY();
	end

	acutil.saveJSON("../addons/statviewer/settings.json", _G["STATVIEWER"]["settings"]);
end

function STATVIEWER_SAVE_STATSETTINGS_INIT(cid)
	_G["STATVIEWER"] = _G["STATVIEWER"] or {};

	_G["STATVIEWER"]["statsettings"] = {
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
	};

	acutil.saveJSON("../addons/statviewer/"..cid..".json", _G["STATVIEWER"]["statsettings"]);
end

function STATVIEWER_GET_DEFAULT_X()
	local frame = ui.GetFrame("statviewer");

	return (option.GetClientWidth() / 2);
end

function STATVIEWER_GET_DEFAULT_Y()
	local frame = ui.GetFrame("statviewer");

	return (option.GetClientHeight() / 2);
end

function STATVIEWER_UPDATE_POSITION()
	local frame = ui.GetFrame("statviewer");

	if frame ~= nil and not _G["STATVIEWER"].isDragging then
		frame:SetOffset(_G["STATVIEWER"]["settings"].x, _G["STATVIEWER"]["settings"].y);
	end
end

function STATVIEWER_UPDATE(frame)
	local pc = GetMyPCObject();

	local dimensions = STATVIEWER_GET_DIMENSIONS();

	--frame, statName, statString, yPosition
	if _G["STATVIEWER"]["statsettings"].PATK then
		STATVIEWER_UPDATE_STAT(frame, "PATK"     , pc["MINPATK"] .. "~" .. pc["MAXPATK"], dimensions, _G["STATVIEWER"]["statsettings"].PATK_COLOR);
	end
	if _G["STATVIEWER"]["statsettings"].PATK_SUB then
		STATVIEWER_UPDATE_STAT(frame, "PATK_SUB" , pc["MINPATK_SUB"] .. "~" .. pc["MAXPATK_SUB"], dimensions, _G["STATVIEWER"]["statsettings"].PATK_SUB_COLOR);
	end
	if _G["STATVIEWER"]["statsettings"].MATK then
		STATVIEWER_UPDATE_STAT(frame, "MATK"     , pc["MINMATK"] .. "~" .. pc["MAXMATK"], dimensions, _G["STATVIEWER"]["statsettings"].MATK_COLOR);
	end
	if _G["STATVIEWER"]["statsettings"].MHR then
		STATVIEWER_UPDATE_STAT(frame, "MHR"      , pc["MHR"], dimensions, _G["STATVIEWER"]["statsettings"].MHR_COLOR);
	end
	if _G["STATVIEWER"]["statsettings"].EATK then
		local elementalAttack = STATVIEWER_CALCULATE_ELEMENTAL_ATTACK(pc);
		STATVIEWER_UPDATE_STAT(frame, "EATK"     , elementalAttack, dimensions, _G["STATVIEWER"]["statsettings"].EATK_COLOR);
	end
	if _G["STATVIEWER"]["statsettings"].CRTHR then
		STATVIEWER_UPDATE_STAT(frame, "CRTHR"    , pc["CRTHR"], dimensions, _G["STATVIEWER"]["statsettings"].CRTHR_COLOR);
	end
	if _G["STATVIEWER"]["statsettings"].CRTATK then
		STATVIEWER_UPDATE_STAT(frame, "CRTATK"   , pc["CRTATK"], dimensions, _G["STATVIEWER"]["statsettings"].CRTATK_COLOR);
	end
	if _G["STATVIEWER"]["statsettings"].HR then
		STATVIEWER_UPDATE_STAT(frame, "HR"       , pc["HR"], dimensions, _G["STATVIEWER"]["statsettings"].HR_COLOR);
	end
	if _G["STATVIEWER"]["statsettings"].BLK_BREAK then
		STATVIEWER_UPDATE_STAT(frame, "BLK_BREAK", pc["BLK_BREAK"], dimensions, _G["STATVIEWER"]["statsettings"].BLK_BREAK_COLOR);
	end
	if _G["STATVIEWER"]["statsettings"].SR then
		STATVIEWER_UPDATE_STAT(frame, "SR"       , pc["SR"], dimensions, _G["STATVIEWER"]["statsettings"].SR_COLOR);
	end
	if _G["STATVIEWER"]["statsettings"].DEF then
		STATVIEWER_UPDATE_STAT(frame, "DEF"      , pc["DEF"], dimensions, _G["STATVIEWER"]["statsettings"].DEF_COLOR);
	end
	if _G["STATVIEWER"]["statsettings"].MDEF then
		STATVIEWER_UPDATE_STAT(frame, "MDEF"     , pc["MDEF"], dimensions, _G["STATVIEWER"]["statsettings"].MDEF_COLOR);
	end
	if _G["STATVIEWER"]["statsettings"].DR then
		STATVIEWER_UPDATE_STAT(frame, "DR"       , pc["DR"], dimensions, _G["STATVIEWER"]["statsettings"].DR_COLOR);
	end
	if _G["STATVIEWER"]["statsettings"].BLK then
		STATVIEWER_UPDATE_STAT(frame, "BLK"      , pc["BLK"], dimensions, _G["STATVIEWER"]["statsettings"].BLK_COLOR);
	end
	if _G["STATVIEWER"]["statsettings"].CRTDR then
		STATVIEWER_UPDATE_STAT(frame, "CRTDR"    , pc["CRTDR"], dimensions, _G["STATVIEWER"]["statsettings"].CRTDR_COLOR);
	end
	if _G["STATVIEWER"]["statsettings"].SDR then
		STATVIEWER_UPDATE_STAT(frame, "SDR"      , pc["SDR"], dimensions, _G["STATVIEWER"]["statsettings"].SDR_COLOR);
	end
	if _G["STATVIEWER"]["statsettings"].RHP then
		STATVIEWER_UPDATE_STAT(frame, "RHP"      , pc["RHP"], dimensions, _G["STATVIEWER"]["statsettings"].RHP_COLOR);
	end
	if _G["STATVIEWER"]["statsettings"].RSP then
		STATVIEWER_UPDATE_STAT(frame, "RSP"      , pc["RSP"], dimensions, _G["STATVIEWER"]["statsettings"].RSP_COLOR);
	end
	if _G["STATVIEWER"]["statsettings"].MSPD then
		STATVIEWER_UPDATE_STAT(frame, "MSPD"     , pc["MSPD"], dimensions, _G["STATVIEWER"]["statsettings"].MSPD_COLOR);
	end
	if _G["STATVIEWER"]["statsettings"].WHEIGHT then
		STATVIEWER_UPDATE_STAT(frame, "WHEIGHT"  , pc["NowWeight"] .."/".. pc["MaxWeight"].. "("..tostring(math.floor(pc.NowWeight*100/pc.MaxWeight)).."%)", dimensions, _G["STATVIEWER"]["statsettings"].WHEIGHT_COLOR);
	end
	
	frame:Resize(dimensions.width, dimensions.height);
	STATVIEWER_UPDATE_POSITION();
end

function STATVIEWER_GET_DIMENSIONS()
	local dimensions = {};

	dimensions.x = 5;
	dimensions.y = 5;
	dimensions.width = 0;
	dimensions.height = 0;

	return dimensions;
end

function STATVIEWER_CALCULATE_ELEMENTAL_ATTACK(pc)
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

function STATVIEWER_GET_STATSTRING(statName)
	if option.GetCurrentCountry()=="Japanese" then
		return label[statName].name
	else
		return label[statName].ename
	end
end

function STATVIEWER_UPDATE_STAT(frame, statName, statString, dimensions, fontcolor)
	local statRichText = frame:CreateOrGetControl("richtext", statName .. "_text", dimensions.x, dimensions.y, 100, 25);
	tolua.cast(statRichText, "ui::CRichText");
	statRichText:SetGravity(ui.LEFT, ui.TOP);
	statRichText:SetTextAlign("left", "center");
	statRichText:SetText("{#"..fontcolor.."}{ol}{s16}"..STATVIEWER_GET_STATSTRING(statName)..statString.."{/}{/}{/}");
	statRichText:EnableHitTest(0);
	statRichText:ShowWindow(1);

	dimensions.y = dimensions.y + (statRichText:GetHeight() - 7);

	if statRichText:GetWidth() > dimensions.width then
		dimensions.width = statRichText:GetWidth();
	end

	dimensions.height = dimensions.height + statRichText:GetHeight();
end
