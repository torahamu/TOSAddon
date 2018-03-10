local addonName = "CHATEXTENDS";
local addonNameLower = string.lower(addonName);

local author = "torahamu_sound";

_G['ADDONS'] = _G['ADDONS'] or {};
_G['ADDONS'][author] = _G['ADDONS'][author] or {}
_G['ADDONS'][author][addonName] = _G['ADDONS'][author][addonName] or {};
local g = _G['ADDONS'][author][addonName];

g.settingsFileLoc = string.format("../addons/%s/soundsettings.json", addonNameLower);

local soundTypes = nil;
if option.GetCurrentCountry()=="Japanese" then
	soundTypes = {
		[1]  = {name='button_click_stats_up'; sound='button_click_stats_up'};
		[2]  = {name='quest_count'; sound='quest_count'};
		[3]  = {name='quest_event_start'; sound='quest_event_start'};
		[4]  = {name='quest_success_2'; sound='quest_success_2'};
		[5]  = {name='sys_alarm_mon_kill_count'; sound='sys_alarm_mon_kill_count'};
		[6]  = {name='quest_event_click'; sound='quest_event_click'};
		[7]  = {name='sys_secret_alarm'; sound='sys_secret_alarm'};
		[8]  = {name='travel_diary_1'; sound='travel_diary_1'};
		[9]  = {name='button_click_4'; sound='button_click_4'};
		[10] = {name='うぅーい！'; sound='voice_archer_multishot_cast'};
		[11] = {name='はいっ！'; sound='voice_archer_camouflage_shot'};
		[12] = {name='このぉ！'; sound='voice_archer_cloaking_shot'};
		[13] = {name='そぉい！'; sound='voice_archer_fulldraw_cast'};
		[14] = {name='フィーバー！'; sound='voice_war_jollyroger_shot'};
		[15] = {name='あーあー'; sound='PLAYLIST_m_boss_scenario2'};
	}
else
	soundTypes = {
		[1]  = {name='button_click_stats_up'; sound='button_click_stats_up'};
		[2]  = {name='quest_count'; sound='quest_count'};
		[3]  = {name='quest_event_start'; sound='quest_event_start'};
		[4]  = {name='quest_success_2'; sound='quest_success_2'};
		[5]  = {name='sys_alarm_mon_kill_count'; sound='sys_alarm_mon_kill_count'};
		[6]  = {name='quest_event_click'; sound='quest_event_click'};
		[7]  = {name='sys_secret_alarm'; sound='sys_secret_alarm'};
		[8]  = {name='travel_diary_1'; sound='travel_diary_1'};
		[9]  = {name='button_click_4'; sound='button_click_4'};
		[10] = {name='CuteVoice1'; sound='voice_archer_multishot_cast'};
		[11] = {name='CuteVoice2'; sound='voice_archer_camouflage_shot'};
		[12] = {name='CuteVoice3'; sound='voice_archer_cloaking_shot'};
		[13] = {name='CuteVoice4'; sound='voice_archer_fulldraw_cast'};
		[14] = {name='CuteVoice5'; sound='voice_war_jollyroger_shot'};
		[15] = {name='boss_music'; sound='PLAYLIST_m_boss_scenario2'};
	}
end

--ライブラリ読み込み
local acutil = require('acutil');

if not g.loaded then
	g.settings = {
		flg=false; --どこかの設定があれば、保存時にtrueになる
		all = {
			normal=false; shout=false; party=false; guild=false; whisper=false; group=false; system=false; normalsound=1; shoutsound=1; partysound=1; guildsound=1; whispersound=1; groupsound=1; systemsound=1
		};
		word = {
			[1]  = {word="";normal=false; shout=false; party=false; guild=false; whisper=false; group=false; system=false; sound=1};
			[2]  = {word="";normal=false; shout=false; party=false; guild=false; whisper=false; group=false; system=false; sound=1};
			[3]  = {word="";normal=false; shout=false; party=false; guild=false; whisper=false; group=false; system=false; sound=1};
			[4]  = {word="";normal=false; shout=false; party=false; guild=false; whisper=false; group=false; system=false; sound=1};
			[5]  = {word="";normal=false; shout=false; party=false; guild=false; whisper=false; group=false; system=false; sound=1};
			[6]  = {word="";normal=false; shout=false; party=false; guild=false; whisper=false; group=false; system=false; sound=1};
			[7]  = {word="";normal=false; shout=false; party=false; guild=false; whisper=false; group=false; system=false; sound=1};
			[8]  = {word="";normal=false; shout=false; party=false; guild=false; whisper=false; group=false; system=false; sound=1};
			[9]  = {word="";normal=false; shout=false; party=false; guild=false; whisper=false; group=false; system=false; sound=1};
			[10] = {word="";normal=false; shout=false; party=false; guild=false; whisper=false; group=false; system=false; sound=1};
			[11] = {word="";normal=false; shout=false; party=false; guild=false; whisper=false; group=false; system=false; sound=1};
			[12] = {word="";normal=false; shout=false; party=false; guild=false; whisper=false; group=false; system=false; sound=1};
			[13] = {word="";normal=false; shout=false; party=false; guild=false; whisper=false; group=false; system=false; sound=1};
			[14] = {word="";normal=false; shout=false; party=false; guild=false; whisper=false; group=false; system=false; sound=1};
			[15] = {word="";normal=false; shout=false; party=false; guild=false; whisper=false; group=false; system=false; sound=1};
		}
	};
end

--************************************************
-- JSON保存
--************************************************
function CHATEXTENDS_SOUND_SAVE_SETTINGS()
	local frame = ui.GetFrame("zchatsounds");
	g.settings.flg=false;
	if g.settings.all.normal or g.settings.all.shout or g.settings.all.party or g.settings.all.guild or g.settings.all.whisper or g.settings.all.group or g.settings.all.system then
		g.settings.flg=true;
	end
	local list = tolua.cast(frame:GetChild("ALL_DROPLIST0"), "ui::CDropList");
	g.settings.all.normalsound  = list:GetSelItemIndex() + 1;
	list = tolua.cast(frame:GetChild("ALL_DROPLIST1"), "ui::CDropList");
	g.settings.all.shoutsound   = list:GetSelItemIndex() + 1;
	list = tolua.cast(frame:GetChild("ALL_DROPLIST2"), "ui::CDropList");
	g.settings.all.partysound   = list:GetSelItemIndex() + 1;
	list = tolua.cast(frame:GetChild("ALL_DROPLIST3"), "ui::CDropList");
	g.settings.all.guildsound   = list:GetSelItemIndex() + 1;
	list = tolua.cast(frame:GetChild("ALL_DROPLIST4"), "ui::CDropList");
	g.settings.all.whispersound = list:GetSelItemIndex() + 1;
	list = tolua.cast(frame:GetChild("ALL_DROPLIST5"), "ui::CDropList");
	g.settings.all.groupsound   = list:GetSelItemIndex() + 1;
	list = tolua.cast(frame:GetChild("ALL_DROPLIST6"), "ui::CDropList");
	g.settings.all.systemsound   = list:GetSelItemIndex() + 1;
	for i, ver in ipairs(g.settings.word) do
		if g.settings.word[i].normal or g.settings.word[i].shout or g.settings.word[i].party or g.settings.word[i].guild or g.settings.word[i].whisper or g.settings.word[i].group or g.settings.word[i].system then
			g.settings.flg=true;
		end
		local word = tolua.cast(frame:GetChild("WORD"..i), "ui::CEditControl");
		g.settings.word[i].word  = tostring(word:GetText());
		list = tolua.cast(frame:GetChild("WORD_DROPLIST"..i), "ui::CDropList");
		g.settings.word[i].sound  = list:GetSelItemIndex() + 1;
	end
	acutil.saveJSON(g.settingsFileLoc, g.settings);
end

--マップ読み込み時処理（1度だけ）
function ZCHATSOUNDS_ON_INIT(addon, frame)
	frame:ShowWindow(0);
	if not g.loaded then
		local t, err = acutil.loadJSON(g.settingsFileLoc, g.settings);
		-- 読み込めない = ファイルがない
		if err then
		else
			-- 読み込めたら読み込んだ値使う
			g.settings = t;
		end
		g.loaded = true;
	end

end

--************************************************
-- メイン処理
--************************************************
function CHATEXTENDS_SOUND_DRAW_CHAT_MSG_EVENT(frame, msg)
	-- そもそも設定なければ終了
	if not g.settings.flg then
		return;
	end

	local groupboxname, startindex, chatframe = acutil.getEventArgs(msg);

	-- 再描画とかで開始インデックスが0以下なら終了
	if startindex <= 0 then
		return;
	end
	-- メインのチャットフレームの文言のみ
	if chatframe ~= ui.GetFrame("chatframe") then
		return;
	end
	-- メインの全体発言のみ
	if groupboxname ~= "chatgbox_TOTAL" then
		return;
	end

	local groupbox = GET_CHILD(chatframe,groupboxname);
	-- 取れなかったら(ありえるのか？)終了
	if groupbox == nil then
		return;
	end

	local clusterinfo = session.ui.GetChatMsgInfo(groupboxname, startindex)
	-- 取れなかったら(ありえるのか？)終了
	if clusterinfo == nil then
		return;
	end
	-- 自分の発言は無視
	if clusterinfo:GetCommanderName() == GETMYFAMILYNAME() then
		return
	end

	local msgType = clusterinfo:GetMsgType();

	if msgType == "Normal" then
		if g.settings.all.normal then
			CHAT_SOUNDS_PLAYSOUND(soundTypes[tonumber(g.settings.all.normalsound)].sound)
		end
		for i, ver in ipairs(g.settings.word) do
			if g.settings.word[i].normal and g.settings.word[i].word ~= "" and g.settings.word[i].word ~= nil then
				if CHATEXTENDS_SOUND_IS_FINDMSG(clusterinfo:GetMsg(), g.settings.word[i].word) then
					CHAT_SOUNDS_PLAYSOUND(soundTypes[tonumber(g.settings.word[i].sound)].sound)
				end
			end
		end
	elseif msgType == "Shout" then
		if g.settings.all.shout then
			CHAT_SOUNDS_PLAYSOUND(soundTypes[tonumber(g.settings.all.shoutsound)].sound)
		end
		for i, ver in ipairs(g.settings.word) do
			if g.settings.word[i].shout and g.settings.word[i].word ~= "" and g.settings.word[i].word ~= nil then
				if CHATEXTENDS_SOUND_IS_FINDMSG(clusterinfo:GetMsg(), g.settings.word[i].word) then
					CHAT_SOUNDS_PLAYSOUND(soundTypes[tonumber(g.settings.word[i].sound)].sound)
				end
			end
		end
	elseif msgType == "Party" then
		if g.settings.all.party then
			CHAT_SOUNDS_PLAYSOUND(soundTypes[tonumber(g.settings.all.partysound)].sound)
		end
		for i, ver in ipairs(g.settings.word) do
			if g.settings.word[i].party and g.settings.word[i].word ~= "" and g.settings.word[i].word ~= nil then
				if CHATEXTENDS_SOUND_IS_FINDMSG(clusterinfo:GetMsg(), g.settings.word[i].word) then
					CHAT_SOUNDS_PLAYSOUND(soundTypes[tonumber(g.settings.word[i].sound)].sound)
				end
			end
		end
	elseif msgType == "Guild" then
		if g.settings.all.guild then
			CHAT_SOUNDS_PLAYSOUND(soundTypes[tonumber(g.settings.all.guildsound)].sound)
		end
		for i, ver in ipairs(g.settings.word) do
			if g.settings.word[i].guild and g.settings.word[i].word ~= "" and g.settings.word[i].word ~= nil then
				if CHATEXTENDS_SOUND_IS_FINDMSG(clusterinfo:GetMsg(), g.settings.word[i].word) then
					CHAT_SOUNDS_PLAYSOUND(soundTypes[tonumber(g.settings.word[i].sound)].sound)
				end
			end
		end
	elseif msgType == "Whisper" then
		if g.settings.all.whisper then
			CHAT_SOUNDS_PLAYSOUND(soundTypes[tonumber(g.settings.all.whispersound)].sound)
		end
		for i, ver in ipairs(g.settings.word) do
			if g.settings.word[i].whisper and g.settings.word[i].word ~= "" and g.settings.word[i].word ~= nil then
				if CHATEXTENDS_SOUND_IS_FINDMSG(clusterinfo:GetMsg(), g.settings.word[i].word) then
					CHAT_SOUNDS_PLAYSOUND(soundTypes[tonumber(g.settings.word[i].sound)].sound)
				end
			end
		end
	elseif msgType == "Group" then
		if g.settings.all.group then
			CHAT_SOUNDS_PLAYSOUND(soundTypes[tonumber(g.settings.all.groupsound)].sound)
		end
		for i, ver in ipairs(g.settings.word) do
			if g.settings.word[i].group and g.settings.word[i].word ~= "" and g.settings.word[i].word ~= nil then
				if CHATEXTENDS_SOUND_IS_FINDMSG(clusterinfo:GetMsg(), g.settings.word[i].word) then
					CHAT_SOUNDS_PLAYSOUND(soundTypes[tonumber(g.settings.word[i].sound)].sound)
				end
			end
		end
	elseif msgType == "System" or msgType == "Notice" then
		if g.settings.all.system then
			CHAT_SOUNDS_PLAYSOUND(soundTypes[tonumber(g.settings.all.systemsound)].sound)
		end
		for i, ver in ipairs(g.settings.word) do
			if g.settings.word[i].system and g.settings.word[i].word ~= "" and g.settings.word[i].word ~= nil then
				if CHATEXTENDS_SOUND_IS_FINDMSG(clusterinfo:GetMsg(), g.settings.word[i].word) then
					CHAT_SOUNDS_PLAYSOUND(soundTypes[tonumber(g.settings.word[i].sound)].sound)
				end
			end
		end
	end

end


-- tpChatSys使っている場合はシステムメッセージはtpChatSys側から取得
function CHATEXTENDS_SOUND_TPCHATSYS_HOOK_CHAT_SYSTEM_EVENT(frame, msg)
	-- そもそも設定なければ終了
	if not g.settings.flg then
		return;
	end
	local chatbody = acutil.getEventArgs(msg);

	if g.settings.all.system then
		CHAT_SOUNDS_PLAYSOUND(soundTypes[tonumber(g.settings.all.systemsound)].sound)
	end
	for i, ver in ipairs(g.settings.word) do
		if g.settings.word[i].system and g.settings.word[i].word ~= "" and g.settings.word[i].word ~= nil then
			if CHATEXTENDS_SOUND_IS_FINDMSG(chatbody, g.settings.word[i].word) then
				CHAT_SOUNDS_PLAYSOUND(soundTypes[tonumber(g.settings.word[i].sound)].sound)
			end
		end
	end
end

--************************************************
-- 判定
--************************************************
function CHATEXTENDS_SOUND_IS_FINDMSG(msg, findmsg)
	if string.find(CHATEXTENDS_SOUND_GET_MSGBODY(msg),findmsg) then
		return true;
	elseif string.find(CHATEXTENDS_SOUND_GET_MSGBODY_BOSS(msg),findmsg) then
		return true;
	end
	return false;
end

--************************************************
-- リンクなどを消した内容
--************************************************
function CHATEXTENDS_SOUND_GET_MSGBODY(msgbody)
	local logbody="";
	local tempstr="";
	logbody=string.gsub(msgbody,"{.-}", "");

	-- stinrg.gsub内で直接dictionary.ReplaceDicIDInCompStr("%1")とやったが使えなかった
	-- ので、一時変数に入れる
	tempstr=string.match(logbody, "(@dicID.+\*\^)");
	if tempstr ~= nil then
		tempstr = dictionary.ReplaceDicIDInCompStr(tempstr);
		logbody=string.gsub(logbody,"(@dicID.+\*\^)", tempstr);
	end
	return logbody;
end

function CHATEXTENDS_SOUND_GET_MSGBODY_BOSS(msgbody)
	local logbody=msgbody
	local tempstr="";

	tempstr=string.match(logbody, "FieldBossWillAppear");
	if tempstr ~= nil then
		logbody = ClMsg("FieldBossWillAppear");
		logbody = dictionary.ReplaceDicIDInCompStr(logbody);
	end
	return logbody;
end

--************************************************
-- オープン
--************************************************
function CHATEXTENDS_SOUND_FRAME_OPEN()
	ui.CloseFrame("chat");
	CHATEXTENDS_SOUND_FRAME_CREATE();
	ui.OpenFrame("zchatsounds");
end
--************************************************
-- クローズ
--************************************************
function CHATEXTENDS_SOUND_FRAME_SAVECLOSE()
	CHATEXTENDS_SOUND_SAVE_SETTINGS()
	ui.CloseFrame("zchatsounds");
end
function CHATEXTENDS_SOUND_FRAME_CLOSE()
	ui.CloseFrame("zchatsounds");
end

--************************************************
-- フレーム作成
--************************************************
function CHATEXTENDS_SOUND_FRAME_CREATE()
	local frame = ui.GetFrame("zchatsounds");
	frame:Resize(960,840);

	local fontType = "{@st43}{s14}"
	local fontName = "white_16_ol"
	local rtLabel = {
		[1]  = {name="■何でも反応"  ;ename="React at any time"  ; left=30  ; top= 30 ;  h=0; w=0;};
		[2]  = {name=" 一  般 "      ;ename="normal "            ; left=60  ; top= 60 ;  h=0; w=0;};
		[3]  = {name="シャウト"      ;ename=" shout "            ; left=190 ; top= 60 ;  h=0; w=0;};
		[4]  = {name="パーティ"      ;ename=" party "            ; left=320 ; top= 60 ;  h=0; w=0;};
		[5]  = {name=" ギルド "      ;ename=" guild "            ; left=450 ; top= 60 ;  h=0; w=0;};
		[6]  = {name="ささやき"      ;ename="whisper"            ; left=580 ; top= 60 ;  h=0; w=0;};
		[7]  = {name="グループ"      ;ename=" group "            ; left=710 ; top= 60 ;  h=0; w=0;};
		[8]  = {name="システム"      ;ename="system "            ; left=840 ; top= 60 ;  h=0; w=0;};
		[9]  = {name="■単語指定"    ;ename="Respond with words" ; left=30  ; top= 200;  h=0; w=0;};
		[10] = {name="フラグ"        ;ename="flg"                ; left=200 ; top= 210;  h=0; w=0;};
		[11] = {name="単語"          ;ename="word"               ; left=480 ; top= 240;  h=0; w=0;};
		[12] = {name="効果音"        ;ename="sound"              ; left=800 ; top= 240;  h=0; w=0;};
		[13] = {name=" 一  般 "      ;ename="normal "            ; left=40  ; top= 240;  h=0; w=0;};
		[14] = {name="シャウト"      ;ename=" shout "            ; left=100 ; top= 240;  h=0; w=0;};
		[15] = {name="パーティ"      ;ename=" party "            ; left=160 ; top= 240;  h=0; w=0;};
		[16] = {name=" ギルド "      ;ename=" guild "            ; left=220 ; top= 240;  h=0; w=0;};
		[17] = {name="ささやき"      ;ename="whisper"            ; left=280 ; top= 240;  h=0; w=0;};
		[18] = {name="グループ"      ;ename=" group "            ; left=340 ; top= 240;  h=0; w=0;};
		[19] = {name="システム"      ;ename="system "            ; left=400 ; top= 240;  h=0; w=0;};
	};

	for i, ver in ipairs(rtLabel) do
		local header = frame:CreateOrGetControl("richtext", "chatsounds_label"..i, rtLabel[i].left, rtLabel[i].top, rtLabel[i].h, rtLabel[i].w);
		tolua.cast(header, "ui::CRichText");
		header:SetFontName(fontName);
		if option.GetCurrentCountry()=="Japanese" then
			header:SetText(fontType .. rtLabel[i].name .. "{/}");
		else
			header:SetText(fontType .. rtLabel[i].ename .. "{/}");
		end
	end

	local chatSoundsLine = frame:CreateOrGetControl('labelline', 'chatsounds_line', 0, 180, frame:GetWidth(), 2);
	chatSoundsLine:SetSkinName('labelline_def')

	-- 何でも反応部分
	for i = 0, 6 do
		local marginLeft = 130*i
		local rtAll = {
			[1]  = {name="ENABLE"      ;type= "checkbox"; left=80  ; top= 90  ; h=35;  w=35;};
			[2]  = {name="ALL_DROPLIST";type= "droplist"; left=40  ; top= 130 ; h=100; w=20;};
		};

		for j, ver in ipairs(rtAll) do
			local create_CTRL = frame:CreateOrGetControl(rtAll[j].type, rtAll[j].name..i, rtAll[j].left + marginLeft, rtAll[j].top, rtAll[j].h, rtAll[j].w);
			if rtAll[j].type == "checkbox" then
				tolua.cast(create_CTRL, "ui::CCheckBox");
				create_CTRL:SetClickSound("button_click_big");
				create_CTRL:SetAnimation("MouseOnAnim",  "btn_mouseover");
				create_CTRL:SetAnimation("MouseOffAnim", "btn_mouseoff");
				create_CTRL:SetOverSound("button_over");
				create_CTRL:SetEventScript(ui.LBUTTONUP, "CHAT_SOUNDS_ALL_ENABLE");
				create_CTRL:SetUserValue("NUMBER", i);
				create_CTRL:SetCheck(0);
				--ロード値のセット
				if i==0 then
					if g.settings.all.normal then
						create_CTRL:SetCheck(1);
					end
				elseif i==1 then
					if g.settings.all.shout then
						create_CTRL:SetCheck(1);
					end
				elseif i==2 then
					if g.settings.all.party then
						create_CTRL:SetCheck(1);
					end
				elseif i==3 then
					if g.settings.all.guild then
						create_CTRL:SetCheck(1);
					end
				elseif i==4 then
					if g.settings.all.whisper then
						create_CTRL:SetCheck(1);
					end
				elseif i==5 then
					if g.settings.all.group then
						create_CTRL:SetCheck(1);
					end
				elseif i==6 then
					if g.settings.all.system then
						create_CTRL:SetCheck(1);
					end
				end
			elseif rtAll[j].type == "droplist" then
				tolua.cast(create_CTRL, "ui::CDropList");
				create_CTRL:SetSkinName("droplist_normal");
				create_CTRL:SetTextAlign("left", "center");
				for k, v in ipairs(soundTypes) do
					create_CTRL:AddItem(k, string.format("{#FFFFFF}{ol}{b}{s16}%s",v.name), 0, "CHAT_SOUNDS_PLAYSOUND('"..v.sound.."')");
				end
				--ロード値のセット
				if i==0 then
					create_CTRL:SelectItem(g.settings.all.normalsound - 1)
				elseif i==1 then
					create_CTRL:SelectItem(g.settings.all.shoutsound - 1)
				elseif i==2 then
					create_CTRL:SelectItem(g.settings.all.partysound - 1)
				elseif i==3 then
					create_CTRL:SelectItem(g.settings.all.guildsound - 1)
				elseif i==4 then
					create_CTRL:SelectItem(g.settings.all.whispersound - 1)
				elseif i==5 then
					create_CTRL:SelectItem(g.settings.all.groupsound - 1)
				elseif i==6 then
					create_CTRL:SelectItem(g.settings.all.systemsound - 1)
				end
			end
		end


	end

	-- 単語指定
	for i = 1, 15 do
		local marginTop = 35*(i-1)
		local rtWord = {
			[1]  = {name="NORMAL_ENABLE" ;type= "checkbox"; left=60   ; top= 260 ; h=35;  w=35;};
			[2]  = {name="SHOUT_ENABLE"  ;type= "checkbox"; left=120  ; top= 260 ; h=35;  w=35;};
			[3]  = {name="PARTY_ENABLE"  ;type= "checkbox"; left=180  ; top= 260 ; h=35;  w=35;};
			[4]  = {name="GUILD_ENABLE"  ;type= "checkbox"; left=240  ; top= 260 ; h=35;  w=35;};
			[5]  = {name="WHISPER_ENABLE";type= "checkbox"; left=300  ; top= 260 ; h=35;  w=35;};
			[6]  = {name="GROUP_ENABLE"  ;type= "checkbox"; left=360  ; top= 260 ; h=35;  w=35;};
			[7]  = {name="SYSTEM_ENABLE" ;type= "checkbox"; left=420  ; top= 260 ; h=35;  w=35;};
			[8]  = {name="WORD"          ;type= "edit"    ; left=480  ; top= 260 ; h=260; w=33;};
			[9]  = {name="WORD_DROPLIST" ;type= "droplist"; left=780  ; top= 260 ; h=100; w=20;};
		};

		for j, ver in ipairs(rtWord) do
			local create_CTRL = frame:CreateOrGetControl(rtWord[j].type, rtWord[j].name..i, rtWord[j].left, rtWord[j].top + marginTop, rtWord[j].h, rtWord[j].w);
			if rtWord[j].type == "checkbox" then
				tolua.cast(create_CTRL, "ui::CCheckBox");
				create_CTRL:SetClickSound("button_click_big");
				create_CTRL:SetAnimation("MouseOnAnim",  "btn_mouseover");
				create_CTRL:SetAnimation("MouseOffAnim", "btn_mouseoff");
				create_CTRL:SetOverSound("button_over");
				create_CTRL:SetEventScript(ui.LBUTTONUP, "CHAT_SOUNDS_WORD_ENABLE");
				create_CTRL:SetUserValue("NAME", rtWord[j].name);
				create_CTRL:SetUserValue("NUMBER", i);
				create_CTRL:SetCheck(0);
				if rtWord[j].name == "NORMAL_ENABLE" then
					if g.settings.word[i].normal then
						create_CTRL:SetCheck(1);
					end
				elseif rtWord[j].name == "SHOUT_ENABLE" then
					if g.settings.word[i].shout then
						create_CTRL:SetCheck(1);
					end
				elseif rtWord[j].name == "PARTY_ENABLE" then
					if g.settings.word[i].party then
						create_CTRL:SetCheck(1);
					end
				elseif rtWord[j].name == "GUILD_ENABLE" then
					if g.settings.word[i].guild then
						create_CTRL:SetCheck(1);
					end
				elseif rtWord[j].name == "WHISPER_ENABLE" then
					if g.settings.word[i].whisper then
						create_CTRL:SetCheck(1);
					end
				elseif rtWord[j].name == "GROUP_ENABLE" then
					if g.settings.word[i].group then
						create_CTRL:SetCheck(1);
					end
				elseif rtWord[j].name == "SYSTEM_ENABLE" then
					if g.settings.word[i].system then
						create_CTRL:SetCheck(1);
					end
				end
			elseif rtWord[j].type == "edit" then
				tolua.cast(create_CTRL, "ui::CEditControl");
				create_CTRL:MakeTextPack();
				create_CTRL:SetFontName("white_16_ol");
				create_CTRL:SetSkinName("systemmenu_vertical");
				create_CTRL:SetTextAlign("left", "center");
				create_CTRL:SetText(g.settings.word[i].word);
			elseif rtWord[j].type == "droplist" then
				tolua.cast(create_CTRL, "ui::CDropList");
				create_CTRL:SetSkinName("droplist_normal");
				create_CTRL:SetTextAlign("left", "center");
				for k, v in ipairs(soundTypes) do
					create_CTRL:AddItem(k, string.format("{#FFFFFF}{ol}{b}{s16}%s",v.name), 0, "CHAT_SOUNDS_PLAYSOUND('"..v.sound.."')");
				end
				create_CTRL:SelectItem(g.settings.word[i].sound - 1)
			end
		end

	end

	local savebtn = frame:CreateOrGetControl("button", "CHATEXTENDS_SAVE_BUTTON", 550, 800, 100, 24);
	savebtn = tolua.cast(savebtn, "ui::CButton");
	savebtn:SetFontName("white_16_ol");
	savebtn:SetText("SAVE");
	savebtn:SetGravity(ui.LEFT, ui.TOP);
	savebtn:SetClickSound("button_click");
	savebtn:SetOverSound("button_cursor_over_2");
	savebtn:SetAnimation("MouseOnAnim", "btn_mouseover");
	savebtn:SetAnimation("MouseOffAnim", "btn_mouseoff");
	savebtn:SetEventScript(ui.LBUTTONDOWN, "CHATEXTENDS_SOUND_FRAME_SAVECLOSE");

	local cancelbtn = frame:CreateOrGetControl("button", "CHATEXTENDS_CANCEL_BUTTON", 700, 800, 100, 24);
	cancelbtn = tolua.cast(cancelbtn, "ui::CButton");
	cancelbtn:SetFontName("white_16_ol");
	cancelbtn:SetText("CANCEL");
	cancelbtn:SetGravity(ui.LEFT, ui.TOP);
	cancelbtn:SetClickSound("button_click");
	cancelbtn:SetOverSound("button_cursor_over_2");
	cancelbtn:SetAnimation("MouseOnAnim", "btn_mouseover");
	cancelbtn:SetAnimation("MouseOffAnim", "btn_mouseoff");
	cancelbtn:SetEventScript(ui.LBUTTONDOWN, "CHATEXTENDS_SOUND_FRAME_CLOSE");

end

--************************************************
-- 何でも指定チェックボックス処理
--************************************************
function CHAT_SOUNDS_ALL_ENABLE(frame, ctrl, argStr, argNum)
	local num = ctrl:GetUserValue("NUMBER");
	if num == "0" then
		if ctrl:IsChecked() == 1 then
			g.settings.all.normal = true;
		else
			g.settings.all.normal = false;
		end
	elseif num == "1" then
		if ctrl:IsChecked() == 1 then
			g.settings.all.shout = true;
		else
			g.settings.all.shout = false;
		end
	elseif num == "2" then
		if ctrl:IsChecked() == 1 then
			g.settings.all.party = true;
		else
			g.settings.all.party = false;
		end
	elseif num == "3" then
		if ctrl:IsChecked() == 1 then
			g.settings.all.guild = true;
		else
			g.settings.all.guild = false;
		end
	elseif num == "4" then
		if ctrl:IsChecked() == 1 then
			g.settings.all.whisper = true;
		else
			g.settings.all.whisper = false;
		end
	elseif num == "5" then
		if ctrl:IsChecked() == 1 then
			g.settings.all.group = true;
		else
			g.settings.all.group = false;
		end
	elseif num == "6" then
		if ctrl:IsChecked() == 1 then
			g.settings.all.system = true;
		else
			g.settings.all.system = false;
		end
	end
end

--************************************************
-- 単語指定チェックボックス処理
--************************************************
function CHAT_SOUNDS_WORD_ENABLE(frame, ctrl, argStr, argNum)
	local name = ctrl:GetUserValue("NAME");
	local num = tonumber(ctrl:GetUserValue("NUMBER"));

	if name == "NORMAL_ENABLE" then
		if ctrl:IsChecked() == 1 then
			g.settings.word[num].normal = true;
		else
			g.settings.word[num].normal = false;
		end
	elseif name == "SHOUT_ENABLE" then
		if ctrl:IsChecked() == 1 then
			g.settings.word[num].shout = true;
		else
			g.settings.word[num].shout = false;
		end
	elseif name == "PARTY_ENABLE" then
		if ctrl:IsChecked() == 1 then
			g.settings.word[num].party = true;
		else
			g.settings.word[num].party = false;
		end
	elseif name == "GUILD_ENABLE" then
		if ctrl:IsChecked() == 1 then
			g.settings.word[num].guild = true;
		else
			g.settings.word[num].guild = false;
		end
	elseif name == "WHISPER_ENABLE" then
		if ctrl:IsChecked() == 1 then
			g.settings.word[num].whisper = true;
		else
			g.settings.word[num].whisper = false;
		end
	elseif name == "GROUP_ENABLE" then
		if ctrl:IsChecked() == 1 then
			g.settings.word[num].group = true;
		else
			g.settings.word[num].group = false;
		end
	elseif name == "SYSTEM_ENABLE" then
		if ctrl:IsChecked() == 1 then
			g.settings.word[num].system = true;
		else
			g.settings.word[num].system = false;
		end
	end

end


--************************************************
-- 音慣らし
--************************************************
function CHAT_SOUNDS_PLAYSOUND(bgmnames)

	if string.sub(bgmnames,1,5) == "voice" then
		GetMyActor():GetEffect():PlaySound(bgmnames);
	elseif string.sub(bgmnames,1,8) == "PLAYLIST" then
		bgmnames = string.gsub(bgmnames, 'PLAYLIST_', '');
		imcSound.PlayMusic(bgmnames, 1);
	else
		imcSound.PlaySoundEvent(bgmnames);
	end

end
