--dofile("../data/addon_d/statviewer/statviewer.lua");

--ライブラリ読み込み
local acutil = require('acutil');

function STATVIEWERSETTING_ON_INIT(addon, frame)
	acutil.slashCommand("/statviewer", STATVIEWERSETTING_OPEN_UI);
	frame:ShowWindow(0);
end

function STATVIEWERSETTING_SAVE_STATSETTINGS()
	local mySession = session.GetMySession();
	local cid = mySession:GetCID();
	acutil.saveJSON("../addons/statviewer/"..cid..".json", _G["STATVIEWER"]["statsettings"]);
	local statframe = ui.GetFrame("statviewer");
	statframe:RemoveAllChild();
	STATVIEWER_UPDATE(statframe)
end

function STATVIEWERSETTING_OPEN_UI()
	STATVIEWERSETTING_CREATE_UI();
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
		[4]  = {name="魔法増幅"   ;ename="MHR"      };
		[5]  = {name="属性攻撃"   ;ename="EATK"     };
		[6]  = {name="クリ発　"   ;ename="CRTHR"    };
		[7]  = {name="クリ攻撃"   ;ename="CRTATK"   };
		[8]  = {name="命中　　"   ;ename="HR"       };
		[9]  = {name="ブロ貫通"   ;ename="BLK_BREAK"};
		[10] = {name="ＡＯＥ　"   ;ename="SR"       };
		[11] = {name="物理防御"   ;ename="DEF"      };
		[12] = {name="魔法防御"   ;ename="MDEF"     };
		[13] = {name="回避　　"   ;ename="DR"       };
		[14] = {name="ブロック"   ;ename="BLK"      };
		[15] = {name="クリ抵抗"   ;ename="CRTDR"    };
		[16] = {name="広域防御"   ;ename="SDR"      };
		[17] = {name="ＨＰ回復"   ;ename="RHP"      };
		[18] = {name="ＳＰ回復"   ;ename="RSP"      };
		[19] = {name="スピード"   ;ename="MSPD"     };
		[20] = {name="所持量　"   ;ename="WHEIGHT"  };
	};

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

	for i = 1 , 10 do
		local text = frame:CreateOrGetControl("richtext", "statviewersetting_label"..i, 30, 40*i, 0, 0);
		tolua.cast(text, "ui::CRichText");
		if option.GetCurrentCountry()=="Japanese" then
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
		if _G["STATVIEWER"]["statsettings"][rtLabel[i].ename] then
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
	for i = 11 , 20 do
		local text = frame:CreateOrGetControl("richtext", "statviewersetting_label"..i, 450, 40*(i-10), 0, 0);
		tolua.cast(text, "ui::CRichText");
		if option.GetCurrentCountry()=="Japanese" then
			text:SetText(fontType .. rtLabel[i].name .. "{/}{/}");
		else
			text:SetText(fontType .. rtLabel[i].ename .. "{/}{/}");
		end

		local check = frame:CreateOrGetControl('checkbox', "statviewersetting_check"..i, 560, 40*(i-10), 24, 24);
		tolua.cast(check, "ui::CCheckBox");
		check:SetClickSound('button_click_big');
		check:SetAnimation("MouseOnAnim", "btn_mouseover");
		check:SetAnimation("MouseOffAnim", "btn_mouseoff");
		check:SetOverSound('button_over');
		check:SetEventScript(ui.LBUTTONUP, "STATVIEWERSETTING_TOGGLE_CHECK_FLG");
		check:SetEventScriptArgString(ui.LBUTTONUP, rtLabel[i].ename);
		if _G["STATVIEWER"]["statsettings"][rtLabel[i].ename] then
			check:SetCheck(1);
		else
			check:SetCheck(0);
		end

		local colorBox = frame:CreateOrGetControl('groupbox', "statviewersetting_color"..i, 600, 40*(i-10), 250, 25);
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
end


function STATVIEWERSETTING_SELECT_COLOR(parent, ctrl, argStr, argNum)
print("frame:"..tostring(frame))
print("ctrl:"..tostring(ctrl))
print("argStr:"..tostring(argStr))
print("argNum:"..tostring(argNum))

	local colorText = string.sub(argStr, 1, 6 );
	local ename = string.sub(argStr, 8 );
print("colorText:"..tostring(colorText))
print("ename:"..tostring(ename))

	_G["STATVIEWER"]["statsettings"][ename.."_COLOR"] = colorText;
	STATVIEWERSETTING_SAVE_STATSETTINGS();

--	STATVIEWERSETTING_DRAW_CHECKMARK(argNum)
end

--function STATVIEWERSETTING_DRAW_CHECKMARK(colorType)
--
--	local clslist, cnt  = GetClassList("ChatColorStyle");
--
--	local frame = ui.GetFrame("statviewersetting");
--	local vmark = GET_CHILD_RECURSIVELY(frame,"vmark")
--
--	for i = 0 , cnt - 1 do
--
--		local cls = GetClassByIndexFromList(clslist, i);
--
--		if cls.ClassID == colorType then
--		    vmark:SetOffset(i * 25, vmark:GetY())
--		end
--	end
--
--end

-- チェックボックスのイベント
function STATVIEWERSETTING_TOGGLE_CHECK_FLG(frame, ctrl, argStr, argNum)
	if ctrl:IsChecked() == 1 then
		_G["STATVIEWER"]["statsettings"][argStr] = true;
	else
		_G["STATVIEWER"]["statsettings"][argStr] = false;
	end
	STATVIEWERSETTING_SAVE_STATSETTINGS();
end

