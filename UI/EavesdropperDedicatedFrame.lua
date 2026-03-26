-- Copyright The Eavesdropper Authors
-- SPDX-License-Identifier: Apache-2.0

---@type EavesdropperConstants
local Constants = ED.Constants;

---@type EavesdropperEnums
local Enums = ED.Enums;

---@class EavesdropperDedicatedFrame
local DedicatedFrame = {};

---@type table<string, EavesdropperDedicatedFrame>
DedicatedFrame.frames = DedicatedFrame.frames or {};

---Inherit all shared frame behaviour; frame-specific methods are defined below
Eavesdropper_Dedicated_FrameMixin = CreateFromMixins(Eavesdropper_SharedFrameMixin);

-- ============================================================
-- Dedicated Frame Getters (saved in local frame state)
-- ============================================================

---@return boolean
function Eavesdropper_Dedicated_FrameMixin:IsMouseEnabled()
	return self.mouseEnabled;
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

-- ============================================================
-- OnLoad / OnShow / OnHide
-- ============================================================

function Eavesdropper_Dedicated_FrameMixin:OnLoad()
	-- Extract the tracked player from the frame's global name
	local name = self:GetName();
	local player = name:match("^Eavesdropper_Dedicated_Frame_(.+)$");
	self.eavesdropped_player = player;
	self.titlebar_name = nil;

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
	self:UpdateTitleBar();
	titleBtn:SetScript("OnClick", function()
		ED.Config:ShowConfigMenu(self, true);
	end);

	hooksecurefunc(self.ChatBox, "RefreshDisplay", function()
		self:OnChatboxRefresh();
	end);
end

function Eavesdropper_Dedicated_FrameMixin:OnShow()
	self:RefreshChat();
	if not self.chatTicker then
		self.chatTicker = C_Timer.NewTicker(Constants.CHAT_UPDATE_THROTTLE_DEFAULT, function()
			self:RefreshChat();
		end);
	end
end

function Eavesdropper_Dedicated_FrameMixin:OnHide()
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

	DedicatedFrame.frames[self.eavesdropped_player] = nil;

	-- Clean up the global reference so the name can be reused
	local frameName = self:GetName();
	if frameName and _G[frameName] == self then
		_G[frameName] = nil;
	end
end

-- ============================================================
-- Mouse / interaction
-- ============================================================

function Eavesdropper_Dedicated_FrameMixin:OnEnter()
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

---Position is intentionally not persisted; dedicated frames reset on reload
function Eavesdropper_Dedicated_FrameMixin:OnDragStop()
	self:StopMovingOrSizing();
end

---Size is intentionally not persisted; dedicated frames reset on reload
function Eavesdropper_Dedicated_FrameMixin:OnResizeFinished()
end

-- ============================================================
-- Layout / appearance
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
end

---Restore resize handle and close button from local frame state (not the database)
function Eavesdropper_Dedicated_FrameMixin:RestoreLayout()
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

function Eavesdropper_Dedicated_FrameMixin:HandleVisibility()
	-- Hide in combat if the setting is on
	if ED.Database:GetSetting("HideInCombat") and InCombatLockdown() then
		self:Hide();
		return;
	end

	-- Dedicated frames are always shown; intentionally skip HideWhenEmpty
	-- to avoid silently hiding a frame the user explicitly opened
	self:Show();
end

-- ============================================================
-- Chat
-- ============================================================

---Repopulate the chat box from stored history
function Eavesdropper_Dedicated_FrameMixin:RefreshChat()
	if not self.ChatBox then return; end

	self.refreshing = true;
	self.ChatBox:Clear();

	local maxMessages = ED.Database:GetSetting("MaxHistory");
	local player = self.eavesdropped_player;

	if player then
		self:PopulateHistoryMessages(player, maxMessages);
	end

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

	-- local hidden = not self:EavesdroppingOn(entry.g); -- UNUSED for now.

	if not self.ChatBox then return; end

	if not fromHistory and (ED.Database:GetSetting("HideWhenEmpty") or ED.Frame.settingsOpened) then
		self:Show();
	end

	local r, g, b = ED.ChatFormatter.GetEntryColor(entry);
	local formatted = ED.ChatFormatter:FormatMessage(entry);
	self.ChatBox:AddMessage(formatted, r, g, b);
end

---Override of the base TryAddMessage to handle the new-message indicator
---@param entry EavesdropperChatEntry
function Eavesdropper_Dedicated_FrameMixin:TryAddMessage(entry)
	if self.ChatBox:GetScrollOffset() == 0 then
		self.clickblock = GetTime();
	end

	self:AddMessage(entry);

	-- Show new-message indicator for incoming messages when the frame is not hovered
	if not entry.p
		and ED.Database:GetGlobalSetting("DedicatedWindowsNewIndicator")
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
function Eavesdropper_Dedicated_FrameMixin:ApplyWindowSettings()
	ED.ChatBox:ApplyFontOptions(self);
	ED.ChatFilters:UpdateFilters(self);
	self:RestoreLayout();
	self:ApplyThemeColors();
	self:RefreshChat();
end

-- ============================================================
-- DedicatedFrame manager
-- ============================================================

---Iterate all live dedicated frames
---@param func fun(frame: EavesdropperDedicatedFrame)
function DedicatedFrame:ForEachFrame(func)
	for _, frame in pairs(self.frames) do
		if frame then
			func(frame);
		end
	end
end

---Show an existing dedicated frame for sender, or create and initialise a new one
function DedicatedFrame:AddFrame(sender)
	local frame = _G["Eavesdropper_Dedicated_Frame_" .. sender];

	if frame then
		frame:Show();
		frame:Raise();
	else
		frame = CreateFrame("Frame", "Eavesdropper_Dedicated_Frame_" .. sender, UIParent, "Eavesdropper_Dedicated_FrameTemplate");
		frame:Raise();
		frame:HandleVisibility();
		frame:ApplyWindowSettings();
		ED.ChatFilters:Init(frame);
	end

	self.frames[sender] = frame;

	return frame;
end

ED.DedicatedFrame = DedicatedFrame;
