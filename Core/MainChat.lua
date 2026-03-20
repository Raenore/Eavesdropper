-- Copyright The Eavesdropper Authors
-- SPDX-License-Identifier: Apache-2.0

---@type EavesdropperConstants
local Constants = ED.Constants;

---@class EavesdropperMainChat
local MainChat = {};

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

	local handler;
	if event == "CHAT_MSG_TEXT_EMOTE" or event == "CHAT_MSG_SYSTEM" then
		handler = ED.AdvancedFormatter;
	elseif event == "CHAT_MSG_MONSTER_SAY" then
		message = ED.GossipText.SubstitutePlayerPreferredName(message);
		return false, message, sender, ...;
	else
		ED.AdvancedFormatter:DisableNameFormatting();
		handler = ED.Keywords;
	end

	local handled, newMessage, newSender = handler:HandleChecks(chatFrame, event, message, sender, ...);

	if handled ~= nil then
		return handled, newMessage, newSender, ...;
	end

	return false, message, sender, ...;
end

function MainChat:ToggleAdvancedFormatting()
	if ED.Database:GetSetting("ApplyOnMainChat") then
		for _, evt in ipairs(Constants.CHAT_EVENTS_ADVANCED_FORMATTING) do
			ChatFrameUtil.AddMessageEventFilter(evt, function(...)
				return ED.ChatHandler:MainChatFilter(...);
			end);
		end
	else
		for _, evt in ipairs(Constants.CHAT_EVENTS_ADVANCED_FORMATTING) do
			ChatFrameUtil.RemoveMessageEventFilter(evt, function(...)
				return ED.ChatHandler:MainChatFilter(...);
			end);
		end
	end
end

function MainChat:ToggleKeywords()
	if ED.Database:GetSetting("EnableKeywords") then
		for _, evt in ipairs(Constants.CHAT_EVENTS_KEYWORDS) do
			ChatFrameUtil.AddMessageEventFilter(evt, function(...)
				return ED.ChatHandler:MainChatFilter(...);
			end);
		end
	else
		for _, evt in ipairs(Constants.CHAT_EVENTS_KEYWORDS) do
			ChatFrameUtil.RemoveMessageEventFilter(evt, function(...)
				return ED.ChatHandler:MainChatFilter(...);
			end);
		end
	end
end

function MainChat:Toggle()
	self:ToggleAdvancedFormatting();
	self:ToggleKeywords();
end

ED.MainChat = MainChat;
