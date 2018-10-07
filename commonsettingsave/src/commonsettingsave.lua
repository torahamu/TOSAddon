--アドオン名（大文字）
local addonName = "COMMONSETTINGSAVE";
local addonNameLower = string.lower(addonName);
--作者名
local author = "torahamu";

--アドオン内で使用する領域を作成。以下、ファイル内のスコープではグローバル変数gでアクセス可
_G["ADDONS"] = _G["ADDONS"] or {};
_G["ADDONS"][author] = _G["ADDONS"][author] or {};
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {};
local g = _G["ADDONS"][author][addonName];
g.settings = {}
g.settings.config = {}
g.settings.load = false

--設定ファイル保存先
g.settingsDirLoc = string.format("../addons/%s", addonNameLower);
g.settingsFileLoc = string.format("%s/settings.json", g.settingsDirLoc);

local acutil = require('acutil');
local readFlg = false

function COMMONSETTINGSAVE_ON_INIT(addon, frame)
	if nil == COMMONSETTINGSAVE_SYS_OPTION_CLOSE_OLD then
		COMMONSETTINGSAVE_SYS_OPTION_CLOSE_OLD = SYS_OPTION_CLOSE;
		SYS_OPTION_CLOSE = COMMONSETTINGSAVE_SYS_OPTION_CLOSE;
	end
	if nil == COMMONSETTINGSAVE_APPS_TRY_LEAVE_OLD then
		COMMONSETTINGSAVE_APPS_TRY_LEAVE_OLD = APPS_TRY_LEAVE;
		APPS_TRY_LEAVE = COMMONSETTINGSAVE_APPS_TRY_LEAVE;
	end

	if readFlg then
	else
		local t, err = acutil.loadJSON(g.settingsFileLoc);
		-- 読み込めない = ファイルがない
		if err then
		else
			-- 読み込めたら読み込んだ値使う
			g.settings.config = t;
			g.settings.load = true;
			COMMONSETTINGSAVE_LOAD()
			COMMONSETTINGSAVE_LOAD_UI()
		end
		readFlg = true;
	end

end

function COMMONSETTINGSAVE_SYS_OPTION_CLOSE()
	if g.settings.load then
		-- 設定ファイルとかあるなら共通セーブにもセーブ
		COMMONSETTINGSAVE_SAVE()
	else
		-- 初回時は確認する
		local yesscp = "COMMONSETTINGSAVE_SAVE()";
		local country=string.lower(option.GetCurrentCountry());
		local msg = ""
		if country=="japanese" then
			msg = "このゲーム設定を全キャラクターで統一しますか？{nl}今後はどのキャラクターでゲーム設定を変更しても全キャラクター変更されます。"
		else
			msg = "Do you want all characters to unify this game setting?{nl}All characters will be changed in any future character setting even if you change the game setting."
		end
		ui.MsgBox(msg, yesscp, "None")
	end
end

function COMMONSETTINGSAVE_SAVE()
	COMMONSETTINGSAVE_SAVE_GAME()
	COMMONSETTINGSAVE_SAVE_UI()
	COMMONSETTINGSAVE_SAVE_PVP()
	COMMONSETTINGSAVE_SAVE_PERFORMANCE()
	COMMONSETTINGSAVE_SAVE_GRAPHIC()
	g.settings.load = true
	acutil.saveJSON(g.settingsFileLoc, g.settings.config);
end

function COMMONSETTINGSAVE_SAVE_GAME()
	-- Game Config
	g.settings.config.ViewCharInfoBase = config.GetXMLConfig("ViewCharInfoBase");
	g.settings.config.HideGivenName = config.GetXMLConfig("HideGivenName");
	g.settings.config.ShowPartyName = config.GetXMLConfig("ShowPartyName");
	g.settings.config.ShowOtherPCName = config.GetXMLConfig("ShowOtherPCName");
	g.settings.config.ShowHpSpGauge = config.GetXMLConfig("ShowHpSpGauge");
	g.settings.config.JoyPadVibration = config.GetXMLConfig("JoyPadVibration");
	g.settings.config.PumpRecipe = config.GetXMLConfig("PumpRecipe");
	g.settings.config.ShowDropItemName = config.GetXMLConfig("ShowDropItemName");
	g.settings.config.SklCtrlSpd = config.GetSklCtrlSpd()
	g.settings.config.EnableAutoCellSelect = config.GetXMLConfig("EnableAutoCellSelect");
	g.settings.config.ShowCurrentGetVis = config.GetXMLConfig("ShowCurrentGetVis");
	g.settings.config.ShowCurrentGetExp = config.GetXMLConfig("ShowCurrentGetExp");
	g.settings.config.ShowSummonedMonName = config.GetXMLConfig("ShowSummonedMonName");
	g.settings.config.AutoCellSelectSpd = config.GetAutoCellSelectSpd()
end

function COMMONSETTINGSAVE_SAVE_UI()
	--UI Config
	g.settings.config.ControlMode = config.GetXMLConfig("ControlMode");
end

function COMMONSETTINGSAVE_SAVE_PVP()
	--PVP Config
	g.settings.config.DmgFontScale = config.GetDmgFontScale()
	g.settings.config.EnableShowPadSkillRange = config.IsEnableShowPadSkillRange()
	g.settings.config.EnableSimplifyBuffEffects = config.IsEnableSimplifyBuffEffects()
	g.settings.config.EnableSimplifyModel = config.IsEnableSimplifyModel();
end

function COMMONSETTINGSAVE_SAVE_PERFORMANCE()
	g.settings.config.AutoAdjustLowLevel = config.GetAutoAdjustLowLevel()
	g.settings.config.ShowPerformanceValue = config.GetXMLConfig("ShowPerformanceValue")
	g.settings.config.EnableOtherFluting = config.IsEnableOtherFluting()
end

function COMMONSETTINGSAVE_SAVE_GRAPHIC()
	g.settings.config.EnableBloom = config.GetXMLConfig("EnableBloom");
	g.settings.config.EnableSoftParticle = config.GetXMLConfig("EnableSoftParticle");
	g.settings.config.EnableOtherPCEffect = config.GetXMLConfig("EnableOtherPCEffect");
	g.settings.config.EnableDeadParts = config.GetXMLConfig("EnableDeadParts");
	g.settings.config.UseCamShockWave = config.GetXMLConfig("UseCamShockWave");
	g.settings.config.UseItemDropEffect = config.GetXMLConfig("UseItemDropEffect");
	g.settings.config.EnableRenderShadow = config.GetXMLConfig("EnableRenderShadow");
	g.settings.config.EnableFXAA = config.GetXMLConfig("EnableFXAA");
	g.settings.config.EnableHighTexture = config.GetXMLConfig("EnableHighTexture");
	g.settings.config.EnableNaturalEffect = config.GetXMLConfig("EnableNaturalEffect");
	g.settings.config.EnableCharSilhouette = config.GetXMLConfig("EnableCharSilhouette");
	g.settings.config.EnableOtherPCDamageEffect = config.GetXMLConfig("EnableOtherPCDamageEffect");
	g.settings.config.EnableHitGlow = config.GetXMLConfig("EnableHitGlow");
end

function COMMONSETTINGSAVE_LOAD()
	COMMONSETTINGSAVE_LOAD_XML("ViewCharInfoBase")
	COMMONSETTINGSAVE_LOAD_XML("HideGivenName")
	COMMONSETTINGSAVE_LOAD_XML("ShowPartyName")
	COMMONSETTINGSAVE_LOAD_XML("ShowOtherPCName")
	COMMONSETTINGSAVE_LOAD_XML("ShowHpSpGauge")
	COMMONSETTINGSAVE_LOAD_XML("JoyPadVibration")
	COMMONSETTINGSAVE_LOAD_XML("PumpRecipe")
	COMMONSETTINGSAVE_LOAD_XML("ShowDropItemName")
	config.SetSklCtrlSpd(g.settings.config.SklCtrlSpd)
	COMMONSETTINGSAVE_LOAD_XML("EnableAutoCellSelect")
	COMMONSETTINGSAVE_LOAD_XML("ShowCurrentGetVis")
	COMMONSETTINGSAVE_LOAD_XML("ShowCurrentGetExp")
	COMMONSETTINGSAVE_LOAD_XML("ShowSummonedMonName")
	config.SetAutoCellSelectSpd(g.settings.config.AutoCellSelectSpd)
	COMMONSETTINGSAVE_LOAD_XML("ControlMode")
	config.SetDmgFontScale(g.settings.config.DmgFontScale)
	config.SetEnableShowPadSkillRange(g.settings.config.EnableShowPadSkillRange)
	config.SetEnableSimplifyBuffEffects(g.settings.config.EnableSimplifyBuffEffects)
	config.SetEnableSimplifyModel(g.settings.config.EnableSimplifyModel)
	config.SetAutoAdjustLowLevel(g.settings.config.AutoAdjustLowLevel)
	config.EnableOtherFluting(g.settings.config.EnableOtherFluting);
	COMMONSETTINGSAVE_LOAD_XML("ShowPerformanceValue")
	COMMONSETTINGSAVE_LOAD_XML("EnableBloom")
	COMMONSETTINGSAVE_LOAD_XML("EnableSoftParticle")
	COMMONSETTINGSAVE_LOAD_XML("EnableOtherPCEffect")
	COMMONSETTINGSAVE_LOAD_XML("EnableDeadParts")
	COMMONSETTINGSAVE_LOAD_XML("UseCamShockWave")
	COMMONSETTINGSAVE_LOAD_XML("UseItemDropEffect")
	COMMONSETTINGSAVE_LOAD_XML("EnableRenderShadow")
	COMMONSETTINGSAVE_LOAD_XML("EnableFXAA")
	COMMONSETTINGSAVE_LOAD_XML("EnableHighTexture")
	COMMONSETTINGSAVE_LOAD_XML("EnableNaturalEffect")
	COMMONSETTINGSAVE_LOAD_XML("EnableCharSilhouette")
	COMMONSETTINGSAVE_LOAD_XML("EnableOtherPCDamageEffect")
	COMMONSETTINGSAVE_LOAD_XML("EnableHitGlow")
	config.SaveConfig();
end

function COMMONSETTINGSAVE_LOAD_UI()
	local frame = ui.GetFrame("systemoption");
	COMMONSETTINGSAVE_LOAD_UI_CHECKBOX(frame,"viewCharInfoBase", "ViewCharInfoBase")
	COMMONSETTINGSAVE_LOAD_UI_CHECKBOX(frame,"HideGivenName","HideGivenName")
	COMMONSETTINGSAVE_LOAD_UI_CHECKBOX(frame,"ShowPartyName","ShowPartyName")
	COMMONSETTINGSAVE_LOAD_UI_CHECKBOX(frame,"ShowOtherPcName","ShowOtherPCName")
	COMMONSETTINGSAVE_LOAD_UI_CHECKBOX(frame,"ShowHpSpGauge","ShowHpSpGauge")
	COMMONSETTINGSAVE_LOAD_UI_CHECKBOX(frame,"JoyPadVibration","JoyPadVibration")
	COMMONSETTINGSAVE_LOAD_UI_CHECKBOX(frame,"PumpRecipe","PumpRecipe")
	COMMONSETTINGSAVE_LOAD_UI_CHECKBOX(frame,"ShowDropItemName","ShowDropItemName")

	COMMONSETTINGSAVE_LOAD_UI_CHECKBOX(frame,"autoCellSelect","EnableAutoCellSelect")
	COMMONSETTINGSAVE_LOAD_UI_CHECKBOX(frame,"ShowCurrentGetVis","ShowCurrentGetVis")
	COMMONSETTINGSAVE_LOAD_UI_CHECKBOX(frame,"ShowCurrentGetExp","ShowCurrentGetExp")
	COMMONSETTINGSAVE_LOAD_UI_CHECKBOX(frame,"ShowSummonedMonName","ShowSummonedMonName")
	
	INIT_CONTROL_CONFIG(frame)
	SET_SHOW_PAD_SKILL_RANGE(frame)
	SET_SIMPLIFY_BUFF_EFFECTS(frame)
	SET_SIMPLIFY_MODEL(frame)

	local autoPerfMode = config.GetAutoAdjustLowLevel();
	local autoPerfBtn = GET_CHILD_RECURSIVELY(frame,"perftype_" .. autoPerfMode);
	if autoPerfBtn ~= nil then
		autoPerfBtn:Select();
	end

	SHOW_PERFORMANCE_VALUE(frame)
	COMMONSETTINGSAVE_LOAD_UI_CHECKBOX(frame,"check_fluting","EnableOtherFluting")
	COMMONSETTINGSAVE_LOAD_UI_CHECKBOX(frame,"ShowPerformanceValue","ShowPerformanceValue")
	COMMONSETTINGSAVE_LOAD_UI_CHECKBOX(frame,"check_Bloom","EnableBloom")
	COMMONSETTINGSAVE_LOAD_UI_CHECKBOX(frame,"check_SoftParticle","EnableSoftParticle")
	COMMONSETTINGSAVE_LOAD_UI_CHECKBOX(frame,"check_ShowOtherPCEffect","EnableOtherPCEffect")
	COMMONSETTINGSAVE_LOAD_UI_CHECKBOX(frame,"check_EnableDeadParts","EnableDeadParts")
	COMMONSETTINGSAVE_LOAD_UI_CHECKBOX(frame,"UseCamShockWave","UseCamShockWave")
	COMMONSETTINGSAVE_LOAD_UI_CHECKBOX(frame,"UseItemDropEffect","UseItemDropEffect")
	COMMONSETTINGSAVE_LOAD_UI_CHECKBOX(frame,"check_RenderShadow","EnableRenderShadow")
	COMMONSETTINGSAVE_LOAD_UI_CHECKBOX(frame,"check_fxaa","EnableFXAA")
	COMMONSETTINGSAVE_LOAD_UI_CHECKBOX(frame,"check_highTexture","EnableHighTexture")
	COMMONSETTINGSAVE_LOAD_UI_CHECKBOX(frame,"check_EnableNaturalEffect","EnableNaturalEffect")
	COMMONSETTINGSAVE_LOAD_UI_CHECKBOX(frame,"check_EnableCharSilhouette","EnableCharSilhouette")
	COMMONSETTINGSAVE_LOAD_UI_CHECKBOX(frame,"check_ShowOtherPCDamageEffect","EnableOtherPCDamageEffect")
	COMMONSETTINGSAVE_LOAD_UI_CHECKBOX(frame,"check_HitGlow","EnableHitGlow")

end

function COMMONSETTINGSAVE_LOAD_XML(key)
	config.ChangeXMLConfig(key, g.settings.config[key]);
end

function COMMONSETTINGSAVE_LOAD_UI_CHECKBOX(frame, key, value)
	local check = GET_CHILD_RECURSIVELY(frame, key, "ui::CCheckBox");
	check:SetCheck(g.settings.config[value]);
end

function COMMONSETTINGSAVE_APPS_TRY_LEAVE(type)
	-- キャラやログアウトなど、今のキャラから変更する時にフラグオフ
	readFlg = false
	COMMONSETTINGSAVE_APPS_TRY_LEAVE_OLD(type)
end

