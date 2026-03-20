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

---Handles a specific chat message.
---@param chatFrame table
---@param event string
---@param message string
---@param sender string
---@vararg any
---@return boolean?, string, string, ...
function MainChat:HandleChecks(chatFrame, event, message, sender, ...) -- luacheck: no unused (chatFrame)
	if not message or not canaccessvalue(message) then
		return;
	end

	ED.AdvancedFormatter:DisableNameFormatting(event);
	if event == "CHAT_MSG_TEXT_EMOTE" or event == "CHAT_MSG_SYSTEM" then
		local handled, newMessage, newSender = ED.AdvancedFormatter:HandleChecks(chatFrame, event, message, sender, ...);
		if handled ~= nil then return handled, newMessage, newSender, ...; end
	elseif event == "CHAT_MSG_MONSTER_SAY" then
		message = ED.GossipText.SubstitutePlayerPreferredName(message);
		return false, message, sender, ...;
	else
		local handled, newMessage, newSender = ED.Keywords:HandleChecks(chatFrame, event, message, sender, ...);
		if handled ~= nil then return handled, newMessage, newSender, ...; end
	end

	return false;
end

function MainChat:ToggleAdvancedFormatting()
	toggleFilters(Constants.CHAT_EVENTS_ADVANCED_FORMATTING, ED.Database:GetSetting("ApplyOnMainChat"));
end

function MainChat:ToggleKeywords()
	toggleFilters(Constants.CHAT_EVENTS_KEYWORDS, ED.Database:GetSetting("EnableKeywords"));
end

function MainChat:Toggle()
	self:ToggleAdvancedFormatting();
	self:ToggleKeywords();
end

ED.MainChat = MainChat;
