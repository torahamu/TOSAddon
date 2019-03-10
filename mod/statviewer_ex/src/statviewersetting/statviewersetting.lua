local acutil = require('acutil');

function STATVIEWERSETTING_ON_INIT(addon, frame)
	acutil.slashCommand("/statviewer", STATVIEWERSETTING_COMMAND);
	frame:ShowWindow(0);
end

function STATVIEWERSETTING_SAVE_STATSETTINGS()
	local mySession = session.GetMySession();
	local cid = mySession:GetCID();
	acutil.saveJSON("../addons/statviewer_ex/"..cid..".json", _G["STATVIEWER_EX"]["statsettings"]);
	local statframe = ui.GetFrame("statviewer_ex");
	statframe:RemoveAllChild();
	STATVIEWER_EX_UPDATE(statframe)
end

function STATVIEWERSETTING_COMMAND(command)
	local cmd = "";
	local no = "";

	if nil == command or #command == 0 then
		return STATVIEWERSETTING_OPEN_UI()
	elseif #command < 2 or #command > 2 then
		return STATVIEWERSETTING_USAGE()
	else
		cmd = string.lower(table.remove(command, 1));
		no = string.lower(table.remove(command, 1));
		no = tonumber(no);
		if (cmd ~= "save") and (cmd ~= "load") then
			return STATVIEWERSETTING_USAGE();
		elseif (no < 1) or (no > 10) then
			return STATVIEWERSETTING_USAGE();
		end

		local msg = "";
		local country=string.lower(option.GetCurrentCountry());
		if (cmd == "save") then
			STATVIEWERSETTING_COMMONSAVE_SAVE(no)
			if country=="japanese" then
				msg = "現在の設定を共通データ"..no.."にセーブしました"
			else
				msg = "save the current setting to common data "..no.."."
			end
			ui.SysMsg(msg)
		elseif (cmd == "load") then
			STATVIEWERSETTING_COMMONSAVE_LOAD(no)
			if country=="japanese" then
				msg = "共通データ"..no.."をロードしました"
			else
				msg = "load to common data "..no.."."
			end
			ui.SysMsg(msg)
		end
	end
end

function STATVIEWERSETTING_USAGE()
	local msg = '';
	msg = msg.. '/statviewer{nl}';
	msg = msg.. 'Open Stat Viewer Setting{nl}';
	msg = msg.. '-----------{nl}';
	msg = msg.. '/statviewer save [1 ~ 10]{nl}';
	msg = msg.. 'save common1~10{nl}';
	msg = msg.. '-----------{nl}';
	msg = msg.. '/statviewer load [1 ~ 10]{nl}';
	msg = msg.. 'load common1~10{nl}';
	return ui.MsgBox(msg,"","Nope")
end


function STATVIEWERSETTING_OPEN_UI()
	STATVIEWERSETTING_CREATE_UI();
	STATVIEWERSETTING_CREATE_UI_COMMONDATA();
	ui.OpenFrame("statviewersetting");
end

function STATVIEWERSETTING_FRAME_SAVECLOSE()
	STATVIEWERSETTING_SAVE_STATSETTINGS()
	ui.CloseFrame("statviewersetting");
end
function STATVIEWERSETTING_FRAME_CLOSE()
	ui.CloseFrame("statviewersetting");
end


function STATVIEWERSETTING_CREATE_UI()
	local frame = ui.GetFrame("statviewersetting");
	local fontType = "{@st43}{s16}"
	local rtHead = {
		[1]  = {name="パラメータ" ;ename="Parameter" ;x=30 ; y=0;};
		[2]  = {name="表示フラグ" ;ename="Flg"       ;x=140; y=0;};
		[3]  = {name="色"         ;ename="Color"     ;x=285; y=0;};
		[4]  = {name="パラメータ" ;ename="Parameter" ;x=450; y=0;};
		[5]  = {name="表示フラグ" ;ename="Flg"       ;x=560; y=0;};
		[6]  = {name="色"         ;ename="Color"     ;x=705; y=0;};
	};
	local rtLabel = {
		[1]  = {name="物理攻撃"   ;ename="PATK"     };
		[2]  = {name="補助攻撃"   ;ename="PATK_SUB" };
		[3]  = {name="魔法攻撃"   ;ename="MATK"     };
		[4]  = {name="属性攻撃"   ;ename="EATK"     };
		[5]  = {name="クリ発　"   ;ename="CRTHR"    };
		[6]  = {name="物理クリ"   ;ename="CRTATK"   };
		[7]  = {name="魔法クリ"   ;ename="CRTMATK"  };
		[8]  = {name="治癒力　"   ;ename="HEAL_PWR" };
		[9]  = {name="命中　　"   ;ename="HR"       };
		[10] = {name="ブロ貫通"   ;ename="BLK_BREAK"};
		[11] = {name="ＡＯＥ　"   ;ename="SR"       };
		[12] = {name="物理防御"   ;ename="DEF"      };
		[13] = {name="魔法防御"   ;ename="MDEF"     };
		[14] = {name="回避　　"   ;ename="DR"       };
		[15] = {name="ブロック"   ;ename="BLK"      };
		[16] = {name="クリ抵抗"   ;ename="CRTDR"    };
		[17] = {name="広域防御"   ;ename="SDR"      };
		[18] = {name="ＨＰ回復"   ;ename="RHP"      };
		[19] = {name="ＳＰ回復"   ;ename="RSP"      };
		[20] = {name="スピード"   ;ename="MSPD"     };
		[21] = {name="所持量　"   ;ename="WHEIGHT"  };
		[22] = {name="チャンス"   ;ename="CHANCE"   };
		[23] = {name="力　　　"   ;ename="STR"      };
		[24] = {name="体力　　"   ;ename="CON"      };
		[25] = {name="知能　　"   ;ename="INT"      };
		[26] = {name="精神　　"   ;ename="MNA"      };
		[27] = {name="敏捷　　"   ;ename="DEX"      };
		[28] = {name="能力値　"   ;ename="STATUS"   };
	};
	local country=string.lower(option.GetCurrentCountry());

	for i = 1 , 6 do
		local text = frame:CreateOrGetControl("richtext", "statviewersetting_head"..i, rtHead[i].x, rtHead[i].y, 0, 0);
		tolua.cast(text, "ui::CRichText");
		if option.GetCurrentCountry()=="Japanese" then
			text:SetText(fontType .. rtHead[i].name .. "{/}{/}");
		else
			text:SetText(fontType .. rtHead[i].ename .. "{/}{/}");
		end
	end

	local line = frame:CreateOrGetControl('labelline', 'statviewersetting_line', 15, 25, frame:GetWidth()-30, 2);
	line:SetSkinName('labelline_def')

	for i = 1 , 11 do
		local text = frame:CreateOrGetControl("richtext", "statviewersetting_label"..i, 30, 40*i, 0, 0);
		tolua.cast(text, "ui::CRichText");
		if country=="japanese" then
			text:SetText(fontType .. rtLabel[i].name .. "{/}{/}");
		else
			text:SetText(fontType .. rtLabel[i].ename .. "{/}{/}");
		end

		local check = frame:CreateOrGetControl('checkbox', "statviewersetting_check"..i, 140, 40*i, 24, 24);
		tolua.cast(check, "ui::CCheckBox");
		check:SetClickSound('button_click_big');
		check:SetAnimation("MouseOnAnim", "btn_mouseover");
		check:SetAnimation("MouseOffAnim", "btn_mouseoff");
		check:SetOverSound('button_over');
		check:SetEventScript(ui.LBUTTONUP, "STATVIEWERSETTING_TOGGLE_CHECK_FLG");
		check:SetEventScriptArgString(ui.LBUTTONUP, rtLabel[i].ename);
		if _G["STATVIEWER_EX"]["statsettings"][rtLabel[i].ename] then
			check:SetCheck(1);
		else
			check:SetCheck(0);
		end

		local colorBox = frame:CreateOrGetControl('groupbox', "statviewersetting_color"..i, 180, 40*i, 250, 25);
		tolua.cast(colorBox, "ui::CGroupBox");

		for j = 0, 9 do

			local colorCls = GetClass("ChatColorStyle", "Class"..j)
		
			if colorCls ~= nil then

				local color = colorBox:CreateOrGetControl("picture", "statviewersetting_color_" .. i .. "_" ..j, 25*j, 0, 25, 25);
				tolua.cast(color, "ui::CPicture");
				color:SetImage("chat_color");
				color:SetEventScript(ui.LBUTTONDOWN, 'STATVIEWERSETTING_SELECT_COLOR');
				color:SetEventScriptArgString(ui.LBUTTONDOWN, colorCls.TextColor..","..rtLabel[i].ename);
				color:SetEventScriptArgNumber(ui.LBUTTONDOWN, i + 100);
				color:SetColorTone("FF"..colorCls.TextColor)
				color:SetTextTooltip(colorCls.Name)
			end
		end
	end
	for i = 12 , 22 do
		local text = frame:CreateOrGetControl("richtext", "statviewersetting_label"..i, 450, 40*(i-11), 0, 0);
		tolua.cast(text, "ui::CRichText");
		if option.GetCurrentCountry()=="Japanese" then
			text:SetText(fontType .. rtLabel[i].name .. "{/}{/}");
		else
			text:SetText(fontType .. rtLabel[i].ename .. "{/}{/}");
		end

		local check = frame:CreateOrGetControl('checkbox', "statviewersetting_check"..i, 560, 40*(i-11), 24, 24);
		tolua.cast(check, "ui::CCheckBox");
		check:SetClickSound('button_click_big');
		check:SetAnimation("MouseOnAnim", "btn_mouseover");
		check:SetAnimation("MouseOffAnim", "btn_mouseoff");
		check:SetOverSound('button_over');
		check:SetEventScript(ui.LBUTTONUP, "STATVIEWERSETTING_TOGGLE_CHECK_FLG");
		check:SetEventScriptArgString(ui.LBUTTONUP, rtLabel[i].ename);
		if _G["STATVIEWER_EX"]["statsettings"][rtLabel[i].ename] then
			check:SetCheck(1);
		else
			check:SetCheck(0);
		end

		local colorBox = frame:CreateOrGetControl('groupbox', "statviewersetting_color"..i, 600, 40*(i-11), 250, 25);
		tolua.cast(colorBox, "ui::CGroupBox");

		for j = 0, 9 do

			local colorCls = GetClass("ChatColorStyle", "Class"..j)
		
			if colorCls ~= nil then

				local color = colorBox:CreateOrGetControl("picture", "statviewersetting_color_" .. i .. "_" ..j, 25*j, 0, 25, 25);
				tolua.cast(color, "ui::CPicture");
				color:SetImage("chat_color");
				color:SetEventScript(ui.LBUTTONDOWN, 'STATVIEWERSETTING_SELECT_COLOR');
				color:SetEventScriptArgString(ui.LBUTTONDOWN, colorCls.TextColor..","..rtLabel[i].ename);
				color:SetEventScriptArgNumber(ui.LBUTTONDOWN, i + 100);
				color:SetColorTone("FF"..colorCls.TextColor)
				color:SetTextTooltip(colorCls.Name)
			end
		end
	end

	for i = 23 , 25 do
		local text = frame:CreateOrGetControl("richtext", "statviewersetting_label"..i, 30, 40*(i-11), 0, 0);
		tolua.cast(text, "ui::CRichText");
		if country=="japanese" then
			text:SetText(fontType .. rtLabel[i].name .. "{/}{/}");
		else
			text:SetText(fontType .. rtLabel[i].ename .. "{/}{/}");
		end

		local check = frame:CreateOrGetControl('checkbox', "statviewersetting_check"..i, 140, 40*(i-11), 24, 24);
		tolua.cast(check, "ui::CCheckBox");
		check:SetClickSound('button_click_big');
		check:SetAnimation("MouseOnAnim", "btn_mouseover");
		check:SetAnimation("MouseOffAnim", "btn_mouseoff");
		check:SetOverSound('button_over');
		check:SetEventScript(ui.LBUTTONUP, "STATVIEWERSETTING_TOGGLE_CHECK_FLG");
		check:SetEventScriptArgString(ui.LBUTTONUP, rtLabel[i].ename);
		if _G["STATVIEWER_EX"]["statsettings"][rtLabel[i].ename] then
			check:SetCheck(1);
		else
			check:SetCheck(0);
		end

		local colorBox = frame:CreateOrGetControl('groupbox', "statviewersetting_color"..i, 180, 40*(i-11), 250, 25);
		tolua.cast(colorBox, "ui::CGroupBox");

		for j = 0, 9 do

			local colorCls = GetClass("ChatColorStyle", "Class"..j)
		
			if colorCls ~= nil then

				local color = colorBox:CreateOrGetControl("picture", "statviewersetting_color_" .. i .. "_" ..j, 25*j, 0, 25, 25);
				tolua.cast(color, "ui::CPicture");
				color:SetImage("chat_color");
				color:SetEventScript(ui.LBUTTONDOWN, 'STATVIEWERSETTING_SELECT_COLOR');
				color:SetEventScriptArgString(ui.LBUTTONDOWN, colorCls.TextColor..","..rtLabel[i].ename);
				color:SetEventScriptArgNumber(ui.LBUTTONDOWN, i + 100);
				color:SetColorTone("FF"..colorCls.TextColor)
				color:SetTextTooltip(colorCls.Name)
			end
		end
	end
	for i = 26 , 28 do
		local text = frame:CreateOrGetControl("richtext", "statviewersetting_label"..i, 450, 40*(i-14), 0, 0);
		tolua.cast(text, "ui::CRichText");
		if option.GetCurrentCountry()=="Japanese" then
			text:SetText(fontType .. rtLabel[i].name .. "{/}{/}");
		else
			if rtLabel[i].ename=="MNA" then
				text:SetText(fontType .. "SPR" .. "{/}{/}");
			else
				text:SetText(fontType .. rtLabel[i].ename .. "{/}{/}");
			end
		end

		local check = frame:CreateOrGetControl('checkbox', "statviewersetting_check"..i, 560, 40*(i-14), 24, 24);
		tolua.cast(check, "ui::CCheckBox");
		check:SetClickSound('button_click_big');
		check:SetAnimation("MouseOnAnim", "btn_mouseover");
		check:SetAnimation("MouseOffAnim", "btn_mouseoff");
		check:SetOverSound('button_over');
		check:SetEventScript(ui.LBUTTONUP, "STATVIEWERSETTING_TOGGLE_CHECK_FLG");
		check:SetEventScriptArgString(ui.LBUTTONUP, rtLabel[i].ename);
		if _G["STATVIEWER_EX"]["statsettings"][rtLabel[i].ename] then
			check:SetCheck(1);
		else
			check:SetCheck(0);
		end

		if i ~= 28 then
			local colorBox = frame:CreateOrGetControl('groupbox', "statviewersetting_color"..i, 600, 40*(i-14), 250, 25);
			tolua.cast(colorBox, "ui::CGroupBox");

			for j = 0, 9 do

				local colorCls = GetClass("ChatColorStyle", "Class"..j)
			
				if colorCls ~= nil then

					local color = colorBox:CreateOrGetControl("picture", "statviewersetting_color_" .. i .. "_" ..j, 25*j, 0, 25, 25);
					tolua.cast(color, "ui::CPicture");
					color:SetImage("chat_color");
					color:SetEventScript(ui.LBUTTONDOWN, 'STATVIEWERSETTING_SELECT_COLOR');
					color:SetEventScriptArgString(ui.LBUTTONDOWN, colorCls.TextColor..","..rtLabel[i].ename);
					color:SetEventScriptArgNumber(ui.LBUTTONDOWN, i + 100);
					color:SetColorTone("FF"..colorCls.TextColor)
					color:SetTextTooltip(colorCls.Name)
				end
			end
		else
			local statustext = frame:CreateOrGetControl("richtext", "statviewersetting_statuslabel"..i, 600, 40*(i-14), 0, 0);
			tolua.cast(statustext, "ui::CRichText");
			if country=="japanese" then
				statustext:SetText(fontType .. "他のステータスの色を選択してください" .. "{/}{/}");
			else
				statustext:SetText(fontType .. "Please select color of other status" .. "{/}{/}");
			end
		end
	end

	local line2 = frame:CreateOrGetControl('labelline', 'statviewersetting_line2', 15, 600, frame:GetWidth()-30, 2);
	line2:SetSkinName('labelline_def')

end

function STATVIEWERSETTING_CREATE_UI_COMMONDATA()
	local frame = ui.GetFrame("statviewersetting");
	local fontType = "{@st43}{s16}"
	local rtDropLabel = {
		[1]  = {name="共通データ1"  ;ename="Common Data1"  };
		[2]  = {name="共通データ2"  ;ename="Common Data2"  };
		[3]  = {name="共通データ3"  ;ename="Common Data3"  };
		[4]  = {name="共通データ4"  ;ename="Common Data4"  };
		[5]  = {name="共通データ5"  ;ename="Common Data5"  };
		[6]  = {name="共通データ6"  ;ename="Common Data6"  };
		[7]  = {name="共通データ7"  ;ename="Common Data7"  };
		[8]  = {name="共通データ8"  ;ename="Common Data8"  };
		[9]  = {name="共通データ9"  ;ename="Common Data9"  };
		[10] = {name="共通データ10" ;ename="Common Data10" };
	};
	local country=string.lower(option.GetCurrentCountry());

	local droplist = frame:CreateOrGetControl('droplist', "statviewersetting_droplist", 50, 630, 200, 20)
	tolua.cast(droplist, "ui::CDropList");
	droplist:SetSkinName("droplist_normal");
	droplist:SetTextAlign("left", "center");
	for i = 1 , 10 do
		if country=="japanese" then
			droplist:AddItem(i, rtDropLabel[i].name, 0, "STATVIEWERSETTING_CHANGE_DROPLIST("..i..")");
		else
			droplist:AddItem(i, rtDropLabel[i].ename, 0, "STATVIEWERSETTING_CHANGE_DROPLIST("..i..")");
		end
	end
	droplist:SelectItem(0)

	local text = frame:CreateOrGetControl("richtext", "statviewersetting_memotext", 350, 630, 0, 0);
	tolua.cast(text, "ui::CRichText");
	text:SetText(fontType .. "MEMO{/}{/}");

	local memo = frame:CreateControl("edit", "statviewersetting_memo", 400, 630, 400, 24);
	tolua.cast(memo, "ui::CEditControl");
	memo:SetGravity(ui.LEFT, ui.TOP);
	memo:SetFontName("white_16_ol");
	memo:SetText(_G["STATVIEWER_EX"]["common1"].MEMO);

	local savebtn = frame:CreateOrGetControl("button", "statviewersetting_savebutton", 450, 690, 150, 24);
	tolua.cast(savebtn, "ui::CButton");
	savebtn:SetFontName("white_16_ol");
	savebtn:SetText("COMMONDATA SAVE");
	savebtn:SetGravity(ui.LEFT, ui.TOP);
	savebtn:SetClickSound("button_click");
	savebtn:SetOverSound("button_cursor_over_2");
	savebtn:SetAnimation("MouseOnAnim", "btn_mouseover");
	savebtn:SetAnimation("MouseOffAnim", "btn_mouseoff");
	savebtn:SetEventScript(ui.LBUTTONDOWN, "STATVIEWERSETTING_COMMONSAVE_CHECK");
	savebtn:SetEventScriptArgNumber(ui.LBUTTONDOWN, 1);

	local loadbtn = frame:CreateOrGetControl("button", "statviewersetting_loadbutton", 650, 690, 150, 24);
	tolua.cast(loadbtn, "ui::CButton");
	loadbtn:SetFontName("white_16_ol");
	loadbtn:SetText("COMMONDATA LOAD");
	loadbtn:SetGravity(ui.LEFT, ui.TOP);
	loadbtn:SetClickSound("button_click");
	loadbtn:SetOverSound("button_cursor_over_2");
	loadbtn:SetAnimation("MouseOnAnim", "btn_mouseover");
	loadbtn:SetAnimation("MouseOffAnim", "btn_mouseoff");
	loadbtn:SetEventScript(ui.LBUTTONDOWN, "STATVIEWERSETTING_COMMONLOAD_CHECK");
	loadbtn:SetEventScriptArgNumber(ui.LBUTTONDOWN, 1);

end


function STATVIEWERSETTING_SELECT_COLOR(parent, ctrl, argStr, argNum)
	local colorText = string.sub(argStr, 1, 6 );
	local ename = string.sub(argStr, 8 );

	_G["STATVIEWER_EX"]["statsettings"][ename.."_COLOR"] = colorText;
	STATVIEWERSETTING_SAVE_STATSETTINGS();

end

function STATVIEWERSETTING_TOGGLE_CHECK_FLG(frame, ctrl, argStr, argNum)
	if ctrl:IsChecked() == 1 then
		_G["STATVIEWER_EX"]["statsettings"][argStr] = true;
	else
		_G["STATVIEWER_EX"]["statsettings"][argStr] = false;
	end
	STATVIEWERSETTING_SAVE_STATSETTINGS();
end

function STATVIEWERSETTING_CHANGE_DROPLIST(no)
	local frame = ui.GetFrame("statviewersetting");
	local memo = GET_CHILD(frame, "statviewersetting_memo");
	tolua.cast(memo, "ui::CEditControl");
	memo:SetText(_G["STATVIEWER_EX"]["common"..no].MEMO);

	local savebtn = GET_CHILD(frame, "statviewersetting_savebutton");
	tolua.cast(savebtn, "ui::CButton");
	savebtn:SetEventScriptArgNumber(ui.LBUTTONDOWN, no);

	local loadbtn = GET_CHILD(frame, "statviewersetting_loadbutton");
	tolua.cast(loadbtn, "ui::CButton");
	loadbtn:SetEventScriptArgNumber(ui.LBUTTONDOWN, no);
end

function STATVIEWERSETTING_COMMONSAVE_CHECK(frame, ctrl, argStr, argNum)
	local yesscp = string.format("STATVIEWERSETTING_COMMONSAVE_SAVE(%d)", argNum);
	local country=string.lower(option.GetCurrentCountry());
	local msg = ""
	if country=="japanese" then
		msg = "現在の設定を共通データ"..argNum.."にセーブしますか？"
	else
		msg = "save the current setting to common data "..argNum.."?"
	end
	ui.MsgBox(msg, yesscp, "None")
end

function STATVIEWERSETTING_COMMONSAVE_SAVE(no)
	local frame = ui.GetFrame("statviewersetting");
	local memo = GET_CHILD(frame, "statviewersetting_memo");
	tolua.cast(memo, "ui::CEditControl");
	_G["STATVIEWER_EX"]["statsettings"].MEMO=memo:GetText();
	acutil.saveJSON("../addons/statviewer_ex/common"..no..".json", _G["STATVIEWER_EX"]["statsettings"]);
	_G["STATVIEWER_EX"]["common"..no] = _G["STATVIEWER_EX"]["statsettings"]
end

function STATVIEWERSETTING_COMMONLOAD_CHECK(frame, ctrl, argStr, argNum)
	local yesscp = string.format("STATVIEWERSETTING_COMMONSAVE_LOAD(%d)", argNum);
	local country=string.lower(option.GetCurrentCountry());
	local msg = ""
	if country=="japanese" then
		msg = "共通データ"..argNum.."をロードしますか？"
	else
		msg = "load to common data "..argNum.."?"
	end
	ui.MsgBox(msg, yesscp, "None")
end

function STATVIEWERSETTING_COMMONSAVE_LOAD(no)
	_G["STATVIEWER_EX"]["statsettings"] = _G["STATVIEWER_EX"]["common"..no]
	STATVIEWERSETTING_SAVE_STATSETTINGS()
	STATVIEWERSETTING_CREATE_UI()
	local statframe = ui.GetFrame("statviewer_ex");
	statframe:RemoveAllChild();
	STATVIEWER_EX_UPDATE(statframe)
end

