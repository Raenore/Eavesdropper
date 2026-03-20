-- Copyright The Eavesdropper Authors
-- SPDX-License-Identifier: Apache-2.0

---@type EavesdropperPlayerName
local PlayerName = ED.PlayerName;

---@class EavesdropperQuestText
local QuestText = {};

-- We only handle customizations (beyond the OOC name) if there is an addon loaded that is supported.
local INSTALLED_QUEST_TEXT_ADDON;

---Returns the currently cached preferred (RP) name for the player.
---@return string?
function QuestText.GetPlayerPreferredName()
	return PlayerName.preferredName;
end

---Refreshes the preferred name from MSP, only when a supported addon is active and MSP is enabled.
function QuestText.RefreshPlayerPreferredName()
	if not INSTALLED_QUEST_TEXT_ADDON or not ED.MSP.IsEnabled() then return; end
	PlayerName.RefreshPlayerPreferredName();
end

---Substitutes the player's preferred name into quest text, respecting display mode and addon guards.
---@param questText string
---@return string
function QuestText.SubstitutePlayerPreferredName(questText)
	if not INSTALLED_QUEST_TEXT_ADDON or ED.Database:GetSetting("NPCAndQuestNameDisplayMode") == 3 or not ED.Database:GetSetting("UseRPNameInQuestText") then
		return questText;
	end

	return PlayerName:SubstitutePlayerPreferredName(questText);
end

---Returns the name of the installed supported addon, or nil if none are active.
---@return string?
function QuestText.SupportedAddonsInstalled()
	return INSTALLED_QUEST_TEXT_ADDON;
end

local SUPPORTED_ADDONS = { "DialogueUI" };
function QuestText.Init()
	for _, name in ipairs(SUPPORTED_ADDONS) do
		if C_AddOns.IsAddOnLoaded(name) then
			INSTALLED_QUEST_TEXT_ADDON = name;
			break;
		end
	end
	-- We do not call RefreshPlayerPreferredName() here as it is called in MSP.Init() later
	-- or whenever the first SubstitutePlayerPreferredName call is by a supported addon.
end

ED.QuestText = QuestText;
