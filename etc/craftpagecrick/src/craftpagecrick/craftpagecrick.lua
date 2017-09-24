function CRAFTPAGECRICK_ON_INIT(addon, frame)
	if nil == CRAFTPAGECRICK_CRAFT_UPDATE_PAGE_OLD then
		CRAFTPAGECRICK_CRAFT_UPDATE_PAGE_OLD = CRAFT_UPDATE_PAGE;
		CRAFT_UPDATE_PAGE = CRAFTPAGECRICK_CRAFT_UPDATE_PAGE_HOOKED;
	end
end

function CRAFTPAGECRICK_CRAFT_UPDATE_PAGE_HOOKED(page, cls, haveMaterial, item)
	CRAFTPAGECRICK_CRAFT_UPDATE_PAGE_OLD(page, cls, haveMaterial, item)
	local app = page:CreateOrGetControlSet(g_craftRecipe, cls.ClassName, 10, 10);
	gbox = app:CreateOrGetControl('groupbox', cls.ClassName.."_GBOX", 0, 300, 470, 110);
	tolua.cast(gbox, "ui::CGroupBox");
	gbox:SetSkinName("None");
end
