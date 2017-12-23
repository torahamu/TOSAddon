--Addon Name
local addonName = "HAIRENCHANTEXTEND";
local addonNameLower = string.lower(addonName);

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
function HAIRENCHANTEXTEND_ON_INIT(addon, frame)
	g.addon = addon;
	g.frame = frame;


	--フック処理
	acutil.setupHook(HAIRENCHANT_UPDATE_ITEM_OPTION_HOOKED, "HAIRENCHANT_UPDATE_ITEM_OPTION");
	acutil.setupHook(DRAW_EQUIP_PROPERTY_HOOKED, "DRAW_EQUIP_PROPERTY");

	--ドラッグ
	frame:SetEventScript(ui.LBUTTONUP, "HAIRENCHANTEXTEND_END_DRAG");

end

-- Hat prop Max Values
local propList = {};
propList.MHP           = {max = 2283;};
propList.RHP           = {max = 56;};
propList.MSP           = {max = 450;};
propList.RSP           = {max = 42;};
propList.PATK          = {max = 126;};
propList.ADD_MATK      = {max = 126;};
propList.ADD_DEF       = {max = 110;};
propList.ADD_MDEF      = {max = 110;};
propList.ADD_MHR       = {max = 126;};
propList.CRTATK        = {max = 189;};
propList.CRTHR         = {max = 14;};
propList.CRTDR         = {max = 14;};
propList.BLK           = {max = 14;};
propList.ADD_HR        = {max = 14;};
propList.ADD_DR        = {max = 14;};
propList.ADD_FIRE      = {max = 99;};
propList.ADD_ICE       = {max = 99;};
propList.ADD_POISON    = {max = 99;};
propList.ADD_LIGHTNING = {max = 99;};
propList.ADD_EARTH     = {max = 99;};
propList.ADD_SOUL      = {max = 99;};
propList.ADD_HOLY      = {max = 99;};
propList.ADD_DARK      = {max = 99;};
propList.RES_FIRE      = {max = 84;};
propList.RES_ICE       = {max = 84;};
propList.RES_POISON    = {max = 84;};
propList.RES_LIGHTNING = {max = 84;};
propList.RES_EARTH     = {max = 84;};
propList.RES_SOUL      = {max = 84;};
propList.RES_HOLY      = {max = 84;};
propList.RES_DARK      = {max = 84;};
propList.MSPD          = {max = 1;};
propList.SR            = {max = 1;};
propList.SDR           = {max = 4;};

local itemColor = {
	[0] = "FFFFFF",    -- Normal
	[1] = "108CFF",    -- 0.75 over
	[2] = "9F30FF",    -- 0.85 over
	[3] = "FF4F00",    -- 0.95 over
};
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
function HAIRENCHANT_UPDATE_ITEM_OPTION_HOOKED(itemIES)
	HAIRENCHANT_UPDATE_ITEM_OPTION_MAIN(itemIES)
end

function HAIRENCHANT_UPDATE_ITEM_OPTION_MAIN(itemIES)
	local invItem = session.GetInvItemByGuid(itemIES)
	if nil == invItem then
		return;
	end
	local obj = GetIES(invItem:GetObject());

	local frame = ui.GetFrame("hairenchant");
	local nonOption = false;
	for i = 1, 3 do
		local propName = "HatPropName_"..i;
		local propValue = "HatPropValue_"..i;

		local option = frame:GetChild(propName)
		local txt = "";
		if 1 == i and ( obj[propName] == "None" or obj[propName] == nil ) then
			nonOption = true;
		else
			if obj[propName] ~= "None" then
				local propValueColored = GET_ITEM_VALUE_COLOR(obj[propName], obj[propValue], propList[obj[propName]].max);
				local opName = string.format("%s",ScpArgMsg(obj[propName]));
				txt = string.format("{#%s}{ol}%s "..ScpArgMsg("PropUp").."%d{/}{/}", propValueColored, opName, tonumber(obj[propValue]));
			end
		end

		if true == nonOption then
			txt = ClMsg("EnchantOptionNone");
		end

		option:SetTextByKey("value", txt);
	end
end

function DRAW_EQUIP_PROPERTY_HOOKED(tooltipframe, invitem, yPos, mainframename)
	return DRAW_EQUIP_PROPERTY_MAIN(tooltipframe, invitem, yPos, mainframename)
end

function DRAW_EQUIP_PROPERTY_MAIN(tooltipframe, invitem, yPos, mainframename)
	local gBox = GET_CHILD(tooltipframe,mainframename,'ui::CGroupBox')
	gBox:RemoveChild('tooltip_equip_property');
	
	local baseicList = GET_EQUIP_TOOLTIP_PROP_LIST(invitem);
    local list = {};
    local basicTooltipPropList = StringSplit(invitem.BasicTooltipProp, ';');
    for i = 1, #basicTooltipPropList do
        local basicTooltipProp = basicTooltipPropList[i];
        list = GET_CHECK_OVERLAP_EQUIPPROP_LIST(baseicList, basicTooltipProp, list);
    end
	local list2 = GET_EUQIPITEM_PROP_LIST();
	
	local cnt = 0;
	for i = 1 , #list do

		local propName = list[i];
		local propValue = invitem[propName];
		
		if propValue ~= 0 then
            local checkPropName = propName;
            if propName == 'MINATK' or propName == 'MAXATK' then
                checkPropName = 'ATK';
            end
            if EXIST_ITEM(basicTooltipPropList, checkPropName) == false then
                cnt = cnt + 1;
            end
		end
	end

	for i = 1 , #list2 do
		local propName = list2[i];
		local propValue = invitem[propName];
		if propValue ~= 0 then

			cnt = cnt +1
		end
	end

	for i = 1 , 3 do
		local propName = "HatPropName_"..i;
		local propValue = "HatPropValue_"..i;
		if invitem[propValue] ~= 0 and invitem[propName] ~= "None" then
			cnt = cnt +1
		end
	end
	
	if cnt <= 0 and (invitem.OptDesc == nil or invitem.OptDesc == "None" ) then -- 일단 그릴 프로퍼티가 있는지 검사. 없으면 컨트롤 셋 자체를 안만듬
		if invitem.ReinforceRatio == 100 then
    		return yPos
    	end
	end

	local tooltip_equip_property_CSet = gBox:CreateOrGetControlSet('tooltip_equip_property', 'tooltip_equip_property', 0, yPos);
	local property_gbox = GET_CHILD(tooltip_equip_property_CSet,'property_gbox','ui::CGroupBox')

	local class = GetClassByType("Item", invitem.ClassID);

	local inner_yPos = 0;

	for i = 1 , #list do
		local propName = list[i];
		local propValue = invitem[propName];

		if class[propName] ~= 0 then
			if  invitem.GroupName == 'Weapon' then
				if propName ~= "MINATK" and propName ~= 'MAXATK' then
					local strInfo = ABILITY_DESC_PLUS(ScpArgMsg(propName), class[propName], invitem[propName]);
					inner_yPos = ADD_ITEM_PROPERTY_TEXT(property_gbox, strInfo, 0, inner_yPos);
				end
			elseif  invitem.GroupName == 'Armor' then
				if invitem.ClassType == 'Gloves' then
					if propName ~= "HR" then
						local strInfo = ABILITY_DESC_PLUS(ScpArgMsg(propName), class[propName], invitem[propName]);
						inner_yPos = ADD_ITEM_PROPERTY_TEXT(property_gbox, strInfo, 0, inner_yPos);
					end
				elseif invitem.ClassType == 'Boots' then
					if propName ~= "DR" then
						local strInfo = ABILITY_DESC_PLUS(ScpArgMsg(propName), class[propName], invitem[propName]);
						inner_yPos = ADD_ITEM_PROPERTY_TEXT(property_gbox, strInfo, 0, inner_yPos);
					end
				else
					if propName ~= "DEF" then
						local strInfo = ABILITY_DESC_PLUS(ScpArgMsg(propName), class[propName], invitem[propName]);
						inner_yPos = ADD_ITEM_PROPERTY_TEXT(property_gbox, strInfo, 0, inner_yPos);
					end
				end
			else
				local strInfo = ABILITY_DESC_PLUS(ScpArgMsg(propName), class[propName], invitem[propName]);
				inner_yPos = ADD_ITEM_PROPERTY_TEXT(property_gbox, strInfo, 0, inner_yPos);
			end
		end
	end

	for i = 1 , 3 do
		local propName = "HatPropName_"..i;
		local propValue = "HatPropValue_"..i;
		if invitem[propValue] ~= 0 and invitem[propName] ~= "None" then
-- add code start
			local propValueColored = GET_ITEM_VALUE_COLOR(invitem[propName], invitem[propValue], propList[invitem[propName]].max);
			local opName = string.format("[%s] {#%s}{ol}%s{/}{/}", ClMsg("EnchantOption"), propValueColored, ScpArgMsg(invitem[propName]));
			local strInfo = "";
			if invitem[propValue] < 0 then
				strInfo = string.format(" - %s "..ScpArgMsg("PropDown").."{#%s}{ol}%d{/}{/}", opName, propValueColored, math.abs(invitem[propValue]));
			else
				strInfo = string.format(" - %s "..ScpArgMsg("PropUp").."{#%s}{ol}%d{/}{/}", opName, propValueColored, math.abs(invitem[propValue]));
			end
			inner_yPos = ADD_ITEM_PROPERTY_TEXT(property_gbox, strInfo, 0, inner_yPos);
-- add code end
		end
	end

	for i = 1 , 6 do
	    local propGroupName = "RandomOptionGroup_"..i;
		local propName = "RandomOption_"..i;
		local propValue = "RandomOptionValue_"..i;
		local clientMessage = 'None'
		
		if invitem[propGroupName] == 'ATK' then
		    clientMessage = 'ItemRandomOptionGroupATK'
		elseif invitem[propGroupName] == 'DEF' then
		    clientMessage = 'ItemRandomOptionGroupDEF'
		elseif invitem[propGroupName] == 'UTIL_WEAPON' then
		    clientMessage = 'ItemRandomOptionGroupUTIL'
		elseif invitem[propGroupName] == 'UTIL_ARMOR' then
		    clientMessage = 'ItemRandomOptionGroupUTIL'
		elseif invitem[propGroupName] == 'UTIL_SHILED' then
		    clientMessage = 'ItemRandomOptionGroupUTIL'
		elseif invitem[propGroupName] == 'STAT' then
		    clientMessage = 'ItemRandomOptionGroupSTAT'
		end
		
		if invitem[propValue] ~= 0 and invitem[propName] ~= "None" then
			local opName = string.format("%s %s", ClMsg(clientMessage), ScpArgMsg(invitem[propName]));
			local strInfo = ABILITY_DESC_NO_PLUS(opName, invitem[propValue], 0);
			inner_yPos = ADD_ITEM_PROPERTY_TEXT(property_gbox, strInfo, 0, inner_yPos);
		end
	end

	for i = 1 , #list2 do
		local propName = list2[i];
		local propValue = invitem[propName];
		if propValue ~= 0 then
			local strInfo = ABILITY_DESC_PLUS(ScpArgMsg(propName), class[propName], invitem[propName]);
			inner_yPos = ADD_ITEM_PROPERTY_TEXT(property_gbox, strInfo, 0, inner_yPos);
		end
	end

	if invitem.OptDesc ~= nil and invitem.OptDesc ~= 'None' then
		inner_yPos = ADD_ITEM_PROPERTY_TEXT(property_gbox, invitem.OptDesc, 0, inner_yPos);
	end

	if invitem.IsAwaken == 1 then
		local opName = string.format("[%s] %s", ClMsg("AwakenOption"), ScpArgMsg(invitem.HiddenProp));
		local strInfo = ABILITY_DESC_PLUS(opName, invitem.HiddenPropValue, invitem[invitem.HiddenProp]);
		inner_yPos = ADD_ITEM_PROPERTY_TEXT(property_gbox, strInfo, 0, inner_yPos);
	end

	if invitem.ReinforceRatio > 100 then
		local opName = ClMsg("ReinforceOption");
		local strInfo = ABILITY_DESC_PLUS(opName, math.floor(10 * invitem.ReinforceRatio/100), ClMsg("ReinforceOption"));
		inner_yPos = ADD_ITEM_PROPERTY_TEXT(property_gbox, strInfo.."0%"..ClMsg("ReinforceOptionAtk"), 0, inner_yPos);
	end

	local BOTTOM_MARGIN = tooltipframe:GetUserConfig("BOTTOM_MARGIN"); -- 맨 아랫쪽 여백
	BOTTOM_MARGIN = tonumber(BOTTOM_MARGIN)
	if BOTTOM_MARGIN == nil then
		BOTTOM_MARGIN = 0
	end

	tooltip_equip_property_CSet:Resize(tooltip_equip_property_CSet:GetWidth(),tooltip_equip_property_CSet:GetHeight() + property_gbox:GetHeight() + property_gbox:GetY() + BOTTOM_MARGIN);

	gBox:Resize(gBox:GetWidth(),gBox:GetHeight() + tooltip_equip_property_CSet:GetHeight())

	return tooltip_equip_property_CSet:GetHeight() + tooltip_equip_property_CSet:GetY();
end
