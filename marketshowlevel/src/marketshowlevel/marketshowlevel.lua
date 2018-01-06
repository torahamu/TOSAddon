CHAT_SYSTEM("MARKET SHOW LEVEL v1.2.2 loaded!");

local addonName = "MARKETSHOWLEVEL";
local addonNameLower = string.lower(addonName);

local author = "torahamu";

_G['ADDONS'] = _G['ADDONS'] or {};
_G['ADDONS'][author] = _G['ADDONS'][author] or {}
_G['ADDONS'][author][addonName] = _G['ADDONS'][author][addonName] or {};
local g = _G['ADDONS'][author][addonName];

--ライブラリ読み込み
local acutil = require('acutil');

-- 読み込みフラグ
g.loaded=false

if not g.loaded then
	g.settings = {
		flg=false; --どこかの設定があれば、trueになる
		andFlg=false;
		filter = {
			PATK=false;
			MATK=false;
			ADD_MHR=false;
			ADD_FIRE=false;
			ADD_ICE=false;
			ADD_SOUL=false;
			ADD_POISON=false;
			ADD_LIGHTNING=false;
			ADD_EARTH=false;
			ADD_HOLY=false;
			ADD_DARK=false;
			CRTATK=false;
			ADD_CLOTH=false;
			ADD_LEATHER=false;
			ADD_IRON=false;
			ADD_GHOST=false;
			ADD_FORESTER=false;
			ADD_WIDLING=false;
			ADD_VELIAS=false;
			ADD_PARAMUNE=false;
			ADD_KLAIDA=false;
			ADD_SMALLSIZE=false;
			ADD_MIDDLESIZE=false;
			ADD_LARGESIZE=false;
			ADD_DEF=false;
			ADD_MDEF=false;
			AriesDEF=false;
			SlashDEF=false;
			SlashDEF=false;
			StrikeDEF=false;
			RES_FIRE=false;
			RES_ICE=false;
			RES_SOUL=false;
			RES_POISON=false;
			RES_LIGHTNING=false;
			RES_EARTH=false;
			RES_HOLY=false;
			RES_DARK=false;
			CRTDR=false;
			ADD_HR=false;
			ADD_DR=false;
			MSTA=false;
			MHP=false;
			MSP=false;
			RHP=false;
			RSP=false;
			BLK=false;
			CRTHR=false;
			BLK_BREAK=false;
			LootingChance=false;
			STR=false;
			CON=false;
			INT=false;
			MNA=false;
			DEX=false;
		}
	};
end

-- Equip Jem And Hat prop align
local propAlign = "center";
if option.GetCurrentCountry()=="Japanese" then
	propAlign = "left";
end

-- Hat prop color
local itemColor = {
	[0] = "FFFFFF",    -- Normal
	[1] = "108CFF",    -- 0.75 over
	[2] = "9F30FF",    -- 0.85 over
	[3] = "FF4F00",    -- 0.95 over
};

-- Prop Text
local AwakenText="Awaken Option"
local SocketText="Socket"
local PotentialText="Potential"
local OptionFilterButtonText = "OPTION FILTER"
if option.GetCurrentCountry()=="Japanese" then
	AwakenText="覚醒オプション"
	SocketText="ソケット"
	PotentialText="ポテンシャル"
	
end

-- Hat prop Name and Max Values
local propList = {};
propList.MHP           = {name = "ＨＰ";ename =  "MaxHP"   ;max = 2283;};
propList.RHP           = {name = "HP回";ename =  "HP Rec"  ;max = 56;};
propList.MSP           = {name = "ＳＰ";ename =  "Max SP"  ;max = 450;};
propList.RSP           = {name = "SP回";ename =  "SP Rec"  ;max = 42;};
propList.PATK          = {name = "物攻";ename =  "P.Atk"   ;max = 126;};
propList.ADD_MATK      = {name = "魔攻";ename =  "M.Atk"   ;max = 126;};
propList.STR           = {name = "STR ";ename =  "STR"     ;};
propList.DEX           = {name = "DEX ";ename =  "DEX"     ;};
propList.CON           = {name = "CON ";ename =  "CON"     ;};
propList.INT           = {name = "INT ";ename =  "INT"     ;};
propList.MNA           = {name = "SPR ";ename =  "SPR"     ;};
propList.ADD_DEF       = {name = "物防";ename =  "P.Def"   ;max = 110;};
propList.ADD_MDEF      = {name = "魔防";ename =  "M.Def"   ;max = 110;};
propList.ADD_MHR       = {name = "増幅";ename =  "M.Amp"   ;max = 126;};
propList.CRTATK        = {name = "ｸﾘ攻";ename =  "CritAtk" ;max = 189;};
propList.CRTHR         = {name = "ｸﾘ発";ename =  "CritRate";max = 14;};
propList.CRTDR         = {name = "ｸﾘ抵";ename =  "CritDef" ;max = 14;};
propList.BLK           = {name = "ブロ";ename =  "Blk"     ;max = 14;};
propList.ADD_HR        = {name = "命中";ename =  "Acc"     ;max = 14;};
propList.ADD_DR        = {name = "回避";ename =  "Eva"     ;max = 14;};
propList.ADD_FIRE      = {name = "炎攻";ename =  "FireAtk" ;max = 99;};
propList.ADD_ICE       = {name = "氷攻";ename =  "IceAtk"  ;max = 99;};
propList.ADD_POISON    = {name = "毒攻";ename =  "PsnAtk"  ;max = 99;};
propList.ADD_LIGHTNING = {name = "雷攻";ename =  "LgtAtk"  ;max = 99;};
propList.ADD_EARTH     = {name = "地攻";ename =  "EarthAtk";max = 99;};
propList.ADD_SOUL      = {name = "霊攻";ename =  "GhostAtk";max = 99;};
propList.ADD_HOLY      = {name = "聖攻";ename =  "HolyAtk" ;max = 99;};
propList.ADD_DARK      = {name = "闇攻";ename =  "DarkAtk" ;max = 99;};
propList.RES_FIRE      = {name = "炎防";ename =  "FireRes" ;max = 84;};
propList.RES_ICE       = {name = "氷防";ename =  "IceRes"  ;max = 84;};
propList.RES_POISON    = {name = "毒防";ename =  "PsnRes"  ;max = 84;};
propList.RES_LIGHTNING = {name = "雷防";ename =  "LgtRes"  ;max = 84;};
propList.RES_EARTH     = {name = "地防";ename =  "EarthRes";max = 84;};
propList.RES_SOUL      = {name = "霊防";ename =  "GhostRes";max = 84;};
propList.RES_HOLY      = {name = "聖防";ename =  "HolyRes" ;max = 84;};
propList.RES_DARK      = {name = "闇防";ename =  "DarkRes" ;max = 84;};
propList.MSPD          = {name = "移動";ename =  "Mspd"    ;max = 1;};
propList.SR            = {name = "広攻";ename =  "AoEAtk"  ;max = 1;};
propList.SDR           = {name = "広防";ename =  "AoEDef"  ;max = 4;};
propList.LootingChance = {name = "ﾙｰﾄ%";ename =  "Loot%"   ;};

function MARKETSHOWLEVEL_ON_INIT(addon, frame)
	frame:ShowWindow(0);
	-- 元関数封印
	-- marketnamesでも同じ箇所にHOOKしているので、毎ロード時実行
	acutil.setupHook(ON_MARKET_ITEM_LIST_HOOKED, "ON_MARKET_ITEM_LIST");
	-- イベント登録
	acutil.setupEvent(addon, "ON_OPEN_MARKET", "MARKETSHOWLEVEL_ON_OPEN_MARKET");
	g.loaded = true;
end

function MARKETSHOWLEVEL_ON_OPEN_MARKET(frame, msg)
	MARKETSHOWLEVEL_FLG_INIT();
	CUSTOM_DETAIL_BOX();
	CREATE_FILTER_FRAME();
end

function CUSTOM_DETAIL_BOX()
	local marketframe = ui.GetFrame("market")
	local gBox = GET_CHILD(marketframe, "detailOption");
	local filter_button = gBox:CreateOrGetControl("button", "MARKET_FILTER_BUTTON", 160, 10, 180, 30);
	filter_button = tolua.cast(filter_button, "ui::CButton");
	filter_button:SetFontName("white_16_ol");
	filter_button:SetText(OptionFilterButtonText);
	filter_button:SetClickSound("button_click_big");
	filter_button:SetOverSound("button_over");
	filter_button:SetAnimation("MouseOnAnim", "btn_mouseover");
	filter_button:SetAnimation("MouseOffAnim", "btn_mouseoff");
	filter_button:SetEventScript(ui.LBUTTONDOWN, "OPEN_FILTER_FRAME");
end

function CREATE_FILTER_FRAME()
	local frame = ui.GetFrame("marketshowlevel")
	frame:Resize(1300,850)
	local labelfontName = "white_24_ol"
	local bodyfontName = "white_16_ol"

	local andRadio = GET_CHILD(frame, "andRadio");
	tolua.cast(andRadio, "ui::CRadioButton");
	andRadio:SetFontName(labelfontName)
	andRadio:SetText("AND")

	local orRadio = GET_CHILD(frame, "orRadio");
	tolua.cast(orRadio, "ui::CRadioButton");
	orRadio:SetFontName(labelfontName)
	orRadio:SetText("OR")
	orRadio:Select()

	local rtLabel = {
		[1]  = {name="赤グループ"  ;ename="RED GROUP"    ;clmsg="ItemRandomOptionGroupATK" ; left=200  ; top= 100 ;  h=0; w=0;};
		[2]  = {name="青グループ"  ;ename="BLUE GROUP"   ;clmsg="ItemRandomOptionGroupDEF" ; left=550  ; top= 100 ;  h=0; w=0;};
		[3]  = {name="紫グループ"  ;ename="PURPLE GROUP" ;clmsg="ItemRandomOptionGroupUTIL"; left=800  ; top= 100 ;  h=0; w=0;};
		[4]  = {name="緑グループ"  ;ename="GREEN GROUP"  ;clmsg="ItemRandomOptionGroupSTAT"; left=1050 ; top= 100 ;  h=0; w=0;};
	};

	for i, ver in ipairs(rtLabel) do
		local header = frame:CreateOrGetControl("richtext", "marketshowlevel_filter_label"..i, rtLabel[i].left, rtLabel[i].top, rtLabel[i].h, rtLabel[i].w);
		tolua.cast(header, "ui::CRichText");
		header:SetFontName(labelfontName);
		if option.GetCurrentCountry()=="Japanese" then
			header:SetText(ClMsg(rtLabel[i].clmsg) .. rtLabel[i].name);
		else
			header:SetText(ClMsg(rtLabel[i].clmsg) .. rtLabel[i].ename);
		end
	end

	local rtATK = {
		[1]   = {clmsg="PATK"           ; left=70 ; top= 150  ;  h=0; w=0;};
		[2]   = {clmsg="MATK"           ; left=70 ; top= 200  ;  h=0; w=0;};
		[3]   = {clmsg="ADD_MHR"        ; left=70 ; top= 250  ;  h=0; w=0;};
		[4]   = {clmsg="ADD_FIRE"       ; left=70 ; top= 300  ;  h=0; w=0;};
		[5]   = {clmsg="ADD_ICE"        ; left=70 ; top= 350  ;  h=0; w=0;};
		[6]   = {clmsg="ADD_SOUL"       ; left=70 ; top= 400  ;  h=0; w=0;};
		[7]   = {clmsg="ADD_POISON"     ; left=70 ; top= 450  ;  h=0; w=0;};
		[8]   = {clmsg="ADD_LIGHTNING"  ; left=70 ; top= 500  ;  h=0; w=0;};
		[9]   = {clmsg="ADD_EARTH"      ; left=70 ; top= 550  ;  h=0; w=0;};
		[10]  = {clmsg="ADD_HOLY"       ; left=70 ; top= 600  ;  h=0; w=0;};
		[11]  = {clmsg="ADD_DARK"       ; left=70 ; top= 650  ;  h=0; w=0;};
		[12]  = {clmsg="CRTATK"         ; left=70 ; top= 700  ;  h=0; w=0;};
		[13]  = {clmsg="ADD_CLOTH"      ; left=320; top= 150  ;  h=0; w=0;};
		[14]  = {clmsg="ADD_LEATHER"    ; left=320; top= 200  ;  h=0; w=0;};
		[15]  = {clmsg="ADD_IRON"       ; left=320; top= 250  ;  h=0; w=0;};
		[16]  = {clmsg="ADD_GHOST"      ; left=320; top= 300  ;  h=0; w=0;};
		[17]  = {clmsg="ADD_FORESTER"   ; left=320; top= 350  ;  h=0; w=0;};
		[18]  = {clmsg="ADD_WIDLING"    ; left=320; top= 400  ;  h=0; w=0;};
		[19]  = {clmsg="ADD_VELIAS"     ; left=320; top= 450  ;  h=0; w=0;};
		[20]  = {clmsg="ADD_PARAMUNE"   ; left=320; top= 500  ;  h=0; w=0;};
		[21]  = {clmsg="ADD_KLAIDA"     ; left=320; top= 550  ;  h=0; w=0;};
		[22]  = {clmsg="ADD_SMALLSIZE"  ; left=320; top= 600  ;  h=0; w=0;};
		[23]  = {clmsg="ADD_MIDDLESIZE" ; left=320; top= 650  ;  h=0; w=0;};
		[24]  = {clmsg="ADD_LARGESIZE"  ; left=320; top= 700  ;  h=0; w=0;};
	};

	for i, ver in ipairs(rtATK) do
		local atkbody = frame:CreateOrGetControl("richtext", "marketshowlevel_filter_atk"..i, rtATK[i].left, rtATK[i].top, rtATK[i].h, rtATK[i].w);
		tolua.cast(atkbody, "ui::CRichText");
		atkbody:SetFontName(bodyfontName);
		atkbody:SetText(ClMsg(rtATK[i].clmsg));
		atkbody:EnableResizeByText(1);
		atkbody:SetTextFixWidth(1);
		atkbody:SetMaxWidth(220);
		atkbody:Resize(220, 50);

		local atkCheck = frame:CreateOrGetControl("checkbox", "marketshowlevel_check_atk"..i, rtATK[i].left-25, rtATK[i].top-5, 35, 35);
		tolua.cast(atkCheck, "ui::CCheckBox");
		atkCheck:SetClickSound("button_click_big");
		atkCheck:SetAnimation("MouseOnAnim",  "btn_mouseover");
		atkCheck:SetAnimation("MouseOffAnim", "btn_mouseoff");
		atkCheck:SetOverSound("button_over");
		atkCheck:SetEventScript(ui.LBUTTONUP, "MARKETSHOWLEVEL_FILTER");
		atkCheck:SetUserValue("TYPE", rtATK[i].clmsg);
		if g.settings.filter[rtATK[i].clmsg] then
			atkCheck:SetCheck(1);
		else
			atkCheck:SetCheck(0);
		end
	end

	local rtDEF = {
		[1]   = {clmsg="ADD_DEF"       ; left=570 ; top= 150 ;  h=0; w=0;};
		[2]   = {clmsg="ADD_MDEF"      ; left=570 ; top= 200 ;  h=0; w=0;};
		[3]   = {clmsg="AriesDEF"      ; left=570 ; top= 250 ;  h=0; w=0;};
		[4]   = {clmsg="SlashDEF"      ; left=570 ; top= 300 ;  h=0; w=0;};
		[5]   = {clmsg="StrikeDEF"     ; left=570 ; top= 350 ;  h=0; w=0;};
		[6]   = {clmsg="RES_FIRE"      ; left=570 ; top= 400 ;  h=0; w=0;};
		[7]   = {clmsg="RES_ICE"       ; left=570 ; top= 450 ;  h=0; w=0;};
		[8]   = {clmsg="RES_SOUL"      ; left=570 ; top= 500 ;  h=0; w=0;};
		[9]   = {clmsg="RES_POISON"    ; left=570 ; top= 550 ;  h=0; w=0;};
		[10]  = {clmsg="RES_LIGHTNING" ; left=570 ; top= 600 ;  h=0; w=0;};
		[11]  = {clmsg="RES_EARTH"     ; left=570 ; top= 650 ;  h=0; w=0;};
		[12]  = {clmsg="RES_HOLY"      ; left=570 ; top= 700 ;  h=0; w=0;};
		[13]  = {clmsg="RES_DARK"      ; left=570 ; top= 750 ;  h=0; w=0;};
		[14]  = {clmsg="CRTDR"         ; left=570 ; top= 800 ;  h=0; w=0;};
	};

	for i, ver in ipairs(rtDEF) do
		local defbody = frame:CreateOrGetControl("richtext", "marketshowlevel_filter_def"..i, rtDEF[i].left, rtDEF[i].top, rtDEF[i].h, rtDEF[i].w);
		tolua.cast(defbody, "ui::CRichText");
		defbody:SetFontName(bodyfontName);
		defbody:SetText(ClMsg(rtDEF[i].clmsg));
		defbody:EnableResizeByText(1);
		defbody:SetTextFixWidth(1);
		defbody:SetMaxWidth(220);
		defbody:Resize(220, 50);

		local defCheck = frame:CreateOrGetControl("checkbox", "marketshowlevel_check_def"..i, rtDEF[i].left-25, rtDEF[i].top-5, 35, 35);
		tolua.cast(defCheck, "ui::CCheckBox");
		defCheck:SetClickSound("button_click_big");
		defCheck:SetAnimation("MouseOnAnim",  "btn_mouseover");
		defCheck:SetAnimation("MouseOffAnim", "btn_mouseoff");
		defCheck:SetOverSound("button_over");
		defCheck:SetEventScript(ui.LBUTTONUP, "MARKETSHOWLEVEL_FILTER");
		defCheck:SetUserValue("TYPE", rtDEF[i].clmsg);
		if g.settings.filter[rtDEF[i].clmsg] then
			defCheck:SetCheck(1);
		else
			defCheck:SetCheck(0);
		end
	end

	local rtUTIL = {
		[1]   = {clmsg="ADD_HR"           ; left=820 ; top= 150 ;  h=0; w=0;};
		[2]   = {clmsg="ADD_DR"           ; left=820 ; top= 200 ;  h=0; w=0;};
		[3]   = {clmsg="MSTA"             ; left=820 ; top= 250 ;  h=0; w=0;};
		[4]   = {clmsg="MHP"              ; left=820 ; top= 300 ;  h=0; w=0;};
		[5]   = {clmsg="MSP"              ; left=820 ; top= 350 ;  h=0; w=0;};
		[6]   = {clmsg="RHP"              ; left=820 ; top= 400 ;  h=0; w=0;};
		[7]   = {clmsg="RSP"              ; left=820 ; top= 450 ;  h=0; w=0;};
		[8]   = {clmsg="CRTHR"            ; left=820 ; top= 500 ;  h=0; w=0;};
		[9]   = {clmsg="BLK"              ; left=820 ; top= 550 ;  h=0; w=0;};
		[10]  = {clmsg="BLK_BREAK"        ; left=820 ; top= 600 ;  h=0; w=0;};
		[11]  = {clmsg="LootingChance"    ; left=820 ; top= 650 ;  h=0; w=0;};
	};

	for i, ver in ipairs(rtUTIL) do
		local utilbody = frame:CreateOrGetControl("richtext", "marketshowlevel_filter_util"..i, rtUTIL[i].left, rtUTIL[i].top, rtUTIL[i].h, rtUTIL[i].w);
		tolua.cast(utilbody, "ui::CRichText");
		utilbody:SetFontName(bodyfontName);
		utilbody:SetText(ClMsg(rtUTIL[i].clmsg));
		utilbody:EnableResizeByText(1);
		utilbody:SetTextFixWidth(1);
		utilbody:SetMaxWidth(220);
		utilbody:Resize(220, 50);

		local utilCheck = frame:CreateOrGetControl("checkbox", "marketshowlevel_check_util"..i, rtUTIL[i].left-25, rtUTIL[i].top-5, 35, 35);
		tolua.cast(utilCheck, "ui::CCheckBox");
		utilCheck:SetClickSound("button_click_big");
		utilCheck:SetAnimation("MouseOnAnim",  "btn_mouseover");
		utilCheck:SetAnimation("MouseOffAnim", "btn_mouseoff");
		utilCheck:SetOverSound("button_over");
		utilCheck:SetEventScript(ui.LBUTTONUP, "MARKETSHOWLEVEL_FILTER");
		utilCheck:SetUserValue("TYPE", rtUTIL[i].clmsg);
		if g.settings.filter[rtUTIL[i].clmsg] then
			utilCheck:SetCheck(1);
		else
			utilCheck:SetCheck(0);
		end
	end

	local rtSTAT = {
		[1]  = {clmsg="STR"  ; left=1070 ; top= 150 ;  h=0; w=0;};
		[2]  = {clmsg="CON"  ; left=1070 ; top= 200 ;  h=0; w=0;};
		[3]  = {clmsg="INT"  ; left=1070 ; top= 250 ;  h=0; w=0;};
		[4]  = {clmsg="MNA"  ; left=1070 ; top= 300 ;  h=0; w=0;};
		[5]  = {clmsg="DEX"  ; left=1070 ; top= 350 ;  h=0; w=0;};
	};

	for i, ver in ipairs(rtSTAT) do
		local statbody = frame:CreateOrGetControl("richtext", "marketshowlevel_filter_stat"..i, rtSTAT[i].left, rtSTAT[i].top, rtSTAT[i].h, rtSTAT[i].w);
		tolua.cast(statbody, "ui::CRichText");
		statbody:SetFontName(bodyfontName);
		statbody:SetText(ClMsg(rtSTAT[i].clmsg));
		statbody:EnableResizeByText(1);
		statbody:SetTextFixWidth(1);
		statbody:SetMaxWidth(220);
		statbody:Resize(220, 50);

		local statCheck = frame:CreateOrGetControl("checkbox", "marketshowlevel_check_stat"..i, rtSTAT[i].left-25, rtSTAT[i].top-5, 35, 35);
		tolua.cast(statCheck, "ui::CCheckBox");
		statCheck:SetClickSound("button_click_big");
		statCheck:SetAnimation("MouseOnAnim",  "btn_mouseover");
		statCheck:SetAnimation("MouseOffAnim", "btn_mouseoff");
		statCheck:SetOverSound("button_over");
		statCheck:SetEventScript(ui.LBUTTONUP, "MARKETSHOWLEVEL_FILTER");
		statCheck:SetUserValue("TYPE", rtSTAT[i].clmsg);
		if g.settings.filter[rtSTAT[i].clmsg] then
			statCheck:SetCheck(1);
		else
			statCheck:SetCheck(0);
		end
	end

	local closebtn = frame:CreateOrGetControl("button", "MARKETSHOWLEVEL_CLOSE_BUTTON", 0, 0, 44, 44);
	closebtn = tolua.cast(closebtn, "ui::CButton");
	closebtn:SetImage("testclose_button");
	closebtn:SetGravity(ui.RIGHT, ui.TOP);
	closebtn:SetClickSound("button_click_big");
	closebtn:SetOverSound("button_over");
	closebtn:SetAnimation("MouseOnAnim", "btn_mouseover");
	closebtn:SetAnimation("MouseOffAnim", "btn_mouseoff");
	closebtn:SetEventScript(ui.LBUTTONDOWN, "CLOSE_FILTER_FRAME");
end

function MARKETSHOWLEVEL_FILTER_SEARCH(frame, ctrl)
	local marketframe = ui.GetFrame("market");
	local radioBtn = GET_CHILD_RECURSIVELY(frame, "andRadio");
	tolua.cast(radioBtn, "ui::CRadioButton");
	local type = radioBtn:IsChecked();
	if type == 1 then
		g.settings.andFlg=true;
	else
		g.settings.andFlg=false
	end
	MARGET_FIND_PAGE(marketframe, session.market.GetCurPage());
end

function MARKETSHOWLEVEL_FILTER(frame, ctrl, argStr, argNum)
	local marketframe = ui.GetFrame("market");
	local type = ctrl:GetUserValue("TYPE");
	g.settings.flg = false;
	if ctrl:IsChecked() == 1 then
		g.settings.filter[type] = true;
	else
		g.settings.filter[type] = false;
	end
	for k,v in pairs(g.settings.filter) do
		if v then
			g.settings.flg = true;
		end
	end
	MARGET_FIND_PAGE(marketframe, session.market.GetCurPage());
end

function MARKETSHOWLEVEL_TEST()
	for k,v in pairs(g.settings.filter) do
		print("k:"..tostring(k))
		print("v:"..tostring(v))
		print("g.settings.filter[k]:"..tostring(g.settings.filter[k]))
	end
end

function MARKETSHOWLEVEL_FLG_INIT()
	g.settings.flg=false;
	g.settings.andFlg=false;
	for k,v in pairs(g.settings.filter) do
		g.settings.filter[k] = false;
	end
end

function OPEN_FILTER_FRAME()
	ui.OpenFrame("marketshowlevel");
end

function CLOSE_FILTER_FRAME()
	ui.CloseFrame("marketshowlevel");
end

function GET_GEM_INFO(itemObj)
	local gemInfo = "";
	local fn = GET_FULL_NAME_OLD or GET_FULL_NAME;

	local socketId;
	local rstLevel;
	local gemName;
	local exp;
	local color="";

	for i = 0, 4 do

		socketId = itemObj["Socket_Equip_" .. i];
		rstLevel = itemObj["Socket_JamLv_" .. i];
		exp = itemObj["SocketItemExp_" .. i];

		if socketId > 0 then
			if #gemInfo > 0 then
				gemInfo = gemInfo.." ";
			end

			local obj = GetClassByType("Item", socketId);
			gemName = fn(obj);
			local gemLevel = 0;

			if exp >= 27014700 then
				gemLevel = 10;
			elseif exp >= 5414700 then
				gemLevel = 9;
			elseif exp >= 1094700 then
				gemLevel = 8;
			elseif exp >= 230700 then
				gemLevel = 7;
			elseif exp >= 57900 then
				gemLevel = 6;
			elseif exp >= 14700 then
				gemLevel = 5;
			elseif exp >= 3900 then
				gemLevel = 4;
			elseif exp >= 1200 then
				gemLevel = 3;
			elseif exp >= 300 then
				gemLevel = 2;
			else
				gemLevel = 1;
			end

			if gemLevel <= rstLevel then
				gemInfo = gemInfo .. "{#FF7F50}{ol}Lv" .. gemLevel .. ":" .. GET_ITEM_IMG_BY_CLS(obj, 20) .. "{/}{/}";
			else
				gemInfo = gemInfo .. "{#FFFFFF}{ol}Lv" .. gemLevel .. ":" .. GET_ITEM_IMG_BY_CLS(obj, 20) .. "{/}{/}";
			end

		end
	end

	return gemInfo;

end

function GET_HAT_PROP(itemObj)
	if itemObj.ClassType ~= "Hat" then
		return ""
	end

	local prop = "";
	for i = 1 , 3 do
		local propName = "";
		local propValue = 0;
		local propNameStr = "HatPropName_"..i;
		local propValueStr = "HatPropValue_"..i;
		if itemObj[propValueStr] ~= 0 and itemObj[propNameStr] ~= "None" then
			if #prop > 0 then
				prop = prop.." ";
			end

			propName = itemObj[propNameStr];
			propValue = itemObj[propValueStr];

			propValueColored = GET_ITEM_VALUE_COLOR(propName, propValue, propList[propName].max);
			local viewName = propList[propName].ename;
			if option.GetCurrentCountry()=="Japanese" then
				viewName = propList[propName].name;
			end

			prop = prop .. string.format("%s:{#%s}{ol}%4d{/}{/}", viewName, propValueColored, propValue);
		end
	end

	return prop;
end

function GET_INFO_RANDOM(obj,ctrlSet)
	local randomInfo = "";
	if g.settings.flg then
		ctrlSet:SetSkinName("tooltip1")
	end

	local propNameList = {};

	for i = 1 , MAX_RANDOM_OPTION_COUNT do
	    local propGroupName = "RandomOptionGroup_"..i;
		local propName = "RandomOption_"..i;
		local propValue = "RandomOptionValue_"..i;
		local clientMessage = 'None'
		
		if obj[propGroupName] == 'ATK' then
		    clientMessage = 'ItemRandomOptionGroupATK'
		elseif obj[propGroupName] == 'DEF' then
		    clientMessage = 'ItemRandomOptionGroupDEF'
		elseif obj[propGroupName] == 'UTIL_WEAPON' then
		    clientMessage = 'ItemRandomOptionGroupUTIL'
		elseif obj[propGroupName] == 'UTIL_ARMOR' then
		    clientMessage = 'ItemRandomOptionGroupUTIL'
		elseif obj[propGroupName] == 'UTIL_SHILED' then
		    clientMessage = 'ItemRandomOptionGroupUTIL'
		elseif obj[propGroupName] == 'STAT' then
		    clientMessage = 'ItemRandomOptionGroupSTAT'
		end

		if obj[propValue] ~= 0 and obj[propName] ~= "None" then
			--local opName = string.format("%s %s", ClMsg(clientMessage), ScpArgMsg(obj[propName]));
			if #randomInfo > 0 then
				randomInfo = randomInfo.." ";
			end
			local prop = ""
			if propList[propName] ~= nil then
				prop = propList[propName].ename;
				if option.GetCurrentCountry()=="Japanese" then
					prop = propList[propName].name;
				end
			else
				prop = ScpArgMsg(obj[propName])
			end

			local opName = string.format("%s %s", ClMsg(clientMessage), prop);
			local info = string.format("%s " .. "%d", opName, math.abs(obj[propValue]))
			randomInfo = randomInfo..info
			if g.settings.flg then
				if g.settings.andFlg then
					propNameList[obj[propName]] = true;
				else
					if g.settings.filter[obj[propName]] then
						ctrlSet:SetSkinName("market_listbase")
					end
				end
			end
		end
	end

	if g.settings.flg then
		if g.settings.andFlg then
			local matchFlg = true;
			for k, v in pairs(g.settings.filter) do
				if v then
					if nil == propNameList[k] then
						matchFlg = false;
					end
				end
			end
			if matchFlg then
				ctrlSet:SetSkinName("market_listbase")
			end
		end
	end

	return randomInfo
end

function GET_ITEM_VALUE_COLOR(propname,value, max)
	if propname == "MSPD" or propname == "SR" or propname == "SDR" then
		return itemColor[0];
	else
		if value > (max * 0.95) then
			return itemColor[3];
		elseif value > (max * 0.85) then
			return itemColor[2];
		elseif value > (max * 0.75) then
			return itemColor[1];
		else
			return itemColor[0];
		end
	end
end

function GET_EQUIP_PROP(ctrlSet, itemObj, row)
	local gemInfo = GET_GEM_INFO(itemObj);
	local prop = GET_HAT_PROP(itemObj);
	local randomInfo = GET_INFO_RANDOM(itemObj,ctrlSet)

	local propDetail = ctrlSet:CreateControl("richtext", "PROP_ITEM_" .. row, 100, 42, 0, 0);
	tolua.cast(propDetail, 'ui::CRichText');
	propDetail:SetFontName("brown_16_b");
	if #randomInfo > 0 then
		randomInfo = randomInfo.." ";
	end
	if option.GetCurrentCountry()=="Japanese" then
		propDetail:SetText("{s14}"..prop..randomInfo..gemInfo.."{/}");
	else
		propDetail:SetText("{s12}"..prop..randomInfo..gemInfo.."{/}");
	end
	propDetail:Resize(100, propDetail:GetY()-12)
	propDetail:SetTextAlign(propAlign, "top");
end

function GET_SOCKET_POTENSIAL_AWAKEN_PROP(ctrlSet, itemObj, row)
	local nowusesocketcount = 0
	for i = 0, itemObj.MaxSocket - 1 do
		local nowsockettype = itemObj['Socket_' .. i]

		if nowsockettype ~= 0 then
			nowusesocketcount = nowusesocketcount + 1
		end
	end

	local awakenProp = "";

	if itemObj.IsAwaken == 1 then
		awakenProp = "{#3300FF}{b}"..AwakenText.."["..propList[itemObj.HiddenProp].name.. " "..itemObj.HiddenPropValue.."]{/}{/}";
	end

	local maxPR = 0;
	if itemObj.MaxPR == 0 then
		local itemCls = GetClass("Item",itemObj.ClassName)
		maxPR = itemCls.PR
	else
		maxPR = itemObj.MaxPR
	end


	local socketDetail = ctrlSet:CreateControl("richtext", "SOCKTE_ITEM_" .. row, 100, 7, 0, 0);
	tolua.cast(socketDetail, 'ui::CRichText');
	socketDetail:SetFontName("brown_16_b");
	if itemObj.NeedAppraisal ~= 0 then
		socketDetail:SetText("{s13}"..SocketText.."[??/??] "..PotentialText.."[??/??] "..awakenProp.."{/}");
	else
		socketDetail:SetText("{s13}"..SocketText.."["..nowusesocketcount.."/"..itemObj.MaxSocket.."] "..PotentialText.."["..itemObj.PR.."/"..maxPR.."] "..awakenProp.."{/}");
	end
	socketDetail:Resize(400, 0)
	socketDetail:SetTextAlign(propAlign, "center");
end

--Market names integration
function SHOW_MARKET_NAMES(ctrlSet, marketItem)
	if marketItem == nil then
		return;
	end

	if _G["MARKETNAMES"] == nil then
		return;
	end
	
	local marketName = _G["MARKETNAMES"][marketItem:GetSellerCID()];
	if marketName == nil then
		return;
	end
	
	local buyButton = ctrlSet:GetChild("button_1");

	if buyButton ~= nil then
		buyButton:SetTextTooltip("Buy from " .. marketName.characterName .. " " .. marketName.familyName .. "!");
	end
end

function ON_MARKET_ITEM_LIST_HOOKED(frame, msg, argStr, argNum)
	if frame:IsVisible() == 0 then
		return;
	end

	local itemlist = GET_CHILD(frame, "itemlist", "ui::CDetailListBox");
	itemlist:RemoveAllChild();
	local mySession = session.GetMySession();
	local cid = mySession:GetCID();

	local count = session.market.GetItemCount();
	for i = 0 , count - 1 do
		local marketItem = session.market.GetItemByIndex(i);
		local itemObj = GetIES(marketItem:GetObject());


		local refreshScp = itemObj.RefreshScp;
		if refreshScp ~= "None" then
			refreshScp = _G[refreshScp];
			refreshScp(itemObj);
		end	

		local ctrlSet = INSERT_CONTROLSET_DETAIL_LIST(itemlist, i, 0, "market_item_detail");
		ctrlSet = tolua.cast(ctrlSet, "ui::CControlSet");
		ctrlSet:EnableHitTestSet(1);
		ctrlSet:SetUserValue("DETAIL_ROW", i);

		SET_ITEM_TOOLTIP_ALL_TYPE(ctrlSet, marketItem, itemObj.ClassName, "market", marketItem.itemType, marketItem:GetMarketGuid());

		local pic = GET_CHILD(ctrlSet, "pic", "ui::CPicture");
		local imgName = GET_ITEM_ICON_IMAGE(itemObj);
		pic:SetImage(imgName);

		local name = ctrlSet:GetChild("name");

-- add code start

		local itemLevel = GET_ITEM_LEVEL(itemObj);
		local itemGroup = itemObj.GroupName;

		if itemGroup == "Weapon" or itemGroup == "SubWeapon" or itemGroup == "Armor" then
			name:SetTextByKey("value", GET_FULL_NAME(itemObj));
			if itemObj.NeedAppraisal ~= 0 or itemObj.NeedRandomOption ~= 0 then
				pic:SetColorTone("CC222222");
			end
			if itemObj.ClassType ~= "Hat" then
				GET_SOCKET_POTENSIAL_AWAKEN_PROP(ctrlSet, itemObj, i);
			end
			GET_EQUIP_PROP(ctrlSet, itemObj, i);
		elseif itemGroup == "Gem" or itemGroup == "Card" then
			name:SetTextByKey("value", "Lv".. itemLevel .. ":" .. GET_FULL_NAME(itemObj));
		elseif (itemObj.ClassName == "Scroll_SkillItem") then
			local skillClass = GetClassByType("Skill", itemObj.SkillType);
			name:SetTextByKey("value", "Lv".. itemObj.SkillLevel .. " " .. skillClass.Name .. ":" .. GET_FULL_NAME(itemObj));
		else
			name:SetTextByKey("value", GET_FULL_NAME(itemObj));
		end

-- add code end

		local count = ctrlSet:GetChild("count");
		count:SetTextByKey("value", marketItem.count);
		
		local level = ctrlSet:GetChild("level");
		level:SetTextByKey("value", itemObj.UseLv);

		local price = ctrlSet:GetChild("price");
		price:SetTextByKey("value", GetCommaedText(marketItem.sellPrice));
		price:SetUserValue("Price", marketItem.sellPrice);

		--Marketnames integration
		if (marketItem ~= nil) then
			SHOW_MARKET_NAMES(ctrlSet, marketItem)
		end

		if cid == marketItem:GetSellerCID() then
			local button_1 = ctrlSet:GetChild("button_1");
			button_1:SetEnable(0);

			local btnmargin = 639
			if USE_MARKET_REPORT == 1 then
				local button_report = ctrlSet:GetChild("button_report");
				button_report:SetEnable(0);
				btnmargin = 720
			end

			local btn = ctrlSet:CreateControl("button", "DETAIL_ITEM_" .. i, btnmargin, 8, 100, 50);
			btn = tolua.cast(btn, "ui::CButton");
			btn:ShowWindow(1);
			btn:SetText("{@st41b}" .. ClMsg("Cancel"));
			btn:SetTextAlign("center", "center");

			if notUseAnim ~= true then
				btn:SetAnimation("MouseOnAnim", "btn_mouseover");
				btn:SetAnimation("MouseOffAnim", "btn_mouseoff");
			end
			btn:UseOrifaceRectTextpack(true)
			btn:SetEventScript(ui.LBUTTONUP, "CANCEL_MARKET_ITEM");
			btn:SetEventScriptArgString(ui.LBUTTONUP,marketItem:GetMarketGuid());
			btn:SetSkinName("test_pvp_btn");
			local totalPrice = ctrlSet:GetChild("totalPrice");
			totalPrice:SetTextByKey("value", 0);
		else
			local btnmargin = 639
			if USE_MARKET_REPORT == 1 then
				btnmargin = 560
			end
			local numUpDown = ctrlSet:CreateControl("numupdown", "DETAIL_ITEM_" .. i, btnmargin, 20, 100, 30);
			numUpDown = tolua.cast(numUpDown, "ui::CNumUpDown");
			numUpDown:SetFontName("white_18_ol");
			numUpDown:MakeButtons("btn_numdown", "btn_numup", "editbox");
			numUpDown:ShowWindow(1);
			numUpDown:SetMaxValue(marketItem.count);
			numUpDown:SetMinValue(1);
			numUpDown:SetNumChangeScp("MARKET_CHANGE_COUNT");
			numUpDown:SetClickSound('button_click_chat');
			numUpDown:SetNumberValue(1)

			local totalPrice = ctrlSet:GetChild("totalPrice");
				totalPrice:SetTextByKey("value", GetCommaedText(marketItem.sellPrice));
				totalPrice:SetUserValue("Price", marketItem.sellPrice);
		end		
	end

	itemlist:RealignItems();
	GBOX_AUTO_ALIGN(itemlist, 10, 0, 0, false, true);

	local maxPage = math.ceil(session.market.GetTotalCount() / MARKET_ITEM_PER_PAGE);
	local curPage = session.market.GetCurPage();
	local pagecontrol = GET_CHILD(frame, 'pagecontrol', 'ui::CPageController')
	if maxPage < 1 then
		maxPage = 1;
	end

	pagecontrol:SetMaxPage(maxPage);
	pagecontrol:SetCurPage(curPage);

	if nil ~= argNum and  argNum == 1 then
		MARGET_FIND_PAGE(frame, session.market.GetCurPage());
	end
end
