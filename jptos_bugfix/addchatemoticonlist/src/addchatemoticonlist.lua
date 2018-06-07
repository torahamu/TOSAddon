function ADDCHATEMOTICONLIST_ON_INIT(addon, frame)
	local emoticonFrame = ui.GetFrame('chat_emoticon');
	emoticonFrame:Resize(emoticonFrame:GetWidth(),emoticonFrame:GetHeight()+50)
	local emoticons = GET_CHILD(emoticonFrame, "emoticons", "ui::CSlotSet");
	emoticons:SetColRow(10,6);
	emoticons:CreateSlots();
end
