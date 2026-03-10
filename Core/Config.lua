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
---@param frame table
---@param dedicatedFrame boolean?
---@return nil
function Config:ShowConfigMenu(frame, dedicatedFrame)
	dedicatedFrame = dedicatedFrame or false;

	local function getSetting(key)
		if dedicatedFrame then
			return frame[key];
		else
			return ED.Database:GetSetting(key);
		end
	end

	local function toggleSetting(key, postUpdate)
		if dedicatedFrame then
			frame[key] = not frame[key];
		else
			local current = ED.Database:GetSetting(key);
			ED.Database:SetSetting(key, not current);
		end
		if postUpdate then
			postUpdate();
		end
	end

	MenuUtil.CreateContextMenu(frame, function(_, rootDescription)
		rootDescription:SetMinimumWidth(1);
		rootDescription:AddMenuReleasedCallback(function() frame:OnLeave(); end);

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
		ED.ChatFilters:GenerateFilterListMenu(frame, filter);

		if not dedicatedFrame then
			-- Notification Settings
			rootDescription:CreateButton(SETTINGS, function()
				ED.Settings:ShowSettings();
			end);
		end

		rootDescription:CreateDivider();
		rootDescription:CreateTitle(Localization.WINDOW_OPTIONS);

		-- Enable Mouse
		local enableMouse = rootDescription:CreateCheckbox(
			Localization.ENABLE_MOUSE,
			function() return getSetting("EnableMouse"); end,
			function() toggleSetting("EnableMouse", function() frame:UpdateMouseLock(); end); end
		);
		SetTooltip(enableMouse, Localization.ENABLE_MOUSE_HELP);

		-- Lock Scroll
		local lockScroll = rootDescription:CreateCheckbox(
			Localization.LOCK_SCROLL,
			function() return getSetting("LockScroll"); end,
			function() toggleSetting("LockScroll", function() frame.ChatBox:ScrollToBottom(); end); end
		);
		SetTooltip(lockScroll, Localization.LOCK_SCROLL_HELP);

		-- Lock Window
		local lockWindow = rootDescription:CreateCheckbox(
			Localization.LOCK_WINDOW,
			function() return getSetting("LockWindow"); end,
			function() toggleSetting("LockWindow", function() frame.ResizeHandle:SetShown(frame.LockWindow); end); end
		);
		SetTooltip(lockWindow, Localization.LOCK_WINDOW_HELP);

		-- Lock Title Bar
		local lockTitleBar = rootDescription:CreateCheckbox(
			Localization.LOCK_TITLEBAR,
			function() return getSetting("LockTitleBar"); end,
			function() toggleSetting("LockTitleBar"); end
		);
		SetTooltip(lockTitleBar, Localization.LOCK_TITLEBAR_HELP);

		if dedicatedFrame then
			rootDescription:CreateDivider();
			rootDescription:CreateTitle(Localization.DEDICATED_OPTIONS);

			-- Hide Close Button
			rootDescription:CreateCheckbox(
				Localization.HIDE_CLOSE_BUTTON,
				function() return getSetting("HideCloseButton"); end,
				function() toggleSetting("HideCloseButton", function() frame.TitleBar.CloseButton:SetShown(not frame.HideCloseButton); end); end
			);
		end
	end);
end

---@return nil
local function SetupMenu()
	ED.Frame.TitleBar.TitleButton:SetScript("OnClick", function()
		Config:ShowConfigMenu(ED.Frame);
	end);
end

---@return nil
function Config:Init()
	SetupSounds();
	SetupMenu();
end

ED.Config = Config;
