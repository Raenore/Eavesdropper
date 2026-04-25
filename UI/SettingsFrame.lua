-- Copyright The Eavesdropper Authors
-- SPDX-License-Identifier: Apache-2.0

---@type EavesdropperConstants
local Constants = ED.Constants;

---@type EavesdropperSettingsElements
local SettingsElements = ED.SettingsElements;

---@class EavesdropperSettings
local Settings = {};

---@type table
local SharedMedia = LibStub("LibSharedMedia-3.0");

local L = ED.Localization;

Eavesdropper_SettingsMixin = {};

local fontList = {};
for _, fontName in ipairs(SharedMedia:List("font")) do
	fontList[fontName] = fontName;
end

local lastSelectedTab;
local allWidgets = {};

-- ============================================================
-- Widget refresh
-- ============================================================

function Eavesdropper_SettingsMixin:RefreshWidgets()
	for _, widget in pairs(allWidgets) do
		if widget.Refresh then
			widget:Refresh();
		end
	end
end

-- ============================================================
-- Tab management
-- ============================================================

function Eavesdropper_SettingsMixin:CreateCategoryListButton(addToBottom)
	local button = CreateFrame("Button", nil, self.CategoryList, "Eavesdropper_SettingsCategoryListButtonTemplate");

	if not self.topTabCount then
		self.topTabCount = 0;
	end

	if not self.bottomTabCount then
		self.bottomTabCount = 0;
	end

	local tabHeight = button:GetHeight();
	local tabPadding = 2;

	if addToBottom then
		-- Add a button to the bottom of the list, such as Changelog
		self.bottomTabCount = self.bottomTabCount + 1;
		local fromOffset = 12;
		button:SetPoint("BOTTOMLEFT", 0, fromOffset + (self.bottomTabCount - 1) * (tabHeight + tabPadding) + tabPadding);
	else
		self.topTabCount = self.topTabCount + 1;
		local fromOffset = -16;
		button:SetPoint("TOPLEFT", 0, fromOffset - (self.topTabCount - 1) * (tabHeight + tabPadding) - tabPadding);
	end

	ED.ElvUI.RegisterSkinnableElement(button);

	return button;
end

function Eavesdropper_SettingsMixin:SetTab(index)
	for i, panel in ipairs(self.Views) do
		local isSelected = (i == index);
		panel:SetShown(isSelected);
		panel.categoryListBtton:SetSelected(isSelected);

		local scroll = panel.scrollFrame;
		if scroll then
			scroll:SetShown(isSelected);
			if scroll.ScrollBar then
				scroll.ScrollBar:SetShown(isSelected);
			end
		end
	end

	lastSelectedTab = index;
end

-- ============================================================
-- Panel / view management
-- ============================================================

---Creates a non-scrollable panel for a settings tab
function Eavesdropper_SettingsMixin:AddFrame()
	local frame = CreateFrame("Frame", nil, self.SettingsList);
	frame:SetPoint("TOP", 0, -4);
	frame:SetPoint("LEFT");
	frame:SetPoint("RIGHT");
	frame:SetPoint("BOTTOM");

	frame.isScrollable = false;
	frame.scrollFrame = nil;

	self.Views[#self.Views + 1] = frame;

	return frame;
end

---Creates a scrollable panel for a settings tab
function Eavesdropper_SettingsMixin:AddScrollableFrame()
	local frame = CreateFrame("Frame", nil, self.SettingsList);
	frame:SetPoint("TOP", 0, 0);
	frame:SetPoint("LEFT");
	frame:SetPoint("RIGHT");
	frame:SetPoint("BOTTOM");

	local paddingLeft, paddingRight, paddingTop, paddingBottom = 0, 25, 4, 4;

	local scrollFrame = CreateFrame("ScrollFrame", nil, frame, "Eavesdropper_SettingsScrollFrameTemplate");
	scrollFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", paddingLeft, -paddingTop);
	scrollFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -paddingRight, paddingBottom);

	-- Extend mouse interaction into the scrollbar area
	scrollFrame:SetHitRectInsets(0, -paddingRight, 0, 0);

	-- Scroll child holds all content
	local scrollChild = CreateFrame("Frame", nil, scrollFrame);
	scrollChild:SetPoint("TOPLEFT");
	scrollFrame:SetScrollChild(scrollChild);

	scrollFrame:HookScript("OnSizeChanged", function(_, width, height)
		scrollChild:SetWidth(width);
		scrollChild:SetHeight(height);
	end);

	frame.isScrollable = true;
	frame.scrollFrame = scrollFrame;
	frame.scrollChild = scrollChild;

	self.Views[#self.Views + 1] = frame;
	ED.ElvUI.RegisterSkinnableElement(scrollFrame.ScrollBar, "scrollbar");

	return frame, scrollChild;
end

---Populates a panel (frame or scrollChild) with a list of options
function Eavesdropper_SettingsMixin:PopulatePanel(panel, options)
	local previousContainer = nil;

	tinsert(options, {type = "spacer"}); -- Additional spacer to the bottom so the last widget doesn't touch the bottom of border

	for _, data in ipairs(options) do
		local container, widget;
		local padding = -Constants.SETTINGS.PADDING_HEIGHT;

		if data.type == "subtitle" then
			container = SettingsElements.CreateSubTitle(panel, data.label, data.subLabel, data);
			widget = data and container or nil;
			padding = -Constants.SETTINGS.PADDING_HEIGHT_TITLE;
		elseif data.type == "description" then
			container = SettingsElements.CreateDescription(panel, data.label);
			widget = nil;
		elseif data.type == "spacer" then
			container = CreateFrame("Frame", nil, panel);
			container:SetSize(2, Constants.SETTINGS.PADDING_HEIGHT_TITLE);
		else
			container, widget = SettingsElements.CreateElement(panel, data);
		end

		if previousContainer then
			container:SetPoint("TOPLEFT", previousContainer, "BOTTOMLEFT", 0, padding);
		else
			container:SetPoint("TOPLEFT", panel, "TOPLEFT", 0, padding);
		end

		if widget then
			local key = widget.settingKey or (#allWidgets + 1);
			allWidgets[key] = widget;
		end

		previousContainer = container;
	end

	return previousContainer;
end

---Create a CategoryListButton (left) and a panel (right) populated with options
function Eavesdropper_SettingsMixin:CreateCategory(categoryName, isScrollable, options, addToBottom)
	if not self.categoryIndex then
		self.categoryIndex = 0;
	end

	self.categoryIndex = self.categoryIndex + 1;

	local categoryListBtton = self:CreateCategoryListButton(addToBottom);
	table.insert(self.CategoryListButtons, categoryListBtton);
	categoryListBtton:SetText(categoryName);

	local frame, scrollChild;

	if isScrollable then
		frame, scrollChild = self:AddScrollableFrame();
		frame:Hide();
	else
		frame = self:AddFrame();
		frame:Hide();
	end

	frame.categoryListBtton = categoryListBtton;

	-- Store the following two values because we need to re-index categories due to adding categories to the bottom
	frame.categoryIndex = self.categoryIndex;
	frame.addToBottom = addToBottom;

	local panel = scrollChild or frame; -- This is the options' container

	if options then
		self:PopulatePanel(panel, options);
	end

	return panel, categoryListBtton;
end

-- ============================================================
-- OnLoad
-- ============================================================

function Eavesdropper_SettingsMixin:OnLoad()
	tinsert(UISpecialFrames, self:GetName());

	self.CategoryListButtons = {};
	self.Views = {};

	self.NineSlice.Text:SetText(ED.Globals.addon_settings_icon .. " " .. ED.Globals.addon_title .. " " .. SETTINGS);
	NineSliceUtil.DisableSharpening(self.NineSlice);

	self.CloseButton:SetScript("OnClick", function()
		self:Hide();
	end);

	local pos = ED.Database:GetGlobalSetting("SettingsWindowPosition");
	if pos then
		self:ClearAllPoints();
		self:SetPoint(pos.point, UIParent, pos.relativePoint, pos.x, pos.y);
	end

	self.Background.BackgroundColor:SetColorTexture(0.12, 0.12, 0.12, 0.95);
	self.Background.InnerShadow:SetTexture("Interface/AddOns/Eavesdropper/Resources/SettingsPanelInnerShadow.png");

	-- Add a divider between CategoryList and SettingsList
	local function CreateLine(parent, relativeTo, orientation, lineShrink, offset)
		local line = parent:CreateTexture(nil, "OVERLAY");
		if orientation == "vertical" then
			line:SetPoint("TOP", relativeTo, "TOPRIGHT", offset, -lineShrink);
			line:SetPoint("BOTTOM", relativeTo, "BOTTOMRIGHT", offset, lineShrink);
			line:SetWidth(PixelUtil.ConvertPixelsToUIForRegion(1, line));
		else
			line:SetPoint("LEFT", relativeTo, "TOPLEFT", lineShrink, offset);
			line:SetPoint("RIGHT", relativeTo, "TOPRIGHT", -lineShrink, offset);
			line:SetHeight(PixelUtil.ConvertPixelsToUIForRegion(1, line));
		end
		line:SetColorTexture(0.25, 0.25, 0.25);
		line:SetTexelSnappingBias(0);
		line:SetSnapToPixelGrid(false);
	end

	if C_AddOns.IsAddOnLoaded("ElvUI") then
		CreateLine(self.CategoryList, self, "horizontal", 3, -24); -- Horizontal divider below the title, for ElvUI skinned window
	end
	CreateLine(self.CategoryList, self.CategoryList, "vertical", 6, 0); -- Vertical divider between CategoryList and SettingsList

	-- --------------------------------------------------------
	-- General options
	-- --------------------------------------------------------

	local generalOptions = {
		{
			type = "subtitle",
			label = L.TARGETING,
			subLabel = ED.Utils.CreatePriorityString(ED.Database:GetSetting("TargetPriority"), ED.Database:GetSetting("FocusTarget")),
			get = function() return ED.Utils.CreatePriorityString(ED.Database:GetSetting("TargetPriority"), ED.Database:GetSetting("FocusTarget")); end,
		},
		{
			type = "dropdown",
			label = L.TARGET_PRIORITY,
			tooltip = L.TARGET_PRIORITY_HELP,
			values = {
				[1] = L.TARGET_PRIORITY_PRIORITIZE_MOUSEOVER,
				[2] = L.TARGET_PRIORITY_PRIORITIZE_TARGET,
				[3] = L.TARGET_PRIORITY_MOUSEOVER_ONLY,
				[4] = L.TARGET_PRIORITY_TARGET_ONLY,
				[5] = L.TARGET_PRIORITY_FOCUS_ONLY,
			},
			sorting = { 1, 2, 3, 4, 5 },
			get = function() return ED.Database:GetSetting("TargetPriority"); end,
			set = function(val)
				ED.Database:SetSetting("TargetPriority", val);
				ED.Magnifier:HandleUpdate(ED.Enums.MAGNIFIER_REASON.SETTINGS);
			end,
		},
		{
			type = "checkbox",
			label = L.INCLUDE_COMPANIONS,
			tooltip = L.INCLUDE_COMPANIONS_HELP,
			get = function() return ED.Database:GetSetting("CompanionSupport"); end,
			set = function(val)
				ED.Database:SetSetting("CompanionSupport", val);
				ED.Frame:RefreshChat();
			end,
		},
		{
			type = "dropdown",
			label = L.FOCUS,
			tooltip = L.FOCUS_HELP,
			values = {
				[1] = L.FOCUS_OVERRIDE,
				[2] = L.FOCUS_FALLBACK,
				[3] = L.FOCUS_IGNORE,
			},
			sorting = { 1, 2, 3 },
			disabled = function() return not (ED.Database:GetSetting("TargetPriority") == 1 or ED.Database:GetSetting("TargetPriority") == 2); end,
			get = function() return ED.Database:GetSetting("FocusTarget"); end,
			set = function(val)
				ED.Database:SetSetting("FocusTarget", val);
				ED.Magnifier:HandleUpdate(ED.Enums.MAGNIFIER_REASON.SETTINGS);
			end,
		},
		{
			type = "subtitle",
			label = L.MESSAGES,
			subLabel = L.MESSAGES_HELP,
		},
		{
			type = "slider",
			label = L.HISTORY_SIZE,
			tooltip = L.HISTORY_SIZE_HELP,
			min = 10,
			max = 300,
			step = 1,
			get = function() return ED.Database:GetSetting("MaxHistory"); end,
			set = function(val)
				ED.Database:SetSetting("MaxHistory", val);
				ED.Frame:RefreshChat();
			end,
		},
		{
			type = "dropdown",
			label = L.NAME_DISPLAY_MODE,
			tooltip = L.NAME_DISPLAY_MODE_HELP,
			values = {
				[1] = L.NAME_DISPLAY_MODE_FULL_NAME,
				[2] = L.NAME_DISPLAY_MODE_FIRST_NAME,
				[3] = L.NAME_DISPLAY_MODE_ORIGINAL_NAME,
			},
			sorting = { 1, 2, 3 },
			disabled = function() return not ED.MSP.IsEnabled(); end,
			disabledValues = function()
				return {
					[1] = not ED.MSP.IsEnabled(),
					[2] = not ED.MSP.IsEnabled(),
				};
			end,
			get = function() return ED.Database:GetSetting("NameDisplayMode"); end,
			set = function(val)
				ED.Database:SetSetting("NameDisplayMode", val);
				ED.Frame:RefreshChat();
			end,
		},
		{
			type = "checkbox",
			label = L.USE_RP_NAME_COLOR,
			tooltip = L.USE_RP_NAME_COLOR_HELP,
			disabled = function() return ED.Database:GetSetting("NameDisplayMode") == 3; end,
			get = function() return ED.Database:GetSetting("UseRPNameColor"); end,
			set = function(val)
				ED.Database:SetSetting("UseRPNameColor", val);
				ED.Frame:RefreshChat();
			end,
		},
		{
			type = "checkbox",
			label = L.TIMESTAMP_BRACKETS,
			tooltip = L.TIMESTAMP_BRACKETS_HELP,
			get = function() return ED.Database:GetSetting("TimestampBrackets"); end,
			set = function(val)
				ED.Database:SetSetting("TimestampBrackets", val);
				ED.Frame:RefreshChat();
			end,
		},
		{
			type = "subtitle",
			label = L.ADVANCED_FORMATTING,
		},
		{
			type = "checkbox",
			label = L.APPLY_ON_MAIN_CHAT,
			tooltip = L.APPLY_ON_MAIN_CHAT_HELP,
			get = function() return ED.Database:GetSetting("ApplyOnMainChat"); end,
			set = function(val)
				ED.Database:SetSetting("ApplyOnMainChat", val);
				ED.MainChat:ToggleAdvancedFormatting();
			end,
		},
		{
			type = "checkbox",
			label = L.USE_RP_NAME_FOR_TARGETS,
			tooltip = L.USE_RP_NAME_FOR_TARGETS_HELP,
			disabled = function() return ED.Database:GetSetting("NameDisplayMode") == 3; end,
			get = function() return ED.Database:GetSetting("UseRPNameForTargets"); end,
			set = function(val)
				ED.Database:SetSetting("UseRPNameForTargets", val);
				ED.Frame:RefreshChat();
			end,
		},
		{
			type = "checkbox",
			label = L.USE_RP_NAME_IN_ROLLS,
			tooltip = L.USE_RP_NAME_IN_ROLLS_HELP,
			disabled = function() return ED.Database:GetSetting("NameDisplayMode") == 3; end,
			get = function() return ED.Database:GetSetting("UseRPNameInRolls"); end,
			set = function(val)
				ED.Database:SetSetting("UseRPNameInRolls", val);
				ED.Frame:RefreshChat();
			end,
		},--[[ Decide on if we make this a separate category
		{
			type = "subtitle",
			label = L.NPC_DIALOGUE_AND_QUEST_TEXT,
			subLabel = L.NPC_DIALOGUE_AND_QUEST_TEXT_HELP,
		},]]
		{
			type = "dropdown",
			label = L.NPC_AND_QUEST_NAME_DISPLAY,
			tooltip = L.NPC_AND_QUEST_NAME_DISPLAY_HELP,
			values = {
				[1] = L.NAME_DISPLAY_MODE_FULL_NAME,
				[2] = L.NAME_DISPLAY_MODE_FIRST_NAME,
				[3] = L.NAME_DISPLAY_MODE_ORIGINAL_NAME,
			},
			sorting = { 1, 2, 3 },
			disabled = function() return not ED.MSP.IsEnabled() end,
			disabledValues = function()
				return {
					[1] = not ED.MSP.IsEnabled(),
					[2] = not ED.MSP.IsEnabled(),
				};
			end,
			buildAdded = "0.3.0-0.4.0|120001",
			get = function() return ED.Database:GetSetting("NPCAndQuestNameDisplayMode"); end,
			set = function(val)
				ED.Database:SetSetting("NPCAndQuestNameDisplayMode", val);
				ED.QuestText.RefreshPlayerPreferredName();
			end,
		},
		{
			type = "checkbox",
			label = L.USE_RP_NAME_FOR_QUEST_TEXT,
			tooltip = L.USE_RP_NAME_FOR_QUEST_TEXT_HELP,
			buildAdded = "0.3.0-0.4.0|120001",
			disabled = function() return not ED.QuestText.SupportedAddonsInstalled() or ED.Database:GetSetting("NPCAndQuestNameDisplayMode") == 3; end,
			get = function() return ED.Database:GetSetting("UseRPNameInQuestText"); end,
			set = function(val)
				ED.Database:SetSetting("UseRPNameInQuestText", val);
			end,
		},
		{
			type = "checkbox",
			label = L.USE_RP_NAME_FOR_NPC_DIALOGUE,
			tooltip = L.USE_RP_NAME_FOR_NPC_DIALOGUE_HELP,
			buildAdded = "0.3.0-0.4.0|120001",
			disabled = function() return ED.Database:GetSetting("NPCAndQuestNameDisplayMode") == 3; end,
			get = function() return ED.Database:GetSetting("UseRPNameInNPCDialogue"); end,
			set = function(val)
				ED.Database:SetSetting("UseRPNameInNPCDialogue", val);
			end,
		},
		{
			type = "subtitle",
			label = L.DISPLAY,
		},
		{
			type = "colorswatch",
			label = L.THEMES_BACKGROUND_COLOR,
			tooltip = L.THEMES_BACKGROUND_COLOR_HELP,
			opacity = true,
			get = function()
				local color = ED.Database:GetSetting("ColorBackground");
				if type(color) ~= "table" then
					return { r = 0, g = 0, b = 0, a = 0.5 };
				end
				return color;
			end,
			set = function(val)
				if type(val) ~= "table" then return; end

				local background = ED.Frame.Background;
				if not background then return; end

				background:SetColorTexture(val.r, val.g, val.b, val.a);

				ED.DedicatedFrame:ForEachFrame(function(frame)
					local frameBg = frame.Background;
					if not frameBg then return; end
					frameBg:SetColorTexture(val.r, val.g, val.b, val.a);
				end);

				if val.r == 0 and val.g == 0 and val.b == 0 and val.a == 0.5 then
					ED.Database:SetSetting("ColorBackground", nil);
					return;
				end

				ED.Database:SetSetting("ColorBackground", { r = val.r, g = val.g, b = val.b, a = val.a });
			end,
		},
		{
			type = "colorswatch",
			label = L.THEMES_TITLEBAR_COLOR,
			tooltip = L.THEMES_TITLEBAR_COLOR_HELP,
			opacity = true,
			get = function()
				local color = ED.Database:GetSetting("ColorTitleBar");
				if type(color) ~= "table" then
					return { r = 0, g = 0, b = 0, a = 0.25 };
				end
				return color;
			end,
			set = function(val)
				if type(val) ~= "table" then return; end

				local background = ED.Frame.TitleBar.Background;
				if not background then return; end

				background:SetColorTexture(val.r, val.g, val.b, val.a);

				ED.DedicatedFrame:ForEachFrame(function(frame)
					local frameTitleBg = frame.TitleBar.Background;
					if not frameTitleBg then return; end
					frameTitleBg:SetColorTexture(val.r, val.g, val.b, val.a);
				end);

				if val.r == 0 and val.g == 0 and val.b == 0 and val.a == 0.25 then
					ED.Database:SetSetting("ColorTitleBar", nil);
					return;
				end

				ED.Database:SetSetting("ColorTitleBar", { r = val.r, g = val.g, b = val.b, a = val.a });
			end,
		},
		{
			type = "checkbox",
			label = L.THEMES_SETTINGS_ELVUI,
			tooltip = L.THEMES_SETTINGS_ELVUI_HELP,
			disabled = function() return not C_AddOns.IsAddOnLoaded("ElvUI"); end,
			get = function() return ED.Database:GetSetting("ElvUITheme"); end,
			set = function(val)
				ED.Database:SetSetting("ElvUITheme", val);
				ReloadUI();
			end,
		},
		{
			type = "checkbox",
			label = L.HIDE_IN_COMBAT,
			tooltip = L.HIDE_IN_COMBAT_HELP,
			get = function() return ED.Database:GetSetting("HideInCombat"); end,
			set = function(val)
				ED.Database:SetSetting("HideInCombat", val);
				if InCombatLockdown() then
					ED.Frame:Hide();
					ED.DedicatedFrame:ForEachFrame(function(frame)
						frame:Hide();
					end);
				end
			end,
		},
		{
			type = "checkbox",
			label = L.HIDE_WHEN_EMPTY,
			tooltip = L.HIDE_WHEN_EMPTY_HELP,
			get = function() return ED.Database:GetSetting("HideWhenEmpty"); end,
			set = function(val)
				ED.Database:SetSetting("HideWhenEmpty", val);
				-- If users turn this off, we can assume they want the frame to be visible.
				if not val then
					ED.Database:SetCharSetting("WindowVisible", true);
				end
			end,
		},
		{
			type = "checkbox",
			label = L.HIDE_CLOSE_BUTTON,
			tooltip = L.HIDE_CLOSE_BUTTON_HELP,
			get = function() return ED.Database:GetSetting("HideCloseButton"); end,
			set = function(val)
				ED.Database:SetSetting("HideCloseButton", val);
				ED.Frame.TitleBar.CloseButton:SetShown(not val);
			end,
		},
		{
			type = "checkbox",
			label = L.TITLE_BAR_TARGET_NAME,
			tooltip = L.TITLE_BAR_TARGET_NAME_HELP,
			get = function() return ED.Database:GetSetting("UpdateTitleBarWithName"); end,
			set = function(val)
				ED.Database:SetSetting("UpdateTitleBarWithName", val);
				ED.Frame:RefreshChat();
			end,
		},
		{
			type = "checkbox",
			label = L.WELCOME_MSG .. "*",
			tooltip = L.WELCOME_MSG_HELP,
			get = function() return ED.Database:GetGlobalSetting("WelcomeMessage"); end,
			set = function(val)
				ED.Database:SetGlobalSetting("WelcomeMessage", val);
			end,
		},
		{
			type = "subtitle",
			label = L.FONT,
		},
		{
			type = "dropdown",
			label = L.FONT_FACE,
			tooltip = L.FONT_FACE_HELP,
			values = fontList,
			get = function() return ED.Database:GetSetting("FontFace"); end,
			set = function(val)
				ED.Database:SetSetting("FontFace", val);
				ED.ChatBox:ApplyFontOptions(ED.Frame);
				ED.DedicatedFrame:ForEachFrame(function(frame)
					ED.ChatBox:ApplyFontOptions(frame);
				end);
			end,
		},
		{
			type = "slider",
			label = L.FONT_SIZE,
			tooltip = L.FONT_SIZE_HELP,
			min = 6,
			max = 24,
			step = 1,
			get = function() return ED.Database:GetSetting("FontSize"); end,
			set = function(val)
				ED.Database:SetSetting("FontSize", val);
				ED.ChatBox:ApplyFontOptions(ED.Frame);
			end,
		},
		{
			type = "dropdown",
			label = L.FONT_OUTLINE,
			tooltip = L.FONT_OUTLINE_HELP,
			values = {
				[1] = L.FONT_OUTLINE_NONE,
				[2] = L.FONT_OUTLINE_THIN,
				[3] = L.FONT_OUTLINE_THICK,
			},
			sorting = { 1, 2, 3 },
			get = function() return ED.Database:GetSetting("FontOutline"); end,
			set = function(val)
				ED.Database:SetSetting("FontOutline", val);
				ED.ChatBox:ApplyFontOptions(ED.Frame);
				ED.DedicatedFrame:ForEachFrame(function(frame)
					ED.ChatBox:ApplyFontOptions(frame);
				end);
			end,
		},
		{
			type = "checkbox",
			label = L.FONT_SHADOW,
			tooltip = L.FONT_SHADOW_HELP,
			get = function() return ED.Database:GetSetting("FontShadow"); end,
			set = function(val)
				ED.Database:SetSetting("FontShadow", val);
				ED.ChatBox:ApplyFontOptions(ED.Frame);
				ED.DedicatedFrame:ForEachFrame(function(frame)
					ED.ChatBox:ApplyFontOptions(frame);
				end);
			end,
		},
		{
			type = "subtitle",
			label = L.DEDICATED_WINDOWS,
		},
		{
			type = "checkbox",
			label = L.DEDICATED_WINDOWS .. "*",
			tooltip = L.DEDICATED_WINDOWS_HELP,
			buildAdded = "0.3.0-0.4.0|120001",
			get = function() return ED.Database:GetGlobalSetting("DedicatedWindows"); end,
			set = function(val)
				ED.Database:SetGlobalSetting("DedicatedWindows", val);
				if not val then
					ED.DedicatedFrame:ForEachFrame(function(frame)
						frame:Hide();
					end);
				end
			end,
		},
		{
			type = "checkbox",
			label = L.NEW_WINDOWS_NEW_INDICATOR .. "*",
			tooltip = L.NEW_WINDOWS_NEW_INDICATOR_HELP,
			buildAdded = "0.3.0-0.4.0|120001",
			disabled = function() return not ED.Database:GetGlobalSetting("DedicatedWindows"); end,
			get = function() return ED.Database:GetGlobalSetting("DedicatedWindowsNewIndicator"); end,
			set = function(val)
				ED.Database:SetGlobalSetting("DedicatedWindowsNewIndicator", val);
			end,
		},
		{
			type = "checkbox",
			label = L.NEW_WINDOWS_UNIT_POPUPS .. "*",
			tooltip = L.NEW_WINDOWS_UNIT_POPUPS_HELP,
			buildAdded = "0.3.0-0.4.0|120001",
			disabled = function() return not ED.Database:GetGlobalSetting("DedicatedWindows"); end,
			get = function() return ED.Database:GetGlobalSetting("DedicatedWindowsUnitPopups"); end,
			set = function(val)
				ED.Database:SetGlobalSetting("DedicatedWindowsUnitPopups", val);
			end,
		},
		{
			type = "checkbox",
			label = L.DEDICATED_WINDOWS_PERSIST .. "*",
			tooltip = L.DEDICATED_WINDOWS_PERSIST_HELP,
			buildAdded = "0.4.0|120001",
			disabled = function() return not ED.Database:GetGlobalSetting("DedicatedWindows"); end,
			get = function() return ED.Database:GetGlobalSetting("DedicatedWindowsPersist"); end,
			set = function(val)
				ED.Database:SetGlobalSetting("DedicatedWindowsPersist", val);
			end,
		},
		{
			type = "subtitle",
			label = L.GROUP_WINDOWS,
		},
		{
			type = "checkbox",
			label = L.GROUP_WINDOWS .. "*",
			tooltip = L.GROUP_WINDOWS_HELP,
			buildAdded = "0.4.0|120001",
			get = function() return ED.Database:GetGlobalSetting("GroupWindows"); end,
			set = function(val)
				ED.Database:SetGlobalSetting("GroupWindows", val);
				if not val then
					ED.GroupFrame:ForEachFrame(function(frame)
						frame:Hide();
					end);
				end
			end,
		},
		{
			type = "checkbox",
			label = L.NEW_WINDOWS_NEW_INDICATOR .. "*",
			tooltip = L.NEW_WINDOWS_NEW_INDICATOR_HELP,
			buildAdded = "0.4.0|120001",
			disabled = function() return not ED.Database:GetGlobalSetting("GroupWindows"); end,
			get = function() return ED.Database:GetGlobalSetting("GroupWindowsNewIndicator"); end,
			set = function(val)
				ED.Database:SetGlobalSetting("GroupWindowsNewIndicator", val);
			end,
		},
		{
			type = "checkbox",
			label = L.NEW_WINDOWS_UNIT_POPUPS .. "*",
			tooltip = L.NEW_WINDOWS_UNIT_POPUPS_HELP,
			buildAdded = "0.4.0|120001",
			disabled = function() return not ED.Database:GetGlobalSetting("GroupWindows"); end,
			get = function() return ED.Database:GetGlobalSetting("GroupWindowsUnitPopups"); end,
			set = function(val)
				ED.Database:SetGlobalSetting("GroupWindowsUnitPopups", val);
			end,
		},
		{
			type = "checkbox",
			label = L.GROUP_WINDOWS_PERSIST .. "*",
			tooltip = L.GROUP_WINDOWS_PERSIST_HELP,
			buildAdded = "0.4.0|120001",
			disabled = function() return not ED.Database:GetGlobalSetting("GroupWindows"); end,
			get = function() return ED.Database:GetGlobalSetting("GroupWindowsPersist"); end,
			set = function(val)
				ED.Database:SetGlobalSetting("GroupWindowsPersist", val);
			end,
		},
		{
			type = "subtitle",
			label = L.MINIMAP,
		},
		{
			type = "checkbox",
			label = L.MINIMAP_BUTTON .. "*",
			tooltip = L.MINIMAP_BUTTON_HELP,
			get = function() return not ED.Database:GetGlobalSetting("MinimapButton").Hide; end,
			set = function(val)
				local minimap = ED.Database:GetGlobalSetting("MinimapButton");
				minimap.Hide = not val;
				ED.Database:SetGlobalSetting("MinimapButton", minimap);
				ED.Minimap:UpdateMinimapButtons();
			end,
		},
		{
			type = "checkbox",
			label = L.ADDON_COMPARTMENT_BUTTON .. "*",
			tooltip = L.ADDON_COMPARTMENT_BUTTON_HELP,
			disabled = function() return ED.Database:GetGlobalSetting("MinimapButton").Hide; end,
			get = function() return ED.Database:GetGlobalSetting("MinimapButton").ShowAddonCompartmentButton; end,
			set = function(val)
				local minimap = ED.Database:GetGlobalSetting("MinimapButton");
				minimap.ShowAddonCompartmentButton = val;
				ED.Database:SetGlobalSetting("MinimapButton", minimap);
				ED.Minimap:UpdateMinimapButtons();
			end,
		},
	};

	-- --------------------------------------------------------
	-- Notifications options
	-- --------------------------------------------------------

	local notificationsOptions = {
		{
			type = "subtitle",
			label = L.EMOTES,
			subLabel = L.EMOTES_HELP,
		},
		{
			type = "checkbox",
			label = L.NOTIFICATIONS_PLAY_SOUND,
			tooltip = L.NOTIFICATIONS_PLAY_SOUND_HELP,
			get = function() return ED.Database:GetSetting("NotificationEmotesSound"); end,
			set = function(val)
				ED.Database:SetSetting("NotificationEmotesSound", val);
			end,
		},
		{
			type = "dropdown",
			label = L.NOTIFICATIONS_SOUND_FILE,
			tooltip = L.NOTIFICATIONS_SOUND_FILE_HELP,
			values = ED.Config.soundList,
			disabled = function() return not ED.Database:GetSetting("NotificationEmotesSound"); end,
			get = function() return ED.Database:GetSetting("NotificationEmotesSoundFile"); end,
			set = function(val)
				local soundPath = SharedMedia:Fetch("sound", val);
				if soundPath then
					PlaySoundFile(soundPath, "Master");
					ED.Database:SetSetting("NotificationEmotesSoundFile", val);
				end
			end,
		},
		{
			type = "checkbox",
			label = L.NOTIFICATION_FLASH_TASKBAR,
			tooltip = L.NOTIFICATION_FLASH_TASKBAR_HELP,
			get = function() return ED.Database:GetSetting("NotificationEmotesFlashTaskbar"); end,
			set = function(val)
				ED.Database:SetSetting("NotificationEmotesFlashTaskbar", val);
			end,
		},
		{
			type = "subtitle",
			label = L.TARGET,
			subLabel = L.TARGET_HELP,
		},
		{
			type = "checkbox",
			label = L.NOTIFICATIONS_PLAY_SOUND,
			tooltip = L.NOTIFICATIONS_PLAY_SOUND_HELP,
			get = function() return ED.Database:GetSetting("NotificationTargetSound"); end,
			set = function(val)
				ED.Database:SetSetting("NotificationTargetSound", val);
			end,
		},
		{
			type = "dropdown",
			label = L.NOTIFICATIONS_SOUND_FILE,
			tooltip = L.NOTIFICATIONS_SOUND_FILE_HELP,
			values = ED.Config.soundList,
			disabled = function() return not ED.Database:GetSetting("NotificationTargetSound"); end,
			get = function() return ED.Database:GetSetting("NotificationTargetSoundFile"); end,
			set = function(val)
				local soundPath = SharedMedia:Fetch("sound", val);
				if soundPath then
					PlaySoundFile(soundPath, "Master");
					ED.Database:SetSetting("NotificationTargetSoundFile", val);
				end
			end,
		},
		{
			type = "checkbox",
			label = L.NOTIFICATION_FLASH_TASKBAR,
			tooltip = L.NOTIFICATION_FLASH_TASKBAR_HELP,
			get = function() return ED.Database:GetSetting("NotificationTargetFlashTaskbar"); end,
			set = function(val)
				ED.Database:SetSetting("NotificationTargetFlashTaskbar", val);
			end,
		},
		{
			type = "subtitle",
			label = L.DEDICATED,
			subLabel = L.DEDICATED_HELP,
		},
		{
			type = "checkbox",
			label = L.NOTIFICATIONS_PLAY_SOUND,
			tooltip = L.NOTIFICATIONS_PLAY_SOUND_HELP,
			buildAdded = "0.3.0-0.4.0|120001",
			get = function() return ED.Database:GetSetting("NotificationDedicatedSound"); end,
			set = function(val)
				ED.Database:SetSetting("NotificationDedicatedSound", val);
			end,
		},
		{
			type = "dropdown",
			label = L.NOTIFICATIONS_SOUND_FILE,
			tooltip = L.NOTIFICATIONS_SOUND_FILE_HELP,
			buildAdded = "0.3.0-0.4.0|120001",
			values = ED.Config.soundList,
			disabled = function() return not ED.Database:GetSetting("NotificationDedicatedSound"); end,
			get = function() return ED.Database:GetSetting("NotificationDedicatedSoundFile"); end,
			set = function(val)
				local soundPath = SharedMedia:Fetch("sound", val);
				if soundPath then
					PlaySoundFile(soundPath, "Master");
					ED.Database:SetSetting("NotificationDedicatedSoundFile", val);
				end
			end,
		},
		{
			type = "checkbox",
			label = L.NOTIFICATION_FLASH_TASKBAR,
			tooltip = L.NOTIFICATION_FLASH_TASKBAR_HELP,
			buildAdded = "0.3.0-0.4.0|120001",
			get = function() return ED.Database:GetSetting("NotificationDedicatedFlashTaskbar"); end,
			set = function(val)
				ED.Database:SetSetting("NotificationDedicatedFlashTaskbar", val);
			end,
		},
		{
			type = "subtitle",
			label = L.GROUP,
			subLabel = L.GROUP_HELP,
		},
		{
			type = "checkbox",
			label = L.NOTIFICATIONS_PLAY_SOUND,
			tooltip = L.NOTIFICATIONS_PLAY_SOUND_HELP,
			buildAdded = "0.4.0|120001",
			get = function() return ED.Database:GetSetting("NotificationGroupSound"); end,
			set = function(val)
				ED.Database:SetSetting("NotificationGroupSound", val);
			end,
		},
		{
			type = "dropdown",
			label = L.NOTIFICATIONS_SOUND_FILE,
			tooltip = L.NOTIFICATIONS_SOUND_FILE_HELP,
			buildAdded = "0.4.0|120001",
			values = ED.Config.soundList,
			disabled = function() return not ED.Database:GetSetting("NotificationGroupSound"); end,
			get = function() return ED.Database:GetSetting("NotificationGroupSoundFile"); end,
			set = function(val)
				local soundPath = SharedMedia:Fetch("sound", val);
				if soundPath then
					PlaySoundFile(soundPath, "Master");
					ED.Database:SetSetting("NotificationGroupSoundFile", val);
				end
			end,
		},
		{
			type = "checkbox",
			label = L.NOTIFICATION_FLASH_TASKBAR,
			tooltip = L.NOTIFICATION_FLASH_TASKBAR_HELP,
			buildAdded = "0.4.0|120001",
			get = function() return ED.Database:GetSetting("NotificationGroupFlashTaskbar"); end,
			set = function(val)
				ED.Database:SetSetting("NotificationGroupFlashTaskbar", val);
			end,
		},
	};

	-- --------------------------------------------------------
	-- Keywords options
	-- --------------------------------------------------------

	local keywordsOptions = {
		{
			type = "subtitle",
			label = L.KEYWORDS_TITLE,
			subLabel = L.KEYWORDS_HELP,
		},
		{
			type = "checkbox",
			label = L.KEYWORDS_ENABLE,
			tooltip = L.KEYWORDS_ENABLE_HELP,
			get = function() return ED.Database:GetSetting("EnableKeywords"); end,
			set = function(val)
				ED.Database:SetSetting("EnableKeywords", val);
				ED.MainChat:ToggleKeywords();
			end,
		},
		{
			type = "editbox_multiline",
			label = L.KEYWORDS_LIST,
			tooltip = L.KEYWORDS_LIST_HELP,
			height = 100,
			get = function() return ED.Database:GetSetting("HighlightKeywords"); end,
			set = function(val)
				ED.Database:SetSetting("HighlightKeywords", val);
				ED.Keywords:ParseList();
			end,
		},
		{
			type = "colorswatch",
			label = L.KEYWORDS_HIGHLIGHT_COLOR,
			tooltip = L.KEYWORDS_HIGHLIGHT_COLOR_HELP,
			get = function()
				local color = ED.Database:GetSetting("HighlightColor");
				if type(color) ~= "table" then
					return { r = 0, g = 1, b = 0 };
				end
				return color;
			end,
			set = function(val)
				ED.Database:SetSetting("HighlightColor", val);
			end,
		},
		{
			type = "checkbox",
			label = L.KEYWORDS_ENABLE_PARTIAL_MATCHING,
			tooltip = L.KEYWORDS_ENABLE_PARTIAL_MATCHING_HELP,
			get = function() return ED.Database:GetSetting("EnablePartialKeywords"); end,
			set = function(val)
				ED.Database:SetSetting("EnablePartialKeywords", val);
			end,
		},
		{
			type = "subtitle",
			label = L.NOTIFICATIONS_TITLE,
			subLabel = L.KEYWORDS_NOTIFICATIONS_HELP,
		},
		{
			type = "checkbox",
			label = L.NOTIFICATIONS_PLAY_SOUND,
			tooltip = L.NOTIFICATIONS_PLAY_SOUND_HELP,
			get = function() return ED.Database:GetSetting("NotificationKeywordsSound"); end,
			set = function(val)
				ED.Database:SetSetting("NotificationKeywordsSound", val);
			end,
		},
		{
			type = "dropdown",
			label = L.NOTIFICATIONS_SOUND_FILE,
			tooltip = L.NOTIFICATIONS_SOUND_FILE_HELP,
			values = ED.Config.soundList,
			disabled = function() return not ED.Database:GetSetting("NotificationKeywordsSound"); end,
			get = function() return ED.Database:GetSetting("NotificationKeywordsSoundFile"); end,
			set = function(val)
				local soundPath = SharedMedia:Fetch("sound", val);
				if soundPath then
					PlaySoundFile(soundPath, "Master");
					ED.Database:SetSetting("NotificationKeywordsSoundFile", val);
				end
			end,
		},
		{
			type = "checkbox",
			label = L.NOTIFICATION_FLASH_TASKBAR,
			tooltip = L.NOTIFICATION_FLASH_TASKBAR_HELP,
			get = function() return ED.Database:GetSetting("NotificationKeywordsFlashTaskbar"); end,
			set = function(val)
				ED.Database:SetSetting("NotificationKeywordsFlashTaskbar", val);
			end,
		},
	};

	-- --------------------------------------------------------
	-- Profiles options
	-- --------------------------------------------------------

	local profilesOptions = {
		{
			type = "subtitle",
			label = L.PROFILES_TITLE,
		},
		{
			type = "dropdown",
			label = L.PROFILES_CURRENTPROFILE,
			tooltip = L.PROFILES_CURRENTPROFILE_HELP,
			gearButton = true,
			values = function() return ED.Database:GetAllProfiles(); end,
			get = function() return ED.Database:GetProfileName(); end,
			set = function(val)
				ED.Database:SetProfile(val);
			end,
		},
		{
			type = "editbox",
			label = L.PROFILES_NEWPROFILE,
			tooltip = L.PROFILES_NEWPROFILE_HELP,
			get = function() end,
			set = function(val)
				ED.ConfirmDialog:Show(L.PROFILES_CONFIRM_NEWPROFILE:format(val), function()
					ED.Database:CreateProfile(val);
				end);
			end,
		},
		{
			type = "dropdown",
			label = L.PROFILES_COPYFROM,
			tooltip = L.PROFILES_COPYFROM_HELP,
			style = "button",
			values = function() return ED.Database:GetAllProfiles(true, false); end,
			get = function() end,
			set = function(val)
				ED.ConfirmDialog:Show(L.PROFILES_CONFIRM_COPYFROM:format(val), function()
					ED.Database:CopyProfile(val);
				end);
			end,
		},
		{
			type = "button",
			label = L.PROFILES_RESETBUTTON,
			tooltip = L.PROFILES_RESETBUTTON_HELP,
			func = function()
				ED.ConfirmDialog:Show(L.PROFILES_CONFIRM_RESET, function()
					ED.Database:ResetProfile();
					self:RefreshWidgets();
				end);
			end,
		},
		{
			type = "dropdown",
			label = L.PROFILES_DELETEPROFILE,
			tooltip = L.PROFILES_DELETEPROFILE_HELP,
			style = "button",
			values = function() return ED.Database:GetAllProfiles(true, true); end,
			get = function() end,
			set = function(val)
				ED.ConfirmDialog:Show(L.PROFILES_CONFIRM_DELETE:format(val), function()
					ED.Database:DeleteProfile(val);
				end);
			end,
		},
	};

	-- --------------------------------------------------------
	-- Populate & finalise
	-- --------------------------------------------------------

	self:CreateCategory(L.GENERAL_TITLE, true, generalOptions);
	self:CreateCategory(L.KEYWORDS_TITLE, true, keywordsOptions);
	self:CreateCategory(L.NOTIFICATIONS_TITLE, true, notificationsOptions);
	self:CreateCategory(L.PROFILES_TITLE, false, profilesOptions);

	local version = ED.Globals.addon_version;
	local versionTextColor = ED.Utils.ValidateLatestBuild() and "COMMON_GRAY_COLOR" or "WARNING_FONT_COLOR";
	if version == "@project-version@" then
		version = "Dev"; -- Show "Dev" for internal build
	end
	local aboutPanel, aboutCategoryListButton = self:CreateCategory(string.format("%s  |cn%s:%s|r", L.ABOUT_TITLE, versionTextColor, version), false, nil, true);

	aboutCategoryListButton:SetScript("OnEnter", function(button)
		button:UpdateVisual();

		GameTooltip:SetOwner(button, "ANCHOR_RIGHT");
		GameTooltip:AddDoubleLine(L.ADDONINFO_VERSION:format(version), L.ADDONINFO_BUILD:format(ED.Utils.OutputBuild(true)), 1, 1, 1, 1, 1, 1);

		if ED.Utils.ValidateLatestBuild() then
			GameTooltip:AddLine(L.ADDONINFO_BUILD_CURRENT, 1, 1, 1, true);
		else
			GameTooltip:AddLine(L.ADDONINFO_BUILD_OUTDATED, 1, 1, 1, true);
		end

		GameTooltip:Show();
	end);

	aboutCategoryListButton:SetScript("OnLeave", function(button)
		button:UpdateVisual();
		GameTooltip:Hide();
	end);

	aboutPanel:SetScript("OnShow", function()
		-- Create ChangelogFrame after clicking About
		aboutPanel:SetScript("OnShow", nil);
		ED.Changelogs:CreateChangelogFrame(aboutPanel);
	end);

	local infoFrame = SettingsElements.CreateDeveloperInfoFrame(aboutPanel);
	infoFrame:SetPoint("TOPLEFT", aboutPanel, "TOPLEFT", 12, -8);
	infoFrame:SetPoint("TOPRIGHT", aboutPanel, "TOPRIGHT", -12, -8);
	CreateLine(infoFrame, infoFrame, "horizontal", -12, -34);

	-- ReIndex Categories
	local function SortFunc(a, b)
		if a.addToBottom == b.addToBottom then
			if a.addToBottom then
				return a.categoryIndex > b.categoryIndex;
			else
				return a.categoryIndex < b.categoryIndex;
			end
		elseif a.addToBottom then
			return false;
		else
			return true;
		end
	end

	table.sort(self.Views, SortFunc);

	for i, panel in ipairs(self.Views) do
		panel.categoryIndex = i;
		panel.categoryListBtton.tabIndex = i;
	end

	-- Adjust category list and button width so that the category label is always shown in full in one line
	-- If the category list becomes wider, the right section, SettingsList width will not be affected. The entire frame will become wider.
	local labelPaddingLeft = Constants.SETTINGS.CATEGORY_BUTTON_TEXT_OFFSET;
	local labelPaddingRight = Constants.SETTINGS.CATEGORY_BUTTON_TEXT_RIGHT_PADDING;
	local maxLabelWidth = Constants.SETTINGS.CATEGORY_BUTTON_TEXT_MIN_WIDTH;

	for _, button in ipairs(self.CategoryListButtons) do
		local labelWidth = button.Text:GetWidth();
		if labelWidth > maxLabelWidth then
			maxLabelWidth = labelWidth;
		end
	end

	local categoryButtonWidth = math.ceil(labelPaddingLeft + maxLabelWidth + labelPaddingRight); -- Fit to the longest word
	self.CategoryList:SetWidth(categoryButtonWidth);
	for _, button in ipairs(self.CategoryListButtons) do
		button.Text:ClearAllPoints();
		button.Text:SetPoint("LEFT", button, "LEFT", labelPaddingLeft, 1);
		button:SetWidth(categoryButtonWidth);
	end

	local frameWidth = categoryButtonWidth + Constants.SETTINGS.SETTINGS_LIST_WIDTH;
	local frameHeight = Constants.SETTINGS.FRAME_HEIGHT;
	self:SetSize(frameWidth, frameHeight);

	ED.ElvUI.RegisterSkinnableElement(self, "frame");
end

-- ============================================================
-- Drag
-- ============================================================

function Eavesdropper_SettingsMixin:OnDragStart()
	self:StartMoving();
end

function Eavesdropper_SettingsMixin:OnDragStop()
	self:StopMovingOrSizing();

	if not ED.Database then return; end

	local point, _, relativePoint, x, y = self:GetPoint(1);
	ED.Database:SetGlobalSetting("SettingsWindowPosition", { point = point, relativePoint = relativePoint, x = x, y = y });
end

-- ============================================================
-- OnShow / OnHide
-- ============================================================

function Eavesdropper_SettingsMixin:OnShow()
	ED.Frame.settingsOpened = true;
	ED.Frame:HandleVisibility();
	ED.ElvUI.SkinRegisteredElements();
	local tabToShow = lastSelectedTab or 1;
	self:SetTab(tabToShow);
	self:RefreshWidgets()
end

function Eavesdropper_SettingsMixin:OnHide()
	ED.Frame.settingsOpened = false;
	ED.Frame:HandleVisibility();

	if self.SetAlphaChannelMode then
		self:SetAlphaChannelMode(nil);
	end
end

-- ============================================================
-- Screenshot Helper
-- ============================================================

function Eavesdropper_SettingsMixin:SetAlphaChannelMode(mode)
	-- mode 1: All Widgets turn black + white fullscreen backdrop
	-- mode 2: Widgets use original colors + black fullscreen backdrop
	-- other : Disable

	local showFullScreenBackdrop = mode == 1 or mode == 2;
	local enableColorizing = mode == 1;
	local a = mode == 1 and 0 or 1;

	local function SetupFunc(object)
		if object:IsObjectType("FontString") then
			if enableColorizing then
				if not object.originalColor then
					local r, g, b = object:GetTextColor();
					object.originalColor = {r = r, g = g, b = b};
				end
				object:SetTextColor(a, a, a);
				object:SetFixedColor(true);
			else
				if object.originalColor then
					local color = object.originalColor;
					object:SetTextColor(color.r, color.g, color.b);
					object.originalColor = nil;
				end
				object:SetFixedColor(false);
			end
		elseif object:IsObjectType("Texture") then
			if enableColorizing then
				if not object.originalColor then
					local r, g, b = object:GetVertexColor();
					object.originalColor = {r = r, g = g, b = b};
				end
				object:SetVertexColor(a, a, a);
			else
				if object.originalColor then
					local color = object.originalColor;
					object:SetVertexColor(color.r, color.g, color.b);
					object.originalColor = nil;
				end
			end
		end

		if object.GetRegions then
			for _, region in ipairs({object:GetRegions()}) do
				SetupFunc(region);
			end
		end

		if object.GetChildren then
			for _, child in ipairs({object:GetChildren()}) do
				SetupFunc(child);
			end
		end
	end

	SetupFunc(self);
	SetupFunc(GameTooltip);

	self.Background.BackgroundColor:SetVertexColor(1, 1, 1);

	if enableColorizing then
		self.NineSlice.Text:SetText(nil);
	else
		self.NineSlice.Text:SetText(ED.Globals.addon_settings_icon .. " " .. ED.Globals.addon_title .. " " .. SETTINGS);
	end

	if showFullScreenBackdrop then
		if not self.fullscreenBackdrop then
			self.fullscreenBackdrop = self:CreateTexture(nil, "BACKGROUND", nil, -8);
			self.fullscreenBackdrop:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 0, 0);
			self.fullscreenBackdrop:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", 0, 0);
		end
		self.fullscreenBackdrop:Show();
		self.fullscreenBackdrop:SetVertexColor(1, 1, 1);
		if mode == 1 then
			self.fullscreenBackdrop:SetColorTexture(1, 1, 1);
			self.Background.BackgroundColor:SetColorTexture(0, 0, 0, 0.95);
		else
			self.fullscreenBackdrop:SetColorTexture(0, 0, 0);
			self.Background.BackgroundColor:SetColorTexture(0.12, 0.12, 0.12, 1);
		end
	else
		self.Background.BackgroundColor:SetColorTexture(0.12, 0.12, 0.12, 0.95);
		if self.fullscreenBackdrop then
			self.fullscreenBackdrop:Hide();
		end
	end
end

-- ============================================================
-- Category list button
-- ============================================================

Eavesdropper_SettingsCategoryListButtonMixin = {};

function Eavesdropper_SettingsCategoryListButtonMixin:OnEnter()
	self:UpdateVisual();
end

function Eavesdropper_SettingsCategoryListButtonMixin:OnLeave()
	self:UpdateVisual();
end

function Eavesdropper_SettingsCategoryListButtonMixin:OnClick()
	ED.SettingsFrame:SetTab(self.tabIndex);
end

function Eavesdropper_SettingsCategoryListButtonMixin:SetText(text)
	self.Text:SetText(text);
end

function Eavesdropper_SettingsCategoryListButtonMixin:SetSelected(isSelected)
	self.isSelected = isSelected;
	self:UpdateVisual();
end

function Eavesdropper_SettingsCategoryListButtonMixin:UpdateVisual()
	if self.isSelected or self:IsMouseMotionFocus() then
		self.Text:SetTextColor(1, 1, 1);
		if self.isSelected then
			self.Texture:SetAtlas("Options_List_Active");
		else
			self.Texture:SetAtlas("Options_List_Hover");
		end
	else
		self.Text:SetTextColor(1, 0.82, 0);
		self.Texture:SetTexture(nil);
	end
end

-- ============================================================
-- Settings module
-- ============================================================

---@param view number? Optional tab index, defaults to 1.
function Settings:ShowSettings(view)
	if not ED.SettingsFrame then
		Settings:Init();
	end

	ED.SettingsFrame:SetShown(not ED.SettingsFrame:IsShown());
	ED.SettingsFrame:Raise();

	if view then
		ED.SettingsFrame:SetTab(view);
	end
end

function Settings:Init()
	local frame = CreateFrame("Frame", "Eavesdropper_Settings", UIParent, "Eavesdropper_SettingsMenuTemplate");
	ED.SettingsFrame = frame;
end

ED.Settings = Settings;
