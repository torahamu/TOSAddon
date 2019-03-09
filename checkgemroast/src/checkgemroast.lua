local acutil = require("acutil");
CHAT_SYSTEM("CHECK GEM ROAST loaded!");
local msgbody = "";

------------------------------------
-- Language Setting
------------------------------------
if option.GetCurrentCountry()=="Japanese" then
	msgbody = "装着しようとしているジェムはロースティングしていませんがよろしいですか？";
else
	msgbody = "This gem is not roasting. Is it OK?";
end

------------------------------------
-- Hook base ui.ipf/uiscp/game.lua
------------------------------------
function CHECKGEMROAST_ON_INIT(addon, frame)
	acutil.setupHook(SCR_GEM_ITEM_SELECT_HOOKED, "SCR_GEM_ITEM_SELECT");
end

function SCR_GEM_ITEM_SELECT_HOOKED(argNum, luminItem, frameName)
	-- get inventory item
	local invitem = nil;
	if frameName == 'inventory' then
		invitem = session.GetInvItem(argNum);		
	else
		invitem = session.GetEquipItemBySpot(argNum);
	end
	if invitem == nil then
		RELEASE_ITEMTARGET_ICON_GEM();
		return;
	end

	-- get item object
	local itemobj = GetIES(invitem:GetObject());
	if itemobj == nil then
		RELEASE_ITEMTARGET_ICON_GEM();
		return;
	end

	-- get total / empty socket count
	local socketCnt = GET_NEXT_SOCKET_SLOT_INDEX(itemobj);
	if socketCnt == 0 then
		ui.SysMsg(ScpArgMsg("NOT_HAVE_SOCKET_SPACE"));
		RELEASE_ITEMTARGET_ICON_GEM();
		return;
	end
	local emptyCnt = GET_EMPTY_SOCKET_CNT(socketCnt, invitem);
	if emptyCnt < 1 then
		ui.SysMsg(ScpArgMsg("Auto_SoKaeseopKeoNa_JeonBu_SayongJungiDa"));		
		RELEASE_ITEMTARGET_ICON_GEM();
		return
	end

	local gemClass = GetClassByType("Item", luminItem.type)
	if gemClass ~= nil then
		local gemEquipGroup = TryGetProp(gemClass, "EquipXpGroup")
		if gemEquipGroup == 'Gem_Skill' then
			if IS_SAME_TYPE_GEM_IN_ITEM(invitem, luminItem.type, socketCnt, itemobj) then
				local ret = true
				local invFrame = ui.GetFrame(frameName)
				invFrame:SetUserValue("GEM_EQUIP_ITEM_ID", luminItem:GetIESID())
				invFrame:SetUserValue("GEM_EQUIP_TARGET_ID", invitem:GetIESID())

				if frameName == 'inventory' then
					ui.MsgBox(ScpArgMsg("GEM_EQUIP_SAME_TYPE"), "GEM_EQUIP_TRY", "None");
				elseif frameName == 'status' then
					ui.MsgBox(ScpArgMsg("GEM_EQUIP_SAME_TYPE"), "GEM_EQUIP_TRY_STATUS", "None");
				end
				return
			end
		end
	end

	if IS_ENABLE_EQUIP_GEM(itemobj, gemClass.ClassID, invitem) == false then
		ui.SysMsg(ScpArgMsg("ValidDupEquipGemBy{VALID_CNT}", "VALID_CNT", VALID_DUP_GEM_CNT));
		RELEASE_ITEMTARGET_ICON_GEM();
		return;
	end

	local cnt = 0;
	for i = 0 , socketCnt - 1 do
		if invitem:IsAvailableSocket(i) == false then
			break;
		end
		cnt = cnt + 1;
	end
	local gemobj = GetIES(luminItem:GetObject());
	local lv = GET_ITEM_LEVEL(gemobj);
	if lv > gemobj.GemRoastingLv then
		local yesscp = string.format("GEM_EQUIP_EXECUTE(\'%s\',\'%s\', %d)", luminItem:GetIESID(), invitem:GetIESID(), cnt);
		ui.MsgBox(msgbody, yesscp, "None")
		return;
	end
	GEM_EQUIP_EXECUTE(luminItem:GetIESID(),invitem:GetIESID(), cnt);
end

function GEM_EQUIP_EXECUTE(luminItemIESID, invitemIESID, cnt)
	item.UseItemToItem(luminItemIESID, invitemIESID, cnt);
	RELEASE_ITEMTARGET_ICON_GEM();
end
