-- Copyright The Eavesdropper Authors
-- SPDX-License-Identifier: GPL-3.0-or-later

---@type EavesdropperEnums
local Enums = ED.Enums;

---@type EavesdropperConstants
local Constants = ED.Constants;

local L = ED.Localization;

---Shared mixin inherited by Eavesdropper_FrameMixin, Eavesdropper_Dedicated_FrameMixin,
---and Eavesdropper_Group_FrameMixin.
---Five getters are required on the proper mixins (as one uses DB and other uses local frame state):
---IsMouseEnabled(), IsWindowLocked(), IsScrollLocked(), IsTitleBarLocked(), GetNewIndicatorSettingKey()
---@class Eavesdropper_SharedFrameMixin : Frame
Eavesdropper_SharedFrameMixin = {};

-- ============================================================
-- OnLoad
-- ============================================================

---Configure ChatBox properties
---@param frame table
---@param maxLines number Lines beyond this are silently dropped, oldest first.
function Eavesdropper_SharedFrameMixin.InitChatBox(frame, maxLines)
	frame.ChatBox:SetJustifyH("LEFT");
	frame.ChatBox:SetIndentedWordWrap(true);
	frame.ChatBox:SetHyperlinksEnabled(true);
	frame.ChatBox:SetFading(false);
	frame.ChatBox:SetMaxLines(maxLines);
	frame.ChatBox.ScrollMarker.Text:SetText(L.SCROLLMARKER_TEXT);
end

---Create the close button's SVG icon
---@param closeBtn Button
function Eavesdropper_SharedFrameMixin.InitCloseButton(closeBtn)
	if not closeBtn.svg then
		local svg = closeBtn:CreateVectorGraphics(nil, "OVERLAY");
		closeBtn.svg = svg;
		svg:SetSVG("Interface/AddOns/Eavesdropper/Resources/CloseButton.svg");
		svg:SetPoint("CENTER", closeBtn, "CENTER", 0, 0);
		svg:SetSize(12, 12);

		local function UpdateVisual()
			if closeBtn:IsMouseMotionFocus() then
				svg:SetVertexColor(1, 1, 1);
			else
				svg:SetVertexColor(0.6, 0.6, 0.6);
			end
		end

		closeBtn:HookScript("OnEnter", UpdateVisual);
		closeBtn:HookScript("OnLeave", UpdateVisual);
		UpdateVisual();
	end
end

---Close button's icon and click handler.
---@param onClose fun()? Extra behaviour to run after Hide(); the main frame uses this to also persist WindowVisible.
function Eavesdropper_SharedFrameMixin:InitCloseButtonClick(onClose)
	local closeBtn = self.TitleBar.CloseButton;
	Eavesdropper_SharedFrameMixin.InitCloseButton(closeBtn);
	closeBtn:SetScript("OnClick", function()
		self:Hide();
		if onClose then onClose(); end
	end);
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
-- OnHide
-- ============================================================

---OnHide shared by every frame type.
function Eavesdropper_SharedFrameMixin:OnHideCommon()
	self:ResetNewIndicator();

	if self.newIndicatorTimer then
		self.newIndicatorTimer:Cancel();
		self.newIndicatorTimer = nil;
	end

	if self.alphaChannelMode and self.SetAlphaChannelMode then
		self:SetAlphaChannelMode(nil);
	end
end

---OnHide for Dedicated and Group instance frames.
function Eavesdropper_SharedFrameMixin:OnHideInstanceFrame()
	if not UIParent:IsShown() or self.isCombatHidden then return; end

	self:StopChatTicker();
	self:OnHideCommon();

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
-- Chat refresh ticker
-- ============================================================

---Returns true when no line in this window can still change with age.
---An empty window counts as frozen.
---@return boolean
function Eavesdropper_SharedFrameMixin:IsTimestampFrozen()
	if not self.newestEntryTime then return true; end
	return (time() - self.newestEntryTime) >= Constants.TIMESTAMP_FREEZE_AGE;
end

---Start the periodic refresh that ages the timestamps on this window.
---The first tick is offset randomly, so windows shown together do not refresh in the same frame.
---Stops itself once every line is frozen; TryAddMessage starts it again.
function Eavesdropper_SharedFrameMixin:StartChatTicker()
	self.usesChatTicker = true;

	if self.chatTicker or self.chatTickerDelay then return; end

	local interval = Constants.WINDOW_REFRESH_INTERVAL;

	self.chatTickerDelay = C_Timer.NewTimer(math.random() * interval, function()
		self.chatTickerDelay = nil;
		self.chatTicker = C_Timer.NewTicker(interval, function()
			-- Refresh before testing; the tick that freezes a window still has a label to draw.
			self:RefreshChat(true);

			if self:IsTimestampFrozen() then
				self:StopChatTicker();
			end
		end);
	end);
end

---Cancel the periodic refresh and any pending staggered start.
---The stagger uses NewTimer rather than After so it can be cancelled here.
function Eavesdropper_SharedFrameMixin:StopChatTicker()
	if self.chatTickerDelay then
		self.chatTickerDelay:Cancel();
		self.chatTickerDelay = nil;
	end

	if self.chatTicker then
		self.chatTicker:Cancel();
		self.chatTicker = nil;
	end
end

-- ============================================================
-- Frame registry
-- ============================================================

---@alias EavesdropperFrameFamily
---| "main"
---| "mentions"
---| "dedicated"
---| "group"

---Centralises the frame-type enumeration; a new frame family only needs to be registered here.
---@param func fun(frame: Eavesdropper_SharedFrameMixin, family: EavesdropperFrameFamily)
function Eavesdropper_SharedFrameMixin.ForEachManagedFrame(func)
	if ED.Frame then
		func(ED.Frame, "main");
	end

	if ED.MentionsFrame then
		func(ED.MentionsFrame, "mentions");
	end

	ED.DedicatedFrame:ForEachFrame(function(frame)
		func(frame, "dedicated");
	end);

	ED.GroupFrame:ForEachFrame(function(frame)
		func(frame, "group");
	end);
end

-- ============================================================
-- Data-driven refresh (MSP invalidation)
-- ============================================================

---True while the burst window's cooldown is running.
local dataRefreshOnCooldown = false;

---True if an invalidation arrived during the cooldown and still needs a redraw.
local dataRefreshPending = false;

---Dedicated and Group windows only exist in the registry while shown, so they always redraw;
---Main and Mentions are checked for IsShown() first.
function Eavesdropper_SharedFrameMixin.RefreshAllWindows()
	Eavesdropper_SharedFrameMixin.ForEachManagedFrame(function(frame, family)
		if family == "main" or family == "mentions" then
			if frame:IsShown() then
				frame:RefreshChat(true);
			end
			return;
		end

		if family == "group" then
			frame.playerListDirty = true;
		end

		frame:RefreshChat(true);
	end);
end

---Main is skipped: its OnHide never reads isCombatHidden, unlike Dedicated/Group/Mentions.
---@param combatHidden boolean
function Eavesdropper_SharedFrameMixin.ApplyCombatHidden(combatHidden)
	Eavesdropper_SharedFrameMixin.ForEachManagedFrame(function(frame, family)
		if family ~= "main" then
			frame.isCombatHidden = combatHidden;
		end
		frame:HandleVisibility();
	end);
end

---Rearms itself if something is pending when the cooldown expires, rather than always going
---idle. Keeps a sustained burst on a steady interval instead of having it basically spam.
local function ArmDataRefreshCooldown()
	C_Timer.NewTimer(Constants.DATA_REFRESH_THROTTLE, function()
		if not dataRefreshPending then
			dataRefreshOnCooldown = false;
			ED.Debug:Print("ScheduleDataRefresh: cooldown expired, idle");
			return;
		end

		dataRefreshPending = false;
		ED.Debug:Print("ScheduleDataRefresh: cooldown expired, trailing redraw");
		Eavesdropper_SharedFrameMixin.RefreshAllWindows();
		ArmDataRefreshCooldown();
	end);
end

---Entry point for MSP invalidation to request a redraw. Invalidation sources must always
---come through here, never call RefreshChat directly.
function Eavesdropper_SharedFrameMixin.ScheduleDataRefresh()
	if dataRefreshOnCooldown then
		dataRefreshPending = true;
		ED.Debug:Print("ScheduleDataRefresh: on cooldown, queued");
		return;
	end

	ED.Debug:Print("ScheduleDataRefresh: leading edge, redrawing now");
	Eavesdropper_SharedFrameMixin.RefreshAllWindows();

	dataRefreshOnCooldown = true;
	ArmDataRefreshCooldown();
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

---Hook the ChatBox's RefreshDisplay so the scroll marker stays in sync with scroll position.
function Eavesdropper_SharedFrameMixin:HookChatboxRefresh()
	hooksecurefunc(self.ChatBox, "RefreshDisplay", function()
		self:OnChatboxRefresh();
	end);
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
---FadeOutNewIndicator is a no-op on frames without a NewIndicator widget.
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

---Handle hyperlink clicks when IsMouseEnabled() is true;
---With some exceptions for edjump and player-name right click.
function Eavesdropper_SharedFrameMixin:OnHyperlinkClick(link, text, button)
	local linkType, value = link:match("^(.-):(.*)$");

	if not self:IsMouseEnabled() then
		-- edjump bypasses mouse not enabled when IsJumpToContextMouseExempt() is true.
		local edjumpExempt = linkType == "edjump" and self:IsJumpToContextMouseExempt();
		-- player-name right-click bypasses mouse not enabled when IsPlayerLinkMouseExempt() is true.
		local playerExempt = linkType == "player" and button == "RightButton" and self:IsPlayerLinkMouseExempt();
		if not edjumpExempt and not playerExempt then return; end
	end

	-- Suppress rapid clicks when scroll position just changed.
	if GetTime() < (self.clickblock or 0) + Constants.FRAME.CLICKBLOCK_TIME then return; end

	-- Open edurls directly in the chat edit box.
	if linkType == "edurl" and value then
		local editBox = ChatFrameUtil.ChooseBoxForSend();
		if not editBox:IsShown() then
			ChatFrameUtil.ActivateChat(editBox);
		end
		editBox:Insert(value);
		return;
	end

	-- Jump to Context: open (or focus) sender's dedicated window, scrolled to entryId.
	if linkType == "edjump" and value then
		local entryId, sender = value:match("^(%d+):(.+)$");
		if entryId and sender and ED.Database:GetGlobalSetting("DedicatedWindows") then
			ED.DedicatedFrame:JumpToEntry(sender, tonumber(entryId));
		end
		return;
	end

	-- UnitPopups:OnMenuOpen fires synchronously inside SetItemRef when the link opens
	-- a menu; this flag tells it the menu was reached through an addon-owned frame so
	-- the native Copy Character Name button's CopyToClipboard call would be tainted.
	if ED.UnitPopups then
		ED.UnitPopups:SetHyperlinkOrigin(true);
	end

	SetItemRef(link, text, button, DEFAULT_CHAT_FRAME);

	if ED.UnitPopups then
		ED.UnitPopups:SetHyperlinkOrigin(false);
	end

	self.fade_time = GetTime();
end

---Single reusable underline texture, reparented/repositioned per hover.
local NameHoverHighlight;

---@param region table
---@param left number
---@param bottom number
---@param width number
---@param height number
local function NameHoverHighlight_Show(region, left, bottom, width, height)
	if not NameHoverHighlight then
		NameHoverHighlight = region:GetParent():CreateTexture(nil, "BACKGROUND", nil, 1);
		NameHoverHighlight:SetColorTexture(0.8, 0.8, 0.8, 0.6); -- Matches Jump.png
	end

	local thickness = PixelUtil.ConvertPixelsToUIForRegion(1, region);

	NameHoverHighlight:SetParent(region:GetParent());
	NameHoverHighlight:ClearAllPoints();
	NameHoverHighlight:SetPoint("TOPLEFT", region, "TOPLEFT", left, bottom - height + thickness);
	NameHoverHighlight:SetPoint("BOTTOMRIGHT", region, "TOPLEFT", left + width, bottom - height);
	NameHoverHighlight:Show();
end

local function NameHoverHighlight_Hide()
	if NameHoverHighlight then
		NameHoverHighlight:Hide();
		NameHoverHighlight:ClearAllPoints();
	end
end

---Shows a tooltip on hover for Jump to Context links & underline under
---clickable sender names (supports Group and Mentions windows).
---@param link string
---@param text string
---@param region table
---@param left number
---@param bottom number
---@param width number?
---@param height number?
function Eavesdropper_SharedFrameMixin:OnHyperlinkEnter(link, text, region, left, bottom, width, height) -- luacheck: no unused (text)
	local linkType, value = link:match("^(.-):(.*)$");

	if not self:IsMouseEnabled() then
		local edjumpExempt = linkType == "edjump" and self:IsJumpToContextMouseExempt();
		local playerExempt = linkType == "player" and self:IsPlayerLinkMouseExempt();
		if not edjumpExempt and not playerExempt then return; end
	end

	if not value then return; end

	if linkType == "edjump" then
		local _, sender = value:match("^(%d+):(.+)$");
		if not sender then return; end

		GameTooltip:SetOwner(self, "ANCHOR_NONE");
		GameTooltip:ClearAllPoints();
		GameTooltip:SetPoint("BOTTOMLEFT", region, "TOPLEFT", left, bottom);
		GameTooltip_SetTitle(GameTooltip, L.JUMP_TO_CONTEXT);
		GameTooltip_AddNormalLine(GameTooltip, L.JUMP_TO_CONTEXT_TOOLTIP:format(ED.Utils.StripRealmSuffix(sender)));
		GameTooltip:Show();
		return;
	end

	if linkType == "player" then
		if not width or not height then return; end
		NameHoverHighlight_Show(region, left, bottom, width, height);
		return;
	end

	-- Otherwise try showing a tooltip on the top right
	GameTooltip:SetOwner(self, "ANCHOR_PRESERVE");
	GameTooltip:ClearAllPoints();
	GameTooltip:SetPoint("BOTTOMLEFT", region, "TOPLEFT", left + width, bottom);
	GameTooltip:SetHyperlink(link);
end

function Eavesdropper_SharedFrameMixin:OnHyperlinkLeave()
	GameTooltip:Hide();
	NameHoverHighlight_Hide();
end

-- ============================================================
-- Mouse lock / propagation
-- ============================================================

---Override in Group/Mentions to let the Jump to Context link stay clickable in ghost mode.
---@return boolean
function Eavesdropper_SharedFrameMixin:IsJumpToContextMouseExempt()
	return false;
end

---Override in Group/Mentions to let a player-name right-click (unit popup) stay usable in ghost mode.
---@return boolean
function Eavesdropper_SharedFrameMixin:IsPlayerLinkMouseExempt()
	return false;
end

---Mouse-click propagation depends on IsMouseEnabled(), passthrough on false.
function Eavesdropper_SharedFrameMixin:UpdateMouseLock()
	local isEnabled = self:IsMouseEnabled();
	self.stripMessageHyperlink = not isEnabled;

	-- Always keep the frame itself mouse-enabled so OnEnter/OnLeave still fire
	self:EnableMouse(true);

	-- Pass clicks and motion through to the world
	-- Unless they land on Jump, Sender, or enabled Hyperlink
	self:SetPropagateMouseClicks(true);
	self:SetPropagateMouseMotion(true);

	if self.SetMouseMotionEnabled then
		self:SetMouseMotionEnabled(true);
	end

	-- SetHyperlinksEnabled stays true when exempt so edjump/player can still hit-test; OnHyperlinkClick/
	-- OnHyperlinkEnter's per-linkType gate is what blocks every other link.
	local hyperlinksEnabled = isEnabled or self:IsJumpToContextMouseExempt() or self:IsPlayerLinkMouseExempt();

	-- This delay is essential otherwise it won't take effect
	RunNextFrame(function()
		if self.ChatBox then
			self.ChatBox:SetHyperlinksEnabled(hyperlinksEnabled);
		end
	end);

	self:RefreshChat(true);
end

-- ============================================================
-- Drag
-- ============================================================

---Begin moving the frame; only fires from the title bar when not locked
function Eavesdropper_SharedFrameMixin:OnDragStart()
	if self:IsWindowLocked() then return; end

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

---Applies saved position and size from a CharDB entry onto this frame so SaveToCharDB picks them up.
---@param pos table?
---@param size table?
function Eavesdropper_SharedFrameMixin:ApplySavedLayout(pos, size)
	if pos then
		self.savedPos = pos;
		self:ClearAllPoints();
		self:SetPoint(pos.point, UIParent, pos.relativePoint, pos.x, pos.y);
	end
	if size then
		self.savedSize = size;
		self:SetSize(size.width, size.height);
	end
end

---Applies saved per-instance filters from a CharDB entry, overriding Init's profile default.
---@param filters table<string, boolean>?
function Eavesdropper_SharedFrameMixin:ApplySavedFilters(filters)
	if not filters then return; end
	self.filters = filters;
	ED.ChatFilters:UpdateFilters(self);
end

---Applies saved config & title bar options from a CharDB entry (Dedicated/Group only)
---Mentions reads these from the profile instead.
---Re-runs RestoreLayout/UpdateMouseLock to apply the proper states.
---@param entry (EavesdropperSavedDedicatedFrame|EavesdropperGroupSessionState|EavesdropperSavedGroupFrame)?
function Eavesdropper_SharedFrameMixin:ApplySavedOptions(entry)
	if not entry then return; end

	if entry.mouseEnabled ~= nil then self.mouseEnabled = entry.mouseEnabled; end
	if entry.lockWindow ~= nil then self.lockWindow = entry.lockWindow; end
	if entry.lockScroll ~= nil then self.lockScroll = entry.lockScroll; end
	if entry.lockTitleBar ~= nil then self.lockTitleBar = entry.lockTitleBar; end
	if entry.hideCloseButton ~= nil then self.hideCloseButton = entry.hideCloseButton; end
	if entry.fontSize then self.FontSize = entry.fontSize; end

	self:UpdateMouseLock();
	self:RestoreLayout();
	ED.ChatBox:ApplyFontOptions(self);
end

---Override in concrete mixins to persist per-instance state (filters, layout options for Dedicated/Group only).
function Eavesdropper_SharedFrameMixin:SaveInstanceState()
end

---Callers add their own identifying fields (sender/name, players, nameDisplayMode) on top.
---@param entry table
function Eavesdropper_SharedFrameMixin:FillSavedStateFields(entry)
	entry.pos = self.savedPos;
	entry.size = self.savedSize;
	entry.filters = self.filters;
	entry.mouseEnabled = self.mouseEnabled;
	entry.lockWindow = self.lockWindow;
	entry.lockScroll = self.lockScroll;
	entry.lockTitleBar = self.lockTitleBar;
	entry.hideCloseButton = self.hideCloseButton;
	entry.fontSize = self.FontSize;
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
	if ED.Database:GetSetting("HideInCombat") and ED.Utils.CombatLockdown() then
		self:Hide();
		return;
	end

	self:Show();
end

---Apply font, filters, layout, colors, and history to this frame.
---Instance frames call this directly; the main frame's ApplyProfileSettings
---calls this then additionally refreshes the settings panel.
---@param skipChatRefresh boolean? True when the caller will immediately trigger its own RefreshChat (e.g. restoring a saved entry).
function Eavesdropper_SharedFrameMixin:ApplyWindowSettings(skipChatRefresh)
	ED.ChatBox:ApplyFontOptions(self);
	ED.ChatFilters:UpdateFilters(self);
	self:RestoreLayout();
	self:ApplyThemeColors();
	if not skipChatRefresh then
		self:RefreshChat();
	end
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

---Close button is 15px, flush-mounted; +1px margin.
local CLOSE_BUTTON_RESERVED = 16;
---Internal padding added to measured text width so the label stays visually centered.
local TITLE_BUTTON_PADDING = 24;
local MIN_TITLE_BUTTON_WIDTH = 110;

---Resize the TitleButton to fit its text, clamped between the minimum width and available TitleBar width.
function Eavesdropper_SharedFrameMixin:ResizeTitleButton()
	local titleButton = self.TitleBar and self.TitleBar.TitleButton;
	if not titleButton or not titleButton.Text then return; end

	local textWidth = titleButton.Text:GetStringWidth() + TITLE_BUTTON_PADDING;
	local maxWidth = self.TitleBar:GetWidth() - CLOSE_BUTTON_RESERVED;
	local width = Clamp(textWidth, MIN_TITLE_BUTTON_WIDTH, maxWidth);

	titleButton:SetWidth(width);
end

---Recalculate the TitleButton width when the frame is resized.
function Eavesdropper_SharedFrameMixin:OnSizeChanged()
	self:ResizeTitleButton();
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
	local chatFull = ED.ChatHistory:GetPlayerHistory(player, maxMessages, self);
	if chatFull and #chatFull > 0 then
		for _, entry in ipairs(chatFull) do
			self:AddMessage(entry, true);
		end
		return;
	end

	local chatBare = ED.ChatHistory:GetPlayerHistory(ED.Utils.StripRealmSuffix(player), maxMessages, self);
	if chatBare and #chatBare > 0 then
		for _, entry in ipairs(chatBare) do
			self:AddMessage(entry, true);
		end
	end
end

---Record the newest displayed entry's timestamp, read by IsTimestampFrozen.
---Takes the maximum, as group windows merge several histories out of order.
---@param entry EavesdropperChatEntry
function Eavesdropper_SharedFrameMixin:TrackNewestEntry(entry)
	if not entry.t then return; end

	if not self.newestEntryTime or entry.t > self.newestEntryTime then
		self.newestEntryTime = entry.t;
	end
end

---Override to add extra eligibility conditions for the new-message indicator.
---Mentions overrides this to also require a matching mention reason.
---@param entry EavesdropperChatEntry
---@return boolean
function Eavesdropper_SharedFrameMixin:IsNewIndicatorEligible(entry) -- luacheck: no unused (entry)
	return true;
end

---Record the clickblock timestamp, delegate to AddMessage, and handle the new-message indicator.
---@param entry EavesdropperChatEntry
function Eavesdropper_SharedFrameMixin:TryAddMessage(entry)
	if self.ChatBox:GetScrollOffset() == 0 then
		self.clickblock = GetTime();
	end

	self:AddMessage(entry);

	-- A new message un-freezes the window; the flag skips the Magnifier-driven main frame.
	if self.usesChatTicker then
		self:StartChatTicker();
	end

	-- GetNewIndicatorSettingKey() and IsNewIndicatorEligible() are overridden by their respective mixins.
	if not entry.p
		and ED.ChatFilters:HasEvent(entry.e, self)
		and ED.Database:GetGlobalSetting(self:GetNewIndicatorSettingKey())
		and self.NewIndicator
		and not self.isMouseOver
		and self:IsNewIndicatorEligible(entry)
	then
		self:FadeInNewIndicator();
		self:ScheduleNewIndicatorFadeOut();
	end
end

-- ============================================================
-- Screenshot Helper
-- ============================================================

function Eavesdropper_SharedFrameMixin:SetAlphaChannelMode(mode)
	-- mode 1: All Widgets turn black + white fullscreen backdrop
	-- mode 2: Widgets use original colors + black fullscreen backdrop
	-- other : Disable

	-- Nothing to restore if this frame was never colorized
	if not mode and not self.alphaChannelMode then return; end

	self.alphaChannelMode = mode;

	local frameStrata;

	ED.ScreenshotHelper.SetupObjectColorByMode(self, mode);

	if mode == 1 or mode == 2 then
		frameStrata = "MEDIUM";
		self:Raise();
	else
		frameStrata = "BACKGROUND";
		self:ApplyThemeColors();
	end

	self:SetFrameStrata(frameStrata);
end

-- ============================================================
-- Chatbox Scrollbar
-- ============================================================

function Eavesdropper_SharedFrameMixin:UpdateScrollbar()
	if self.ChatBox.Scrollbar then
		self.ChatBox.Scrollbar:FullUpdate();
	end
end
