function HIRAHUWA_ON_INIT(addon, frame)
	_G["HIRAHUWA_STARTED"] = false;

	local acutil = require("acutil");

	acutil.slashCommand("/!hirahuwastart", HIRAHUWA_START);
	acutil.slashCommand("/!hirahuwastop", HIRAHUWA_STOP);

	addon:RegisterMsg("FPS_UPDATE", "HIRAHUWA_UPDATE");

	CHAT_SYSTEM("HIRAHUWA loaded!");
end

function HIRAHUWA_START()
	_G["HIRAHUWA_STARTED"] = true;
	CHAT_SYSTEM("HIRAHUWA started!");
end

function HIRAHUWA_STOP()
	_G["HIRAHUWA_STARTED"] = false;
	CHAT_SYSTEM("HIRAHUWA stopped!");
end

function HIRAHUWA_UPDATE(frame, msg, argStr, argNum)
	if not _G["HIRAHUWA_STARTED"] then
		return;
	end

	local mapClassName = session.GetMapName();
	local mapprop = geMapTable.GetMapProp(mapClassName);
	local mapName = dictionary.ReplaceDicIDInCompStr(mapprop:GetName());
	local currentChannel = session.loginInfo.GetChannel() + 1;

	if mapClassName ~= "f_siauliai_50_1" then
		return;
	end
	local fndList, fndCount = SelectObject(GetMyPCObject(), 5000, 'ALL');

	for i = 1, fndCount do
		local className = fndList[i].ClassName;
		local classId = fndList[i].ClassID;
		if classId == 156040 or className == "npc_orchard_flower" then
			GetMyActor():GetEffect():PlaySound("voice_archer_multishot_cast");
		end
	end
end
