-- Copyright The Eavesdropper Authors
-- SPDX-License-Identifier: Apache-2.0

local L = ED.Localization;

---@class EavesdropperGroupDialog
local GroupDialog = {};

---Maximum character length for a user-defined group window name
local MaxGroupNameLength = 32;

-- ============================================================
-- Name Group (initial creation)
-- ============================================================

StaticPopupDialogs["EAVESDROPPER_NAME_GROUP"] = {
	text = L.POPUP_EAVESDROP_GROUP,
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = true,
	maxLetters = MaxGroupNameLength,
	whileDead = true,
	hideOnEscape = true,
	---@param self table
	---@param data { sender: string }
	OnAccept = function(self, data)
		local name = string.trim(self.EditBox:GetText());
		if name ~= "" then
			ED.GroupFrame:CreateNamedFrame(name, data and data.sender);
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
		local name = string.trim(self.EditBox:GetText());
		button1:SetEnabled(name ~= "" and not ED.GroupFrame:HasFrameWithName(name));
	end,
	---@param self EditBox
	EditBoxOnEscapePressed = function(self)
		StaticPopup_Hide("EAVESDROPPER_NAME_GROUP");
	end,
	---@param self EditBox
	---@param data { sender: string }
	EditBoxOnEnterPressed = function(self, data)
		local name = string.trim(self.EditBox:GetText());
		if name ~= "" and not ED.GroupFrame:HasFrameWithName(name) then
			ED.GroupFrame:CreateNamedFrame(name, data and data.sender);
			StaticPopup_Hide("EAVESDROPPER_NAME_GROUP");
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
	maxLetters = MaxGroupNameLength,
	whileDead = true,
	hideOnEscape = true,
	---@param self table
	---@param data { frame: EavesdropperGroupFrame }
	OnAccept = function(self, data)
		local newName = string.trim(self.EditBox:GetText());
		if data and data.frame then
			data.frame:RenameFrame(newName);
		end
	end,
	---@param self table
	---@param data { frame: EavesdropperGroupFrame }
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
	---@param data { frame: EavesdropperGroupFrame }
	EditBoxOnTextChanged = function(self, data)
		local popup = self:GetParent();
		local button1 = _G[popup:GetName() .. "Button1"];
		if not button1 then return; end

		local newName = string.trim(self:GetText());
		local currentName = data and data.frame and data.frame.displayName or "";
		local isDuplicate = ED.GroupFrame:HasFrameWithName(newName);
		local isSame = newName == currentName;

		button1:SetEnabled(newName ~= "" and not isDuplicate and not isSame);
	end,
	---@param self EditBox
	EditBoxOnEscapePressed = function(self)
		StaticPopup_Hide("EAVESDROPPER_RENAME_GROUP");
	end,
	---@param self EditBox
	---@param data { frame: EavesdropperGroupFrame }
	EditBoxOnEnterPressed = function(self, data)
		local newName = string.trim(self:GetText());
		if data and data.frame then
			local currentName = data.frame.displayName or "";
			local isDuplicate = ED.GroupFrame:HasFrameWithName(newName);
			if newName ~= "" and not isDuplicate and newName ~= currentName then
				data.frame:RenameFrame(newName);
				StaticPopup_Hide("EAVESDROPPER_RENAME_GROUP");
			end
		end
	end,
};

ED.GroupDialog = GroupDialog;
