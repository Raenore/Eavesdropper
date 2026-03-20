-- Copyright The Eavesdropper Authors
-- SPDX-License-Identifier: Apache-2.0

---@class EavesdropperAdvancedFormatter
local AdvancedFormatter = {};

---Whether the sender name filter is currently registered.
AdvancedFormatter.senderNameFormatted = false;

---@param event string
---@param _ any
---@param _ any
---@param sender string
---@param _ any
---@param _ any
---@param _ any
---@param _ any
---@param _ any
---@param _ any
---@param _ any
---@param _ any
---@param _ any
---@param guid string?
---@return string? senderFormatted
local function CreateChatName(event, _, _, sender, _, _, _, _, _, _, _, _, _, guid)
	-- Own player remains "you" or whichever the locale sets.
	if not ED.Database:GetSetting("ApplyOnMainChat") or ED.Utils.IsOwnPlayer(sender, event) or event == "CHAT_MSG_SYSTEM" then
		return;
	end

	-- Resolve Name-Realm if GUID exists (can be nil and secret will also return nil)
	if guid then
		sender = ED.PlayerCache:GetSenderDataFromGUID(guid) or sender;
	end

	-- nil if secrets, guard against that
	local newSender, newGuid = ED.PlayerCache:InsertAndRetrieve(sender, guid);
	if newSender then
		sender = newSender;
		guid = newGuid;
	end

	local entry = {
		t = time(),
		e = event,
		s = sender,
		g = guid,
	};

	local senderFormatted, _ = ED.ChatFormatter:GetFormattedName(entry);
	if senderFormatted then
		sender = senderFormatted;
	end

	return sender;
end

---Registers the sender name filter if not already active.
---Only acts when event is CHAT_MSG_TEXT_EMOTE and the filter is off.
---@param event string
function AdvancedFormatter:EnableNameFormatting(event)
	if event ~= "CHAT_MSG_TEXT_EMOTE" or self.senderNameFormatted then return; end
	self.senderNameFormatted = true;
	ChatFrameUtil.AddSenderNameFilter(CreateChatName);
end

---Removes the sender name filter if currently active.
---Only acts when event is not CHAT_MSG_TEXT_EMOTE and the filter is on.
---@param event string
function AdvancedFormatter:DisableNameFormatting(event)
	if event == "CHAT_MSG_TEXT_EMOTE" or not self.senderNameFormatted then return; end
	self.senderNameFormatted = false;
	ChatFrameUtil.RemoveSenderNameFilter(CreateChatName);
end

---Substitutes targets in a chat message and returns the modified message for the chat frame.
---@param chatFrame table
---@param event string
---@param message string
---@param sender string
---@vararg any
---@return boolean?, string, string, ...
function AdvancedFormatter:HandleChecks(chatFrame, event, message, sender, ...) -- luacheck: no unused (chatFrame)
	if not message or not canaccessvalue(message) then return; end
	if not ED.Database:GetSetting("ApplyOnMainChat") then return; end

	local guid = select(10, ...); -- SYSTEM may not have a GUID
	local msgText = message;
	local msgSender = sender;

	-- System roll messages
	if event == "CHAT_MSG_SYSTEM" then
		msgSender, _, _, _ = ED.Utils.GetRollData(msgText);
		if msgSender then
			event = "ROLL";
		else
			return;
		end
	end

	-- Extract sender data from Blizzard Emote
	if event == "CHAT_MSG_TEXT_EMOTE" then
		msgSender = ED.ChatHistory:HandleTextEmote(sender, message, true);
	end

	if ED.Utils.IsOwnPlayer(msgSender, event) then
		guid = ED.Globals.player_guid;
	end

	-- Resolve Name-Realm if GUID exists
	if guid then
		msgSender = ED.PlayerCache:GetSenderDataFromGUID(guid) or msgSender;
	end

	msgSender, guid = ED.PlayerCache:InsertAndRetrieve(msgSender, guid);

	local entry = {
		t = time(),
		e = event,
		m = msgText,
		s = msgSender,
		g = guid, -- Can be tied to Companion Information
	};

	local name, applyRPName = ED.ChatFormatter:GetFormattedName(entry);
	local msgFinalText;

	if ED.Utils.IsOwnPlayer(sender, event) then
		msgFinalText = entry.m;
	else
		msgFinalText = ED.Utils.StripRealmSuffix(entry.s) .. " " .. ED.ChatFormatter:MsgFormatTextEmoteNoName(entry, name);
	end

	local msgToSend = msgFinalText;

	if entry.e == "CHAT_MSG_TEXT_EMOTE" and applyRPName then
		msgToSend = ED.ChatFormatter:FormatTextEmoteTargetWithRPName(entry, msgFinalText);
		self:EnableNameFormatting(entry.e);
	elseif entry.e == "ROLL" and applyRPName then
		msgToSend = ED.ChatFormatter:MsgFormatTextEmote(entry, name);
	end

	return false, msgToSend, sender, ...;
end

ED.AdvancedFormatter = AdvancedFormatter;
