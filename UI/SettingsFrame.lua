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
function Eavesdropper_SettingsMixin:RefreshWidgets()
	for _, widget in pairs(allWidgets) do
		if widget.Refresh then
			widget:Refresh();
		end
	end
end

function Eavesdropper_SettingsMixin:AddTab()
	local tabs = self.Tabs;
	local tab = CreateFrame("Button", nil, self, "Eavesdropper_SettingsMenuTabTopTemplate");

	if tIndexOf(tabs, tab) == nil then
		table.insert(tabs, tab);
	end

	local tabCount = #tabs;
	if tabCount > 1 then
		tab:SetPoint("TOPLEFT", tabs[tabCount - 1], "TOPRIGHT", 5, 0);
	else
		tab:SetPoint("TOPLEFT", 10, -20);
	end
	local tabIndex = tabCount;

	local function OnShow(tabButton)
		PanelTemplates_TabResize(tabButton, 15, nil, 65);
		PanelTemplates_DeselectTab(tabButton);
	end

	local function OnClick()
		self:SetTab(tabIndex);
	end

	tab:SetScript("OnShow", OnShow);
	tab:SetScript("OnClick", OnClick);

	ED.ElvUI.RegisterSkinnableElement(tab, "toptabbutton");

	return tab;
end

function Eavesdropper_SettingsMixin:SetTab(index)
	for i, panel in ipairs(self.Views) do
		local isSelected = (i == index);
		panel:SetShown(isSelected);

		local scroll = panel.scrollFrame;
		if scroll then
			scroll:SetShown(isSelected);
			if scroll.ScrollBar then
				scroll.ScrollBar:SetShown(isSelected);
			end
		end
	end

	PanelTemplates_SetTab(self, index);
	self.selectedTab = index;
	lastSelectedTab = index;
end

function Eavesdropper_SettingsMixin:AddFrame()
	local frame = CreateFrame("Frame", nil, self);
	frame:SetPoint("TOP", 0, -65);
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
	local frame = CreateFrame("Frame", nil, self);
	frame:SetPoint("TOP", 0, -65);
	frame:SetPoint("LEFT");
	frame:SetPoint("RIGHT");
	frame:SetPoint("BOTTOM");

	local paddingLeft, paddingRight, paddingTop, paddingBottom = 0, 25, 0, 16;

	local scrollFrame = CreateFrame("ScrollFrame", nil, frame, "ScrollFrameTemplate");
	scrollFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", paddingLeft, -paddingTop);
	scrollFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -paddingRight, paddingBottom);

	-- Create scroll child to hold content
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

function Eavesdropper_SettingsMixin:PopulateTab(tab, options)
	local previousContainer = nil;
	for _, data in ipairs(options) do
		local container, widget;
		local padding = -Constants.SETTINGS.PADDING_HEIGHT;

		if data.type == "subtitle" then
			container = SettingsElements.CreateSubTitle(tab, data.label, data.subLabel);
			widget = nil;
			padding = -Constants.SETTINGS.PADDING_HEIGHT_TITLE;
		elseif data.type == "description" then
			container = SettingsElements.CreateDescription(tab, data.label);
			widget = nil;
		else
			container, widget = SettingsElements.CreateElement(tab, data);
		end

		if data.type == "editbox_multiline" then
			padding = Constants.SETTINGS.PADDING_MULTILINE_EDITBOX;
		end

		if previousContainer then
			container:SetPoint("TOP", previousContainer, "BOTTOM", 0, padding);
		else
			container:SetPoint("TOP", tab, "TOP", 0, -5);
		end

		if widget then
			local key = widget.settingKey or (#allWidgets + 1);
			allWidgets[key] = widget;
		end

		previousContainer = container;
	end

	return previousContainer;
end

function Eavesdropper_SettingsMixin:OnLoad()
	ButtonFrameTemplate_HidePortrait(self);
	ButtonFrameTemplate_HideButtonBar(self);
	tinsert(UISpecialFrames, self:GetName());
	self.Inset:Hide();
	self.Tabs = {};
	self.Views = {};

	self:SetTitle(ED.Globals.addon_settings_icon .. " " .. ED.Globals.addon_title .. " " .. MAIN_MENU);

	self.CloseButton:SetScript("OnClick", function()
		self:Hide();
	end)

	local pos = ED.Database:GetGlobalSetting("SettingsWindowPosition");
	if pos then
		self:ClearAllPoints();
		self:SetPoint(pos.point, UIParent, pos.relativePoint, pos.x, pos.y);
	end

	local generalTab = self:AddTab();
	generalTab:SetText(L.GENERAL_TITLE);
	local generalPanel, generalContent = self:AddScrollableFrame(); -- luacheck: no unused (generalPanel)

	local keywordsTab = self:AddTab();
	keywordsTab:SetText(L.KEYWORDS_TITLE);
	local keywordsPanel, keywordsContent = self:AddScrollableFrame(); -- luacheck: no unused (keywordsPanel)

	local notificationsTab = self:AddTab();
	notificationsTab:SetText(L.NOTIFICATIONS_TITLE);
	local notificationsPanel, notificationsContent = self:AddScrollableFrame(); -- luacheck: no unused (notificationsPanel)

	local profilesTab = self:AddTab();
	profilesTab:SetText(L.PROFILES_TITLE);
	local profilesPanel = self:AddFrame();

	PanelTemplates_SetNumTabs(self, #self.Tabs);

	local generalOptions = {
		{
			type = "subtitle",
			label = L.TARGETING,
		},
		{
			type = "dropdown",
			label = L.TARGET_PRIORITY,
			tooltip = L.TARGET_PRIORITY_HELP,
			values = {
				[1] = L.TARGET_PRIORITY_PRIORITIZE_MOUSEOVER;
				[2] = L.TARGET_PRIORITY_PRIORITIZE_TARGET;
				[3] = L.TARGET_PRIORITY_MOUSEOVER_ONLY;
				[4] = L.TARGET_PRIORITY_TARGET_ONLY;
			},
			sorting = {
				1,
				2,
				3,
				4,
			},
			get = function() return ED.Database:GetSetting("TargetPriority") end,
			set = function(val)
				ED.Database:SetSetting("TargetPriority", val);
				ED.Magnifier:HandleUpdate();
			end,
		},
		{
			type = "checkbox",
			label = L.INCLUDE_COMPANIONS,
			tooltip = L.INCLUDE_COMPANIONS_HELP,
			get = function() return ED.Database:GetSetting("CompanionSupport") end,
			set = function(val)
				ED.Database:SetSetting("CompanionSupport", val);
				ED.Frame:RefreshChat();
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
			get = function() return ED.Database:GetSetting("MaxHistory") end,
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
				[1] = L.NAME_DISPLAY_MODE_FULL_NAME;
				[2] = L.NAME_DISPLAY_MODE_FIRST_NAME;
				[3] = L.NAME_DISPLAY_MODE_ORIGINAL_NAME;
			},
			sorting = {
				1,
				2,
				3,
			},
			get = function() return ED.Database:GetSetting("NameDisplayMode") end,
			set = function(val)
				ED.Database:SetSetting("NameDisplayMode", val);
				ED.Frame:RefreshChat();
			end,
		},
		{
			type = "checkbox",
			label = L.USE_RP_NAME_COLOR,
			tooltip = L.USE_RP_NAME_COLOR_HELP,
			disabled = function() return ED.Database:GetSetting("NameDisplayMode") == 3 end,
			get = function() return ED.Database:GetSetting("UseRPNameColor") end,
			set = function(val)
				ED.Database:SetSetting("UseRPNameColor", val);
				ED.Frame:RefreshChat();
			end,
		},
		{
			type = "checkbox",
			label = L.TIMESTAMP_BRACKETS,
			tooltip = L.TIMESTAMP_BRACKETS_HELP,
			get = function() return ED.Database:GetSetting("TimestampBrackets") end,
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
			get = function() return ED.Database:GetSetting("ApplyOnMainChat") end,
			set = function(val)
				ED.Database:SetSetting("ApplyOnMainChat", val);
			end,
		},
		{
			type = "checkbox",
			label = L.USE_RP_NAME_FOR_TARGETS,
			tooltip = L.USE_RP_NAME_FOR_TARGETS_HELP,
			disabled = function() return ED.Database:GetSetting("NameDisplayMode") == 3 end,
			get = function() return ED.Database:GetSetting("UseRPNameForTargets") end,
			set = function(val)
				ED.Database:SetSetting("UseRPNameForTargets", val);
				ED.Frame:RefreshChat();
			end,
		},
		{
			type = "checkbox",
			label = L.USE_RP_NAME_IN_ROLLS,
			tooltip = L.USE_RP_NAME_IN_ROLLS_HELP,
			disabled = function() return ED.Database:GetSetting("NameDisplayMode") == 3 end,
			get = function() return ED.Database:GetSetting("UseRPNameInRolls") end,
			set = function(val)
				ED.Database:SetSetting("UseRPNameInRolls", val)
				ED.Frame:RefreshChat();
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
					return {
						r = 0;
						g = 0;
						b = 0;
						a = 0.5;
					};
				end
				return color;
			end;
			set = function(val)
				if type(val) ~= "table" then return; end

				local background = ED.Frame.Background;
				if not background then return; end

				background:SetColorTexture(val.r, val.g, val.b, val.a);

				if val.r == 0 and val.g == 0 and val.b == 0 and val.a == 0.5 then
					ED.Database:SetSetting("ColorBackground", nil);
					return;
				end

				ED.Database:SetSetting("ColorBackground", {
					r = val.r;
					g = val.g;
					b = val.b;
					a = val.a;
				});
			end;
		},
		{
			type = "colorswatch",
			label = L.THEMES_TITLEBAR_COLOR,
			tooltip = L.THEMES_TITLEBAR_COLOR_HELP,
			opacity = true,
			get = function()
				local color = ED.Database:GetSetting("ColorTitleBar");
				if type(color) ~= "table" then
					return {
						r = 0;
						g = 0;
						b = 0;
						a = 0.25;
					};
				end
				return color;
			end;
			set = function(val)
				if type(val) ~= "table" then return; end

				local background = ED.Frame.TitleBar.Background;
				if not background then return; end

				background:SetColorTexture(val.r, val.g, val.b, val.a);

				if val.r == 0 and val.g == 0 and val.b == 0 and val.a == 0.25 then
					ED.Database:SetSetting("ColorTitleBar", nil);
					return;
				end

				ED.Database:SetSetting("ColorTitleBar", {
					r = val.r;
					g = val.g;
					b = val.b;
					a = val.a;
				});
			end;
		},
		{
			type = "checkbox",
			label = L.THEMES_SETTINGS_ELVUI,
			tooltip = L.THEMES_SETTINGS_ELVUI_HELP,
			disabled = function() return not C_AddOns.IsAddOnLoaded("ElvUI") end,
			get = function() return ED.Database:GetSetting("ElvUITheme") end,
			set = function(val)
				ED.Database:SetSetting("ElvUITheme", val);
				ReloadUI();
			end,
		},
		{
			type = "checkbox",
			label = L.HIDE_IN_COMBAT,
			tooltip = L.HIDE_IN_COMBAT_HELP,
			get = function() return ED.Database:GetSetting("HideInCombat") end,
			set = function(val)
				ED.Database:SetSetting("HideInCombat", val);
				if InCombatLockdown() then
					ED.Frame:Hide();
				end
			end,
		},
		{
			type = "checkbox",
			label = L.HIDE_WHEN_EMPTY,
			tooltip = L.HIDE_WHEN_EMPTY_HELP,
			get = function() return ED.Database:GetSetting("HideWhenEmpty") end,
			set = function(val)
				ED.Database:SetSetting("HideWhenEmpty", val);
				ED.Frame:HandleHiding();
			end,
		},
		{
			type = "checkbox",
			label = L.HIDE_CLOSE_BUTTON,
			tooltip = L.HIDE_CLOSE_BUTTON_HELP,
			get = function() return ED.Database:GetSetting("HideCloseButton") end,
			set = function(val)
				ED.Database:SetSetting("HideCloseButton", val);
				ED.Frame.TitleBar.CloseButton:SetShown(not val);
			end,
		},
		{
			type = "checkbox",
			label = L.TITLE_BAR_TARGET_NAME,
			tooltip = L.TITLE_BAR_TARGET_NAME_HELP,
			get = function() return ED.Database:GetSetting("UpdateTitleBarWithName") end,
			set = function(val)
				ED.Database:SetSetting("UpdateTitleBarWithName", val);
				ED.Frame:RefreshChat();
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
			get = function() return ED.Database:GetSetting("FontFace") end,
			set = function(val)
				ED.Database:SetSetting("FontFace", val);
				ED.ChatBox:ApplyFontOptions();
			end,
		},
		{
			type = "slider",
			label = L.FONT_SIZE,
			tooltip = L.FONT_SIZE_HELP,
			min = 6,
			max = 24,
			step = 1,
			get = function() return ED.Database:GetSetting("FontSize") end,
			set = function(val)
				ED.Database:SetSetting("FontSize", val);
				ED.ChatBox:ApplyFontOptions();
			end,
		},
		{
			type = "dropdown",
			label = L.FONT_OUTLINE,
			tooltip = L.FONT_OUTLINE_HELP,
			values = {
				[1] = L.FONT_OUTLINE_NONE;
				[2] = L.FONT_OUTLINE_THIN;
				[3] = L.FONT_OUTLINE_THICK;
			},
			sorting = {
				1,
				2,
				3,
			},
			get = function() return ED.Database:GetSetting("FontOutline") end,
			set = function(val)
				ED.Database:SetSetting("FontOutline", val);
				ED.ChatBox:ApplyFontOptions();
			end,
		},
		{
			type = "checkbox",
			label = L.FONT_SHADOW,
			tooltip = L.FONT_SHADOW_HELP,
			get = function() return ED.Database:GetSetting("FontShadow") end,
			set = function(val)
				ED.Database:SetSetting("FontShadow", val);
				ED.ChatBox:ApplyFontOptions();
			end,
		},
		{
			type = "subtitle",
			label = L.MINIMAP,
		},
		{
			type = "checkbox",
			label = L.MINIMAP_BUTTON,
			tooltip = L.MINIMAP_BUTTON_HELP,
			get = function() return not ED.Database:GetGlobalSetting("MinimapButton").Hide end,
			set = function(val)
				local minimap = ED.Database:GetGlobalSetting("MinimapButton");
				minimap.Hide = not val;
				ED.Database:SetGlobalSetting("MinimapButton", minimap);
				ED.Minimap:UpdateMinimapButtons();
			end,
		},
		{
			type = "checkbox",
			label = L.ADDON_COMPARTMENT_BUTTON,
			tooltip = L.ADDON_COMPARTMENT_BUTTON_HELP,
			get = function() return ED.Database:GetGlobalSetting("MinimapButton").ShowAddonCompartmentButton end,
			set = function(val)
				local minimap = ED.Database:GetGlobalSetting("MinimapButton");
				minimap.ShowAddonCompartmentButton = val;
				ED.Database:SetGlobalSetting("MinimapButton", minimap);
				ED.Minimap:UpdateMinimapButtons();
			end,
		},
	};

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
			get = function() return ED.Database:GetSetting("NotificationEmotesSound") end,
			set = function(val)
				ED.Database:SetSetting("NotificationEmotesSound", val);
			end,
		},
		{
			type = "dropdown",
			label = L.NOTIFICATIONS_SOUND_FILE,
			tooltip = L.NOTIFICATIONS_SOUND_FILE_HELP,
			values = ED.Config.soundList,
			disabled = function() return not ED.Database:GetSetting("NotificationEmotesSound") end,
			get = function() return ED.Database:GetSetting("NotificationEmotesSoundFile") end,
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
			get = function() return ED.Database:GetSetting("NotificationEmotesFlashTaskbar") end,
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
			get = function() return ED.Database:GetSetting("NotificationTargetSound") end,
			set = function(val)
				ED.Database:SetSetting("NotificationTargetSound", val);
			end,
		},
		{
			type = "dropdown",
			label = L.NOTIFICATIONS_SOUND_FILE,
			tooltip = L.NOTIFICATIONS_SOUND_FILE_HELP,
			values = ED.Config.soundList,
			disabled = function() return not ED.Database:GetSetting("NotificationTargetSound") end,
			get = function() return ED.Database:GetSetting("NotificationTargetSoundFile") end,
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
			get = function() return ED.Database:GetSetting("NotificationTargetFlashTaskbar") end,
			set = function(val)
				ED.Database:SetSetting("NotificationTargetFlashTaskbar", val);
			end,
		},
	};

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
			get = function() return ED.Database:GetSetting("EnableKeywords") end,
			set = function(val)
				ED.Database:SetSetting("EnableKeywords", val);
			end,
		},
		{
			type = "description",
			label = L.KEYWORDS_LIST,
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
			get = function() return ED.Database:GetSetting("EnablePartialKeywords") end,
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
			get = function() return ED.Database:GetSetting("NotificationKeywordsSound") end,
			set = function(val)
				ED.Database:SetSetting("NotificationKeywordsSound", val);
			end,
		},
		{
			type = "dropdown",
			label = L.NOTIFICATIONS_SOUND_FILE,
			tooltip = L.NOTIFICATIONS_SOUND_FILE_HELP,
			values = ED.Config.soundList,
			disabled = function() return not ED.Database:GetSetting("NotificationKeywordsSound") end,
			get = function() return ED.Database:GetSetting("NotificationKeywordsSoundFile") end,
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
			get = function() return ED.Database:GetSetting("NotificationKeywordsFlashTaskbar") end,
			set = function(val)
				ED.Database:SetSetting("NotificationKeywordsFlashTaskbar", val);
			end,
		},
	};

	local profilesOptions = {
		{
			type = "subtitle",
			label = L.PROFILES_TITLE,
		},
		{
			type = "dropdown",
			label = L.PROFILES_CURRENTPROFILE,
			tooltip = L.PROFILES_CURRENTPROFILE_HELP,
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
				ED.Database:CreateProfile(val);
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
				ED.Database:CopyProfile(val);
			end,
		},
		{
			type = "button",
			label = L.PROFILES_RESETBUTTON,
			tooltip = L.PROFILES_RESETBUTTON_HELP,
			func = function()
				ED.Database:ResetProfile();
				self:RefreshWidgets();
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
				ED.Database:DeleteProfile(val);
			end,
		},
	};

	local insetWidgets = {
		{
			type = "logo",
		},
		{
			type = "title",
			text = ED.Globals.addon_title,
		},
		{
			type = "version",
			text = ED.Globals.addon_version,
		},
		{
			type = "build",
			text = L.ADDONINFO_BUILD:format(ED.Utils.OutputBuild(true)),
			tooltip = function()
				if ED.Utils.ValidateLatestBuild() then
					return L.ADDONINFO_BUILD_CURRENT;
				else
					return L.ADDONINFO_BUILD_OUTDATED;
				end
			end,
		},
		{
			type = "author",
			text = ED.Globals.author,
		},
		{
			type = "bsky",
			text = "Bluesky",
			tooltip = L.ADDONINFO_BLUESKY_SHILL_HELP,
		},
	};

	self:PopulateTab(generalContent, generalOptions);
	self:PopulateTab(keywordsContent, keywordsOptions);
	self:PopulateTab(notificationsContent, notificationsOptions);
	self:PopulateTab(profilesPanel, profilesOptions);

	SettingsElements.CreateInset(profilesPanel, insetWidgets, true);

	local totalWidth = 0;
	for _, tab in ipairs(self.Tabs) do
		PanelTemplates_TabResize(tab, 15, nil, 65);
		PanelTemplates_DeselectTab(tab);
		totalWidth = totalWidth + tab:GetWidth() + 8; -- 8px spacing between tabs
	end
	self:SetWidth(totalWidth);

	ED.ElvUI.RegisterSkinnableElement(self, "frame");
end

function Eavesdropper_SettingsMixin:OnDragStart()
	self:StartMoving();
end

function Eavesdropper_SettingsMixin:OnDragStop()
	self:StopMovingOrSizing();

	if not ED.Database then return; end

	local point, _, relativePoint, x, y = self:GetPoint(1);
	ED.Database:SetGlobalSetting("SettingsWindowPosition", { point = point, relativePoint = relativePoint, x = x, y = y, });
end

function Eavesdropper_SettingsMixin:OnShow()
	ED.ElvUI.SkinRegisteredElements();
	-- self:RefreshWidgets() unnecessary (?)
	local tabToShow = lastSelectedTab or 1;
	self:SetTab(tabToShow);
end

function Eavesdropper_SettingsMixin:OnHide()
	if ED.Frame.closed then
		ED.Frame:Hide();
	end
end

---@param view number? Optional tab index, defaults to 1.
function Settings:ShowSettings(view)
	if not ED.SettingsFrame then
		Settings:Init();
	end

	if ED.Frame.closed then
		ED.Frame:Show();
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
