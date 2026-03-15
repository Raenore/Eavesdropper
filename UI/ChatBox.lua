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
---@param frame table?
function ChatBox:ApplyFontOptions(frame)
	local owner = frame or ED.Frame;
	local chatBox = owner and owner.ChatBox;
	if not chatBox then
		return;
	end

	local outline = ED.Database:GetSetting("FontOutline");
	local face = ED.Database:GetSetting("FontFace");
	local size = (owner == ED.Frame) and ED.Database:GetSetting("FontSize") or owner.FontSize;
	local shadow = ED.Database:GetSetting("FontShadow");

	local flags = "";
	if outline == Enums.CHAT_BOX.FONT_OUTLINE.OUTLINE then
		flags = "OUTLINE";
	elseif outline == Enums.CHAT_BOX.FONT_OUTLINE.THICKOUTLINE then
		flags = "THICKOUTLINE";
	end

	local font = SharedMedia:Fetch("font", face);
	if font then
		chatBox:SetFont(font, size, flags);
	end

	if shadow then
		chatBox:SetShadowColor(0, 0, 0, 0.8);
		chatBox:SetShadowOffset(1, -1);
	else
		chatBox:SetShadowColor(0, 0, 0, 0);
	end
end

---Adjust font size by delta (+1 / -1)
---@param frame table
---@param delta number
function ChatBox:AdjustFontSize(frame, delta)
	local size = (frame == ED.Frame) and ED.Database:GetSetting("FontSize") or frame.FontSize;
	if not size then
		return;
	end

	size = math.min(Constants.CHAT_BOX.MAX_FONT_SIZE, math.max(Constants.CHAT_BOX.MIN_FONT_SIZE, size + delta));

	-- Only save for main frame
	if frame == ED.Frame then
		ED.Database:SetSetting("FontSize", size);
	else
		frame.FontSize = size;
	end

	self:ApplyFontOptions(frame);
end

ED.ChatBox = ChatBox;
