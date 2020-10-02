local addonName = "INDUNPLUS";
local addonNameLower = string.lower(addonName);
local currentVersion = 4.0;

-- this version of IDP is maintained by member from ToSAC, find us here: https://discord.gg/hgxRFwy
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
    version = currentVersion;
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
    deposit = "0"
  };

  g.sortType = {
    {label="level", attribute="level"},
    {label="name", attribute="name"},
    {label="create date", attribute="cid"},
  };

  g.weekResetWday = 2;
end

function INDUNPLUS_RELOAD()
  local t, err = acutil.loadJSON(g.settingsFileLoc, g.settings);
  if err then
    CHAT_SYSTEM('no indunplus save file');
  else
    CHAT_SYSTEM('indunplus savedata is loaded');
    g.settings = t;
  end

  INDUNPLUS_SHOW_PLAYCOUNT();
end

function INDUNPLUS_GET_OTHER_DUNS()
  local temp = {}
  local result = {};
  local clslist, cnt = GetClassList('contents_info');
  local categoryCount = 1;
  for i = 0, cnt -1 do
    local cls = GetClassByIndexFromList(clslist, i);
    local idx = temp[tostring(cls.ResetGroupID)];
    if idx == nil and cls.Category ~= 'None' then
    local categoryName = dictionary.ReplaceDicIDInCompStr(cls.Category);
    categoryName = string.gsub(categoryName, "^%s*(.-)%s*$", "%1")
    table.insert(result,
    categoryCount,
      {
      ["type"] = tostring(cls.ResetGroupID),
      ["label"] = categoryName,
      ["id"] = cls.ClassID,
      ["level"] = cls.Level,
      ["WeeklyEnterableCount"] = (cls.ResetPer == 'WEEK' and cls.EnterableCount) or 0,
      ["isCharaBased"] = cls.UnitPerReset == 'PC'
      });
      temp[tostring(cls.ResetGroupID)] = categoryCount;
      categoryCount = categoryCount + 1;
    elseif cls.Category ~= 'None' and result[idx]["level"] > cls.Level then
      result[idx]["level"] = cls.Level;
    end
  end
  return result
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
      local categoryName = dictionary.ReplaceDicIDInCompStr(cls.Category);
        if string.find(cls.ClassName, "Casual_") == nil then
          local findLegend = string.find(categoryName,":") or string.find(categoryName,"：")
          if findLegend ~= nil then
            categoryName = string.sub(categoryName,findLegend + 1);
          end
        end
        --trim spaces; well, not fastest, but IMC won't even have their dungeon names like 100+ chars with dozen of spaces, should be fine.....
        categoryName = string.gsub(categoryName, "^%s*(.-)%s*$", "%1")
    
      table.insert(result,
        categoryCount,
        {
          ["type"] = tostring(cls.PlayPerResetType),
          ["label"] = categoryName,
          ["id"] = cls.ClassID,
          ["level"] = cls.Level,
          ["WeeklyEnterableCount"] = cls.WeeklyEnterableCount or 0,
          ["isCharaBased"] = cls.UnitPerReset == 'PC'
        });
      temp[tostring(cls.PlayPerResetType)] = categoryCount;
      categoryCount = categoryCount + 1;
    elseif cls.Category ~= 'None' and result[idx]["level"] > cls.Level then
      result[idx]["level"] = cls.Level;
    end
  end

  local otherInduns = INDUNPLUS_GET_OTHER_DUNS()
  for i=1,#otherInduns do
    result[#result+1] = otherInduns[i]
  end
  return result;
end

function INDUNPLUS_GET_COUNT(indun, resettype)
  local count = 0
  for  i = 1 , #indun do
    if resettype == 'day' and indun[i].WeeklyEnterableCount == 0 then
      count = count + 1
    end
    if resettype == 'week' and indun[i].WeeklyEnterableCount > 0 then
      count = count + 1
    end
  end
  return count;
end
function INDUNPLUS_GET_PLAY_COUNT(indun)
  return GET_CURRENT_ENTERANCE_COUNT(tonumber(indun.type))
end

function INDUNPLUS_GET_MAX_PLAY_COUNT(indun)
  local _getmaxentrance = GET_INDUN_MAX_ENTERANCE_COUNT or GET_MAX_ENTERANCE_COUNT
  local _rt = _getmaxentrance(tonumber(indun.type)) 
  return _rt == "{img infinity_text 20 10}" and tonumber(99) or tonumber(_rt)
end

function INDUNPLUS_GET_RESETTIME(targetwday)
  local currentDate = os.date("*t");
  -- lua言語仕様の日曜日が1始まりを利用して、デフォルトを0(指定なし)
  targetwday = targetwday or 0;

  local resetDate = os.date("*t");
  local resetTime = 0;
  resetDate.hour = g.settings.resetHour;
  resetDate.min = 0;
  resetDate.sec = 0;
  if targetwday == 0 then
    -- 指定がない場合は、毎日6時リセット
    resetTime = os.time(resetDate);

    if currentDate.hour < g.settings.resetHour then
      resetTime = resetTime - 24*3600;
    end
  else
    -- 指定がある場合は、指定曜日の6時リセット
    -- リセットされる日は、指定日-現在の曜日、0以下なら来週として7を足す
    local addwday = targetwday - resetDate.wday;
    if addwday <= 0 then
      addwday = addwday + 7
    end
    resetDate.day = resetDate.day + addwday;
    resetTime = os.time(resetDate);
    -- 月曜かつ6時前なら、来週の月曜6時じゃなくて今日の6時リセットにする
    if addwday == 7 and currentDate.hour < g.settings.resetHour then
      resetTime = resetTime - 24*3600*7;
    end
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
    silverText:SetText("{@st48}{#FFFFFF}{img silver 14 14}"..GET_COMMAED_STRING(record.money).."{/}{/}");
    silverText:SetGravity(ui.RIGHT, ui.TOP);
    silverText:Move((0 - x), 0);
  end

end

function INDUNPLUS_LOAD()
  --総合設定の読み取り
  if not g.loaded then
    local t, err = acutil.loadJSON(g.settingsFileLoc);
    if err then
      CHAT_SYSTEM('no indunplus save file');
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
  local counts = record.counts and record.counts[indun.type];

  if counts == nil or cid == session.GetMySession():GetCID() then
    counts = {
      playCount = INDUNPLUS_GET_PLAY_COUNT(indun),
      maxPlayCount = INDUNPLUS_GET_MAX_PLAY_COUNT(indun),
    };
  end

  local label = indun.label;
  local type = indun.type;
  local color = "FFFFFF";
  
  if record.level ~= nil and indun.level > record.level then
    color = "444444";
  elseif counts.maxPlayCount > 0 and counts.playCount >= counts.maxPlayCount then
    color = "00FF00";
  elseif counts.playCount > 0 then
    color = "FFFF00";
  end

  if string.len(label) > 30 then
    label = string.sub(label, 1, 30) .. "..."
  end
  local maxCountTxt = (counts.maxPlayCount == 99 or counts.maxPlayCount == 0) and "INF" or counts.maxPlayCount
  local labelText = parent:CreateOrGetControl("richtext", "label"..cid.."_"..type, 20, y, width / 2, 15);
  tolua.cast(labelText, "ui::CRichText");
  labelText:SetText(string.format("{@st48}{#%s}{s%d}%s{/}{/}{/}", color, fontSize ,label));

  local countText = parent:CreateOrGetControl("richtext", "count"..cid.."_"..type, 0, y, width / 2, 15);
  tolua.cast(countText, "ui::CRichText");
  countText:SetText(string.format("{@st48}{#%s}{s%d}%d/%s{/}{/}{/}", color, fontSize, counts.playCount, maxCountTxt));
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

  -- バラック順
  local accountInfo = _G.session.barrack.GetMyAccount();
  local cnt = accountInfo:GetBuySlotCount();
  local barrackCls = GetClass("BarrackMap", accountInfo:GetThemaName());
  cnt = cnt + barrackCls.BaseSlot;
  for i = 0 , cnt do
    local slot = accountInfo:GetBySlot(i);
    if slot ~= nil then
      local cid = tostring(slot:GetCID());
      if g.records[cid] ~= nil then
        table.insert(result, g.records[cid]);
      end
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
  local sum = tonumber(tostring(g.settings.deposit) or "0");

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
    --tooltip = tooltip.. string.format("{@st48}%s{img silver 20 20}%s{/}{nl}", record.name ,GET_COMMAED_STRING(record.money));
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
      if record.jobIcon ~= nil then
        job:SetImage(record.jobIcon);
      elseif record.job ~= nil then
        -- 旧バージョンの設定があれば表示
        job:SetImage(GET_JOB_ICON(record.job));
      end

      local y = 5;
      INDUNPLUS_CREATE_CHARALABEL(page, cid, record, fontSize, 12, y, pageWidth, lineHeight);
      y = y + 2;

      for i, indun in ipairs(induns) do
        if indun.isCharaBased then
          y = y + fontSize;
          INDUNPLUS_CREATE_INDUNLINE(page, cid, record, indun, fontSize, 20, y, pageWidth, lineHeight)
        end
      end

      for i, indun in ipairs(induns) do
        if not indun.isCharaBased then
          y = y + fontSize;
          INDUNPLUS_CREATE_INDUNLINE(page, cid, record, indun, fontSize, 20, y, pageWidth, lineHeight)
        end
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
  frame:EnableMove(1);
  frame:SetEventScript(ui.RBUTTONDOWN, "INDUNPLUS_CONTEXT_MENU");
  frame:SetEventScript(ui.LBUTTONDOWN, "INDUNPLUS_START_DRAG");
  frame:SetEventScript(ui.LBUTTONUP, "INDUNPLUS_END_DRAG");

  addon:RegisterMsg("GAME_START_3SEC", "INDUNPLUS_3SEC");
  
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
  g.addon:RegisterMsg("ACCOUNT_WAREHOUSE_WITHDRAW", "INDUNPLUS_SAVE_DEPOSIT");

  acutil.setupEvent(g.addon, "ACCEPT_STOP_LEVEL_CHALLENGE_MODE", "INDUNPLUS_REFRESH_AFTER_CHALLENGE_END")
  g.addon:RegisterMsg("INDUN_REWARD_RESULT", "INDUNPLUS_REFRESH_AND_SHOW_COUNT");

  g.addon:RegisterMsg("NOTICE_Dm_Clear", "INDUNPLUS_REFRESH_AND_SHOW_COUNT");
  g.addon:RegisterMsg("NOTICE_Dm_scroll", "INDUNPLUS_REFRESH_AND_SHOW_COUNT");
  g.addon:RegisterMsg("NOTICE_Dm_raid_clear", "INDUNPLUS_REFRESH_AND_SHOW_COUNT");

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
function INDUNPLUS_REFRESH_AFTER_CHALLENGE_END()
  ReserveScript("INDUNPLUS_REFRESH_AND_SHOW_COUNT()", 5)
end

function INDUNPLUS_REFRESH_AND_SHOW_COUNT()
  ReserveScript("INDUNPLUS_REFRESH_COUNTS()", 0.5)
  ReserveScript("INDUNPLUS_SHOW_PLAYCOUNT()", 1)
end
function INDUNPLUS_SAVE_TIME()
  INDUNPLUS_REFRESH_COUNTS();

  local mySession = session.GetMySession();
  local cid = mySession:GetCID();
  local charName = info.GetName(session.GetMyHandle());
  local time = os.time();
  local level = info.GetLevel(session.GetMyHandle());
  -- 最後に履修したJobID取得
  local job = info.GetJob(session.GetMyHandle());
  -- プレイヤーがゲーム内で設定したJobIconを取得
  local jobIcon = GET_CHILD_RECURSIVELY(ui.GetFrame("headsupdisplay"), "jobPic"):GetImageName()

  g.records[cid] = {
    ["version"] = currentVersion,
    ["cid"] = cid,
    ["level"] = level,
    ["name"] = charName,
    ["time"] = time,
    ["job"] = job,
    ["jobIcon"] = jobIcon,
    ["money"] = GET_TOTAL_MONEY_STR();
    ["counts"] = {},
  };

  local counts = g.records[cid]["counts"];

  local induns = INDUNPLUS_GET_INDUNS();

  for i, indun in ipairs(induns) do
    if indun.isCharaBased then
    counts[indun.type] = {
      ["playCount"] = INDUNPLUS_GET_PLAY_COUNT(indun),
      ["maxPlayCount"] = INDUNPLUS_GET_MAX_PLAY_COUNT(indun),
    };
    end
  end

  local fileName = string.format("../addons/indunplus/%s.json", cid);
  acutil.saveJSON(fileName, g.records[cid]);
end

function INDUNPLUS_REFRESH_COUNTS()
  local mySession = session.GetMySession();
  local mycid = mySession:GetCID();
  local resetTime = INDUNPLUS_GET_RESETTIME();
  for cid, record in pairs(g.records) do
    if record.time < resetTime then

      local counts = record.counts;
      local induns = INDUNPLUS_GET_INDUNS();

      for i, indun in ipairs(induns) do
        if counts[indun.type] == nil then
          counts[indun.type] = {};
        end
        if indun.WeeklyEnterableCount == 0 then
          counts[indun.type]["playCount"] = (cid == mycid and INDUNPLUS_GET_PLAY_COUNT(indun)) or 0;
          counts[indun.type]["maxPlayCount"] = INDUNPLUS_GET_MAX_PLAY_COUNT(indun);
        else
          if os.date("*t").wday == g.weekResetWday then
            local resetWeekTime = INDUNPLUS_GET_RESETTIME(g.weekResetWday);
            if record.time < resetWeekTime then
              counts[indun.type]["playCount"] = (cid == mycid and INDUNPLUS_GET_PLAY_COUNT(indun)) or 0;
              counts[indun.type]["maxPlayCount"] = INDUNPLUS_GET_MAX_PLAY_COUNT(indun);
            end
          end
        end
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
    silverText:SetText("{@st48}{#AAAAAA}"..GET_COMMAED_STRING(invItem.count).."s{/}{/}");
    return;
  end

end

function INDUNPLUS_SAVE_DEPOSIT()
  local itemList = session.GetEtcItemList(IT_ACCOUNT_WAREHOUSE);
  local guidList = itemList:GetGuidList();
  local cnt = guidList:Count();

  for i = 0, cnt - 1 do
    local guid = guidList:Get(i);
    local invItem = itemList:GetItemByGuid(guid);
    local obj = GetIES(invItem:GetObject());
    if obj.ClassName == MONEY_NAME then
      g.settings.deposit = invItem:GetAmountStr();
      acutil.saveJSON(g.settingsFileLoc, g.settings);
      INDUNPLUS_SHOW_PLAYCOUNT();
      return;
    end
  end
end

function INDUNPLUS_UPDATE_TOTAL_MONEY()

  --ツールチップ
  local money = INDUNPLUS_GET_TOTAL_MONEY();
  local depositstr = tostring(g.settings.deposit) or "0";
  local other = money - tonumber(depositstr);
  local outDeposit = GET_COMMAED_STRING(depositstr);
  local outOther = GET_COMMAED_STRING(other);
  local title = GET_CHILD(g.frame, "title", "ui::CRichText");
  local tooltip = string.format("{@st48}Deposit: {img silver 20 20}%s{nl}   Chars: {img silver 20 20}%s{/}", outDeposit, outOther);
  title:SetTextTooltip(tooltip);
  title:EnableHitTest(0)
  local outMoney = GET_COMMAED_STRING(money)
  if g.settings.minimize then
    title:SetText(string.format("{@st48}/idp {img silver 20 20}%s{/}", outMoney));
  else
    title:SetText(string.format("{@st48}Total{img silver 20 20}%s{/}", outMoney));
    title:EnableHitTest(1);
  end
end

function INDUNPLUS_GETCOMMA(num)
  local tempStr = string.format("%09d",num);
  local retStr = "";
  for i = 1, 8 do
    retStr = retStr .. string.sub(tempStr, i, i)
    if i%3 == 0 then
      retStr = retStr .. ","
    end
  end
  retStr = retStr .. string.sub(tempStr, 9, 9)
  return retStr
end
