-- Copyright The Eavesdropper Authors
-- SPDX-License-Identifier: GPL-3.0-or-later

---@type EavesdropperConstants
local Constants = ED.Constants;

---@class EavesdropperDedicatedFrame
local DedicatedFrame = {};

---@type table<string, EavesdropperDedicatedFrameInstance>
DedicatedFrame.frames = DedicatedFrame.frames or {};

---We save a table of current session's dedicated windows by sender.
---Allowing us to restore current session's overrides just in case (close & re-open, etc.)
---@type table<string, EavesdropperSavedDedicatedFrame>
DedicatedFrame.sessionState = DedicatedFrame.sessionState or {};

---Inherit all shared frame behaviour; frame-specific methods are defined below
---@class EavesdropperDedicatedFrameInstance : Eavesdropper_SharedFrameMixin
Eavesdropper_Dedicated_FrameMixin = CreateFromMixins(Eavesdropper_SharedFrameMixin);

-- ============================================================
-- Dedicated Frame Getters (saved in local frame state)
-- ============================================================

---@return boolean
function Eavesdropper_Dedicated_FrameMixin:IsMouseEnabled()
	return self.mouseEnabled;
end

---Hardcoded so right-click/hover on player names always bypasses Enable Mouse.
---If we want this to not be default behavior, we can change that here.
---@return boolean
function Eavesdropper_Dedicated_FrameMixin:IsPlayerLinkMouseExempt()
	return true;
end

---@return boolean
function Eavesdropper_Dedicated_FrameMixin:IsWindowLocked()
	return self.lockWindow;
end

---@return boolean
function Eavesdropper_Dedicated_FrameMixin:IsScrollLocked()
	return self.lockScroll;
end

---@return boolean
function Eavesdropper_Dedicated_FrameMixin:IsTitleBarLocked()
	return self.lockTitleBar;
end

---Returns the current name-display override, or nil to follow the profile setting.
---Only visible on EMOTE/TEXT_EMOTE/ROLL entries (and emote-target RP substitution) since
---those are the only message types that embed a sender name in a non-group window.
---@return number?
function Eavesdropper_Dedicated_FrameMixin:GetNameDisplayMode()
	return self.nameDisplayMode;
end

---@param mode number? nil clears the override, reverting this window to follow the profile setting.
function Eavesdropper_Dedicated_FrameMixin:SetNameDisplayMode(mode)
	if self.nameDisplayMode == mode then return; end
	self.nameDisplayMode = mode;
	self:RefreshChat();
	DedicatedFrame:SaveToCharDB();
end

---@return string
function Eavesdropper_Dedicated_FrameMixin:GetNewIndicatorSettingKey()
	return "DedicatedWindowsNewIndicator";
end

---Font size is per-instance (self.FontSize via CharDB), not profile-scoped.
---@return string?
function Eavesdropper_Dedicated_FrameMixin:GetProfileFontSizeKey()
	return nil;
end

-- ============================================================
-- OnLoad / OnShow / OnHide
-- ============================================================

function Eavesdropper_Dedicated_FrameMixin:OnLoad()
	-- Extract the tracked player from the frame's global name
	local name = self:GetName();
	local player = name:match("^Eavesdropper_Dedicated_Frame_(.+)$");
	self.eavesdropped_player = player;
	self.titlebar_name = nil;

	-- When nil, follows the profile's NameDisplayMode until overridden in SetNameDisplayMode.
	self.nameDisplayMode = nil;

	self:InitInstanceFrameState();

	self:EnableMouseWheel(true);
	self:UpdateMouseLock();

	Eavesdropper_SharedFrameMixin.InitChatBox(self, Constants.CHAT_BOX.MAX_HISTORY);

	-- Inherit font size from the main frame settings
	self.FontSize = ED.Database:GetSetting("FontSize");

	self:ShowTitleBar();

	-- RestoreLayout sets ResizeHandle/CloseButton visibility right after this runs.
	self:InitCloseButtonClick();

	-- Configure title button; prefer MSP display name, fall back to bare player name
	local titleBtn = self.TitleBar.TitleButton;
	self:UpdateTitleBar();
	titleBtn:SetScript("OnClick", function()
		ED.Config.ShowConfigMenu(self, "dedicated");
	end);

	self:HookChatboxRefresh();
end

function Eavesdropper_Dedicated_FrameMixin:OnShow()
	self:RefreshChat();
	self:StartChatTicker();
end

function Eavesdropper_Dedicated_FrameMixin:OnHide()
	Eavesdropper_SharedFrameMixin.OnHideInstanceFrame(self);
end

---Remove self from the DedicatedFrame manager on hide and update saved data.
---Saves to sessionState so we can re-use it in the same session still.
function Eavesdropper_Dedicated_FrameMixin:OnUnregisterFrame()
	local entry = { sender = self.eavesdropped_player, nameDisplayMode = self.nameDisplayMode };
	self:FillSavedStateFields(entry);
	DedicatedFrame.sessionState[self.eavesdropped_player] = entry;

	DedicatedFrame.frames[self.eavesdropped_player] = nil;
	DedicatedFrame:SaveToCharDB();
end

-- ============================================================
-- Mouse / Interaction
-- ============================================================

---Persist position after a drag.
function Eavesdropper_Dedicated_FrameMixin:OnDragStop()
	self:StopMovingOrSizing();
	local point, _, relativePoint, x, y = self:GetPoint(1);
	self.savedPos = { point = point, relativePoint = relativePoint, x = x, y = y };
	DedicatedFrame:SaveToCharDB();
end

---Persist size and position after a resize.
function Eavesdropper_Dedicated_FrameMixin:OnResizeFinished()
	local w, h = self:GetSize();
	local point, _, relativePoint, x, y = self:GetPoint(1);
	self.savedSize = { width = w, height = h };
	self.savedPos = { point = point, relativePoint = relativePoint, x = x, y = y };
	DedicatedFrame:SaveToCharDB();
end

---Persist per-instance state (filters, layout options) after a change.
function Eavesdropper_Dedicated_FrameMixin:SaveInstanceState()
	DedicatedFrame:SaveToCharDB();
end

-- ============================================================
-- Layout / Appearance
-- ============================================================

---Updates the name in the title bar
function Eavesdropper_Dedicated_FrameMixin:UpdateTitleBar()
	local newName = self.eavesdropped_player;

	local newPlayer, newGuid = ED.PlayerCache:InsertAndRetrieve(self.eavesdropped_player);
	if newPlayer and newGuid then
		local _, firstName = ED.MSP.TryGetMSPData(newPlayer, newGuid);
		newName = ED.Utils.StripColorCodes(ED.Utils.StripRealmSuffix(firstName or newPlayer));
	else
		newName = ED.Utils.StripRealmSuffix(newName);
	end

	if newName == self.titlebar_name then return; end

	self.titlebar_name = newName;
	self.TitleBar.TitleButton.Text:SetText(self.titlebar_name);
	self:ResizeTitleButton();
end

-- ============================================================
-- Chat
-- ============================================================

---Repopulate the chat box from stored history. Uses jumpHistoryLimit instead of MaxHistory
---while a jump's widened buffer is still in view; drops back to normal once scrolled to bottom.
---@param retainScroll boolean? If true, retain the previous scroll position.
function Eavesdropper_Dedicated_FrameMixin:RefreshChat(retainScroll)
	if not self.ChatBox then return; end

	self.refreshing = true;

	local scrollOffset = self.ChatBox:GetScrollOffset();

	if self.jumpHistoryLimit and scrollOffset == 0 then
		self.jumpHistoryLimit = nil;
		self.ChatBox:SetMaxLines(Constants.CHAT_BOX.MAX_HISTORY);
	end

	self.ChatBox:Clear();
	self.newestEntryTime = nil;

	local maxMessages = self.jumpHistoryLimit or ED.Database:GetSetting("MaxHistory");
	local player = self.eavesdropped_player;

	if player then
		self:PopulateHistoryMessages(player, maxMessages);
	end

	if retainScroll then
		self.ChatBox:SetScrollOffset(scrollOffset or 0);
	end

	self:UpdateTitleBar();
	self.refreshing = false;
end

---Scrolls so entryId lands as the bottom-most visible line. SetScrollOffset fixes to the
---bottom edge, not the top. Widens the history buffer via jumpHistoryLimit when entryId
---needs more than MAX_HISTORY; RefreshChat drops it back to normal once scrolled to bottom.
---@param entryId number
function Eavesdropper_Dedicated_FrameMixin:ScrollToEntry(entryId)
	if not self.ChatBox then return; end

	local targetEntry = ED.ChatHistory:GetEntry(entryId);
	if targetEntry then
		ED.ChatFilters:EnsureEntryVisible(self, targetEntry);
	end

	self.refreshing = true;
	self.ChatBox:Clear();
	self.newestEntryTime = nil;

	local player = self.eavesdropped_player;
	local padding = Constants.CHAT_BOX.JUMP_CONTEXT_PADDING;
	local offset = 0;

	if player then
		local chat = ED.ChatHistory:GetPlayerHistoryAroundEntry(player, entryId, padding, self)
			or ED.ChatHistory:GetPlayerHistoryAroundEntry(ED.Utils.StripRealmSuffix(player), entryId, padding, self);

		if chat then
			if #chat > (self.jumpHistoryLimit or Constants.CHAT_BOX.MAX_HISTORY) then
				self.jumpHistoryLimit = #chat;
				self.ChatBox:SetMaxLines(self.jumpHistoryLimit);
			end

			for i, entry in ipairs(chat) do
				self:AddMessage(entry, true);
				if entry.id == entryId then
					offset = #chat - i;
				end
			end
		end
	end

	self.ChatBox:SetScrollOffset(offset);
	self:UpdateTitleBar();
	self.refreshing = false;
end

---Add a chat entry to the frame
---@param entry EavesdropperChatEntry
---@param fromHistory boolean
function Eavesdropper_Dedicated_FrameMixin:AddMessage(entry, fromHistory)
	if not entry then return; end

	if not ED.ChatFilters:HasEvent(entry.e, self) then return; end

	if not self.refreshing then
		self.fade_time = GetTime();
	end

	if not self.ChatBox then return; end

	if not fromHistory and (ED.Database:GetSetting("HideWhenEmpty") or ED.Frame.settingsOpened) then
		self:Show();
	end

	local r, g, b = ED.ChatFormatter.GetEntryColor(entry);
	local formatted, _, prefix, suffix, isFrozen = ED.ChatFormatter.FormatMessage(entry, false, self.nameDisplayMode, nil, self.stripMessageHyperlink);
	self.ChatBox:AddMessage(formatted, r, g, b, entry, prefix, suffix, isFrozen);

	-- Only track lines (to keep frame awake) when they are actually inserted.
	self:TrackNewestEntry(entry);
end

-- ============================================================
-- DedicatedFrame manager
-- ============================================================

---Iterate all live dedicated frames
---@param func fun(frame: EavesdropperDedicatedFrameInstance)
function DedicatedFrame:ForEachFrame(func)
	for _, frame in pairs(self.frames) do
		if frame then
			func(frame);
		end
	end
end

---Stores every per-instance option for each visible dedicated frame.
function DedicatedFrame:SaveToCharDB()
	if not EavesdropperCharDB then return; end

	local profileMode = ED.Database:GetSetting("NameDisplayMode");
	local saved = {};

	for sender, frame in pairs(self.frames) do
		if frame then
			local entry = { sender = sender };
			frame:FillSavedStateFields(entry);

			---Only persist nameDisplayMode when it differs from the profile default.
			if frame.nameDisplayMode and frame.nameDisplayMode ~= profileMode then
				entry.nameDisplayMode = frame.nameDisplayMode;
			end

			saved[#saved + 1] = entry;
		end
	end

	EavesdropperCharDB.dedicatedFrames = saved;
end

---Restore dedicated frames from the character saved variables.
---Handles both the legacy string format and the current table format.
function DedicatedFrame:RestoreFromCharDB()
	if not EavesdropperCharDB then return; end

	local saved = EavesdropperCharDB.dedicatedFrames;
	if not saved or #saved == 0 then return; end

	for _, entry in ipairs(saved) do
		local sender = type(entry) == "string" and entry or entry.sender;
		if sender and sender ~= "" then
			-- Pass entry explicitly: AddFrame's own lookup reads the live CharDB table.
			local frame = self:AddFrame(sender, type(entry) == "table" and entry or nil);
			if frame then
				frame:ApplySavedLayout(entry.pos, entry.size);
			end
		end
	end

	-- Save once more now that every frame's layout is settled.
	self:SaveToCharDB();
end

---Look up sender's saved CharDB entry, used to restore a window reopened mid-session
---RestoreFromCharDB does not require this as it passes entry explicitly.
---@param sender string
---@return EavesdropperSavedDedicatedFrame?
function DedicatedFrame:FindSavedEntry(sender)
	local saved = EavesdropperCharDB and EavesdropperCharDB.dedicatedFrames;
	if not saved then return nil; end

	for _, entry in ipairs(saved) do
		if type(entry) == "table" and entry.sender == sender then
			return entry;
		end
	end

	return nil;
end

---Returns true if a dedicated frame already exists for sender
---@param sender string
---@return boolean
function DedicatedFrame:FrameExists(sender)
	return self.frames[sender] ~= nil;
end

---Handle creating/showing a dedicated frame for current magnified target.
---GetMagnified incorporates the user's choice of targeting priority.
function DedicatedFrame:AddFrameForMagnified()
	local magnifiedName, magnifiedGUID = ED.Magnifier:GetMagnified();
	local target = magnifiedName
		or (magnifiedGUID and canaccessvalue(magnifiedGUID) and ED.PlayerCache:GetSenderDataFromGUID(magnifiedGUID));

	if target then
		ED.PlayerCache:InsertAndRetrieve(magnifiedName, magnifiedGUID);
		self:AddFrame(target);
	end
end

---Show an existing dedicated frame for sender, or create and initialise a new one.
---A fresh frame restores from, in priority order:
---Explicit savedEntry > sessionState > CharDB's FindSavedEntry.
---@param sender string
---@param savedEntry EavesdropperSavedDedicatedFrame? Pass explicitly from RestoreFromCharDB's pass.
---@return EavesdropperDedicatedFrameInstance
function DedicatedFrame:AddFrame(sender, savedEntry)
	---@type EavesdropperDedicatedFrameInstance?
	local frame = _G["Eavesdropper_Dedicated_Frame_" .. sender];

	if frame then
		frame:Show();
		frame:Raise();
	else
		frame = CreateFrame("Frame", "Eavesdropper_Dedicated_Frame_" .. sender, UIParent, "Eavesdropper_Dedicated_FrameTemplate");
		frame:Raise();
		frame:HandleVisibility();

		local entry = savedEntry or self.sessionState[sender] or self:FindSavedEntry(sender);

		frame:ApplyWindowSettings(entry ~= nil);
		ED.ChatFilters:Init(frame);

		if entry then
			if entry.nameDisplayMode then
				frame.nameDisplayMode = entry.nameDisplayMode;
			end
			frame:ApplySavedLayout(entry.pos, entry.size);
			frame:ApplySavedFilters(entry.filters);
			frame:ApplySavedOptions(entry);
		end
	end

	frame:UpdateScrollbar();

	self.frames[sender] = frame;
	self:SaveToCharDB();

	return frame;
end

---Open (or focus) sender's dedicated window and scroll it to entryId.
---@param sender string
---@param entryId number
function DedicatedFrame:JumpToEntry(sender, entryId)
	local frame = self:AddFrame(sender);
	frame:ScrollToEntry(entryId);
end

ED.DedicatedFrame = DedicatedFrame;
