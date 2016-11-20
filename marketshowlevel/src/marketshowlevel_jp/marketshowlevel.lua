CHAT_SYSTEM("MARKET SHOW LEVEL v1.0.2 JP loaded!");

local itemColor = {
	[0] = "FFFFFF",    -- Normal
	[1] = "108CFF",    -- 0.75 over
	[2] = "9F30FF",    -- 0.85 over
	[3] = "FF4F00",    -- 0.95 over
};

local propNameList = {
	["MHP"]            = "ＨＰ",
	["RHP"]            = "HP回",
	["MSP"]            = "ＳＰ",
	["RSP"]            = "SP回",
	["PATK"]           = "物攻",
	["ADD_MATK"]       = "魔攻",
	["ADD_DEF"]        = "物防",
	["ADD_MDEF"]       = "魔防",
	["ADD_MHR"]        = "増幅",
	["CRTATK"]         = "ｸﾘ攻",
	["CRTHR"]          = "ｸﾘ発",
	["CRTDR"]          = "ｸﾘ抵",
	["ADD_HR"]         = "命中",
	["ADD_DR"]         = "回避",
	["ADD_FIRE"]       = "炎攻",
	["ADD_ICE"]        = "氷攻",
	["ADD_POISON"]     = "毒攻",
	["ADD_LIGHTNING"]  = "雷攻",
	["ADD_EARTH"]      = "地攻",
	["ADD_SOUL"]       = "霊攻",
	["ADD_HOLY"]       = "聖攻",
	["ADD_DARK"]       = "闇攻",
	["RES_FIRE"]       = "炎防",
	["RES_ICE"]        = "氷防",
	["RES_POISON"]     = "毒防",
	["RES_LIGHTNING"]  = "雷防",
	["RES_EARTH"]      = "地防",
	["RES_SOUL"]       = "霊防",
	["RES_HOLY"]       = "聖防",
	["RES_DARK"]       = "闇防",
	["MSPD"]           = "移動",
	["SR"]             = "広攻",
	["SDR"]            = "広防",
	["BLK"]            = "ブロ",
	
};

function GetItemValueColor(value, max)
	local index = 0;
	if value > (max * 0.95) then
		index = 3
	elseif value > (max * 0.85) then
		index = 2
	elseif value > (max * 0.75) then
		index = 1
	end
	return itemColor[index]
end

function MARKETSHOWLEVEL_ON_INIT(addon, frame)

	_G["ON_MARKET_ITEM_LIST"] = ON_MARKET_ITEM_LIST_HOOKED;

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

-- add code start
		local itemLevel = GET_ITEM_LEVEL(itemObj);
		local itemGroup = itemObj.GroupName;
-- add code end

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
		if itemGroup == "Gem" or itemGroup == "Card" then
			name:SetTextByKey("value", "Lv".. itemLevel .. ":" .. GET_FULL_NAME(itemObj));
		elseif (itemObj.ClassName == "Scroll_SkillItem") then
			local skillClass = GetClassByType("Skill", itemObj.SkillType);
			name:SetTextByKey("value", "Lv".. itemObj.SkillLevel .. " " .. skillClass.Name .. ":" .. GET_FULL_NAME(itemObj));
		elseif itemGroup == "Armor" then
			local prop = "";
			local space= "";
			for i = 1 , 3 do
				local propName = "";
				local propValue = 0;
				local propNameStr = "HatPropName_"..i;
				local propValueStr = "HatPropValue_"..i;
				local propValueColored = "FFFFFF";
				if itemObj[propValueStr] ~= 0 and itemObj[propNameStr] ~= "None" then
					if #prop > 0 then
						prop = prop..",";
						space = space .. " ";
					end

					propName = itemObj[propNameStr];
					propValue = itemObj[propValueStr];

					if propName == "MHP" then
						propValueColored = GetItemValueColor(propValue,2283);
					elseif propName == "RHP" then
						propValueColored = GetItemValueColor(propValue,56);
					elseif propName == "MSP" then
						propValueColored = GetItemValueColor(propValue,447);
					elseif propName == "RSP" then
						propValueColored = GetItemValueColor(propValue,42);
					elseif propName == "PATK" then
						propValueColored = GetItemValueColor(propValue,126);
					elseif propName == "ADD_MATK" then
						propValueColored = GetItemValueColor(propValue,126);
					elseif propName == "ADD_DEF" then
						propValueColored = GetItemValueColor(propValue,110);
					elseif propName == "ADD_MDEF" then
						propValueColored = GetItemValueColor(propValue,110);
					elseif propName == "ADD_MHR" then
						propValueColored = GetItemValueColor(propValue,126);
					elseif propName == "CRTATK" then
						propValueColored = GetItemValueColor(propValue,189);
					elseif propName == "CRTHR" then
						propValueColored = GetItemValueColor(propValue,14);
					elseif propName == "CRTDR" then
						propValueColored = GetItemValueColor(propValue,14);
					elseif propName == "BLK" then
						propValueColored = GetItemValueColor(propValue,14);
					elseif propName == "ADD_HR" then
						propValueColored = GetItemValueColor(propValue,14);
					elseif propName == "ADD_DR" then
						propValueColored = GetItemValueColor(propValue,14);
					elseif propName == "ADD_FIRE" then
						propValueColored = GetItemValueColor(propValue,99);
					elseif propName == "ADD_ICE" then
						propValueColored = GetItemValueColor(propValue,99);
					elseif propName == "ADD_POISON" then
						propValueColored = GetItemValueColor(propValue,99);
					elseif propName == "ADD_LIGHTNING" then
						propValueColored = GetItemValueColor(propValue,99);
					elseif propName == "ADD_EARTH" then
						propValueColored = GetItemValueColor(propValue,99);
					elseif propName == "ADD_SOUL" then
						propValueColored = GetItemValueColor(propValue,99);
					elseif propName == "ADD_HOLY" then
						propValueColored = GetItemValueColor(propValue,99);
					elseif propName == "ADD_DARK" then
						propValueColored = GetItemValueColor(propValue,99);
					elseif propName == "RES_FIRE" then
						propValueColored = GetItemValueColor(propValue,84);
					elseif propName == "RES_ICE" then
						propValueColored = GetItemValueColor(propValue,84);
					elseif propName == "RES_POISON" then
						propValueColored = GetItemValueColor(propValue,84);
					elseif propName == "RES_LIGHTNING" then
						propValueColored = GetItemValueColor(propValue,84);
					elseif propName == "RES_EARTH" then
						propValueColored = GetItemValueColor(propValue,84);
					elseif propName == "RES_SOUL" then
						propValueColored = GetItemValueColor(propValue,84);
					elseif propName == "RES_HOLY" then
						propValueColored = GetItemValueColor(propValue,84);
					elseif propName == "RES_DARK" then
						propValueColored = GetItemValueColor(propValue,84);
					end

					propName = propNameList[propName];
					prop = prop..propName..":"..string.format("{#%s}{ol}%4d{/}{/}", propValueColored, propValue);
					space = space .. "         ";
				end
			end
			if prop == "" then
				name:SetTextByKey("value", GET_FULL_NAME(itemObj));
			else
				name:SetTextByKey("value", GET_FULL_NAME(itemObj).."\r\n"..space..prop);
			end
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
