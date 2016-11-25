CHAT_SYSTEM("MARKET SHOW LEVEL v1.0.2 loaded!");

local itemColor = {
	[0] = "FFFFFF",    -- Normal
	[1] = "108CFF",    -- 0.75 over
	[2] = "9F30FF",    -- 0.85 over
	[3] = "FF4F00"     -- 0.95 over
};

local propNameList = {
	["MHP"]            = "Max HP",
	["RHP"]            = "HP Rec",
	["MSP"]            = "Max SP",
	["RSP"]            = "SP Rec",
	["PATK"]           = "PhysAtk",
	["ADD_MATK"]       = "Mag Atk",
	["ADD_DEF"]        = "PhysDef",
	["ADD_MDEF"]       = "Mag Def",
	["ADD_MHR"]        = "Mag Amp",
	["CRTATK"]         = "CritAtk",
	["CRTHR"]          = "CritRate",
	["CRTDR"]          = "CritDef",
	["ADD_HR"]         = "Accuracy",
	["ADD_DR"]         = "Evasion",
	["ADD_FIRE"]       = "FireAtk",
	["ADD_ICE"]        = "IceAtk",
	["ADD_POISON"]     = "PsnAtk",
	["ADD_LIGHTNING"]  = "LgtAtk",
	["ADD_EARTH"]      = "EarthAtk",
	["ADD_SOUL"]       = "GhostAtk",
	["ADD_HOLY"]       = "HolyAtk",
	["ADD_DARK"]       = "DarkAtk",
	["RES_FIRE"]       = "FireRes",
	["RES_ICE"]        = "IceRes",
	["RES_POISON"]     = "PsnRes",
	["RES_LIGHTNING"]  = "LgtRes",
	["RES_EARTH"]      = "EarthRes",
	["RES_SOUL"]       = "GhostRes",
	["RES_HOLY"]       = "HolyRes",
	["RES_DARK"]       = "DarkRes",
	["MSPD"]           = "Mspd",
	["SR"]             = "AoEAtk",
	["SDR"]            = "AoEDef",
	["BLK"]            = "Block"
};

function MARKETSHOWLEVEL_ON_INIT(addon, frame)
	_G["ON_MARKET_ITEM_LIST"] = ON_MARKET_ITEM_LIST_HOOKED;
end

function GET_ITEM_VALUE_COLOR(value, max)
	if value > (max * 0.95) then
		return itemColor[3]
	elseif value > (max * 0.85) then
		return itemColor[2]
	elseif value > (max * 0.75) then
		return itemColor[1]
	else
		return itemColor[0]
	end
end

--Show extra details, refactored method
function SHOW_EXTRA_DETAILS(itemObj)
	local itemLevel = GET_ITEM_LEVEL(itemObj);
	local itemGroup = itemObj.GroupName;
	local itemFullName = GET_FULL_NAME(itemObj);
	if itemGroup == "Gem" or itemGroup == "Card" then
		return "Lv".. itemLevel .. ":" .. itemFullName
	elseif (itemObj.ClassName == "Scroll_SkillItem") then
		local skillClass = GetClassByType("Skill", itemObj.SkillType);
		return "Lv".. itemObj.SkillLevel .. " " .. skillClass.Name .. ":" .. itemFullName
	elseif itemGroup == "Armor" then
		local prop = "";
		for i = 1 , 3 do
			local propName = "";
			local propValue = 0;
			local propNameStr = "HatPropName_"..i;
			local propValueStr = "HatPropValue_"..i;
			local propValueColored = "FFFFFF";
			if itemObj[propValueStr] ~= 0 and itemObj[propNameStr] ~= "None" then
				propName = itemObj[propNameStr];
				propValue = itemObj[propValueStr];

				if propName == "MHP" then propValueColored = GET_ITEM_VALUE_COLOR(propValue,2283);
				elseif propName == "RHP" then propValueColored = GET_ITEM_VALUE_COLOR(propValue,56);
				elseif propName == "MSP" then propValueColored = GET_ITEM_VALUE_COLOR(propValue,447);
				elseif propName == "RSP" then propValueColored = GET_ITEM_VALUE_COLOR(propValue,42);
				elseif propName == "CRTATK" then propValueColored = GET_ITEM_VALUE_COLOR(propValue,189);
				elseif propName == "ADD_DEF" 
					or propName == "ADD_MDEF" then propValueColored = GET_ITEM_VALUE_COLOR(propValue,110);
				elseif propName == "PATK" 
					or propName == "ADD_MATK" 
					or propName == "ADD_MHR" then propValueColored = GET_ITEM_VALUE_COLOR(propValue,126);
				elseif propName == "CRTHR" 
					or propName == "CRTDR" 
					or propName == "BLK" 
					or propName == "ADD_HR" 
					or propName == "ADD_DR" then propValueColored = GET_ITEM_VALUE_COLOR(propValue,14);
				elseif propName == "ADD_FIRE" 
					or propName == "ADD_ICE" 
					or propName == "ADD_POISON" 
					or propName == "ADD_LIGHTNING"
					or propName == "ADD_EARTH"
					or propName == "ADD_SOUL"
					or propName == "ADD_HOLY"
					or propName == "ADD_DARK" then propValueColored = GET_ITEM_VALUE_COLOR(propValue,99);
				elseif propName == "RES_FIRE" 
					or propName == "RES_ICE" 
					or propName == "RES_POISON" 
					or propName == "RES_LIGHTNING"
					or propName == "RES_EARTH"
					or propName == "RES_SOUL"
					or propName == "RES_HOLY"
					or propName == "RES_DARK" then propValueColored = GET_ITEM_VALUE_COLOR(propValue,84);
				end

				propName = propNameList[propName];
				prop = prop .. string.format("%s:{#%s}{ol}%d{/}{/}", propName, propValueColored, propValue);
			end
		end
		if prop == "" then
			return itemFullName
		else
			local spacesBeforeProp = ""
			for k = 1, #itemFullName + 10 do
				spacesBeforeProp = spacesBeforeProp .. " "
			end
			local text = "%s{nl}" .. spacesBeforeProp .. "%s"
			return string.format(text, itemFullName, prop) 
		end
	else
		return itemFullName
	end
end

--Market names integration
function SHOW_MARKET_NAMES(ctrlSet, marketItem)
	if marketItem == nil then
		return;
	end

	if _G["MARKETNAMES"] ~= nil then
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

		-- add code start
		local name = ctrlSet:GetChild("name");
		name:SetTextByKey("value", SHOW_EXTRA_DETAILS(itemObj));
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
