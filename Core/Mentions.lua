-- Copyright The Eavesdropper Authors
-- SPDX-License-Identifier: GPL-3.0-or-later

---@type EavesdropperConstants
local Constants = ED.Constants;

---@class EavesdropperMentions
local Mentions = {};

---Determines whether a Blizzard emote message is aimed at the player.
---Currently only supports enUS due to an english-only ignore list.
---@param message string
---@return boolean
function Mentions:IsEmoteAtPlayer(message)
	if GetLocale() ~= "enUS" or not message:find(" you[^a-z]") then return false; end

	for _, phrase in ipairs(Constants.CHAT_HISTORY.IGNORE_EMOTES) do
		if StringContains(message, phrase) then
			return false;
		end
	end

	return true;
end

---Evaluates whether a chat entry counts as a mention and what kind by bitmasking it.
---This will run once on message creation and should not be called again at any point.
---@param entry EavesdropperChatEntry
---@param message string Pre-format message text (before AddLanguageTag, HandleLinks, SubRaidTargets)
---@return EavesdropperMentionReason? reason Mention reason (stored as a bitmask), or nil if not a mention
function Mentions:Evaluate(entry, message)
	if entry.p then return nil; end
	if not ED.Database:GetGlobalSetting("MentionsHistory") then return nil; end

	local reason = 0;

	if ED.Database:GetSetting("EnableKeywords") then
		-- Strip colour codes before scanning: a highlighted keyword fails the word-boundary
		-- check otherwise. This was documented prior as "the colour-code trap".
		if ED.Keywords:HasMatch(ED.Utils.StripColorCodes(message)) then
			reason = reason + ED.Enums.MENTION_REASON.KEYWORD;
		end
	end

	-- We can only reliably track emotes aimed at you in Blizzard emotes.
	if entry.e == "CHAT_MSG_TEXT_EMOTE" and self:IsEmoteAtPlayer(message) then
		reason = reason + ED.Enums.MENTION_REASON.EMOTE;
	end

	ED.Debug:Print("Mentions:Evaluate", entry.e, message, reason);

	if reason == 0 then return nil; end
	return reason;
end

ED.Mentions = Mentions;
