-- Copyright The Eavesdropper Authors
-- Inspired by Sippy Cup
-- SPDX-License-Identifier: Apache-2.0

local L = ED.Localization;

---@class EavesdropperLinkDialog
local LinkDialog = {};

---Returns the editBox child of a StaticPopup dialog, handling both API styles.
---Borrowed from Total RP 3.
---@param dialog table
---@return table
local function GetDialogEditBox(dialog)
	return dialog.GetEditBox and dialog:GetEditBox() or dialog.editBox;
end

---Applies ElvUI skin to the dialog's editBox if ElvUITheme is enabled.
---@param editBox table
local function SkinEditBox(editBox)
	local E = ElvUI and ElvUI[1];
	if not E or not ED.Database:GetSetting("ElvUITheme") then return; end
	local S = E:GetModule("Skins");
	if not S then return; end

	S:HandleEditBox(editBox);
end

---Populates and wires up the editBox for URL display and keyboard interaction.
---@param editBox table
---@param url string?
local function SetupEditBox(editBox, url)
	editBox:SetText(url or "");
	editBox:HighlightText();
	editBox:SetFocus();

	editBox:SetScript("OnEditFocusGained", function(self)
		self:HighlightText();
	end);

	editBox:SetScript("OnKeyDown", function(self, key)
		if key == "ESCAPE" then
			self:GetParent():Hide();
		elseif key == "C" and IsControlKeyDown() then
			self:HighlightText();
			UIErrorsFrame:AddMessage(L.COPY_SYSTEM_MESSAGE, YELLOW_FONT_COLOR:GetRGB());
			RunNextFrame(function()
				self:GetParent():Hide();
			end);
		end
	end);
end

StaticPopupDialogs["EAVESDROPPER_LINK_DIALOG"] = {
	text = ED.Globals.addon_title .. L.POPUP_LINK,
	button1 = CANCEL,
	hasEditBox = true,
	editBoxWidth = 320,
	OnShow = function(self)
		local editBox = GetDialogEditBox(self);
		SkinEditBox(editBox);
		SetupEditBox(editBox, StaticPopupDialogs["EAVESDROPPER_LINK_DIALOG"].url or "");
	end,
	timeout = false,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,
};

---Displays a static popup dialog containing the given URL in a copyable editBox.
---@param url string
function LinkDialog.CreateExternalLinkDialog(url)
	StaticPopupDialogs["EAVESDROPPER_LINK_DIALOG"].url = url;
	local dialog = StaticPopup_Show("EAVESDROPPER_LINK_DIALOG");
	if dialog then
		dialog:ClearAllPoints();
		dialog:SetPoint("CENTER", UIParent, "CENTER");
	end
end

ED.LinkDialog = LinkDialog;
