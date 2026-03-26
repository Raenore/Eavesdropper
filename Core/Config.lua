-- Copyright The Eavesdropper Authors
-- SPDX-License-Identifier: Apache-2.0

---@type table
local SharedMedia = LibStub("LibSharedMedia-3.0");

local L = ED.Localization;

---@class EavesdropperConfig
local Config = {};

---@type table<string, string>
Config.soundList = {};

---Maps DB setting keys to their camelCase field names on dedicated frames.
---Required to avoid shadowing WoW Frame API methods (e.g. EnableMouse, LockScroll).
---@type table<string, string>
local DedicatedFrameFieldMap = {
	EnableMouse = "mouseEnabled",
	LockScroll = "lockScroll",
	LockWindow = "lockWindow",
	LockTitleBar = "lockTitleBar",
	HideCloseButton = "hideCloseButton",
};

---@param element table UI element
---@param text string Tooltip text
---@return nil
local function SetTooltip(element, text)
	element:SetTooltip(function(tooltip, desc)
		GameTooltip_SetTitle(tooltip, MenuUtil.GetElementText(desc));
		GameTooltip_AddNormalLine(tooltip, text);
	end);
end

---Registers default sounds and populates the config sound list
---@return nil
local function SetupSounds()
	for _, sound in ipairs(ED.Constants.DEFAULT_SOUND_LIST) do
		SharedMedia:Register("sound", sound.key, sound.fid);
	end

	local localSoundPath = ED.Constants.LOCAL_SOUND_PATH;
	for _, sound in ipairs(ED.Constants.LOCAL_SOUND_LIST) do
		SharedMedia:Register("sound", sound.key, localSoundPath .. sound.fileName);
	end

	for _, soundName in ipairs(SharedMedia:List("sound")) do
		Config.soundList[soundName] = soundName;
	end
end

---Display the configuration menu for the addon.
---@param frame table
---@param dedicatedFrame boolean?
---@param groupFrame boolean?
---@return nil
function Config:ShowConfigMenu(frame, dedicatedFrame, groupFrame)
	dedicatedFrame = dedicatedFrame or false;
	groupFrame = groupFrame or false;

	local useFrameState = dedicatedFrame or groupFrame;

	---Handles extra clicks on the Title Bar Button to not close the menu.
	function frame.TitleBar.TitleButton.HandlesGlobalMouseEvent()
		return true;
	end

	---Reads a setting from frame state or the DB
	---@param key string
	---@return any
	local function getSetting(key)
		if useFrameState then
			local field = DedicatedFrameFieldMap[key] or key;
			return frame[field];
		end
		return ED.Database:GetSetting(key);
	end

	---Toggles a setting on frame state or in the DB, then runs postUpdate
	---@param key string
	---@param postUpdate function?
	local function toggleSetting(key, postUpdate)
		if useFrameState then
			local field = DedicatedFrameFieldMap[key] or key;
			frame[field] = not frame[field];
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
		if groupFrame then
			rootDescription:CreateTitle(L.GROUP_WINDOWS);
		elseif dedicatedFrame then
			rootDescription:CreateTitle(L.DEDICATED_WINDOWS);
		else
			local title = rootDescription:CreateTitle(ED.Globals.addon_settings_icon .. " " .. ED.Globals.addon_title);
			title:SetTooltip(function(tooltip, elementDescription)
				GameTooltip_SetTitle(tooltip, MenuUtil.GetElementText(elementDescription));
				GameTooltip_AddNormalLine(tooltip, "Version: " .. ED.Globals.addon_version);
			end);
		end

		-- Filters
		local filter = rootDescription:CreateButton(L.FILTER);
		filter:SetTooltip(function(tooltip, elementDescription)
			GameTooltip_SetTitle(tooltip, MenuUtil.GetElementText(elementDescription));
			GameTooltip_AddNormalLine(tooltip, L.FILTER_HELP);
		end);
		filter:CreateTitle(L.FILTER .. " " .. MAIN_MENU);
		ED.ChatFilters:GenerateFilterListMenu(frame, filter);

		if not useFrameState then
			-- Notification Settings
			rootDescription:CreateButton(SETTINGS, function()
				ED.Settings:ShowSettings();
			end);
		end

		rootDescription:CreateDivider();
		rootDescription:CreateTitle(L.WINDOW_OPTIONS);

		-- Enable Mouse
		local enableMouse = rootDescription:CreateCheckbox(
			L.ENABLE_MOUSE,
			function() return getSetting("EnableMouse"); end,
			function() toggleSetting("EnableMouse", function() frame:UpdateMouseLock(); end); end
		);
		SetTooltip(enableMouse, L.ENABLE_MOUSE_HELP);

		-- Lock Scroll
		local lockScroll = rootDescription:CreateCheckbox(
			L.LOCK_SCROLL,
			function() return getSetting("LockScroll"); end,
			function() toggleSetting("LockScroll", function() frame.ChatBox:ScrollToBottom(); end); end
		);
		SetTooltip(lockScroll, L.LOCK_SCROLL_HELP);

		-- Lock Window
		local lockWindow = rootDescription:CreateCheckbox(
			L.LOCK_WINDOW,
			function() return getSetting("LockWindow"); end,
			function()
				toggleSetting("LockWindow", function()
					frame.ResizeHandle:SetShown(not getSetting("LockWindow"));
				end);
			end
		);
		SetTooltip(lockWindow, L.LOCK_WINDOW_HELP);

		-- Lock Title Bar
		local lockTitleBar = rootDescription:CreateCheckbox(
			L.LOCK_TITLEBAR,
			function() return getSetting("LockTitleBar"); end,
			function() toggleSetting("LockTitleBar"); end
		);
		SetTooltip(lockTitleBar, L.LOCK_TITLEBAR_HELP);

		if useFrameState then
			rootDescription:CreateDivider();

			if groupFrame then
				rootDescription:CreateTitle(L.GROUP_OPTIONS);
			else
				rootDescription:CreateTitle(L.DEDICATED_OPTIONS);
			end

			rootDescription:CreateButton(L.GROUP_RENAME, function()
				frame:PromptRenameFrame();
			end);

			local frameFontSize = rootDescription:CreateButton(L.FONT_SIZE);
			frameFontSize:CreateTitle(L.FONT_SIZE);
			for i = ED.Constants.CHAT_BOX.MIN_FONT_SIZE, ED.Constants.CHAT_BOX.MAX_FONT_SIZE, 2 do
				frameFontSize:CreateCheckbox(
					i,
					function() return i == frame.FontSize; end,
					function()
						frame.FontSize = i;
						ED.ChatBox:ApplyFontOptions(frame);
					end
				);
			end

			-- Hide Close Button
			rootDescription:CreateCheckbox(
				L.HIDE_CLOSE_BUTTON,
				function() return getSetting("HideCloseButton"); end,
				function()
					toggleSetting("HideCloseButton", function()
						frame.TitleBar.CloseButton:SetShown(not getSetting("HideCloseButton"));
					end);
				end
			);

			if groupFrame then
				local frameNameDisplayMode = rootDescription:CreateButton(L.NAME_DISPLAY_MODE);
				frameNameDisplayMode:CreateTitle(L.NAME_DISPLAY_MODE .. " " .. MAIN_MENU);
				frameNameDisplayMode:CreateRadio(L.NAME_DISPLAY_MODE_FULL_NAME, function() return frame.nameDisplayMode == 1 end, function() frame:SetNameDisplayMode(1); end);
				frameNameDisplayMode:CreateRadio(L.NAME_DISPLAY_MODE_FIRST_NAME, function() return frame.nameDisplayMode == 2 end, function() frame:SetNameDisplayMode(2); end);
				frameNameDisplayMode:CreateRadio(L.NAME_DISPLAY_MODE_ORIGINAL_NAME, function() return frame.nameDisplayMode == 3 end, function() frame:SetNameDisplayMode(3); end);
			end
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
