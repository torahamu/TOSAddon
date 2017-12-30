local addonName = "INDUNPLUS";
local addonNameLower = string.lower(addonName);
local currentVersion = 2.0;

_G['ADDONS'] = _G['ADDONS'] or {};
_G['ADDONS']['MONOGUSA'] = _G['ADDONS']['MONOGUSA'] or {};
_G['ADDONS']['MONOGUSA'][addonName] = _G['ADDONS']['MONOGUSA'][addonName] or {};

local g = _G['ADDONS']['MONOGUSA'][addonName];
local acutil = require('acutil');

g.settingsFileLoc = "../addons/indunplus/settings.json";

if not g.loaded then
  g.isDragging = false;
  g.removingItem = nil;
  g.records = {};
  g.color = {
    normal = "FFFFFFFF",
    nearComplete = "FF00FFFF",
    complete = "FF00FF00",
  };

  g.settings = {
    version = 2.0;
    --ソート指定
    sortType = "level";
    --ソート指定（昇順 or 降順)
    sortAsc = false;
    --表示非表示
    show = true;
    --X座標、Y座標
    xPosition = 500,
    yPosition = 500,
    --リセット時刻
    resetHour = 6,
    --1列に表示するキャラ数
    rowMax = 5,
    --貯金
    deposit = 0
  };

  g.sortType = {
    {label="level", attribute="level"},
    {label="name", attribute="name"},
    {label="create date", attribute="cid"},
  };

  g.challengeDebuffId = 100102;
end

function INDUNPLUS_RELOAD()
  local t, err = acutil.loadJSON(g.settingsFileLoc, g.settings);
  if err then
    CHAT_SYSTEM('no save file');
  else
    CHAT_SYSTEM('indunplus savedata is loaded');
    g.settings = t;
  end

  INDUNPLUS_SHOW_PLAYCOUNT();
end

function INDUNPLUS_GET_INDUNS()
  local clslist, cnt = GetClassList("Indun");
  local temp = {};
  local result = {};

  local categoryCount = 1;
  for i = 0 , cnt - 1 do
    local cls = GetClassByIndexFromList(clslist, i);
    local idx = temp[tostring(cls.PlayPerResetType)];

    if idx == nil and cls.Category ~= 'None' then
      table.insert(result,
        categoryCount,
        {
          ["type"] = tostring(cls.PlayPerResetType),
          ["label"] = cls.Category,
          ["id"] = cls.ClassID,
          ["level"] = cls.Level
        });
      temp[tostring(cls.PlayPerResetType)] = categoryCount;
      categoryCount = categoryCount + 1;
    elseif cls.Category ~= 'None' and result[idx]["level"] > cls.Level then
      result[idx]["level"] = cls.Level;
    end
  end

  return result;
end

function INDUNPLUS_GET_PLAY_COUNT(indun)
  local etcObj = GetMyEtcObject();
  local etcType = "InDunCountType_"..indun.type;
  local count = etcObj[etcType];

  return count;
end

function INDUNPLUS_GET_MAX_PLAY_COUNT(indun)
  if indun.id == 42 then
    return 99;
  end
  local cls = GetClassByType("Indun", indun.id);
  local maxPlayCnt = cls.PlayPerReset;
  if true == session.loginInfo.IsPremiumState(ITEM_TOKEN) then 
    maxPlayCnt = maxPlayCnt + cls.PlayPerReset_Token;
  end

  return maxPlayCnt;
end

function INDUNPLUS_GET_RESETTIME()
  local currentDate = os.date("*t");

  local resetDate = os.date("*t");
  resetDate.hour = g.settings.resetHour;
  resetDate.min = 0;
  resetDate.sec = 0;

  local resetTime = os.time(resetDate);

  if currentDate.hour < g.settings.resetHour then
    resetTime = resetTime - 24*3600;
  end

  return resetTime;
end

function INDUNPLUS_CREATE_CHARALABEL(parent, cid, record, fontSize, x, y, width, height)
  local charaText = parent:CreateOrGetControl("richtext", "record"..cid, x, y, width, height)
  tolua.cast(charaText, "ui::CRichText");
  local text = "";

  local color = "FFFFFF"
  if cid == session.GetMySession():GetCID() then
    color = "FFFF00";
  end

  if record.level == nil then
    text = string.format("{@st48}{#%s}{s%d}%s{/}{/}{/}", color, fontSize, record.name);
  else
    text = string.format("{@st48}{#%s}{s%d}Lv%d %s{/}{/}{/}", color, fontSize, record.level, record.name);
  end

  charaText:SetText(text);

  if record.money ~= nil then
    local silverText = parent:CreateOrGetControl("richtext", "silver_"..cid, x, y, width, height)
    tolua.cast(silverText, "ui::CRichText");
    silverText:SetText("{@st48}{#AAAAAA}"..GetCommaedText(record.money).."s{/}{/}");
    silverText:SetGravity(ui.RIGHT, ui.TOP);
  end

end

function INDUNPLUS_CREATE_CHALLENGETIME(parent, cid, record, fontSize, x, y, width, height)
  local challengeLabelText = parent:CreateOrGetControl("richtext", "challengeLabel"..cid, x, y, width, height)
  local challengeText = parent:CreateOrGetControl("richtext", "challengeDebuff"..cid, x, y, width, height)

  local color = "00FF00";
  local playCount = 1;
  if nil == record.challengeDebuffTime or record.challengeDebuffTime == 0 or record.challengeDebuffTime <= os.time() then
    color = "FFFFFF";
    playCount = 0;
  end
  challengeLabelText:ShowWindow(1);
  challengeText:ShowWindow(1);

  local text = string.format("{@st48}{#%s}{s%d}%s{/}{/}{/}", color, fontSize, "Challenge");
  tolua.cast(challengeLabelText, "ui::CRichText");
  challengeLabelText:SetText(text);

  local challengeDate = os.date("*t", record.challengeDebuffTime);
  tolua.cast(challengeText, "ui::CRichText");

  challengeText:SetText(string.format("{@st48}{#%s}{s%d}%d/%d{/}{/}{/}",color, fontSize, playCount, 1));
  challengeText:SetGravity(ui.RIGHT, ui.TOP);

  return true;
end

function INDUNPLUS_LOAD()
  --総合設定の読み取り
  if not g.loaded then
    local t, err = acutil.loadJSON(g.settingsFileLoc);
    if err then
      CHAT_SYSTEM('no save file');
    else
      if t.version ~= nil and t.version >= currentVersion then
        CHAT_SYSTEM('[indunplus] savedata is loaded');
        g.settings = t;
      else
        CHAT_SYSTEM('[indunplus] delete old version save data');
        acutil.saveJSON(g.settingsFileLoc, g.settings);
      end
    end
    g.loaded = true;
  end

  --キャラごとのデータを読み込み
  local accountInfo = session.barrack.GetMyAccount();
  local cnt = accountInfo:GetPCCount();
  for i = 0 , cnt - 1 do
    local pcInfo = accountInfo:GetPCByIndex(i);
    local cid = tostring(pcInfo:GetCID());
    local fileName = string.format("../addons/indunplus/%s.json", cid);
    local t, err = acutil.loadJSON(fileName);
    if not err then
      if t.version ~= nil and t.version >= currentVersion then
        g.records[cid] = t;
      end
    end
  end
end


function INDUNPLUS_CREATE_INDUNLINE(parent, cid, record, indun, fontSize, x, y, width, height)

  local counts = record.counts[indun.type];

  if counts == nil then
    counts = {
      playCount = 0,
      maxPlayCount = INDUNPLUS_GET_MAX_PLAY_COUNT(indun),
    };
  end

  local label = indun.label;
  local type = indun.type;
  local color = "FFFFFF";

  if record.level ~= nil and indun.level > record.level then
    color = "444444";
  elseif counts.playCount >= counts.maxPlayCount then
    color = "00FF00";
  elseif counts.playCount > 0 then
    color = "FFFF00";
  end

  local labelText = parent:CreateOrGetControl("richtext", "label"..cid.."_"..type, 20, y, width / 2, 15);
  tolua.cast(labelText, "ui::CRichText");
  labelText:SetText(string.format("{@st48}{#%s}{s%d}%s{/}{/}{/}", color, fontSize ,label));

  local countText = parent:CreateOrGetControl("richtext", "count"..cid.."_"..type, 0, y, width / 2, 15);
  tolua.cast(countText, "ui::CRichText");
  countText:SetText(string.format("{@st48}{#%s}{s%d}%d/%s{/}{/}{/}", color, fontSize, counts.playCount, counts.maxPlayCount));
  countText:SetGravity(ui.RIGHT, ui.TOP);
end

function INDUNPLUS_TOGGLE_FRAME()
  if g.frame:IsVisible() == 0 then
    g.frame:ShowWindow(1);
    g.settings.show = true;
  else
    g.frame:ShowWindow(0);
    g.settings.show = false;
  end

  acutil.saveJSON(g.settingsFileLoc, g.settings);
end

function INDUNPLUS_GET_SORT_RECORDS()
  local attribute = g.settings.sortType or "level";
  local asc = true;
  if g.settings.sortAsc ~= nil then
    asc = g.settings.sortAsc;
  end

  --配列を複製し、ソート可能な形に変換する
  local result = {}

  for cid, record in pairs(g.records) do
    local pcPCInfo = session.barrack.GetMyAccount():GetByStrCID(cid);
    if pcPCInfo ~= nil then
      table.insert(result, record);
    end
  end

--  if attribute == "level" then
--    table.sort(result, function(a, b)
--        local comp = a.level < b.level;
--        if not asc then
--          return not comp
--        end
--        return comp;
--      end);
--  elseif attribute == "cid" then
--    table.sort(result, function(a, b)
--        local comp = tonumber(a.cid) < tonumber(b.cid);
--        if not asc then
--          return not comp
--        end
--        return comp;
--      end);
--  elseif attribute == "name" then
--    table.sort(result, function(a, b)
--        local comp = string.lower(a.name) < string.lower(b.name);
--        if not asc then
--          return not comp
--        end
--        return comp;
--      end);
--  end

  --指定された要素を比較し、並び替えを行う
  return result;
end


function INDUNPLUS_GET_TOTAL_MONEY()
  local sum = g.settings.deposit or 0;
  for i, record in pairs(g.records) do
    sum = sum + record.money
  end

  return sum
end

function INDUNPLUS_SHOW_PLAYCOUNT()
  local records = INDUNPLUS_GET_SORT_RECORDS();

  local frame = ui.GetFrame("indunplus");
  local fontSize = 16
  local lineHeight = fontSize + 6;
  local induns = INDUNPLUS_GET_INDUNS();
  local lineNum = #induns + 3;

  local topMargin,bottomMargin = 30, 20;
  local width, height = 0, 0;
  local cnt = 0;
  local rowMax = g.settings.rowMax or 5;

  local row = 0;
  local col = 0;

  local pageX = 0;
  local pageY = 15;
  local pageWidth = 250;
  local pageHeight = fontSize * lineNum + 15;

  local title = GET_CHILD(frame, "title", "ui::CRichText");
  local minButton = frame:CreateOrGetControl("button", "minimize", 0, 0, 25, 25);

  INDUNPLUS_UPDATE_TOTAL_MONEY();
  if g.settings.minimize then
    --最小化時
    minButton:Move(0, 0);
    minButton:SetOffset(250 -30, 5);
    frame:Resize(250, 35);
    frame:Move(0, 0);
    frame:SetOffset(g.settings.xPosition, g.settings.yPosition);
    title:EnableHitTest(0);
    return;
  else
    title:EnableHitTest(1);
  end

  for i, record in ipairs(records) do
    local cid = record.cid;
    --tooltip = tooltip.. string.format("{@st48}%s{img silver 20 20}%s{/}{nl}", record.name ,GetCommaedText(record.money));
    local pcPCInfo = session.barrack.GetMyAccount():GetByStrCID(cid);
    if pcPCInfo ~= nil then
      if cnt > 0 and cnt % rowMax == 0 then
        row = 0;
        height = 0;
        col = col + 1;
        pageX = pageWidth * col;
      end

      pageY = pageHeight * row + topMargin;
      local page = frame:CreateOrGetControl("groupbox", "page_"..cid, pageX , pageY, pageWidth, pageHeight);
      page:SetSkinName('None');
      page:EnableHitTest(0);

      local job = page:CreateOrGetControl("picture", "job_"..cid, 100, lineHeight/2, 128, 128);
      tolua.cast(job, "ui::CPicture");
      job:SetGravity(ui.LEFT, ui.TOP);
      job:SetEnableStretch(1);
      job:SetColorTone("AAFFFFFF");
      if record.job ~= nil then
        job:SetImage(GET_JOB_ICON(record.job));
      end

      local y = 5;
      INDUNPLUS_CREATE_CHARALABEL(page, cid, record, fontSize, 12, y, pageWidth, lineHeight);
      y = y + 2;

      y = y + fontSize;
      if not INDUNPLUS_CREATE_CHALLENGETIME(page, cid, record, fontSize, 20, y, pageWidth, lineHeight) then
        y = y - fontSize;
      end

      for i, indun in ipairs(induns) do
        y = y + fontSize;
        INDUNPLUS_CREATE_INDUNLINE(page, cid, record, indun, fontSize, 20, y, pageWidth, lineHeight)
      end

      page:Resize(pageWidth, pageHeight);

      if cnt < rowMax then
        height = pageHeight * (row + 1) + bottomMargin + topMargin;
      else
        height = pageHeight * rowMax + bottomMargin + topMargin;
      end

      cnt = cnt + 1;
      row = row + 1;
    end
  end

  minButton:Move(0, 0);
  minButton:SetOffset(pageWidth * (col + 1) -30, 10);
  frame:Resize(pageWidth * (col + 1) + 10, height);
  frame:Move(0, 0);
  frame:SetOffset(g.settings.xPosition, g.settings.yPosition);
end

function INDUNPLUS_MINIMIZE_FRAME()
  local frame = g.frame;
  g.settings.xPosition = frame:GetX();
  g.settings.yPosition = frame:GetY();
  g.settings.minimize = not g.settings.minimize;

  acutil.saveJSON(g.settingsFileLoc, g.settings);
  INDUNPLUS_SHOW_PLAYCOUNT();
end

function INDUNPLUS_ON_INIT(addon, frame)
  g.addon = addon;
  g.frame = frame;
  g.records = {};
  frame:ShowWindow(0);
  frame:EnableHitTest(1);
  frame:SetEventScript(ui.RBUTTONDOWN, "INDUNPLUS_CONTEXT_MENU");
  frame:SetEventScript(ui.LBUTTONDOWN, "INDUNPLUS_START_DRAG");
  frame:SetEventScript(ui.LBUTTONUP, "INDUNPLUS_END_DRAG");

  addon:RegisterMsg("GAME_START_3SEC", "INDUNPLUS_3SEC");
  --バフ
  addon:RegisterMsg('BUFF_ADD', 'INDUNPLUS_UPDATE_BUFF');
  addon:RegisterMsg('BUFF_REMOVE', 'INDUNPLUS_UPDATE_BUFF');

  local title = frame:CreateOrGetControl("richtext", "title", 10, 12, 200, 16);
  title:EnableHitTest(0);

  local minButton = frame:CreateOrGetControl("button", "minimize", 0, 0, 25, 25);
  minButton:SetEventScript(ui.LBUTTONDOWN, "INDUNPLUS_MINIMIZE_FRAME");
  minButton:SetText("_");
end

function INDUNPLUS_CONTEXT_MENU(frame, msg, clickedGroupName, argNum)
  local context = ui.CreateContextMenu("INDUNPLUS_RBTN", "IndunPlus", 0, 0, 150, 100);
  ui.AddContextMenuItem(context, "Hide (/idp)", "INDUNPLUS_TOGGLE_FRAME()");
  ui.AddContextMenuItem(context, "Toggle Minimize", "INDUNPLUS_MINIMIZE_FRAME()");

--  --ソート|>
--  local subContextSort = ui.CreateContextMenu("SUBCONTEXT_SORT", "", 0, 0, 100, 0);
--  --ソート選択
--  local subContextSortType = ui.CreateContextMenu("SUBCONTEXT_SORTTYPE", "", 0, 0, 50, 0);
--  for i, sortType in ipairs(g.sortType) do
--    local subContextSortType = ui.CreateContextMenu("SUBCONTEXT_SORTTYPE_"..sortType.label, "", 0, 0, 0, 0);
--    ui.AddContextMenuItem(subContextSortType, "asc(昇順)", string.format("INDUNPLUS_CHANGE_SORTTYPE(%d, true)", i));
--    ui.AddContextMenuItem(subContextSortType, "desc(降順)", string.format("INDUNPLUS_CHANGE_SORTTYPE(%d, false)", i));
--    ui.AddContextMenuItem(subContextSort, sortType.label.."{img white_right_arrow 18 18}", "", nil, 0, 1, subContextSortType);
--  end
--  ui.AddContextMenuItem(context, "Sort {img white_right_arrow 18 18}", "", nil, 0, 1, subContextSort);
--  subContextSort:Resize(150, subContextSort:GetHeight());

  local subContextRowNum = ui.CreateContextMenu("SUBCONTEXT_ROWNUM", "", 0, 0, 0, 0);
  for i = 1, 5 do
    ui.AddContextMenuItem(subContextRowNum, ""..i , string.format("INDUNPLUS_CHANGE_ROWNUM(%d)", i));
  end

  ui.AddContextMenuItem(context, "Row Num {img white_right_arrow 18 18}", "", nil, 0, 1, subContextRowNum);

  context:Resize(150, context:GetHeight());
  ui.OpenContextMenu(context);
end

function INDUNPLUS_CHANGE_SORTTYPE(index, asc)
  local sortType = g.sortType[index].attribute;
  g.settings.sortType = sortType;
  g.settings.sortAsc = asc;
  acutil.saveJSON(g.settingsFileLoc, g.settings);
  INDUNPLUS_SHOW_PLAYCOUNT();
end

function INDUNPLUS_CHANGE_ROWNUM(num)
  g.settings.rowMax = num;
  acutil.saveJSON(g.settingsFileLoc, g.settings);
  INDUNPLUS_SHOW_PLAYCOUNT();
end

function INDUNPLUS_UPDATE_BUFF(frame, msg, argStr, argNum)
  if argNum == g.challengeDebuffId then
    if msg == "BUFF_ADD" then
      INDUNPLUS_CHECK_BUFF();
      INDUNPLUS_SHOW_PLAYCOUNT();
    elseif msg == "BUFF_REMOVE" then
      INDUNPLUS_SAVE_CHALLENGEDEBUFF(0);
      INDUNPLUS_SHOW_PLAYCOUNT();
    end
  end
end

function INDUNPLUS_SAVE_CHALLENGEDEBUFF(challengeTime)
  local mySession = session.GetMySession();
  local cid = mySession:GetCID();

  g.records[cid]["challengeDebuffTime"] = challengeTime;
  local fileName = string.format("../addons/indunplus/%s.json", cid);
  acutil.saveJSON(fileName, g.records[cid]);
end

function INDUNPLUS_CHECK_BUFF()
  local challengeDebuff = false;
  local challengeTime = 0;

  local handle = session.GetMyHandle();
  local buffCount = info.GetBuffCount(handle);

  for i = 0, buffCount - 1 do
    local buff = info.GetBuffIndexed(handle, i);

    if buff.buffID == g.challengeDebuffId then
      challengeDebuff = true;
      challengeTime = os.time() + math.floor(buff.time / 1000);
    end
  end

  INDUNPLUS_SAVE_CHALLENGEDEBUFF(challengeTime);
end

function INDUNPLUS_START_DRAG(addon, frame)
  g.isDragging = true;
end

function INDUNPLUS_END_DRAG(addon, frame)
  g.isDragging = false;
  g.settings.xPosition = g.frame:GetX();
  g.settings.yPosition = g.frame:GetY();
  acutil.saveJSON(g.settingsFileLoc, g.settings);
end


function INDUNPLUS_3SEC()
  acutil.slashCommand("/idp", INDUNPLUS_TOGGLE_FRAME);

  --アイテム
  g.addon:RegisterMsg('INV_ITEM_ADD', 'INDUNPLUS_ON_ITEM_CHANGE_COUNT');
  g.addon:RegisterMsg('INV_ITEM_REMOVE', 'INDUNPLUS_ON_ITEM_CHANGE_COUNT');
  g.addon:RegisterMsg('INV_ITEM_CHANGE_COUNT', 'INDUNPLUS_ON_ITEM_CHANGE_COUNT');
  --銀行
 	g.addon:RegisterMsg("ACCOUNT_WAREHOUSE_ITEM_LIST", "INDUNPLUS_SAVE_DEPOSIT");
	g.addon:RegisterMsg("ACCOUNT_WAREHOUSE_ITEM_ADD", "INDUNPLUS_SAVE_DEPOSIT");
	g.addon:RegisterMsg("ACCOUNT_WAREHOUSE_ITEM_REMOVE", "INDUNPLUS_SAVE_DEPOSIT");
	g.addon:RegisterMsg("ACCOUNT_WAREHOUSE_ITEM_CHANGE_COUNT", "INDUNPLUS_SAVE_DEPOSIT");
	g.addon:RegisterMsg("ACCOUNT_WAREHOUSE_ITEM_IN", "INDUNPLUS_SAVE_DEPOSIT");

  INDUNPLUS_LOAD();
  local frame = g.frame;

  INDUNPLUS_SAVE_TIME();
  INDUNPLUS_SHOW_PLAYCOUNT();

  if frame ~= nil then
    if g.settings.show then
      frame:ShowWindow(1);
    else
      frame:ShowWindow(0);
    end
    frame:Move(0, 0);
    frame:SetOffset(g.settings.xPosition, g.settings.yPosition);
  end
end

function INDUNPLUS_SAVE_TIME()
  INDUNPLUS_REFLESH_COUNTS();

  local mySession = session.GetMySession();
  local cid = mySession:GetCID();
  local charName = info.GetName(session.GetMyHandle());
  local time = os.time();
  local level = info.GetLevel(session.GetMyHandle());
  local job = info.GetJob(session.GetMyHandle());

  g.records[cid] = {
    ["version"] = currentVersion,
    ["cid"] = cid,
    ["level"] = level,
    ["name"] = charName,
    ["time"] = time,
    ["job"] = job,
    ["money"] = GET_TOTAL_MONEY();
    ["counts"] = {},
  };

  INDUNPLUS_CHECK_BUFF();

  local counts = g.records[cid]["counts"];

  local induns = INDUNPLUS_GET_INDUNS();

  for i, indun in ipairs(induns) do
    counts[indun.type] = {
      ["playCount"] = INDUNPLUS_GET_PLAY_COUNT(indun),
      ["maxPlayCount"] = INDUNPLUS_GET_MAX_PLAY_COUNT(indun),
    };
  end

  local fileName = string.format("../addons/indunplus/%s.json", cid);
  acutil.saveJSON(fileName, g.records[cid]);
end

function INDUNPLUS_REFLESH_COUNTS()
  local resetTime = INDUNPLUS_GET_RESETTIME();

  for cid, record in pairs(g.records) do
    if record.time < resetTime then

      local counts = record.counts;
      local induns = INDUNPLUS_GET_INDUNS();

      for i, indun in ipairs(induns) do
        if counts[indun.type] == nil then
          counts[indun.type] = {};
        end
        counts[indun.type]["playCount"] = 0;
        counts[indun.type]["maxPlayCount"] = INDUNPLUS_GET_MAX_PLAY_COUNT(indun);
      end
    end
  end
end

function INDUNPLUS_ON_ITEM_CHANGE_COUNT(frame, msg, argStr, argNum)
  local invItem, itemCls = nil, nil;
  if msg == "INV_ITEM_ADD" then
    invItem = session.GetInvItem(argNum);
  else
    invItem = GET_PC_ITEM_BY_GUID(argStr);
  end

  itemCls = GetIES(invItem:GetObject());
  if MONEY_NAME == itemCls.ClassName then
    --金情報を更新
    local cid = session.GetMySession():GetCID();
    g.records[cid]["money"] = invItem.count;
    local fileName = string.format("../addons/indunplus/%s.json", cid);
    acutil.saveJSON(fileName, g.records[cid]);
    INDUNPLUS_UPDATE_TOTAL_MONEY();
    local silverText = GET_CHILD_RECURSIVELY(g.frame, "silver_"..cid, "ui::CRichText");
    silverText:SetText("{@st48}{#AAAAAA}"..GetCommaedText(invItem.count).."s{/}{/}");
    return;
  end

end

function INDUNPLUS_SAVE_DEPOSIT()
  local itemList = session.GetEtcItemList(IT_ACCOUNT_WAREHOUSE);
  local index = itemList:Head();
  local itemCnt = itemList:Count();
  local deposit = 0;

  while itemList:InvalidIndex() ~= index do
    local invItem = itemList:Element(index);
    local obj = GetIES(invItem:GetObject());
    if obj.ClassName == MONEY_NAME then
      g.settings.deposit = invItem.count;
      acutil.saveJSON(g.settingsFileLoc, g.settings);
      INDUNPLUS_SHOW_PLAYCOUNT();
      return;
    end
    index = itemList:Next(index);
  end
end

function INDUNPLUS_UPDATE_TOTAL_MONEY()
  local money = INDUNPLUS_GET_TOTAL_MONEY();
  local title = GET_CHILD(g.frame, "title", "ui::CRichText");
  
  --ツールチップ
  local deposit = g.settings.deposit or 0;
  local other = money - g.settings.deposit;
  local tooltip = string.format("{@st48}Deposit {img silver 20 20}%s{nl}Other   {img silver 20 20}%s{/}", GetCommaedText(deposit), GetCommaedText(other));
  title:SetTextTooltip(tooltip);

  if g.settings.minimize then
    title:SetText(string.format("{@st48}/idp {img silver 20 20}%s{/}", GetCommaedText(money)));
  else
    title:SetText(string.format("{@st48}Total{img silver 20 20}%s{/}", GetCommaedText(money)));
  end
end
