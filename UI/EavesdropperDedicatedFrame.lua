-- Copyright The Eavesdropper Authors
-- SPDX-License-Identifier: Apache-2.0

---@type EavesdropperConstants
local Constants = ED.Constants;

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

	self:InitInstanceFrameState();

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
	Eavesdropper_SharedFrameMixin.OnHideInstanceFrame(self);
end

---Remove self from the DedicatedFrame manager on hide
function Eavesdropper_Dedicated_FrameMixin:OnUnregisterFrame()
	DedicatedFrame.frames[self.eavesdropped_player] = nil;
end

-- ============================================================
-- Mouse / Interaction
-- ============================================================

---Position is intentionally not persisted; dedicated frames reset on reload
function Eavesdropper_Dedicated_FrameMixin:OnDragStop()
	self:StopMovingOrSizing();
end

---Size is intentionally not persisted; dedicated frames reset on reload
function Eavesdropper_Dedicated_FrameMixin:OnResizeFinished()
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
	Eavesdropper_SharedFrameMixin.TryAddMessage(self, entry);

	if not entry.p
		and ED.Database:GetGlobalSetting("DedicatedWindowsNewIndicator")
		and self.NewIndicator
		and not self.isMouseOver
	then
		self:FadeInNewIndicator();
		self:ScheduleNewIndicatorFadeOut();
	end
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
---@param sender string
---@return EavesdropperDedicatedFrame
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
