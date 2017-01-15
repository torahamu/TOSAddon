--アドオン名（大文字）
local addonName = "FKSYSTEMMSG";
local addonNameLower = string.lower(addonName);
--作者名
local author = "torahamu";

--アドオン内で使用する領域を作成。以下、ファイル内のスコープではグローバル変数gでアクセス可
_G["ADDONS"] = _G["ADDONS"] or {};
_G["ADDONS"][author] = _G["ADDONS"][author] or {};
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {};
local g = _G["ADDONS"][author][addonName];

--ライブラリ読み込み
local acutil = require('acutil');

--lua読み込み時のメッセージ
CHAT_SYSTEM(string.format("%s.lua is loaded", addonName));

--マップ読み込み時処理（1度だけ）
function FKSYSTEMMSG_ON_INIT(addon, frame)
	g.addon = addon;
	g.frame = frame;

	--フック
	acutil.setupHook(DRAW_CHAT_MSG_HOOKED, "DRAW_CHAT_MSG");

end

-- チャット表示処理のフック
function DRAW_CHAT_MSG_HOOKED(groupboxname, size, startindex, framename)
	DRAW_CHAT_MSG_MAIN(groupboxname, size, startindex, framename)
end

-- チャット表示処理メイン
-- 初回はframenameはnilになっている？
function DRAW_CHAT_MSG_MAIN(groupboxname, size, startindex, framename)
	if startindex < 0 then
		return;
	end

	-- 初回は必ずこの処理に入る？
	if framename == nil then
		framename = "chatframe";

		-- chatpopupフレーム(ささやきの別ウィンドウ)があれば、先にそちらから処理
		local popupframename = "chatpopup_" ..string.sub(groupboxname, 10, string.len(groupboxname))
		DRAW_CHAT_MSG(groupboxname, size, startindex, popupframename);
	end

	local mainchatFrame = ui.GetFrame("chatframe")
	local chatframe = ui.GetFrame(framename)
	-- フレームがない場合終了(chatpopupがない場合はここで終了)
	if chatframe == nil then
		return
	end

	-- フレーム毎のボックス(一般・シャウト・パーティーとかの窓)取得
	local groupbox = GET_CHILD(chatframe,groupboxname);
	if groupbox == nil then

		local gboxleftmargin = chatframe:GetUserConfig("GBOX_LEFT_MARGIN")
		local gboxrightmargin = chatframe:GetUserConfig("GBOX_RIGHT_MARGIN")
		local gboxtopmargin = chatframe:GetUserConfig("GBOX_TOP_MARGIN")
		local gboxbottommargin = chatframe:GetUserConfig("GBOX_BOTTOM_MARGIN")
		
		groupbox = chatframe:CreateControl("groupbox", groupboxname, chatframe:GetWidth() - (gboxleftmargin + gboxrightmargin), chatframe:GetHeight() - (gboxtopmargin + gboxbottommargin), ui.RIGHT, ui.BOTTOM, 0, 0, gboxrightmargin, gboxbottommargin);

		_ADD_GBOX_OPTION_FOR_CHATFRAME(groupbox)
		
	end

	-- チャットがまだ何もない場合、発言表示用フレーム(cluster)を削除
	if startindex == 0 then
		DESTROY_CHILD_BYNAME(groupbox, "cluster_");
	end

	local roomID = "Default";
	local marginLeft = 0;
	local marginRight = 25;
	local ypos = 0;
	local textVer = IS_TEXT_VER_CHAT();

	for i = startindex , size - 1 do

		if i ~= 0 then
			-- 
			local clusterinfo = session.ui.GetChatMsgClusterInfo(groupboxname, i-1)
			if clusterinfo ~= nil then
				local beforechildname = "cluster_"..clusterinfo:GetClusterID()
				local beforechild = GET_CHILD(groupbox, beforechildname);
				if beforechild ~= nil then
					ypos = beforechild:GetY() + beforechild:GetHeight();
				end
			end
			-- gbox内に表示がなければ、最初から表示しなおす
			if ypos == 0 then
				DRAW_CHAT_MSG(groupboxname, size, 0, framename);
				return;
			end
		end

		local clusterinfo = session.ui.GetChatMsgClusterInfo(groupboxname, i)
		if clusterinfo == nil then
			return;
		end
		local clustername = "cluster_"..clusterinfo:GetClusterID();
		local msgType = clusterinfo:GetMsgType();
		local commnderName = clusterinfo:GetCommanderName();
		local fontSize = GET_CHAT_FONT_SIZE();	
		local tempfontSize = string.format("{s%s}", fontSize);
		local offsetX = chatframe:GetUserConfig("CTRLSET_OFFSETX");
		if textVer == 0 then
			roomID = clusterinfo:GetRoomID();

			local cluster = GET_CHILD(groupbox, clustername);
			if cluster ~= nil then
-- add code start
-- システムメッセージが全体ボックスでない場合、表示を消す
if ((msgType == "System" or msgType == "Notice") and groupboxname ~= "chatgbox_TOTAL") then
	cluster:Resize( 0 , 0);
	cluster:ShowWindow(0);
else
				local fontStyle = mainchatFrame:GetUserConfig("BALLONCHAT_FONTSTYLE");
				local label = cluster:GetChild('bg');

				if msgType == "System" then
					fontStyle = mainchatFrame:GetUserConfig("BALLONCHAT_FONTSTYLE_SYSTEM");
				elseif msgType == "friendmem" then
					fontStyle = mainchatFrame:GetUserConfig("BALLONCHAT_FONTSTYLE_MEMBER");
					cluster:RemoveChild("name");
				elseif msgType == "guildmem" then
					fontStyle = mainchatFrame:GetUserConfig("BALLONCHAT_FONTSTYLE_MEMBER");
					cluster:RemoveChild("name");
				end;
				local txt = GET_CHILD(label, "text");
				local tempMsg = string.gsub(clusterinfo:GetMsg(), "({/}{/})", "%1" .. fontStyle .. tempfontSize);
				txt:SetTextByKey("text", tempMsg);

				
				local timeBox = GET_CHILD(cluster, "timebox");
				RESIZE_CHAT_CTRL(1, chatframe, cluster, label, txt, timeBox, offsetX);

				if cluster:GetHorzGravity() == ui.RIGHT then
						cluster:SetOffset( marginRight , ypos + 5); 
				else
						cluster:SetOffset( marginLeft , ypos + 5); 
				end

				local slflag = string.find(clusterinfo:GetMsg(),'a SL%a')
				if slflag == nil then				
					label:EnableHitTest(0)
				else
					label:EnableHitTest(1)
				end

end
			else
				local chatCtrlName = 'chatu';
				if true == ui.IsMyChatCluster(clusterinfo) then
					chatCtrlName = 'chati';
				end
				local horzGravity = ui.LEFT;
				if chatCtrlName == 'chati' then
					horzGravity = ui.RIGHT;
				end

				local chatCtrl = groupbox:CreateOrGetControlSet(chatCtrlName, clustername, horzGravity, ui.TOP, marginLeft, ypos + 5 , marginRight, 0);
-- add code start
-- システムメッセージが全体ボックスでない場合、表示を消す
if ((msgType == "System" or msgType == "Notice") and groupboxname ~= "chatgbox_TOTAL") then
	chatCtrl:Resize( 0 , 0);
	chatCtrl:ShowWindow(0);
else				
				chatCtrl:EnableHitTest(1);

				local label = chatCtrl:GetChild('bg');
				local fontStyle = mainchatFrame:GetUserConfig("BALLONCHAT_FONTSTYLE");
				if msgType == "friendmem" then
					fontStyle = mainchatFrame:GetUserConfig("BALLONCHAT_FONTSTYLE_MEMBER");
				elseif msgType == "guildmem" then
					fontStyle = mainchatFrame:GetUserConfig("BALLONCHAT_FONTSTYLE_MEMBER");
				elseif msgType ~= "System" then
					chatCtrl:SetEventScript(ui.RBUTTONDOWN, 'CHAT_RBTN_POPUP');
					chatCtrl:SetUserValue("TARGET_NAME", commnderName);
				elseif msgType == "System" then
					fontStyle = mainchatFrame:GetUserConfig("BALLONCHAT_FONTSTYLE_SYSTEM");
				end			

				local myColor, targetColor = GET_CHAT_COLOR(msgType);
				local txt = GET_CHILD(label, "text", "ui::CRichText");
				local timeBox = GET_CHILD(chatCtrl, "timebox", "ui::CGroupBox");
				local timeCtrl = GET_CHILD(timeBox, "time", "ui::CRichText");
				local nameText = GET_CHILD(chatCtrl, "name", "ui::CRichText");

				local tempMsg = string.gsub(clusterinfo:GetMsg(), "({/}{/})", "%1" .. fontStyle .. tempfontSize);
				txt:SetTextByKey("font", fontStyle);	
				txt:SetTextByKey("size", fontSize);
				txt:SetTextByKey("text", tempMsg);

				local labelMarginX = 0
				local labelMarginY = 0

				if chatCtrlName == 'chati' then
					label:SetSkinName('textballoon_i');
					label:SetColorTone(myColor);
				else
					label:SetColorTone(targetColor);
					if commnderName == "guildmem" or commnderName == "friendmem" then
						chatCtrl:RemoveChild("name");
					elseif commnderName == 'System' and groupboxname == "chatgbox_TOTAL" then
						nameText:SetText('{img chat_system_icon 65 18 }{/}');
					else
						nameText:SetText('{@st61}'..commnderName..'{/}');
					end

					local iconPicture = GET_CHILD(chatCtrl, "iconPicture", "ui::CPicture");
					iconPicture:ShowWindow(0);
				end
			
				timeCtrl:SetTextByKey("time", clusterinfo:GetTimeStr());

				local slflag = string.find(clusterinfo:GetMsg(),'a SL%a')
				if slflag == nil then
					label:EnableHitTest(0)
				else
					label:EnableHitTest(1)
				end
				RESIZE_CHAT_CTRL(1, chatframe, chatCtrl, label, txt, timeBox, offsetX);
end
			end;			
		elseif textVer == 1 then
			local chatCtrlName = 'chatTextVer';
			local horzGravity = ui.LEFT;
			local chatCtrl = groupbox:CreateOrGetControlSet(chatCtrlName, clustername, horzGravity, ui.TOP, marginLeft, ypos -2 , marginRight, 0);						
-- add code start
-- システムメッセージが全体ボックスでない場合、表示を消す
if ((msgType == "System" or msgType == "Notice") and groupboxname ~= "chatgbox_TOTAL") then
	chatCtrl:Resize( 0 , 0);
	chatCtrl:ShowWindow(0);
else				
			local itemCnt = clusterinfo:GetMsgItemCount();
			local label = chatCtrl:GetChild('bg');
			local txt = GET_CHILD(chatCtrl, "text", "ui::CRichText");	
			local timeCtrl = GET_CHILD(chatCtrl, "time", "ui::CRichText");
			local msgFront = "";
			local msgString = "";				
			local fontStyle = nil;
			local msgIsMine = false;

			chatCtrl:EnableHitTest(1);

			if true == ui.IsMyChatCluster(clusterinfo) then
				msgIsMine = true;
				label:SetColorTone("FF000000");
				label:SetAlpha(60);
			else
				label:SetAlpha(0);
			end;

			if msgType == "friendmem" then
				fontStyle = mainchatFrame:GetUserConfig("TEXTCHAT_FONTSTYLE_SYSTEM");
				msgFront = "#86E57F";
			elseif msgType == "guildmem" then
				fontStyle = mainchatFrame:GetUserConfig("TEXTCHAT_FONTSTYLE_SYSTEM");
				msgFront = "#A566FF";
			elseif msgType ~= "System" then
				chatCtrl:SetEventScript(ui.RBUTTONDOWN, 'CHAT_RBTN_POPUP');
				chatCtrl:SetUserValue("TARGET_NAME", commnderName);

				if msgType == "Normal" then
					msgFront = string.format("[%s]", commnderName);
					fontStyle = CHAT_TEXT_IS_MINE_AND_SETFONT(mainchatFrame, msgIsMine, "TEXTCHAT_FONTSTYLE_NORMAL");
				elseif msgType == "Shout" then
					fontStyle = CHAT_TEXT_IS_MINE_AND_SETFONT(mainchatFrame, msgIsMine, "TEXTCHAT_FONTSTYLE_SHOUT");
					msgFront = string.format("[%s][%s]", ScpArgMsg("ChatType_2"), commnderName);	
				elseif msgType == "Party" then
					fontStyle = CHAT_TEXT_IS_MINE_AND_SETFONT(mainchatFrame, msgIsMine, "TEXTCHAT_FONTSTYLE_PARTY");
					msgFront = string.format("[%s][%s]", ScpArgMsg("ChatType_3"), commnderName);		
				elseif msgType == "Guild" then
					fontStyle = CHAT_TEXT_IS_MINE_AND_SETFONT(mainchatFrame, msgIsMine, "TEXTCHAT_FONTSTYLE_GUILD");
					msgFront = string.format("[%s][%s]", ScpArgMsg("ChatType_4"), commnderName);	
				elseif msgType == "Notice" then
					fontStyle = mainchatFrame:GetUserConfig("TEXTCHAT_FONTSTYLE_NOTICE");	
					msgFront = string.format("[%s]", ScpArgMsg("ChatType_6"));		
				else
					fontStyle = CHAT_TEXT_IS_MINE_AND_SETFONT(mainchatFrame, msgIsMine, "TEXTCHAT_FONTSTYLE_WHISPER");
					msgFront = string.format("[%s][%s]", ScpArgMsg("ChatType_5"), commnderName);	
				end;
			elseif msgType == "System" then
				fontStyle = mainchatFrame:GetUserConfig("TEXTCHAT_FONTSTYLE_SYSTEM");
				msgFront = string.format("[%s]", ScpArgMsg("ChatType_7"));		
				label:SetColorTone("FF000000");
				label:SetAlpha(80);
			end
			local timeMsg = "";
			for i = 1 , itemCnt do
				--local tempMsg = string.gsub(clusterinfo:GetMsgItembyIndex(i-1), "({img %a+_%d+%s)%d+%s%d+(}{/})", "%1" .. (fontSize * 3) .. " " .. (fontSize * 3) .. "%2".. fontStyle .. tempfontSize);
				local tempMsg = string.gsub(clusterinfo:GetMsgItembyIndex(i-1), "({/}{/})", "%1" .. fontStyle .. tempfontSize);
				local msgStingAdd = ' ';
				if msgType == "friendmem" or  msgType == "guildmem" then
					msgStingAdd = string.format("{%s}%s{nl}",msgFront, tempMsg);		
				else
					msgStingAdd = string.format("%s : %s{nl}", msgFront, tempMsg);		
				end																									
				msgString = msgString .. msgStingAdd;
				--timeMsg = string.format("%s{nl}%s", timeMsg, clusterinfo:GetTimeStr());	
			end;	
			msgString = string.format("%s{/}", msgString);	
			txt:SetTextByKey("font", fontStyle);				
			txt:SetTextByKey("size", fontSize);				
			txt:SetTextByKey("text", CHAT_TEXT_LINKCHAR_FONTSET(mainchatFrame, msgString));
			timeCtrl:SetTextByKey("time", clusterinfo:GetTimeStr());	

			local slflag = string.find(clusterinfo:GetMsg(),'a SL%a')
			if slflag == nil then
				txt:EnableHitTest(0)
			else
				txt:EnableHitTest(1)
			end
			timeCtrl:SetOffset(10, 10);
			RESIZE_CHAT_CTRL(0, chatframe, chatCtrl, label, txt, timeCtrl, offsetX);
end
		end;
	end;

	local scrollend = false
	if groupbox:GetLineCount() == groupbox:GetCurLine() + groupbox:GetVisibleLineCount() then
		scrollend = true;
	end

	local beforeLineCount = groupbox:GetLineCount();	
	groupbox:UpdateData();
	
	local afterLineCount = groupbox:GetLineCount();
	local changedLineCount = afterLineCount - beforeLineCount;
	local curLine = groupbox:GetCurLine();

	if (IS_BOTTOM_CHAT() == 1) or (scrollend == true) then
		groupbox:SetScrollPos(99999);
	else 
	groupbox:SetScrollPos(curLine + changedLineCount);
	end

	if groupbox:GetName() == "chatgbox_TOTAL" and groupbox:IsVisible() == 1 then
		chat.UpdateAllReadFlag();
	end

	local parentframe = groupbox:GetParent()
	
	if string.find(parentframe:GetName(),"chatpopup_") == nil then
		if roomID ~= "Default" and groupbox:IsVisible() == 1 then
			chat.UpdateReadFlag(roomID);
		end
	else
	
		if roomID ~= "Default" and parentframe:IsVisible() == 1 then
			chat.UpdateReadFlag(roomID);
		end
	end
end

