-- Copyright The Eavesdropper Authors
-- SPDX-License-Identifier: Apache-2.0

---@type EavesdropperPlayerName
local PlayerName = ED.PlayerName;

---@class EavesdropperNPCDialogue
local NPCDialogue = {};

---Returns the currently cached preferred (RP) name for the player.
---@return string?
function NPCDialogue.GetPlayerPreferredName()
	return PlayerName.preferredName;
end

---Refreshes the preferred name from MSP if MSP is enabled.
function NPCDialogue.RefreshPlayerPreferredName()
	if not ED.MSP.IsEnabled() then return; end
	PlayerName.RefreshPlayerPreferredName();
end

---Substitutes the player's preferred name into NPC dialogue, respecting display mode settings.
---@param npcDialogue string
---@return string
function NPCDialogue.SubstitutePlayerPreferredName(npcDialogue)
	if ED.Database:GetSetting("NPCAndQuestNameDisplayMode") == 3 or not ED.Database:GetSetting("UseRPNameInNPCDialogue") then
		return npcDialogue;
	end

	return PlayerName:SubstitutePlayerPreferredName(npcDialogue);
end

function NPCDialogue.Init()
	NPCDialogue.RefreshPlayerPreferredName();
end

ED.NPCDialogue = NPCDialogue;
