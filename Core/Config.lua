-- Copyright The Eavesdropper Authors
-- SPDX-License-Identifier: Apache-2.0

---@type table
local SharedMedia = LibStub("LibSharedMedia-3.0");

local Localization = ED.Localization;

---@class EavesdropperConfig
local Config = {};

---@type table<string, string>
Config.soundList = {};

---@param element table UI element
---@param text string Tooltip text
---@return nil
local function SetTooltip(element, text)
	element:SetTooltip(function(tooltip, desc)
		GameTooltip_SetTitle(tooltip, MenuUtil.GetElementText(desc));
		GameTooltip_AddNormalLine(tooltip, text);
	end);
end

---SetupSounds Registers default sounds and populates the config sound list
---@return nil
local function SetupSounds()
	for _, sound in ipairs(ED.Constants.DEFAULT_SOUND_LIST) do
		SharedMedia:Register("sound", sound.key, sound.fid);
	end

	for _, soundName in ipairs(SharedMedia:List("sound")) do
		Config.soundList[soundName] = soundName;
	end
end

---ShowConfigMenu Displays the configuration menu for the addon
---@return nil
local function ShowConfigMenu()
	MenuUtil.CreateContextMenu(ED.Frame, function(_, rootDescription)
		rootDescription:SetMinimumWidth(1);
		rootDescription:AddMenuReleasedCallback(function() ED.Frame:OnLeave(); end);

		-- Title
		local title = rootDescription:CreateTitle(ED.Globals.addon_settings_icon .. " " .. ED.Globals.addon_title);
		title:SetTooltip(function(tooltip, elementDescription)
			GameTooltip_SetTitle(tooltip, MenuUtil.GetElementText(elementDescription));
			GameTooltip_AddNormalLine(tooltip, "Version: " .. ED.Globals.addon_version);
		end);

		-- Filters
		local filter = rootDescription:CreateButton(Localization.FILTER);
		filter:SetTooltip(function(tooltip, elementDescription)
			GameTooltip_SetTitle(tooltip, MenuUtil.GetElementText(elementDescription));
			GameTooltip_AddNormalLine(tooltip, Localization.FILTER_HELP);
		end);
		filter:CreateTitle(Localization.FILTER .. " " .. MAIN_MENU);
		ED.ChatFilters:GenerateFilterListMenu(filter);

		-- Notification Settings
		rootDescription:CreateButton(SETTINGS, function()
			ED.Settings:ShowSettings();
		end);

		rootDescription:CreateDivider();
		rootDescription:CreateTitle(Localization.WINDOW_OPTIONS);

		-- Enable Mouse
		local enableMouse = rootDescription:CreateCheckbox(
			Localization.ENABLE_MOUSE,
			function() return ED.Database:GetSetting("EnableMouse"); end,
			function()
				local current = ED.Database:GetSetting("EnableMouse");
				ED.Database:SetSetting("EnableMouse", not current);
				ED.Frame:UpdateMouseLock();
			end
		);
		SetTooltip(enableMouse, Localization.ENABLE_MOUSE_HELP);

		-- Lock Scroll
		local lockScroll = rootDescription:CreateCheckbox(
			Localization.LOCK_SCROLL,
			function() return ED.Database:GetSetting("LockScroll"); end,
			function()
				local current = ED.Database:GetSetting("LockScroll");
				ED.Database:SetSetting("LockScroll", not current);
				ED.Frame.ChatBox:ScrollToBottom();
			end
		);
		SetTooltip(lockScroll, Localization.LOCK_SCROLL_HELP);

		-- Lock Window
		local lockWindow = rootDescription:CreateCheckbox(
			Localization.LOCK_WINDOW,
			function() return ED.Database:GetSetting("LockWindow"); end,
			function()
				local current = ED.Database:GetSetting("LockWindow");
				ED.Database:SetSetting("LockWindow", not current);
				ED.Frame.ResizeHandle:SetShown(current);
			end
		);
		SetTooltip(lockWindow, Localization.LOCK_WINDOW_HELP);

		-- Lock Title Bar
		local lockTitleBar = rootDescription:CreateCheckbox(
			Localization.LOCK_TITLEBAR,
			function() return ED.Database:GetSetting("LockTitleBar"); end,
			function()
				local current = ED.Database:GetSetting("LockTitleBar");
				ED.Database:SetSetting("LockTitleBar", not current);
			end
		);
		SetTooltip(lockTitleBar, Localization.LOCK_TITLEBAR_HELP);
	end);
end

---@return nil
local function SetupMenu()
	ED.Frame.TitleBar.TitleButton:SetScript("OnClick", ShowConfigMenu);
end

---@return nil
function Config:Init()
	SetupSounds();
	SetupMenu();
end

ED.Config = Config;
