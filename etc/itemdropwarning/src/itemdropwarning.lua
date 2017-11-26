function ITEMDROPWARNING_ON_INIT(addon, frame)
	if nil == INVENTORY_DELETE_OLD then
		_G["INVENTORY_DELETE_OLD"] = INVENTORY_DELETE;
		_G["INVENTORY_DELETE"] = INVENTORY_DELETE_HOOKED;
	end
end

function INVENTORY_DELETE_HOOKED(itemIESID, itemType)
	if true == BEING_TRADING_STATE() then
		return;
	end

	local invframe = ui.GetFrame("inventory");
	if ui.GetPickedFrame() ~= nil then
		return;
	end

	local invItem = session.GetInvItemByGuid(itemIESID);
	if nil == invItem then
		return;
	end

	if true == invItem.isLockState or true == IS_TEMP_LOCK(invframe, invItem) then
		ui.SysMsg(ClMsg("MaterialItemIsLock"));
		return;
	end

	local cls = GetClassByType("Item", itemType);
	if nil == cls then
		return;
	end

	local itemProp = geItemTable.IsDestroyable(itemType);
	if cls.Destroyable == 'NO' or geItemTable.IsDestroyable(itemType) == false then
		local obj = GetIES(invItem:GetObject());
		if obj.ItemLifeTimeOver == 0 then
			ui.AlarmMsg("ItemIsNotDestroy");
			return;
		end
	end

	s_dropDeleteItemIESID = itemIESID;
	local yesScp = string.format("EXEC_DELETE_ITEMDROP()");
	local WarnIcon = "{img NOTICE_Dm_! 42 42}";
	local msg = "{s36}{b}{ol}{#EEEEEE}"..WarnIcon.."!!!!Warning!!!!"..WarnIcon.."{/}{/}{/}{/}{nl}{nl}"
	msg = msg .. "{s24}{b}{ol}{#EEEEEE}"..ScpArgMsg("Auto_JeongMal_[").."{#FF0000}"..cls.Name.."{/}"..ScpArgMsg("Auto_]_eul_BeoLiSiKessSeupNiKka?").."{/}{/}{/}{/}"
	ui.MsgBox(msg, yesScp, "None");
end
