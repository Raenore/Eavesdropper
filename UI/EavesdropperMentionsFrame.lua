-- Copyright The Eavesdropper Authors
-- SPDX-License-Identifier: GPL-3.0-or-later

local L = ED.Localization;

---@class EavesdropperMentionsFrameModule
local MentionsFrameModule = {};

---Inherit all shared frame behaviour; frame-specific methods are defined below
---@class EavesdropperMentionsFrameInstance : Eavesdropper_SharedFrameMixin
Eavesdropper_Mentions_FrameMixin = CreateFromMixins(Eavesdropper_SharedFrameMixin);

-- ============================================================
-- Mentions Frame getters (saved in DB with its own profile keys)
-- ============================================================

---@return boolean
function Eavesdropper_Mentions_FrameMixin:IsMouseEnabled()
	return ED.Database:GetSetting("MentionsEnableMouse");
end

---Tied to Jump to Context itself, so the icon always bypasses Enable Mouse while it's on.
---Disable Jump to Context if we want the window to fully click-through instead.
---@return boolean
function Eavesdropper_Mentions_FrameMixin:IsJumpToContextMouseExempt()
	return ED.Database:GetGlobalSetting("MentionsHistoryJumpToContext");
end

---Hardcoded so right-click/hover on player names always bypasses Enable Mouse.
---If we want this to not be default behavior, we can change that here.
---@return boolean
function Eavesdropper_Mentions_FrameMixin:IsPlayerLinkMouseExempt()
	return true;
end

---@return boolean
function Eavesdropper_Mentions_FrameMixin:IsWindowLocked()
	return ED.Database:GetSetting("MentionsLockWindow");
end

---@return boolean
function Eavesdropper_Mentions_FrameMixin:IsScrollLocked()
	return ED.Database:GetSetting("MentionsLockScroll");
end

---@return boolean
function Eavesdropper_Mentions_FrameMixin:IsTitleBarLocked()
	return ED.Database:GetSetting("MentionsLockTitleBar");
end

---Returns the current name-display override, or nil to follow the profile setting.
---Profile-scoped, unlike Group's per-instance CharDB field.
---@return number?
function Eavesdropper_Mentions_FrameMixin:GetNameDisplayMode()
	if not ED.Database:GetSetting("MentionsNameDisplayModeOverride") then return nil; end
	return ED.Database:GetSetting("MentionsNameDisplayMode");
end

---@param mode number? nil clears the override, reverting this window to follow the profile setting.
function Eavesdropper_Mentions_FrameMixin:SetNameDisplayMode(mode)
	if self:GetNameDisplayMode() == mode then return; end
	ED.Database:SetSetting("MentionsNameDisplayModeOverride", mode ~= nil);
	if mode ~= nil then
		ED.Database:SetSetting("MentionsNameDisplayMode", mode);
	end
	self:RefreshChat();
end

---@return string
function Eavesdropper_Mentions_FrameMixin:GetNewIndicatorSettingKey()
	return "MentionsHistoryNewIndicator";
end

---@return string
function Eavesdropper_Mentions_FrameMixin:GetProfileFontSizeKey()
	return "MentionsFontSize";
end

---Mentions additionally requires the entry's reason to match the active mention-reason filters.
---@param entry EavesdropperChatEntry
---@return boolean
function Eavesdropper_Mentions_FrameMixin:IsNewIndicatorEligible(entry)
	return ED.ChatFilters:HasMentionReason(entry.mn);
end

-- ============================================================
-- OnLoad / OnShow / OnHide
-- ============================================================

function Eavesdropper_Mentions_FrameMixin:OnLoad()
	self:InitInstanceFrameState();

	-- Never restored across logins/reloads; only Open() (a deliberate user action) sets this.
	self.userOpened = false;

	self:EnableMouseWheel(true);
	self:UpdateMouseLock();

	Eavesdropper_SharedFrameMixin.InitChatBox(self, ED.Database:GetSetting("MentionsHistorySize"));
	self.EmptyLabel.Text:SetText(L.MENTIONS_EMPTYLABEL_TEXT);

	self:ShowTitleBar();

	-- RestoreLayout sets ResizeHandle/CloseButton visibility right after this runs.
	self:InitCloseButtonClick();

	local titleBtn = self.TitleBar.TitleButton;
	titleBtn.Text:SetText(L.MENTIONS_WINDOW_TITLE);
	titleBtn:SetScript("OnClick", function()
		ED.Config.ShowConfigMenu(self, "mentions");
	end);
	self:ResizeTitleButton();

	self:HookChatboxRefresh();
end

function Eavesdropper_Mentions_FrameMixin:OnShow()
	self:RefreshChat();
	self:StartChatTicker();
end

function Eavesdropper_Mentions_FrameMixin:OnHide()
	self:StopChatTicker();
	self:OnHideCommon();

	-- A combat-driven hide must not count as closing it; Events.lua sets isCombatHidden
	-- before calling HandleVisibility so it knows to reappear once combat ends.
	if not self.isCombatHidden then
		self.userOpened = false;
	end
end

---Marks the window as deliberately opened this session, then shows it (unless combat-hidden).
function Eavesdropper_Mentions_FrameMixin:Open()
	self.userOpened = true;
	self:HandleVisibility();
end

-- ============================================================
-- Mouse / Interaction
-- ============================================================

---Persist window position after a drag. Profile-scoped, unlike Dedicated/Group's CharDB.
function Eavesdropper_Mentions_FrameMixin:OnDragStop()
	self:StopMovingOrSizing();

	local point, _, relativePoint, x, y = self:GetPoint(1);
	ED.Database:SetSetting("MentionsWindowPosition", { point = point, relativePoint = relativePoint, x = x, y = y });
end

---Persist window size and position after a resize. Profile-scoped, unlike Dedicated/Group's CharDB.
function Eavesdropper_Mentions_FrameMixin:OnResizeFinished()
	local w, h = self:GetSize();
	local point, _, relativePoint, x, y = self:GetPoint(1);
	ED.Database:SetSetting("MentionsWindowSize", { width = w, height = h });
	ED.Database:SetSetting("MentionsWindowPosition", { point = point, relativePoint = relativePoint, x = x, y = y });
end

-- ============================================================
-- Layout / Visibility
-- ============================================================

---Restore the title bar options, window position, size, etc all read from the profile.
---Overrides SharedFrameMixin:RestoreLayout which uses local frame state for everything.
function Eavesdropper_Mentions_FrameMixin:RestoreLayout()
	if not ED.Database then return; end

	local pos = ED.Database:GetSetting("MentionsWindowPosition");
	if pos then
		self:ClearAllPoints();
		self:SetPoint(pos.point, UIParent, pos.relativePoint, pos.x, pos.y);
	end

	local size = ED.Database:GetSetting("MentionsWindowSize");
	if size then
		self:SetSize(size.width, size.height);
	end

	if not self:IsWindowLocked() then
		self.ResizeHandle:Show();
	else
		self.ResizeHandle:Hide();
	end

	if ED.Database:GetSetting("MentionsHideCloseButton") then
		self.TitleBar.CloseButton:Hide();
	else
		self.TitleBar.CloseButton:Show();
	end
end

---Overrides SharedFrameMixin:HandleVisibility. Mentions never restores its open state across
---logins/reloads. self.userOpened starts false every session and is only set by Open(). Once
---open, it still respects HideInCombat like its siblings, via Events.lua's isCombatHidden wiring.
function Eavesdropper_Mentions_FrameMixin:HandleVisibility()
	if not self.userOpened then
		self:Hide();
		return;
	end

	if ED.Database:GetSetting("HideInCombat") and ED.Utils.CombatLockdown() then
		self:Hide();
	else
		self:Show();
	end
end

-- ============================================================
-- Chat
-- ============================================================

---Show or hide the empty-state label based on whether the chat box currently has any lines.
function Eavesdropper_Mentions_FrameMixin:RefreshEmptyState()
	if self.EmptyLabel and self.ChatBox then
		self.EmptyLabel:SetShown(self.ChatBox:GetNumMessages() == 0);
	end
end

---Repopulate the chat box from the mention index.
---@param retainScroll boolean? If true, retain the previous scroll position.
function Eavesdropper_Mentions_FrameMixin:RefreshChat(retainScroll)
	if not self.ChatBox then return; end

	self.refreshing = true;

	local scrollOffset = self.ChatBox:GetScrollOffset();
	self.ChatBox:Clear();
	self.newestEntryTime = nil;

	local maxMessages = ED.Database:GetSetting("MentionsHistorySize");
	local mentions = ED.ChatHistory:GetMentions(maxMessages, self);

	for _, entry in ipairs(mentions) do
		self:AddMessage(entry, true);
	end

	self:RefreshEmptyState();

	if retainScroll then
		self.ChatBox:SetScrollOffset(scrollOffset or 0);
	end

	self:UpdateScrollbar();

	self.refreshing = false;
end

---Add a chat entry to the frame
---@param entry EavesdropperChatEntry
---@param fromHistory boolean? True when replayed from history; false/nil for a live message.
function Eavesdropper_Mentions_FrameMixin:AddMessage(entry, fromHistory)
	if not entry then return; end

	if not ED.ChatFilters:HasEvent(entry.e, self) then return; end

	-- fromHistory entries already passed this in ChatHistory:GetMentions; only live entries need it.
	if not fromHistory and not ED.ChatFilters:HasMentionReason(entry.mn) then return; end

	if not self.refreshing then
		self.fade_time = GetTime();
	end

	if not self.ChatBox then return; end

	local r, g, b = ED.ChatFormatter.GetEntryColor(entry);
	local showJumpLink = ED.Database:GetGlobalSetting("DedicatedWindows") and ED.Database:GetGlobalSetting("MentionsHistoryJumpToContext");
	local formatted, _, prefix, suffix, isFrozen = ED.ChatFormatter.FormatMessage(entry, true, self:GetNameDisplayMode(), showJumpLink, self.stripMessageHyperlink);
	self.ChatBox:AddMessage(formatted, r, g, b, entry, prefix, suffix, isFrozen);

	if not fromHistory then
		self:RefreshEmptyState();
	end

	self:TrackNewestEntry(entry);
end

-- ============================================================
-- MentionsFrameModule
-- ============================================================

function MentionsFrameModule.Init()
	---@type EavesdropperMentionsFrameInstance
	local frame = CreateFrame("Frame", "Eavesdropper_Mentions_Frame", UIParent, "Eavesdropper_Mentions_FrameTemplate");
	ED.MentionsFrame = frame;
	frame:Raise();
	frame:HandleVisibility();

	frame:ApplyWindowSettings();
	ED.ChatFilters:Init(frame);
end

ED.MentionsFrameModule = MentionsFrameModule;
