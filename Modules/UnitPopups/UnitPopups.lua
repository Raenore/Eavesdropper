-- Copyright The Eavesdropper Authors
-- Inspired by Total RP 3
-- SPDX-License-Identifier: GPL-3.0-or-later

local L = ED.Localization;

if not Menu or not Menu.ModifyMenu then
	return;
end

---@class EavesdropperUnitPopups
local UnitPopups = {};

UnitPopups.MenuElementFactories = {};
UnitPopups.MenuEntries = {};
UnitPopups.isHyperlinkOrigin = false;

---Whether the unit popup menu about to open came from an addon-owned frame's
---hyperlink click, where the native Copy Character Name button is tainted.
---@param isFromHyperlink boolean
function UnitPopups:SetHyperlinkOrigin(isFromHyperlink)
	self.isHyperlinkOrigin = isFromHyperlink;
end

function UnitPopups:Init()
	for menuTagSuffix in pairs(UnitPopups.MenuEntries) do
		-- ModifyMenu uses each closure as an "owner" key behind the scenes, so it must be
		-- unique per iteration or successive registrations replace previous ones.

		local function OnMenuOpen(owner, rootDescription, contextData)
			self:OnMenuOpen(owner, rootDescription, contextData);
		end

		local menuTag = "MENU_UNIT_" .. menuTagSuffix;
		Menu.ModifyMenu(menuTag, OnMenuOpen);
	end
end

function UnitPopups:OnMenuOpen(owner, rootDescription, contextData)
	local dedicatedOrGroup = ED.Database:GetGlobalSetting("DedicatedWindows") or ED.Database:GetGlobalSetting("GroupWindows");
	local mentions = ED.Database:GetGlobalSetting("MentionsHistory") and ED.Database:GetGlobalSetting("MentionsHistoryUnitPopups");

	if not dedicatedOrGroup and not mentions then
		return; -- Every feature that could populate this menu is disabled.
	elseif not owner or owner:IsForbidden() then
		return; -- Invalid or forbidden owner.
	end

	local menuEntries = self.MenuEntries[contextData.which];

	if menuEntries then
		rootDescription:QueueDivider();
		rootDescription:QueueTitle(L.UNIT_POPUPS_EAVESDROPPER_OPTIONS_HEADER);

		for _, elementFactoryKey in ipairs(menuEntries) do
			local factory = self.MenuElementFactories[elementFactoryKey];

			if factory then
				factory(rootDescription, contextData);
			end
		end

		rootDescription:ClearQueuedDescriptions();
	end
end

-- ============================================================
-- Sender resolution helpers
-- ============================================================

---Resolve sender and GUID from BattleNet game account info.
---Returns (nil, nil) if the sender string begins with UNKNOWNOBJECT.
---@param gameAccountInfo table
---@return string?, string?
local function GetBattleNetCharacterFullName(gameAccountInfo)
	local characterName = gameAccountInfo.characterName;
	local realmName = gameAccountInfo.realmName;
	local sender = ED.Utils.ComposeSender(characterName, realmName);
	local guid = gameAccountInfo.playerGuid;

	if string.find(sender, UNKNOWNOBJECT, 1, true) == 1 then
		sender = nil;
	end

	return sender, guid;
end

---Resolve the sender string and GUID from character contextData.
---If the unit exists in the world, GetUnitName and UnitGUID are used directly.
---Returns (nil, nil) if the constructed sender begins with UNKNOWNOBJECT.
---@param contextData table
---@return string?, string?
local function ResolveCharacterData(contextData)
	local unit = contextData.unit;
	local name = contextData.name;
	local server = contextData.server;
	local sender = ED.Utils.ComposeSender(name, server);
	local guid = contextData.playerLocation and contextData.playerLocation.guid;

	if UnitExists(unit) then
		return ED.Utils.GetUnitName(unit), UnitGUID(unit);
	elseif string.find(sender, UNKNOWNOBJECT, 1, true) == 1 then
		return nil, nil;
	end

	return sender, guid;
end

-- ============================================================
-- Menu element factories
-- ============================================================

local function CreateOpenBattleNetEavesdropButton(menuDescription, contextData)
	if not ED.Database:GetGlobalSetting("DedicatedWindows") or not ED.Database:GetGlobalSetting("DedicatedWindowsUnitPopups") then
		return;
	end

	local function OnClick(contextData) -- luacheck: no redefined
		local accountInfo = contextData.accountInfo;
		local gameAccountInfo = accountInfo and accountInfo.gameAccountInfo or nil;

		-- Only a basic sanity test is required here.
		if not gameAccountInfo then
			return;
		end

		local sender, guid = GetBattleNetCharacterFullName(gameAccountInfo);
		if sender then
			ED.PlayerCache:InsertAndRetrieve(sender, guid);
			ED.DedicatedFrame:AddFrame(sender);
		end
	end

	local accountInfo = contextData.accountInfo;
	local gameAccountInfo = accountInfo and accountInfo.gameAccountInfo;
	if gameAccountInfo.clientProgram ~= "WoW" then
		return;
	end

	local elementDescription = menuDescription:CreateButton(L.UNIT_POPUPS_EAVESDROP_ON);
	ED.Utils.SetMenuTooltip(elementDescription, L.UNIT_POPUPS_EAVESDROP_ON_HELP);
	elementDescription:SetResponder(OnClick);
	elementDescription:SetData(contextData);
	return elementDescription;
end

local function CreateOpenCharacterEavesdropButton(menuDescription, contextData)
	if not ED.Database:GetGlobalSetting("DedicatedWindows") or not ED.Database:GetGlobalSetting("DedicatedWindowsUnitPopups") then
		return;
	end

	local sender, guid = ResolveCharacterData(contextData);
	local elementDescription = UnitPopups:CreateEavesdropOnButton(menuDescription, sender, guid);
	elementDescription:SetData(contextData);
	return elementDescription;
end

---Shared by the unit popup menu and Config.lua's window menu.
---@param menuDescription table
---@param sender string?
---@param guid string?
---@return table elementDescription
function UnitPopups:CreateEavesdropOnButton(menuDescription, sender, guid)
	local elementDescription = menuDescription:CreateButton(L.UNIT_POPUPS_EAVESDROP_ON);
	ED.Utils.SetMenuTooltip(elementDescription, L.UNIT_POPUPS_EAVESDROP_ON_HELP);
	elementDescription:SetResponder(function()
		if sender then
			ED.PlayerCache:InsertAndRetrieve(sender, guid);
			ED.DedicatedFrame:AddFrame(sender);
		end
	end);
	if not sender or ED.DedicatedFrame:FrameExists(sender) then
		elementDescription:SetEnabled(false);
	end
	return elementDescription;
end

---Shared by the unit popup menu and Config.lua's window menu.
---@param menuDescription table
---@param sender string?
---@param guid string?
---@return table elementDescription
function UnitPopups:CreateEavesdropGroupButton(menuDescription, sender, guid)
	local elementDescription = menuDescription:CreateButton(L.UNIT_POPUPS_EAVESDROP_GROUP);
	elementDescription:CreateTitle(L.UNIT_POPUPS_EAVESDROP_GROUP .. " " .. MAIN_MENU);
	ED.Utils.SetMenuTooltip(elementDescription, L.UNIT_POPUPS_EAVESDROP_GROUP_HELP);

	if not sender then
		elementDescription:SetEnabled(false);
		return elementDescription;
	end

	local function OnClick(targetFrame, hasSender)
		ED.PlayerCache:InsertAndRetrieve(sender, guid);
		if targetFrame and hasSender then
			targetFrame:RemovePlayer(sender);
		elseif targetFrame and not hasSender then
			targetFrame:AddPlayer(sender);
		else
			ED.GroupFrame:AddFrame(sender);
		end
	end

	local groupWindows = ED.GroupFrame:GetGroupWindows(sender);
	if groupWindows then
		for _, group in ipairs(groupWindows) do
			local frame = _G[group.globalName];
			if frame then
				local buttonText = group.displayName;
				if group.hasSender then
					buttonText = "|cnGREEN_FONT_COLOR:" .. group.displayName .. "|r";
				end
				elementDescription:CreateButton(buttonText, function() -- luacheck: no redefined
					OnClick(frame, group.hasSender);
				end);
			end
		end
		elementDescription:CreateDivider();
	end

	elementDescription:CreateButton(L.UNIT_POPUPS_EAVESDROP_GROUP_NEW, function() -- luacheck: no redefined
		OnClick();
	end);

	return elementDescription;
end

local function CreateBattleNetEavesdropGroupMenu(menuDescription, contextData)
	if not ED.Database:GetGlobalSetting("GroupWindows") or not ED.Database:GetGlobalSetting("GroupWindowsUnitPopups") then return; end

	local accountInfo = contextData.accountInfo;
	local gameAccountInfo = accountInfo and accountInfo.gameAccountInfo;
	if not gameAccountInfo or gameAccountInfo.clientProgram ~= "WoW" then
		return;
	end

	local sender, guid = GetBattleNetCharacterFullName(gameAccountInfo);
	local elementDescription = UnitPopups:CreateEavesdropGroupButton(menuDescription, sender, guid);
	elementDescription:SetData(contextData);
	return elementDescription;
end

local function CreateEavesdropGroupMenu(menuDescription, contextData)
	if not ED.Database:GetGlobalSetting("GroupWindows") or not ED.Database:GetGlobalSetting("GroupWindowsUnitPopups") then return; end

	local sender, guid = ResolveCharacterData(contextData);
	local elementDescription = UnitPopups:CreateEavesdropGroupButton(menuDescription, sender, guid);
	elementDescription:SetData(contextData);
	return elementDescription;
end

---Find the native Copy Character Name button already inserted into rootDescription
---by Blizzard's own menu generation, which runs before UnitPopups:OnMenuOpen fires.
---@param rootDescription table
---@return table?
local function FindNativeCopyNameButton(rootDescription)
	for _, elementDescription in rootDescription:EnumerateElementDescriptions() do
		if MenuUtil.GetElementText(elementDescription) == COPY_CHARACTER_NAME then
			return elementDescription;
		end
	end
end

---Insert a button two positions after the "Other Options" subsection title (mimicking Blizzard's
---own placement), or append it at the end if that title isn't present.
---@param menuDescription table
---@param text string
---@return table elementDescription
local function CreateButtonAfterOtherOptions(menuDescription, text)
	local titleIndex;
	for index, elementDescription in menuDescription:EnumerateElementDescriptions() do
		if MenuUtil.GetElementText(elementDescription) == UNIT_FRAME_DROPDOWN_SUBSECTION_TITLE_OTHER then
			titleIndex = index;
			break;
		end
	end

	local elementDescription = MenuUtil.CreateButton(text);
	if titleIndex then
		menuDescription:Insert(elementDescription, titleIndex + 2);
	else
		menuDescription:Insert(elementDescription);
	end
	return elementDescription;
end

local function CreateCopyNameButton(menuDescription, contextData)
	local sender = ResolveCharacterData(contextData);
	if not sender then return; end

	local function OnClick(contextData) -- luacheck: no redefined
		local clickedSender = ResolveCharacterData(contextData);
		if clickedSender then
			ED.CopyTextDialog.ShowCopyName(clickedSender);
		end
	end

	if contextData.which == "FRIEND" then
		-- Eavesdropper's hyperlink click always opens FRIEND (Blizzard hardcodes this
		-- for chat player links), the only path where the native button is tainted.
		-- Leave it untouched when FRIEND opens from the real Blizzard paths instead.
		if not UnitPopups.isHyperlinkOrigin then
			return;
		end

		local nativeButton = FindNativeCopyNameButton(menuDescription);
		if nativeButton then
			-- Native button does not know contextData, so GetData() would end up being nil.
			-- We inject this ourselves and set its Responder to use it with OnClick.
			nativeButton:SetData(contextData);
			nativeButton:SetResponder(OnClick);
			return nativeButton;
		end
	end

	-- Reuse Blizzard's globalstring so translation is already in place.
	local elementDescription;
	if contextData.which == "SELF" then
		-- Blizzard does not expose a native Copy Character Name option for the local player.
		elementDescription = CreateButtonAfterOtherOptions(menuDescription, COPY_CHARACTER_NAME);
	else
		elementDescription = menuDescription:CreateButton(COPY_CHARACTER_NAME);
	end

	elementDescription:SetResponder(OnClick);
	elementDescription:SetData(contextData);
	return elementDescription;
end

local function CreateBattleNetCopyNameButton(menuDescription, contextData)
	local function OnClick(contextData) -- luacheck: no redefined
		local accountInfo = contextData.accountInfo;
		local gameAccountInfo = accountInfo and accountInfo.gameAccountInfo or nil;

		-- Only a basic sanity test is required here.
		if not gameAccountInfo then
			return;
		end

		local clickedSender, _ = GetBattleNetCharacterFullName(gameAccountInfo);
		if clickedSender then
			ED.CopyTextDialog.ShowCopyName(clickedSender);
		end
	end

	local accountInfo = contextData.accountInfo;
	local gameAccountInfo = accountInfo and accountInfo.gameAccountInfo;
	if gameAccountInfo.clientProgram ~= "WoW" then
		return;
	end

	-- Reuse Blizzard's globalstring so translation is already in place.
	local elementDescription;
	if contextData.which == "BN_FRIEND" then
		-- Blizzard does not expose a native Copy Character Name option WoW Bnet friends.
		elementDescription = CreateButtonAfterOtherOptions(menuDescription, COPY_CHARACTER_NAME);
	else
		elementDescription = menuDescription:CreateButton(COPY_CHARACTER_NAME);
	end

	elementDescription:SetResponder(OnClick);
	elementDescription:SetData(contextData);
	return elementDescription;
end

local function CreateToggleMentionsButton(menuDescription, contextData)
	if not ED.Database:GetGlobalSetting("MentionsHistory") or not ED.Database:GetGlobalSetting("MentionsHistoryUnitPopups") then
		return;
	end

	-- Player themselves in chat frame is considered FRIEND, so check that we only run on ourselves.
	local sender = ResolveCharacterData(contextData);
	if not sender or sender ~= ED.Utils.GetUnitName() then
		return;
	end

	local elementDescription = menuDescription:CreateButton(L.SLASH_COMMAND_ED_MENTIONS);
	ED.Utils.SetMenuTooltip(elementDescription, L.UNIT_POPUPS_TOGGLE_MENTIONS_HELP);
	elementDescription:SetResponder(function()
		if ED.MentionsFrame:IsShown() then
			ED.MentionsFrame:Hide();
		else
			ED.MentionsFrame:Open();
		end
	end);
	elementDescription:SetData(contextData);
	return elementDescription;
end

-- ============================================================
-- Registry
-- ============================================================

UnitPopups.MenuElementFactories = {
	OpenBattleNetProfile = CreateOpenBattleNetEavesdropButton,
	OpenEavesdropperOn = CreateOpenCharacterEavesdropButton,
	BattleNetEavesdropGroup = CreateBattleNetEavesdropGroupMenu,
	EavesdropGroup = CreateEavesdropGroupMenu,
	CopyName = CreateCopyNameButton,
	BattleNetCopyName = CreateBattleNetCopyNameButton,
	ToggleMentions = CreateToggleMentionsButton,
};

UnitPopups.MenuEntries = {
	-- BN_FRIEND = { "OpenBattleNetProfile", "BattleNetEavesdropGroup", "BattleNetCopyName" },
	-- CHAT_ROSTER = { "OpenEavesdropperOn", "EavesdropGroup" },
	-- COMMUNITIES_GUILD_MEMBER = { "OpenEavesdropperOn", "EavesdropGroup" },
	-- COMMUNITIES_MEMBER = { "OpenBattleNetProfile", "BattleNetEavesdropGroup", "BattleNetCopyName" },
	-- COMMUNITIES_WOW_MEMBER = { "OpenEavesdropperOn", "EavesdropGroup" },
	-- FRIEND = { "OpenEavesdropperOn", "EavesdropGroup", "ToggleMentions", "CopyName" },
	-- FRIEND_OFFLINE = { "OpenEavesdropperOn", "EavesdropGroup" },
	PARTY = { "OpenEavesdropperOn", "EavesdropGroup" },
	PLAYER = { "OpenEavesdropperOn", "EavesdropGroup" },
	RAID = { "OpenEavesdropperOn", "EavesdropGroup" },
	RAID_PLAYER = { "OpenEavesdropperOn", "EavesdropGroup" },
	-- RECENT_ALLY = { "OpenEavesdropperOn", "EavesdropGroup" },
	-- RECENT_ALLY_OFFLINE = { "OpenEavesdropperOn", "EavesdropGroup" },
	SELF = { "OpenEavesdropperOn", "EavesdropGroup", "ToggleMentions", "CopyName" },
};

ED.UnitPopups = UnitPopups;
