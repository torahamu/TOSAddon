CHAT_SYSTEM("SHOW HIDE BUFF loaded!");

function SHOWHIDEBUFF_ON_INIT(addon, frame)
	if nil == SHOW_HIDE_BUFF_COMMON_BUFF_MSG_OLD then
		SHOW_HIDE_BUFF_COMMON_BUFF_MSG_OLD = COMMON_BUFF_MSG;
		COMMON_BUFF_MSG = SHOW_HIDE_BUFF_COMMON_BUFF_MSG;
	end
end

function SHOW_HIDE_BUFF_COMMON_BUFF_MSG(frame, msg, buffType, handle, buff_ui, buffIndex)
	if msg == "SET" then
		local buffCount = info.GetBuffCount(handle);

		for i = 0, buffCount - 1 do
			local buff = info.GetBuffIndexed(handle, i);
			COMMON_BUFF_MSG(frame, "ADD", buff.buffID, handle, buff_ui, buff.index);
		end

		return;
	elseif msg == "CLEAR" then

		for i = 0 , buff_ui["buff_group_cnt"] do
			local slotlist = buff_ui["slotlist"][i];
			local slotcount = buff_ui["slotcount"][i];
			local captionlist = buff_ui["captionlist"][i];
            if slotcount ~= nil and slotcount >= 0 then
    			for i = 0, slotcount - 1 do
    				local slot		= slotlist[i];
    				local text		= captionlist[i];
    				slot:ShowWindow(0);
    				slot:ReleaseBlink();
    				text:SetText("");
    			end
    		end
		end

		frame:Invalidate();
		return;
	end

	if "None" == buffIndex or nil == buffIndex then
		buffIndex = 0;
	end
    buffIndex = tonumber(buffIndex);

	local class = GetClassByType('Buff', buffType);
--	if class.ShowIcon == "FALSE" then
--		return;
--	end
	if class.Icon == nil or class.Icon == "" then
		class.Icon = "expup";
	end

	local slotlist;
	local slotcount;
	local captionlist;
	local colcnt = 0;
	local ApplyLimitCountBuff = "YES"
	if class.Group1 == 'Debuff' then
		slotlist = buff_ui["slotlist"][2];
		slotcount = buff_ui["slotcount"][2];
		captionlist = buff_ui["captionlist"][2];
		colcnt = buff_ui["slotsets"][2]:GetCol();
	else
		if class.ApplyLimitCountBuff == 'YES' then
			slotlist = buff_ui["slotlist"][0];
			slotcount = buff_ui["slotcount"][0];
			captionlist = buff_ui["captionlist"][0];
			if nil ~= buff_ui["slotsets"][0] then
				colcnt = buff_ui["slotsets"][0]:GetCol();
			end
		else
			slotlist = buff_ui["slotlist"][1];
			slotcount = buff_ui["slotcount"][1];
			captionlist = buff_ui["captionlist"][1];
			colcnt = buff_ui["slotsets"][1]:GetCol();
			ApplyLimitCountBuff = "NO";
		end
	end

	if msg == 'ADD' then
        local skip = false
        if class ~= nil then
            if TryGetProp(class, 'OnlyOneBuff', 'None') == 'YES' and TryGetProp(class, 'Duplicate', 1) == 0 then
                local exist_slot, i = get_exist_debuff_in_slotlist(slotlist, buffType)
                if exist_slot ~= nil then
                    if exist_slot:IsVisible() == 0 then
                        SET_BUFF_SLOT(exist_slot, captionlist[i], class, buffType, handle, slotlist, buffIndex);
                    end
                    skip = true                  
                end
            end
        end

        if skip == false then
		for j = 0, slotcount - 1 do
			local i = GET_BUFF_SLOT_INDEX(j, colcnt);
			local slot				= slotlist[i];
           
			if slot:IsVisible() == 0 then
				SET_BUFF_SLOT(slot, captionlist[i], class, buffType, handle, slotlist, buffIndex);
				break;
			end
		end
        end
	elseif msg == 'REMOVE' then
		for i = 0, slotcount - 1 do

			local slot		= slotlist[i];
			local text		= captionlist[i];
			local oldIcon 		= slot:GetIcon();
			if slot:IsVisible() == 1 then
				local oldBuffIndex = oldIcon:GetUserIValue("BuffIndex");			
				local iconInfo = oldIcon:GetInfo();
                local isBuffIndexSame = oldBuffIndex - buffIndex;
				if iconInfo.type == buffType and isBuffIndexSame == 0 then
					CLEAR_BUFF_SLOT(slot, text);
				
					local j = GET_BUFF_ARRAY_INDEX(i, colcnt);
					PULL_BUFF_SLOT_LIST(slotlist, captionlist, j, slotcount, colcnt, ApplyLimitCountBuff);
					frame:Invalidate();
					break;
				end
			end
		end

	elseif msg == "UPDATE" then    
		for i = 0, slotcount - 1 do
			local slot = slotlist[i];
			local text = captionlist[i];
			local oldIcon = slot:GetIcon();

			if slot:IsVisible() == 1 then
				local iconInfo = oldIcon:GetInfo();
				if iconInfo.type == buffType and oldIcon:GetUserIValue("BuffIndex") == buffIndex then                
					SET_BUFF_SLOT(slot, captionlist[i], class, buffType, handle, slotlist, buffIndex);
					break;
				end
			end
		end
	end
    ARRANGE_DEBUFF_SLOT(frame, buff_ui);

    COLONY_POINT_INFO_DRAW_BUFF_ICON()
end
