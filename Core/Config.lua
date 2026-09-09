-- Copyright The Eavesdropper Authors
-- SPDX-License-Identifier: GPL-3.0-or-later

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
local DEDICATED_FRAME_FIELD_MAP = {
	EnableMouse = "mouseEnabled",
	LockScroll = "lockScroll",
	LockWindow = "lockWindow",
	LockTitleBar = "lockTitleBar",
	HideCloseButton = "hideCloseButton",
};

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
---@param mode ("dedicated"|"group"|"mentions")? nil means the main Eavesdropper frame.
---@return nil
function Config.ShowConfigMenu(frame, mode)
	-- All three instance windows show the options section.
	-- Dedicated/Group back it with frame state.
	-- Mentions reads/writes its own profile keys instead, like Main.
	local showInstanceOptions = mode ~= nil;
	local useFrameState = mode == "dedicated" or mode == "group";
	local keyPrefix = (mode == "mentions") and "Mentions" or "";

	---Handles extra clicks on the Title Bar Button to not close the menu.
	function frame.TitleBar.TitleButton.HandlesGlobalMouseEvent()
		return true;
	end

	---Reads a setting from frame state or the DB
	---@param key string
	---@return any
	local function GetSetting(key)
		if useFrameState then
			local field = DEDICATED_FRAME_FIELD_MAP[key] or key;
			return frame[field];
		end
		return ED.Database:GetSetting(keyPrefix .. key);
	end

	---Toggles a setting on frame state or in the DB, then runs postUpdate
	---@param key string
	---@param postUpdate function?
	local function ToggleSetting(key, postUpdate)
		if useFrameState then
			local field = DEDICATED_FRAME_FIELD_MAP[key] or key;
			frame[field] = not frame[field];
			frame:SaveInstanceState();
		else
			local dbKey = keyPrefix .. key;
			local current = ED.Database:GetSetting(dbKey);
			ED.Database:SetSetting(dbKey, not current);
		end
		if postUpdate then
			postUpdate();
		end
	end

	MenuUtil.CreateContextMenu(frame, function(_, rootDescription)
		rootDescription:SetMinimumWidth(1);
		rootDescription:AddMenuReleasedCallback(function() frame:OnLeave(); end);

		-- Title
		if mode == "group" then
			rootDescription:CreateTitle(L.GROUP_WINDOWS);
		elseif mode == "dedicated" then
			rootDescription:CreateTitle(L.DEDICATED_WINDOWS);
		elseif mode == "mentions" then
			rootDescription:CreateTitle(L.MENTIONS_WINDOW_TITLE);
		else
			local title = rootDescription:CreateTitle(ED.Globals.addon_settings_icon .. " " .. ED.Globals.addon_title);
			ED.Utils.SetMenuTooltip(title, "Version: " .. ED.Globals.addon_version);
		end

		-- Filters
		local filter = rootDescription:CreateButton(L.FILTER);
		ED.Utils.SetMenuTooltip(filter, L.FILTER_HELP);
		filter:CreateTitle(L.FILTER .. " " .. MAIN_MENU);
		ED.ChatFilters:GenerateFilterListMenu(frame, filter);

		-- Eavesdrop on / Eavesdrop Group: always shown, disabled without an eavesdropped target.
		-- A dedicated window always has one, so it only gets Eavesdrop Group.
		if (mode == nil or mode == "dedicated") and ED.UnitPopups then
			local sender = frame.eavesdropped_player;
			local guid = frame.eavesdropped_player_guid;

			if mode == nil and ED.Database:GetGlobalSetting("DedicatedWindows") then
				ED.UnitPopups:CreateEavesdropOnButton(rootDescription, sender, guid);
			end
			if ED.Database:GetGlobalSetting("GroupWindows") then
				ED.UnitPopups:CreateEavesdropGroupButton(rootDescription, sender, guid);
			end
		end

		-- No other frame ever displays entry.mn, so this is Mentions-only.
		if mode == "mentions" then
			local mentionTypes = rootDescription:CreateButton(L.MENTIONS_REASON_FILTER);
			ED.Utils.SetMenuTooltip(mentionTypes, L.MENTIONS_REASON_FILTER_HELP);
			mentionTypes:CreateTitle(L.MENTIONS_REASON_FILTER .. " " .. MAIN_MENU);
			ED.ChatFilters:GenerateMentionReasonFilterMenu(mentionTypes);
		end

		if mode == "group" then
			local playerList = rootDescription:CreateButton(L.PLAYER_LIST);
			ED.Utils.SetMenuTooltip(playerList, L.PLAYER_LIST_HELP);
			playerList:CreateTitle(L.PLAYER_LIST .. " " .. MAIN_MENU);
			ED.GroupFrame:GeneratePlayerListMenu(frame, playerList);
		end

		-- Settings, scoped to this frame's own category. nil for the main frame.
		local settingsView;
		if mode == "dedicated" then
			settingsView = L.DEDICATED;
		elseif mode == "group" then
			settingsView = L.GROUPS;
		elseif mode == "mentions" then
			settingsView = L.MENTIONS_WINDOW_TITLE;
		end

		local copyHistory = rootDescription:CreateButton(L.COPY_HISTORY, function()
			ED.CopyHistoryDialog:Show(frame, mode == "group" or mode == "mentions");
		end);
		ED.Utils.SetMenuTooltip(copyHistory, L.COPY_HISTORY_HELP);
		if frame.ChatBox:GetNumMessages() == 0 then
			copyHistory:SetEnabled(false);
		end

		rootDescription:CreateButton(SETTINGS, function()
			ED.Settings.OpenSettings(settingsView);
		end);

		rootDescription:CreateDivider();
		rootDescription:CreateTitle(L.WINDOW_OPTIONS);

		-- Enable Mouse
		local enableMouse = rootDescription:CreateCheckbox(
			L.ENABLE_MOUSE,
			function() return GetSetting("EnableMouse"); end,
			function() ToggleSetting("EnableMouse", function() frame:UpdateMouseLock(); end); end
		);
		ED.Utils.SetMenuTooltip(enableMouse, L.ENABLE_MOUSE_HELP);

		-- Lock Scroll
		local lockScroll = rootDescription:CreateCheckbox(
			L.LOCK_SCROLL,
			function() return GetSetting("LockScroll"); end,
			function() ToggleSetting("LockScroll", function() frame.ChatBox:ScrollToBottom(); end); end
		);
		ED.Utils.SetMenuTooltip(lockScroll, L.LOCK_SCROLL_HELP);

		-- Lock Window
		local lockWindow = rootDescription:CreateCheckbox(
			L.LOCK_WINDOW,
			function() return GetSetting("LockWindow"); end,
			function()
				ToggleSetting("LockWindow", function()
					frame.ResizeHandle:SetShown(not GetSetting("LockWindow"));
				end);
			end
		);
		ED.Utils.SetMenuTooltip(lockWindow, L.LOCK_WINDOW_HELP);

		-- Lock Title Bar
		local lockTitleBar = rootDescription:CreateCheckbox(
			L.LOCK_TITLEBAR,
			function() return GetSetting("LockTitleBar"); end,
			function() ToggleSetting("LockTitleBar"); end
		);
		ED.Utils.SetMenuTooltip(lockTitleBar, L.LOCK_TITLEBAR_HELP);

		-- Jump to Context: Mentions/Group only. A per-family global (mirroring Settings).
		-- Enabling it also exempts the icon from Enable Mouse (IsJumpToContextMouseExempt),
		-- disabling it makes the window go back to being full click passthrough.
		if mode == "group" or mode == "mentions" then
			local jumpToContextKey = (mode == "mentions") and "MentionsHistoryJumpToContext" or "GroupWindowsJumpToContext";

			local jumpToContext = rootDescription:CreateCheckbox(
				L.JUMP_TO_CONTEXT,
				function() return ED.Database:GetGlobalSetting(jumpToContextKey); end,
				function()
					ED.Database:SetGlobalSetting(jumpToContextKey, not ED.Database:GetGlobalSetting(jumpToContextKey));
					Eavesdropper_SharedFrameMixin.RefreshAllWindows();
					-- RefreshAllWindows only calls RefreshChat, not UpdateMouseLock, so it wouldn't
					-- re-apply SetHyperlinksEnabled for the exemption this setting now controls.
					if mode == "group" then
						ED.GroupFrame:ForEachFrame(function(f) f:UpdateMouseLock(); end);
					else
						ED.MentionsFrame:UpdateMouseLock();
					end
				end
			);
			ED.Utils.SetMenuTooltip(jumpToContext, L.JUMP_TO_CONTEXT_HELP);
			if not ED.Database:GetGlobalSetting("DedicatedWindows") then
				jumpToContext:SetEnabled(false);
			end
		end

		if showInstanceOptions then
			rootDescription:CreateDivider();

			if mode == "group" then
				rootDescription:CreateTitle(L.GROUP_OPTIONS);
			elseif mode == "mentions" then
				rootDescription:CreateTitle(L.MENTIONS_OPTIONS);
			else
				rootDescription:CreateTitle(L.DEDICATED_OPTIONS);
			end

			if mode == "group" then
				rootDescription:CreateButton(L.GROUP_RENAME, function()
					frame:PromptRenameFrame();
				end);
			end

			local frameFontSize = rootDescription:CreateButton(L.FONT_SIZE);
			frameFontSize:CreateTitle(L.FONT_SIZE);
			for i = ED.Constants.CHAT_BOX.MIN_FONT_SIZE, ED.Constants.CHAT_BOX.MAX_FONT_SIZE, 2 do
				frameFontSize:CreateCheckbox(
					i,
					function() return i == (useFrameState and frame.FontSize or ED.Database:GetSetting(keyPrefix .. "FontSize")); end,
					function()
						if useFrameState then
							frame.FontSize = i;
							frame:SaveInstanceState();
						else
							ED.Database:SetSetting(keyPrefix .. "FontSize", i);
						end
						ED.ChatBox:ApplyFontOptions(frame);
					end
				);
			end

			-- Hide Close Button
			rootDescription:CreateCheckbox(
				L.HIDE_CLOSE_BUTTON,
				function() return GetSetting("HideCloseButton"); end,
				function()
					ToggleSetting("HideCloseButton", function()
						frame.TitleBar.CloseButton:SetShown(not GetSetting("HideCloseButton"));
					end);
				end
			);

			if mode == "dedicated" or mode == "group" or mode == "mentions" then
				-- frame:GetNameDisplayMode() is nil until explicitly overridden.
				-- Follow Profile == nil, the others carry an override.
				local frameNameDisplayMode = rootDescription:CreateButton(L.NAME_DISPLAY_MODE);
				frameNameDisplayMode:CreateTitle(L.NAME_DISPLAY_MODE .. " " .. MAIN_MENU);
				frameNameDisplayMode:CreateRadio(L.NAME_DISPLAY_MODE_FOLLOW_PROFILE, function() return frame:GetNameDisplayMode() == nil end, function() frame:SetNameDisplayMode(nil); end);
				frameNameDisplayMode:CreateRadio(L.NAME_DISPLAY_MODE_FULL_NAME, function() return frame:GetNameDisplayMode() == 1 end, function() frame:SetNameDisplayMode(1); end);
				frameNameDisplayMode:CreateRadio(L.NAME_DISPLAY_MODE_FIRST_NAME, function() return frame:GetNameDisplayMode() == 2 end, function() frame:SetNameDisplayMode(2); end);
				frameNameDisplayMode:CreateRadio(L.NAME_DISPLAY_MODE_ORIGINAL_NAME, function() return frame:GetNameDisplayMode() == 3 end, function() frame:SetNameDisplayMode(3); end);
			end
		end
	end);
end

---@return nil
local function SetupMenu()
	ED.Frame.TitleBar.TitleButton:SetScript("OnClick", function()
		Config.ShowConfigMenu(ED.Frame);
	end);
end

---@return nil
function Config.Init()
	SetupSounds();
	SetupMenu();
end

ED.Config = Config;
