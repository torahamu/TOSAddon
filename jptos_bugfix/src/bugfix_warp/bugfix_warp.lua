local bugfix_warp_load = false;

function BUGFIX_WARP_ON_INIT(addon, frame)
	if bugfix_warp_load == false then
		_G["GET_INTE_WARP_LIST_OLD"] = GET_INTE_WARP_LIST;
		_G["GET_INTE_WARP_LIST"] = GET_INTE_WARP_LIST_HOOKED;
		bugfix_warp_load = true;
		CHAT_SYSTEM("呪文書使用地域修正 読み込み完了！");
	end
end

function GET_INTE_WARP_LIST_HOOKED()
	local sObj_main = GET_MAIN_SOBJ();
	if sObj_main == nil then
		return nil;
	end

	local gentype_classcount = GetClassCount('camp_warp')
	local result = {}
	if gentype_classcount > 0 then
		for i = 0 , gentype_classcount-1 do
			local cls = GetClassByIndex('camp_warp', i);
			if sObj_main[cls.ClassName] == 300 then
				result[#result + 1] = cls
			end
		end
	end

-- add code start
	local etc = GetMyEtcObject();
	local mapCls = GetClassByType("Map", etc.ItemWarpMapID);

	if mapCls ~= nil and mapCls.WorldMap ~= "None" then
		local tempCls = {};
		tempCls.ClassName=mapCls.ClassName;
		tempCls.Name="{#ffff00}"..ScpArgMsg('Auto_(woPeuJuMunSeo)');
		tempCls.Zone=mapCls.ClassName;
		result[#result + 1] = tempCls;
	end
-- add code end

    return result
end
