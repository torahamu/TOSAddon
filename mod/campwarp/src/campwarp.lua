--アドオン名（大文字）
local addonName = "CAMPWARP";
local addonNameLower = string.lower(addonName);
--作者名
local author = "AUTHOR";

--アドオン内で使用する領域を作成。以下、ファイル内のスコープではグローバル変数gでアクセス可
_G["ADDONS"] = _G["ADDONS"] or {};
_G["ADDONS"][author] = _G["ADDONS"][author] or {};
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {};
local g = _G["ADDONS"][author][addonName];

--設定ファイル保存先
g.settingsFileLoc = string.format("../addons/%s/settings.json", addonNameLower);

--ライブラリ読み込み
local acutil = require('acutil');

--デフォルト設定
if not g.loaded then
  g.settings = {
    --有効/無効
    enable = true,
    --フレーム表示場所
    position = {
      x = 0,
      y = 0
    }
  };
end

--lua読み込み時のメッセージ
CHAT_SYSTEM(string.format("%s.lua is loaded", addonName));

function CAMPWARP_SAVESETTINGS()
  acutil.saveJSON(g.settingsFileLoc, g.settings);
end

--マップ読み込み時処理（1度だけ）
function CAMPWARP_ON_INIT(addon, frame)
  g.addon = addon;
  g.frame = frame;
  frame:ShowWindow(0);
  acutil.slashCommand("/"..addonNameLower, CAMPWARP_PROCESS_COMMAND);
  acutil.slashCommand("/cw", CAMPWARP_PROCESS_COMMAND);

  if not g.loaded then
    local t, err = acutil.loadJSON(g.settingsFileLoc, g.settings);
    if err then
      --設定ファイル読み込み失敗時処理
      CHAT_SYSTEM(string.format("[%s] cannot load setting files", addonName));
    else
      --設定ファイル読み込み成功時処理
      g.settings = t;
    end
    g.loaded = true;
  end

  --設定ファイル保存処理
  CAMPWARP_SAVESETTINGS();
  --メッセージ受信登録処理
  addon:RegisterMsg("GAME_START_3SEC", "CAMPWARP_3SEC");

  --コンテキストメニュー
  frame:SetEventScript(ui.RBUTTONDOWN, "CAMPWARP_CONTEXT_MENU");
  --ドラッグ
  frame:SetEventScript(ui.LBUTTONUP, "CAMPWARP_END_DRAG");
end

function CAMPWARP_3SEC()
  --マップ移動直後はキャンプ情報が取得できないので、3秒待つ
  local frame = g.frame;
  --フレーム初期化処理
  CAMPWARP_INIT_FRAME(frame);

  --再表示処理
  if g.settings.enable then
    frame:ShowWindow(1);
  else
    frame:ShowWindow(0);
  end
  --Moveではうまくいかないので、OffSetを使用する…
  frame:Move(0, 0);
  frame:SetOffset(g.settings.position.x, g.settings.position.y);
end

function CAMPWARP_INIT_FRAME(frame)
  --XMLに記載するとデザイン調整時にクライアント再起動が必要になるため、luaに書き込むことをオススメする
  local iconSize = 45;
  local title = frame:CreateOrGetControl("richtext", "title", 5, 3, 0, 15);
  tolua.cast(title, "ui::CRichText");
  title:SetText(string.format("{@st62}Camp Warp{/}"));
  title:EnableHitTest(0);

  local camps = CAMPWARP_GET_CAMPLIST();
  for i, camp in ipairs(camps) do
    local picture = frame:CreateOrGetControl("picture", "picture_"..i, (i-1) * iconSize + 10, 15, iconSize, iconSize);
    tolua.cast(picture, "ui::CPicture");
    picture:SetEnableStretch(1);
    picture:SetImage("minimap_man_market");
    picture:SetEventScript(ui.LBUTTONUP, "CAMPWARP_EXEC_WARP_BUTTON");
    picture:SetEventScriptArgNumber(ui.LBUTTONUP, i);
    picture:SetTextTooltip(camp.name..":"..camp.map.Name);
    
    local name = picture:CreateOrGetControl("richtext", "name_"..i, (i-1) * 0, 0, iconSize, 15);
    tolua.cast(name, "ui::CRichText");
    name:EnableHitTest(0);
    name:EnableResizeByText(0);
    name:SetText(string.format("{@st62}%s{/}", camp.name));
    name:SetGravity(ui.LEFT, ui.BOTTOM);
  end

  if #camps > 0 then
    local width = iconSize * #camps + 10 < title:GetWidth()+5 and title:GetWidth()+5 or iconSize * #camps + 10;
    frame:Resize(width, iconSize + 15);
  else
    frame:Resize(title:GetWidth()+5, title:GetHeight()+5);
  end
end

--コンテキストメニュー表示処理
function CAMPWARP_CONTEXT_MENU(frame, msg, clickedGroupName, argNum)
  local context = ui.CreateContextMenu("CAMPWARP_RBTN", "CampWarp", 0, 0, 300, 100);
  ui.AddContextMenuItem(context, "Hide", "CAMPWARP_TOGGLE_FRAME()");
  context:Resize(300, context:GetHeight());
  ui.OpenContextMenu(context);
end

--表示非表示切り替え処理
function CAMPWARP_TOGGLE_FRAME()
  if g.frame:IsVisible() == 0 then
    --非表示->表示
    g.frame:ShowWindow(1);
    g.settings.enable = true;
  else
    --表示->非表示
    g.frame:ShowWindow(0);
    g.settings.enable = false;
  end

  CAMPWARP_SAVESETTINGS();
end

function CAMPWARP_FRAME_ON()
  if g.frame:IsVisible() == 0 then
    --非表示->表示
    g.frame:ShowWindow(1);
    g.settings.enable = true;
  end

  CAMPWARP_SAVESETTINGS();
end

function CAMPWARP_FRAME_OFF()
  if g.frame:IsVisible() == 1 then
    --表示->非表示
    g.frame:ShowWindow(0);
    g.settings.enable = false;
  end

  CAMPWARP_SAVESETTINGS();
end

--フレーム場所保存処理
function CAMPWARP_END_DRAG()
  g.dragging = false;
  g.settings.position.x = g.frame:GetX();
  g.settings.position.y = g.frame:GetY();
  CAMPWARP_SAVESETTINGS();
end

--チャットコマンド処理（acutil使用時）
function CAMPWARP_PROCESS_COMMAND(command)
  local cmd = "";

  if #command > 0 then
    cmd = table.remove(command, 1);
    if "number" == type(tonumber(cmd)) then
      cmd = tonumber(cmd);
      if cmd then
        CAMPWARP_EXEC_WARP(cmd);
        return;
      end
    elseif string.lower(cmd) == "on" then
      CAMPWARP_FRAME_ON()
      return;
    elseif string.lower(cmd) == "off" then
      CAMPWARP_FRAME_OFF()
      return;
    end
  else
    CAMPWARP_EXEC_WARP(1);
    return;
  end

  CHAT_SYSTEM("[CAMPWARP] Invalid Command");
end

function CAMPWARP_EXEC_WARP_BUTTON(frame, ctrl, argStr, argNum)
  CAMPWARP_EXEC_WARP(argNum)
end

function CAMPWARP_EXEC_WARP(number)
  number = number or 1;
  local camps = CAMPWARP_GET_CAMPLIST()
  local member = camps[number];
  if member ~= nil then
    local message = string.format("warp to %s's camp in %s", member.name, member.map.Name);
    CHAT_SYSTEM(message);
    MOVETOCAMP(member.aid);
    return;
  end
  CHAT_SYSTEM("[CAMPWARP] cannot find camp ");
end

function CAMPWARP_GET_CAMPLIST()
  local list = session.party.GetPartyMemberList(PARTY_NORMAL);
  local count = list:Count();
  local campCount = 0;
  local camps = {};
  for i = 0 , count - 1 do
    local partyMemberInfo = list:Element(i);
    local map = GetClassByType("Map", partyMemberInfo.campMapID);
    if  nil ~= map then
      table.insert(camps, {name=partyMemberInfo:GetName(), aid = partyMemberInfo:GetAID(), map = map});
    end
  end
  return camps;
end
