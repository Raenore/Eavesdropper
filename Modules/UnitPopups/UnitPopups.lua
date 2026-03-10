-- Copyright The Eavesdropper Authors
-- Inspired by Total RP 3
-- SPDX-License-Identifier: Apache-2.0

local L = ED.Localization;

if not Menu or not Menu.ModifyMenu then
	return;
end

---@class EavesdropperUnitPopups
local UnitPopups = {};

UnitPopups.MenuElementFactories = {};
UnitPopups.MenuEntries = {};

function UnitPopups:Init()
	for menuTagSuffix in pairs(UnitPopups.MenuEntries) do
		-- The closure supplied to ModifyMenu needs to be unique on each
		-- iteration of the loop as it acts as an "owner" in a callback
		-- registry behind the scenes. If not unique, successive registrations
		-- will replace previous ones.

		local function OnMenuOpen(owner, rootDescription, contextData)
			self:OnMenuOpen(owner, rootDescription, contextData);
		end

		local menuTag = "MENU_UNIT_" .. menuTagSuffix;
		Menu.ModifyMenu(menuTag, OnMenuOpen);
	end
end

function UnitPopups:OnMenuOpen(owner, rootDescription, contextData)
	if not ED.Database:GetGlobalSetting("DedicatedWindows") then
		return;  -- Don't show when Dedicated Windows is disabled.
	elseif not owner or owner:IsForbidden() then
		return;  -- Invalid or forbidden owner.
	elseif not self:ShouldCustomizeMenus() then
		return;  -- Menu customizations are disabled.
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

function UnitPopups:ShouldCustomizeMenus()
	if not ED.Database:GetGlobalSetting("DedicatedWindowsUnitPopups") then
		return false;
	else
		return true;
	end
end

local function GetBattleNetCharacterFullName(gameAccountInfo)
	local characterName = gameAccountInfo.characterName;
	local realmName = gameAccountInfo.realmName;
	local sender = string.join("-", characterName or UNKNOWNOBJECT, realmName or GetNormalizedRealmName());
	local guid = gameAccountInfo.playerGuid;

	if string.find(sender, UNKNOWNOBJECT, 1, true) == 1 then
		sender = nil;
	end

	return sender, guid;
end

local function CreateOpenBattleNetEavesdropButton(menuDescription, contextData)
	local function OnClick(contextData)  -- luacheck: no redefined
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

	local elementDescription = menuDescription:CreateButton(L.UNIT_POPUPS_EAVESDROP_ON);
	elementDescription:SetResponder(OnClick);
	elementDescription:SetData(contextData);
	return elementDescription;
end

local function CreateOpenCharacterEavesdropButton(menuDescription, contextData)
	local function OnClick(contextData)  -- luacheck: no redefined
		local unit = contextData.unit;
		local name = contextData.name;
		local server = contextData.server;
		local sender = string.join("-", name or UNKNOWNOBJECT, server or GetNormalizedRealmName());
		local guid = contextData.playerLocation.guid;

		if UnitExists(unit) then
			sender = ED.Utils.GetUnitName(unit);
			guid = UnitGUID(unit); -- sanity check
		elseif string.find(sender, UNKNOWNOBJECT, 1, true) == 1 then
			sender = nil;
		end

		if sender then
			ED.PlayerCache:InsertAndRetrieve(sender, guid);
			ED.DedicatedFrame:AddFrame(sender);
		end
	end

	local elementDescription = menuDescription:CreateButton(L.UNIT_POPUPS_EAVESDROP_ON);
	elementDescription:SetResponder(OnClick);
	elementDescription:SetData(contextData);
	return elementDescription;
end

UnitPopups.MenuElementFactories = {
	OpenBattleNetProfile = CreateOpenBattleNetEavesdropButton,
	OpenEavesdropperOn = CreateOpenCharacterEavesdropButton,
};

UnitPopups.MenuEntries = {
	BN_FRIEND = { "OpenBattleNetProfile" },
	CHAT_ROSTER = { "OpenEavesdropperOn" },
	COMMUNITIES_GUILD_MEMBER = { "OpenEavesdropperOn" },
	COMMUNITIES_MEMBER = { "OpenBattleNetProfile" },
	COMMUNITIES_WOW_MEMBER = { "OpenEavesdropperOn" },
	FRIEND = { "OpenEavesdropperOn" },
	FRIEND_OFFLINE = { "OpenEavesdropperOn" },
	PARTY = { "OpenEavesdropperOn" },
	PLAYER = { "OpenEavesdropperOn" },
	RAID = { "OpenEavesdropperOn" },
	RAID_PLAYER = { "OpenEavesdropperOn" },
	SELF = { "OpenEavesdropperOn" },
};

ED.UnitPopups = UnitPopups;
