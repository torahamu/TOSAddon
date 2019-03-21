CHAT_SYSTEM("MARKET SHOW LEVEL v3.1.0 loaded!");

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
		oldflg=true; --表示を古くするか
		flg=false; --どこかの設定があれば、trueになる
		hairFlg=false; --どこかの設定があれば、trueになる
		hairTypeFlg=false; --どこかの設定があれば、trueになる
		andFlg=false;
		filter = {
			PATK=false;
			ADD_MATK=false;
			CRTMATK=false;
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
		};
		hairTypeFilter = {
			HAT=false;
			HAT_T=false;
			HAT_L=false;
		};
		hairFilter = {
			MHP=false;
			RHP=false;
			MSP=false;
			RSP=false;
			PATK=false;
			ADD_MATK=false;
			ADD_DEF=false;
			ADD_MDEF=false;
			CRTMATK=false;
			CRTATK=false;
			CRTHR=false;
			CRTDR=false;
			BLK=false;
			ADD_HR=false;
			ADD_DR=false;
			ADD_FIRE=false;
			ADD_ICE=false;
			ADD_POISON=false;
			ADD_LIGHTNING=false;
			ADD_EARTH=false;
			ADD_SOUL=false;
			ADD_HOLY=false;
			ADD_DARK=false;
			RES_FIRE=false;
			RES_ICE=false;
			RES_POISON=false;
			RES_LIGHTNING=false;
			RES_EARTH=false;
			RES_SOUL=false;
			RES_HOLY=false;
			RES_DARK=false;
			MSPD=false;
			SR=false;
			SDR=false;
		};
	};
end

local MARKETSHOWLEVEL_MARKET_ITEM_COUNT_PER_PAGE = {
	Weapon = 7,
	Armor = 7,
	Accessory = 7,	
	HairAcc = 7,
	RecipeMaterial = 7,
	Recipe_Detail = 3,
	Default = 11
};

local MARKETSHOWLEVEL_MARKET_ITEM_COUNT_PER_PAGE_OLDLIST = {
	Weapon = 11,
	Armor = 11,
	Accessory = 11,	
	HairAcc = 11,
	RecipeMaterial = 7,
	Recipe_Detail = 3,
	Default = 11
};

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
local newoldText="Simple Equipment List"
local OptionFilterButtonText = "OPTION FILTER"
if option.GetCurrentCountry()=="Japanese" then
	AwakenText="覚醒オプション"
	SocketText="ソケット"
	PotentialText="ポテンシャル"
	newoldText="装備を簡易リストにする"
end

-- Hat prop Name and Max Values
local propList = {};
propList.MHP           = {name = "ＨＰ";ename =  "MaxHP"   ;max = 2283;};
propList.RHP           = {name = "HP回";ename =  "HP Rec"  ;max = 56;};
propList.MSP           = {name = "ＳＰ";ename =  "Max SP"  ;max = 450;};
propList.RSP           = {name = "SP回";ename =  "SP Rec"  ;max = 42;};
propList.PATK          = {name = "物攻";ename =  "P.Atk"   ;max = 126;};
propList.ADD_MATK      = {name = "魔攻";ename =  "M.Atk"   ;max = 126;};
propList.ADD_DEF       = {name = "物防";ename =  "P.Def"   ;max = 110;};
propList.ADD_MDEF      = {name = "魔防";ename =  "M.Def"   ;max = 110;};
propList.CRTMATK       = {name = "ｸﾘ魔";ename =  "CritMatk";max = 126;};
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

-- Random Option Name
local randomList = {};
randomList.PATK           = {name = "物攻"          ;ename = "P.Atk"        ;default = ClMsg(PATK)          ;};
randomList.ADD_MATK       = {name = "魔攻"          ;ename = "M.Atk"        ;default = ClMsg(MATK)          ;};
randomList.CRTMATK        = {name = "クリ魔"        ;ename = "M.Amp"        ;default = ClMsg(CRTMATK)       ;};
randomList.ADD_FIRE       = {name = "炎攻"          ;ename = "FireAtk"      ;default = ClMsg(ADD_FIRE)      ;};
randomList.ADD_ICE        = {name = "氷攻"          ;ename = "IceAtk"       ;default = ClMsg(ADD_ICE)       ;};
randomList.ADD_SOUL       = {name = "霊攻"          ;ename = "GhostAtk"     ;default = ClMsg(ADD_SOUL)      ;};
randomList.ADD_POISON     = {name = "毒攻"          ;ename = "PsnAtk"       ;default = ClMsg(ADD_POISON)    ;};
randomList.ADD_LIGHTNING  = {name = "雷攻"          ;ename = "LgtAtk"       ;default = ClMsg(ADD_LIGHTNING) ;};
randomList.ADD_EARTH      = {name = "地攻"          ;ename = "EarthAtk"     ;default = ClMsg(ADD_EARTH)     ;};
randomList.ADD_HOLY       = {name = "聖攻"          ;ename = "HolyAtk"      ;default = ClMsg(ADD_HOLY)      ;};
randomList.ADD_DARK       = {name = "闇攻"          ;ename = "DarkAtk"      ;default = ClMsg(ADD_DARK)      ;};
randomList.CRTATK         = {name = "クリ攻"        ;ename = "CritAtk"      ;default = ClMsg(CRTATK)        ;};
randomList.ADD_CLOTH      = {name = "クロース攻"    ;ename = "ClothAtk"     ;default = ClMsg(ADD_CLOTH)     ;};
randomList.ADD_LEATHER    = {name = "レザー攻"      ;ename = "LeatherAtk"   ;default = ClMsg(ADD_LEATHER)   ;};
randomList.ADD_IRON       = {name = "プレート攻"    ;ename = "PlateAtk"     ;default = ClMsg(ADD_IRON)      ;};
randomList.ADD_GHOST      = {name = "アストラル攻"  ;ename = "GhostAtk"     ;default = ClMsg(ADD_GHOST)     ;};
randomList.ADD_FORESTER   = {name = "植物攻"        ;ename = "PlantAtk"     ;default = ClMsg(ADD_FORESTER)  ;};
randomList.ADD_WIDLING    = {name = "野獣攻"        ;ename = "BeastAtk"     ;default = ClMsg(ADD_WIDLING)   ;};
randomList.ADD_VELIAS     = {name = "悪魔攻"        ;ename = "DevilAtk"     ;default = ClMsg(ADD_VELIAS)    ;};
randomList.ADD_PARAMUNE   = {name = "変異攻"        ;ename = "MutantAtk"    ;default = ClMsg(ADD_PARAMUNE)  ;};
randomList.ADD_KLAIDA     = {name = "昆虫攻"        ;ename = "InsectAtk"    ;default = ClMsg(ADD_KLAIDA)    ;};
randomList.ADD_SMALLSIZE  = {name = "小サイズ攻"    ;ename = "SmallSizeAtk" ;default = ClMsg(ADD_SMALLSIZE) ;};
randomList.ADD_MIDDLESIZE = {name = "中サイズ攻"    ;ename = "MiddleSizeAtk";default = ClMsg(ADD_MIDDLESIZE);};
randomList.ADD_LARGESIZE  = {name = "大サイズ攻"    ;ename = "LargeSizeAtk" ;default = ClMsg(ADD_LARGESIZE) ;};
randomList.ADD_DEF        = {name = "物防"          ;ename = "P.Def"        ;default = ClMsg(ADD_DEF)       ;};
randomList.ADD_MDEF       = {name = "魔防"          ;ename = "M.Def"        ;default = ClMsg(ADD_MDEF)      ;};
randomList.AriesDEF       = {name = "突防"          ;ename = "PierceDef"    ;default = ClMsg(AriesDEF)      ;};
randomList.SlashDEF       = {name = "斬防"          ;ename = "SlashDef"     ;default = ClMsg(SlashDEF)      ;};
randomList.StrikeDEF      = {name = "打撃防"        ;ename = "StrikeDef"    ;default = ClMsg(StrikeDEF)     ;};
randomList.RES_FIRE       = {name = "炎防"          ;ename = "FireRes"      ;default = ClMsg(RES_FIRE)      ;};
randomList.RES_ICE        = {name = "氷防"          ;ename = "IceRes"       ;default = ClMsg(RES_ICE)       ;};
randomList.RES_SOUL       = {name = "霊防"          ;ename = "GhostRes"     ;default = ClMsg(RES_SOUL)      ;}; 
randomList.RES_POISON     = {name = "毒防"          ;ename = "PsnRes"       ;default = ClMsg(RES_POISON)    ;};
randomList.RES_LIGHTNING  = {name = "雷防"          ;ename = "LgtRes"       ;default = ClMsg(RES_LIGHTNING) ;};
randomList.RES_EARTH      = {name = "地防"          ;ename = "EarthRes"     ;default = ClMsg(RES_EARTH)     ;};
randomList.RES_HOLY       = {name = "聖防"          ;ename = "HolyRes"      ;default = ClMsg(RES_HOLY)      ;};
randomList.RES_DARK       = {name = "闇防"          ;ename = "DarkRes"      ;default = ClMsg(RES_DARK)      ;};
randomList.CRTDR          = {name = "クリ抵"        ;ename = "CritDef"      ;default = ClMsg(CRTDR)         ;};
randomList.ADD_HR         = {name = "命中"          ;ename = "Acc"          ;default = ClMsg(ADD_HR)        ;};
randomList.ADD_DR         = {name = "回避"          ;ename = "Eva"          ;default = ClMsg(ADD_DR)        ;};
randomList.MSTA           = {name = "スタミナ"      ;ename = "Sta"          ;default = ClMsg(MSTA)          ;};
randomList.MHP            = {name = "HP"            ;ename = "MaxHP"        ;default = ClMsg(MHP)           ;};
randomList.MSP            = {name = "SP"            ;ename = "MaxSP"        ;default = ClMsg(MSP)           ;};
randomList.RHP            = {name = "HP回復"        ;ename = "HP Rec"       ;default = ClMsg(RHP)           ;};
randomList.RSP            = {name = "SP回復"        ;ename = "SP Rec"       ;default = ClMsg(RSP)           ;};
randomList.CRTHR          = {name = "クリ発"        ;ename = "CritRate"     ;default = ClMsg(CRTHR)         ;};
randomList.BLK            = {name = "ブロック"      ;ename = "Blk"          ;default = ClMsg(BLK)           ;};
randomList.BLK_BREAK      = {name = "ブロ貫通"      ;ename = "Blk BR"       ;default = ClMsg(BLK_BREAK)     ;};
randomList.LootingChance  = {name = "ルーティング"  ;ename = "Looting"      ;default = ClMsg(LootingChance) ;};
randomList.STR            = {name = "力"            ;ename = "STR"          ;default = ClMsg(STR)           ;};
randomList.CON            = {name = "体力"          ;ename = "CON"          ;default = ClMsg(CON)           ;};
randomList.INT            = {name = "知能"          ;ename = "INT"          ;default = ClMsg(INT)           ;};
randomList.MNA            = {name = "精神"          ;ename = "SPR"          ;default = ClMsg(MNA)           ;};
randomList.DEX            = {name = "敏捷"          ;ename = "DEX"          ;default = ClMsg(DEX)           ;};

function MARKETSHOWLEVEL_ON_INIT(addon, frame)
	frame:ShowWindow(0);
	-- 元関数封印
	-- marketnamesでも同じ箇所にHOOKしているので、毎ロード時実行

	if nil == MARKETSHOWLEVEL_ON_MARKET_ITEM_LIST_OLD then
		MARKETSHOWLEVEL_ON_MARKET_ITEM_LIST_OLD = ON_MARKET_ITEM_LIST;
		ON_MARKET_ITEM_LIST = MARKETSHOWLEVEL_ON_MARKET_ITEM_LIST_HOOKED;
	end
	if nil == MARKETSHOWLEVEL_MARKET_DRAW_CTRLSET_DEFAULT_OLD then
		MARKETSHOWLEVEL_MARKET_DRAW_CTRLSET_DEFAULT_OLD = MARKET_DRAW_CTRLSET_DEFAULT;
		MARKET_DRAW_CTRLSET_DEFAULT = MARKETSHOWLEVEL_MARKET_DRAW_CTRLSET_DEFAULT_HOOKED;
	end
	if nil == MARKETSHOWLEVEL_MARKET_DRAW_CTRLSET_EQUIP_OLD then
		MARKETSHOWLEVEL_MARKET_DRAW_CTRLSET_EQUIP_OLD = MARKET_DRAW_CTRLSET_EQUIP;
		MARKET_DRAW_CTRLSET_EQUIP = MARKETSHOWLEVEL_MARKET_DRAW_CTRLSET_EQUIP_HOOKED;
	end
	if nil == MARKETSHOWLEVEL_MARKET_DRAW_CTRLSET_RECIPE_OLD then
		MARKETSHOWLEVEL_MARKET_DRAW_CTRLSET_RECIPE_OLD = MARKET_DRAW_CTRLSET_RECIPE;
		MARKET_DRAW_CTRLSET_RECIPE = MARKETSHOWLEVEL_MARKET_DRAW_CTRLSET_RECIPE_HOOKED;
	end
	if nil == MARKETSHOWLEVEL_MARKET_DRAW_CTRLSET_RECIPE_SEARCHLIST_OLD then
		MARKETSHOWLEVEL_MARKET_DRAW_CTRLSET_RECIPE_SEARCHLIST_OLD = MARKET_DRAW_CTRLSET_RECIPE_SEARCHLIST;
		MARKET_DRAW_CTRLSET_RECIPE_SEARCHLIST = MARKETSHOWLEVEL_MARKET_DRAW_CTRLSET_RECIPE_SEARCHLIST_HOOKED;
	end
	if nil == MARKETSHOWLEVEL_MARKET_DRAW_CTRLSET_ACCESSORY_OLD then
		MARKETSHOWLEVEL_MARKET_DRAW_CTRLSET_ACCESSORY_OLD = MARKET_DRAW_CTRLSET_ACCESSORY;
		MARKET_DRAW_CTRLSET_ACCESSORY = MARKETSHOWLEVEL_MARKET_DRAW_CTRLSET_ACCESSORY_HOOKED;
	end
	if nil == MARKETSHOWLEVEL_MARKET_DRAW_CTRLSET_GEM_OLD then
		MARKETSHOWLEVEL_MARKET_DRAW_CTRLSET_GEM_OLD = MARKET_DRAW_CTRLSET_GEM;
		MARKET_DRAW_CTRLSET_GEM = MARKETSHOWLEVEL_MARKET_DRAW_CTRLSET_GEM_HOOKED;
	end
	if nil == MARKETSHOWLEVEL_MARKET_DRAW_CTRLSET_CARD_OLD then
		MARKETSHOWLEVEL_MARKET_DRAW_CTRLSET_CARD_OLD = MARKET_DRAW_CTRLSET_CARD;
		MARKET_DRAW_CTRLSET_CARD = MARKETSHOWLEVEL_MARKET_DRAW_CTRLSET_CARD_HOOKED;
	end
	if nil == MARKETSHOWLEVEL_MARKET_DRAW_CTRLSET_EXPORB_OLD then
		MARKETSHOWLEVEL_MARKET_DRAW_CTRLSET_EXPORB_OLD = MARKET_DRAW_CTRLSET_EXPORB;
		MARKET_DRAW_CTRLSET_EXPORB = MARKETSHOWLEVEL_MARKET_DRAW_CTRLSET_EXPORB_HOOKED;
	end

	if nil == MARKETSHOWLEVEL_GET_MARKET_SEARCH_ITEM_COUNT_OLD then
		MARKETSHOWLEVEL_GET_MARKET_SEARCH_ITEM_COUNT_OLD = GET_MARKET_SEARCH_ITEM_COUNT;
		GET_MARKET_SEARCH_ITEM_COUNT = MARKETSHOWLEVEL_GET_MARKET_SEARCH_ITEM_COUNT_HOOKED;
	end

	if nil == MARKETSHOWLEVEL_DRAW_DETAIL_CATEGORY_OLD then
		MARKETSHOWLEVEL_DRAW_DETAIL_CATEGORY_OLD = DRAW_DETAIL_CATEGORY;
		DRAW_DETAIL_CATEGORY = MARKETSHOWLEVEL_DRAW_DETAIL_CATEGORY_HOOKED;
	end

	if nil == MARKETSHOWLEVEL_MARKET_FIND_PAGE_OLD then
		MARKETSHOWLEVEL_MARKET_FIND_PAGE_OLD = MARKET_FIND_PAGE;
		MARKET_FIND_PAGE = MARKETSHOWLEVEL_MARKET_FIND_PAGE_HOOKED;
	end

	--if nil == MARKETSHOWLEVEL_MARKET_TRY_SAVE_CATEGORY_OPTION_OLD then
	--	MARKETSHOWLEVEL_MARKET_TRY_SAVE_CATEGORY_OPTION_OLD = MARKET_TRY_SAVE_CATEGORY_OPTION;
	--	MARKET_TRY_SAVE_CATEGORY_OPTION = MARKETSHOWLEVEL_MARKET_TRY_SAVE_CATEGORY_OPTION_HOOKED;
	--end

	--if nil == MARKETSHOWLEVEL_MARKET_TRY_LOAD_CATEGORY_OPTION_OLD then
	--	MARKETSHOWLEVEL_MARKET_TRY_LOAD_CATEGORY_OPTION_OLD = MARKET_TRY_LOAD_CATEGORY_OPTION;
	--	MARKET_TRY_LOAD_CATEGORY_OPTION = MARKETSHOWLEVEL_MARKET_TRY_LOAD_CATEGORY_OPTION_HOOKED;
	--end

	if nil == MARKETSHOWLEVEL_EASYSEARCH_INV_RBTN_OLD and nil ~= EASYSEARCH_INV_RBTN then
		MARKETSHOWLEVEL_EASYSEARCH_INV_RBTN_OLD = EASYSEARCH_INV_RBTN;
		EASYSEARCH_INV_RBTN = MARKETSHOWLEVEL_EASYSEARCH_INV_RBTN_HOOKED;
	end

	-- イベント登録
	acutil.setupEvent(addon, "ON_OPEN_MARKET", "MARKETSHOWLEVEL_ON_OPEN_MARKET");
	g.loaded = true;
end

function MARKETSHOWLEVEL_ON_OPEN_MARKET(frame, msg)
	MARKETSHOWLEVEL_CREATE_NEWOLD_CHECK();
	MARKETSHOWLEVEL_CREATE_DETAIL_BOX();
end

function MARKETSHOWLEVEL_CREATE_NEWOLD_CHECK()
	local frame = ui.GetFrame("market")
	local newoldCheck = frame:CreateOrGetControl("checkbox", "marketshowlevel_check_newold", 620, 55, 250, 35);
	tolua.cast(newoldCheck, "ui::CCheckBox");
	newoldCheck:SetClickSound("button_click_big");
	newoldCheck:SetAnimation("MouseOnAnim",  "btn_mouseover");
	newoldCheck:SetAnimation("MouseOffAnim", "btn_mouseoff");
	newoldCheck:SetOverSound("button_over");
	newoldCheck:SetEventScript(ui.LBUTTONUP, "MARKETSHOWLEVEL_NEWOLD_FLG");
	newoldCheck:SetFontName("white_16_ol");
	newoldCheck:SetText(newoldText);
	if g.settings.oldflg then
		newoldCheck:SetCheck(1);
	else
		newoldCheck:SetCheck(0);
	end
end

function MARKETSHOWLEVEL_CREATE_DETAIL_BOX()
	local frame = ui.GetFrame("market")
	local marketCategory = GET_CHILD_RECURSIVELY(frame, 'marketCategory');
	local detailBox = frame:CreateOrGetControl('groupbox', 'detailOption', 10, 727, marketCategory:GetWidth(), 255);
	AUTO_CAST(detailBox);
	detailBox:SetSkinName('test_frame_midle_light');
	detailBox:EnableScrollBar(0);
	local ypos = 0;
	ypos = MARKETSHOWLEVEL_ADD_ITEM_PRICEORDER(detailBox, ypos);
	--ypos = MARKETSHOWLEVEL_ADD_OPTION_BUTTON(detailBox, ypos);
	ypos = MARKETSHOWLEVEL_ADD_LEVEL_RANGE(detailBox, ypos);
	ypos = MARKETSHOWLEVEL_ADD_ITEM_GRADE(detailBox, ypos);
	ypos = MARKETSHOWLEVEL_ADD_ITEM_SEARCH(detailBox, ypos);
	ypos = MARKETSHOWLEVEL_ADD_SEARCH_COMMIT(detailBox, ypos)

	local bgBox = GET_CHILD_RECURSIVELY(marketCategory, 'bgBox');
	local cateBox = GET_CHILD_RECURSIVELY(marketCategory, 'cateBox');
	local cateListBox = GET_CHILD_RECURSIVELY(marketCategory, 'cateListBox');
	local margin = 10;
	marketCategory:Resize(marketCategory:GetWidth(),marketCategory:GetOriginalHeight()-detailBox:GetHeight()-margin)
	bgBox:Resize(bgBox:GetWidth(),bgBox:GetOriginalHeight()-detailBox:GetHeight()-margin)
	cateBox:Resize(cateBox:GetWidth(),cateBox:GetOriginalHeight()-detailBox:GetHeight()-margin)
	cateListBox:Resize(cateListBox:GetWidth(),cateListBox:GetOriginalHeight()-detailBox:GetHeight()-margin)
end

function MARKETSHOWLEVEL_ADD_ITEM_PRICEORDER(detailBox, ypos)
	local gbox = detailBox:CreateOrGetControl('groupbox', 'priceorder', 0, ypos, detailBox:GetWidth(), 40);
	AUTO_CAST(gbox);
	gbox:SetSkinName('none');
	local priceOrderAsc = gbox:CreateOrGetControl('radiobutton', 'priceOrderAsc', 15, 8, 120, 30);
	tolua.cast(priceOrderAsc, "ui::CRadioButton");
	priceOrderAsc:SetFontName("brown_16_b")
	priceOrderAsc:SetText(ClMsg("ALIGN_ITEM_TYPE_2"))
	priceOrderAsc:SetGroupID("priceOrder");
	local priceOrderDesc = gbox:CreateOrGetControl('radiobutton', 'priceOrderDesc', 170, 8, 120, 30);
	tolua.cast(priceOrderDesc, "ui::CRadioButton");
	priceOrderDesc:SetFontName("brown_16_b")
	priceOrderDesc:SetText(ClMsg("ALIGN_ITEM_TYPE_1"))
	priceOrderDesc:AddToGroup(priceOrderAsc);
	priceOrderAsc:Select();
	priceOrderAsc:SetEventScript(ui.LBUTTONUP, "MARKETSHOWLEVEL_PRICEORDER");
	priceOrderDesc:SetEventScript(ui.LBUTTONUP, "MARKETSHOWLEVEL_PRICEORDER");
	return ypos + gbox:GetHeight();
end

function MARKETSHOWLEVEL_ADD_OPTION_BUTTON(detailBox, ypos)
	local gbox = detailBox:CreateOrGetControl('groupbox', 'optionarea', 0, ypos, detailBox:GetWidth(), 40);
	AUTO_CAST(gbox);
	gbox:SetSkinName('none');
	local button_option = gbox:CreateOrGetControl("button", "marketoptionbutton", detailBox:GetWidth()/2-150/2, 0, 150, 30);
	tolua.cast(button_option, "ui::CButton");
	button_option:SetFontName("white_16_ol");
	button_option:SetText("Search Option");
	button_option:SetClickSound("button_click");
	button_option:SetOverSound("button_cursor_over_2");
	button_option:SetAnimation("MouseOnAnim", "btn_mouseover");
	button_option:SetAnimation("MouseOffAnim", "btn_mouseoff");
	button_option:SetEventScript(ui.LBUTTONDOWN, "MARKETSHOWLEVEL_SHOW_OPTION");
	return ypos + gbox:GetHeight();
end

function MARKETSHOWLEVEL_SHOW_OPTION(parent, ctrl)
	local frame = ui.GetFrame("market");
	local optionBox = GET_CHILD_RECURSIVELY(frame, 'optionBox');
	optionBox:ShowWindow(1);

	local optionSaveBox = GET_CHILD(optionBox, 'optionSaveBox');
	optionSaveBox:ShowWindow(0);

	local optionLoadBox = GET_CHILD(optionBox, 'optionLoadBox');	
	optionLoadBox:ShowWindow(0);

	local parentCategory = frame:GetUserValue('SELECTED_CATEGORY');
	--local subCategory = frame:GetUserValue('SELECTED_SUB_CATEGORY');
	
	local optionOptionBox = optionBox:CreateOrGetControl('groupbox', 'optionOptionBox', 0, 0, 450, 300);
	AUTO_CAST(optionOptionBox);
	optionOptionBox:SetSkinName('none');

	local pic = optionOptionBox:CreateOrGetControl('picture', 'option_titletextline', 7, 15, 450, 40);
	tolua.cast(pic, 'ui::CPicture');
	pic:SetImage("test_com_namebg");

	local picText = pic:CreateOrGetControl("richtext", "titletext", 10, 0, 120, 24);
	tolua.cast(picText, 'ui::CRichText');
	picText:SetFontName("black_20");
	picText:SetText("option");
	picText:SetTextAlign("center", "center");

	local ypos = 40

	local optiondetailarea = optionBox:CreateOrGetControl('groupbox', 'optiondetailarea', 0, ypos, optionBox:GetWidth(), 40);
	AUTO_CAST(optiondetailarea);
	optiondetailarea:SetSkinName('none');

	ypos = MARKETSHOWLEVEL_ADD_LEVEL_RANGE(optiondetailarea, ypos, parentCategory);
	ypos = MARKETSHOWLEVEL_ADD_ITEM_GRADE(optiondetailarea, ypos, parentCategory);
	ypos = MARKETSHOWLEVEL_ADD_APPRAISAL_OPTION(optiondetailarea, ypos, parentCategory);
	ypos = MARKETSHOWLEVEL_ADD_DETAIL_OPTION_SETTING(optiondetailarea, ypos, parentCategory, true);
	ypos = MARKETSHOWLEVEL_ADD_GEM_OPTION(optiondetailarea, ypos, parentCategory);
	
	optiondetailarea:Resize(optionBox:GetWidth(), ypos);
	optionOptionBox:Resize(optionBox:GetWidth(), ypos);

end

--function MARKETSHOWLEVEL_MARKET_TRY_SAVE_CATEGORY_OPTION_HOOKED(parent, ctrl)
--	local frame = ui.GetFrame("market");
--	local optionBox = GET_CHILD_RECURSIVELY(frame, 'optionBox');
--	local optionOptionBox = GET_CHILD(optionBox, 'optionOptionBox');
--	if nil ~= optionOptionBox then
--		optionOptionBox:ShowWindow(0);
--	end
--	optionBox:Resize(optionBox:GetOriginalWidth(), optionBox:GetOriginalHeight());
--	return MARKETSHOWLEVEL_MARKET_TRY_SAVE_CATEGORY_OPTION_OLD(parent, ctrl)
--end

--function MARKETSHOWLEVEL_MARKET_TRY_LOAD_CATEGORY_OPTION_HOOKED(parent, ctrl)
--	local frame = ui.GetFrame("market");
--	local optionBox = GET_CHILD_RECURSIVELY(frame, 'optionBox');
--	local optionOptionBox = GET_CHILD(optionBox, 'optionOptionBox');
--	if nil ~= optionOptionBox then
--		optionOptionBox:ShowWindow(0);
--	end
--	optionBox:Resize(optionBox:GetOriginalWidth(), optionBox:GetOriginalHeight());
--	return MARKETSHOWLEVEL_MARKET_TRY_LOAD_CATEGORY_OPTION_OLD(parent, ctrl);
--end

function MARKETSHOWLEVEL_EASYSEARCH_INV_RBTN_HOOKED(itemObj)
	local frame = ui.GetFrame("market");
	local detailBox = GET_CHILD_RECURSIVELY(frame, 'detailOption');
	local market_search = GET_CHILD_RECURSIVELY(detailBox, 'itemSearchSet');
	local searchEdit = GET_CHILD_RECURSIVELY(market_search, 'searchEdit');
	local name = dictionary.ReplaceDicIDInCompStr(itemObj.Name);
	searchEdit:SetText(name);
	MARKET_FIND_PAGE(frame);
end

function MARKETSHOWLEVEL_PRICEORDER(parent, ctrl)
	local marketframe = ui.GetFrame("market");
	MARKET_FIND_PAGE(marketframe, session.market.GetCurPage());
end

function MARKETSHOWLEVEL_ADD_LEVEL_RANGE(detailBox, ypos, parentCategory)
	if parentCategory ~= 'Weapon' and parentCategory ~= 'Accessory' and parentCategory ~= 'Armor' and parentCategory ~= 'Recipe' and parentCategory ~= 'OPTMisc' then
		return ypos;
	end

	local market_level = detailBox:CreateOrGetControlSet('market_level', 'levelRangeSet', 0, ypos);
	local minEdit = GET_CHILD_RECURSIVELY(market_level, 'minEdit');
	local maxEdit = GET_CHILD_RECURSIVELY(market_level, 'maxEdit');
	minEdit:SetText('');
	maxEdit:SetText('');
	ypos = ypos + market_level:GetHeight();
	return ypos;
end

function MARKETSHOWLEVEL_ADD_ITEM_GRADE(detailBox, ypos, parentCategory)
	if parentCategory ~= 'Weapon' and parentCategory ~= 'Accessory' and parentCategory ~= 'Armor' and parentCategory ~= 'Recipe' then
		return ypos;
	end

	local market_grade = detailBox:CreateOrGetControlSet('market_grade', 'gradeCheckSet', 0, ypos);
	ypos = ypos + market_grade:GetHeight();
	return ypos;
end

function MARKETSHOWLEVEL_ADD_ITEM_SEARCH(detailBox, ypos)
	local market_search = detailBox:CreateOrGetControlSet('market_search', 'itemSearchSet', 0, ypos);
	market_search:RemoveChild('priceOrderCheck_0');
	market_search:RemoveChild('priceOrderCheck_1');
	market_search:Resize(market_search:GetWidth(),market_search:GetOriginalHeight()-35)
	local staticText = GET_CHILD_RECURSIVELY(market_search, 'staticText');
	staticText:SetOffset(staticText:GetOriginalX(),staticText:GetOriginalY()-35)
	local cateListBox2 = GET_CHILD_RECURSIVELY(market_search, 'cateListBox2');
	cateListBox2:SetOffset(cateListBox2:GetOriginalX(),cateListBox2:GetOriginalY()-35)
	ypos = ypos + market_search:GetHeight();
	return ypos;
end

function MARKETSHOWLEVEL_ADD_APPRAISAL_OPTION(detailBox, ypos, parentCategory)
	if parentCategory ~= 'Weapon' and parentCategory ~= 'Accessory' and parentCategory ~= 'Armor' then
		return ypos;
	end

	local market_appraisal = detailBox:CreateOrGetControlSet('market_appraisal', 'appCheckSet', 0, ypos);
	ypos = ypos + market_appraisal:GetHeight();
	return ypos;
end

function MARKETSHOWLEVEL_ADD_DETAIL_OPTION_SETTING(detailBox, ypos, parentCategory, forceOpen)
	if parentCategory ~= 'Weapon' and parentCategory ~= 'Accessory' and parentCategory ~= 'Armor' and parentCategory ~= 'Recipe' and parentCategory ~= 'HairAcc' then
		return ypos;
	end

	if parentCategory ~= 'HairAcc' and parentCategory ~= 'Recipe' then
		local market_detail_setting = detailBox:CreateOrGetControlSet('market_detail_setting', 'detailOptionSet', 0, ypos);
		if forceOpen ~= true then
			MARKET_ADD_SEARCH_DETAIL_SETTING(market_detail_setting, nil, true);
		end
		ypos = ypos + market_detail_setting:GetHeight();
	end

	local market_option_group = detailBox:CreateOrGetControlSet('market_option_group', 'optionGroupSet', 0, ypos);
	if forceOpen ~= true then
		MARKET_ADD_SEARCH_OPTION_GROUP(market_option_group, nil, true);
	end
	ypos = ypos + market_option_group:GetHeight();
	return ypos;
end

function MARKETSHOWLEVEL_ADD_SEARCH_COMMIT(detailBox, ypos, parentCategory)	
	local market_commit = detailBox:CreateOrGetControlSet('market_commit', 'commitSet', 0, ypos);
	ypos = ypos + market_commit:GetHeight();
	return ypos;
end

function MARKETSHOWLEVEL_ADD_GEM_OPTION(detailBox, ypos, parentCategory)
	if parentCategory ~= 'Gem' and parentCategory ~= 'Card' then
		return ypos;
	end

	local market_gem_option = detailBox:CreateOrGetControlSet('market_gem_option', 'gemOptionSet', 0, ypos);
	local levelMinEdit = GET_CHILD_RECURSIVELY(market_gem_option, 'levelMinEdit');
	local levelMaxEdit = GET_CHILD_RECURSIVELY(market_gem_option, 'levelMaxEdit');
	levelMinEdit:SetText('');
	levelMaxEdit:SetText('');

	local roastingMinEdit = GET_CHILD_RECURSIVELY(market_gem_option, 'roastingMinEdit');
	local roastingMaxEdit = GET_CHILD_RECURSIVELY(market_gem_option, 'roastingMaxEdit');
	roastingMinEdit:SetText('');
	roastingMaxEdit:SetText('');

	if parentCategory == 'Card' then
		market_gem_option:Resize(market_gem_option:GetWidth(), 40);
	end
	ypos = ypos + market_gem_option:GetHeight();
	return ypos;
end

function MARKETSHOWLEVEL_ADD_SEARCH_COMMIT(detailBox, ypos)
	local market_commit = detailBox:CreateOrGetControlSet('market_commit', 'commitSet', 0, ypos);
	ypos = ypos + market_commit:GetHeight();
	return ypos;
end

function MARKETSHOWLEVEL_NEWOLD_FLG(frame, ctrl, argStr, argNum)
	local marketframe = ui.GetFrame("market");
	if ctrl:IsChecked() == 1 then
		g.settings.oldflg = true;
	else
		g.settings.oldflg = false;
	end
	MARKET_FIND_PAGE(marketframe, session.market.GetCurPage());
end

function MARKETSHOWLEVEL_CLAMP_MARKET_PAGE_NUMBER(frame, pageControllerName, page)
	if page == nil then
		return 0;
	end
	local pagecontrol = GET_CHILD(frame, pageControllerName);	
	local MaxPage = pagecontrol:GetMaxPage();	
	if page >= MaxPage then
		page = MaxPage - 1;
	elseif page <= 0 then
		page = 0;
	end
	return page;
end

function MARKETSHOWLEVEL_MARKET_FIND_PAGE_HOOKED(frame, page)
	local detailBox = GET_CHILD_RECURSIVELY(frame, "detailOption");

	page = MARKETSHOWLEVEL_CLAMP_MARKET_PAGE_NUMBER(frame, 'pagecontrol', page);
	local orderByDesc = MARKETSHOWLEVEL_GET_SEARCH_PRICE_ORDER(detailBox);
	if orderByDesc < 0 then
		return;
	end
	local searchText = MARKETSHOWLEVEL_GET_SEARCH_TEXT(detailBox);
	local category, _category, _subCategory = GET_CATEGORY_STRING(frame);	
	--if category == '' and searchText == '' then
	--	return;
	--end

	if searchText ~= '' and ui.GetPaperLength(searchText) < 2 then
		ui.SysMsg(ClMsg('InvalidFindItemQueryMin'));
		return;
	end

	local optionKey, optionValue = MARKETSHOWLEVEL_GET_SEARCH_OPTION(frame);
	local itemCntPerPage = GET_MARKET_SEARCH_ITEM_COUNT(_category);		
	MarketSearch(page + 1, orderByDesc, searchText, category, optionKey, optionValue, itemCntPerPage);
	DISABLE_BUTTON_DOUBLECLICK_WITH_CHILD(frame:GetName(), 'commitSet', 'searchBtn', 1);
	MARKET_OPTION_BOX_CLOSE_CLICK(frame);
end

function MARKETSHOWLEVEL_GET_SEARCH_PRICE_ORDER(detailBox)
	local gbox = GET_CHILD_RECURSIVELY(detailBox, "priceorder");
	local priceOrderAsc = GET_CHILD_RECURSIVELY(gbox, 'priceOrderAsc');
	local priceOrderDesc = GET_CHILD_RECURSIVELY(gbox, 'priceOrderDesc');
	tolua.cast(priceOrderAsc, "ui::CRadioButton");
	tolua.cast(priceOrderDesc, "ui::CRadioButton");

	if priceOrderAsc:IsChecked() == 1 then
		return 0;
	end
	if priceOrderDesc:IsChecked() == 1 then
		return 1;
	end
	return 0; -- default
end

function MARKETSHOWLEVEL_GET_SEARCH_TEXT(detailBox)
	local defaultValue = '';
	local market_search = GET_CHILD_RECURSIVELY(detailBox, 'itemSearchSet');
	if market_search ~= nil and market_search:IsVisible() == 1 then
		local searchEdit = GET_CHILD_RECURSIVELY(market_search, 'searchEdit');
		local findItem = searchEdit:GetText();
		local minLength = 0;
		local findItemStrLength = findItem.len(findItem);
		local maxLength = 60;
		if config.GetServiceNation() == "GLOBAL" then
			minLength = 1;
			maxLength = 20;
		elseif config.GetServiceNation() == "JPN" then
			maxLength = 60;
		elseif config.GetServiceNation() == "KOR" then
			maxLength = 60;
		end
		if findItemStrLength ~= 0 then	-- 있다면 길이 조건 체크
			if findItemStrLength <= minLength then
				ui.SysMsg(ClMsg("InvalidFindItemQueryMin"));
				return defaultValue;
			elseif findItemStrLength > maxLength then
				ui.SysMsg(ClMsg("InvalidFindItemQueryMax"));
				return defaultValue;
	        end
	    end 
	    return findItem;
	end
	return defaultValue;
end

function MARKETSHOWLEVEL_DRAW_DETAIL_CATEGORY_HOOKED(frame, selectedCtrlset, subCategoryList, forceOpen)
	local parentCategory = selectedCtrlset:GetUserValue('CATEGORY');
	local cateListBox = selectedCtrlset:GetParent();
	local detailBox = cateListBox:CreateControl('groupbox', 'detailBox', 5, 0, selectedCtrlset:GetWidth() - 20, 0);
	AUTO_CAST(detailBox);
	detailBox:SetSkinName('None');
	detailBox:EnableScrollBar(0);

	if parentCategory == 'IntegrateRetreive' then
		detailBox:Resize(detailBox:GetWidth(), 0);
		return detailBox;
	end

	local ypos = MARKETSHOWLEVEL_ADD_SUB_CATEGORY(detailBox, parentCategory, subCategoryList);
	ypos = MARKETSHOWLEVEL_ADD_LEVEL_RANGE(detailBox, ypos, parentCategory);
	ypos = MARKETSHOWLEVEL_ADD_ITEM_GRADE(detailBox, ypos, parentCategory);
	ypos = MARKETSHOWLEVEL_ADD_APPRAISAL_OPTION(detailBox, ypos, parentCategory);
	ypos = MARKETSHOWLEVEL_ADD_DETAIL_OPTION_SETTING(detailBox, ypos, parentCategory, forceOpen);
	ypos = MARKETSHOWLEVEL_ADD_GEM_OPTION(detailBox, ypos, parentCategory);

	detailBox:Resize(detailBox:GetWidth(), ypos);
	return detailBox;
end

function GET_HAT_PROP(itemObj,ctrlSet)
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
	if obj.ClassType == "Hat" then
		return ""
	end
	local randomInfo = "";

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
			if randomList[obj[propName]] ~= nil then
				prop = randomList[obj[propName]].ename;
				if option.GetCurrentCountry()=="Japanese" then
					prop = randomList[obj[propName]].name;
				end
			else
				prop = ScpArgMsg(obj[propName]);
			end

			local opName = string.format("%s %s", ClMsg(clientMessage), prop);
			local info = string.format("%s " .. "%d", opName, math.abs(obj[propValue]))
			randomInfo = randomInfo..info
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
	local prop = GET_HAT_PROP(itemObj,ctrlSet);
	local randomInfo = GET_INFO_RANDOM(itemObj,ctrlSet)

	local propDetail = ctrlSet:CreateControl("richtext", "PROP_ITEM_" .. row, 70, 42, 0, 0);
	tolua.cast(propDetail, 'ui::CRichText');
	propDetail:SetFontName("brown_16_b");
	if #randomInfo > 0 then
		randomInfo = randomInfo.." ";
	end

	local charScale = "{s12}";
	if option.GetCurrentCountry()=="Japanese" then
		charScale = "{s14}";
	end

	-- Hat don't have random options.
	if itemObj.ClassType == "Hat" then
		propDetail:SetText(charScale..prop.."{/}");
	else
		propDetail:SetText(charScale..randomInfo.."{/}");
	end
	propDetail:Resize(100, propDetail:GetY()-12)
	propDetail:SetTextAlign(propAlign, "top");
end

function GET_SOCKET_POTENSIAL_AWAKEN_PROP(ctrlSet, itemObj, row)
	local awakenProp = "";

	if itemObj.IsAwaken == 1 then
		awakenProp = "{#3300FF}{b}"..AwakenText.."["..propList[itemObj.HiddenProp].name.. " "..itemObj.HiddenPropValue.."]{/}{/}";
	end

	local socketDetail = ctrlSet:CreateControl("richtext", "SOCKTE_ITEM_" .. row, 70, 7, 0, 0);
	tolua.cast(socketDetail, 'ui::CRichText');
	socketDetail:SetFontName("brown_16_b");
	socketDetail:SetText("{s13}"..awakenProp.."{/}");
	socketDetail:Resize(400, 0)
	socketDetail:SetTextAlign(propAlign, "center");
end

function MARKETSHOWLEVEL_ON_MARKET_ITEM_LIST_HOOKED(frame, msg, argStr, argNum)
	MARKETSHOWLEVEL_ON_MARKET_ITEM_LIST_OLD(frame, msg, argStr, argNum);
end

-- OLD関数内で呼ばれているlocal fanctionを移行 (addon.ipf/market/market.lua)
function MARKETSHOWLEVEL_MARKET_CTRLSET_SET_ICON(ctrlSet, itemObj, marketItem)
	local pic = GET_CHILD_RECURSIVELY(ctrlSet, "pic");
	SET_SLOT_ITEM_CLS(pic, itemObj)
	SET_ITEM_TOOLTIP_ALL_TYPE(pic:GetIcon(), marketItem, itemObj.ClassName, "market", marketItem.itemType, marketItem:GetMarketGuid());

    SET_SLOT_STYLESET(pic, itemObj)
    if itemObj.MaxStack > 1 then
		SET_SLOT_COUNT_TEXT(pic, marketItem.count, '{s16}{ol}{b}');
	end
end

-- OLD関数内で呼ばれているlocal fanctionを移行 (addon.ipf/market/market.lua)
function MARKETSHOWLEVEL_MARKET_SET_PAGE_CONTROL(frame, pageControl)
	local category, _category, _subCategory = GET_CATEGORY_STRING(frame);
	local itemCntPerPage = GET_MARKET_SEARCH_ITEM_COUNT(_category);
	local maxPage = math.ceil(session.market.GetTotalCount() / itemCntPerPage);
	local curPage = session.market.GetCurPage();
	local pageController = GET_CHILD(frame, pageControl, 'ui::CPageController')
    if maxPage < 1 then
        maxPage = 1;
    end

	pageController:SetMaxPage(maxPage);
	pageController:SetCurPage(curPage);
end

-- OLD関数内で呼ばれているlocal fanctionを移行 (addon.ipf/market/market.lua)
function MARKETSHOWLEVEL_ADD_SUB_CATEGORY(detailBox, parentCategory, subCategoryList)
	if #subCategoryList < 1 then
		return 0;
	end

	local frame = detailBox:GetTopParentFrame();
	DESTROY_CHILD_BYNAME(detailBox, 'subCateBox');

	-- sort sub category
	if parentCategory == 'HairAcc' then
		subCategoryList = MARKETSHOWLEVEL_SORT_CATEGORY(subCategoryList, function(lhs, rhs)
			return lhs < rhs;
			end);
	end

	local subCateBox = detailBox:CreateControl('groupbox', 'subCateBox', 0, 0, detailBox:GetWidth(), 0);
	AUTO_CAST(subCateBox);
	subCateBox:SetSkinName('None');
	subCateBox:EnableScrollBar(0);
	for i = 0, #subCategoryList do
		local category = subCategoryList[i];		
		if category == nil then
			category = 'ShowAll';
		end
		
		local subCateCtrlset = subCateBox:CreateControl('groupbox', 'SUB_CATE_'..category, 0, 0, detailBox:GetWidth(), 20);
		AUTO_CAST(subCateCtrlset);
		subCateCtrlset:SetSkinName('None');
		subCateCtrlset:SetUserValue('PARENT_CATEGORY', parentCategory);
		subCateCtrlset:SetUserValue('CATEGORY', category);
		subCateCtrlset:SetEventScript(ui.LBUTTONUP, 'MARKET_SUB_CATEOGRY_CLICK');
		subCateCtrlset:EnableScrollBar(0);

		local text = subCateCtrlset:CreateControl('richtext', 'text', 20, 0, 100, 20);
		text:SetGravity(ui.LEFT, ui.CENTER_VERT);
		text:SetFontName('brown_16_b');
		text:SetText(ClMsg(category));
		text:EnableHitTest(0);
	end

	GBOX_AUTO_ALIGN(subCateBox, 2, 2, 0, true, true);
	detailBox:Resize(detailBox:GetWidth(), subCateBox:GetHeight());
	return subCateBox:GetHeight();
end

-- OLD関数内で呼ばれているlocal fanctionを移行 (addon.ipf/market/market.lua)
function MARKETSHOWLEVEL_SORT_CATEGORY(categoryList, sortFunc)
	table.sort(categoryList, sortFunc);
	return categoryList;
end

-- OLD関数内で呼ばれているlocal fanctionを移行 (addon.ipf/market/market.lua)
function MARKETSHOWLEVEL_GET_SEARCH_OPTION(frame)
	local optionName, optionValue = {}, {};
	local optionSet = {}; -- for checking duplicate option
	local category = frame:GetUserValue('SELECTED_CATEGORY');

	-- level range
	local levelRangeSet = GET_CHILD_RECURSIVELY(frame, 'levelRangeSet');
	if levelRangeSet ~= nil and levelRangeSet:IsVisible() == 1 then
		local minEdit = GET_CHILD_RECURSIVELY(levelRangeSet, 'minEdit');
		local maxEdit = GET_CHILD_RECURSIVELY(levelRangeSet, 'maxEdit');
		local opValue = MARKETSHOWLEVEL_GET_MINMAX_QUERY_VALUE_STRING(minEdit, maxEdit);
		if opValue ~= '' then
			local opName = 'CT_UseLv';
			if category == 'OPTMisc' then
				opName = 'Level';
			end
			optionName[#optionName + 1] = opName;
			optionValue[#optionValue + 1] = opValue;
			optionSet[opName] = true;
		end
	end

	-- grade
	local gradeCheckSet = GET_CHILD_RECURSIVELY(frame, 'gradeCheckSet');
	if gradeCheckSet ~= nil and gradeCheckSet:IsVisible() == 1 then
		local checkStr = '';
		local matchCnt, lastMatch = 0, nil;
		local childCnt = gradeCheckSet:GetChildCount();
		for i = 0, childCnt - 1 do
			local child = gradeCheckSet:GetChildByIndex(i);
			if string.find(child:GetName(), 'gradeCheck_') ~= nil then
				AUTO_CAST(child);
				if child:IsChecked() == 1 then
					local grade = string.sub(child:GetName(), string.find(child:GetName(), '_') + 1);
					checkStr = checkStr..grade..';';
					matchCnt = matchCnt + 1;
					lastMatch = grade;
				end
			end
		end
		if checkStr ~= '' then
			if matchCnt == 1 then
				checkStr = checkStr..lastMatch;
			end
			local opName = 'CT_ItemGrade';
			optionName[#optionName + 1] = opName;
			optionValue[#optionValue + 1] = checkStr;
			optionSet[opName] = true;
		end
	end

	-- random option flag
	local appCheckSet = GET_CHILD_RECURSIVELY(frame, 'appCheckSet');
	if appCheckSet ~= nil and appCheckSet:IsVisible() == 1 then
		local ranOpName, ranOpValue;
		local appCheck_0 = GET_CHILD(appCheckSet, 'appCheck_0');
		if appCheck_0:IsChecked() == 1 then
			ranOpName = 'Random_Item';
			ranOpValue = '2'
		end

		local appCheck_1 = GET_CHILD(appCheckSet, 'appCheck_1');
		if appCheck_1:IsChecked() == 1 then
			ranOpName = 'Random_Item';
			ranOpValue = '1'
		end

		if ranOpName ~= nil then
			optionName[#optionName + 1] = ranOpName;
			optionValue[#optionValue + 1] = ranOpValue;
			optionSet[ranOpName] = true;
		end
	end

	-- detail setting
	local detailOptionSet = GET_CHILD_RECURSIVELY(frame, 'detailOptionSet');
	if detailOptionSet ~= nil and detailOptionSet:IsVisible() == 1 then
		local curCnt = detailOptionSet:GetUserIValue('ADD_SELECT_COUNT');
		for i = 0, curCnt do
			local selectSet = GET_CHILD_RECURSIVELY(detailOptionSet, 'SELECT_'..i);
			if selectSet ~= nil and selectSet:IsVisible() == 1 then
				local nameList = GET_CHILD(selectSet, 'groupList');
				local opName = nameList:GetSelItemKey();
				if opName ~= '' then
					local opValue = MARKETSHOWLEVEL_GET_MINMAX_QUERY_VALUE_STRING(GET_CHILD_RECURSIVELY(selectSet, 'minEdit'), GET_CHILD_RECURSIVELY(selectSet, 'maxEdit'));				
					if opValue ~= '' and optionSet[opName] == nil then
						optionName[#optionName + 1] = opName;
						optionValue[#optionValue + 1] = opValue;
						optionSet[opName] = true;
					end
				end
			end
		end
	end

	-- option group
	local optionGroupSet = GET_CHILD_RECURSIVELY(frame, 'optionGroupSet');
	if optionGroupSet ~= nil and optionGroupSet:IsVisible() == 1 then
		local curCnt = optionGroupSet:GetUserIValue('ADD_SELECT_COUNT');		
		for i = 0, curCnt do
			local selectSet = GET_CHILD_RECURSIVELY(optionGroupSet, 'SELECT_'..i);
			if selectSet ~= nil then
				local nameList = GET_CHILD(selectSet, 'nameList');
				local opName = nameList:GetSelItemKey();
				if opName ~= '' then
					local opValue = MARKETSHOWLEVEL_GET_MINMAX_QUERY_VALUE_STRING(GET_CHILD_RECURSIVELY(selectSet, 'minEdit'), GET_CHILD_RECURSIVELY(selectSet, 'maxEdit'));
					if opValue ~= '' and optionSet[opName] == nil then
						optionName[#optionName + 1] = opName;
						optionValue[#optionValue + 1] = opValue;
						optionSet[opName] = true;
					end
				end
			end
		end
	end

	-- gem option
	local gemOptionSet = GET_CHILD_RECURSIVELY(frame, 'gemOptionSet');
	if gemOptionSet ~= nil and gemOptionSet:IsVisible() == 1 then
		local levelMinEdit = GET_CHILD_RECURSIVELY(gemOptionSet, 'levelMinEdit');
		local levelMaxEdit = GET_CHILD_RECURSIVELY(gemOptionSet, 'levelMaxEdit');
		local roastingMinEdit = GET_CHILD_RECURSIVELY(gemOptionSet, 'roastingMinEdit');
		local roastingMaxEdit = GET_CHILD_RECURSIVELY(gemOptionSet, 'roastingMaxEdit');
		if category == 'Gem' then
			local opValue = MARKETSHOWLEVEL_GET_MINMAX_QUERY_VALUE_STRING(levelMinEdit, levelMaxEdit);
			if opValue ~= '' then
				optionName[#optionName + 1] = 'GemLevel';
				optionValue[#optionValue + 1] = opValue;
				optionSet['GemLevel'] = true;
			end

			local roastOpValue = MARKETSHOWLEVEL_GET_MINMAX_QUERY_VALUE_STRING(roastingMinEdit, roastingMaxEdit);			
			if roastOpValue ~= '' then
				optionName[#optionName + 1] = 'GemRoastingLv';
				optionValue[#optionValue + 1] = roastOpValue;
				optionSet['GemRoastingLv'] = true;
			end
		elseif category == 'Card' then
			local opValue = MARKETSHOWLEVEL_GET_MINMAX_QUERY_VALUE_STRING(levelMinEdit, levelMaxEdit);
			if opValue ~= '' then
				optionName[#optionName + 1] = 'CardLevel';
				optionValue[#optionValue + 1] = opValue;
				optionSet['CardLevel'] = true;
			end
		end
	end

	-- 検索何もなしの時はデフォルトで全グレード
	if #optionName == 0 and #optionValue == 0 then
		optionName[#optionName + 1] = "CT_ItemGrade";
		optionValue[#optionValue + 1] = "1;2;3;4;5;";
	end

	return optionName, optionValue;
end

-- OLD関数内で呼ばれているlocal fanctionを移行 (addon.ipf/market/market.lua)
function MARKETSHOWLEVEL_GET_MINMAX_QUERY_VALUE_STRING(minEdit, maxEdit)
	local queryValue = '';
	local minValue = -1000000;
	local maxValue = 1000000;
	local valid = false;
	if minEdit:GetText() ~= nil and minEdit:GetText() ~= '' then
		minValue = tonumber(minEdit:GetText());
		valid = true;
	end
	if maxEdit:GetText() ~= nil and maxEdit:GetText() ~= '' then
		maxValue = tonumber(maxEdit:GetText());
		valid = true;
	end
	
	if valid == false then
		return queryValue;
	end

	queryValue = minValue..';'..maxValue;	
	return queryValue;
end

-- OLD関数内で呼ばれているlocal fanctionを移行 (addon.ipf/market/market.lua)
function MARKETSHOWLEVEL_CREATE_SEAL_OPTION(ctrlSet, itemObj)
	if TryGetProp(itemObj, 'GroupName') ~= 'Seal' then
		return;
	end

	for i = 1, itemObj.MaxReinforceCount do
		local option = TryGetProp(itemObj, 'SealOption_'..i, 'None');
		if option == 'None' then
			break;
		end		
		local strInfo = GET_OPTION_VALUE_OR_PERCECNT_STRING(option, itemObj['SealOptionValue_'..i]);
		SET_MARKET_EQUIP_CTRLSET_OPTION_TEXT(ctrlSet, strInfo);
	end
end

function MARKETSHOWLEVEL_MARKET_DRAW_CTRLSET_DEFAULT_HOOKED(frame, isShowLevel)
	MARKETSHOWLEVEL_MARKET_DRAW_CTRLSET_DEFAULT_OLD(frame, isShowLevel);
end

function MARKETSHOWLEVEL_MARKET_DRAW_CTRLSET_EQUIP_HOOKED(frame, isShowSocket)
	if g.settings.oldflg then
		MARKETSHOWLEVEL_MARKET_ITEM_OLDLIST(frame, isShowSocket)
	else
		MARKETSHOWLEVEL_MARKET_DRAW_CTRLSET_EQUIP_OLD(frame, isShowSocket);
	end
end

function MARKETSHOWLEVEL_MARKET_DRAW_CTRLSET_RECIPE_HOOKED(frame)
	MARKETSHOWLEVEL_MARKET_DRAW_CTRLSET_RECIPE_OLD(frame);
end

function MARKETSHOWLEVEL_MARKET_DRAW_CTRLSET_RECIPE_SEARCHLIST_HOOKED(frame)
	MARKETSHOWLEVEL_MARKET_DRAW_CTRLSET_RECIPE_SEARCHLIST_OLD(frame);
end

function MARKETSHOWLEVEL_MARKET_DRAW_CTRLSET_ACCESSORY_HOOKED(frame)
	MARKETSHOWLEVEL_MARKET_DRAW_CTRLSET_ACCESSORY_OLD(frame);
end

function MARKETSHOWLEVEL_MARKET_DRAW_CTRLSET_GEM_HOOKED(frame)
	MARKETSHOWLEVEL_MARKET_DRAW_CTRLSET_GEM_NEWFRAME(frame);
end

function MARKETSHOWLEVEL_MARKET_DRAW_CTRLSET_CARD_HOOKED(frame)
	MARKETSHOWLEVEL_MARKET_DRAW_CTRLSET_CARD_NEWFRAME(frame);
end

function MARKETSHOWLEVEL_MARKET_DRAW_CTRLSET_EXPORB_HOOKED(frame)
	MARKETSHOWLEVEL_MARKET_DRAW_CTRLSET_EXPORB_OLD(frame);
end

function MARKETSHOWLEVEL_MARKET_DRAW_CTRLSET_CARD_NEWFRAME(frame)
	local itemlist = GET_CHILD_RECURSIVELY(frame, "itemListGbox");
	itemlist:RemoveAllChild();
	local mySession = session.GetMySession();
	local cid = mySession:GetCID();
	local count = session.market.GetItemCount();

	MARKET_SELECT_SHOW_TITLE(frame, "cardTitle")

	local yPos = 0
	for i = 0 , count - 1 do
		local marketItem = session.market.GetItemByIndex(i);
		local itemObj = GetIES(marketItem:GetObject());
		local refreshScp = itemObj.RefreshScp;
		if refreshScp ~= "None" then
			refreshScp = _G[refreshScp];
			refreshScp(itemObj);
		end	

		local ctrlSet = nil;
		if itemObj.GroupName ~= 'Card' then
			ctrlSet = itemlist:CreateOrGetControlSet("market_item_detail_default", "ITEM_EQUIP_" .. i, ui.LEFT, ui.TOP, 0, 0, 0, yPos);
		else
			ctrlSet = itemlist:CreateOrGetControlSet("market_item_detail_card", "ITEM_EQUIP_" .. i, ui.LEFT, ui.TOP, 0, 0, 0, yPos);
		end
		AUTO_CAST(ctrlSet)
		ctrlSet:SetUserValue("DETAIL_ROW", i);

		MARKETSHOWLEVEL_MARKET_CTRLSET_SET_ICON(ctrlSet, itemObj, marketItem);

		local name = ctrlSet:GetChild("name");
		name:SetTextByKey("value", GET_FULL_NAME(itemObj));

		local lvText = itemObj.Level;
		local level = GET_CHILD_RECURSIVELY(ctrlSet, "level")
		level:SetTextByKey("value", lvText);

		if itemObj.GroupName == 'Card' then
			local option = GET_CHILD_RECURSIVELY(ctrlSet, "option")

			local tempText1 = itemObj.Desc;
			if itemObj.Desc == "None" then
				tempText1 = "";
			end

			local textDesc = string.format("%s", tempText1)	
			option:SetTextByKey("value", textDesc);
		else
			MARKET_CTRLSET_SET_PRICE(ctrlSet, marketItem, cid);
		end

		if cid == marketItem:GetSellerCID() then
			local buyBtn = GET_CHILD_RECURSIVELY(ctrlSet, "buyBtn");
			buyBtn:ShowWindow(0)
			buyBtn:SetEnable(0);
			local cancelBtn = GET_CHILD_RECURSIVELY(ctrlSet, "cancelBtn");
			cancelBtn:ShowWindow(1)
			cancelBtn:SetEnable(1)

			if USE_MARKET_REPORT == 1 then
				local reportBtn = ctrlSet:GetChild("reportBtn");
				reportBtn:SetEnable(0);
			end

			local totalPrice_num = ctrlSet:GetChild("totalPrice_num");
			totalPrice_num:SetTextByKey("value", 0);
			local totalPrice_text = ctrlSet:GetChild("totalPrice_text");
			totalPrice_text:SetTextByKey("value", 0);
		else

			local buyBtn = GET_CHILD_RECURSIVELY(ctrlSet, "buyBtn");
			buyBtn:ShowWindow(1)
			buyBtn:SetEnable(1);
			local cancelBtn = GET_CHILD_RECURSIVELY(ctrlSet, "cancelBtn");
			cancelBtn:ShowWindow(0)
			cancelBtn:SetEnable(0)

			if itemObj.GroupName ~= 'Card' then
				local editCount = GET_CHILD_RECURSIVELY(ctrlSet, "count")
				editCount:SetMinNumber(1)
				editCount:SetMaxNumber(marketItem.count)
				editCount:SetText("1")
				editCount:SetNumChangeScp("MARKET_CHANGE_COUNT");
				ctrlSet:SetUserValue("minItemCount", 1)
				ctrlSet:SetUserValue("maxItemCount", marketItem.count)
			end

			MARKET_CTRLSET_SET_TOTAL_PRICE(ctrlSet, marketItem);
		end		

		ctrlSet:SetUserValue("sellPrice", marketItem:GetSellPrice());
	end

	local ITEM_CTRLSET_INTERVAL_Y_MARGIN = tonumber(frame:GetUserConfig('ITEM_CTRLSET_INTERVAL_Y_MARGIN'));
	GBOX_AUTO_ALIGN(itemlist, 4, ITEM_CTRLSET_INTERVAL_Y_MARGIN, 0, false, true);

	MARKETSHOWLEVEL_MARKET_SET_PAGE_CONTROL(frame, "pagecontrol")
end

function MARKETSHOWLEVEL_MARKET_DRAW_CTRLSET_GEM_NEWFRAME(frame)
	--SAME CARD UI
	
	local itemlist = GET_CHILD_RECURSIVELY(frame, "itemListGbox");
	itemlist:RemoveAllChild();
	local mySession = session.GetMySession();
	local cid = mySession:GetCID();
	local count = session.market.GetItemCount();

	MARKET_SELECT_SHOW_TITLE(frame, "cardTitle")

	local yPos = 0
	for i = 0 , count - 1 do
		local marketItem = session.market.GetItemByIndex(i);
		local itemObj = GetIES(marketItem:GetObject());
		local refreshScp = itemObj.RefreshScp;
		if refreshScp ~= "None" then
			refreshScp = _G[refreshScp];
			refreshScp(itemObj);
		end	

		local ctrlSet = itemlist:CreateControlSet("market_item_detail_card", "ITEM_EQUIP_" .. i, ui.LEFT, ui.TOP, 0, 0, 0, yPos);
		AUTO_CAST(ctrlSet)
		ctrlSet:SetUserValue("DETAIL_ROW", i);

		MARKETSHOWLEVEL_MARKET_CTRLSET_SET_ICON(ctrlSet, itemObj, marketItem);

		local name = ctrlSet:GetChild("name");
		name:SetTextByKey("value", GET_FULL_NAME(itemObj));

		local level = GET_CHILD_RECURSIVELY(ctrlSet, "level")
		local gemLevelValue = GET_ITEM_LEVEL_EXP(itemObj)
		level:SetTextByKey("value", gemLevelValue)

		local option = GET_CHILD_RECURSIVELY(ctrlSet, "option")

		-- Monster Jem
		local tempText1 = "";
		if itemObj["EquipXpGroup"] == "Gem_Skill" then
			local gemSkill = string.sub(itemObj["ClassName"],5);
			local skillClass = GetClass("Skill", gemSkill);

			local equipList = StringSplit(itemObj["EnableEquipParts"], "/");
			local equipPos = "";
			local sep = "/";
			for equipIndex = 1 , #equipList do
				if equipIndex == #equipList then
					sep = "";
				end
				if equipList[equipIndex] == "TopLeg" then
					equipPos = equipPos .. ClMsg("Shirt").. "/";
					equipPos = equipPos .. ClMsg("Pants").. sep;
				elseif equipList[equipIndex] == "Hand" then
					equipPos = equipPos .. ClMsg("Gloves").. sep;
				elseif equipList[equipIndex] == "Foot" then
					equipPos = equipPos .. ClMsg("Boots").. sep;
				else
					equipPos = equipPos .. ClMsg(equipList[equipIndex]).. sep;
				end
			end
			tempText1 = "Skill:{#FFFFFF}{ol}"..skillClass.Name.."{/}{/}  Equip:{#FFFFFF}{ol}["..equipPos.."]{/}{/}";
		end

		local textDesc = string.format("%s", tempText1)	
		option:SetTextByKey("value", textDesc);

		if cid == marketItem:GetSellerCID() then
			local buyBtn = GET_CHILD_RECURSIVELY(ctrlSet, "buyBtn");
			buyBtn:ShowWindow(0)
			buyBtn:SetEnable(0);
			local cancelBtn = GET_CHILD_RECURSIVELY(ctrlSet, "cancelBtn");
			cancelBtn:ShowWindow(1)
			cancelBtn:SetEnable(1)

			if USE_MARKET_REPORT == 1 then
				local reportBtn = ctrlSet:GetChild("reportBtn");
				reportBtn:SetEnable(0);
			end

			local totalPrice_num = ctrlSet:GetChild("totalPrice_num");
			totalPrice_num:SetTextByKey("value", 0);
			local totalPrice_text = ctrlSet:GetChild("totalPrice_text");
			totalPrice_text:SetTextByKey("value", 0);
		else

			local buyBtn = GET_CHILD_RECURSIVELY(ctrlSet, "buyBtn");
			buyBtn:ShowWindow(1)
			buyBtn:SetEnable(1);
			local cancelBtn = GET_CHILD_RECURSIVELY(ctrlSet, "cancelBtn");
			cancelBtn:ShowWindow(0)
			cancelBtn:SetEnable(0)

			MARKET_CTRLSET_SET_TOTAL_PRICE(ctrlSet, marketItem);

		end

		ctrlSet:SetUserValue("sellPrice", marketItem:GetSellPrice());
	end


	local ITEM_CTRLSET_INTERVAL_Y_MARGIN = tonumber(frame:GetUserConfig('ITEM_CTRLSET_INTERVAL_Y_MARGIN'));
	GBOX_AUTO_ALIGN(itemlist, 4, ITEM_CTRLSET_INTERVAL_Y_MARGIN, 0, false, true);

	MARKETSHOWLEVEL_MARKET_SET_PAGE_CONTROL(frame, "pagecontrol")
end


function MARKETSHOWLEVEL_MARKET_ITEM_OLDLIST(frame)
	local itemlist = GET_CHILD_RECURSIVELY(frame, "itemListGbox");
	itemlist:RemoveAllChild();
	local mySession = session.GetMySession();
	local cid = mySession:GetCID();
	local count = session.market.GetItemCount();

	MARKET_SELECT_SHOW_TITLE(frame, "equipTitle")
	--local tempTitleGbox = GET_CHILD_RECURSIVELY(frame, "equipTitle")
	--local equipTitle_stats = GET_CHILD_RECURSIVELY(tempTitleGbox, "equipTitle_stats")
	--equipTitle_stats:ShowWindow(0)
	--local equipTitle_level = GET_CHILD_RECURSIVELY(tempTitleGbox, "equipTitle_level")
	--equipTitle_level:SetOffset(equipTitle_level:GetOriginalX() + 100, equipTitle_level:GetOriginalY());

	local yPos = 0
	for i = 0 , count - 1 do
		local marketItem = session.market.GetItemByIndex(i);
		local itemObj = GetIES(marketItem:GetObject());
		local refreshScp = itemObj.RefreshScp;
		if refreshScp ~= "None" then
			refreshScp = _G[refreshScp];
			refreshScp(itemObj);
		end

		local ctrlSet = itemlist:CreateControlSet("market_item_detail_equip", "ITEM_EQUIP_" .. i, ui.LEFT, ui.TOP, 0, 0, 0, yPos);
		AUTO_CAST(ctrlSet)
		ctrlSet:SetUserValue("DETAIL_ROW", i);
		ctrlSet:SetUserValue("optionIndex", 0)
		ctrlSet:Resize(ctrlSet:GetWidth(), 66)

		local inheritanceItem = GetClass('Item', itemObj.InheritanceItemName)
		MARKETSHOWLEVEL_MARKET_CTRLSET_SET_ICON(ctrlSet, itemObj, marketItem);

		local name = GET_CHILD_RECURSIVELY(ctrlSet, "name");
		name:SetTextByKey("value", "{s16}"..GET_FULL_NAME(itemObj).."{/}");
		name:Resize(280, name:GetHeight());
		name:EnableTextOmitByWidth(1);

		local level = GET_CHILD_RECURSIVELY(ctrlSet, "level");
		level:SetTextByKey("value", itemObj.UseLv);
		--level:SetOffset(level:GetX() + 110, level:GetY()-20);

		--ATK, MATK, DEF 
		--local atkdef = GET_CHILD_RECURSIVELY(ctrlSet, "atkdef");
		--atkdef:SetTextByKey("value", "");
		--ctrlSet:RemoveChild("atkdef")
		--ATK, MATK, DEF 
		local atkdefImageSize = ctrlSet:GetUserConfig("ATKDEF_IMAGE_SIZE")
 		local basicProp = 'None';
 		local atkdefText = "";
    	if itemObj.BasicTooltipProp ~= 'None' then
    		local basicTooltipPropList = StringSplit(itemObj.BasicTooltipProp, ';');
    	    for i = 1, #basicTooltipPropList do
    	        basicProp = basicTooltipPropList[i];
    	        if basicProp == 'ATK' then
				    typeiconname = 'test_sword_icon'
					typestring = ScpArgMsg("Melee_Atk")
					if TryGetProp(itemObj, 'EquipGroup') == "SubWeapon" then
						typestring = ScpArgMsg("PATK_SUB")
					end
					arg1 = itemObj.MINATK;
					arg2 = itemObj.MAXATK;
				elseif basicProp == 'MATK' then
				    typeiconname = 'test_sword_icon'
					typestring = ScpArgMsg("Magic_Atk")
					arg1 = itemObj.MATK;
					arg2 = itemObj.MATK;
				else
					typeiconname = 'test_shield_icon'
					typestring = ScpArgMsg(basicProp);
					if itemObj.RefreshScp ~= 'None' then
						local scp = _G[itemObj.RefreshScp];
						if scp ~= nil then
							scp(itemObj);
						end
					end
					
					arg1 = TryGetProp(itemObj, basicProp);
					arg2 = TryGetProp(itemObj, basicProp);
				end

				local tempStr = string.format("{img %s %d %d}", typeiconname, atkdefImageSize, atkdefImageSize)
				local tempATKDEF = ""
				if arg1 == arg2 or arg2 == 0 then
					tempATKDEF = " " .. arg1
				else
					tempATKDEF = " " .. arg1 .. "~" .. arg2
				end

				if i == 1 then
					atkdefText = atkdefText .. tempStr .. typestring .. tempATKDEF
				else
					atkdefText = atkdefText .. "{nl}" .. tempStr .. typestring .. tempATKDEF
				end
    	    end
   		end
   		

    	local atkdef = GET_CHILD_RECURSIVELY(ctrlSet, "atkdef");
		atkdef:SetTextByKey("value", atkdefText);

		--SOCKET

		local socket = GET_CHILD_RECURSIVELY(ctrlSet, "socket")
		
		local needAppraisal = TryGetProp(itemObj, "NeedAppraisal");
		local needRandomOption = TryGetProp(itemObj, "NeedRandomOption");
			local maxSocketCount = itemObj.MaxSocket
			local drawFlag = 0
			if maxSocketCount > 3 then
				drawFlag = 1
			end

			local curCount = 1
			local socketText = ""
			local tempStr = ""
			for i = 0, maxSocketCount - 1 do
				if marketItem:IsAvailableSocket(i) == true then
					
					local isEquip = marketItem:GetEquipGemID(i);
					if isEquip == 0 then
						tempStr = ctrlSet:GetUserConfig("SOCKET_IMAGE_EMPTY")
						if drawFlag == 1 and curCount % 2 == 1 then
							socketText = socketText .. tempStr
						else
							socketText = socketText .. tempStr .. "{nl}"
						end
					else
						local gemClass = GetClassByType("Item", isEquip);
						if gemClass.ClassName == 'gem_circle_1' then
							tempStr = ctrlSet:GetUserConfig("SOCKET_IMAGE_RED")
						elseif gemClass.ClassName == 'gem_square_1' then
							tempStr = ctrlSet:GetUserConfig("SOCKET_IMAGE_BLUE")
						elseif gemClass.ClassName == 'gem_diamond_1' then
							tempStr = ctrlSet:GetUserConfig("SOCKET_IMAGE_GREEN")
						elseif gemClass.ClassName == 'gem_star_1' then
							tempStr = ctrlSet:GetUserConfig("SOCKET_IMAGE_YELLOW")
						elseif gemClass.ClassName == 'gem_White_1' then
							tempStr = ctrlSet:GetUserConfig("SOCKET_IMAGE_WHITE")
						elseif gemClass.EquipXpGroup == "Gem_Skill" then
							tempStr = ctrlSet:GetUserConfig("SOCKET_IMAGE_MONSTER")
						end
						
						local gemLv = GET_ITEM_LEVEL_EXP(gemClass, marketItem:GetEquipGemExp(i));
						tempStr = tempStr .. "Lv" .. gemLv

						if drawFlag == 1 and curCount % 2 == 1 then
							socketText = socketText .. tempStr
						else
							socketText = socketText .. tempStr .. "{nl}"
						end
					end									
				end
				curCount = curCount + 1
			end
			socket:SetTextByKey("value", socketText)

		-- POTENTIAL

		local potential = GET_CHILD_RECURSIVELY(ctrlSet, "potential");
		if needAppraisal == 1 then
			potential:SetTextByKey("value1", "?")
			potential:SetTextByKey("value2", "?")			
		else
			potential:SetTextByKey("value1", itemObj.PR)
			potential:SetTextByKey("value2", itemObj.MaxPR)
		end

		-- OPTION
		if itemObj.ClassType ~= "Hat" then
			GET_SOCKET_POTENSIAL_AWAKEN_PROP(ctrlSet, itemObj, i);
		end
		GET_EQUIP_PROP(ctrlSet, itemObj, i);

		MARKETSHOWLEVEL_CREATE_SEAL_OPTION(ctrlSet, itemObj);

		-- 내 판매리스트 처리

		if cid == marketItem:GetSellerCID() then
			local buyBtn = GET_CHILD_RECURSIVELY(ctrlSet, "buyBtn");
			buyBtn:ShowWindow(0)
			buyBtn:SetEnable(0);
			local cancelBtn = GET_CHILD_RECURSIVELY(ctrlSet, "cancelBtn");
			cancelBtn:ShowWindow(1)
			cancelBtn:SetEnable(1)

			if USE_MARKET_REPORT == 1 then
				local reportBtn = GET_CHILD_RECURSIVELY(ctrlSet, "reportBtn");
				reportBtn:SetEnable(0);
			end

			local totalPrice_num = GET_CHILD_RECURSIVELY(ctrlSet, "totalPrice_num");
			totalPrice_num:SetTextByKey("value", 0);
			local totalPrice_text = GET_CHILD_RECURSIVELY(ctrlSet, "totalPrice_text");
			totalPrice_text:SetTextByKey("value", 0);
		else

			local buyBtn = GET_CHILD_RECURSIVELY(ctrlSet, "buyBtn");
			buyBtn:ShowWindow(1)
			buyBtn:SetEnable(1);
			local cancelBtn = GET_CHILD_RECURSIVELY(ctrlSet, "cancelBtn");
			cancelBtn:ShowWindow(0)
			cancelBtn:SetEnable(0)

			MARKET_CTRLSET_SET_TOTAL_PRICE(ctrlSet, marketItem);
			
		end		

		ctrlSet:SetUserValue("sellPrice", marketItem:GetSellPrice());
	end

	local ITEM_CTRLSET_INTERVAL_Y_MARGIN = tonumber(frame:GetUserConfig('ITEM_CTRLSET_INTERVAL_Y_MARGIN'));
	GBOX_AUTO_ALIGN(itemlist, 4, ITEM_CTRLSET_INTERVAL_Y_MARGIN, 0, true, false);

	MARKETSHOWLEVEL_MARKET_SET_PAGE_CONTROL(frame, "pagecontrol")
end

function MARKETSHOWLEVEL_GET_MARKET_SEARCH_ITEM_COUNT_HOOKED(category)
	if MARKETSHOWLEVEL_MARKET_ITEM_COUNT_PER_PAGE[category] == nil then
		return MARKETSHOWLEVEL_MARKET_ITEM_COUNT_PER_PAGE['Default'];
	end
	if g.settings.oldflg then
		return MARKETSHOWLEVEL_MARKET_ITEM_COUNT_PER_PAGE_OLDLIST[category];
	else
		return MARKETSHOWLEVEL_MARKET_ITEM_COUNT_PER_PAGE[category];
	end
end
