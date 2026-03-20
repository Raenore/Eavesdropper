-- Copyright The Eavesdropper Authors
-- SPDX-License-Identifier: Apache-2.0

---@type EavesdropperPlayerName
local PlayerName = ED.PlayerName;

---@class EavesdropperQuestText
local QuestText = {};

-- We only handle customizations (beyond the OOC name) if there is an addon loaded that is supported.
local INSTALLED_QUEST_TEXT_ADDON;

function QuestText.GetPlayerPreferredName()
	return PlayerName.preferredName;
end

function QuestText.RefreshPlayerPreferredName()
	if not INSTALLED_QUEST_TEXT_ADDON or not ED.MSP.IsEnabled() then
		return;
	end
	PlayerName.RefreshPlayerPreferredName();
end

---@param questText string
function QuestText.SubstitutePlayerPreferredName(questText)
	if not INSTALLED_QUEST_TEXT_ADDON or ED.Database:GetSetting("QuestTextNameDisplayMode") == 3 then
		return questText;
	end

	return PlayerName:SubstitutePlayerPreferredName(questText);
end

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
