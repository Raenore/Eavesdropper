-- Copyright The Eavesdropper Authors
-- SPDX-License-Identifier: GPL-3.0-or-later

---@type EavesdropperConstants
local Constants = ED.Constants;

---@class EavesdropperFrameModule
local FrameModule = {};

-- Private frame state
local EAVESDROP_TARGET = nil;

---Inherit all shared frame behaviour; frame-specific methods are defined below
---@class EavesdropperFrameInstance : Eavesdropper_SharedFrameMixin
Eavesdropper_FrameMixin = CreateFromMixins(Eavesdropper_SharedFrameMixin);

-- ============================================================
-- Main Frame Getters (saved in DB)
-- ============================================================

---@return boolean
function Eavesdropper_FrameMixin:IsMouseEnabled()
	if not ED.Database then return true; end
	return ED.Database:GetSetting("EnableMouse");
end

---Hardcoded so right-click/hover on player names always bypasses Enable Mouse.
---If we want this to not be default behavior, we can change that here.
---@return boolean
function Eavesdropper_FrameMixin:IsPlayerLinkMouseExempt()
	return true;
end

---@return boolean
function Eavesdropper_FrameMixin:IsWindowLocked()
	return not ED.Database or ED.Database:GetSetting("LockWindow") or false;
end

---@return boolean
function Eavesdropper_FrameMixin:IsScrollLocked()
	return ED.Database ~= nil and ED.Database:GetSetting("LockScroll") or false;
end

---@return boolean
function Eavesdropper_FrameMixin:IsTitleBarLocked()
	return ED.Database ~= nil and ED.Database:GetSetting("LockTitleBar") or false;
end

---@return string
function Eavesdropper_FrameMixin:GetNewIndicatorSettingKey()
	return "WindowNewIndicator";
end

---@return string
function Eavesdropper_FrameMixin:GetProfileFontSizeKey()
	return "FontSize";
end

-- ============================================================
-- OnLoad / OnHide
-- ============================================================

function Eavesdropper_FrameMixin:OnLoad()
	self:EnableMouseWheel(true);
	self:UpdateMouseLock();
	self.clickblock = 0;
	self.isMouseOver = false;
	self.titlebar_name = nil;

	Eavesdropper_SharedFrameMixin.InitChatBox(self, Constants.CHAT_BOX.MAX_HISTORY);

	self:ShowTitleBar();

	-- RestoreLayout sets ResizeHandle/CloseButton visibility right after this runs.
	self:InitCloseButtonClick(function()
		ED.Database:SetCharSetting("WindowVisible", false);
	end);

	-- Configure title button
	self:UpdateTitleBar();

	self:HookChatboxRefresh();
end

function Eavesdropper_FrameMixin:OnHide()
	self:OnHideCommon();
end

-- ============================================================
-- Mouse / Interaction
-- ============================================================

---Persist window position after a drag; intentionally not called from the base
function Eavesdropper_FrameMixin:OnDragStop()
	self:StopMovingOrSizing();

	if not ED.Database then return; end

	local point, _, relativePoint, x, y = self:GetPoint(1);
	ED.Database:SetSetting("WindowPosition", { point = point, relativePoint = relativePoint, x = x, y = y });
end

---Persist window size and position after a resize
function Eavesdropper_FrameMixin:OnResizeFinished()
	if not ED.Database then return; end

	local w, h = self:GetSize();
	local point, _, relativePoint, x, y = self:GetPoint(1);
	ED.Database:SetSetting("WindowSize", { width = w, height = h });
	ED.Database:SetSetting("WindowPosition", { point = point, relativePoint = relativePoint, x = x, y = y });
end

---Returns true if the frame is currently tracking name
---@param name string
---@return boolean
function Eavesdropper_FrameMixin:EavesdroppingOn(name)
	local filter = self.players and self.players[name];
	return filter == 1;
end

---Called when the magnifier target changes; triggers a full target refresh
function Eavesdropper_FrameMixin:UpdateMagnifier()
	if not self then return; end

	ED.Debug:Print("Magnified Changed!");
	self:UpdateTarget();
end

-- ============================================================
-- Layout / Appearance
-- ============================================================

---Updates the name in the title bar
function Eavesdropper_FrameMixin:UpdateTitleBar()
	local newName = "Eavesdropper";
	if ED.Database:GetSetting("UpdateTitleBarWithName") and self.eavesdropped_player then
		local _, firstName = ED.MSP.TryGetMSPData(self.eavesdropped_player, self.eavesdropped_player_guid);
		newName = ED.Utils.StripColorCodes(ED.Utils.StripRealmSuffix(firstName or self.eavesdropped_player));
	end

	if newName == self.titlebar_name then return; end

	self.titlebar_name = newName;
	self.TitleBar.TitleButton.Text:SetText(self.titlebar_name);
	self:ResizeTitleButton();
end

---Restore window position, size, resize handle, and close button from the database.
---Overrides SharedFrameMixin:RestoreLayout which uses local frame state instead.
function Eavesdropper_FrameMixin:RestoreLayout()
	if not ED.Database then return; end

	local pos = ED.Database:GetSetting("WindowPosition");
	if pos then
		self:ClearAllPoints();
		self:SetPoint(pos.point, UIParent, pos.relativePoint, pos.x, pos.y);
	end

	local size = ED.Database:GetSetting("WindowSize");
	if size then
		self:SetSize(size.width, size.height);
	end

	if not ED.Database:GetSetting("LockWindow") then
		self.ResizeHandle:Show();
	else
		self.ResizeHandle:Hide();
	end

	if ED.Database:GetSetting("HideCloseButton") then
		self.TitleBar.CloseButton:Hide();
	else
		self.TitleBar.CloseButton:Show();
	end
end

-- ============================================================
-- Visibility
-- ============================================================

---Overrides SharedFrameMixin:HandleVisibility with HideWhenEmpty and WindowVisible logic
function Eavesdropper_FrameMixin:HandleVisibility()
	if ED.Database:GetSetting("HideInCombat") and ED.Utils.CombatLockdown() then
		self:Hide();
		return;
	end

	local shouldShow = true;

	if ED.Database:GetSetting("HideWhenEmpty") then
		-- Hide when there is no target or the chat box is empty
		if not EAVESDROP_TARGET or self.ChatBox:GetNumMessages() == 0 then
			shouldShow = false;
		end
	elseif not ED.Database:GetCharSetting("WindowVisible") then
		-- HideWhenEmpty is off; fall back to last saved position
		shouldShow = false;
	end

	-- Settings panel open always overrides hide
	if shouldShow or ED.Frame.settingsOpened then
		self:Show();
	else
		self:Hide();
	end
end

-- ============================================================
-- Target tracking
-- ============================================================

---Update the eavesdropped target based on the magnifier, then refresh if needed
function Eavesdropper_FrameMixin:UpdateTarget()
	ED.Debug:Print("UpdateTarget");
	if ED.Utils.CombatLockdown() then return; end

	-- Resolve target from magnifier
	local magnifiedName, magnifiedGUID = ED.Magnifier:GetMagnified();
	local target = magnifiedName
		or (magnifiedGUID and canaccessvalue(magnifiedGUID) and ED.PlayerCache:GetSenderDataFromGUID(magnifiedGUID));

	-- Nothing to track and nothing previously tracked
	if not target and not EAVESDROP_TARGET then return; end

	-- Safety net for UpdateTarget arriving from several sources at once, not a refresh timer.
	local now = GetTime();
	if EAVESDROP_TARGET == target and now - (self.lastUpdate or 0) < Constants.TARGET_UPDATE_THROTTLE then
		return;
	end

	local hardUpdate = EAVESDROP_TARGET ~= target;
	EAVESDROP_TARGET = target;

	-- Recycle players table
	self.players = self.players or {};
	wipe(self.players);

	local companionSupport = ED.Database:GetSetting("CompanionSupport");

	if target and (companionSupport or magnifiedName) then
		self.players[target] = 1;
		self.eavesdropped_player = target;
		self.eavesdropped_player_guid = magnifiedGUID;
	else
		self.eavesdropped_player = nil;
		self.eavesdropped_player_guid = nil;
	end

	-- New target starts at bottom and requires a real rebuild.
	-- Same target just needs its timestamp updated for age.
	if hardUpdate then
		-- A new target invalidates any new-message indicator lit for the previous one.
		if self.newIndicatorTimer then
			self.newIndicatorTimer:Cancel();
			self.newIndicatorTimer = nil;
		end
		self:FadeOutNewIndicator();

		self:RefreshChat();
	elseif not self:IsTimestampFrozen() then
		self:RefreshTimestamps();
	end

	self.lastUpdate = now;

	self:HandleVisibility();
end

-- ============================================================
-- Chat
-- ============================================================

---Repopulate the chat box from stored history
---@param retainScroll boolean? If true, retain the previous scroll position.
function Eavesdropper_FrameMixin:RefreshChat(retainScroll)
	if not self.ChatBox then return; end

	self.refreshing = true;

	local scrollOffset = self.ChatBox:GetScrollOffset();
	self.ChatBox:Clear();
	self.newestEntryTime = nil;

	local maxMessages = ED.Database:GetSetting("MaxHistory");
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

---Add a chat entry to the frame
---@param entry EavesdropperChatEntry
---@param fromHistory boolean
function Eavesdropper_FrameMixin:AddMessage(entry, fromHistory)
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
	local formatted, _, prefix, suffix, isFrozen = ED.ChatFormatter.FormatMessage(entry, nil, nil, nil, self.stripMessageHyperlink);
	self.ChatBox:AddMessage(formatted, r, g, b, entry, prefix, suffix, isFrozen);

	-- Only track lines (to keep frame awake) when they are actually inserted.
	self:TrackNewestEntry(entry);
end

---Keywords are parsed first so every window's refresh below highlights against the new profile.
function Eavesdropper_FrameMixin:ApplyProfileSettings()
	ED.Keywords:ParseList();

	Eavesdropper_SharedFrameMixin.ForEachManagedFrame(function(frame)
		frame:ApplyWindowSettings();
	end);

	if ED.SettingsFrame then
		ED.SettingsFrame:RefreshWidgets();
	end
end

-- ============================================================
-- FrameModule
-- ============================================================

function FrameModule.Init()
	---@type EavesdropperFrameInstance
	local frame = CreateFrame("Frame", "Eavesdropper_Frame", UIParent, "Eavesdropper_FrameTemplate");
	ED.Frame = frame;
	frame:Raise();
	frame:HandleVisibility(); -- Takes HideWhenEmpty & HideInCombat in account

	frame:ApplyProfileSettings();
	ED.ChatFilters:Init(frame);
end

ED.FrameModule = FrameModule;

return FrameModule;
