-- Copyright The Eavesdropper Authors
-- SPDX-License-Identifier: GPL-3.0-or-later

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

---Returns true if NPC dialogue substitution is off or already handled by TRP3RPNameInQuests.
---@return boolean
local function IsSubstitutionDisabled()
	return ED.Database:GetSetting("NPCAndQuestNameDisplayMode") == 3
		or not ED.Database:GetSetting("UseRPNameInNPCDialogue")
		or (TRP3RPNameInQuests and TRP3RPNameInQuests.API and type(TRP3RPNameInQuests.API.IsTextModifierEnabled) == "function"
			and TRP3RPNameInQuests.API:IsTextModifierEnabled("npcspeech"));
end

---Substitutes the player's preferred name into NPC dialogue, respecting display mode settings.
---@param npcDialogue string?
---@return string?
function NPCDialogue.SubstitutePlayerPreferredName(npcDialogue)
	if not npcDialogue or IsSubstitutionDisabled() then return npcDialogue; end
	return PlayerName.SubstitutePlayerPreferredName(npcDialogue);
end

---Rewrites player names to RP names in NPC bubbles; all are rewritten blindly (no sender identity).
function NPCDialogue.SubstituteChatBubbles()
	if IsSubstitutionDisabled() or C_ChatInfo.InChatMessagingLockdown() then return; end

	RunNextFrame(function()
		for _, bubble in pairs(C_ChatBubbles.GetAllChatBubbles()) do
			for i = 1, bubble:GetNumChildren() do
				local child = select(i, bubble:GetChildren());
				if child and child.String then
					child.String:SetText(PlayerName.SubstitutePlayerPreferredName(child.String:GetText()));
					child.String:SetWidth(child.String:GetWrappedWidth());
				end
			end
		end
	end);
end

---Currently unused; no call site.
function NPCDialogue.Init()
	NPCDialogue.RefreshPlayerPreferredName();
end

ED.NPCDialogue = NPCDialogue;
