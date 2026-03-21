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

local L = ED.Localization;

Eavesdropper_Dedicated_FrameMixin = {};

-- ============================================================
-- OnLoad / OnShow / OnHide
-- ============================================================

function Eavesdropper_Dedicated_FrameMixin:OnLoad()
	-- Extract player from frame name
	local name = self:GetName();
	local player = name:match("^Eavesdropper_Dedicated_Frame_(.+)$");
	self.eavesdropped_player = player;

	self:EnableMouseWheel(true);
	self:UpdateMouseLock();
	self.clickblock = 0;
	self.isMouseOver = false;

	self.ChatBox:SetJustifyH("LEFT");
	self.ChatBox:SetIndentedWordWrap(true);
	self.ChatBox:SetHyperlinksEnabled(true);
	self.ChatBox:SetFading(false);
	self.ChatBox:SetMaxLines(300);
	self.ChatBox.ScrollMarker.Text:SetText(L.SCROLLMARKER_TEXT);

	-- Frame-local state (not persisted to DB)
	self.lockWindow = false;
	self.lockTitleBar = true;
	self:HandleHoverState(Enums.FRAME.MOUSE_HOVER_STATE.ON);
	self.hideCloseButton = false;
	self.lockScroll = false;
	self.mouseEnabled = false;

	-- Inherit font size from main frame settings
	self.FontSize = ED.Database:GetSetting("FontSize");

	if not self.lockWindow then
		self.ResizeHandle:Show();
	end

	self:ShowTitleBar();

	-- Configure close button
	local closeBtn = self.TitleBar.CloseButton;
	closeBtn:SetNormalAtlas("uitools-icon-close");
	closeBtn:SetPushedAtlas("uitools-icon-close");
	closeBtn:SetHighlightAtlas("uitools-icon-close");
	closeBtn:SetScript("OnClick", function()
		self:Hide();
	end);

	if self.hideCloseButton then
		self.TitleBar.CloseButton:Hide();
	end

	-- Configure title button
	local titleBtn = self.TitleBar.TitleButton;
	local newPlayer, newGuid = ED.PlayerCache:InsertAndRetrieve(player);
	if newPlayer and newGuid then
		local _, firstName = ED.MSP.TryGetMSPData(newPlayer, newGuid);
		self.titlebar_name = firstName;
	else
		self.titlebar_name = player and ED.Utils.StripRealmSuffix(player);
	end
	titleBtn.Text:SetText(self.titlebar_name);
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
		self.chatTicker = C_Timer.NewTicker(ED.Constants.CHAT_UPDATE_THROTTLE_DEFAULT, function()
			self:RefreshChat();
		end);
	end
end

function Eavesdropper_Dedicated_FrameMixin:OnHide()
	-- When UI parent is hidden (ALT-Z etc), don't run destructive code.
	if not UIParent:IsShown() then return; end

	if self.chatTicker then
		self.chatTicker:Cancel();
		self.chatTicker = nil;
	end

	-- Stop any new-indicator animations
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

	-- Clean up global reference
	local name = self:GetName();
	if name and _G[name] == self then
		_G[name] = nil;
	end
end

-- ============================================================
-- Mouse / Interaction
-- ============================================================

function Eavesdropper_Dedicated_FrameMixin:OnHyperlinkClick(link, text, button)
	if not self.mouseEnabled then return; end

	-- Suppress rapid clicks when scroll position just changed
	if GetTime() < (self.clickblock or 0) + Constants.FRAME.CLICKBLOCK_TIME then return; end

	local linkType, value = link:match("^(.-):(.*)$");

	-- Open edurls directly in the chat edit box
	if linkType == "edurl" and value then
		local editBox = ChatFrameUtil.ChooseBoxForSend();
		if not editBox:IsShown() then
			ChatFrameUtil.ActivateChat(editBox);
		end
		editBox:Insert(value);
		return;
	end

	SetItemRef(link, text, button, DEFAULT_CHAT_FRAME);

	self.fade_time = GetTime();
end

function Eavesdropper_Dedicated_FrameMixin:OnScrollMarkerMouseUp()
	self.ChatBox:ScrollToBottom();
	self:OnChatboxRefresh();
end

function Eavesdropper_Dedicated_FrameMixin:OnChatboxRefresh()
	if self.ChatBox:GetScrollOffset() ~= 0 then
		if not self.ChatBox.ScrollMarker:IsShown() then
			self.ChatBox.ScrollMarker:Show();
			self.ChatBox:SetPoint("BOTTOM", self.ChatBox.ScrollMarker, "TOP", 0, 1);
		end
	else
		if self.ChatBox.ScrollMarker:IsShown() then
			self.ChatBox.ScrollMarker:Hide();
			self.ChatBox:SetPoint("BOTTOM", self, 0, 2);
		end
	end
end

---Returns true if the cursor is over any part of this frame or its chrome
function Eavesdropper_Dedicated_FrameMixin:IsHoveringOverEavesdropperFrame()
	-- Check Eavesdropper frame itself.
	if self and self:IsMouseOver() then
		return true;
	end
	-- Check TitleBar and children.
	if self.TitleBar and (self.TitleBar:IsMouseOver() or self.TitleBar.CloseButton:IsMouseOver() or self.TitleBar.TitleButton:IsMouseOver()) then
		return true;
	end
	-- Check ResizeHandle.
	if self.ResizeHandle and self.ResizeHandle:IsMouseOver() then
		return true;
	end
	return false;
end

function Eavesdropper_Dedicated_FrameMixin:OnEnter()
	if self.isMouseOver then return; end
	self.isMouseOver = true;

	-- Fade out the new-message indicator when the user hovers
	if self.NewIndicator and self.NewIndicator.isFadedIn and not self.NewIndicator.isFadedOut then
		self.NewIndicator.NewIndicatorFadeIn:Stop();
		self.NewIndicator.NewIndicatorFadeOut:Stop();
		self.NewIndicator.NewIndicatorFadeOut:Play();
		self.NewIndicator.isFadedOut = true;
		self.NewIndicator.isFadedIn = false;
	end

	self:HandleHoverState(Enums.FRAME.MOUSE_HOVER_STATE.ON);
end

function Eavesdropper_Dedicated_FrameMixin:OnLeave()
	if not self:IsHoveringOverEavesdropperFrame() then
		self.isMouseOver = false;
		self:HandleHoverState(Enums.FRAME.MOUSE_HOVER_STATE.OFF);
	end
end

function Eavesdropper_Dedicated_FrameMixin:OnDragStart()
	-- Only drag when the cursor is on the title bar
	local isTitlebar = GetMouseFoci()[1] == self.TitleBar;
	if self.lockWindow or not isTitlebar then return; end

	self:StopMovingOrSizing();
	self:StartMoving();
end

function Eavesdropper_Dedicated_FrameMixin:OnDragStop()
	self:StopMovingOrSizing();
	-- Position is intentionally not persisted; dedicated frames reset on reload
end

function Eavesdropper_Dedicated_FrameMixin:OnResizeFinished()
	-- Size is intentionally not persisted; dedicated frames reset on reload
end

-- Unused — reserved for future use
function Eavesdropper_Dedicated_FrameMixin:OnSizeChanged()
end

function Eavesdropper_Dedicated_FrameMixin:OnMouseWheel(delta)
	if self.lockScroll then return; end

	if delta > 0 then
		if IsAltKeyDown() then
			self.ChatBox:ScrollToTop();
		elseif IsControlKeyDown() then
			ED.ChatBox:AdjustFontSize(self, Enums.FRAME.SCROLL_DIRECTION.UP);
		else
			self.ChatBox:ScrollUp();
		end
	else
		if IsAltKeyDown() then
			self.ChatBox:ScrollToBottom();
		elseif IsControlKeyDown() then
			ED.ChatBox:AdjustFontSize(self, Enums.FRAME.SCROLL_DIRECTION.DOWN);
		else
			self.ChatBox:ScrollDown();
		end
	end

	self.fade_time = GetTime();
end

-- This is a bit more involved as we don't use OnUpdate to check OnEnter/OnLeave checks for the frame
function Eavesdropper_Dedicated_FrameMixin:UpdateMouseLock()
	local isLocked = self.mouseEnabled;

	-- Always keep the parent frame mouse-enabled
	self:EnableMouse(true);

	if not isLocked then
		-- Ghost mode: pass all clicks and motion through to the world
		self:SetPropagateMouseClicks(true);
		self:SetPropagateMouseMotion(true);

		if self.SetMouseMotionEnabled then
			self:SetMouseMotionEnabled(true);
			self:SetMouseClickEnabled(true);
		end
	else
		-- Normal mode: consume clicks, block world interaction
		self:SetPropagateMouseClicks(false);
		self:SetPropagateMouseMotion(false);

		if self.SetMouseMotionEnabled then
			self:SetMouseMotionEnabled(true);
		end
	end
end

-- ============================================================
-- Layout / Appearance
-- ============================================================

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

function Eavesdropper_Dedicated_FrameMixin:ApplyThemeColors()
	if not ED.Database then return; end

	-- Background color
	local background = self.Background;
	if background then
		local bg = ED.Database:GetSetting("ColorBackground");
		if type(bg) ~= "table" then
			bg = { r = 0, g = 0, b = 0, a = 0.5 };
		end
		background:SetColorTexture(bg.r, bg.g, bg.b, bg.a);
	end

	-- Title bar color
	if self.TitleBar and self.TitleBar.Background then
		local tb = ED.Database:GetSetting("ColorTitleBar");
		if type(tb) ~= "table" then
			tb = { r = 0, g = 0, b = 0, a = 0.25 };
		end
		self.TitleBar.Background:SetColorTexture(tb.r, tb.g, tb.b, tb.a);
	end
end

function Eavesdropper_Dedicated_FrameMixin:ShowTitleBar(show)
	if self.lockTitleBar then
		show = Enums.FRAME.MOUSE_HOVER_STATE.ON;
	end

	if show then
		self.TitleBar:Show();
		self.ChatBox:SetPoint("TOP", self.TitleBar, "BOTTOM", 0, -1);
	else
		self.TitleBar:Hide();
		self.ChatBox:SetPoint("TOP", self, 0, -2);
	end
end

function Eavesdropper_Dedicated_FrameMixin:ShowResizeHandle(show)
	if not self.lockWindow and show and not self.ResizeHandle:IsShown() then
		self.ResizeHandle:Show();
	elseif not show and self.ResizeHandle:IsShown() then
		self.ResizeHandle:Hide();
	end
end

function Eavesdropper_Dedicated_FrameMixin:HandleHoverState(show)
	self:ShowTitleBar(show);
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

	-- Dedicated frames are always shown; we intentionally skip HideWhenEmpty
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

	self.TitleBar.TitleButton.Text:SetText(self.titlebar_name);

	if player then
		-- Try full name (with realm) first, fall back to bare name
		local chatFull = ED.ChatHistory:GetPlayerHistory(player, maxMessages);
		if chatFull and #chatFull > 0 then
			for _, entry in ipairs(chatFull) do
				self:AddMessage(entry, true);
			end
		else
			local chatBare = ED.ChatHistory:GetPlayerHistory(ED.Utils.StripRealmSuffix(player), maxMessages);
			if chatBare and #chatBare > 0 then
				for _, entry in ipairs(chatBare) do
					self:AddMessage(entry, true);
				end
			end
		end
	end

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
	local formatted, firstName = ED.ChatFormatter:FormatMessage(entry);
	self.ChatBox:AddMessage(formatted, r, g, b);
	self.titlebar_name = firstName;
	self.TitleBar.TitleButton.Text:SetText(firstName);
end

---Safe wrapper to add a chat message; also handles the new-message indicator
---@param entry EavesdropperChatEntry
function Eavesdropper_Dedicated_FrameMixin:TryAddMessage(entry)
	if self.ChatBox:GetScrollOffset() == 0 then
		self.clickblock = GetTime();
	end

	self:AddMessage(entry);

	-- Show new-message indicator for incoming messages when not hovered
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

		self.newIndicatorTimer = C_Timer.NewTimer(ED.Constants.CHAT_NEW_INDICATOR_FADE_OUT, function()
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

---Iterate all dedicated frames
---@param func fun(frame: EavesdropperDedicatedFrame)
function DedicatedFrame:ForEachFrame(func)
	for _, frame in pairs(self.frames) do
		if frame then
			func(frame);
		end
	end
end

---Show an existing dedicated frame for sender, or create and initialise one
function DedicatedFrame:AddFrame(sender)
	local frame = _G["Eavesdropper_Dedicated_Frame_" .. sender];

	if frame then
		frame:Show();
	else
		frame = CreateFrame("Frame", "Eavesdropper_Dedicated_Frame_" .. sender, UIParent, "Eavesdropper_Dedicated_FrameTemplate");
		frame:HandleVisibility();
		frame:ApplyWindowSettings();
		ED.ChatFilters:Init(frame);
	end

	self.frames[sender] = frame;

	return frame;
end

ED.DedicatedFrame = DedicatedFrame;
