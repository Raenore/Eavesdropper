-- Copyright The Eavesdropper Authors
-- Read-only editbox handling adapted from Total RP 3
-- SPDX-License-Identifier: GPL-3.0-or-later

local L = ED.Localization;

---@type EavesdropperConstants
local Constants = ED.Constants;

---@class EavesdropperDialogWidgets
local DialogWidgets = {};

local ROW_SPACING = 8;
local BODY_INSET_BOTTOM = 14;
local EDITBOX_PADDING = 5;
local EDITBOX_INSET = 4;
local EDITBOX_INSET_RIGHT = 24; -- Leaves room for the ScrollBar

---Installs read-only behaviour on a multi-line editbox: SetReadOnlyText plus its input guard.
---@param editBox table
local function InstallTextGuards(editBox)
	---Pins the box to text, making it read-only. Pass nil to make it editable again.
	---@param text string?
	editBox.SetReadOnlyText = function(self, text)
		self.readOnlyText = text;
		self:RestoreReadOnlyText();
	end;

	editBox.RestoreReadOnlyText = function(self)
		if self.restoringReadOnlyText then return; end
		self.restoringReadOnlyText = true;
		self:SetText(self.readOnlyText or "");
		self.restoringReadOnlyText = false;
	end;

	editBox:SetScript("OnChar", function(self, char)
		if self.readOnlyText == nil then return; end

		-- Rewind past the rejected character so the caret does not jump to the start.
		local cursorPosition = self:GetUTF8CursorPosition();
		self:RestoreReadOnlyText();
		self:SetCursorPosition(cursorPosition - strlenutf8(char));
	end);
end

---Builds a read-only, selectable multi-line text box.
---@param parent table Frame the widgets are parented to, and hidden on Escape.
---@param anchorFrame table Frame the box's top edge anchors below.
---@return table backdrop
---@return table scrollFrame
---@return table editBox
function DialogWidgets.CreateReadOnlyTextBox(parent, anchorFrame)
	local backdrop = CreateFrame("Frame", nil, parent, "BackdropTemplate");
	backdrop:SetBackdrop({
		bgFile = "Interface/ChatFrame/ChatFrameBackground",
		edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
		edgeSize = 12,
		insets = { left = 4, right = 4, top = 4, bottom = 4 },
	});
	backdrop:SetBackdropColor(0, 0, 0, 0.35);
	backdrop:SetBackdropBorderColor(0.3, 0.3, 0.3, 1);
	backdrop:SetPoint("TOPLEFT", anchorFrame, "BOTTOMLEFT", 0, -ROW_SPACING);
	backdrop:SetPoint("TOPRIGHT", anchorFrame, "BOTTOMRIGHT", 0, -ROW_SPACING);
	backdrop:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", Constants.SETTINGS.TITLE_OFFSET, BODY_INSET_BOTTOM);
	backdrop:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -Constants.SETTINGS.TITLE_OFFSET, BODY_INSET_BOTTOM);

	local scrollFrame = CreateFrame("ScrollFrame", nil, parent, "ScrollFrameTemplate");
	scrollFrame:SetPoint("TOPLEFT", backdrop, "TOPLEFT", EDITBOX_PADDING, -EDITBOX_PADDING);
	scrollFrame:SetPoint("BOTTOMRIGHT", backdrop, "BOTTOMRIGHT", -EDITBOX_PADDING, EDITBOX_PADDING);

	-- Unlike the settings variant the scrollbar stays visible; payloads always need it.
	scrollFrame.ScrollBar:ClearAllPoints();
	scrollFrame.ScrollBar:SetPoint("TOPRIGHT", scrollFrame, "TOPRIGHT", -6, -3);
	scrollFrame.ScrollBar:SetPoint("BOTTOMRIGHT", scrollFrame, "BOTTOMRIGHT", -6, 2);

	local editBox = CreateFrame("EditBox", nil, scrollFrame);
	editBox:SetMultiLine(true);
	editBox:SetAutoFocus(false);
	editBox:SetFontObject("ChatFontNormal");
	editBox:SetTextInsets(EDITBOX_INSET, EDITBOX_INSET_RIGHT, EDITBOX_INSET, EDITBOX_INSET);
	editBox:SetPoint("TOPLEFT", scrollFrame, "TOPLEFT", 0, 0);
	scrollFrame:SetScrollChild(editBox);

	scrollFrame:SetScript("OnSizeChanged", function(frame)
		editBox:SetWidth(frame:GetWidth());
	end);

	backdrop:SetScript("OnMouseDown", function(_, button)
		if button == "LeftButton" then
			editBox:SetFocus();
		end
	end);

	scrollFrame:SetScript("OnMouseDown", function(_, button)
		if button == "LeftButton" then
			editBox:SetFocus();
		end
	end);

	InstallTextGuards(editBox);

	-- Backstop for deletion, which never reaches OnChar.
	editBox:HookScript("OnTextChanged", function(box)
		if box.readOnlyText == nil then return; end
		if box:GetText() ~= box.readOnlyText then
			box:RestoreReadOnlyText();

			-- SetText parks the caret at the end; put it back where the key was pressed.
			if box.cursorBeforeKey then
				box:SetCursorPosition(box.cursorBeforeKey);
			end
		end
	end);

	editBox:SetScript("OnEscapePressed", function() parent:Hide(); end);

	-- Releases focus so a second Enter opens chat instead of being swallowed here.
	editBox:SetScript("OnEnterPressed", function(box)
		if box.readOnlyText == nil then return; end
		box:ClearFocus();
	end);

	editBox:SetScript("OnKeyDown", function(box, key)
		if box.readOnlyText == nil then return; end

		box.cursorBeforeKey = box:GetCursorPosition();

		if key == "C" and IsControlKeyDown() then
			UIErrorsFrame:AddMessage(L.COPY_SYSTEM_MESSAGE, YELLOW_FONT_COLOR:GetRGB());
		end
	end);

	return backdrop, scrollFrame, editBox;
end

ED.DialogWidgets = DialogWidgets;
