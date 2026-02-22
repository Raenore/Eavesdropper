-- Copyright The Eavesdropper Authors
-- SPDX-License-Identifier: Apache-2.0

---@class EavesdropperChatEntry
---@field id number Line ID of the chat entry
---@field t number Timestamp
---@field e string Event name
---@field m string Message text
---@field s string Sender (Name-Realm)
---@field c string? Uppercase channel token (no spaces)
---@field p boolean? True if own player wrote the message
---@field g string Player GUID

---@class EavesdropperChatHistory
---@field history table<string, EavesdropperChatEntry[]> Per-sender chat history
---@field list table<number, EavesdropperChatEntry> Global index of entries by ID
---@field minEntryId number
---@field nextEntryId number
---@field deduper table<string, number> Deduplication timestamps
local ChatHistory = {};

ChatHistory.byTime = {};
ChatHistory.deduper = {};
ChatHistory.minEntryId = 0;
ChatHistory.history = {};
ChatHistory.list = {};
ChatHistory.nextEntryId = 1;

---@type EavesdropperConstants
local Constants = ED.Constants;

---pruneAndRebuild Rebuilds list index and prunes expired entries
---@param now number
---@return number? minLineId
---@return number maxLineId
function ChatHistory:pruneAndRebuild(now)
	local minLineId;
	local maxLineId = 0;

	for sender, chatData in pairs(self.history) do
		local nextIndex = 1;

		for i = 1, #chatData do
			local entry = chatData[i];
			if entry then
				if now <= (entry.t or 0) + Constants.CHAT_HISTORY.EXPIRE_AFTER then
					chatData[i] = nil;
					chatData[nextIndex] = entry;
					nextIndex = nextIndex + 1;

					self.list[entry.id] = entry;

					if entry.s then
						entry.s, entry.g = ED.PlayerCache:InsertAndRetrieve(entry.s, entry.g);
					end

					minLineId = minLineId and math.min(minLineId, entry.id) or entry.id;
					maxLineId = math.max(maxLineId, entry.id);
				else
					chatData[i] = nil;
				end
			end
		end

		if #chatData == 0 then
			self.history[sender] = nil;
		end
	end

	return minLineId, maxLineId;
end

---upgradeBareNames Upgrades old entries without realm suffix
---@return nil
function ChatHistory:upgradeBareNames()
	if not self.byTime then return; end

	local byTimeKeys = {};
	for ts in pairs(self.byTime) do
		tinsert(byTimeKeys, ts);
	end

	table.sort(byTimeKeys, function(a, b) return a > b end);

	for _, ts in ipairs(byTimeKeys) do
		local entry = self.byTime[ts];
		if entry and entry.sender and not ED.Utils.HasRealmSuffix(entry.sender) then
			local fullSender = ED.PlayerCache:GetSenderEntryByTime(entry.sender);
			if fullSender then
				entry.sender = fullSender;
				self.history[fullSender] = self.history[fullSender] or {};
				tinsert(self.history[fullSender], entry);
			end
		end
	end
end

---backfillGUIDs Fills missing GUIDs per sender history
---@return nil
function ChatHistory:backfillGUIDs()
	for _, chatData in pairs(self.history) do
		local knownGUID;

		for _, entry in ipairs(chatData) do
			if entry.g then
				knownGUID = entry.g;
			elseif knownGUID then
				entry.g = knownGUID;
			end
		end
	end
end

---LoadFromSaved Loads saved chat history and prunes expired entries
---@param savedHistory table<string, EavesdropperChatEntry[]> Saved chat history
---@return nil
function ChatHistory:LoadFromSaved(savedHistory)
	self.history = savedHistory or {};
	self.list = {};
	self.deduper = {};
	self.byTime = self.byTime or {};

	local now = time();

	local minLineId, maxLineId = self:pruneAndRebuild(now);

	self:upgradeBareNames();
	self:backfillGUIDs();

	self.minEntryId = minLineId or maxLineId;
	self.nextEntryId = (maxLineId or 0) + 1;
end

---Returns the most recent chat entries for a player
---@param player string Player name
---@param maxEntries number? Maximum number of entries to return
---@return EavesdropperChatEntry[]? entries Array of chat entries, or nil if none
function ChatHistory:GetPlayerHistory(player, maxEntries)
	if not player or not self.history[player] then
		return nil;
	end

	local chat = self.history[player];
	local entries = {};
	local limit = maxEntries or 50;

	for i = #chat, 1, -1 do
		if ED.ChatFilters:HasEvent(chat[i].e) then
			tinsert(entries, 1, chat[i]);
			if #entries >= limit then
				break;
			end
		end
	end

	return entries;
end

---Checks if a chat message is a duplicate
---@param event string Event name
---@param sender string Sender name
---@param message string Message content
---@param channel string? Chat channel
---@param language string? Message language
---@param guid string? Sender GUID
---@return boolean True if duplicate, false otherwise
function ChatHistory:IsDuplicate(event, sender, message, channel, language, guid)
	local now = GetTime();
	local key =
		(event or "") .. "|" ..
		(sender or "") .. "|" ..
		(message or "") .. "|" ..
		(channel or "") .. "|" ..
		(language or "") .. "|" ..
		(guid or "");

	local last = self.deduper[key];
	if last and now - last < 0.5 then
		return true;
	end

	self.deduper[key] = now;
	return false;
end

---Handle data for blizzard text emote
---@param sender string
---@param message string
---@return string sender Possibly updated sender name
function ChatHistory:HandleTextEmote(sender, message)
	local emoteName = ED.Utils.GetCharacterNameFromEmote(message);
	if emoteName then sender = emoteName; end

	local playSound = ED.Database:GetSetting("NotificationEmotesSound");
	local flashTaskbar = ED.Database:GetSetting("NotificationEmotesFlashTaskbar");

	if (playSound or flashTaskbar) and GetLocale() == "enUS" and message:find(" you") then
		for _, phrase in ipairs(Constants.CHAT_HISTORY.IGNORE_EMOTES) do
			if message:find(phrase, 1, true) then
				return sender; -- skip notifications
			end
		end

		if playSound then
			ED.Notifications:PlayAlertSound(ED.Enums.NOTIFICATIONS_TYPE.EMOTES);
			end
		if flashTaskbar then
			ED.Notifications:FlashTaskbar();
		end
	end

	return sender;
end

---@param language string? Language code
---@param message string Message text
---@return string formattedMsg Formatted message with language tag
local function AddLanguageTag(language, message)
	if language and language ~= "" and language ~= GetDefaultLanguage() then
		return string.format("[%s] %s", language, message);
	end
	return message;
end

---@param message string Chat message
---@return string formattedMsg Formatted message with raid target icons
local function SubRaidTargets(message)
	return message:gsub("{(%S-)}", function(term)
		local t = ED.Enums.RAID_TARGETS[term:lower()];
		if t then
			return "|TInterface/TargetingFrame/UI-RaidTargetingIcon_" .. t .. ":0|t";
		end
	end);
end

---AddEntry Adds a chat message entry to history, handling duplicates, formatting, and notifications
---@param event string Event type
---@param sender string Sender name
---@param message string Message content
---@param language string? Language code
---@param guid string? Sender GUID
---@param channel string? Chat channel
---@return EavesdropperChatEntry? chatEntry The created chat entry, or nil if ignored
function ChatHistory:AddEntry(event, sender, message, language, guid, channel)
	if not sender or sender == "" then return; end
	if message == "" and event ~= "CHAT_MSG_CHANNEL_JOIN" and event ~= "CHAT_MSG_CHANNEL_LEAVE" then return; end
	if self:IsDuplicate(event, sender, message, channel, language, guid) then return; end

	-- Extract sender data from Blizzard Emote
	if event == "CHAT_MSG_TEXT_EMOTE" then
		sender = ChatHistory:HandleTextEmote(sender, message);
	end

	-- TRP NPC emote
	if event == "CHAT_MSG_EMOTE" and TRP3_API and message == " " then
		message = TRP3_API.chat.getNPCMessageName();
	end

	local isOwn = ED.Utils.IsOwnPlayer(sender, event);

	if isOwn then
		guid = UnitGUID("player");
	end

	-- Resolve Name-Realm if GUID exists
	if guid then
		sender = ED.PlayerCache:GetSenderDataFromGUID(guid) or sender;
	end

	sender, guid = ED.PlayerCache:InsertAndRetrieve(sender, guid);
	self.history[sender] = self.history[sender] or {};

	message = AddLanguageTag(language, message);
	message = ED.Utils.HandleLinks(message);
	message = SubRaidTargets(message);

	local entry = {
		id = self.nextEntryId,
		t = time(),
		e = event,
		m = message,
		s = sender,
		g = guid, -- Can be tied to Companion Information
	};

	if channel then
		local c = channel:match("^%S+");
		if c then entry.c = c:upper(); end
	end

	if isOwn then
		entry.p = true;
	end

	self.list[entry.id] = entry;
	self.nextEntryId = self.nextEntryId + 1;
	tinsert(self.history[sender], entry);

	-- Target notifications
	local targetName = ED.Utils.GetUnitName("target");
	local notifyTargetSound = ED.Database:GetSetting("NotificationTargetSound");
	local notifyTargetFlash = ED.Database:GetSetting("NotificationTargetFlashTaskbar");

	if (notifyTargetSound or notifyTargetFlash)
		and not ED.Constants.CHANNELS_TO_SKIP_NOTIFICATIONS[entry.e]
		and targetName == sender
		and not entry.p then
		if notifyTargetSound then ED.Notifications:PlayAlertSound(ED.Enums.NOTIFICATIONS_TYPE.TARGET); end
		if notifyTargetFlash then ED.Notifications:FlashTaskbar(); end
	end

	-- Add message to eavesdrop frame if relevant
	if ED.Frame then
		local eavesdroppedPlayer = ED.Frame.eavesdropped_player;
		if sender == eavesdroppedPlayer or ED.Utils.StripRealmSuffix(sender) == ED.Utils.StripRealmSuffix(eavesdroppedPlayer) then
			ED.Frame:TryAddMessage(entry);
		end
	end

	return entry;
end

ED.ChatHistory = ChatHistory;
