-- Copyright The Eavesdropper Authors
-- SPDX-License-Identifier: GPL-3.0-or-later

local L = ED.Localization;

---@type EavesdropperConstants
local Constants = ED.Constants;

---@type EavesdropperEnums
local Enums = ED.Enums;

---@class EavesdropperCopyHistoryDialog
local CopyHistoryDialog = {};

local FRAME_NAME = "Eavesdropper_CopyHistoryDialog";

local BODY_INSET_TOP = 34; -- Matches ImportExportDialog's first-row inset below the title bar.
local SELECT_ALL_BUTTON_MIN_WIDTH = 90;
local SELECT_ALL_BUTTON_PADDING = 24; -- Matches ResizeTitleButton's own padding.
local SELECT_ALL_BUTTON_GAP = 10; -- Kept clear of the dropdown for a very long translation.
local SELECT_ALL_BUTTON_HEIGHT = 20;
local FORMATTING_DROPDOWN_WIDTH = 120;

local TIMESTAMP_MODE = Enums.COPY_HISTORY.TIMESTAMP_MODE;
local SHOW_NAMES_MODE = Enums.COPY_HISTORY.SHOW_NAMES_MODE;
local NAME_DISPLAY_MODE = Enums.NAME_DISPLAY_MODE;

-- These three double as the Formatting dropdown's menu entries; labelKey is resolved live
-- in BuildFormattingGroup, since L.KEY this early would freeze on enUS until login.
local TIMESTAMP_ROW_OPTIONS = {
	{ mode = TIMESTAMP_MODE.FIXED, labelKey = "COPYHISTORY_TIMESTAMP_FIXED" },
	{ mode = TIMESTAMP_MODE.RELATIVE, labelKey = "COPYHISTORY_TIMESTAMP_RELATIVE" },
	{ mode = TIMESTAMP_MODE.NONE, labelKey = "COPYHISTORY_TIMESTAMP_NONE" },
};

local SHOW_NAMES_ROW_OPTIONS = {
	{ mode = SHOW_NAMES_MODE.WINDOW_DEFAULT, labelKey = "COPYHISTORY_SHOW_NAMES_WINDOW_DEFAULT" },
	{ mode = SHOW_NAMES_MODE.ON, labelKey = "COPYHISTORY_SHOW_NAMES_ON" },
	{ mode = SHOW_NAMES_MODE.OFF, labelKey = "COPYHISTORY_SHOW_NAMES_OFF" },
};

-- When nil, follows the profile's NameDisplayMode, same as the frame-level override.
local NAME_DISPLAY_ROW_OPTIONS = {
	{ mode = nil, labelKey = "NAME_DISPLAY_MODE_FOLLOW_PROFILE" },
	{ mode = NAME_DISPLAY_MODE.FULL_NAME, labelKey = "NAME_DISPLAY_MODE_FULL_NAME" },
	{ mode = NAME_DISPLAY_MODE.FIRST_NAME, labelKey = "NAME_DISPLAY_MODE_FIRST_NAME" },
	{ mode = NAME_DISPLAY_MODE.ORIGINAL_NAME, labelKey = "NAME_DISPLAY_MODE_ORIGINAL_NAME" },
};

-- Fixed timestamps carry no color of their own, unlike Relative's age tint.
local FIXED_TIMESTAMP_COLOR = CreateColor(0.5, 0.5, 0.5);

---Builds one copy line from entry, formatted fresh so Show Names/Name Display can differ
---from how the line originally rendered live.
---@param entry EavesdropperChatEntry
---@param timestampMode EavesdropperCopyHistoryTimestampMode
---@param forGroup boolean Whether the sender name gets embedded.
---@param nameDisplayMode EavesdropperNameDisplayMode?
---@return string
local function BuildCopyLine(entry, timestampMode, forGroup, nameDisplayMode)
	local timestamp = "";
	if timestampMode == TIMESTAMP_MODE.FIXED then
		timestamp = ED.Utils.WrapTextInColor(date("%H:%M:%S", entry.t), FIXED_TIMESTAMP_COLOR) .. " ";
	elseif timestampMode == TIMESTAMP_MODE.RELATIVE then
		timestamp = ED.ChatFormatter.FormatTimestamp(entry);
	end

	local suffix = ED.ChatFormatter.FormatSuffix(entry, forGroup, nameDisplayMode);
	return timestamp .. ED.Utils.StripHyperlinks(suffix);
end

---Gathers a sender's full stored history, unbounded by the frame's configured display cap.
---@param player string?
---@param frame table Frame whose filters apply.
---@return EavesdropperChatEntry[]
local function GatherPlayerHistory(player, frame)
	if not player then return {}; end

	local history = ED.ChatHistory:GetPlayerHistory(player, math.huge, frame);
	if history and #history > 0 then return history; end

	return ED.ChatHistory:GetPlayerHistory(ED.Utils.StripRealmSuffix(player), math.huge, frame) or {};
end

---Mirrors RebuildMergedHistory's gather and sort, minus the maxMessages trim.
---@param frame table Group frame with a players list.
---@param onComplete fun(entries: EavesdropperChatEntry[])
---@param isCurrent fun(): boolean Stops the walk early once a newer CaptureSnapshot supersedes it.
local function GatherGroupHistory(frame, onComplete, isCurrent)
	local players = frame.players;
	local seen = {};
	local entries = {};

	local function GatherPlayer(player)
		for _, entry in ipairs(GatherPlayerHistory(player, frame)) do
			if not seen[entry.id] then
				seen[entry.id] = true;
				entries[#entries + 1] = entry;
			end
		end
	end

	local function Finish()
		table.sort(entries, function(a, b) return a.id < b.id; end);
		onComplete(entries);
	end

	local rawCount = 0;
	for _, player in ipairs(players) do
		rawCount = rawCount + #(ED.ChatHistory.history[player] or {});
	end

	if rawCount <= Constants.CHAT_BOX.GROUP_CHUNK_THRESHOLD then
		for _, player in ipairs(players) do
			GatherPlayer(player);
		end
		Finish();
		return;
	end

	local index = 0;
	local function Step()
		if not isCurrent() then return; end

		index = index + 1;
		local player = players[index];
		if not player then
			Finish();
			return;
		end

		GatherPlayer(player);
		RunNextFrame(Step);
	end

	Step();
end

---Resolves whether a line's sender name should be embedded, per the Show Names setting.
---@param showNamesMode EavesdropperCopyHistoryShowNamesMode
---@param windowDefaultForGroup boolean The invoking window's own default (on for Group/Mentions).
---@return boolean
local function ResolveForGroup(showNamesMode, windowDefaultForGroup)
	if showNamesMode == SHOW_NAMES_MODE.ON then return true; end
	if showNamesMode == SHOW_NAMES_MODE.OFF then return false; end
	return windowDefaultForGroup;
end

---Builds a shared tooltip's OnEnter/OnLeave, anchored wherever setAnchorFrame points it.
---@param title string
---@param text string
---@return function onEnter, function onLeave, function setAnchorFrame
local function CreateGroupTooltipHandlers(title, text)
	local anchorFrame;

	local function OnEnter()
		local tooltip = GetAppropriateTooltip();
		tooltip:SetOwner(anchorFrame, "ANCHOR_RIGHT");
		GameTooltip_SetTitle(tooltip, title);
		GameTooltip_AddNormalLine(tooltip, text);
		tooltip:Show();
	end

	local function OnLeave()
		GetAppropriateTooltip():Hide();
	end

	local function SetAnchorFrame(frame)
		anchorFrame = frame;
	end

	return OnEnter, OnLeave, SetAnchorFrame;
end

---Builds one radio group in the Formatting dropdown; every radio shares the title's
---tooltip and keeps the dropdown open on pick.
---@param dialog table The CopyHistoryDialog frame, for RefreshText.
---@param rootDescription table
---@param title string
---@param helpText string
---@param settingKey EavesdropperGlobalSettingKey
---@param options table[] { mode, labelKey }
local function BuildFormattingGroup(dialog, rootDescription, title, helpText, settingKey, options)
	local onEnter, onLeave, setAnchorFrame = CreateGroupTooltipHandlers(title, helpText);
	local titleElement = rootDescription:CreateTitle(title);
	titleElement:AddInitializer(function(frame) setAnchorFrame(frame); end);
	titleElement:SetOnEnter(onEnter);
	titleElement:SetOnLeave(onLeave);

	for _, option in ipairs(options) do
		local radio = rootDescription:CreateRadio(L[option.labelKey],
			function() return ED.Database:GetGlobalSetting(settingKey) == option.mode; end,
			function()
				ED.Database:SetGlobalSetting(settingKey, option.mode);
				dialog:RefreshText();
			end);
		radio:SetResponse(MenuResponse.Refresh); -- Keep the dropdown open so other groups can be changed too.
		radio:SetOnEnter(onEnter);
		radio:SetOnLeave(onLeave);
	end
end

-- ============================================================
-- Frame mixin
-- ============================================================

Eavesdropper_CopyHistoryDialogMixin = {};

function Eavesdropper_CopyHistoryDialogMixin:OnLoad()
	tinsert(UISpecialFrames, self:GetName());

	NineSliceUtil.DisableSharpening(self.NineSlice);
	self.Background.BackgroundColor:SetColorTexture(0.12, 0.12, 0.12, 0.95);
	self.Background.InnerShadow:SetTexture("Interface/AddOns/Eavesdropper/Resources/SettingsPanelInnerShadow.png");
	self.NineSlice.Text:SetText(ED.Globals.addon_settings_icon .. " " .. ED.Globals.addon_title .. " " .. L.COPYHISTORY_TITLE);

	self.CloseButton:SetScript("OnClick", function()
		self:Hide();
	end);

	self:BuildOptionsRow();
	self:BuildTextBox();
	self.LoadingSpinner:Raise();

	ED.ElvUI.RegisterSkinnableElement(self, Enums.ELVUI_SKIN_TYPE.FRAME);
	ED.ElvUI.RegisterSkinnableElement(self.ScrollFrame.ScrollBar, Enums.ELVUI_SKIN_TYPE.SCROLLBAR);
	ED.ElvUI.RegisterSkinnableElement(self.SelectAllButton, Enums.ELVUI_SKIN_TYPE.BUTTON);
	ED.ElvUI.RegisterSkinnableElement(self.FormattingDropdown, Enums.ELVUI_SKIN_TYPE.DROPDOWN, true);
end

function Eavesdropper_CopyHistoryDialogMixin:OnDragStart()
	self:StartMoving();
end

function Eavesdropper_CopyHistoryDialogMixin:OnDragStop()
	self:StopMovingOrSizing();
end

---Builds the options row under the title bar: Select All left, Formatting dropdown right.
function Eavesdropper_CopyHistoryDialogMixin:BuildOptionsRow()
	local row = CreateFrame("Frame", nil, self);
	row:SetPoint("TOPLEFT", self, "TOPLEFT", Constants.SETTINGS.TITLE_OFFSET, -BODY_INSET_TOP);
	row:SetPoint("TOPRIGHT", self, "TOPRIGHT", -Constants.SETTINGS.TITLE_OFFSET, -BODY_INSET_TOP);
	row:SetHeight(Constants.SETTINGS.WIDGET_HEIGHT);
	self.OptionsRow = row;

	local selectAllButton = CreateFrame("Button", nil, row, "UIPanelButtonTemplate");
	selectAllButton:SetHeight(SELECT_ALL_BUTTON_HEIGHT);
	selectAllButton:SetPoint("LEFT", row, "LEFT");
	selectAllButton:SetText(L.COPYHISTORY_SELECT_ALL);

	-- Sized to the label so longer translations aren't clipped.
	local textWidth = selectAllButton:GetFontString():GetStringWidth() + SELECT_ALL_BUTTON_PADDING;
	local maxWidth = row:GetWidth() - FORMATTING_DROPDOWN_WIDTH - SELECT_ALL_BUTTON_GAP;
	selectAllButton:SetWidth(Clamp(textWidth, SELECT_ALL_BUTTON_MIN_WIDTH, maxWidth));

	selectAllButton:SetScript("OnClick", function()
		self.TextBox:SetFocus();
		self.TextBox:HighlightText();
	end);
	self.SelectAllButton = selectAllButton;

	-- Static "Formatting" face text, since three groups' worth of selections wouldn't fit.
	local formattingDropdown = CreateFrame("DropdownButton", nil, row, "WowStyle1DropdownTemplate");
	formattingDropdown:SetSize(FORMATTING_DROPDOWN_WIDTH, Constants.SETTINGS.WIDGET_HEIGHT);
	formattingDropdown:SetPoint("RIGHT", row, "RIGHT");
	formattingDropdown:SetupMenu(function(_, rootDescription)
		BuildFormattingGroup(self, rootDescription, L.COPYHISTORY_SHOW_NAMES_TITLE,
			L.COPYHISTORY_SHOW_NAMES_HELP, "CopyHistoryShowNamesMode", SHOW_NAMES_ROW_OPTIONS);

		rootDescription:CreateDivider();
		BuildFormattingGroup(self, rootDescription, L.NAME_DISPLAY_MODE,
			L.COPYHISTORY_NAME_DISPLAY_HELP, "CopyHistoryNameDisplayMode", NAME_DISPLAY_ROW_OPTIONS);

		rootDescription:CreateDivider();
		BuildFormattingGroup(self, rootDescription, L.COPYHISTORY_TIMESTAMPS_TITLE,
			L.COPYHISTORY_TIMESTAMPS_HELP, "CopyHistoryTimestampMode", TIMESTAMP_ROW_OPTIONS);
	end);
	formattingDropdown:OverrideText(L.COPYHISTORY_FORMATTING_TITLE);
	self.FormattingDropdown = formattingDropdown;
end

---Builds the read-only text box, filling everything below the options row.
function Eavesdropper_CopyHistoryDialogMixin:BuildTextBox()
	local backdrop, scrollFrame, editBox = ED.DialogWidgets.CreateReadOnlyTextBox(self, self.OptionsRow);
	self.TextBoxBackdrop = backdrop;
	self.ScrollFrame = scrollFrame;
	self.TextBox = editBox;
end

---Snapshots frame's history once; RefreshText reformats this afterward instead of re-reading
---live data, since Main rebuilds its ChatBox on every target change.
---@param frame table Any of the four Eavesdropper window types.
---@param mode ("dedicated"|"group"|"mentions")? Matches Config.ShowConfigMenu's own mode values.
---@param onComplete fun()
function Eavesdropper_CopyHistoryDialogMixin:CaptureSnapshot(frame, mode, onComplete)
	self.captureGeneration = (self.captureGeneration or 0) + 1;
	local generation = self.captureGeneration;

	local function IsCurrent()
		return generation == self.captureGeneration;
	end

	local function Apply(entries)
		if not IsCurrent() then return; end
		self.snapshot = entries;
		onComplete();
	end

	if not frame then
		Apply({});
	elseif mode == "group" then
		GatherGroupHistory(frame, Apply, IsCurrent);
	elseif mode == "mentions" then
		Apply(ED.ChatHistory:GetMentions(math.huge, frame));
	else
		Apply(GatherPlayerHistory(frame.eavesdropped_player, frame));
	end
end

---Rebuilds the copy text from the snapshot without touching selection; callers that want
---everything selected call HighlightText themselves.
function Eavesdropper_CopyHistoryDialogMixin:RefreshText()
	local timestampMode = ED.Database:GetGlobalSetting("CopyHistoryTimestampMode");
	local showNamesMode = ED.Database:GetGlobalSetting("CopyHistoryShowNamesMode");
	local nameDisplayMode = ED.Database:GetGlobalSetting("CopyHistoryNameDisplayMode");
	local forGroup = ResolveForGroup(showNamesMode, self.windowDefaultForGroup);
	local lines = {};

	for _, entry in ipairs(self.snapshot) do
		lines[#lines + 1] = BuildCopyLine(entry, timestampMode, forGroup, nameDisplayMode);
	end

	self.TextBox:SetReadOnlyText(table.concat(lines, "\n"));
end

-- ============================================================
-- Module
-- ============================================================

---Creates the dialog on first use and returns it.
---@return table frame
function CopyHistoryDialog:GetFrame()
	if not self.frame then
		self.frame = CreateFrame("Frame", FRAME_NAME, UIParent, "Eavesdropper_CopyHistoryDialogTemplate");
	end

	return self.frame;
end

---Shows the dialog with frame's full chat history. For a large Group, content may take a
---few frames to appear; see CaptureSnapshot.
---@param frame table Any of the four Eavesdropper window types.
---@param mode ("dedicated"|"group"|"mentions")? Matches Config.ShowConfigMenu's own mode values.
function CopyHistoryDialog:Show(frame, mode)
	local dialog = self:GetFrame();
	dialog.windowDefaultForGroup = (mode == "group" or mode == "mentions");
	dialog.TextBox:SetReadOnlyText("");
	dialog.LoadingSpinner:Show();
	dialog:Show();

	dialog:CaptureSnapshot(frame, mode, function()
		dialog.LoadingSpinner:Hide();
		dialog:RefreshText();
		dialog.TextBox:SetFocus();
		dialog.TextBox:HighlightText();
	end);
end

ED.CopyHistoryDialog = CopyHistoryDialog;
