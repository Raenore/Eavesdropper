-- Copyright The Eavesdropper Authors
-- SPDX-License-Identifier: Apache-2.0

---@class EavesdropperConfirmDialog
local ConfirmDialog = {};

StaticPopupDialogs["EAVESDROPPER_CONFIRM_DIALOG"] = {
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function()
		StaticPopupDialogs["EAVESDROPPER_CONFIRM_DIALOG"].onCancel = nil; -- Cleared so OnHide does not get called after OnAccept
		if StaticPopupDialogs["EAVESDROPPER_CONFIRM_DIALOG"].onAccept then
			StaticPopupDialogs["EAVESDROPPER_CONFIRM_DIALOG"].onAccept();
		end
	end,
	OnHide = function() -- OnHide is required as due to enterClicksFirstButton escape does not call OnCancel
		if StaticPopupDialogs["EAVESDROPPER_CONFIRM_DIALOG"].onCancel then
			StaticPopupDialogs["EAVESDROPPER_CONFIRM_DIALOG"].onCancel();
		end
	end,
	timeout = false,
	whileDead = true,
	hideOnEscape = true, -- does not work with enterClicksFirstButton
	showAlert = true,
	enterClicksFirstButton = true,
	escapeHides = true, -- required with enterClicksFirstButton
	preferredIndex = 3,
};

---Displays a reusable confirmation dialog with ACCEPT/CANCEL buttons.
---@param message string The confirmation message shown to the player.
---@param onAccept function Callback invoked when the player clicks ACCEPT or presses Enter.
---@param onCancel function Callback invoked when the player clicks CANCEL or presses Escape.
function ConfirmDialog:Show(message, onAccept, onCancel)
	StaticPopupDialogs["EAVESDROPPER_CONFIRM_DIALOG"].text = message;
	StaticPopupDialogs["EAVESDROPPER_CONFIRM_DIALOG"].onAccept = onAccept;
	StaticPopupDialogs["EAVESDROPPER_CONFIRM_DIALOG"].onCancel = onCancel;
	local dialog = StaticPopup_Show("EAVESDROPPER_CONFIRM_DIALOG");
	if dialog then
		dialog:ClearAllPoints();
		dialog:SetPoint("CENTER", UIParent, "CENTER");
	end
end

ED.ConfirmDialog = ConfirmDialog;
