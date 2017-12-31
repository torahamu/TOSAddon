--アドオン名（大文字）
local addonName = "BUFFSHOPEX"
local addonNameLower = string.lower(addonName)
--作者名
local author = "CHICORI"

--アドオン内で使用する領域を作成。以下、ファイル内のスコープではグローバル変数gでアクセス可
_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

--設定ファイル保存先
g.settingsFileLoc = string.format("../addons/%s/settings.json", addonNameLower)

--ライブラリ読み込み
local acutil = require('acutil')

--デフォルト設定
if not g.loaded then
  g.settings = {
    enable = true,
	shop   = "",
	aspar  = 715,
	bless  = 287,
	sacra  = 500,
	shield  = 287
  }
end

--lua読み込み時のメッセージ
CHAT_SYSTEM(string.format("%s.lua is loaded", addonName))

function BUFFSHOPEX_SAVE_SETTINGS()
	acutil.saveJSON(g.settingsFileLoc, g.settings)
end


--マップ読み込み時処理（1度だけ）
function BUFFSHOPEX_ON_INIT(addon, frame)
	g.addon = addon
	g.frame = frame

	acutil.slashCommand("/"..addonNameLower, BUFFSHOPEX_PROCESS_COMMAND)
	acutil.slashCommand("/buffshop", BUFFSHOPEX_PROCESS_COMMAND)

	if not g.loaded then
		local t, err = acutil.loadJSON(g.settingsFileLoc, g.settings)

		if err then
			--設定ファイル読み込み失敗時処理
			CHAT_SYSTEM(string.format("[%s] cannot load setting files", addonName))
		else
			--設定ファイル読み込み成功時処理
			g.settings = t
		end

		g.loaded = true
	end

	--設定ファイル保存処理
	BUFFSHOPEX_SAVE_SETTINGS()

	--メッセージ受信登録処理
	acutil.setupHook(BUFFSELLER_REG_OPEN_HOOKED, "BUFFSELLER_REG_OPEN")
end


--チャットコマンド処理（acutil使用時）
function BUFFSHOPEX_PROCESS_COMMAND(command)
	local cmd = ""

	if #command > 0 then
		cmd = table.remove(command, 1)
	else
		local msg = "/buffshop *{nl}name = 店名{nl}アスパーション = a金額{nl}ブレス = b金額{nl}サクラメント = s金額{nl}マジックシールド = m金額{nl}例：/buffshop b777"
		return ui.MsgBox(msg,"","Nope")
	end

	if cmd == "on" then
		g.settings.enable = true
		CHAT_SYSTEM(string.format("[%s] is enable", addonName))
		BUFFSHOPEX_SAVE_SETTINGS()
		return
	elseif cmd == "off" then
		--無効
		g.settings.enable = false
		CHAT_SYSTEM(string.format("[%s] is disable", addonName))
		BUFFSHOPEX_SAVE_SETTINGS()
		return
	elseif string.sub(cmd,1,4) == "name" then
		g.settings.shop = string.sub(cmd,5)
		ui.MsgBox("ショップ名を登録しました。{nl} {nl}" .. string.sub(cmd,5))
		BUFFSHOPEX_SAVE_SETTINGS()
		return

	--この辺適当です。廃止予定
	elseif string.sub(cmd,1,1) == "a" then
		local cmdPrice = tonumber(string.sub(cmd,2))
		local altMsg = "アスパーションを次の価格で保存します。"

		if 715 >= tonumber(cmdPrice) then
			altMsg = "アスパーションの原価は715sです。{nl}原価以下になりますが保存しますか？"
		end

		local calcPrice = cmdPrice - 715
		local yesscp    = string.format("SKILLPRICE_SAVE(%q)",cmd)
		ui.MsgBox(altMsg .. "{nl} {nl}（設定額:" .. cmdPrice .. "s / 差益:".. calcPrice .."s)",yesscp,"None")
		return

	elseif string.sub(cmd,1,1) == "b" then
		local cmdPrice = tonumber(string.sub(cmd,2))
		local altMsg   = "ブレッシングを次の価格で保存します。"

		if 287 >= cmdPrice then
			altMsg = "ブレッシングの原価は287sです。{nl}原価以下になりますが保存しますか？"
		end

		local calcPrice = cmdPrice - 287
		local yesscp = string.format("SKILLPRICE_SAVE(%q)",cmd)
		ui.MsgBox(altMsg .. "{nl} {nl}（設定額:" .. cmdPrice .. "s / 差益:".. calcPrice .."s)",yesscp,"None")
		return

	elseif string.sub(cmd,1,1) == "s" then
		local cmdPrice = tonumber(string.sub(cmd,2))
		local altMsg   = "サクラメントを次の価格で保存します。"

		if 500 >= tonumber(cmdPrice) then
			altMsg = "サクラメントの原価は500sです。{nl}原価以下になりますが保存しますか？"
		end

		local calcPrice = cmdPrice - 500
		local yesscp = string.format("SKILLPRICE_SAVE(%q)",cmd)
		ui.MsgBox(altMsg .. "{nl} {nl}（設定額:" .. cmdPrice .. "s / 差益:".. calcPrice .."s)",yesscp,"None")
		return
	elseif string.sub(cmd,1,1) == "m" then
		local cmdPrice = tonumber(string.sub(cmd,2))
		local altMsg   = "マジックシールドを次の価格で保存します。"

		if 287 >= cmdPrice then
			altMsg = "マジックシールトの原価は287sです。{nl}原価以下になりますが保存しますか？"
		end

		local calcPrice = cmdPrice - 287
		local yesscp = string.format("SKILLPRICE_SAVE(%q)",cmd)
		ui.MsgBox(altMsg .. "{nl} {nl}（設定額:" .. cmdPrice .. "s / 差益:".. calcPrice .."s)",yesscp,"None")
		return

	end

	CHAT_SYSTEM(string.format("[%s] Invalid Command", addonName))
end

function SKILLPRICE_SAVE(cmd)
	local cmdFlg   = string.sub(cmd,1,1)
	local cmdPrice = tonumber(string.sub(cmd,2))

		if cmdFlg == "a" then				--アスパ
			g.settings.aspar = cmdPrice

		elseif cmdFlg == "b" then			--ブレス
			g.settings.bless = cmdPrice

		elseif cmdFlg == "s" then			--サクラ
			g.settings.sacra = cmdPrice

		elseif cmdFlg == "m" then			--マジックシールド
			g.settings.shield = cmdPrice

		end

		BUFFSHOPEX_SAVE_SETTINGS()
end


function BUFFSELLER_REG_OPEN_HOOKED(frame)
	ui.OpenFrame("skilltree")

	local customSkill = frame:GetUserValue("CUSTOM_SKILL")
	if customSkill == "None" then
		frame:SetUserValue("GroupName", "BuffRegister")
		frame:SetUserValue("ServerGroupName", "Buff")
	else
		frame:SetUserValue("GroupName", customSkill)
		frame:SetUserValue("ServerGroupName", customSkill)
	end
	BUFFSELLER_UPDATE_LIST(frame)

-- ここから追加処理(ここまではオリジナル処理) ------------------------------


--使用可否
	if g.settings.enable == false then return end


--露店名
	local gBox     = GET_CHILD(frame, "gbox")
	local sellList = GET_CHILD(gBox, "selllist")
	local shopName = GET_CHILD(gBox, "inputname", "ui::CEditControl")


--えもーしょん変換
	InputText = g.settings.shop
--  {img emoticon_0001 50 50}バフ屋だよー
--	#e01##バフ屋だよー

	InputText = string.gsub(InputText,"#e","{img emoticon_00")
--  {img emoticon_0001 50 50}バフ屋だよー
--	{img emoticon_0001##バフ屋だよー

	InputText = string.gsub(InputText,"}","}{/}")
--  {img emoticon_0001 50 50}{\/}バフ屋だよー
--	{img emoticon_0001##バフ屋だよー


	InputText = string.gsub(InputText,"##"," 35 35}{/}")
--  {img emoticon_0001 50 50}{\/}バフ屋だよー
--	{img emoticon_0001 50 50}{\/}バフ屋だよー

	InputText = string.gsub(InputText,"\\","")
--	{img emoticon_0001 50 50}{/}バフ屋だよー

	shopName:SetText(InputText)

--dofile("../data/addon_d/buffshopex/buffshopex.lua");


--スキルセット
	local relationSkill = {
		[1] = {name = "アスパーション";   sklID = 40201; price=g.settings.aspar};
		[2] = {name = "ブレッシング";     sklID = 40203; price=g.settings.bless};
		[3] = {name = "サクラメント";     sklID = 40205; price=g.settings.sacra};
		[4] = {name = "マジックシールト"; sklID = 40808; price=g.settings.shield};
	}
	for i, ver in ipairs(relationSkill) do
		local skillID = relationSkill[i].sklID
		local toFrame = frame:GetTopParentFrame()
		BUFFSELLER_REGISTER(toFrame, skillID)
	end


--価格セット（スキルセットと同じループに入れると処理タイミングの関係で不発します。）
	for i, ver in ipairs(relationSkill) do
		local setPrice = relationSkill[i].price
		local ctrlSet  = GET_CHILD(sellList, "CTRLSET_" .. i - 1)
		local priceIn  = GET_CHILD(ctrlSet, "priceinput")
		tolua.cast(priceIn, 'ui::CEditControl');
		priceIn:SetText(setPrice)

		BUFFSELLER_TYPING_PRICE(ctrlSet, priceIn)
	end


--//ボタン：エモーション
	local emo_button = frame:CreateOrGetControl("button", "BUFFSHOP_EMO_BTN", 225, 58, 80, 22);
	tolua.cast(emo_button, "ui::CButton");
	emo_button:SetFontName("white_16_ol");
	emo_button:SetEventScript(ui.LBUTTONDOWN, "EMO_LIST");
	emo_button:SetText("Img List");


--//ボタン：保存
	local save_button = frame:CreateOrGetControl("button", "BUFFSHOP_SAVE_BTN", 320, 58, 120, 22);
	tolua.cast(save_button, "ui::CButton");
	save_button:SetFontName("white_16_ol");
	save_button:SetEventScript(ui.LBUTTONDOWN, "BUFFSHOP_SAVEBTN");
	save_button:SetText("設定保存");


--//ラベル：アスパ原価
	local setLbl   = sellList:CreateOrGetControl("richtext", "BUFFSHOP_ASPAR_LBL", 260, 65, 50, 50);
	tolua.cast(setLbl, "ui::CRichText");
	setLbl:SetFontName("white_14_ol");
	setLbl:SetText("原価 : 715");

--//ラベル：ブレス原価
	setLbl = sellList:CreateOrGetControl("richtext", "BUFFSHOP_BLESS_LBL", 260, 185, 50, 50);
	tolua.cast(setLbl, "ui::CRichText");
	setLbl:SetFontName("white_14_ol");
	setLbl:SetText("原価 : 287");

--//ラベル：サクラ原価
	setLbl = sellList:CreateOrGetControl("richtext", "BUFFSHOP_SACRA_LBL", 260, 305, 50, 50);
	tolua.cast(setLbl, "ui::CRichText");
	setLbl:SetFontName("white_14_ol");
	setLbl:SetText("原価 : 500");
	
--//ラベル：マジックシールド原価
	setLbl = sellList:CreateOrGetControl("richtext", "BUFFSHOP_SHIELD_LBL", 260, 425, 50, 50);
	tolua.cast(setLbl, "ui::CRichText");
	setLbl:SetFontName("white_14_ol");
	setLbl:SetText("原価 : 287");
	
	
--	local testBB = GET_CHILD(gBox, "inputname"):GetText()


end

function BUFFSHOP_SAVEBTN(frame)

	local gBox     = GET_CHILD(frame, "gbox")
	local sellList = GET_CHILD(gBox, "selllist")
	local shopName = GET_CHILD(gBox, "inputname"):GetText()


--露店名
	local shopNames = GET_CHILD(gBox, "inputname", "ui::CEditControl")

--えもーしょん変換
	InputText = shopName
--  {img emoticon_0001 50 50}バフ屋だよー
--	#e01##バフ屋だよー

	InputText = string.gsub(InputText,"#e","{img emoticon_00")
--  {img emoticon_0001 50 50}バフ屋だよー
--	{img emoticon_0001##バフ屋だよー

	InputText = string.gsub(InputText,"}","}{/}")
--  {img emoticon_0001 50 50}{\/}バフ屋だよー
--	{img emoticon_0001##バフ屋だよー


	InputText = string.gsub(InputText,"##"," 35 35}{/}")
--  {img emoticon_0001 50 50}{\/}バフ屋だよー
--	{img emoticon_0001 50 50}{\/}バフ屋だよー

	InputText = string.gsub(InputText,"\\","")
--	{img emoticon_0001 50 50}{/}バフ屋だよー

	shopNames:SetText(InputText)

--dofile("../data/addon_d/buffshopex/buffshopex.lua");


	local ctrlSet  = GET_CHILD(sellList, "CTRLSET_0")
	local setAspar = GET_CHILD(ctrlSet, "priceinput"):GetText()


	local ctrlSet  = GET_CHILD(sellList, "CTRLSET_1")
	local setBless = GET_CHILD(ctrlSet, "priceinput"):GetText()


	local ctrlSet  = GET_CHILD(sellList, "CTRLSET_2")
	local setSacra = GET_CHILD(ctrlSet, "priceinput"):GetText()

	local ctrlSet  = GET_CHILD(sellList, "CTRLSET_3")
	local setShield= GET_CHILD(ctrlSet, "priceinput"):GetText()



	string.gsub(shopName,"\\","")
	local SaveMsg = "商店名：".. shopName .. "{nl}アスパ：" .. setAspar.."{nl}ブレス："..setBless.."{nl}サクラ："..setSacra.."{nl}マジックシールド："..setShield.."{nl} {nl}以上の内容で登録しますか？"
	ui.MsgBox(SaveMsg,"BUFFSHOP_SAVEBTNACT(\"" .. shopName .. "\"," .. setAspar .. "," .. setBless .. "," ..setSacra .. "," ..setShield .. ")","None")

end

function BUFFSHOP_SAVEBTNACT(shopName,setAspar,setBless,setSacra,setShield)

	g.settings.shop = shopName
	g.settings.aspar = setAspar
	g.settings.bless = setBless
	g.settings.sacra = setSacra
	g.settings.shield = setShield
	BUFFSHOPEX_SAVE_SETTINGS()
	
	CHAT_SYSTEM(shopName .."/ｱｽﾊﾟ".. setAspar .."/ﾌﾞﾚｽ".. setBless .."/ｻｸﾗ".. setSacra.."/ｼｰﾙﾄﾞ".. setShield.."で登録しました。")

end
--dofile("../data/addon_d/buffshopex/buffshopex.lua");



function EMO_LIST()
local sampleEmo =
	"～　エモーションの使い方　～{nl} {nl}"..
	"入力欄に　#e番号##　と入力する{nl}"..
	"※一度設定保存してください{nl} {nl}"..
	"例：バフ屋#e01##だよー　{nl}"..
	"　　バフ屋{img emoticon_0001 35 35}だよー{/}{nl} {nl}"..

	"01 = {img emoticon_0001 35 35}{/}"..
	"02 = {img emoticon_0002 35 35}{/}"..
	"03 = {img emoticon_0003 35 35}{/}{nl}"..
	"04 = {img emoticon_0004 35 35}{/}"..
	"05 = {img emoticon_0005 35 35}{/}"..
	"06 = {img emoticon_0006 35 35}{/}{nl}"..
	"07 = {img emoticon_0007 35 35}{/}"..
	"08 = {img emoticon_0008 35 35}{/}"..
	"09 = {img emoticon_0009 35 35}{/}{nl}"..
	"10 = {img emoticon_0010 35 35}{/}"..
	"11 = {img emoticon_0011 35 35}{/}"..
	"12 = {img emoticon_0012 35 35}{/}{nl}"..
	"13 = {img emoticon_0013 35 35}{/}"..
	"14 = {img emoticon_0014 35 35}{/}"..
	"15 = {img emoticon_0015 35 35}{/}{nl}"..
	"16 = {img emoticon_0016 35 35}{/}"..
	"17 = {img emoticon_0017 35 35}{/}"..
	"18 = {img emoticon_0018 35 35}{/}{nl}"..
	"19 = {img emoticon_0019 35 35}{/}"..
	"20 = {img emoticon_0020 35 35}{/}"..
	"21 = {img emoticon_0021 35 35}{/}{nl}"..
	"22 = {img emoticon_0022 35 35}{/}"..
	"23 = {img emoticon_0023 35 35}{/}"..
	"24 = {img emoticon_0024 35 35}{/}{nl}"..
	"25 = {img emoticon_0025 35 35}{/}"..
	"26 = {img emoticon_0026 35 35}{/}"..
	"27 = {img emoticon_0027 35 35}{/}{nl}"..
	"28 = {img emoticon_0028 35 35}{/}"..
	"29 = {img emoticon_0029 35 35}{/}"..
	"30 = {img emoticon_0030 35 35}{/}{nl}"..
	"31 = {img emoticon_0031 35 35}{/}"..
	"32 = {img emoticon_0032 35 35}{/}"..
	"33 = {img emoticon_0033 35 35}{/}{nl}"..
	"34 = {img emoticon_0034 35 35}{/}"..
	"35 = {img emoticon_0035 35 35}{/}"..
	"36 = {img emoticon_0036 35 35}{/}{nl}"..
	"37 = {img emoticon_0037 35 35}{/}"..
	"38 = {img emoticon_0038 35 35}{/}"..
	"39 = {img emoticon_0039 35 35}{/}{nl}"..
	"40 = {img emoticon_0040 35 35}{/}"..
	"41 = {img emoticon_0041 35 35}{/}"..
	"42 = {img emoticon_0042 35 35}{/}{nl}"..
	"43 = {img emoticon_0043 35 35}{/}"..
	"44 = {img emoticon_0044 35 35}{/}"..
	"45 = {img emoticon_0045 35 35}{/}{nl}"..
	"46 = {img emoticon_0046 35 35}{/}"

	ui.MsgBox(sampleEmo,"none","none")
end
