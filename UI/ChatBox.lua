-- Copyright The Eavesdropper Authors
-- SPDX-License-Identifier: Apache-2.0

---@type EavesdropperConstants
local Constants = ED.Constants;

---@type EavesdropperEnums
local Enums = ED.Enums;

---@class EavesdropperChatBox
local ChatBox = {};

---@type table
local SharedMedia = LibStub("LibSharedMedia-3.0");

---Apply all font-related options from the database
function ChatBox:ApplyFontOptions()
	local frame = ED.Frame and ED.Frame.ChatBox;
	if not frame then
		return;
	end

	local outline = ED.Database:GetSetting("FontOutline");
	local face = ED.Database:GetSetting("FontFace");
	local size = ED.Database:GetSetting("FontSize");
	local shadow = ED.Database:GetSetting("FontShadow");

	local flags = "";
	if outline == Enums.CHAT_BOX.FONT_OUTLINE.OUTLINE then
		flags = "OUTLINE";
	elseif outline == Enums.CHAT_BOX.FONT_OUTLINE.THICKOUTLINE then
		flags = "THICKOUTLINE";
	end

	local font = SharedMedia:Fetch("font", face);
	if font then
		frame:SetFont(font, size, flags);
	end

	if shadow then
		frame:SetShadowColor(0, 0, 0, 0.8);
		frame:SetShadowOffset(1, -1);
	else
		frame:SetShadowColor(0, 0, 0, 0);
	end
end

---Adjust font size by delta (+1 / -1)
---@param delta number
function ChatBox:AdjustFontSize(delta)
	local size = ED.Database:GetSetting("FontSize");
	if not size then
		return;
	end

	size = math.min(Constants.CHAT_BOX.MAX_FONT_SIZE, math.max(Constants.CHAT_BOX.MIN_FONT_SIZE, size + delta));

	ED.Database:SetSetting("FontSize", size);
	self:ApplyFontOptions();
end

ED.ChatBox = ChatBox;
