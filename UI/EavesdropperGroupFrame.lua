-- Copyright The Eavesdropper Authors
-- SPDX-License-Identifier: Apache-2.0

---@type EavesdropperConstants
local Constants = ED.Constants;

local L = ED.Localization;

---@class EavesdropperGroupFrame
local GroupFrame = {};

---@class EavesdropperSavedGroupFrame
---@field name string Display name of the group window
---@field players string[] Tracked senders in "Name-Realm" format
---@field nameDisplayMode number? Only stored when it differs from main Eavesdropper

---Keyed by displayName, which is enforced unique by HasFrameWithName.
---The _G frame name uses a numeric index and is tracked separately.
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

---@param mode number
function Eavesdropper_Group_FrameMixin:SetNameDisplayMode(mode)
	if self.nameDisplayMode == mode then return; end
	self.nameDisplayMode = mode;
	self:RefreshChat();
	GroupFrame:SaveToCharDB();
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

	self:InitInstanceFrameState();

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

	-- Configure title button; triggers the group config menu
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
	Eavesdropper_SharedFrameMixin.OnHideInstanceFrame(self);
end

---Remove self from the GroupFrame manager on hide and update saved data.
function Eavesdropper_Group_FrameMixin:OnUnregisterFrame()
	if self.displayName then
		GroupFrame.frames[self.displayName] = nil;
		GroupFrame:SaveToCharDB();
	end
end

-- ============================================================
-- Mouse / Interaction
-- ============================================================

---Position is intentionally not persisted; group frames reset on reload
function Eavesdropper_Group_FrameMixin:OnDragStop()
	self:StopMovingOrSizing();
end

---Size is intentionally not persisted; group frames reset on reload
function Eavesdropper_Group_FrameMixin:OnResizeFinished()
end

-- ============================================================
-- Layout / Appearance
-- ============================================================

---Update the title bar text
---@param newName string? If provided it becomes the new displayName; otherwise self.displayName is used.
function Eavesdropper_Group_FrameMixin:UpdateTitleBar(newName)
	if newName and newName ~= self.displayName then
		self.displayName = newName;
	end

	if self.displayName == self.titlebar_name then return; end

	self.titlebar_name = self.displayName;
	self.TitleBar.TitleButton.Text:SetText(self.titlebar_name);
	self:ResizeTitleButton();
end

-- ============================================================
-- Chat
-- ============================================================

---Repopulate the chat box by merging history from all tracked players
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

---Collect and deduplicate history across all tracked players, sort chronologically,
---trim to maxMessages, then feed entries into the ChatBox oldest-first.
---@param maxMessages number
function Eavesdropper_Group_FrameMixin:PopulateGroupHistoryMessages(maxMessages)
	-- Collect entries keyed by entry.id to deduplicate across players
	local seen = {};
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

	-- Sort ascending by ID: lowest ID (oldest) first, highest ID (newest) last
	table.sort(entries, function(a, b) return a.id < b.id; end);

	-- Trim to maxMessages total after merging
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

---Override of the base TryAddMessage to handle the new-message indicator.
---@param entry EavesdropperChatEntry
function Eavesdropper_Group_FrameMixin:TryAddMessage(entry)
	Eavesdropper_SharedFrameMixin.TryAddMessage(self, entry);

	if not entry.p
		-- TODO: and ED.Database:GetGlobalSetting("GroupWindowsNewIndicator")
		and self.NewIndicator
		and not self.isMouseOver
	then
		self:FadeInNewIndicator();
		self:ScheduleNewIndicatorFadeOut();
	end
end

-- ============================================================
-- Group manager
-- ============================================================

---Update the display name and re-key in the manager table.
---@param newName string
function Eavesdropper_Group_FrameMixin:RenameFrame(newName)
	if not newName or newName == "" then return; end
	if newName == self.displayName then return; end
	if GroupFrame:HasFrameWithName(newName) then return; end

	-- Re-key before mutating displayName so HasFrameWithName stays consistent
	GroupFrame.frames[self.displayName] = nil;
	self.displayName = newName;
	GroupFrame.frames[self.displayName] = self;

	self:UpdateTitleBar();
	GroupFrame:SaveToCharDB();
end

---Open the rename dialog for this group frame
function Eavesdropper_Group_FrameMixin:PromptRenameFrame()
	StaticPopup_Show("EAVESDROPPER_RENAME_GROUP", nil, nil, { frame = self });
end

-- ============================================================
-- GroupFrame manager methods
-- ============================================================

---Iterate all live group frames and call func on each
---@param func fun(frame: EavesdropperGroupFrame)
function GroupFrame:ForEachFrame(func)
	for _, frame in pairs(self.frames) do
		if frame then func(frame); end
	end
end

---Returns true if any active group frame already uses the given display name
---@param name string
---@return boolean
function GroupFrame:HasFrameWithName(name)
	for _, frame in pairs(self.frames) do
		if frame and frame.displayName == name then return true; end
	end
	return false;
end

---Stores only displayName, players, and nameDisplayMode (when overridden) in saved variables.
function GroupFrame:SaveToCharDB()
	if not EavesdropperCharDB then return; end

	if not ED.Database:GetGlobalSetting("GroupWindowsPersist") then
		EavesdropperCharDB.groupFrames = {};
		return;
	end

	local profileMode = ED.Database:GetSetting("NameDisplayMode");
	local saved = {};

	for _, frame in pairs(self.frames) do
		if frame and frame.displayName and frame.players and #frame.players > 0 then
			local entry = {
				name = frame.displayName,
				players = ED.Utils.ShallowCopy(frame.players),
			};

			---Only persist nameDisplayMode when it differs from the profile default.
			if frame.nameDisplayMode and frame.nameDisplayMode ~= profileMode then
				entry.nameDisplayMode = frame.nameDisplayMode;
			end

			table.insert(saved, entry);
		end
	end

	EavesdropperCharDB.groupFrames = saved;
end

---Restore group frames from the character saved variables.
function GroupFrame:RestoreFromCharDB()
	if not EavesdropperCharDB then return; end
	if not ED.Database:GetGlobalSetting("GroupWindowsPersist") then return; end

	local saved = EavesdropperCharDB.groupFrames;
	if not saved or #saved == 0 then return; end

	for _, entry in ipairs(saved) do
		if entry.name and entry.players and #entry.players > 0 then
			self:CreateNamedFrame(entry.name, nil, entry.players);

			---Apply saved nameDisplayMode override if present.
			local frame = self.frames[entry.name];
			if frame and entry.nameDisplayMode then
				frame.nameDisplayMode = entry.nameDisplayMode;
				frame:RefreshChat();
			end
		end
	end
end

---Prompt the user for a group name before creating any frame.
---No frame is created if the user cancels or submits an empty name.
---@param sender string Initial sender in "Name-Realm" format
function GroupFrame:AddFrame(sender)
	StaticPopup_Show("EAVESDROPPER_NAME_GROUP", nil, nil, { sender = sender });
end

---Find the lowest free numeric index for the stable _G frame name, create the frame,
---then register it in frames keyed by displayName.
---When playerList is provided (restore path), the full list is set directly.
---@param displayName string
---@param sender string? Initial sender to seed the frame with
---@param playerList string[]? Full player list for restore; takes precedence over sender
function GroupFrame:CreateNamedFrame(displayName, sender, playerList)
	if not displayName or displayName == "" then return; end
	if self:HasFrameWithName(displayName) then return; end

	-- Find the lowest free numeric slot for the _G name.
	-- OnHide clears _G[frameName], so any previously hidden slot is available.
	-- The numeric index is only used for the _G global name to avoid special characters.
	local index = 1;
	while _G["Eavesdropper_Group_Frame_" .. index] do
		index = index + 1;
	end

	local globalName = "Eavesdropper_Group_Frame_" .. index;
	local frame = CreateFrame("Frame", globalName, UIParent, "Eavesdropper_Group_FrameTemplate");
	frame:Raise();
	frame:HandleVisibility();
	frame:ApplyWindowSettings();
	ED.ChatFilters:Init(frame);

	frame.displayName = displayName;
	frame.players = {};

	if playerList and #playerList > 0 then
		for _, player in ipairs(playerList) do
			table.insert(frame.players, player);
		end
		frame:RefreshEmptyState();
	elseif sender then
		frame:AddPlayer(sender);
	end

	frame:UpdateTitleBar();
	frame:RefreshChat();

	self.frames[displayName] = frame;
	self:SaveToCharDB();
end

-- ============================================================
-- GroupFrameInfo type and query
-- ============================================================

---@class GroupFrameInfo
---@field displayName string User-facing name of this group window
---@field globalName string Stable _G key e.g. "Eavesdropper_Group_Frame_1"
---@field players string[] All tracked senders in this frame
---@field hasSender boolean True if the queried sender is already in this frame

---Returns a sorted snapshot of all active group frames.
---hasSender is true for any frame that already tracks the given sender.
---Returns nil when no frames exist.
---@param sender string? Optional sender to check membership against
---@return GroupFrameInfo[]?
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

---Show or hide the empty-state label based on current player count
function Eavesdropper_Group_FrameMixin:RefreshEmptyState()
	if self.EmptyLabel then
		self.EmptyLabel:SetShown(#self.players == 0);
	end
end

---Add a sender to this frame's player list if not already present
---@param sender string
function Eavesdropper_Group_FrameMixin:AddPlayer(sender)
	if not sender then return; end
	for _, existing in ipairs(self.players) do
		if existing == sender then return; end
	end
	table.insert(self.players, sender);
	self:RefreshEmptyState();
	self:RefreshChat();
	GroupFrame:SaveToCharDB();
end

---Remove a sender from this frame's player list
---@param sender string
function Eavesdropper_Group_FrameMixin:RemovePlayer(sender)
	for i, existing in ipairs(self.players) do
		if existing == sender then
			table.remove(self.players, i);
			self:RefreshEmptyState();
			self:RefreshChat();
			GroupFrame:SaveToCharDB();
			return;
		end
	end
end

---Returns true if the given sender is currently tracked by this frame
---@param sender string
---@return boolean
function Eavesdropper_Group_FrameMixin:HasPlayer(sender)
	for _, player in ipairs(self.players) do
		if player == sender then return true; end
	end
	return false;
end

ED.GroupFrame = GroupFrame;
