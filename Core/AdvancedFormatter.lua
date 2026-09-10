-- Copyright The Eavesdropper Authors
-- SPDX-License-Identifier: GPL-3.0-or-later

---@class EavesdropperAdvancedFormatter
local AdvancedFormatter = {};

---Whether the sender name filter is currently registered.
AdvancedFormatter.senderNameFormatted = false;

---Returns the main chat name display mode override, or nil to fall back to NameDisplayMode.
---@return number?
function AdvancedFormatter:ResolveMainChatDisplayMode()
	if not ED.Database:GetSetting("AdvNameDisplayModeOverride") then return; end
	return ED.Database:GetSetting("AdvNameDisplayMode");
end

---Resolves Name-Realm from guid, then normalizes through the player cache.
---A secret sender or guid is rejected by either call, so the guid is dropped rather than kept mismatched.
---@param sender string
---@param guid string?
---@return string sender
---@return string? guid
local function ResolveSenderAndGuid(sender, guid)
	if guid then
		sender = ED.PlayerCache:GetSenderDataFromGUID(guid) or sender;
	end

	local newSender, newGuid = ED.PlayerCache:InsertAndRetrieve(sender, guid);
	if newSender then
		return newSender, newGuid;
	end

	return sender, nil;
end

---Builds the entry, display name, and RP-name flag shared by HandleChecks and RefreshMainChat.
---@param event string
---@param message string
---@param sender string
---@param guid string?
---@param forceDisplayMode number?
---@param lineID number?
---@return EavesdropperChatEntry? entry Nil for a non-roll CHAT_MSG_SYSTEM message.
---@return string? name
---@return boolean? applyRPName
function AdvancedFormatter:BuildFormattingEntry(event, message, sender, guid, forceDisplayMode, lineID)
	local msgSender = sender;

	if event == "CHAT_MSG_SYSTEM" then
		-- A prior refresh may have hyperlinked the roller's identity; recover it from there instead
		-- of the display text, which could now be an RP name rather than their real character name.
		local linkedSender = message:match("|Hplayer:(.-)|h");
		if linkedSender then
			msgSender = linkedSender;
		else
			-- Prefer the original line an RP-name addon may have already rewritten.
			message = ED.ChatHandler:GetPendingRollMessage(lineID) or message;
			msgSender = ED.Utils.GetRollData(message);
			if msgSender then
				-- Rolls carry no GUID from Blizzard, but a roll from another player is only ever
				-- visible while grouped with them, so the roster can resolve their full identity.
				local resolvedSender, rollGuid = ED.PlayerCache:ResolveLiveUnitByName(msgSender);
				msgSender = resolvedSender or msgSender;
				guid = guid or rollGuid;
			end
		end
		if not msgSender then return; end
		event = "ROLL";
	elseif event == "CHAT_MSG_TEXT_EMOTE" then
		msgSender = ED.ChatHistory:HandleTextEmote(sender, message, true);
	end

	if ED.Utils.IsOwnPlayer(msgSender, event, guid) then
		guid = ED.Globals.player_guid;
	end

	msgSender, guid = ResolveSenderAndGuid(msgSender, guid);

	local entry = {
		t = time(),
		e = event,
		m = message,
		s = msgSender,
		g = guid, -- Can be tied to Companion Information
		sm = false,
	};

	local name, applyRPName = ED.ChatFormatter.GetFormattedName(entry, forceDisplayMode);
	return entry, name, applyRPName;
end

---Builds the replacement sender name for the AddSenderNameFilter callback.
---@param event string
---@param ... any
---@return string? senderFormatted
local function CreateChatName(event, ...)
	local _, _, sender, _, _, _, _, _, _, _, _, _, guid = ...;

	-- Own player remains "you" or whichever the locale sets.
	if not ED.Database:GetSetting("ApplyOnMainChat") or ED.Utils.IsOwnPlayer(sender, event, guid) or event == "CHAT_MSG_SYSTEM" then
		return;
	end

	sender, guid = ResolveSenderAndGuid(sender, guid);

	local entry = {
		t = time(),
		e = event,
		s = sender,
		g = guid,
		sm = false,
	};

	local senderFormatted, _ = ED.ChatFormatter.GetFormattedName(entry, AdvancedFormatter:ResolveMainChatDisplayMode());
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

	local lineID = select(9, ...);
	local guid = select(10, ...); -- SYSTEM may not have a GUID
	local displayMode = self:ResolveMainChatDisplayMode();
	local entry, name, applyRPName = self:BuildFormattingEntry(event, message, sender, guid, displayMode, lineID);
	if not entry then return; end

	local msgFinalText;

	if ED.Utils.IsOwnPlayer(sender, event, guid) then
		msgFinalText = entry.m;
	else
		msgFinalText = ED.Utils.StripRealmSuffix(entry.s) .. " " .. ED.ChatFormatter.MsgFormatTextEmoteNoName(entry, name);
	end

	local msgToSend = msgFinalText;

	if entry.e == "CHAT_MSG_TEXT_EMOTE" and applyRPName then
		msgToSend = ED.ChatFormatter.FormatTextEmoteTargetWithRPName(entry, msgFinalText, displayMode);
		self:EnableNameFormatting(entry.e);
	elseif entry.e == "ROLL" and applyRPName then
		msgToSend = ED.ChatFormatter.MsgFormatTextEmote(entry, ED.Utils.PlayerHyperlink(entry.s, name));
	end

	return false, msgToSend, sender, ...;
end

---True if the chat frame receives emote/roll events natively; replacement addons unregister these.
---@param chatFrame table
---@return boolean
local function IsChatFrameNative(chatFrame)
	return chatFrame:IsEventRegistered("CHAT_MSG_TEXT_EMOTE") or chatFrame:IsEventRegistered("CHAT_MSG_SYSTEM");
end

---Predicate: matches emote lines and rolls.
---@param message string
---@param r number
---@param g number
---@param b number
---@param infoID number
---@param accessID number
---@param typeID number
---@param event string
---@param eventArgs table?
---@return boolean
local function IsReformattableLine(message, r, g, b, infoID, accessID, typeID, event, eventArgs) -- luacheck: no unused (r, g, b, accessID, typeID)
	if eventArgs and event == "CHAT_MSG_TEXT_EMOTE" then
		return true;
	end

	local systemInfo = ChatTypeInfo["SYSTEM"];
	local isRoll = ED.Utils.GetRollData(message) ~= nil;

	return systemInfo ~= nil and infoID == systemInfo.id and isRoll;
end

---Rebuilds emote/roll formatting; emotes from eventArgs, rolls from message.
---@param displayMode number?
---@param message string
---@param r number
---@param g number
---@param b number
---@param infoID number
---@param accessID number
---@param typeID number
---@param event string
---@param eventArgs table?
---@param MessageFormatter function
---@vararg any
---@return string, ...
local function ReformatLine(displayMode, message, r, g, b, infoID, accessID, typeID, event, eventArgs, MessageFormatter, ...)
	local entry, name, applyRPName;

	if eventArgs then
		entry, name, applyRPName = AdvancedFormatter:BuildFormattingEntry(event, eventArgs[1], eventArgs[2], eventArgs[12], displayMode);
	else
		entry, name, applyRPName = AdvancedFormatter:BuildFormattingEntry("CHAT_MSG_SYSTEM", message, nil, nil, displayMode);
	end

	local newMessage = message;

	if entry then
		if entry.e == "CHAT_MSG_TEXT_EMOTE" then
			newMessage = ED.ChatFormatter.FormatTextEmoteTargetWithRPName(entry, message, displayMode);
		elseif entry.e == "ROLL" then
			local rollName = applyRPName and ED.Utils.PlayerHyperlink(entry.s, name) or name;
			newMessage = ED.ChatFormatter.SubstituteNameOccurrence(message, entry.s, rollName);
		end
	end

	return newMessage, r, g, b, infoID, accessID, typeID, event, eventArgs, MessageFormatter, ...;
end

---Retroactively applies emote-target and roll-name formatting to existing main chat lines.
function AdvancedFormatter:RefreshMainChat()
	if ChatFrameUtil and type(ChatFrameUtil.ForEachChatFrame) == "function" then
		local displayMode = self:ResolveMainChatDisplayMode();
		local transform = function(...) return ReformatLine(displayMode, ...); end

		ChatFrameUtil.ForEachChatFrame(function(chatFrame)
			if IsChatFrameNative(chatFrame) then
				chatFrame:TransformMessages(IsReformattableLine, transform);
			end
		end);
	end

	ED.Chattynator.RefreshMessages();
end

ED.AdvancedFormatter = AdvancedFormatter;
