-- Copyright The Eavesdropper Authors
-- SPDX-License-Identifier: Apache-2.0

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
	else
		handler = ED.Keywords;
	end

	local handled, newMessage, newSender = handler:HandleChecks(chatFrame, event, message, sender, ...);

	if handled ~= nil then
		return handled, newMessage, newSender, ...;
	end

	return false, message, sender, ...;
end

ED.MainChat = MainChat;
