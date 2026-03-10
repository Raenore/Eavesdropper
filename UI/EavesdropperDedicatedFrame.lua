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

---@type C_TimerTicker?
Eavesdropper_Dedicated_FrameMixin.chatTicker = nil;

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

	-- Save these on the frame, not in DB.
	self.LockWindow = false;
	self.LockTitleBar = true;
	self:HandleHoverState(Enums.FRAME.MOUSE_HOVER_STATE.ON);
	self.HideCloseButton = false;
	self.LockScroll = false;
	self.EnableMouse = false;

	-- Start from main frame size, font face and other will remain from main
	self.FontSize = ED.Database:GetSetting("FontSize");

	if not self.LockWindow then
		self.ResizeHandle:Show();
	end

	if self.LockTitleBar then
		self.TitleBar:Show();
	end

	local closeBtn = self.TitleBar.CloseButton;
	closeBtn:SetNormalAtlas("uitools-icon-close");
	closeBtn:SetPushedAtlas("uitools-icon-close");
	closeBtn:SetHighlightAtlas("uitools-icon-close");
	closeBtn:SetScript("OnClick", function()
		self:Hide();
	end);

	if self.HideCloseButton then
		self.TitleBar.CloseButton:Hide();
	end

	local titleBtn = self.TitleBar.TitleButton;
	titleBtn.Text:SetText(player and ED.Utils.StripRealmSuffix(player));
	titleBtn:SetScript("OnClick", function()
		ED.Config:ShowConfigMenu(self, true);
	end);

	hooksecurefunc(self.ChatBox, "RefreshDisplay", function()
		self.OnChatboxRefresh(self)
	end)
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
	if self.chatTicker then
		self.chatTicker:Cancel();
		self.chatTicker = nil;
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

	local name = self:GetName();
	if name and _G[name] == self then
		_G[name] = nil;
	end
end

function Eavesdropper_Dedicated_FrameMixin:OnHyperlinkClick(link, text, button)
	if not self.EnableMouse then
		return;
	end

	-- Block rapid clicks if scroll just changed
	if GetTime() < (self.clickblock or 0) + Constants.FRAME.CLICKBLOCK_TIME then
		return;
	end

	local linkType, value = link:match("^(.-):(.*)$");

	-- open edurls in the chatbox.
	if linkType == "edurl" and value then
		-- Insert URL into chat edit box
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

	if self.NewIndicator then
		self.NewIndicator:Hide();
	end

	if self.newIndicatorTimer then
		self.newIndicatorTimer:Cancel();
		self.newIndicatorTimer = nil;
	end

	self:HandleHoverState(Enums.FRAME.MOUSE_HOVER_STATE.ON);
end

function Eavesdropper_Dedicated_FrameMixin:OnLeave()
	if not self:IsHoveringOverEavesdropperFrame() then
		self.isMouseOver = false;
		self:HandleHoverState(Enums.FRAME.MOUSE_HOVER_STATE.OFF);
	end
end

function Eavesdropper_Dedicated_FrameMixin:RestoreLayout()
	if not ED.Database then return; end

	if not self.LockWindow then
		self.ResizeHandle:Show();
	else
		self.ResizeHandle:Hide();
	end

	if self.HideCloseButton then
		self.TitleBar.CloseButton:Hide();
	else
		self.TitleBar.CloseButton:Show();
	end
end

function Eavesdropper_Dedicated_FrameMixin:ApplyThemeColors()
	-- Still pull this from the general DB settings
	if not ED.Database then return; end

	local background = self.Background;
	if background then
		local bg = ED.Database:GetSetting("ColorBackground");
		if type(bg) ~= "table" then
			bg = { r = 0, g = 0, b = 0, a = 0.5 };
		end
		background:SetColorTexture(bg.r, bg.g, bg.b, bg.a);
	end

	if self.TitleBar and self.TitleBar.Background then
		local tb = ED.Database:GetSetting("ColorTitleBar");
		if type(tb) ~= "table" then
			tb = { r = 0, g = 0, b = 0, a = 0.25 };
		end
		self.TitleBar.Background:SetColorTexture(tb.r, tb.g, tb.b, tb.a);
	end
end

function Eavesdropper_Dedicated_FrameMixin:OnDragStart()
	-- Bit of a hack to know if we're just on the title bar
	local isTitlebar = GetMouseFoci()[1] == self.TitleBar;
	if self.LockWindow or not isTitlebar then
		return;
	end

	self:StopMovingOrSizing();
	self:StartMoving();
end

function Eavesdropper_Dedicated_FrameMixin:OnDragStop()
	self:StopMovingOrSizing();
	-- We don't save it, as these dedicated frames will stop existing (for now) after a reload.
end

function Eavesdropper_Dedicated_FrameMixin:OnResizeFinished()
	-- We don't save it, as these dedicated frames will stop existing (for now) after a reload.
end

-- Unused for now (maybe in the future eh?)
function Eavesdropper_Dedicated_FrameMixin:OnSizeChanged()
end

function Eavesdropper_Dedicated_FrameMixin:OnMouseWheel(delta)
	if self.LockScroll then return; end

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
	local isLocked = self.EnableMouse;

	-- Always keep the parent frame mouse-enabled (sanity check)
	self:EnableMouse(true);

	if not isLocked then
		-- Ghost Mode: allow full world interaction through the frame
		self:SetPropagateMouseClicks(true);
		self:SetPropagateMouseMotion(true);

		if self.SetMouseMotionEnabled then
			self:SetMouseMotionEnabled(true);
			self:SetMouseClickEnabled(true);
		end
	else
		-- Normal Mode: block world interaction
		self:SetPropagateMouseClicks(false);
		self:SetPropagateMouseMotion(false);

		if self.SetMouseMotionEnabled then
			self:SetMouseMotionEnabled(true);
		end
	end
end

---Refresh the chat window for the currently eavesdropped player
function Eavesdropper_Dedicated_FrameMixin:RefreshChat()
	if not self.ChatBox then return; end

	self.refreshing = true;
	self.ChatBox:Clear();

	local maxMessages = ED.Database:GetSetting("MaxHistory");

	local player = self.eavesdropped_player;
	self.TitleBar.TitleButton.Text:SetText(player and ED.Utils.StripRealmSuffix(player));

	if player then
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

function Eavesdropper_Dedicated_FrameMixin:ShowTitleBar(show)
	if self.LockTitleBar then
		show = Enums.FRAME.MOUSE_HOVER_STATE.ON;
	end
	if show and not self.TitleBar:IsShown() then
		self.TitleBar:Show();
		self.ChatBox:SetPoint("TOP", self.TitleBar, "BOTTOM", 0, -1);
	elseif not show and self.TitleBar:IsShown() then
		self.TitleBar:Hide();
		self.ChatBox:SetPoint("TOP", self, 0, -2);
	end
end

function Eavesdropper_Dedicated_FrameMixin:ShowResizeHandle(show)
	if not self.LockWindow and show and not self.ResizeHandle:IsShown() then
		self.ResizeHandle:Show();
	elseif not show and self.ResizeHandle:IsShown() then
		self.ResizeHandle:Hide();
	end
end

function Eavesdropper_Dedicated_FrameMixin:HandleHoverState(show)
	self:ShowTitleBar(show);
end

---@param settingsClosed boolean
function Eavesdropper_Dedicated_FrameMixin:HandleVisibility()
	-- Hide in combat if the setting is on
	if ED.Database:GetSetting("HideInCombat") and InCombatLockdown() then
		self:Hide();
		return;
	end

	-- Determine if frame should be shown
	local shouldShow = true;

	-- For dedicated frames, we always shown them because they're dedicated.
	-- We, purposely, don't use "HideWhenEmpty" to avoid 'hidden' dedicated frames

	-- Show or hide frame, never hiding if settings are open
	if shouldShow then
		self:Show();
	else
		self:Hide();
	end
end

---Add a chat entry to the frame
---@param entry EavesdropperChatEntry
---@param fromHistory boolean
function Eavesdropper_Dedicated_FrameMixin:AddMessage(entry, fromHistory)
	if not entry then
		return;
	end

	if not ED.ChatFilters:HasEvent(entry.e, self) then
		return false;
	end

	if not self.refreshing then
		self.fade_time = GetTime();
	end

	-- local hidden = not self:EavesdroppingOn(entry.g); -- UNUSED for now.

	if not self.ChatBox then return; end
	if not fromHistory and (ED.Database:GetSetting("HideWhenEmpty") or ED.Frame.settingsOpened) then
		self:Show();
	end
	local r, g, b = ED.ChatFormatter:GetEntryColor(entry);
	local formatted, firstName = ED.ChatFormatter:FormatMessage(entry);
	self.ChatBox:AddMessage(formatted, r, g, b);
	self.TitleBar.TitleButton.Text:SetText(firstName);
end

---Safe wrapper to add a chat message
---@param entry EavesdropperChatEntry
function Eavesdropper_Dedicated_FrameMixin:TryAddMessage(entry)
	if self.ChatBox:GetScrollOffset() == 0 then
		self.clickblock = GetTime();
	end

	if ED.Database:GetGlobalSetting("DedicatedWindowsNewIndicator") and self.NewIndicator and not self.isMouseOver then
		self.NewIndicator:Show();

		-- Reset existing timer
		if self.newIndicatorTimer then
			self.newIndicatorTimer:Cancel();
			self.newIndicatorTimer = nil;
		end

		self.newIndicatorTimer = C_Timer.NewTimer(ED.Constants.CHAT_NEW_INDICATOR_FADE_OUT, function()
			if self.NewIndicator then
				self.NewIndicator:Hide();
			end
			self.newIndicatorTimer = nil;
		end);
	end

	self:AddMessage(entry);
end

function Eavesdropper_Dedicated_FrameMixin:ApplyWindowSettings()
	ED.ChatBox:ApplyFontOptions(self);
	ED.ChatFilters:UpdateFilters(self);
	self:RestoreLayout();
	self:ApplyThemeColors();
	self:RefreshChat();
end

---Iterate all dedicated frames
---@param func fun(frame: EavesdropperDedicatedFrame)
function DedicatedFrame:ForEachFrame(func)
	for _, frame in pairs(self.frames) do
		if frame then
			func(frame);
		end
	end
end

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
