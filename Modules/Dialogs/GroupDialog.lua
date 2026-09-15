-- Copyright The Eavesdropper Authors
-- SPDX-License-Identifier: GPL-3.0-or-later

local L = ED.Localization;

---@class EavesdropperGroupDialog
local GroupDialog = {};

---Maximum character length for a user-defined group window name
local MAX_GROUP_NAME_LENGTH = 32;

---Creates a new group under chosen name. If it existed before (case-insensitive) this session
---Then we prompt the user to restore it, re-using the old settings, old player list, etc.
---Otherwise it starts fresh, with none of the saved info carrying over.
---@param name string
---@param sender string?
function GroupDialog.CreateOrRestore(name, sender)
	local closed = ED.GroupFrame.sessionState[name:lower()];
	if closed and closed.players and #closed.players > 0 then
		local message = L.POPUP_RESTORE_GROUP:format(name, #closed.players);
		ED.ConfirmDialog.Show(message, function()
			local playerList = CopyTable(closed.players, true);
			if sender and not tContains(playerList, sender) then
				playerList[#playerList + 1] = sender;
			end
			ED.GroupFrame:CreateNamedFrame(name, nil, playerList, closed);
		end, function()
			ED.GroupFrame:CreateNamedFrame(name, sender, nil, nil, true);
		end);
		return;
	end

	ED.GroupFrame:CreateNamedFrame(name, sender);
end

-- ============================================================
-- Name Group (initial creation)
-- ============================================================

StaticPopupDialogs["EAVESDROPPER_NAME_GROUP"] = {
	text = L.POPUP_EAVESDROP_GROUP,
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = true,
	maxLetters = MAX_GROUP_NAME_LENGTH,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,
	---@param self table
	---@param data { sender: string }
	OnAccept = function(self, data)
		local name = string.trim(self.EditBox:GetText());
		if name ~= "" then
			GroupDialog.CreateOrRestore(name, data and data.sender);
		end
	end,
	---@param self table
	OnShow = function(self)
		local button1 = _G[self:GetName() .. "Button1"];
		if button1 then
			button1:Disable();
		end
		self.EditBox:SetFocus();
	end,
	---@param self EditBox
	EditBoxOnTextChanged = function(self)
		local popup = self:GetParent();
		local button1 = _G[popup:GetName() .. "Button1"];
		if not button1 then return; end
		local name = string.trim(self:GetText());
		button1:SetEnabled(name ~= "" and not ED.GroupFrame:HasFrameWithName(name));
	end,
	---@param self EditBox
	EditBoxOnEscapePressed = function(self)
		StaticPopup_Hide("EAVESDROPPER_NAME_GROUP");
	end,
	---@param self EditBox
	---@param data { sender: string }
	EditBoxOnEnterPressed = function(self, data)
		local name = string.trim(self:GetText());
		if name ~= "" and not ED.GroupFrame:HasFrameWithName(name) then
			StaticPopup_Hide("EAVESDROPPER_NAME_GROUP");
			GroupDialog.CreateOrRestore(name, data and data.sender);
		end
	end,
};

-- ============================================================
-- Rename Group
-- ============================================================

StaticPopupDialogs["EAVESDROPPER_RENAME_GROUP"] = {
	text = L.POPUP_EAVESDROP_GROUP,
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = true,
	maxLetters = MAX_GROUP_NAME_LENGTH,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,
	---@param self table
	---@param data { frame: EavesdropperGroupFrameInstance }
	OnAccept = function(self, data)
		local newName = string.trim(self.EditBox:GetText());
		if data and data.frame then
			data.frame:RenameFrame(newName);
		end
	end,
	---@param self table
	---@param data { frame: EavesdropperGroupFrameInstance }
	OnShow = function(self, data)
		local button1 = _G[self:GetName() .. "Button1"];
		if button1 then
			button1:Disable();
		end
		if data and data.frame then
			self.EditBox:SetText(data.frame.displayName or "");
			self.EditBox:HighlightText();
		end
		self.EditBox:SetFocus();
	end,
	---@param self EditBox
	---@param data { frame: EavesdropperGroupFrameInstance }
	EditBoxOnTextChanged = function(self, data)
		local popup = self:GetParent();
		local button1 = _G[popup:GetName() .. "Button1"];
		if not button1 then return; end

		local newName = string.trim(self:GetText());
		local currentName = data and data.frame and data.frame.displayName or "";
		local isDuplicate = ED.GroupFrame:HasFrameWithName(newName, data and data.frame);
		local isSame = newName == currentName;

		button1:SetEnabled(newName ~= "" and not isDuplicate and not isSame);
	end,
	---@param self EditBox
	EditBoxOnEscapePressed = function(self)
		StaticPopup_Hide("EAVESDROPPER_RENAME_GROUP");
	end,
	---@param self EditBox
	---@param data { frame: EavesdropperGroupFrameInstance }
	EditBoxOnEnterPressed = function(self, data)
		local newName = string.trim(self:GetText());
		if data and data.frame then
			local currentName = data.frame.displayName or "";
			local isDuplicate = ED.GroupFrame:HasFrameWithName(newName, data.frame);
			if newName ~= "" and not isDuplicate and newName ~= currentName then
				data.frame:RenameFrame(newName);
				StaticPopup_Hide("EAVESDROPPER_RENAME_GROUP");
			end
		end
	end,
};

ED.GroupDialog = GroupDialog;
