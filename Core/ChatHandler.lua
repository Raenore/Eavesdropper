-- Copyright The Eavesdropper Authors
-- SPDX-License-Identifier: Apache-2.0

---@class EavesdropperChatHandler
local ChatHandler = {};

---ChatFrameFilter Core Blizzard chat message filter
---@param chatFrame table Blizzard chat frame
---@param event string Chat event
---@vararg any
---@return boolean?
local function ChatFrameFilter(chatFrame, event, ...)
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
local function MainChatFilter(chatFrame, event, message, sender, ...)
	return ED.MainChat:HandleChecks(chatFrame, event, message, sender, ...);
end

---Init Registers Blizzard chat events to be filtered
function ChatHandler:Init()
	if type(ChatFrame_AddMessageEventFilter) ~= "function" then
		return;
	end

	local chatEvents = {
		"CHAT_MSG_SAY",
		"CHAT_MSG_EMOTE",
		"CHAT_MSG_TEXT_EMOTE",
		"CHAT_MSG_WHISPER",
		"CHAT_MSG_WHISPER_INFORM",
		"CHAT_MSG_PARTY",
		"CHAT_MSG_PARTY_LEADER",
		"CHAT_MSG_RAID",
		"CHAT_MSG_RAID_LEADER",
		"CHAT_MSG_RAID_WARNING",
		"CHAT_MSG_YELL",
		"CHAT_MSG_GUILD",
		"CHAT_MSG_OFFICER",
		"CHAT_MSG_CHANNEL", -- unused right now
		"CHAT_MSG_CHANNEL_JOIN", -- unused right now
		"CHAT_MSG_CHANNEL_LEAVE", -- unused right now
		"CHAT_MSG_INSTANCE_CHAT",
		"CHAT_MSG_INSTANCE_CHAT_LEADER",
		"CHAT_MSG_SYSTEM",
	};

	local mainChatEvents = {
		"CHAT_MSG_TEXT_EMOTE", -- Advanced Formatting
		"CHAT_MSG_SYSTEM", -- Advanced Formatting
		"CHAT_MSG_SAY", -- Keywords
		"CHAT_MSG_EMOTE", -- Keywords
		"CHAT_MSG_PARTY", -- Keywords
		"CHAT_MSG_PARTY_LEADER", -- Keywords
		"CHAT_MSG_RAID", -- Keywords
		"CHAT_MSG_RAID_LEADER", -- Keywords
		"CHAT_MSG_YELL", -- Keywords
		"CHAT_MSG_GUILD", -- Keywords
		"CHAT_MSG_OFFICER", -- Keywords
		"CHAT_MSG_CHANNEL", -- Keywords (unused right now)
	};

	for _, evt in ipairs(chatEvents) do
		ChatFrame_AddMessageEventFilter(evt, ChatFrameFilter);
	end

	for _, evt in ipairs(mainChatEvents) do
		ChatFrame_AddMessageEventFilter(evt, MainChatFilter);
	end
end

ED.ChatHandler = ChatHandler;
