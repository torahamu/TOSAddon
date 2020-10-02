--ライブラリ読み込み
local acutil = require('acutil');

-- フレーム内文字

local nameX=20;
local resultX=400;
local pointX=440;
local mapX=550;

function STATUSPOINTCHECK_WARP_LIST(vakarine_gbox)
	local warp = GET_CHILD(vakarine_gbox, "warp_list", "ui::CGroupBox");
	warp = tolua.cast(warp, "ui::CGroupBox");

	--quest for master quest
	STATUSPOINTCHECK_WARP_CHECK(warp)

end

function STATUSPOINTCHECK_WARP_CHECK(warp)
	local sObj_main = GET_MAIN_SOBJ();
	local warpcount = GetClassCount('camp_warp')
	local titleBody = "Vakarine List";
	local body = "";
	local getPoint = 0;
	local sumPoint = warpcount;
	local ypos = 20;
	local title = warp:CreateOrGetControl("richtext", "warpcheck_questcheck_title"  , 0, 0, 0, 0);
	for k = 0 , warpcount-1 do
		local name   = warp:CreateOrGetControl("richtext", "warpcheck_questcheck_name"..k  , nameX  , ypos, 0, 0);
		local result = warp:CreateOrGetControl("richtext", "warpcheck_questcheck_result"..k, resultX, ypos, 0, 0);
		local nameBody = "";
		local resultBody = "";
		local color = "";
		name = tolua.cast(name, "ui::CRichText");
		result = tolua.cast(result, "ui::CRichText");

		local cls = GetClassByIndex('camp_warp', k);
		nameBody = cls.Name;

		if sObj_main[cls.ClassName] == 300 then
			color = "{#FF3333}{ol}{b}{s16}";
			resultBody = "OK"
			getPoint = getPoint + 1;
		else
			color = "{#666666}{ol}{b}{s16}";
			resultBody = "NO"
		end
		name:SetText(color..nameBody.."{/}{/}{/}{/}")
		result:SetText(color..resultBody.."{/}{/}{/}{/}")
		ypos = ypos + name:GetHeight();
		warp:Resize(warp:GetWidth(),ypos)
	end
	title:SetText("{#000000}{s16}"..titleBody.."("..getPoint.."/"..sumPoint.."){/}{/}")
end

