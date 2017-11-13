local acutil = require("acutil");

local settings = {
	maxNumberOfChannelsToShow = 30;
};

function ZCHANNELSURFER_EX_ON_INIT(addon, frame)
	addon:RegisterMsg('GAME_START', 'CHSURF_CREATE_BUTTONS');

	acutil.setupHook(SELECT_ZONE_MOVE_CHANNEL_HOOKED, "SELECT_ZONE_MOVE_CHANNEL");
end

function SELECT_ZONE_MOVE_CHANNEL_HOOKED(index, channelID)
	local zoneInsts = session.serverState.GetMap();
	if zoneInsts == nil or zoneInsts.pcCount == -1 then
		ui.SysMsg(ClMsg("ChannelIsClosed"));
		return;
	end
	RUN_GAMEEXIT_TIMER("Channel", channelID);
end

function CHSURF_CHANGE_CHANNEL(frame,msg,str,nextChannel)
	local zoneInsts = session.serverState.GetMap();
	local numberOfChannels = zoneInsts:GetZoneInstCount();
	local currentChannel = session.loginInfo.GetChannel();
	nextChannel = (1 + nextChannel + currentChannel) % numberOfChannels;

	if nextChannel == 0 then
		nextChannel = numberOfChannels;
	end

	SELECT_ZONE_MOVE_CHANNEL_HOOKED(0, nextChannel-1);
end

function CHSURF_CREATE_BUTTONS()
	local frame = nil;
	frame = ui.GetFrame("rader");
	if frame == nil then
		frame = ui.GetFrame("minimap");
	end
	local btnsize = 30;
	local nextbutton = frame:CreateOrGetControl('button', "nextbutton", 5+34, 5, btnsize, btnsize);
	tolua.cast(nextbutton, "ui::CButton");
	nextbutton:SetText("{s22}>");
	nextbutton:SetEventScript(ui.LBUTTONUP, "CHSURF_CHANGE_CHANNEL");
	nextbutton:SetEventScriptArgNumber(ui.LBUTTONUP, 1);
	nextbutton:SetClickSound('button_click_big');
	nextbutton:SetOverSound('button_over');

	local prevbutton = frame:CreateOrGetControl('button', "prevbutton", 5, 5, btnsize, btnsize);
	tolua.cast(prevbutton, "ui::CButton");
	prevbutton:SetText("{s22}<");
	prevbutton:SetEventScript(ui.LBUTTONUP, "CHSURF_CHANGE_CHANNEL");
	prevbutton:SetEventScriptArgNumber(ui.LBUTTONUP, -1);
	prevbutton:SetClickSound('button_click_big');
	prevbutton:SetOverSound('button_over');
end
