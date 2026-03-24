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
	if not ED.Database:GetGlobalSetting("DedicatedWindows") and not ED.Database:GetGlobalSetting("GroupWindows") then
		return; -- Don't show when Dedicated and Group Windows are disabled.
	elseif not owner or owner:IsForbidden() then
		return; -- Invalid or forbidden owner.
	elseif not self:ShouldCustomizeMenus() then
		return; -- Menu customizations are disabled.
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
	return ED.Database:GetGlobalSetting("DedicatedWindowsUnitPopups") and true or false;
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
	local sender = string.join("-", characterName or UNKNOWNOBJECT, realmName or GetNormalizedRealmName());
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
local function resolveCharacterData(contextData)
	local unit = contextData.unit;
	local name = contextData.name;
	local server = contextData.server;
	local sender = string.join("-", name or UNKNOWNOBJECT, server or GetNormalizedRealmName());
	local guid = contextData.playerLocation and contextData.playerLocation.guid or nil;

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

	local elementDescription = menuDescription:CreateButton(L.UNIT_POPUPS_EAVESDROP_ON);
	elementDescription:SetResponder(OnClick);
	elementDescription:SetData(contextData);
	return elementDescription;
end

local function CreateOpenCharacterEavesdropButton(menuDescription, contextData)
	if not ED.Database:GetGlobalSetting("DedicatedWindows") or not ED.Database:GetGlobalSetting("DedicatedWindowsUnitPopups") then
		return;
	end

	local function OnClick(contextData) -- luacheck: no redefined
		local sender, guid = resolveCharacterData(contextData);
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

local function CreateEavesdropGroupMenu(menuDescription, contextData)
	if not ED.Database:GetGlobalSetting("GroupWindows") then
		return;
	end

	local function OnClick(contextData, targetFrame, hasSender) -- luacheck: no redefined
		local sender, guid = resolveCharacterData(contextData);
		if sender then
			ED.PlayerCache:InsertAndRetrieve(sender, guid);
			if targetFrame and hasSender then
				targetFrame:RemovePlayer(sender);
			elseif targetFrame and not hasSender then
				targetFrame:AddPlayer(sender);
			else
				ED.GroupFrame:AddFrame(sender);
			end
		end
	end

	-- Resolve sender once for membership checks across all group buttons
	local sender = resolveCharacterData(contextData);

	local elementDescription = menuDescription:CreateButton(L.UNIT_POPUPS_EAVESDROP_GROUP);
	elementDescription:CreateTitle(L.UNIT_POPUPS_EAVESDROP_GROUP .. " " .. MAIN_MENU);

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
					OnClick(contextData, frame, group.hasSender);
				end);
			end
		end
		elementDescription:CreateDivider();
	end

	elementDescription:CreateButton(L.UNIT_POPUPS_EAVESDROP_GROUP_NEW, function() -- luacheck: no redefined
		OnClick(contextData);
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
	EavesdropGroup = CreateEavesdropGroupMenu,
};

UnitPopups.MenuEntries = {
	BN_FRIEND = { "OpenBattleNetProfile" },
	CHAT_ROSTER = { "OpenEavesdropperOn", "EavesdropGroup" },
	COMMUNITIES_GUILD_MEMBER = { "OpenEavesdropperOn", "EavesdropGroup" },
	COMMUNITIES_MEMBER = { "OpenBattleNetProfile" },
	COMMUNITIES_WOW_MEMBER = { "OpenEavesdropperOn", "EavesdropGroup" },
	FRIEND = { "OpenEavesdropperOn", "EavesdropGroup" },
	FRIEND_OFFLINE = { "OpenEavesdropperOn", "EavesdropGroup" },
	PARTY = { "OpenEavesdropperOn", "EavesdropGroup" },
	PLAYER = { "OpenEavesdropperOn", "EavesdropGroup" },
	RAID = { "OpenEavesdropperOn", "EavesdropGroup" },
	RAID_PLAYER = { "OpenEavesdropperOn", "EavesdropGroup" },
	SELF = { "OpenEavesdropperOn", "EavesdropGroup" },
};

ED.UnitPopups = UnitPopups;
