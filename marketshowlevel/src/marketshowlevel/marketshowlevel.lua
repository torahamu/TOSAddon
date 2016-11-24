CHAT_SYSTEM("MARKET SHOW LEVEL v1.0.4 loaded!");

local itemColor = {
	[0] = "FFFFFF",    -- Normal
	[1] = "108CFF",    -- 0.75 over
	[2] = "9F30FF",    -- 0.85 over
	[3] = "FF4F00",    -- 0.95 over
};

local propList = {};
propList.MHP           = {name = "HP";max = 2283;};
propList.RHP           = {name = "HPR";max = 56;};
propList.MSP           = {name = "SP";max = 450;};
propList.RSP           = {name = "SPR";max = 56;};
propList.PATK          = {name = "PATK";max = 126;};
propList.ADD_MATK      = {name = "MATK";max = 126;};
propList.ADD_DEF       = {name = "DEF";max = 110;};
propList.ADD_MDEF      = {name = "MDEF";max = 110;};
propList.ADD_MHR       = {name = "MAMP";max = 126;};
propList.CRTATK        = {name = "CATK";max = 189;};
propList.CRTHR         = {name = "CRate";max = 14;};
propList.CRTDR         = {name = "CRes";max = 14;};
propList.BLK           = {name = "BLK";max = 14;};
propList.ADD_HR        = {name = "ACC";max = 14;};
propList.ADD_DR        = {name = "EVA";max = 14;};
propList.ADD_FIRE      = {name = "FATK";max = 99;};
propList.ADD_ICE       = {name = "IATK";max = 99;};
propList.ADD_POISON    = {name = "PATK";max = 99;};
propList.ADD_LIGHTNING = {name = "LATK";max = 99;};
propList.ADD_EARTH     = {name = "EATK";max = 99;};
propList.ADD_SOUL      = {name = "GATK";max = 99;};
propList.ADD_HOLY      = {name = "HATK";max = 99;};
propList.ADD_DARK      = {name = "DATK";max = 99;};
propList.RES_FIRE      = {name = "FRES";max = 84;};
propList.RES_ICE       = {name = "IRES";max = 84;};
propList.RES_POISON    = {name = "PRES";max = 84;};
propList.RES_LIGHTNING = {name = "LRES";max = 84;};
propList.RES_EARTH     = {name = "ERES";max = 84;};
propList.RES_SOUL      = {name = "GRES";max = 84;};
propList.RES_HOLY      = {name = "HRES";max = 84;};
propList.RES_DARK      = {name = "DRES";max = 84;};
propList.MSPD          = {name = "MSpD";max = 1;};
propList.SR            = {name = "AoE AR";max = 1;};
propList.SDR           = {name = "AoE DR";max = 4;};

function MARKETSHOWLEVEL_ON_INIT(addon, frame)
	_G["ON_MARKET_ITEM_LIST"] = ON_MARKET_ITEM_LIST_HOOKED;
end


function GetGemInfo(itemObj)
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

	if #gemInfo > 0 then
		gemInfo = "{nl}" .. gemInfo;
	end

	return gemInfo;

end

function GetHatProp(itemObj)
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

			propValueColored = GetItemValueColor(propName, propValue, propList[propName].max);

			prop = prop .. string.format("%s:{#%s}{ol}%4d{/}{/}", propList[propName].name, propValueColored, propValue);
		end
	end

	if #prop > 0 then
		prop = "{nl}" .. prop;
	end

	return prop;

end

function GetItemValueColor(propname,value, max)
	local index = 0;

	if propname == "MSPD" or propname == "SR" or propname == "SDR" then
		index = 0
	else
		if value > (max * 0.95) then
			index = 3
		elseif value > (max * 0.85) then
			index = 2
		elseif value > (max * 0.75) then
			index = 1
		end
	end

	return itemColor[index]
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

		if itemGroup == "Weapon" or itemGroup == "SubWeapon" then
			local gemInfo = GetGemInfo(itemObj);
			name:SetTextByKey("value", GET_FULL_NAME(itemObj) .. gemInfo);
		elseif itemGroup == "Armor" then
			local gemInfo = GetGemInfo(itemObj);
			local prop = GetHatProp(itemObj);
			name:SetTextByKey("value", GET_FULL_NAME(itemObj) .. prop .. gemInfo);
		elseif itemGroup == "Gem" or itemGroup == "Card" then
			name:SetTextByKey("value", "Lv".. itemLevel .. ":" .. GET_FULL_NAME(itemObj));
		elseif (itemObj.ClassName == "Scroll_SkillItem") then
			local skillClass = GetClassByType("Skill", itemObj.SkillType);
			name:SetTextByKey("value", "Lv".. itemObj.SkillLevel .. " " .. skillClass.Name .. ":" .. GET_FULL_NAME(itemObj));
		else
			name:SetTextByKey("value", GET_FULL_NAME(itemObj));
		end
		name = tolua.cast(name, 'ui::CRichText');
		name:SetTextAlign("left", "top");

-- add code end

		local count = ctrlSet:GetChild("count");
		count:SetTextByKey("value", marketItem.count);
		
		local level = ctrlSet:GetChild("level");
		level:SetTextByKey("value", itemObj.UseLv);

		local price = ctrlSet:GetChild("price");
		price:SetTextByKey("value", GetCommaedText(marketItem.sellPrice));
		price:SetUserValue("Price", marketItem.sellPrice);
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
