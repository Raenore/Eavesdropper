-- Copyright The Eavesdropper Authors
-- SPDX-License-Identifier: Apache-2.0

---@type EavesdropperConstants
local Constants = ED.Constants;

---@class EavesdropperChatHandler
local ChatHandler = {};

---ChatFrameFilter Core Blizzard chat message filter
---@param chatFrame table Blizzard chat frame
---@param event string Chat event
---@vararg any
---@return boolean?
function ChatHandler:ChatFrameFilter(chatFrame, event, ...)
	local message, sender, language, _, _, _, _, _, channel, _, _, guid = ...;

	if not message or not canaccessvalue(message) then
		return;
	end

	-- No support for channels now (or ever?)
	if event == "CHAT_MSG_CHANNEL" and channel then
		local lower = channel:lower();
		if ED.Constants.IGNORED_CHANNELS[lower] then
			return;
		end
	end

	--[[
	Debug in case the ChatFrame arguments ever change.
	local args = {...};
	print("Event:", event);
	for i, v in ipairs(args) do
		print("Arg" .. i .. ":", v);
	end
	]]

	-- Apply Blizzard chat filters
	local filters = ChatFrameUtil and ChatFrameUtil.GetMessageEventFilters(event);
	if filters and message then
		local skipFilters = message:sub(1, 3) == "|| ";

		if not skipFilters then
			for filterFunc in next, filters do
				if type(filterFunc) == "function" then
					local filtered = {filterFunc(chatFrame, event, ...)};
					if filtered[1] then
						-- Fully filtered
						return;
					elseif type(filtered[2]) == "string" then
						-- Modified message
						local newMessage = filtered[2];

						-- Preserve TRP emote edge-cases
						if event == "CHAT_MSG_EMOTE" then
							local firstTwoOrig = message:sub(1,2);
							local firstTwoNew  = newMessage:sub(1,2);
							if (firstTwoOrig == "'s" and firstTwoNew ~= "'s") or (firstTwoOrig == ", " and firstTwoNew ~= ", ") then
								break;
							end
						end

						message  = newMessage;
						sender   = filtered[3];
						language = filtered[4];
						channel  = filtered[10];
						guid     = filtered[13];
					end
				end
			end
		end
	end

	-- Store chat history
	if event == "CHAT_MSG_SYSTEM" then
		local rollSender = ED.Utils.GetRollData(message);
		if sender then
			ED.ChatHistory:AddEntry("ROLL", rollSender, message);
		end
	else
		ED.ChatHistory:AddEntry(event, sender, message, language, guid, channel);
	end

	return false;
end

---MainChatFilter Runs checks on chat entries
---@param chatFrame table Blizzard chat frame
---@param event string Chat event
---@param message string Chat message
---@param sender string Sender name
---@vararg any
---@return boolean?
function ChatHandler:MainChatFilter(chatFrame, event, message, sender, ...)
	return ED.MainChat:HandleChecks(chatFrame, event, message, sender, ...);
end

---Init Registers Blizzard chat events to be filtered
function ChatHandler:Init()
	if type(ChatFrameUtil.AddMessageEventFilter) ~= "function" then
		return;
	end

	for _, evt in ipairs(Constants.CHAT_EVENTS_ALL) do
		ChatFrameUtil.AddMessageEventFilter(evt, function(...)
			return self:ChatFrameFilter(...);
		end);
	end

	ED.MainChat:Toggle();
end

ED.ChatHandler = ChatHandler;
