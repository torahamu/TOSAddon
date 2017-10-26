--アドオン名（大文字）
local addonName = "TURIOFSAVIOR";
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

--lua読み込み時のメッセージ
CHAT_SYSTEM(string.format("%s.lua is loaded", addonName));

--マップ読み込み時処理（1度だけ）
function TURIOFSAVIOR_ON_INIT(addon, frame)
	g.addon = addon;
	g.frame = frame;

	if nil == TURIOFSAVIOR_FISHING_START_LBTN_CLICK_OLD then
		TURIOFSAVIOR_FISHING_START_LBTN_CLICK_OLD = FISHING_START_LBTN_CLICK;
		FISHING_START_LBTN_CLICK = TURIOFSAVIOR_FISHING_START_LBTN_CLICK;
	end

	if nil == TURIOFSAVIOR_FISHING_ITEM_BAG_OPEN_UI_OLD then
		TURIOFSAVIOR_FISHING_ITEM_BAG_OPEN_UI_OLD = FISHING_ITEM_BAG_OPEN_UI;
		FISHING_ITEM_BAG_OPEN_UI = TURIOFSAVIOR_FISHING_ITEM_BAG_OPEN_UI;
	end

	addon:RegisterMsg('INV_ITEM_CHANGE_COUNT', 'TURIOFSAVIOR_FISHING_ON_MSG');
	addon:RegisterMsg('INV_ITEM_REMOVE', 'TURIOFSAVIOR_FISHING_ON_MSG');

end

if option.GetCurrentCountry()=="Japanese" then
	rodtextbody = "釣り竿";
	baittextbody = "餌";
	spread_baittextbody = "撒き餌";
	firetextbody = "焚火";
	
else
	rodtextbody = "Rod";
	baittextbody = "Bait";
	spread_baittextbody = "Spread Bait";
	firetextbody = "fire";
end

function TURIOFSAVIOR_FISHING_START_LBTN_CLICK(parent, ctrl)
	-- 処理は元の関数にお任せ
	TURIOFSAVIOR_FISHING_START_LBTN_CLICK_OLD(parent, ctrl);

	local topFrame = parent:GetTopParentFrame();
	local pasteBaitSlotset = GET_CHILD_RECURSIVELY(topFrame, 'pasteBaitSlotset');
	local selectedSlot = pasteBaitSlotset:GetSelectedSlot(0);
	if selectedSlot == nil then
		ui.SysMsg(ClMsg('YouNeedPasteBait'));
		return;
	end
	local pasteBaitID = selectedSlot:GetUserIValue('PASTE_BAIT_ID');
	topFrame:SetUserValue('PASTE_BAIT_ID', pasteBaitID);

end

-- 釣りの時のウィンドウ
function TURIOFSAVIOR_FISHING_ITEM_BAG_OPEN_UI()
	-- 作成したアイコンとか削除
	TURIOFSAVIOR_FISHING_ITEM_BAG_UI_REMOVE_CHILD();
	-- フレーム作成は元の関数にお任せ
	TURIOFSAVIOR_FISHING_ITEM_BAG_OPEN_UI_OLD();

	-- 自分が釣り中じゃなければ終了
	local enable = Fishing.GetMyFishingState();
	if enable == 0 then
		return;
	end
	-- 釣り専用ウィンドウ作成
	TURIOFSAVIOR_FISHING_ITEM_BAG_CREATE_UI()
end

-- 作成したアイコンとか削除
function TURIOFSAVIOR_FISHING_ITEM_BAG_UI_REMOVE_CHILD()
	local frame = ui.GetFrame('fishing_item_bag');
	local rodtext = GET_CHILD(frame, "rodtext");
	if nil ~= rodtext then
		frame:RemoveChild("rodtext");
	end
	local rodslot = GET_CHILD(frame, "rodslot");
	if nil ~= rodslot then
		rodslot:ClearIcon();
		frame:RemoveChild("rodslot");
	end
	local baittext = GET_CHILD(frame, "baittext");
	if nil ~= baittext then
		frame:RemoveChild("baittext");
	end
	local baitslot = GET_CHILD(frame, "baitslot");
	if nil ~= baitslot then
		baitslot:ClearIcon();
		frame:RemoveChild("baitslot");
	end
	local spread_baittext = GET_CHILD(frame, "spread_baittext");
	if nil ~= spread_baittext then
		frame:RemoveChild("spread_baittext");
	end
	local spread_baitslot = GET_CHILD(frame, "spread_baitslot");
	if nil ~= spread_baitslot then
		spread_baitslot:ClearIcon();
		frame:RemoveChild("spread_baitslot");
	end
	local firetext = GET_CHILD(frame, "firetext");
	if nil ~= firetext then
		frame:RemoveChild("firetext");
	end
	local fireslot = GET_CHILD(frame, "fireslot");
	if nil ~= fireslot then
		fireslot:ClearIcon();
		frame:RemoveChild("fireslot");
	end
end

-- インベントリのイベント
function TURIOFSAVIOR_FISHING_ON_MSG(frame, msg, argStr, argNum)
	-- 自分が釣り中じゃなければ終了
	local enable = Fishing.GetMyFishingState();
	if enable == 0 then
		return;
	end
	-- 餌消費とかアイテム数だけ変更
	if msg == 'INV_ITEM_CHANGE_COUNT' then
		-- 釣り専用ウィンドウ作成をし直す
		TURIOFSAVIOR_FISHING_ITEM_BAG_CREATE_UI();
	end

	-- 餌が完全になくなった時とか、アイテムがなくなった時
	if msg == 'INV_ITEM_REMOVE' then
		TURIOFSAVIOR_FISHING_ITEM_BAG_REMOVE_SLOT(ui.GetFrame('fishing_item_bag'), argStr);
	end

end

-- 釣り専用ウィンドウ作成
function TURIOFSAVIOR_FISHING_ITEM_BAG_CREATE_UI()
	local fishframe = ui.GetFrame('fishing');
	local frame = ui.GetFrame('fishing_item_bag');
	frame:Resize(frame:GetOriginalWidth(),frame:GetOriginalHeight()+100)

	-- インベントリアイテムの検索
	local rodItem = nil;
	local baitItem = nil;
	local spread_baitItem = nil;
	local fireItem = nil;
	local i = 1;
	local list = session.GetInvItemList();
	local listIndex = list:Head();
	while 1 do
		if listIndex == list:InvalidIndex() then
			break;
		end
		local item = list:Element(listIndex);
		if item.type == tonumber(fishframe:GetUserValue('FISHING_ROD_ID')) then
			rodItem = item;
		elseif item.type == tonumber(fishframe:GetUserValue('PASTE_BAIT_ID')) then
			baitItem = item;
		elseif item.type == 730400 then
			spread_baitItem = item;
		elseif item.type == 730600 then
			fireItem = item;
		end
		listIndex = list:Next(listIndex);
	end

	-- 以前作成したアイコンとかをいったん削除
	TURIOFSAVIOR_FISHING_ITEM_BAG_UI_REMOVE_CHILD();

	local rodtext = frame:CreateOrGetControl("richtext", "rodtext", 30, 250, 120, 34);
	tolua.cast(rodtext, 'ui::CRichText');
	rodtext:SetFontName("white_16_ol");
	rodtext:SetText("{@st42}"..rodtextbody.."{/}");

	local rodslot = frame:CreateOrGetControl("slot", "rodslot", 83, 250, 65, 65);
	tolua.cast(rodslot, "ui::CSlot");
	rodslot:SetSkinName("invenslot2");
	rodslot:EnableDrop(0);
	if nil ~= rodItem then
		SET_SLOT_INVITEM(rodslot,rodItem);
	end

	local baittext = frame:CreateOrGetControl("richtext", "baittext", 170, 250, 120, 34);
	tolua.cast(baittext, 'ui::CRichText');
	baittext:SetFontName("white_16_ol");
	baittext:SetText("{@st42}"..baittextbody.."{/}");

	local baitslot = frame:CreateOrGetControl("slot", "baitslot", 217, 250, 65, 65);
	tolua.cast(baitslot, "ui::CSlot");
	baitslot:SetSkinName("invenslot2");
	baitslot:EnableDrop(0);
	if nil ~= baitItem then
		SET_SLOT_INVITEM(baitslot, baitItem);
	end

	local spread_baittext = frame:CreateOrGetControl("richtext", "spread_baittext", 310, 250, 120, 34);
	tolua.cast(spread_baittext, 'ui::CRichText');
	spread_baittext:SetFontName("white_16_ol");
	spread_baittext:SetText("{@st42}"..spread_baittextbody.."{/}");

	local spread_baitslot = frame:CreateOrGetControl("slot", "spread_baitslot", 418, 250, 65, 65);
	tolua.cast(spread_baitslot, "ui::CSlot");
	spread_baitslot:SetSkinName("invenslot2");
	spread_baitslot:EnableDrop(0);
	if nil ~= spread_baitItem then
		SET_SLOT_INVITEM(spread_baitslot, spread_baitItem);
		local spread_baitItemIES = GetIES(spread_baitItem:GetObject());
		spread_baitslot:SetEventScript(ui.RBUTTONDOWN, 'SLOT_ITEMUSE_BY_TYPE');
		spread_baitslot:SetEventScriptArgNumber(ui.RBUTTONDOWN, spread_baitItemIES.ClassID);
	end

	local firetext = frame:CreateOrGetControl("richtext", "firetext", 500, 250, 120, 34);
	tolua.cast(firetext, 'ui::CRichText');
	firetext:SetFontName("white_16_ol");
	firetext:SetText("{@st42}"..firetextbody.."{/}");

	local fireslot = frame:CreateOrGetControl("slot", "fireslot", 552, 250, 65, 65);
	tolua.cast(fireslot, "ui::CSlot");
	fireslot:SetSkinName("invenslot2");
	fireslot:EnableDrop(0);
	if nil ~= fireItem then
		SET_SLOT_INVITEM(fireslot,fireItem);
		local fireItemIES = GetIES(fireItem:GetObject());
		fireslot:SetEventScript(ui.RBUTTONDOWN, 'SLOT_ITEMUSE_BY_TYPE');
		fireslot:SetEventScriptArgNumber(ui.RBUTTONDOWN, fireItemIES.ClassID);
	end
end

-- 完全になくなった時のイベント
function TURIOFSAVIOR_FISHING_ITEM_BAG_REMOVE_SLOT(frame, itemGuid)

	local item = session.GetInvItemByGuid(itemGuid);
	if item == nil then
		return;
	end

	local fishframe = ui.GetFrame('fishing');

	local slotName = "";
	
	if item.type == tonumber(fishframe:GetUserValue('FISHING_ROD_ID')) then
		slotName = "rodslot";
	elseif item.type == tonumber(fishframe:GetUserValue('PASTE_BAIT_ID')) then
		slotName = "baitslot";
	elseif item.type == 730400 then
		slotName = "spread_baitslot";
	elseif item.type == 730600 then
		slotName = "fireslot";
	end

	local slot = GET_CHILD(frame, slotName);
	tolua.cast(slot, "ui::CSlot");
	slot:ClearIcon();
	slot:SetText("")

end

