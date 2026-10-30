-- Copyright The Eavesdropper Authors
-- SPDX-License-Identifier: GPL-3.0-or-later

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

---Sorted timestamps for byTime, newest first. Used for recent-activity iteration.
---@type number[]
local sortedTimes = {};

---Returns a unique GetTime() value for use as a byTime key.
---@return number
function PlayerCache:GetUniqueTime()
	local t = GetTime();
	while self.byTime[t] do
		t = t + Constants.PLAYER_CACHE.TIME;
	end
	return t;
end

---Removes cache entries older than ttl seconds and rebuilds sortedTimes if anything changed.
---@param ttl number Time to live in seconds
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

	-- Rebuild sortedTimes only if something was pruned.
	if changed then
		wipe(sortedTimes);
		for t in pairs(self.byTime) do
			sortedTimes[#sortedTimes + 1] = t;
		end
		table.sort(sortedTimes, function(a, b) return a > b; end);
	end
end

---Loads the player cache from a saved table, rebuilds sortedTimes, and prunes expired entries.
---@param cache table? Saved player cache
---@param ttl number? Time to live in seconds
function PlayerCache:LoadFromSaved(cache, ttl)
	cache = cache or {};
	ttl = ttl or Constants.PLAYER_CACHE.DEFAULT_TTL;

	self.bySender = cache.bySender or {};
	self.byGUID   = cache.byGUID   or {};
	self.byTime   = cache.byTime   or {};

	-- Build sortedTimes
	wipe(sortedTimes);
	for t in pairs(self.byTime) do
		sortedTimes[#sortedTimes + 1] = t;
	end
	table.sort(sortedTimes, function(a, b) return a > b; end);

	self:PruneOldEntries(ttl);
end

---Removes a byTime slot and its sortedTimes entry, if any.
---@param time number?
local function RemoveByTimeSlot(time)
	if not time then return; end

	PlayerCache.byTime[time] = nil;
	for i = #sortedTimes, 1, -1 do
		if sortedTimes[i] == time then
			tremove(sortedTimes, i);
			break;
		end
	end
end

---Inserts or updates a sender <-> GUID mapping across all three indices and persists to CharDB.
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
	if guid and not canaccessvalue(guid) then return; end

	if not Utils.HasRealmSuffix(sender) then
		for fullName, entry in pairs(self.bySender) do
			if Utils.MatchesBareName(fullName, sender) then
				sender = fullName;
				-- The cached guid may belong to a deleted-and-recreated character; this call's is fresher.
				guid = guid or entry.guid;
				break;
			end
		end
	end

	-- Migrate history entries stored under the bare name to the full Name-Realm key.
	-- Regional names have no bare form to migrate.
	if ED.ChatHistory and Utils.HasRealmSuffix(sender) then
		local bareName = Utils.StripRealmSuffix(sender);
		local bareHistory = ED.ChatHistory.history[bareName];

		if bareName ~= sender and bareHistory and #bareHistory > 0 then
			local target = ED.ChatHistory.history[sender] or {};
			ED.ChatHistory.history[sender] = target;

			for _, e in ipairs(bareHistory) do
				e.s = sender;
				if not e.g and guid then
					e.g = guid;
				end
				target[#target + 1] = e;
			end
			ED.ChatHistory.history[bareName] = nil;
		end
	end

	-- Remove the old byTime slot for this sender before reinserting.
	local oldEntry = self.bySender[sender];
	RemoveByTimeSlot(oldEntry and oldEntry.time);

	-- A changed guid leaves its old byGUID entry stale forever otherwise (pruning only walks byTime).
	if oldEntry then
		if not guid and oldEntry.guid then
			guid = oldEntry.guid;
		elseif oldEntry.guid and oldEntry.guid ~= guid then
			self.byGUID[oldEntry.guid] = nil;
		end
	end

	-- Same stale-byGUID risk as above, now for the bare-name entry being replaced.
	if Utils.HasRealmSuffix(sender) then
		local bareName = Utils.StripRealmSuffix(sender);
		local bareEntry = self.bySender[bareName];
		if bareEntry and bareName ~= sender then
			RemoveByTimeSlot(bareEntry.time);
			self.bySender[bareName] = nil;
			if not guid and bareEntry.guid then
				guid = bareEntry.guid;
			elseif bareEntry.guid and bareEntry.guid ~= guid then
				self.byGUID[bareEntry.guid] = nil;
			end
		end
	end

	local cacheTime = self:GetUniqueTime();

	self.bySender[sender] = { guid = guid, time = cacheTime };
	if guid then
		self.byGUID[guid] = { sender = sender, time = cacheTime };
	end
	self.byTime[cacheTime] = { sender = sender, guid = guid };
	tinsert(sortedTimes, 1, cacheTime); -- Newest first.

	-- A bare name just landed in the cache; resume listening for a guild match.
	if not Utils.HasRealmSuffix(sender) and IsInGuild() then
		ED.Events:RegisterEvent("GUILD_ROSTER_UPDATE");
	end

	-- Persist immediately to CharDB.
	if EavesdropperCharDB then
		EavesdropperCharDB.playerCache = {
			bySender = self.bySender,
			byGUID   = self.byGUID,
			byTime   = self.byTime,
		};
	end

	return sender, guid;
end

---Returns the bySender entry for an exact or bare name match.
---@param name string
---@return PlayerCacheEntryBySender? entry
function PlayerCache:GetSenderEntry(name)
	if not name or name == "" then return; end
	local entry = self.bySender[name];
	if entry then return entry; end

	local bareName = Utils.StripRealmSuffix(name);
	if bareName then
		for fullName, data in pairs(self.bySender) do
			if Utils.MatchesBareName(fullName, bareName) then
				return data;
			end
		end
	end
end

---Returns the most recently seen full sender name and bySender entry for a given name.
---@param name string
---@return string? sender
---@return PlayerCacheEntryBySender? entry
function PlayerCache:GetSenderEntryByTime(name)
	if not name or name == "" then return; end
	local bareName = Utils.StripRealmSuffix(name);

	for _, t in ipairs(sortedTimes) do
		local data = self.byTime[t];
		if data and data.sender then
			local sender = data.sender;
			if sender == name or Utils.MatchesBareName(sender, bareName) then
				return sender, self.bySender[sender];
			end
		end
	end
end

---Resolves a sender name from a GUID, backfilling the cache from the WoW API if needed.
---@param guid string
---@return string? sender
function PlayerCache:GetSenderDataFromGUID(guid)
	if not guid then return; end
	if not canaccessvalue(guid) then return; end

	local entry = self.byGUID[guid];
	if entry then return entry.sender; end

	local sender = Utils.GetSenderFromGUID(guid);
	if not sender then return; end

	self:InsertAndRetrieve(sender, guid);
	return sender;
end

---Returns true if bareName appears in message as a standalone whole word.
---Checks every occurrence, since an earlier one can be a substring of a longer name (e.g. "Ann" in "Annabelle").
---@param message string
---@param bareName string
---@return boolean
local function IsWholeWordMatch(message, bareName)
	local searchFrom = 1;

	while true do
		local s, e = message:find(bareName, searchFrom, true);
		if not s then return false; end

		local before = message:sub(s - 1, s - 1);
		local after  = message:sub(e + 1, e + 1);
		if (before == "" or before:match("[%s%p]") ~= nil) and (after == "" or after:match("[%s%p]") ~= nil) then
			return true;
		end

		searchFrom = e + 1;
	end
end

---Unit tokens checked, alongside the current group roster, when a target has no PlayerCache entry.
---@type string[]
local LIVE_TARGET_UNITS = { "target", "mouseover", "focus" };

---Returns a unit's Name-Realm/GUID, or nil if it isn't a resolvable player.
---Rejects GetUnitName's own-name fallback (fires pre-sync) so it isn't paired with a different unit's GUID.
---@param unit string
---@param ownName string?
---@return string? sender
---@return string? guid
local function ResolveUnitSenderGuid(unit, ownName)
	if not UnitExists(unit) or not UnitIsPlayer(unit) then return; end

	local guid = UnitGUID(unit);
	if guid and not canaccessvalue(guid) then return; end

	local sender = Utils.GetUnitName(unit);
	if not sender then return; end
	if guid ~= ED.Globals.player_guid and sender == ownName then return; end

	return sender, guid;
end

---Current group members. Raid tokens include the player, party tokens don't, so includePlayer
---adds you once and skips the raid token that resolves to you.
---@param partyCategory number? LE_PARTY_CATEGORY_*. Nil picks the instance group when in one.
---@param includePlayer boolean? Also return the player.
---@return {sender:string, guid:string?}[]
function PlayerCache:GetGroupRosterUnits(partyCategory, includePlayer)
	local units = {};
	local ownName = Utils.GetUnitName();

	local ownSender;
	if includePlayer then
		local ownGuid;
		ownSender, ownGuid = ResolveUnitSenderGuid("player", ownName);
		if ownSender then
			units[1] = { sender = ownSender, guid = ownGuid };
		end
	end

	local isRaid = IsInRaid(partyCategory);
	local groupPrefix = isRaid and "raid" or "party";
	local numUnits = GetNumGroupMembers(partyCategory);
	if not isRaid then
		numUnits = numUnits - 1;
	end

	for i = 1, numUnits do
		local sender, guid = ResolveUnitSenderGuid(groupPrefix .. i, ownName);
		if sender and sender ~= ownSender then
			units[#units + 1] = { sender = sender, guid = guid };
		end
	end

	return units;
end

---Covers emote targets that were never cached from chat activity but are still visible in-world.
---@return {sender:string, guid:string?}[]
local function GetLiveTargetUnits()
	local units = {};
	local ownName = Utils.GetUnitName();

	for _, unit in ipairs(LIVE_TARGET_UNITS) do
		local sender, guid = ResolveUnitSenderGuid(unit, ownName);
		if sender then
			units[#units + 1] = { sender = sender, guid = guid };
		end
	end

	for _, unitData in ipairs(PlayerCache:GetGroupRosterUnits()) do
		units[#units + 1] = unitData;
	end

	return units;
end

---Resolves and caches a nameplate's player identity as soon as it appears, so they stay
---resolvable through the normal PlayerCache TTL even after their nameplate disappears again.
---@param unitToken string
function PlayerCache:CacheNameplateUnit(unitToken)
	local sender, guid = ResolveUnitSenderGuid(unitToken, Utils.GetUnitName()); -- No arg: own name, for the fallback check.
	if sender then
		self:InsertAndRetrieve(sender, guid);
	end
end

---Finds a live unit whose bare name matches, from a precomputed unit list.
---@param units {sender:string, guid:string?}[]
---@param bareName string
---@return string? sender
---@return string? guid
local function FindUnitByName(units, bareName)
	for _, unitData in ipairs(units) do
		if Utils.MatchesBareName(unitData.sender, bareName) then
			return unitData.sender, unitData.guid;
		end
	end
end

---Resolves a bare character name to a live Name-Realm/GUID via target/mouseover/focus/group.
---@param bareName string
---@return string? sender
---@return string? guid
function PlayerCache:ResolveLiveUnitByName(bareName)
	if not bareName or bareName == "" then return; end
	return FindUnitByName(GetLiveTargetUnits(), bareName);
end

---Upgrades any bare-name bySender entries that match a current group member, instead of waiting
---for their next chat message. Run on login and roster changes.
function PlayerCache:BackfillFromGroupRoster()
	local bareNames = {};
	for sender in pairs(self.bySender) do
		if not Utils.HasRealmSuffix(sender) then
			bareNames[#bareNames + 1] = sender;
		end
	end
	if #bareNames == 0 then return; end

	local liveUnits = GetLiveTargetUnits();
	for _, bareName in ipairs(bareNames) do
		local sender, guid = FindUnitByName(liveUnits, bareName);
		if sender then
			self:InsertAndRetrieve(sender, guid);
		end
	end
end

---GetGuildRosterInfo returns sender and guid directly, without needing a live unit token
---like GetLiveTargetUnits does.
---@return {sender:string, guid:string?}[]
local function GetGuildRosterUnits()
	local units = {};

	for i = 1, GetNumGuildMembers() do
		local name, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, guid = GetGuildRosterInfo(i);
		if name then
			units[#units + 1] = { sender = name, guid = guid };
		end
	end

	return units;
end

---Returns true if any bySender entry is still keyed under a bare (no-realm) name.
---@return boolean
function PlayerCache:HasBareNames()
	for sender in pairs(self.bySender) do
		if not Utils.HasRealmSuffix(sender) then return true; end
	end
	return false;
end

---Upgrades any bare-name bySender entries that match a guild roster member, instead of waiting
---for their next chat message. Run on login and guild roster changes.
---@return boolean madeProgress False once nothing more can resolve against the current roster.
function PlayerCache:BackfillFromGuildRoster()
	if not IsInGuild() then return false; end

	local bareNames = {};
	for sender in pairs(self.bySender) do
		if not Utils.HasRealmSuffix(sender) then
			bareNames[#bareNames + 1] = sender;
		end
	end
	if #bareNames == 0 then return false; end

	local guildUnits = GetGuildRosterUnits();
	local resolved = 0;
	for _, bareName in ipairs(bareNames) do
		local sender, guid = FindUnitByName(guildUnits, bareName);
		if sender then
			self:InsertAndRetrieve(sender, guid);
			resolved = resolved + 1;
		end
	end

	return resolved > 0;
end

---Resolves an emote's target to a sender by bare-name match, preferring the most recently seen
---match, and falling back to live units when PlayerCache has no entry (i.e. the target never spoke).
---@param message string
---@param sourceSender string? Full sender name or Name-Realm
---@return string? bareName
---@return string? sender Full sender name
---@return PlayerCacheEntryByTime? entry
function PlayerCache:ResolveEmoteSender(message, sourceSender)
	if not message or message == "" then return; end

	local sourceBare;
	if sourceSender and sourceSender ~= "" then
		sourceBare = Utils.StripRealmSuffix(sourceSender);
	end

	for _, t in ipairs(sortedTimes) do
		local data = self.byTime[t];
		if data and data.sender then
			local sender = data.sender;
			local bareName = Utils.StripRealmSuffix(sender);

			-- Skip the emote's own sender (both bare and full comparison).
			if bareName and sender ~= sourceSender and bareName ~= sourceBare and IsWholeWordMatch(message, bareName) then
				return bareName, sender, data;
			end
		end
	end

	for _, unitData in ipairs(GetLiveTargetUnits()) do
		local sender = unitData.sender;
		local bareName = Utils.StripRealmSuffix(sender);

		if bareName and sender ~= sourceSender and bareName ~= sourceBare and IsWholeWordMatch(message, bareName) then
			-- Persist so a later reformat (e.g. reopening a dedicated window) hits byTime directly.
			local resolvedSender, resolvedGuid = self:InsertAndRetrieve(sender, unitData.guid);
			return bareName, resolvedSender, { sender = resolvedSender, guid = resolvedGuid };
		end
	end
end

ED.PlayerCache = PlayerCache;
