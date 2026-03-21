-- Copyright The Eavesdropper Authors
-- SPDX-License-Identifier: Apache-2.0

---@type EavesdropperConstants
local Constants = ED.Constants;

---@class EavesdropperMainChat
local MainChat = {};

---Handle Add/Remove on the same function object.
---@type fun(...): boolean?, string?, string?, ...
local mainChatFilterFunc = function(...)
	return ED.ChatHandler:MainChatFilter(...);
end;

---Adds or removes a set of chat event filters.
---@param events string[]
---@param enable boolean
local function toggleFilters(events, enable)
	local filterFunc = enable and ChatFrameUtil.AddMessageEventFilter or ChatFrameUtil.RemoveMessageEventFilter;
	for _, evt in ipairs(events) do
		filterFunc(evt, mainChatFilterFunc);
	end
end

---Returns true if the event is any CHAT_MSG_MONSTER_* variant.
---@param event string
---@return boolean
local function isMonsterEvent(event)
	return event == "CHAT_MSG_MONSTER_SAY"
		or event == "CHAT_MSG_MONSTER_EMOTE"
		or event == "CHAT_MSG_MONSTER_PARTY"
		or event == "CHAT_MSG_MONSTER_YELL"
		or event == "CHAT_MSG_MONSTER_WHISPER";
end

---Routes a chat message through the appropriate handler: AdvancedFormatter, NPCDialogue, or Keywords.
---@param chatFrame table
---@param event string
---@param message string
---@param sender string
---@param ... any
---@return boolean?, string, string, ...
function MainChat:HandleChecks(chatFrame, event, message, sender, ...) -- luacheck: no unused (chatFrame)
	if not message or not canaccessvalue(message) then return; end

	ED.AdvancedFormatter:DisableNameFormatting(event);

	if event == "CHAT_MSG_TEXT_EMOTE" or event == "CHAT_MSG_SYSTEM" then
		local handled, newMessage, newSender = ED.AdvancedFormatter:HandleChecks(chatFrame, event, message, sender, ...);
		if handled ~= nil then return handled, newMessage, newSender, ...; end
	elseif isMonsterEvent(event) then
		message = ED.NPCDialogue.SubstitutePlayerPreferredName(message);
		return false, message, sender, ...;
	else
		local handled, newMessage, newSender = ED.Keywords:HandleChecks(chatFrame, event, message, sender, ...);
		if handled ~= nil then return handled, newMessage, newSender, ...; end
	end

	return false;
end

---Registers or unregisters the advanced formatting filter based on the ApplyOnMainChat setting.
function MainChat:ToggleAdvancedFormatting()
	toggleFilters(Constants.CHAT_EVENTS_ADVANCED_FORMATTING, ED.Database:GetSetting("ApplyOnMainChat"));
end

---Registers or unregisters the keyword filter based on the EnableKeywords setting.
function MainChat:ToggleKeywords()
	toggleFilters(Constants.CHAT_EVENTS_KEYWORDS, ED.Database:GetSetting("EnableKeywords"));
end

---Toggles both the advanced formatting and keyword filters according to current settings.
function MainChat:Toggle()
	self:ToggleAdvancedFormatting();
	self:ToggleKeywords();
end

ED.MainChat = MainChat;
