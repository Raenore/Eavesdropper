-- Copyright The Eavesdropper Authors
-- SPDX-License-Identifier: Apache-2.0

---@type EavesdropperEnums
local Enums = ED.Enums;

---@type EavesdropperConstants
local Constants = ED.Constants;

local L = ED.Localization;

---Shared mixin inherited by Eavesdropper_FrameMixin, Eavesdropper_Dedicated_FrameMixin,
---and Eavesdropper_Group_FrameMixin.
---Four getters are required on the proper mixins (as one uses DB and other uses local frame state):
---IsMouseEnabled(), IsWindowLocked(), IsScrollLocked(), IsTitleBarLocked()
---@class Eavesdropper_SharedFrameMixin
Eavesdropper_SharedFrameMixin = {};

-- ============================================================
-- OnLoad
-- ============================================================

---Configure ChatBox properties
---@param frame table
function Eavesdropper_SharedFrameMixin.InitChatBox(frame)
	frame.ChatBox:SetJustifyH("LEFT");
	frame.ChatBox:SetIndentedWordWrap(true);
	frame.ChatBox:SetHyperlinksEnabled(true);
	frame.ChatBox:SetFading(false);
	frame.ChatBox:SetMaxLines(300);
	frame.ChatBox.ScrollMarker.Text:SetText(L.SCROLLMARKER_TEXT);
end

---Set the three atlas states on a close button
---@param closeBtn Button
function Eavesdropper_SharedFrameMixin.InitCloseButton(closeBtn)
	closeBtn:SetNormalAtlas("uitools-icon-close");
	closeBtn:SetPushedAtlas("uitools-icon-close");
	closeBtn:SetHighlightAtlas("uitools-icon-close");
end

---Initialise local frame state shared by Dedicated and Group instance frames.
---Call from OnLoad before any method that reads these fields.
function Eavesdropper_SharedFrameMixin:InitInstanceFrameState()
	self.lockWindow = false;
	self.lockTitleBar = true;
	self.hideCloseButton = false;
	self.lockScroll = false;
	self.mouseEnabled = false;
	self.clickblock = 0;
	self.isMouseOver = false;
end

-- ============================================================
-- OnHide (instance frames)
-- ============================================================

---OnHide for Dedicated and Group instance frames.
function Eavesdropper_SharedFrameMixin:OnHideInstanceFrame()
	if not UIParent:IsShown() or self.isCombatHidden then return; end

	if self.chatTicker then
		self.chatTicker:Cancel();
		self.chatTicker = nil;
	end

	self:ResetNewIndicator();

	if self.newIndicatorTimer then
		self.newIndicatorTimer:Cancel();
		self.newIndicatorTimer = nil;
	end

	self:UnregisterAllEvents();
	self:SetScript("OnEnter", nil);
	self:SetScript("OnLeave", nil);
	self:SetParent(nil);

	self:OnUnregisterFrame();

	local frameName = self:GetName();
	if frameName and _G[frameName] == self then
		_G[frameName] = nil;
	end
end

---Override in concrete mixins to remove self from the owning frame-manager table.
function Eavesdropper_SharedFrameMixin:OnUnregisterFrame()
end

-- ============================================================
-- Scroll Marker
-- ============================================================

---Show or hide the scroll marker and move the ChatBox accordingly (to prevent overlap)
function Eavesdropper_SharedFrameMixin:OnChatboxRefresh()
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

---Scroll to bottom and refresh (hide) the scroll marker on mouse-up
function Eavesdropper_SharedFrameMixin:OnScrollMarkerMouseUp()
	self.ChatBox:ScrollToBottom();
	self:OnChatboxRefresh();
end

-- ============================================================
-- Mouse / Interaction
-- ============================================================

---Returns true when the cursor is over any visible part of this frame
function Eavesdropper_SharedFrameMixin:IsHoveringOverEavesdropperFrame()
	-- Check the frame itself.
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

-- ============================================================
-- OnEnter / OnLeave
-- ============================================================

---Fade out the new-indicator (if active) then delegate hover state to ShowTitleBar.
---FadeOutNewIndicator is a no-op on frames without a NewIndicator widget (e.g. main frame).
function Eavesdropper_SharedFrameMixin:OnEnter()
	if self.isMouseOver then return; end
	self.isMouseOver = true;
	self:FadeOutNewIndicator();
	self:HandleHoverState(Enums.FRAME.MOUSE_HOVER_STATE.ON);
end

---Revert to the OFF hover state only after the cursor leaves all chrome regions
function Eavesdropper_SharedFrameMixin:OnLeave()
	if not self:IsHoveringOverEavesdropperFrame() then
		self.isMouseOver = false;
		self:HandleHoverState(Enums.FRAME.MOUSE_HOVER_STATE.OFF);
	end
end

---Delegate hover-state changes to ShowTitleBar
---@param hoverState EavesdropperMouseHoverState
function Eavesdropper_SharedFrameMixin:HandleHoverState(hoverState)
	self:ShowTitleBar(hoverState);
end

-- ============================================================
-- Mouse wheel
-- ============================================================

---Handle scroll wheel input when IsScrollLocked() is false
function Eavesdropper_SharedFrameMixin:OnMouseWheel(delta)
	if self:IsScrollLocked() then return; end

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

-- ============================================================
-- Hyperlink click
-- ============================================================

---Handle hyperlink clicks when IsMouseEnabled() is true
function Eavesdropper_SharedFrameMixin:OnHyperlinkClick(link, text, button)
	if not self:IsMouseEnabled() then return; end

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

-- ============================================================
-- Mouse lock / propagation
-- ============================================================

---Mouse-click propagation depends on IsMouseEnabled(), passthrough on false.
function Eavesdropper_SharedFrameMixin:UpdateMouseLock()
	local isEnabled = self:IsMouseEnabled();

	-- Always keep the frame itself mouse-enabled so OnEnter/OnLeave still fire
	self:EnableMouse(true);

	if not isEnabled then
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
-- Drag
-- ============================================================

---Begin moving the frame; only fires from the title bar when not locked
function Eavesdropper_SharedFrameMixin:OnDragStart()
	if self:IsWindowLocked() then return; end;

	self:StopMovingOrSizing();
	self:StartMoving();
end

-- ============================================================
-- Layout / Appearance
-- ============================================================

---Toggle the title bar; always shown when IsTitleBarLocked() is true
---@param hoverState EavesdropperMouseHoverState
function Eavesdropper_SharedFrameMixin:ShowTitleBar(hoverState)
	if self:IsTitleBarLocked() then
		hoverState = Enums.FRAME.MOUSE_HOVER_STATE.ON;
	end

	if hoverState then
		self.TitleBar:Show();
		self.ChatBox:SetPoint("TOP", self.TitleBar, "BOTTOM", 0, -1);
	else
		self.TitleBar:Hide();
		self.ChatBox:SetPoint("TOP", self, 0, -2);
	end
end

---Show or hide the resize handle; respects IsWindowLocked()
---@param show boolean
function Eavesdropper_SharedFrameMixin:ShowResizeHandle(show)
	if not self:IsWindowLocked() and show and not self.ResizeHandle:IsShown() then
		self.ResizeHandle:Show();
	elseif not show and self.ResizeHandle:IsShown() then
		self.ResizeHandle:Hide();
	end
end

---Restore resize handle and close-button visibility from local frame state.
---Overridden by Eavesdropper_FrameMixin to also restore position and size from the DB.
function Eavesdropper_SharedFrameMixin:RestoreLayout()
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

---Hide in combat when the setting is on; otherwise show the frame.
---Overridden by Eavesdropper_FrameMixin for HideWhenEmpty and WindowVisible logic.
function Eavesdropper_SharedFrameMixin:HandleVisibility()
	if ED.Database:GetSetting("HideInCombat") and InCombatLockdown() then
		self:Hide();
		return;
	end

	self:Show();
end

---Apply font, filters, layout, colors, and history to this frame.
---Instance frames call this directly; the main frame's ApplyProfileSettings
---calls this then additionally refreshes the settings panel.
function Eavesdropper_SharedFrameMixin:ApplyWindowSettings()
	ED.ChatBox:ApplyFontOptions(self);
	ED.ChatFilters:UpdateFilters(self);
	self:RestoreLayout();
	self:ApplyThemeColors();
	self:RefreshChat();
end

---Apply background and title bar colors from the database
function Eavesdropper_SharedFrameMixin:ApplyThemeColors()
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

---Unused; reserved for future use
function Eavesdropper_SharedFrameMixin:OnSizeChanged()
end

-- ============================================================
-- New-Indicator helpers
-- ============================================================

---Hard reset: stop all animations and clear both state flags.
---Safe to call when self.NewIndicator is nil.
function Eavesdropper_SharedFrameMixin:ResetNewIndicator()
	if not self.NewIndicator then return; end
	if self.NewIndicator.NewIndicatorFadeIn then self.NewIndicator.NewIndicatorFadeIn:Stop(); end
	if self.NewIndicator.NewIndicatorFadeOut then self.NewIndicator.NewIndicatorFadeOut:Stop(); end
	self.NewIndicator.isFadedIn = false;
	self.NewIndicator.isFadedOut = false;
end

---Play the fade-in animation if the indicator is not already visible.
---Safe to call when self.NewIndicator is nil.
function Eavesdropper_SharedFrameMixin:FadeInNewIndicator()
	if not self.NewIndicator then return; end
	if self.NewIndicator.isFadedIn then return; end
	self.NewIndicator:Show();
	self.NewIndicator.NewIndicatorFadeIn:Stop();
	self.NewIndicator.NewIndicatorFadeOut:Stop();
	self.NewIndicator.NewIndicatorFadeIn:Play();
	self.NewIndicator.isFadedIn = true;
	self.NewIndicator.isFadedOut = false;
end

---Play the fade-out animation if the indicator is currently visible.
---Safe to call when self.NewIndicator is nil.
function Eavesdropper_SharedFrameMixin:FadeOutNewIndicator()
	if not self.NewIndicator then return; end
	if not self.NewIndicator.isFadedIn or self.NewIndicator.isFadedOut then return; end
	self.NewIndicator.NewIndicatorFadeIn:Stop();
	self.NewIndicator.NewIndicatorFadeOut:Stop();
	self.NewIndicator.NewIndicatorFadeOut:Play();
	self.NewIndicator.isFadedOut = true;
	self.NewIndicator.isFadedIn = false;
end

---(Re-)schedule the auto fade-out timer; cancels any running timer first.
function Eavesdropper_SharedFrameMixin:ScheduleNewIndicatorFadeOut()
	if self.newIndicatorTimer then
		self.newIndicatorTimer:Cancel();
		self.newIndicatorTimer = nil;
	end

	self.newIndicatorTimer = C_Timer.NewTimer(Constants.CHAT_NEW_INDICATOR_FADE_OUT, function()
		self:FadeOutNewIndicator();
		self.newIndicatorTimer = nil;
	end);
end

-- ============================================================
-- Chat helpers
-- ============================================================

---Populate the ChatBox from history for player; tries the full name-realm first and then bare name.
---@param player string
---@param maxMessages number
function Eavesdropper_SharedFrameMixin:PopulateHistoryMessages(player, maxMessages)
	local chatFull = ED.ChatHistory:GetPlayerHistory(player, maxMessages);
	if chatFull and #chatFull > 0 then
		for _, entry in ipairs(chatFull) do
			self:AddMessage(entry, true);
		end
		return;
	end

	local chatBare = ED.ChatHistory:GetPlayerHistory(ED.Utils.StripRealmSuffix(player), maxMessages);
	if chatBare and #chatBare > 0 then
		for _, entry in ipairs(chatBare) do
			self:AddMessage(entry, true);
		end
	end
end

---Record the clickblock timestamp then delegate to AddMessage.
---Dedicated and Group frames override this to also handle the new-message indicator.
---@param entry EavesdropperChatEntry
function Eavesdropper_SharedFrameMixin:TryAddMessage(entry)
	if self.ChatBox:GetScrollOffset() == 0 then
		self.clickblock = GetTime();
	end

	self:AddMessage(entry);
end
