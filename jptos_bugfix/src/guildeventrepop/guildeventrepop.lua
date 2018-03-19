function GUILDEVENTREPOP_ON_INIT(addon, frame)
	-- イベント登録
	local frame = ui.GetFrame("guildinfo");
	local repopbtn = frame:CreateOrGetControl("button", "GUILDEVENTREPOP_REPOPBTN", 1270, 90, 200, 30);
	repopbtn = tolua.cast(repopbtn, "ui::CButton");
	repopbtn:SetFontName("white_16_ol");
	repopbtn:SetText("ウィンドウ出るかも");
	repopbtn:SetClickSound("button_click");
	repopbtn:SetOverSound("button_cursor_over_2");
	repopbtn:SetAnimation("MouseOnAnim", "btn_mouseover");
	repopbtn:SetAnimation("MouseOffAnim", "btn_mouseoff");
	repopbtn:SetEventScript(ui.LBUTTONDOWN, "GUILDEVENTREPOP_REPOPEVENT");
end

function GUILDEVENTREPOP_REPOPEVENT()
	ON_UPDATE_GUILDEVENT_POPUP()
end
