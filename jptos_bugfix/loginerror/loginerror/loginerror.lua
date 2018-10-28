function LOGINERROR_ON_INIT(addon, frame)
	if nil == CREATE_DEF_CHAT_GROUPBOX_OLD then
		_G["CREATE_DEF_CHAT_GROUPBOX_OLD"] = CREATE_DEF_CHAT_GROUPBOX;
		_G["CREATE_DEF_CHAT_GROUPBOX"] = CREATE_DEF_CHAT_GROUPBOX_HOOKED;
	end
end

function CREATE_DEF_CHAT_GROUPBOX_HOOKED(frame)

	--DESTROY_CHILD_BYNAME(frame, 'chatgbox_');

	--local gbox = _ADD_NEW_CHAT_GBOX(frame, "chatgbox_TOTAL")
	local gbox = GET_CHILD(frame, "chatgbox_TOTAL");

	_ADD_GBOX_OPTION_FOR_CHATFRAME(gbox)
	
	gbox:ShowWindow(1)
	frame:Invalidate()
end
