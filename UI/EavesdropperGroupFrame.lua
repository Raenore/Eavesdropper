-- Copyright The Eavesdropper Authors
-- SPDX-License-Identifier: GPL-3.0-or-later

---@type EavesdropperConstants
local Constants = ED.Constants;

local L = ED.Localization;

---@class EavesdropperGroupFrame
local GroupFrame = {};

---@class EavesdropperSavedGroupFrame
---@field name string Display name of the group window
---@field players string[] Tracked senders in "Name-Realm" format
---@field nameDisplayMode number? Only stored when it differs from main Eavesdropper
---@field filters table<string, boolean>? Per-instance filter overrides; absent means "not yet saved"
---@field mouseEnabled boolean?
---@field lockWindow boolean?
---@field lockScroll boolean?
---@field lockTitleBar boolean?
---@field hideCloseButton boolean?
---@field fontSize number?

---@class EavesdropperGroupSessionState
---@field name string Display name of the group window
---@field pos EavesdropperWindowPosition?
---@field size EavesdropperWindowSize?
---@field filters table<string, boolean>?
---@field nameDisplayMode number?
---@field mouseEnabled boolean?
---@field lockWindow boolean?
---@field lockScroll boolean?
---@field lockTitleBar boolean?
---@field hideCloseButton boolean?
---@field fontSize number?
---@field players string[]? For GroupDialog's restore prompt only; CreateNamedFrame never reads it.

---Held by group name (case-sensitive), which HasFrameWithName checks lowercase (non-sensitive).
---@type table<string, EavesdropperGroupFrameInstance>
GroupFrame.frames = GroupFrame.frames or {};

---We save a table of current session's group windows by lowercase group names.
---Allowing us to restore current session's overrides just in case (close & re-open, etc.)
---@type table<string, EavesdropperGroupSessionState>
GroupFrame.sessionState = GroupFrame.sessionState or {};

---Inherit all shared frame behaviour; frame-specific methods are defined below
---@class EavesdropperGroupFrameInstance : Eavesdropper_SharedFrameMixin
Eavesdropper_Group_FrameMixin = CreateFromMixins(Eavesdropper_SharedFrameMixin);

-- ============================================================
-- Group Frame Getters (saved in local frame state)
-- ============================================================

---@return boolean
function Eavesdropper_Group_FrameMixin:IsMouseEnabled()
	return self.mouseEnabled;
end

---Tied to Jump to Context itself, so the icon always bypasses Enable Mouse while it's on.
---Disable Jump to Context if we want the window to fully click-through instead.
---@return boolean
function Eavesdropper_Group_FrameMixin:IsJumpToContextMouseExempt()
	return ED.Database:GetGlobalSetting("GroupWindowsJumpToContext");
end

---Hardcoded so right-click/hover on player names always bypasses Enable Mouse.
---If we want this to not be default behavior, we can change that here.
---@return boolean
function Eavesdropper_Group_FrameMixin:IsPlayerLinkMouseExempt()
	return true;
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

---Returns the current name-display override, or nil to follow the profile setting.
---@return number?
function Eavesdropper_Group_FrameMixin:GetNameDisplayMode()
	return self.nameDisplayMode;
end

---@param mode number? nil clears the override, reverting this window to follow the profile setting.
function Eavesdropper_Group_FrameMixin:SetNameDisplayMode(mode)
	if self.nameDisplayMode == mode then return; end
	self.nameDisplayMode = mode;
	self:RefreshChat();
	GroupFrame:SaveToCharDB();
end

---@return string
function Eavesdropper_Group_FrameMixin:GetNewIndicatorSettingKey()
	return "GroupWindowsNewIndicator";
end

---Font size is per-instance (self.FontSize via CharDB), not profile-scoped.
---@return string?
function Eavesdropper_Group_FrameMixin:GetProfileFontSizeKey()
	return nil;
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

	-- When nil, follows the profile's NameDisplayMode until overridden in SetNameDisplayMode.
	self.nameDisplayMode = nil;

	self:InitInstanceFrameState();

	self:EnableMouseWheel(true);
	self:UpdateMouseLock();

	Eavesdropper_SharedFrameMixin.InitChatBox(self, ED.Database:GetGlobalSetting("GroupHistorySize"));
	self.EmptyLabel.Text:SetText(L.EMPTYLABEL_TEXT);

	-- Inherit font size from the main frame settings
	self.FontSize = ED.Database:GetSetting("FontSize");

	self:ShowTitleBar();

	-- RestoreLayout sets ResizeHandle/CloseButton visibility right after this runs.
	self:InitCloseButtonClick();

	-- Configure title button; triggers the group config menu
	local titleBtn = self.TitleBar.TitleButton;
	titleBtn:SetScript("OnClick", function()
		ED.Config.ShowConfigMenu(self, "group");
	end);

	self:HookChatboxRefresh();
end

function Eavesdropper_Group_FrameMixin:OnShow()
	self:RefreshChat();
	self:StartChatTicker();
end

function Eavesdropper_Group_FrameMixin:OnHide()
	Eavesdropper_SharedFrameMixin.OnHideInstanceFrame(self);
end

---Remove self from the GroupFrame manager on hide and update saved data.
---Saves to sessionState so we can re-use it in the same session still (if using same group name).
function Eavesdropper_Group_FrameMixin:OnUnregisterFrame()
	if self.displayName then
		local entry = {
			name = self.displayName,
			nameDisplayMode = self.nameDisplayMode,
			players = ED.Utils.ShallowCopy(self.players),
		};
		self:FillSavedStateFields(entry);
		GroupFrame.sessionState[self.displayName:lower()] = entry;

		GroupFrame.frames[self.displayName] = nil;
		GroupFrame:SaveToCharDB();
	end
end

-- ============================================================
-- Mouse / Interaction
-- ============================================================

---Persist position after a drag.
function Eavesdropper_Group_FrameMixin:OnDragStop()
	self:StopMovingOrSizing();
	local point, _, relativePoint, x, y = self:GetPoint(1);
	self.savedPos = { point = point, relativePoint = relativePoint, x = x, y = y };
	GroupFrame:SaveToCharDB();
end

---Persist size and position after a resize.
function Eavesdropper_Group_FrameMixin:OnResizeFinished()
	local w, h = self:GetSize();
	local point, _, relativePoint, x, y = self:GetPoint(1);
	self.savedSize = { width = w, height = h };
	self.savedPos = { point = point, relativePoint = relativePoint, x = x, y = y };
	GroupFrame:SaveToCharDB();
end

---Persist per-instance state (filters, layout options) after a change.
function Eavesdropper_Group_FrameMixin:SaveInstanceState()
	GroupFrame:SaveToCharDB();
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

---Refreshes the chat box. `retainScroll` (used by the timestamp ticker and the MSP-driven
---refresh) redraws the already-built merged cache; anything else triggers a full rebuild.
---@param retainScroll boolean? If true, retain the previous scroll position.
function Eavesdropper_Group_FrameMixin:RefreshChat(retainScroll)
	if not self.ChatBox then return; end

	if retainScroll and self.mergedHistory then
		self:RedrawChat(retainScroll);
		return;
	end

	if not self.players or #self.players == 0 then
		self.mergedHistory = {};
		self:RedrawChat(retainScroll);
		return;
	end

	local maxMessages = ED.Database:GetGlobalSetting("GroupHistorySize");
	self:RebuildMergedHistory(maxMessages, retainScroll);
end

---Collects & deduplicates history across all tracked players, sorts and trims it to maxMessages,
---then stores it in self.mergedHistory. Above Constants.CHAT_BOX.GROUP_CHUNK_THRESHOLD
---(trackedPlayers x maxMessages), gathering spreads one player per RunNextFrame to avoid FPS hits on huge groups.
---@param maxMessages number
---@param retainScroll boolean?
---@param forceSync boolean? Bypasses the chunk threshold to gather synchronously; used by the debug measurement harness.
function Eavesdropper_Group_FrameMixin:RebuildMergedHistory(maxMessages, retainScroll, forceSync)
	self.mergeGeneration = (self.mergeGeneration or 0) + 1;
	local generation = self.mergeGeneration;

	-- Chunking gathering takes time and might span multiple frames, so we keep the current id and table here.
	-- We can then use this in Finish() to still fold new live messages into self.mergedHistory (through AppendToMergedHistory).
	local rebuildStartId = ED.ChatHistory.nextEntryId;
	local previousMerged = self.mergedHistory;

	local players = self.players;
	local seen = {};
	local entries = {};

	---Gathers one player's history into entries/seen, deduplicating by entry id, as we did in the past.
	---@param player string
	local function GatherPlayer(player)
		local history = ED.ChatHistory:GetPlayerHistory(player, maxMessages, self);

		if not history or #history == 0 then
			history = ED.ChatHistory:GetPlayerHistory(ED.Utils.StripRealmSuffix(player), maxMessages, self);
		end

		if history then
			for _, entry in ipairs(history) do
				if not seen[entry.id] then
					seen[entry.id] = true;
					entries[#entries + 1] = entry;
				end
			end
		end
	end

	---Sorts entries ascending by id and trims to maxMessages.
	local function SortAndTrim()
		if #entries == 0 then return; end

		table.sort(entries, function(a, b) return a.id < b.id; end);

		local start = math.max(1, #entries - maxMessages + 1);
		local trimmed = {};
		for i = start, #entries do
			trimmed[#trimmed + 1] = entries[i];
		end
		entries = trimmed;
	end

	---Sorts and trims the gather, folds in anything appended live since the rebuild started,
	---stores the result, and redraws. See comment @ rebuildStartId for further info.
	local function Finish()
		SortAndTrim();

		if previousMerged then
			local foldedInLive = false;

			for _, entry in ipairs(previousMerged) do
				if entry.id >= rebuildStartId and not seen[entry.id] then
					seen[entry.id] = true;
					entries[#entries + 1] = entry;
					foldedInLive = true;
				end
			end

			if foldedInLive then
				SortAndTrim();
			end
		end

		self.mergedHistory = entries;
		self:RedrawChat(retainScroll);
	end

	if forceSync or (#players * maxMessages <= Constants.CHAT_BOX.GROUP_CHUNK_THRESHOLD) then
		for _, player in ipairs(players) do
			GatherPlayer(player);
		end
		Finish();
		return;
	end

	-- We use a counter for generation so that an invalidated rebuild is stopped early in favor of the newer one.
	local index = 0;
	local function Step()
		if generation ~= self.mergeGeneration then return; end

		index = index + 1;
		local player = players[index];

		if not player then
			Finish();
			return;
		end

		GatherPlayer(player);
		RunNextFrame(Step);
	end

	Step();
end

---Clears the ChatBox and replays the cached merged history into it. Does not re-gather,
---dedupe, or sort; callers needing that go through RebuildMergedHistory.
---@param retainScroll boolean? If true, retain the previous scroll position.
function Eavesdropper_Group_FrameMixin:RedrawChat(retainScroll)
	if not self.ChatBox then return; end

	self.refreshing = true;

	local scrollOffset = self.ChatBox:GetScrollOffset();
	self.ChatBox:Clear();
	self.newestEntryTime = nil;

	if self.mergedHistory then
		for _, entry in ipairs(self.mergedHistory) do
			self:AddMessage(entry, true);
		end
	end

	if retainScroll then
		self.ChatBox:SetScrollOffset(scrollOffset or 0);
	end

	self.refreshing = false;
end

---Appends a live entry to the cached merged history, if over cap we trim from the front.
---Safe as it does not require re-sorting and they have higher IDs so live after the cache.
---@param entry EavesdropperChatEntry
function Eavesdropper_Group_FrameMixin:AppendToMergedHistory(entry)
	if not self.mergedHistory then return; end

	self.mergedHistory[#self.mergedHistory + 1] = entry;

	local maxMessages = ED.Database:GetGlobalSetting("GroupHistorySize");
	while #self.mergedHistory > maxMessages do
		table.remove(self.mergedHistory, 1);
	end
end

---Add a chat entry to the frame
---@param entry EavesdropperChatEntry
---@param fromHistory boolean? True when replayed from the merged history cache; false/nil for a live message.
function Eavesdropper_Group_FrameMixin:AddMessage(entry, fromHistory)
	if not entry then return; end

	if not ED.ChatFilters:HasEvent(entry.e, self) then return; end

	if not self.refreshing then
		self.fade_time = GetTime();
	end

	if not self.ChatBox then return; end

	if not fromHistory then
		if ED.Database:GetSetting("HideWhenEmpty") or ED.Frame.settingsOpened then
			self:Show();
		end

		self:AppendToMergedHistory(entry);
	end

	local r, g, b = ED.ChatFormatter.GetEntryColor(entry);
	local showJumpLink = ED.Database:GetGlobalSetting("DedicatedWindows") and ED.Database:GetGlobalSetting("GroupWindowsJumpToContext");
	local formatted, _, prefix, suffix, isFrozen = ED.ChatFormatter.FormatMessage(entry, true, self.nameDisplayMode, showJumpLink, self.stripMessageHyperlink);
	self.ChatBox:AddMessage(formatted, r, g, b, entry, prefix, suffix, isFrozen);

	-- Only track lines (to keep frame awake) when they are actually inserted.
	self:TrackNewestEntry(entry);
end

-- ============================================================
-- Group manager
-- ============================================================

---Update the display name and re-key in the manager table.
---Also clears the old named session info and creates for the new name.
---@param newName string
function Eavesdropper_Group_FrameMixin:RenameFrame(newName)
	if not newName or newName == "" then return; end
	if newName == self.displayName then return; end
	if GroupFrame:HasFrameWithName(newName, self) then return; end

	local oldName = self.displayName;

	-- Re-key before mutating displayName so HasFrameWithName stays consistent
	GroupFrame.frames[oldName] = nil;
	self.displayName = newName;
	GroupFrame.frames[self.displayName] = self;
	GroupFrame.sessionState[oldName:lower()] = nil;

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
---@param func fun(frame: EavesdropperGroupFrameInstance)
function GroupFrame:ForEachFrame(func)
	for _, frame in pairs(self.frames) do
		if frame then func(frame); end
	end
end

---Returns true if any active group frame already uses the given display name, case-insensitively.
---@param name string
---@param excludeFrame EavesdropperGroupFrameInstance? Skip this frame. Used when renaming, so a pure
---case change (e.g. "Demo" -> "demo") isn't rejected as a duplicate of itself.
---@return boolean
function GroupFrame:HasFrameWithName(name, excludeFrame)
	local lowerName = name:lower();
	for _, frame in pairs(self.frames) do
		if frame and frame ~= excludeFrame and frame.displayName and frame.displayName:lower() == lowerName then
			return true;
		end
	end
	return false;
end

---Stores every per-instance option for each visible group frame.
function GroupFrame:SaveToCharDB()
	if not EavesdropperCharDB then return; end

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

			frame:FillSavedStateFields(entry);

			saved[#saved + 1] = entry;
		end
	end

	EavesdropperCharDB.groupFrames = saved;
end

---Restore group frames from the character saved variables.
function GroupFrame:RestoreFromCharDB()
	if not EavesdropperCharDB then return; end

	local saved = EavesdropperCharDB.groupFrames;
	if not saved or #saved == 0 then return; end

	for _, entry in ipairs(saved) do
		if entry.name and entry.players and #entry.players > 0 then
			-- Pass entry explicitly: CreateNamedFrame's own lookup reads the live CharDB table.
			self:CreateNamedFrame(entry.name, nil, entry.players, entry);
		end
	end

	-- Save once more now that every frame's layout is settled.
	self:SaveToCharDB();
end

---Look up group name's saved CharDB entry, case-insensitively, used to restore a window reopened mid-session
---RestoreFromCharDB does not require this as it passes entry explicitly.
---@param displayName string
---@return EavesdropperSavedGroupFrame?
function GroupFrame:FindSavedEntry(displayName)
	local saved = EavesdropperCharDB and EavesdropperCharDB.groupFrames;
	if not saved then return nil; end

	local lowerName = displayName:lower();
	for _, entry in ipairs(saved) do
		if entry.name and entry.name:lower() == lowerName then
			return entry;
		end
	end

	return nil;
end

---Prompt the user for a group name before creating any frame.
---No frame is created if the user cancels or submits an empty name.
---@param sender string Initial sender in "Name-Realm" format
function GroupFrame:AddFrame(sender)
	StaticPopup_Show("EAVESDROPPER_NAME_GROUP", nil, nil, { sender = sender });
end

---Finds the lowest free numeric index for the stable _G frame name, creates the frame, registers
---it keyed by displayName, and restores options from savedEntry, sessionState, or CharDB's
---FindSavedEntry (in that priority), never the player list; see GroupDialog.CreateOrRestore.
---@param displayName string
---@param sender string? Initial sender to seed the frame with
---@param playerList string[]? Full player list for restore; takes precedence over sender
---@param savedEntry EavesdropperSavedGroupFrame? Pass explicitly from RestoreFromCharDB's pass.
---@param forceFresh boolean? Skip all entry lookups, even a match. Used on a declined restore.
function GroupFrame:CreateNamedFrame(displayName, sender, playerList, savedEntry, forceFresh)
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
	---@type EavesdropperGroupFrameInstance
	local frame = CreateFrame("Frame", globalName, UIParent, "Eavesdropper_Group_FrameTemplate");
	frame:Raise();
	frame:HandleVisibility();
	-- Player list setup and/or the saved-entry restore below always trigger their own refresh.
	frame:ApplyWindowSettings(true);
	ED.ChatFilters:Init(frame);

	frame.displayName = displayName;
	frame.players = {};
	frame.playerListDirty = true;
	frame.playerListCache = nil;

	if playerList and #playerList > 0 then
		for _, player in ipairs(playerList) do
			frame.players[#frame.players + 1] = player;
		end
		frame:RefreshEmptyState();
	elseif sender then
		frame:AddPlayer(sender);
	end

	local entry = not forceFresh and (savedEntry or self.sessionState[displayName:lower()] or self:FindSavedEntry(displayName));
	if entry then
		if entry.nameDisplayMode then
			frame.nameDisplayMode = entry.nameDisplayMode;
		end
		frame:ApplySavedLayout(entry.pos, entry.size);
		frame:ApplySavedFilters(entry.filters);
		frame:ApplySavedOptions(entry);
	end

	frame:UpdateTitleBar();
	if not entry then
		frame:RefreshChat(); -- Restoring a saved entry already refreshed via ApplySavedOptions above.
	end
	frame:UpdateScrollbar();

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
			result[#result + 1] = {
				displayName = frame.displayName,
				globalName = frame:GetName(),
				players = frame.players,
				hasSender = sender ~= nil and frame:HasPlayer(sender) or false,
			};
		end
	end

	if #result == 0 then return nil; end

	table.sort(result, function(a, b) return a.displayName < b.displayName; end);

	return result;
end

-- ============================================================
-- Player List menu
-- ============================================================

---Creates a checkbox menu of cached tracked players (or newly iterated on if frame.playerListDirty).
---Each row is a tracked player with a dedicated window button, with first row being a "Add Target" option.
---@param frame EavesdropperGroupFrame
---@param menu table
function GroupFrame:GeneratePlayerListMenu(frame, menu)
	if menu.SetScrollMode then
		local optionHeight = 20; -- 20 is the default height.
		local maxLines = 20;
		local maxScrollExtent = optionHeight * maxLines;
		menu:SetScrollMode(maxScrollExtent);
	end

	-- Leading action row, like "Profile Management" has to add current target to tracked players.
	local canAddTarget = UnitExists("target") and UnitIsPlayer("target");
	local targetSender, targetGUID;
	if canAddTarget then
		targetSender = ED.Utils.GetUnitName("target");
		targetGUID = UnitGUID("target");
		if not targetSender or frame:HasPlayer(targetSender) then
			canAddTarget = false;
		end
	end

	local addTargetIcon = CreateAtlasMarkup(canAddTarget and "editmode-new-layout-plus" or "editmode-new-layout-plus-disabled");
	local addTargetText = L.PLAYER_LIST_ADD_TARGET;
	if canAddTarget then
		addTargetText = "|cnPURE_GREEN_COLOR:" .. addTargetText .. "|r";
	end

	local addTargetEntry = menu:CreateButton(addTargetIcon .. " " .. addTargetText, function()
		ED.PlayerCache:InsertAndRetrieve(targetSender, targetGUID);
		frame:AddPlayer(targetSender);
	end);
	addTargetEntry:SetEnabled(canAddTarget);
	ED.Utils.SetMenuTooltip(addTargetEntry, L.PLAYER_LIST_ADD_TARGET_HELP, L.PLAYER_LIST_ADD_TARGET);

	menu:CreateDivider();

	if frame.playerListDirty or not frame.playerListCache then
		local rows = {};

		for _, player in ipairs(frame.players) do
			local entry = ED.PlayerCache:GetSenderEntry(player);
			local guid = entry and entry.guid;
			local firstName;
			if guid then
				_, firstName = ED.MSP.TryGetMSPData(player, guid);
			end

			local oocName = ED.Utils.IsSameRealmName(player) and ED.Utils.StripRealmSuffix(player) or player;
			local label = (firstName and firstName ~= oocName) and (firstName .. " (" .. oocName .. ")") or oocName;

			rows[#rows + 1] = { player = player, guid = guid, label = label, sortKey = firstName or oocName };
		end

		table.sort(rows, function(a, b) return a.sortKey < b.sortKey; end);

		frame.playerListCache = rows;
		frame.playerListDirty = false;
	end

	if #frame.playerListCache == 0 then
		menu:CreateButton(L.PLAYER_LIST_EMPTY):SetEnabled(false);
		return;
	end

	local dedicatedWindowsEnabled = ED.Database:GetGlobalSetting("DedicatedWindows");

	for _, row in ipairs(frame.playerListCache) do
		-- Unchecking removes the player, re-checking re-adds them; CreateCheckbox stays open on
		-- click, so an accidental removal is undone just by checking the box again.
		local rowCheckbox = menu:CreateCheckbox(
			row.label,
			function() return frame:HasPlayer(row.player); end,
			function()
				if frame:HasPlayer(row.player) then
					frame:RemovePlayer(row.player);
				else
					ED.PlayerCache:InsertAndRetrieve(row.player, row.guid);
					frame:AddPlayer(row.player);
				end
			end
		);
		ED.Utils.SetMenuTooltip(rowCheckbox, L.PLAYER_LIST_ROW_HELP);

		rowCheckbox:AddInitializer(function(button)
			local dedicatedButton = MenuTemplates.AttachAutoHideCancelButton(button);
			dedicatedButton:SetSize(20, 20);
			dedicatedButton.Texture:SetTexture(ED.Constants.ICONS.PERSON_BUTTON);
			dedicatedButton.Texture:SetSize(18, 18);
			dedicatedButton.Texture:ClearAllPoints();
			dedicatedButton.Texture:SetPoint("CENTER", dedicatedButton, "CENTER", 0, 0);

			-- Checking/unchecking re-initializes attached widgets without a real mouse leave/enter.
			-- If the button is already visible post-re-init, check focus immediately; otherwise it
			-- was hidden by the re-init, so defer the check to next frame once it's back.
			if button:IsVisible() then
				if button:IsMouseMotionFocus() then
					dedicatedButton:Show();
				end
			else
				RunNextFrame(function()
					if button:IsMouseMotionFocus() then
						dedicatedButton:Show();
					end
				end);
			end

			MenuTemplates.SetUtilityButtonAnchor(dedicatedButton, MenuVariants.GearButtonAnchor, button);
			MenuTemplates.SetUtilityButtonClickHandler(dedicatedButton, function()
				if not dedicatedWindowsEnabled or ED.DedicatedFrame:FrameExists(row.player) then
					return;
				end
				ED.PlayerCache:InsertAndRetrieve(row.player, row.guid);
				ED.DedicatedFrame:AddFrame(row.player);
			end);

			MenuUtil.HookTooltipScripts(dedicatedButton, function(tooltip)
				GameTooltip_SetTitle(tooltip, L.PLAYER_LIST_OPEN_DEDICATED);
				GameTooltip_AddNormalLine(tooltip, L.PLAYER_LIST_OPEN_DEDICATED_HELP);
			end);

			-- Small hack to keep showing tooltips when you move between the dedicated button and row.
			dedicatedButton:HookScript("OnLeave", function()
				if button:IsMouseOver() then
					local description = button:GetElementDescription();
					if description then
						description:HandleOnEnter(button);
					end
				end
			end);
		end);
	end
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
	self.players[#self.players + 1] = sender;
	self.playerListDirty = true;
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
			self.playerListDirty = true;
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
