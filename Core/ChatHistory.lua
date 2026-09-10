-- Copyright The Eavesdropper Authors
-- SPDX-License-Identifier: GPL-3.0-or-later

---@class EavesdropperChatEntry
---@field id number Line ID of the chat entry
---@field t number Timestamp
---@field e string Event name
---@field m string Message text
---@field s string Sender (Name-Realm)
---@field c string? Uppercase channel token (no spaces)
---@field p boolean? True if own player wrote the message
---@field g string? Player GUID, generally always set but nil for test messages.
---@field sm string? Split Marker (so old messages don't break on changing them).
---@field mn EavesdropperMentionReason? Mention reason (stored as a bitmask); nil when the message was not aimed at the player.
---@field test boolean? For debug messages, true for test and generally nil otherwise.
---@field tn string? Emote target's Name-Realm, frozen once resolved.
---@field tg string? Emote target's GUID, frozen alongside tn.

---@class EavesdropperChatHistory
---@field history table<string, EavesdropperChatEntry[]> Per-sender chat history
---@field list table<number, EavesdropperChatEntry> Global index of entries by ID
---@field minEntryId number
---@field nextEntryId number
---@field deduper table<number, number> Deduplication timestamps by lineID, current generation
---@field deduperPrevious table<number, number> Deduplication timestamps by lineID, previous generation
---@field deduperRotatedAt number GetTime() the current generation began
---@field byTime table<number, EavesdropperChatEntry> Legacy migration index keyed by timestamp
---@field mentions number[] Ascending entry ids flagged as mentions, derived (not saved in SVs)
local ChatHistory = {};

ChatHistory.byTime = {};
ChatHistory.deduper = {};
ChatHistory.deduperPrevious = {};
ChatHistory.deduperRotatedAt = 0;
ChatHistory.minEntryId = 0;
ChatHistory.history = {};
ChatHistory.list = {};
ChatHistory.mentions = {};
ChatHistory.nextEntryId = 1;

---@type EavesdropperConstants
local Constants = ED.Constants;

---PruneAndRebuild Rebuilds list index and prunes expired entries
---@param now number
---@return number? minLineId
---@return number maxLineId
function ChatHistory:PruneAndRebuild(now)
	local DisablePruning = false; -- dev flag: disable expiration pruning (local set)
	local ForcePruneAll = false; -- dev flag: removes all history (local set, highest priority)

	local minLineId;
	local maxLineId = 0;
	local mentionIds = {};

	for sender, chatData in pairs(self.history) do
		local nextIndex = 1;

		for i = 1, #chatData do
			local entry = chatData[i];
			if entry then
				local isExpired = now > (entry.t or 0) + Constants.CHAT_HISTORY.EXPIRE_AFTER;

				local shouldKeep;

				if ForcePruneAll then
					shouldKeep = false;
				elseif DisablePruning then
					shouldKeep = true;
				else
					shouldKeep = not isExpired;
				end

				if shouldKeep then
					chatData[i] = nil;
					chatData[nextIndex] = entry;
					nextIndex = nextIndex + 1;

					self.list[entry.id] = entry;

					if entry.mn then
						mentionIds[#mentionIds + 1] = entry.id;
					end

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

	-- Entries are grouped by sender, so ids come out unsorted; sort before appending.
	table.sort(mentionIds);
	for _, id in ipairs(mentionIds) do
		self.mentions[#self.mentions + 1] = id;
	end

	return minLineId, maxLineId;
end

---UpgradeBareNames Upgrades old entries without realm suffix
function ChatHistory:UpgradeBareNames()
	if not self.byTime then return; end

	local byTimeKeys = {};
	for ts in pairs(self.byTime) do
		byTimeKeys[#byTimeKeys + 1] = ts;
	end

	table.sort(byTimeKeys, function(a, b) return a > b; end);

	for _, ts in ipairs(byTimeKeys) do
		local entry = self.byTime[ts];
		if entry and entry.sender and not ED.Utils.HasRealmSuffix(entry.sender) then
			local fullSender = ED.PlayerCache:GetSenderEntryByTime(entry.sender);
			if fullSender then
				entry.sender = fullSender;
				self.history[fullSender] = self.history[fullSender] or {};
				self.history[fullSender][#self.history[fullSender] + 1] = entry;
			end
		end
	end
end

---BackfillGUIDs Fills missing GUIDs per sender history
function ChatHistory:BackfillGUIDs()
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
	self.mentions = {};
	self.deduper = {};
	self.deduperPrevious = {};
	self.deduperRotatedAt = 0;
	self.byTime = self.byTime or {};

	local now = time();

	local minLineId, maxLineId = self:PruneAndRebuild(now);

	self:UpgradeBareNames();
	self:BackfillGUIDs();

	self.minEntryId = minLineId or maxLineId;
	self.nextEntryId = (maxLineId or 0) + 1;
end

---Returns the most recent chat entries for a player filtered for the given frame.
---@param player string Player name
---@param maxEntries number? Maximum number of entries to return
---@param frame table? Frame whose filters to apply; defaults to ED.Frame
---@return EavesdropperChatEntry[]? entries Array of chat entries, or nil if none
function ChatHistory:GetPlayerHistory(player, maxEntries, frame)
	if not player or not self.history[player] then
		return nil;
	end

	local targetFrame = frame or ED.Frame;
	local chat = self.history[player];
	local entries = {};
	local limit = maxEntries or 50;

	for i = #chat, 1, -1 do
		if ED.ChatFilters:HasEvent(chat[i].e, targetFrame) then
			tinsert(entries, 1, chat[i]);
			if #entries >= limit then
				break;
			end
		end
	end

	return entries;
end

---@param entryId number
---@return EavesdropperChatEntry?
function ChatHistory:GetEntry(entryId)
	return self.list[entryId];
end

---Like GetPlayerHistory, but anchored on entryId instead of "now": returns everything from
---the newest entry down through entryId, plus up to padding more (older) entries beyond it.
---@param player string Player name
---@param entryId number Entry to anchor on
---@param padding number Older entries to include past entryId
---@param frame table? Frame whose filters to apply; defaults to ED.Frame
---@return EavesdropperChatEntry[]? entries Oldest-first, or nil if entryId isn't in this player's history
function ChatHistory:GetPlayerHistoryAroundEntry(player, entryId, padding, frame)
	if not player or not self.history[player] then
		return nil;
	end

	local targetFrame = frame or ED.Frame;
	local chat = self.history[player];
	local entries = {};
	local found = false;
	local extra = 0;

	for i = #chat, 1, -1 do
		if ED.ChatFilters:HasEvent(chat[i].e, targetFrame) then
			tinsert(entries, 1, chat[i]);

			if chat[i].id == entryId then
				found = true;
			elseif found then
				extra = extra + 1;
				if extra >= padding then break; end
			end
		end
	end

	if not found then return nil; end
	return entries;
end

---Returns the most recent mention entries, oldest-first, filtered for the given frame.
---@param maxEntries number? Maximum number of entries to return
---@param frame table? Frame whose filters to apply; defaults to ED.Frame
---@return EavesdropperChatEntry[] entries Array of chat entries flagged as mentions
function ChatHistory:GetMentions(maxEntries, frame)
	local targetFrame = frame or ED.Frame;
	local entries = {};
	local limit = maxEntries or 50;

	for i = #self.mentions, 1, -1 do
		local entry = self.list[self.mentions[i]];
		if entry and ED.ChatFilters:HasEvent(entry.e, targetFrame) and ED.ChatFilters:HasMentionReason(entry.mn) then
			tinsert(entries, 1, entry);
			if #entries >= limit then
				break;
			end
		end
	end

	return entries;
end

---Deduplicates by Blizzard's lineID, unique to one chat line for the whole session, so a repeat
---means the line was redelivered (e.g. by Prat), not a legitimate repeat like fast /roll spam.
---Keeps two generations so a key survives a full window even right before a rotation.
---@param lineID number? Blizzard chat line ID; entries without one are never deduped
---@return boolean True if duplicate, false otherwise
function ChatHistory:IsDuplicate(lineID)
	if not lineID then return false; end

	local now = GetTime();
	local window = Constants.CHAT_HISTORY.DUPLICATE_WINDOW;

	if now - self.deduperRotatedAt >= window then
		self.deduperPrevious = self.deduper;
		self.deduper = {};
		self.deduperRotatedAt = now;
	end

	local last = self.deduper[lineID] or self.deduperPrevious[lineID];
	if last and now - last < window then
		return true;
	end

	self.deduper[lineID] = now;
	return false;
end

---Handle data for blizzard text emote
---@param sender string
---@param message string
---@param advancedFormatting boolean? if called throughed AdvancedFormatter, we ignore notifications
---@return string sender Possibly updated sender name
function ChatHistory:HandleTextEmote(sender, message, advancedFormatting)
	local emoteName = ED.Utils.GetCharacterNameFromEmote(message);
	if emoteName then
		sender = emoteName;
	end
	if advancedFormatting then return sender; end

	if ED.Mentions:IsEmoteAtPlayer(message) then
		if ED.Database:GetSetting("NotificationEmotesSound") then
			ED.Notifications.PlayAlertSound(ED.Enums.NOTIFICATIONS_TYPE.EMOTES);
		end
		if ED.Database:GetSetting("NotificationEmotesFlashTaskbar") then
			ED.Notifications.FlashTaskbar();
		end
	end

	return sender;
end

---Prepends a language tag to the message if the language differs from the default.
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

---Fires sound and taskbar flash notifications if the entry passes filter and skip-channel checks.
---@param entry EavesdropperChatEntry
---@param frame table Frame whose filters to check
---@param soundKey string DB setting key for sound notification
---@param flashKey string DB setting key for taskbar flash
---@param notifType number ED.Enums.NOTIFICATIONS_TYPE value
local function TryNotify(entry, frame, soundKey, flashKey, notifType)
	if ED.Constants.CHANNELS_TO_SKIP_NOTIFICATIONS[entry.e] then return; end
	if not ED.ChatFilters:HasEvent(entry.e, frame) then return; end

	if ED.Database:GetSetting(soundKey) then
		ED.Notifications.PlayAlertSound(notifType);
	end
	if ED.Database:GetSetting(flashKey) then
		ED.Notifications.FlashTaskbar();
	end
end

---Adds a chat message to history, handling deduplication, formatting, and target/emote notifications.
---@param event string Event type
---@param sender string Sender name
---@param message string Message content
---@param language string? Language code
---@param guid string? Sender GUID
---@param channel string? Chat channel
---@param lineID number? Blizzard chat line ID; used as the dedup key when present
---@return EavesdropperChatEntry? chatEntry The created chat entry, or nil if ignored
function ChatHistory:AddEntry(event, sender, message, language, guid, channel, lineID)
	if not sender or sender == "" then return; end
	if not canaccessvalue(message) then return; end
	if message == "" and event ~= "CHAT_MSG_CHANNEL_JOIN" and event ~= "CHAT_MSG_CHANNEL_LEAVE" then return; end
	if self:IsDuplicate(lineID) then return; end

	-- Extract sender data from Blizzard Emote
	if event == "CHAT_MSG_TEXT_EMOTE" then
		sender = self:HandleTextEmote(sender, message);
	end

	-- TRP NPC emote: replace the blank message with the NPC name.
	if event == "CHAT_MSG_EMOTE" and ED.MSP.IsTRPReady() and message == " " then
		message = TRP3_API.chat.getNPCMessageName();
	end

	local isOwn = ED.Utils.IsOwnPlayer(sender, event, guid);
	if isOwn then
		guid = ED.Globals.player_guid;
	end

	-- Resolve Name-Realm if GUID exists (can be nil; secrets also return nil).
	if guid then
		sender = ED.PlayerCache:GetSenderDataFromGUID(guid) or sender;
	end

	-- InsertAndRetrieve returns nil for secret players; drop guid too rather than keep the
	-- rejected value around.
	local newSender, newGuid = ED.PlayerCache:InsertAndRetrieve(sender, guid);
	if newSender then
		sender = newSender;
		guid = newGuid;
	else
		guid = nil;
	end

	self.history[sender] = self.history[sender] or {};

	-- Kept pre-transform for Mentions:Evaluate below, so a substituted raid-target icon or
	-- rewritten link cannot break up a keyword.
	local rawMessage = message;

	message = AddLanguageTag(language, message);
	message = ED.Utils.HandleLinks(message);
	message = SubRaidTargets(message);

	local entry = {
		id = self.nextEntryId,
		t = time(),
		e = event,
		m = message,
		s = sender,
		g = guid, -- Can be tied to Companion Information.
		sm = false,
	};

	-- Freeze the target's identity while it's still live.
	if event == "CHAT_MSG_TEXT_EMOTE" then
		local _, targetSender, targetEntry = ED.PlayerCache:ResolveEmoteSender(entry.m, entry.s);
		if targetSender then
			entry.tn = targetSender;
			entry.tg = targetEntry and targetEntry.guid;
		end
	end

	if channel then
		local c = channel:match("^%S+");
		if c then entry.c = c:upper(); end
	end

	if isOwn then
		entry.p = true;
	end

	local mentionReason = ED.Mentions:Evaluate(entry, rawMessage);
	if mentionReason then
		entry.mn = mentionReason;
		self.mentions[#self.mentions + 1] = entry.id;

		if ED.MentionsFrame then
			ED.MentionsFrame:TryAddMessage(entry);
		end
	end

	self.list[entry.id] = entry;
	self.nextEntryId = self.nextEntryId + 1;
	local history = self.history[sender];
	history[#history + 1] = entry;

	-- Target notifications.
	if not entry.p and ED.Utils.GetUnitName("target") == sender then
		TryNotify(entry, ED.Frame, "NotificationTargetSound", "NotificationTargetFlashTaskbar", ED.Enums.NOTIFICATIONS_TYPE.TARGET);
	end

	-- Forward to the eavesdrop frame if this sender is currently being watched.
	if ED.Frame then
		local eavesdroppedPlayer = ED.Frame.eavesdropped_player;

		if sender == eavesdroppedPlayer or ED.Utils.StripRealmSuffix(sender) == ED.Utils.StripRealmSuffix(eavesdroppedPlayer) then
			ED.Frame:TryAddMessage(entry);
		end
	end

	if entry.s then
		local dedicatedFrame = _G["Eavesdropper_Dedicated_Frame_" .. entry.s];
		if dedicatedFrame then
			if not entry.p then
				TryNotify(entry, dedicatedFrame, "NotificationDedicatedSound", "NotificationDedicatedFlashTaskbar", ED.Enums.NOTIFICATIONS_TYPE.DEDICATED);
			end
			dedicatedFrame:TryAddMessage(entry);
		end
	end

	if entry.s and ED.GroupFrame then
		ED.GroupFrame:ForEachFrame(function(frame)
			if frame:HasPlayer(sender) then
				if not entry.p then
					TryNotify(entry, frame, "NotificationGroupSound", "NotificationGroupFlashTaskbar", ED.Enums.NOTIFICATIONS_TYPE.GROUP);
				end
				frame:TryAddMessage(entry);
			end
		end);
	end

	return entry;
end

ED.ChatHistory = ChatHistory;
