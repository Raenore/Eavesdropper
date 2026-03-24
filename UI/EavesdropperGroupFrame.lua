-- Copyright The Eavesdropper Authors
-- SPDX-License-Identifier: Apache-2.0

---@type EavesdropperConstants
local Constants = ED.Constants;

---@type EavesdropperEnums
local Enums = ED.Enums;

local L = ED.Localization;

---@class EavesdropperGroupFrame
local GroupFrame = {};

---@type table<string, EavesdropperGroupFrame>
GroupFrame.frames = GroupFrame.frames or {};

---Inherit all shared frame behaviour; frame-specific methods are defined below
Eavesdropper_Group_FrameMixin = CreateFromMixins(Eavesdropper_SharedFrameMixin);

-- ============================================================
-- Group Frame Getters (saved in local frame state)
-- ============================================================

---@return boolean
function Eavesdropper_Group_FrameMixin:IsMouseEnabled()
	return self.mouseEnabled;
end

---@return boolean
function Eavesdropper_Group_FrameMixin:IsWindowLocked()
	return self.lockWindow;
end

---@return boolean
function Eavesdropper_Group_FrameMixin:IsScrollLocked()
	return self.lockScroll;
end

---@return boolean
function Eavesdropper_Group_FrameMixin:IsTitleBarLocked()
	return self.lockTitleBar;
end

-- ============================================================
-- OnLoad / OnShow / OnHide
-- ============================================================

function Eavesdropper_Group_FrameMixin:OnLoad()
	-- Extract the tracked player from the frame's global name
	local name = self:GetName();
	local player = name:match("^Eavesdropper_Group_Frame_(.+)$");
	self.eavesdropped_player = player;
	self.titlebar_name = nil;
	self.nameDisplayMode = ED.Database and ED.Database:GetSetting("NameDisplayMode") or 3;

	-- Initialise all local state before any method calls that read it
	self.lockWindow = false;
	self.lockTitleBar = true;
	self.hideCloseButton = false;
	self.lockScroll = false;
	self.mouseEnabled = false;
	self.clickblock = 0;
	self.isMouseOver = false;

	self:EnableMouseWheel(true);
	self:UpdateMouseLock();

	Eavesdropper_SharedFrameMixin.InitChatBox(self);
	self.EmptyLabel.Text:SetText(L.EMPTYLABEL_TEXT);

	-- Inherit font size from the main frame settings
	self.FontSize = ED.Database:GetSetting("FontSize");

	if not self.lockWindow then
		self.ResizeHandle:Show();
	end

	self:ShowTitleBar();

	-- Configure close button
	local closeBtn = self.TitleBar.CloseButton;
	Eavesdropper_SharedFrameMixin.InitCloseButton(closeBtn);
	closeBtn:SetScript("OnClick", function()
		self:Hide();
	end);

	if self.hideCloseButton then
		self.TitleBar.CloseButton:Hide();
	end

	-- Configure title button; prefer MSP display name, fall back to bare player name
	local titleBtn = self.TitleBar.TitleButton;
	titleBtn:SetScript("OnClick", function()
		ED.Config:ShowConfigMenu(self, false, true);
	end);

	hooksecurefunc(self.ChatBox, "RefreshDisplay", function()
		self:OnChatboxRefresh();
	end);
end

function Eavesdropper_Group_FrameMixin:OnShow()
	self:RefreshChat();
	if not self.chatTicker then
		self.chatTicker = C_Timer.NewTicker(Constants.CHAT_UPDATE_THROTTLE_DEFAULT, function()
			self:RefreshChat();
		end);
	end
end

function Eavesdropper_Group_FrameMixin:OnHide()
	-- When the UI parent is hidden (ALT-Z etc.), skip destructive code.
	if not UIParent:IsShown() then return; end

	if self.chatTicker then
		self.chatTicker:Cancel();
		self.chatTicker = nil;
	end

	-- Stop any in-progress new-indicator animations
	if self.NewIndicator then
		if self.NewIndicator.NewIndicatorFadeIn then self.NewIndicator.NewIndicatorFadeIn:Stop(); end
		if self.NewIndicator.NewIndicatorFadeOut then self.NewIndicator.NewIndicatorFadeOut:Stop(); end
		self.NewIndicator.isFadedIn = false;
		self.NewIndicator.isFadedOut = false;
	end

	if self.newIndicatorTimer then
		self.newIndicatorTimer:Cancel();
		self.newIndicatorTimer = nil;
	end

	self:UnregisterAllEvents();
	self:SetScript("OnEnter", nil);
	self:SetScript("OnLeave", nil);

	self:SetParent(nil);

	for index, frame in pairs(GroupFrame.frames) do
		if frame == self then
			GroupFrame.frames[index] = nil;
			break;
		end
	end

	-- Clean up the global reference so the name can be reused
	local frameName = self:GetName();
	if frameName and _G[frameName] == self then
		_G[frameName] = nil;
	end
end

-- ============================================================
-- Mouse / interaction
-- ============================================================

function Eavesdropper_Group_FrameMixin:OnEnter()
	if self.isMouseOver then return; end
	self.isMouseOver = true;

	-- Fade out the new-message indicator when the user hovers over the frame
	if self.NewIndicator and self.NewIndicator.isFadedIn and not self.NewIndicator.isFadedOut then
		self.NewIndicator.NewIndicatorFadeIn:Stop();
		self.NewIndicator.NewIndicatorFadeOut:Stop();
		self.NewIndicator.NewIndicatorFadeOut:Play();
		self.NewIndicator.isFadedOut = true;
		self.NewIndicator.isFadedIn = false;
	end

	self:HandleHoverState(Enums.FRAME.MOUSE_HOVER_STATE.ON);
end

---Position is intentionally not persisted; group frames reset on reload
function Eavesdropper_Group_FrameMixin:OnDragStop()
	self:StopMovingOrSizing();
end

---Size is intentionally not persisted; group frames reset on reload
function Eavesdropper_Group_FrameMixin:OnResizeFinished()
end

-- ============================================================
-- Layout / appearance
-- ============================================================

---Updates the name in the title bar
---@param newName string
function Eavesdropper_Group_FrameMixin:UpdateTitleBar(newName)
	if newName == self.titlebar_name then return; end
	if self.displayName == self.titlebar_name then return; end

	self.titlebar_name = self.displayName;
	self.TitleBar.TitleButton.Text:SetText(self.titlebar_name);
end

---Restore resize handle and close button from local frame state (not the database)
function Eavesdropper_Group_FrameMixin:RestoreLayout()
	if not ED.Database then return; end

	if not self.lockWindow then
		self.ResizeHandle:Show();
	else
		self.ResizeHandle:Hide();
	end

	if self.hideCloseButton then
		self.TitleBar.CloseButton:Hide();
	else
		self.TitleBar.CloseButton:Show();
	end
end

-- ============================================================
-- Visibility
-- ============================================================

function Eavesdropper_Group_FrameMixin:HandleVisibility()
	-- Hide in combat if the setting is on
	if ED.Database:GetSetting("HideInCombat") and InCombatLockdown() then
		self:Hide();
		return;
	end

	-- Group frames are always shown; intentionally skip HideWhenEmpty
	-- to avoid silently hiding a frame the user explicitly opened
	self:Show();
end

-- ============================================================
-- Chat
-- ============================================================

---Repopulate the chat box from stored history
function Eavesdropper_Group_FrameMixin:RefreshChat()
	if not self.ChatBox then return; end

	self.refreshing = true;
	self.ChatBox:Clear();

	local maxMessages = ED.Database:GetSetting("MaxHistory");

	if self.players and #self.players > 0 then
		self:PopulateGroupHistoryMessages(maxMessages);
	end
	self.refreshing = false;
end

---PopulateGroupHistoryMessages Collects history from all tracked players,
---merges the entries into a single chronological list sorted by entry ID,
---and feeds them into the ChatBox oldest-first.
---@param maxMessages number
function Eavesdropper_Group_FrameMixin:PopulateGroupHistoryMessages(maxMessages)
	---Collect and deduplicate entries across all tracked players
	---keyed by entry.id to avoid duplicates if a sender appears twice
	local seen    = {};
	local entries = {};

	for _, player in ipairs(self.players) do
		local history = ED.ChatHistory:GetPlayerHistory(player, maxMessages);

		if not history or #history == 0 then
			history = ED.ChatHistory:GetPlayerHistory(ED.Utils.StripRealmSuffix(player), maxMessages);
		end

		if history then
			for _, entry in ipairs(history) do
				if not seen[entry.id] then
					seen[entry.id] = true;
					table.insert(entries, entry);
				end
			end
		end
	end

	if #entries == 0 then return; end

	---Sort ascending by ID: lowest ID (oldest) first, highest ID (newest) last
	table.sort(entries, function(a, b) return a.id < b.id; end);

	---Trim to maxMessages total after merging
	local start = math.max(1, #entries - maxMessages + 1);
	for i = start, #entries do
		self:AddMessage(entries[i], true);
	end
end

---Add a chat entry to the frame
---@param entry EavesdropperChatEntry
---@param fromHistory boolean
function Eavesdropper_Group_FrameMixin:AddMessage(entry, fromHistory)
	if not entry then return; end

	if not ED.ChatFilters:HasEvent(entry.e, self) then return; end

	if not self.refreshing then
		self.fade_time = GetTime();
	end

	-- local hidden = not self:EavesdroppingOn(entry.g); -- UNUSED for now.

	if not self.ChatBox then return; end

	if not fromHistory and (ED.Database:GetSetting("HideWhenEmpty") or ED.Frame.settingsOpened) then
		self:Show();
	end

	local r, g, b = ED.ChatFormatter.GetEntryColor(entry);
	local formatted = ED.ChatFormatter:FormatMessage(entry, true, self.nameDisplayMode);
	self.ChatBox:AddMessage(formatted, r, g, b);
end

---Override of the base TryAddMessage to handle the new-message indicator
---@param entry EavesdropperChatEntry
function Eavesdropper_Group_FrameMixin:TryAddMessage(entry)
	if self.ChatBox:GetScrollOffset() == 0 then
		self.clickblock = GetTime();
	end

	self:AddMessage(entry);

	-- Show new-message indicator for incoming messages when the frame is not hovered
	if not entry.p
		-- and ED.Database:GetGlobalSetting("DedicatedWindowsNewIndicator")
		and self.NewIndicator
		and not self.isMouseOver
	then
		if not self.NewIndicator.isFadedIn then
			self.NewIndicator:Show();
			self.NewIndicator.NewIndicatorFadeIn:Stop();
			self.NewIndicator.NewIndicatorFadeOut:Stop();
			self.NewIndicator.NewIndicatorFadeIn:Play();
			self.NewIndicator.isFadedIn = true;
			self.NewIndicator.isFadedOut = false;
		end

		if self.newIndicatorTimer then
			self.newIndicatorTimer:Cancel();
			self.newIndicatorTimer = nil;
		end

		self.newIndicatorTimer = C_Timer.NewTimer(Constants.CHAT_NEW_INDICATOR_FADE_OUT, function()
			if self.NewIndicator and self.NewIndicator.NewIndicatorFadeOut and not self.NewIndicator.isFadedOut then
				self.NewIndicator.NewIndicatorFadeIn:Stop();
				self.NewIndicator.NewIndicatorFadeOut:Stop();
				self.NewIndicator.NewIndicatorFadeOut:Play();
				self.NewIndicator.isFadedOut = true;
				self.NewIndicator.isFadedIn = false;
			end
			self.newIndicatorTimer = nil;
		end);
	end
end

---Apply all window settings: font, filters, layout, colors, and history
function Eavesdropper_Group_FrameMixin:ApplyWindowSettings()
	ED.ChatBox:ApplyFontOptions(self);
	ED.ChatFilters:UpdateFilters(self);
	self:RestoreLayout();
	self:ApplyThemeColors();
	self:RefreshChat();
end

-- ============================================================
-- Group manager
-- ============================================================

---Maximum character length for a user-defined group window name
local MaxGroupNameLength = 32;

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
		local name = self.EditBox:GetText();
		if name ~= "" then
			GroupFrame:CreateNamedFrame(name, data and data.sender);
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
		local name = self:GetText();
		button1:SetEnabled(name ~= "" and not GroupFrame:HasFrameWithName(name));
	end,
	---@param self EditBox
	EditBoxOnEscapePressed = function(self)
		StaticPopup_Hide("EAVESDROPPER_NAME_GROUP");
	end,
	---@param self EditBox
	---@param data { sender: string }
	EditBoxOnEnterPressed = function(self, data)
		local name = self:GetText();
		if name ~= "" and not GroupFrame:HasFrameWithName(name) then
			GroupFrame:CreateNamedFrame(name, data and data.sender);
			StaticPopup_Hide("EAVESDROPPER_NAME_GROUP");
		end
	end,
};

StaticPopupDialogs["EAVESDROPPER_RENAME_GROUP"] = {
	text                   = L.POPUP_EAVESDROP_GROUP,
	button1                = ACCEPT,
	button2                = CANCEL,
	hasEditBox             = true,
	maxLetters             = MaxGroupNameLength,
	whileDead              = true,
	hideOnEscape           = true,
	---@param self table
	---@param data { frame: EavesdropperGroupFrame }
	OnAccept = function(self, data)
		local newName = self.EditBox:GetText();
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
		local popup   = self:GetParent();
		local button1 = _G[popup:GetName() .. "Button1"];
		if not button1 then return; end

		local newName     = self:GetText();
		local currentName = data and data.frame and data.frame.displayName or "";
		local isDuplicate = GroupFrame:HasFrameWithName(newName);
		local isSame      = newName == currentName;

		button1:SetEnabled(newName ~= "" and not isDuplicate and not isSame);
	end,
	---@param self EditBox
	EditBoxOnEscapePressed = function(self)
		StaticPopup_Hide("EAVESDROPPER_RENAME_GROUP");
	end,
	---@param self EditBox
	---@param data { frame: EavesdropperGroupFrame }
	EditBoxOnEnterPressed = function(self, data)
		local newName = self:GetText();
		if data and data.frame then
			local currentName = data.frame.displayName or "";
			local isDuplicate = GroupFrame:HasFrameWithName(newName);
			if newName ~= "" and not isDuplicate and newName ~= currentName then
				data.frame:RenameFrame(newName);
				StaticPopup_Hide("EAVESDROPPER_RENAME_GROUP");
			end
		end
	end,
};

---RenameFrame Updates the display name and refreshes the title bar.
---Aborts if the new name is empty or already in use by another frame.
---@param newName string
function Eavesdropper_Group_FrameMixin:RenameFrame(newName)
	if not newName or newName == ""        then return; end
	if newName == self.displayName         then return; end
	if GroupFrame:HasFrameWithName(newName) then return; end

	self.displayName = newName;
	self:UpdateTitleBar(newName);
end

---PromptRenameFrame Opens the rename dialog for this group frame.
function Eavesdropper_Group_FrameMixin:PromptRenameFrame()
	StaticPopup_Show("EAVESDROPPER_RENAME_GROUP", nil, nil, { frame = self });
end

-- ============================================================
-- GroupFrame manager methods
-- ============================================================

---ForEachFrame Iterates all live group frames and calls func on each.
---@param func fun(frame: EavesdropperGroupFrame)
function GroupFrame:ForEachFrame(func)
	for _, frame in pairs(self.frames) do
		if frame then func(frame); end
	end
end

---HasFrameWithName Returns true if any active group frame already uses the given display name.
---@param name string
---@return boolean
function GroupFrame:HasFrameWithName(name)
	for _, frame in pairs(self.frames) do
		if frame and frame.displayName == name then return true; end
	end
	return false;
end

---AddFrame Prompts the user for a group name before creating any frame.
---No frame is created if the user cancels or submits an empty name.
---@param sender string Initial sender in "Name-Realm" format
function GroupFrame:AddFrame(sender)
	StaticPopup_Show("EAVESDROPPER_NAME_GROUP", nil, nil, { sender = sender });
end

---CreateNamedFrame Finds the next available index, creates the frame, and assigns the display name.
---Aborts silently if displayName is already in use or either argument is missing.
---@param displayName string
---@param sender string Initial sender to seed the frame with
function GroupFrame:CreateNamedFrame(displayName, sender)
	if not displayName or displayName == "" then return; end
	if self:HasFrameWithName(displayName) then return; end

	local index = 1;
	while self.frames[index] and self.frames[index]:IsShown() do
		index = index + 1;
	end

	local globalName = "Eavesdropper_Group_Frame_" .. index;
	local frame = _G[globalName];

	if not frame then
		frame = CreateFrame("Frame", globalName, UIParent, "Eavesdropper_Group_FrameTemplate");
		frame:Raise();
		frame:HandleVisibility();
		frame:ApplyWindowSettings();
		ED.ChatFilters:Init(frame);
	else
		frame:Show();
	end

	frame.displayName = displayName;
	frame.players = {};

	frame:AddPlayer(sender);
	frame:UpdateTitleBar(displayName);
	frame:RefreshChat();
	self.frames[index] = frame;
end

-- ============================================================
-- GroupFrameInfo type and query
-- ============================================================

---@class GroupFrameInfo
---@field displayName string User-facing name of this group window
---@field globalName string Stable _G key e.g. "Eavesdropper_Group_Frame_1"
---@field players string[] All tracked senders in this frame
---@field hasSender boolean True if the queried sender is already in this frame

---GetGroupWindows Returns a sorted snapshot of all active group frames.
---hasSender is true for any frame that already tracks the given sender.
---Returns nil when no frames exist.
---@param sender string ? Optional sender to check membership against
---@return GroupFrameInfo[] ?
function GroupFrame:GetGroupWindows(sender)
	local result = {};

	for _, frame in pairs(self.frames) do
		if frame then
			table.insert(result, {
				displayName = frame.displayName,
				globalName = frame:GetName(),
				players = frame.players,
				hasSender = sender ~= nil and frame:HasPlayer(sender) or false,
			});
		end
	end

	if #result == 0 then return nil; end

	table.sort(result, function(a, b) return a.displayName < b.displayName; end);

	return result;
end

-- ============================================================
-- Mixin: player list management
-- ============================================================

---RefreshEmptyState Shows or hides the empty-state label based on current player count.
function Eavesdropper_Group_FrameMixin:RefreshEmptyState()
	if self.EmptyLabel then
		self.EmptyLabel:SetShown(#self.players == 0);
	end
end

---AddPlayer Adds a sender to this frame's player list if not already present.
---@param sender string
function Eavesdropper_Group_FrameMixin:AddPlayer(sender)
	if not sender then return; end
	for _, existing in ipairs(self.players) do
		if existing == sender then return; end
	end
	table.insert(self.players, sender);
	self:RefreshEmptyState();
	self:RefreshChat();
end

---RemovePlayer Removes a sender from this frame's player list.
---@param sender string
function Eavesdropper_Group_FrameMixin:RemovePlayer(sender)
	for i, existing in ipairs(self.players) do
		if existing == sender then
			table.remove(self.players, i);
			self:RefreshEmptyState();
			self:RefreshChat();
			return;
		end
	end
end

---HasPlayer Returns true if the given sender is currently tracked by this frame.
---@param sender string
---@return boolean
function Eavesdropper_Group_FrameMixin:HasPlayer(sender)
	for _, player in ipairs(self.players) do
		if player == sender then return true; end
	end
	return false;
end

ED.GroupFrame = GroupFrame;
