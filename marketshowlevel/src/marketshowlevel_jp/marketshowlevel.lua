CHAT_SYSTEM("MARKET SHOW LEVEL JP v1.0.5 loaded!");

-- Equip Jem And Hat prop align
local propAlign = "left";

-- Hat prop color
local itemColor = {
	[0] = "FFFFFF",    -- Normal
	[1] = "108CFF",    -- 0.75 over
	[2] = "9F30FF",    -- 0.85 over
	[3] = "FF4F00",    -- 0.95 over
};

-- Hat prop Name and Max Values
local propList = {};
propList.MHP           = {name = "ＨＰ";max = 2283;};
propList.RHP           = {name = "HP回";max = 56;};
propList.MSP           = {name = "ＳＰ";max = 450;};
propList.RSP           = {name = "SP回";max = 56;};
propList.PATK          = {name = "物攻";max = 126;};
propList.ADD_MATK      = {name = "魔攻";max = 126;};
propList.ADD_DEF       = {name = "物防";max = 110;};
propList.ADD_MDEF      = {name = "魔防";max = 110;};
propList.ADD_MHR       = {name = "増幅";max = 126;};
propList.CRTATK        = {name = "ｸﾘ攻";max = 189;};
propList.CRTHR         = {name = "ｸﾘ発";max = 14;};
propList.CRTDR         = {name = "ｸﾘ抵";max = 14;};
propList.BLK           = {name = "ブロ";max = 14;};
propList.ADD_HR        = {name = "命中";max = 14;};
propList.ADD_DR        = {name = "回避";max = 14;};
propList.ADD_FIRE      = {name = "炎攻";max = 99;};
propList.ADD_ICE       = {name = "氷攻";max = 99;};
propList.ADD_POISON    = {name = "毒攻";max = 99;};
propList.ADD_LIGHTNING = {name = "雷攻";max = 99;};
propList.ADD_EARTH     = {name = "地攻";max = 99;};
propList.ADD_SOUL      = {name = "霊攻";max = 99;};
propList.ADD_HOLY      = {name = "聖攻";max = 99;};
propList.ADD_DARK      = {name = "闇攻";max = 99;};
propList.RES_FIRE      = {name = "炎防";max = 84;};
propList.RES_ICE       = {name = "氷防";max = 84;};
propList.RES_POISON    = {name = "毒防";max = 84;};
propList.RES_LIGHTNING = {name = "雷防";max = 84;};
propList.RES_EARTH     = {name = "地防";max = 84;};
propList.RES_SOUL      = {name = "霊防";max = 84;};
propList.RES_HOLY      = {name = "聖防";max = 84;};
propList.RES_DARK      = {name = "闇防";max = 84;};
propList.MSPD          = {name = "移動";max = 1;};
propList.SR            = {name = "広攻";max = 1;};
propList.SDR           = {name = "広防";max = 4;};


function MARKETSHOWLEVEL_ON_INIT(addon, frame)
	if (acutil ~= nil) then
		acutil.setupEvent(addon, "ON_MARKET_ITEM_LIST", "ON_MARKET_ITEM_LIST_HOOKED")
	else
		_G["ON_MARKET_ITEM_LIST"] = ON_MARKET_ITEM_LIST_HOOKED;
	end
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
				gemInfo = gemInfo..",";
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
				gemInfo = gemInfo .. "{#FF7F50}{ol}Lv" .. gemLevel .. ":" .. GET_ITEM_IMG_BY_CLS(obj, 22) .. "{/}{/}";
			else
				gemInfo = gemInfo .. "{#FFFFFF}{ol}Lv" .. gemLevel .. ":" .. GET_ITEM_IMG_BY_CLS(obj, 22) .. "{/}{/}";
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
				prop = prop..",";
			end

			propName = itemObj[propNameStr];
			propValue = itemObj[propValueStr];

			propValueColored = GET_ITEM_VALUE_COLOR(propName, propValue, propList[propName].max);

			prop = prop .. string.format("%s:{#%s}{ol}%4d{/}{/}", propList[propName].name, propValueColored, propValue);
		end
	end

	return prop;

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

	local propDetail = ctrlSet:CreateControl("richtext", "PROP_ITEM_" .. row, 100, 40, 0, 0);
	tolua.cast(propDetail, 'ui::CRichText');
	propDetail:SetFontName("brown_16_b");
	propDetail:SetText(prop..gemInfo);
	propDetail:Resize(400, 0)
	propDetail:SetTextAlign(propAlign, "center");
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
		pic:SetImage(itemObj.Icon);

		local name = ctrlSet:GetChild("name");

-- add code start

		local itemLevel = GET_ITEM_LEVEL(itemObj);
		local itemGroup = itemObj.GroupName;

		if itemGroup == "Weapon" or itemGroup == "SubWeapon" or itemGroup == "Armor" then
			name:SetTextByKey("value", GET_FULL_NAME(itemObj));
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
	pagecontrol:SetMaxPage(maxPage);
	pagecontrol:SetCurPage(curPage);

	if nil ~= argNum and  argNum == 1 then
		MARGET_FIND_PAGE(frame, session.market.GetCurPage());
	end
end
