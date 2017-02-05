-- フラグ
CLASSLIST_ON_INITIAL=false;
CLASSLIST_ON_SETTING=false;

-- ツリー内容
-- アイテム一覧とか毎回呼び出すの重いからグローバルで保管
CLASSLIST_ITEM_TREE=nil;
CLASSLIST_MONSTER_TREE=nil;
--************************************************
-- ON_INIT
-- devconにボタン登録
-- 読み込み順の関係でZ
--************************************************
function ZCLASSLIST_ON_INIT(addon, frame)
	if not CLASSLIST_ON_INITIAL then
		local devconsole = ui.GetFrame("developerconsole");
		local classListButton = devconsole:CreateOrGetControl('button', 'classlist_btn', 690,415,100,40);
		tolua.cast(classListButton, 'ui::CButton');
		classListButton:SetText("Class List");
		classListButton:SetEventScript(ui.LBUTTONUP, "OPEN_CLASSLIST");
		CLASSLIST_ON_INITIAL = true;
	end
end

--************************************************
-- フレームを開く
-- 初回読み込みの場合はフレーム内部の設定をする
--************************************************
function OPEN_CLASSLIST()

	local frame = ui.GetFrame("zclasslist");
	-- 初回のみ処理
	if not CLASSLIST_ON_SETTING then
		SETTING_CLASSLIST(frame)
		CLASSLIST_ON_SETTING = true;
	end
	frame:ShowWindow(1);

end

--************************************************
-- フレーム設定
-- 初回のみ行う
--************************************************
function SETTING_CLASSLIST(frame)

	local itemList = frame:GetChild("ItemList");
	local monsterList = frame:GetChild("MonsterList");
	local itemSearch = frame:GetChild("ItemSearch");
	local execItemSearch = frame:GetChild("ExecItemSearch");
	local monSearch = frame:GetChild("MonSearch");
	local execMonSearch = frame:GetChild("ExecMonSearch");

	CLASSLIST_ITEM_TREE = itemList:GetChild("ItemTree");
	CLASSLIST_MONSTER_TREE = monsterList:GetChild("MonsterTree");

	tolua.cast(itemList, "ui::CGroupBox");
	tolua.cast(CLASSLIST_ITEM_TREE, "ui::CTreeControl");
	tolua.cast(monsterList, "ui::CGroupBox");
	tolua.cast(CLASSLIST_MONSTER_TREE, "ui::CTreeControl");

	UPDATE_ITEM_LIST(frame);
	UPDATE_MONSTER_LIST(frame);

	itemList:ShowWindow(1);
	itemSearch:ShowWindow(1);
	execItemSearch:ShowWindow(1);
	monsterList:ShowWindow(0);
	monSearch:ShowWindow(0);
	execMonSearch:ShowWindow(0);

	itemSearch:SetOffset(30,50);
	execItemSearch:SetOffset(30,50);
	monSearch:SetOffset(30,50);
	execMonSearch:SetOffset(30,50);
end

--************************************************
-- タブ変更時の動作
--************************************************
function CLASSLIST_TAB_CHANGE(frame, obj, argStr, argNum)
	local itemList = frame:GetChild("ItemList");
	local monsterList = frame:GetChild("MonsterList");
	local itemSearch = frame:GetChild("ItemSearch");
	local execItemSearch = frame:GetChild("ExecItemSearch");
	local monSearch = frame:GetChild("MonSearch");
	local execMonSearch = frame:GetChild("ExecMonSearch");

	local tabObj = frame:GetChild("ClassListTab");
	tolua.cast(tabObj, "ui::CTabControl");

	-- タブ内どれが押されたか、はindexで判断する
	-- indexは0始まりで、xmlで定義した順番だと思われる
	local tabIndex = tabObj:GetSelectItemIndex();

	if (tabIndex == 0) then
		itemList:ShowWindow(1);
		itemSearch:ShowWindow(1);
		execItemSearch:ShowWindow(1);
		monsterList:ShowWindow(0);
		monSearch:ShowWindow(0);
		execMonSearch:ShowWindow(0);
	else
		itemList:ShowWindow(0);
		itemSearch:ShowWindow(0);
		execItemSearch:ShowWindow(0);
		monsterList:ShowWindow(1);
		monSearch:ShowWindow(1);
		execMonSearch:ShowWindow(1);
	end
end

--************************************************
-- アイテムの検索ボタン押下時
-- 表示更新へ飛ばす
--************************************************
function SEARCH_ITEM_CLASSLIST(frame, ctrl)
	UPDATE_ITEM_LIST(frame);
end

--************************************************
-- アイテムリスト表示更新
-- 描画処理へ飛ばす
--************************************************
function UPDATE_ITEM_LIST(frame)

	frame = frame:GetTopParentFrame();
	local edit = GET_CHILD(frame, "ItemSearch", "ui::CEditControl");
	-- 描画処理
	DRAW_TREE_LIST(edit:GetText(), CLASSLIST_ITEM_TREE, "Item");
end

--************************************************
-- モンスターの検索ボタン押下時
-- 表示更新へ飛ばす
--************************************************
function SEARCH_MON_CLASSLIST(frame, ctrl)
	UPDATE_MONSTER_LIST(frame);
end

--************************************************
-- アイテムリスト表示更新
-- 描画処理へ飛ばす
--************************************************
function UPDATE_MONSTER_LIST(frame)
	frame = frame:GetTopParentFrame();
	local edit = GET_CHILD(frame, "MonSearch", "ui::CEditControl");
	-- 描画処理
	DRAW_TREE_LIST(edit:GetText(), CLASSLIST_MONSTER_TREE, "Monster");
end

--************************************************
-- フレーム右上×ボタン
--************************************************
function CLOSE_CLASSLIST()
	ui.CloseFrame('classlist');
end

--************************************************
-- 描画処理
-- 　引数：String cap
-- 　　　　検索文字列　初回は空白
-- 　引数：FrameObject tree
-- 　　　　ツリーオブジェクト
-- 　　　　このアドオンだとCLASSLIST_ITEM_TREEかCLASSLIST_MONSTER_TREEのどちらか
-- 　引数：String mode
-- 　　　　Item or Monster
-- 　　　　この文字を元にGetClassをする
--************************************************
function DRAW_TREE_LIST(cap, tree, mode)

	-- 検索用に大文字変換したもの
	local capUpper = string.upper(cap);

	local categoryCount = 0;
	local categoryList = {};

	-- ツリーオブジェクト初期化
	tree:Clear();
	tree:EnableDrawFrame(true);
	tree:SetFitToChild(true,60); --これがないとスクロールを素早くした時にフレームオブジェクトが残ってしまう。2個目の数字はマージン量
	tree:SetFontName("white_20_ol");

	local clslist, cnt  = GetClassList(mode);
	for i = 0 , cnt - 1 do
		local cls = GetClassByIndexFromList(clslist, i);
		local name = dictionary.ReplaceDicIDInCompStr(cls.Name);
		if cap == "" or string.find(name, cap) ~= nil or string.find(string.upper(cls.ClassName),capUpper) ~= nil or string.find(cls.ClassID, cap) ~= nil then
			local categoryName= cls.GroupName;
			local isExist = 0;
			local n = 1;

			-- ツリーにカテゴリ追加
			-- ツリーに追加するアイテムのカテゴリが既にあれば、追加はしない
			for n = 1, categoryCount do
				if categoryList[n] == categoryName then
					isExist = 1;
					break;
				end
			end

			-- ツリーにカテゴリがなければカテゴリ追加
			if isExist == 0 then
				categoryCount = categoryCount + 1;
				categoryList[categoryCount] = categoryName;
				-- tree:Addの引数1個(String)の時はカテゴリ追加
				tree:Add(categoryName);
			end

			local itemName = cls.Name;
			local value = cls.ClassID;

			local nodeName = tree:CreateOrGetControl("richtext",mode.."node"..value,0,0,0,0)
			tolua.cast(nodeName, "ui::CRichText");
			nodeName:EnableResizeByText(1);
			nodeName:SetText(string.format("{@st41b}(%d) %s", value, name));
			nodeName:SetTooltipType('wholeitem');
			nodeName:SetTooltipArg('', value, 0);

			local parentCategory = tree:FindByCaption(categoryName);

			-- tree:Addの引数3個(Object, Object, Object)の時はアイテム追加
			-- 1個目：親カテゴリ名　このカテゴリにアイテムを追加する
			-- 2個目：アイテム表示　ツリー内に表示させる文字。String文字列でもObjectでも何でもいい
			-- 3個目：ID　ツリー内で一意になれば何でもいい？
			tree:Add(parentCategory, nodeName, value);

		end
	end

	if cap ~= "" then
		tree:OpenNodeAll();
		tree:SetScrollBarPos(0);
	end
end
