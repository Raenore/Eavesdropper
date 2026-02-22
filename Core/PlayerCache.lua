-- Copyright The Eavesdropper Authors
-- SPDX-License-Identifier: Apache-2.0

---@type EavesdropperConstants
local Constants = ED.Constants;

---@class PlayerCacheEntryBySender
---@field guid string?
---@field time number

---@class PlayerCacheEntryByGUID
---@field sender string
---@field time number

---@class PlayerCacheEntryByTime
---@field guid string?
---@field sender string

---@class EavesdropperPlayerCache
---@field bySender table<string, PlayerCacheEntryBySender>
---@field byGUID table<string, PlayerCacheEntryByGUID>
---@field byTime table<number, PlayerCacheEntryByTime>
local PlayerCache = {};
PlayerCache.bySender = {};
PlayerCache.byGUID   = {};
PlayerCache.byTime   = {};

---@type EavesdropperUtils
local Utils = ED.Utils;

---@type number[] Sorted timestamps for recent activity
local sortedTimes = {};

---Get a unique timestamp for byTime keys
---@return number
function PlayerCache:_GetUniqueTime()
	local t = GetTime();
	while self.byTime[t] do
		t = t + Constants.PLAYER_CACHE.TIME;
	end
	return t;
end

---Prune cache entries older than TTL seconds.
---@param ttl number Time to live in seconds
---@return nil
function PlayerCache:PruneOldEntries(ttl)
	if not ttl or ttl <= 0 then return; end

	local now = GetTime();
	local changed = false;

	for t, data in pairs(self.byTime) do
		if t + ttl < now then
			if data.sender then
				self.bySender[data.sender] = nil;
			end
			if data.guid then
				self.byGUID[data.guid] = nil;
			end
			self.byTime[t] = nil;
			changed = true;
		end
	end

	-- Rebuild sortedTimes only if something changed
	if changed then
		wipe(sortedTimes);
		for t in pairs(self.byTime) do
			tinsert(sortedTimes, t);
		end
		table.sort(sortedTimes, function(a,b) return a>b end);
	end
end

---Load the player cache from saved table and prune old entries
---@param cache table? Saved player cache
---@param ttl number? Time to live in seconds
---@return nil
function PlayerCache:LoadFromSaved(cache, ttl)
	cache = cache or {};
	ttl = ttl or Constants.PLAYER_CACHE.DEFAULT_TTL;

	self.bySender = cache.bySender or {};
	self.byGUID   = cache.byGUID   or {};
	self.byTime   = cache.byTime   or {};

	-- Build sortedTimes
	wipe(sortedTimes);
	for t in pairs(self.byTime) do
		tinsert(sortedTimes, t);
	end
	table.sort(sortedTimes, function(a,b) return a>b end);

	self:PruneOldEntries(ttl);
end

---Insert or update a sender <-> GUID mapping and save into CharDB
---@param sender string
---@param guid string?
---@return string sender Full sender name with realm
---@return string? guid GUID associated with sender
function PlayerCache:InsertAndRetrieve(sender, guid)
	if (not sender or sender == "") and guid then
		sender = self:GetSenderDataFromGUID(guid);
		if not sender then return; end
	end
	if not sender or sender == "" then return; end

	if not Utils.HasRealmSuffix(sender) then
		for fullName, entry in pairs(self.bySender) do
			if fullName:match("^" .. sender .. "%-") then
				sender = fullName;
				guid = entry.guid or guid;
				break;
			end
		end
	end

	-- Migrate old messages from bare name to full sender
	if ED.ChatHistory and Utils.HasRealmSuffix(sender) then
		local bareName = Utils.StripRealmSuffix(sender);
		local bareHistory = ED.ChatHistory.history[bareName];

		if bareHistory and #bareHistory > 0 then
			local target = ED.ChatHistory.history[sender] or {};
			ED.ChatHistory.history[sender] = target;

			for _, e in ipairs(bareHistory) do
				e.s = sender;
				if not e.g and guid then
					e.g = guid;
				end
				tinsert(target, e);
			end
			ED.ChatHistory.history[bareName] = nil;
		end
	end

	local oldEntry = self.bySender[sender];
	if oldEntry and oldEntry.time then
		self.byTime[oldEntry.time] = nil;
		for i=#sortedTimes,1,-1 do
			if sortedTimes[i] == oldEntry.time then
				tremove(sortedTimes,i);
				break;
			end
		end
	end

	if Utils.HasRealmSuffix(sender) then
		local bareName = Utils.StripRealmSuffix(sender);
		self.bySender[bareName] = nil;
	end

	local cacheTime = self:_GetUniqueTime();

	-- Insert/update indices
	self.bySender[sender] = { guid = guid, time = cacheTime };
	if guid then
		self.byGUID[guid] = { sender = sender, time = cacheTime };
	end
	self.byTime[cacheTime] = { sender = sender, guid = guid };
	tinsert(sortedTimes, 1, cacheTime); -- newest first

	-- Persist to CharDB
	if EavesdropperCharDB then
		EavesdropperCharDB.playerCache = {
			bySender = self.bySender,
			byGUID   = self.byGUID,
			byTime   = self.byTime,
		};
	end

	return sender, guid;
end

---Get a PlayerCacheEntryBySender by exact or bare name.
---@param name string
---@return PlayerCacheEntryBySender? entry
function PlayerCache:GetSenderEntry(name)
	if not name or name == "" then return; end
	local entry = self.bySender[name];
	if entry then return entry; end

	local bareName = name:match("^([^%-]+)");
	if bareName then
		for fullName, data in pairs(self.bySender) do
			if fullName:match("^" .. bareName .. "%-") then
				return data;
			end
		end
	end
end

---Get a PlayerCacheEntryBySender using most recent activity first.
---@param name string
---@return string? sender
---@return PlayerCacheEntryBySender? entry
function PlayerCache:GetSenderEntryByTime(name)
	if not name or name == "" then return; end
	local bareName = name:match("^([^%-]+)") or name;

	for _, t in ipairs(sortedTimes) do
		local data = self.byTime[t];
		if data and data.sender then
			local sender = data.sender;
			if sender == name or sender:match("^" .. bareName .. "%-") then
				return sender, self.bySender[sender];
			end
		end
	end
end

---Resolve sender name from a GUID, backfilling cache
---@param guid string
---@return string? sender
function PlayerCache:GetSenderDataFromGUID(guid)
	if not guid then return; end
	local entry = self.byGUID[guid];
	if entry then return entry.sender; end

	local _, _, _, _, _, name, realm = GetPlayerInfoByGUID(guid);
	if not name then return; end
	if not realm or realm == "" then realm = GetNormalizedRealmName(); end
	if not realm then return; end

	local sender = name .. "-" .. realm;
	self:InsertAndRetrieve(sender, guid);
	return sender;
end

---Resolve a sender mentioned in a text emote
---@param message string
---@param sourceSender string? Full sender name or Name-Realm
---@return string? bareName
---@return string? sender Full sender name
---@return PlayerCacheEntryByTime? entry
function PlayerCache:ResolveEmoteSender(message, sourceSender)
	if not message or message == "" then return; end

	local sourceBare;
	if sourceSender and sourceSender ~= "" then
		sourceBare = sourceSender:match("^([^%-]+)");
	end

	for _, data in pairs(self.byTime) do
		local sender = data.sender;
		if sender then
			local bareName = sender:match("^([^%-]+)");

			-- skip self (both bare and full comparison)
			if bareName and sender ~= sourceSender and bareName ~= sourceBare then

				local s, e = message:find(bareName, 1, true);
				if s then
					local before = message:sub(s - 1, s - 1);
					local after  = message:sub(e + 1, e + 1);

					-- ensure full word match
					if (before == "" or before:match("[%s%p]")) and (after  == "" or after:match("[%s%p]")) then
						return bareName, sender, data;
					end
				end
			end
		end
	end
end

ED.PlayerCache = PlayerCache;
