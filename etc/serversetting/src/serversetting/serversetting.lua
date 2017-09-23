function SERVERSETTING_ON_INIT(addon, frame)
	addon:RegisterMsg("GAME_START_3SEC", "CHATSYSTEM_SERVER_SETTING");
end

function CHATSYSTEM_SERVER_SETTING()
	local str = "----------------------------------{nl}現在の鯖設定{nl}";
	str = str .. "ゴールドドロップ率："..tostring(GET_SERVER_SETTING_VALUE("JAEDDURY_GOLD_RATE")).."{nl}";
	str = str .. "アイテムドロップ率："..tostring(GET_SERVER_SETTING_VALUE("JAEDDURY_DROP_ITEM_RATE")).."{nl}";
	str = str .. "モンスター経験値率："..tostring(1 + tonumber(GET_SERVER_SETTING_VALUE("JAEDDURY_MON_EXP_RATE"))).."{nl}";
	str = str .. "----------------------------------";
	CHAT_SYSTEM(str)
end

function GET_SERVER_SETTING_VALUE(constName)
	local cls = GetClass("SharedConst",constName);
	local val = cls.Value;
	local valStr = string.format("%.2f", val);
	return valStr;
end

