-- Copyright The Eavesdropper Authors
-- SPDX-License-Identifier: Apache-2.0

---@type EavesdropperConstants
local Constants = ED.Constants;

---@type EavesdropperEnums
local Enums = ED.Enums;

---@class EavesdropperFrameModule
local FrameModule = {};

local L = ED.Localization;

-- Private frame state
local EAVESDROP_TARGET = nil;

Eavesdropper_FrameMixin = {};

function Eavesdropper_FrameMixin:OnLoad()
	self:EnableMouseWheel(true);
	self:UpdateMouseLock();
	self.clickblock = 0;
	self.closed = false;
	self.isMouseOver = false;

	self.ChatBox:SetJustifyH("LEFT");
	self.ChatBox:SetIndentedWordWrap(true);
	self.ChatBox:SetHyperlinksEnabled(true);
	self.ChatBox:SetFading(false);
	self.ChatBox:SetMaxLines(300);
	self.ChatBox.ScrollMarker.Text:SetText(L.SCROLLMARKER_TEXT);

	if ED.Database and not ED.Database:GetSetting("LockWindow") then
		self.ResizeHandle:Show();
	end

	if ED.Database and ED.Database:GetSetting("LockTitleBar") then
		self.TitleBar:Show();
	end

	local closeBtn = self.TitleBar.CloseButton;
	closeBtn:SetNormalAtlas("uitools-icon-close");
	closeBtn:SetPushedAtlas("uitools-icon-close");
	closeBtn:SetHighlightAtlas("uitools-icon-close");
	closeBtn:SetScript("OnClick", function()
		self:Hide();
		ED.Frame.closed = true;
	end);

	if ED.Database and ED.Database:GetSetting("HideCloseButton") then
		self.TitleBar.CloseButton:Hide();
	end

	local titleBtn = self.TitleBar.TitleButton;
	titleBtn.Text:SetText("Eavesdropper");

	hooksecurefunc(self.ChatBox, "RefreshDisplay", function()
		self.OnChatboxRefresh(self)
	end)
end

function Eavesdropper_FrameMixin:OnHide()
	self.closed = true;
end

function Eavesdropper_FrameMixin:OnHyperlinkClick(link, text, button)
	if ED.Database and not ED.Database:GetSetting("EnableMouse") then
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

function Eavesdropper_FrameMixin:OnScrollMarkerMouseUp()
	self.ChatBox:ScrollToBottom();
	self:OnChatboxRefresh();
end

function Eavesdropper_FrameMixin:OnChatboxRefresh()
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

function Eavesdropper_FrameMixin:IsHoveringOverEavesdropperFrame()
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

function Eavesdropper_FrameMixin:OnEnter()
	if self.isMouseOver then return; end
	self.isMouseOver = true;
	self:HandleHoverState(Enums.FRAME.MOUSE_HOVER_STATE.ON);
end

function Eavesdropper_FrameMixin:OnLeave()
	if not self:IsHoveringOverEavesdropperFrame() then
		self.isMouseOver = false;
		self:HandleHoverState(Enums.FRAME.MOUSE_HOVER_STATE.OFF);
	end
end

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

	if ED.Database and not ED.Database:GetSetting("LockWindow") then
		self.ResizeHandle:Show();
	else
		self.ResizeHandle:Hide();
	end

	if ED.Database and ED.Database:GetSetting("HideCloseButton") then
		self.TitleBar.CloseButton:Hide();
	else
		self.TitleBar.CloseButton:Show();
	end
end

function Eavesdropper_FrameMixin:ApplyThemeColors()
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

function Eavesdropper_FrameMixin:OnDragStart()
	-- Bit of a hack to know if we're just on the title bar
	local isTitlebar = GetMouseFoci()[1] == self.TitleBar;
	if not ED.Database or ED.Database:GetSetting("LockWindow") or not isTitlebar then
		return;
	end

	self:StopMovingOrSizing();
	self:StartMoving();
end

function Eavesdropper_FrameMixin:OnDragStop()
	self:StopMovingOrSizing();

	if not ED.Database then return; end

	local point, _, relativePoint, x, y = self:GetPoint(1);
	ED.Database:SetSetting("WindowPosition", { point = point, relativePoint = relativePoint, x = x, y = y, });
end

function Eavesdropper_FrameMixin:OnResizeFinished()
	if not ED.Database then return; end

	local w, h = self:GetSize();
	local point, _, relativePoint, x, y = self:GetPoint(1);
	ED.Database:SetSetting("WindowSize", { width = w, height = h });
	ED.Database:SetSetting("WindowPosition", { point = point, relativePoint = relativePoint, x = x, y = y, });
end

-- Unused for now (maybe in the future eh?)
function Eavesdropper_FrameMixin:OnSizeChanged()
end

function Eavesdropper_FrameMixin:OnMouseWheel(delta)
	if ED.Database and ED.Database:GetSetting("LockScroll") then return; end

	if delta > 0 then
		if IsAltKeyDown() then
			self.ChatBox:ScrollToTop();
		elseif IsControlKeyDown() then
			ED.ChatBox:AdjustFontSize(Enums.FRAME.SCROLL_DIRECTION.UP);
		else
			self.ChatBox:ScrollUp();
		end
	else
		if IsAltKeyDown() then
			self.ChatBox:ScrollToBottom();
		elseif IsControlKeyDown() then
			ED.ChatBox:AdjustFontSize(Enums.FRAME.SCROLL_DIRECTION.DOWN);
		else
			self.ChatBox:ScrollDown();
		end
	end

	self.fade_time = GetTime();
end

function Eavesdropper_FrameMixin:EavesdroppingOn(name)
	local filter = self.players and self.players[name];
	return filter == 1;
end

function Eavesdropper_FrameMixin:UpdateMagnifier()
	if not self then return; end

	ED.Debug:Print("Magnified Changed!");
	self:UpdateTarget();
end

-- This is a bit more involved as we don't use OnUpdate to check OnEnter/OnLeave checks for the frame
function Eavesdropper_FrameMixin:UpdateMouseLock()
	local isLocked = ED.Database and ED.Database:GetSetting("EnableMouse");

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
function Eavesdropper_FrameMixin:RefreshChat()
	if not self.ChatBox then return; end

	self.refreshing = true;
	self.ChatBox:Clear();

	local maxMessages = ED.Database:GetSetting("MaxHistory");

	local player = self.eavesdropped_player;
	self.TitleBar.TitleButton.Text:SetText(ED.Database:GetSetting("UpdateTitleBarWithName") and player and ED.Utils.StripRealmSuffix(player) or "Eavesdropper");

	if player then
		local chatFull = ED.ChatHistory:GetPlayerHistory(player, maxMessages);
		if chatFull and #chatFull > 0 then
			for _, entry in ipairs(chatFull) do
				self:AddMessage(entry, false, true);
			end
		else
			local chatBare = ED.ChatHistory:GetPlayerHistory(ED.Utils.StripRealmSuffix(player), maxMessages);
			if chatBare and #chatBare > 0 then
				for _, entry in ipairs(chatBare) do
					self:AddMessage(entry, false, true);
				end
			end
		end
	end

	self.refreshing = false;
end

function Eavesdropper_FrameMixin:ShowTitleBar(show)
	if ED.Database:GetSetting("LockTitleBar") then
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

function Eavesdropper_FrameMixin:ShowResizeHandle(show)
	if not ED.Database:GetSetting("LockWindow") and show and not self.ResizeHandle:IsShown() then
		self.ResizeHandle:Show();
	elseif not show and self.ResizeHandle:IsShown() then
		self.ResizeHandle:Hide();
	end
end

function Eavesdropper_FrameMixin:HandleHoverState(show)
	self:ShowTitleBar(show);
end

function Eavesdropper_FrameMixin:HandleHiding()
	if ED.Database:GetSetting("HideWhenEmpty") then
		local shouldShow = EAVESDROP_TARGET and self.ChatBox:GetNumMessages() > 0;

		if shouldShow and not self:IsShown() then
			self:Show();
		elseif not shouldShow and self:IsShown() then
			self:Hide();
		end
	else
		self:Show();
	end
end

---Update the eavesdropped target based on mouseover, target, and magnifier
function Eavesdropper_FrameMixin:UpdateTarget()
	ED.Debug:Print("UpdateTarget");
	if InCombatLockdown() then return; end

	-- Determine target
	local magnifiedName, magnifiedGUID = ED.Magnifier:GetMagnified();
	local target = magnifiedName or (magnifiedGUID and ED.PlayerCache:GetSenderDataFromGUID(magnifiedGUID));

	-- If nothing resolved and nothing previously tracked, exit early
	if not target and not EAVESDROP_TARGET then
		return;
	end

	-- Skip if same target and recently updated (throttle 10 sec by default)
	-- Logically we never hit this, as UpdateTarget is on a 10s timer by default.
	local now = GetTime();
	if EAVESDROP_TARGET == target and now - (self.lastUpdate or 0) < Constants.CHAT_UPDATE_THROTTLE_DEFAULT then
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
	else
		self.eavesdropped_player = nil;
	end

	-- Refresh if target changed or scrolled to bottom
	if hardUpdate or (self.ChatBox and self.ChatBox:AtBottom()) then
		self:RefreshChat();
		self.lastUpdate = now;
	end

	-- Handle auto-hide when empty
	if ED.Database:GetSetting("HideWhenEmpty") then
		local shouldShow = target and self.ChatBox:GetNumMessages() > 0;

		if shouldShow and not self:IsShown() then
			self:Show();
		elseif not shouldShow and self:IsShown() then
			self:Hide();
		end
	end
end

---Add a chat entry to the frame
---@param entry EavesdropperChatEntry
function Eavesdropper_FrameMixin:AddMessage(entry)
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
	if ED.Database:GetSetting("HideWhenEmpty") then
		self:Show();
	end
	local r, g, b = ED.ChatFormatter:GetEntryColor(entry);
	local formatted, firstName = ED.ChatFormatter:FormatMessage(entry);
	self.ChatBox:AddMessage(formatted, r, g, b);
	if ED.Database:GetSetting("UpdateTitleBarWithName") then
		self.TitleBar.TitleButton.Text:SetText(firstName);
	end
end

---Safe wrapper to add a chat message
---@param entry EavesdropperChatEntry
function Eavesdropper_FrameMixin:TryAddMessage(entry)
	if self.ChatBox:GetScrollOffset() == 0 then
		self.clickblock = GetTime();
	end

	self:AddMessage(entry);
end

function Eavesdropper_FrameMixin:ApplyProfileSettings()
	ED.ChatBox:ApplyFontOptions();
	self:RestoreLayout();
	self:ApplyThemeColors();
	self:RefreshChat();

	if ED.SettingsFrame then
		ED.SettingsFrame:RefreshWidgets();
	end
end

function FrameModule:Init()
	local frame = CreateFrame("Frame", "Eavesdropper_Frame", UIParent, "Eavesdropper_FrameTemplate");
	ED.Frame = frame;
	frame:Show();

	frame:ApplyProfileSettings();
	ED.ChatFilters:Init(frame);
end

ED.FrameModule = FrameModule;

return FrameModule;
