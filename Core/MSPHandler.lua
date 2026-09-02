-- Copyright The Eavesdropper Authors
-- SPDX-License-Identifier: GPL-3.0-or-later

---@type EavesdropperConstants
local Constants = ED.Constants;

---@class EavesdropperMSP
local MSP = {};

---Cache resolved player results for this generation cycle by GUID
---The values are the array TryGetMSPData returns.
---@type table<string, table>
MSP.cache = {};

---A generation cycle is set by GetTime() and dropped when it goes past CACHE_RESET_TIME.
---@type number
local cacheGeneration = 0;

local invalidateCache = false;

---Maps Name-Realm to GUID for everything in MSP.cache.
---MSP and TRP3 identify players by name; the cache itself is keyed by GUID.
---@type table<string, string>
local cacheNames = {};

---Drops every cached player and the name index with it.
local function WipeCache()
	wipe(MSP.cache);
	wipe(cacheNames);
end

---Invalidates the MSP cache; the next TryGetMSPData call drops every cached player.
---Also schedules a redraw through the burst window, so the updated data is drawn.
function MSP.InvalidateCache()
	invalidateCache = true;
	Eavesdropper_SharedFrameMixin.ScheduleDataRefresh();
end

---Drops a single player, leaving every other cached player intact.
---Also schedules a redraw through the burst window, so the updated data is drawn.
---@param playerName string
function MSP.InvalidatePlayer(playerName)
	local key = ED.Utils.AddRealmSuffix(playerName);
	local guid = cacheNames[key];
	if not guid then return; end

	MSP.cache[guid] = nil;
	cacheNames[key] = nil;
	Eavesdropper_SharedFrameMixin.ScheduleDataRefresh();
end

---True once TRP3 has fired WORKFLOW_ON_LOADED. TRP3_API existing does not mean it is ready.
local trp3Ready = false;

---Removes a leading honorific or military title from a name if it is in the COMMON_TITLES list.
---@param name string
---@return string
local function StripTitle(name)
	if not name or name == "" then return name; end
	local firstWord = name:match("^%s*(%S+)");
	if firstWord and ED.Constants.COMMON_TITLES[firstWord:lower()] then
		name = name:gsub("^%s*%S+%s+", "");
	end
	return name;
end

---Returns the class colour hex string for a player GUID, using TRP3 if available.
---@param playerGUID string
---@return string?
local function GetClassColor(playerGUID)
	if not playerGUID then return; end

	local _, englishClass = GetPlayerInfoByGUID(playerGUID);
	if not englishClass then return; end

	local color;
	if trp3Ready then
		color = TRP3_API.GetClassDisplayColor(englishClass);
		color = TRP3_API.GenerateReadableColor(color, TRP3_API.Colors.Black);
		color = color:GenerateHexColor();
	else
		color = C_ClassColor.GetClassColor(englishClass):GenerateHexColor();
	end
	return color;
end

---Returns the flat MSP field table for a player, or nil if no usable data is held.
---Our own fields live in msp.my; msp.char only ever holds data received from others.
---@param playerName string
---@param playerGUID string
---@return table? fields
local function GetMSPFields(playerName, playerGUID)
	if playerGUID and playerGUID == ED.Globals.player_guid then
		return msp.my;
	end

	local char = msp.char[playerName];
	if char and char.supported then
		return char.field;
	end

	return nil;
end

---Retrieves class and race strings from MSP data, falling back to WoW API values.
---@param playerName string
---@param playerGUID string
---@return string? className
---@return string? raceName
local function GetMSPClassAndRace(playerName, playerGUID)
	local className, _, raceName = GetPlayerInfoByGUID(playerGUID);

	local fields = GetMSPFields(playerName, playerGUID);
	if fields then
		className = ED.Utils.StripColorCodes(fields.RC) or className;
		raceName = ED.Utils.StripColorCodes(fields.RA) or raceName;
	end

	return className, raceName;
end

---Retrieves name and colour data from MSP fields.
---@param playerName string
---@param playerGUID string
---@return string? fullName
---@return string? firstName
---@return string? nameColor
---@return string? lastName
---@return string? className
---@return string? raceName
local function GetMSPData(playerName, playerGUID)
	local fields = GetMSPFields(playerName, playerGUID);
	if not fields then return nil, nil, nil; end

	-- msp.my is created empty by LibMSP, so NA is not guaranteed to be present.
	local fullName = fields.NA;
	if not fullName or fullName == "" then return nil, nil, nil; end

	local nameColor = fullName:match("^|c(%x%x%x%x%x%x%x%x)") or GetClassColor(playerGUID);
	fullName = fullName:gsub("^|c%x%x%x%x%x%x%x%x", ""):gsub("|r$", "");
	if fullName == "" then return nil, nil, nil; end

	-- TRP3 has a dedicated title field, so titles are only stripped on the MSP path, and only
	-- on enUS since COMMON_TITLES holds English honorifics.
	if GetLocale() == "enUS" then
		fullName = StripTitle(fullName);
	end

	-- MSP carries the name as a single NA string, match the last two words rather than requiring exactly two.
	local firstName, lastName = fullName:match("(%S+)%s+(%S+)%s*$");

	-- Single word names have no last name, so the name itself is the first name.
	if not firstName then
		firstName = fullName:match("^%s*(%S+)%s*$");
	end

	local className, raceName = GetMSPClassAndRace(playerName, playerGUID);

	return fullName, firstName, nameColor, lastName, className, raceName;
end

---Returns the readable hex colour for a TRP3 profile, using the custom colour if set.
---@param profile table?
---@param playerGUID string
---@return string?
local function GetTRPColor(profile, playerGUID)
	local color;

	if profile and profile.characteristics and profile.characteristics.CH then
		color = TRP3_API.CreateColorFromHexString(profile.characteristics.CH);
	end

	if not color then
		local _, englishClass = GetPlayerInfoByGUID(playerGUID);
		color = englishClass and TRP3_API.GetClassDisplayColor(englishClass);
	end

	if not color then return nil; end

	color = TRP3_API.GenerateReadableColor(color, TRP3_API.Colors.Black);
	return color:GenerateHexColor();
end

---Retrieves class and race strings from a TRP3 profile, falling back to WoW API values.
---@param profile table?
---@param playerGUID string
---@return string? className
---@return string? raceName
local function GetTRPClassAndRace(profile, playerGUID)
	local className, _, raceName = GetPlayerInfoByGUID(playerGUID);

	if profile and profile.characteristics then
		className = profile.characteristics.CL or className;
		raceName = profile.characteristics.RA or raceName;
	end

	return className, raceName;
end

---Retrieves name and colour data from TRP3 profile data.
---@param playerName string
---@param playerGUID string
---@return string? fullName
---@return string? firstName
---@return string? nameColor
---@return string? lastName
---@return string? className
---@return string? raceName
local function GetTRPData(playerName, playerGUID)
	local profile = TRP3_API.register.getUnitIDCurrentProfileSafe(playerName);
	local nameColor = GetClassColor(playerGUID);

	if not profile then
		return nil, nil, nameColor;
	end

	local firstName = TRP3_API.profile.getData(Constants.TRP.FIELDS.FIRST_NAME, profile) or "";
	local lastName = TRP3_API.profile.getData(Constants.TRP.FIELDS.LAST_NAME, profile) or "";
	local fullName = (firstName .. (lastName ~= "" and " " .. lastName or "")):gsub("^%s*(.-)%s*$", "%1");

	if fullName == "" then
		return nil, nil, nameColor;
	end

	nameColor = GetTRPColor(profile, playerGUID);

	local className, raceName = GetTRPClassAndRace(profile, playerGUID);

	return fullName, firstName, nameColor, lastName, className, raceName;
end

---Trims a string and returns nil if the result is empty.
---@param value string?
---@return string?
local function NormalizeString(value)
	if not value then return nil; end
	value = string.trim(value);
	if value == "" then return nil; end
	return value;
end

---Returns true if the MSP library is loaded.
function MSP.IsEnabled()
	return msp ~= nil;
end

---Returns true if TRP3 has finished loading and its API is safe to call.
---@return boolean
function MSP.IsTRPReady()
	return trp3Ready;
end

---Called from the TRP3 module once WORKFLOW_ON_LOADED fires. Any result cached before this
---point was resolved without TRP3 data, so the cache is dropped as well.
function MSP.SetTRPReady()
	if trp3Ready then return; end

	trp3Ready = true;
	MSP.InvalidateCache();

	if not ED.Globals.initialized then return; end

	ED.Keywords:ParseList();
	ED.QuestText.RefreshPlayerPreferredName();
end

---Attempts to retrieve the MSP/TRP3 name and colour of a player, using a short-lived cache.
---@param playerName string
---@param playerGUID string
---@param forceInvalidate boolean?
---@return string? fullName
---@return string? firstName
---@return string? nameColor
---@return string? lastName
---@return string? className
---@return string? raceName
function MSP.TryGetMSPData(playerName, playerGUID, forceInvalidate)
	if not MSP.IsEnabled() then return nil, nil; end
	if not playerGUID or not playerName then return nil, nil; end
	if forceInvalidate then invalidateCache = true; end

	local now = GetTime();

	-- Drop the whole generation cycle when an invalidation is pending, or when the max time
	-- expires it. Invalidation is event-driven now, so the max time only catches missed events.
	local cacheMaxTime = Constants.MSP.CACHE_RESET_TIME;
	if invalidateCache or (cacheMaxTime > 0 and (now - cacheGeneration) > cacheMaxTime) then
		WipeCache();
		cacheGeneration = now;
		invalidateCache = false;
	end

	-- Return the cached result if this player was already resolved this generation cycle.
	local cached = MSP.cache[playerGUID];
	if cached then
		return
			NormalizeString(cached[1]),
			NormalizeString(cached[2]),
			cached[3],
			NormalizeString(cached[4]),
			NormalizeString(cached[5]),
			NormalizeString(cached[6]);
	end

	local fullName, firstName, nameColor, lastName, className, raceName;

	-- If we have (non-default profile) TRP data available we can avoid a full profile lookup.
	if trp3Ready and AddOn_TotalRP3 and playerGUID then
		local player = AddOn_TotalRP3.Player.static.CreateFromGUID(playerGUID);
		if player then
			local profileID = player:GetProfileID();
			local hasNonDefaultProfile = profileID and TRP3_API.profile.isDefaultProfile(profileID) == false;

			if hasNonDefaultProfile then
				fullName  = NormalizeString(player:GetFullName());
				firstName = NormalizeString(player:GetFirstName());
				lastName  = NormalizeString(player:GetLastName());
				className = NormalizeString(player:GetCustomClass());
				raceName  = NormalizeString(player:GetCustomRace());
				nameColor = player:GetCustomColorForDisplay() or GetClassColor(playerGUID);
			end
		end
	end

	-- no TRP cache (or no TRP at all, do a fresh request).
	if not fullName then
		if trp3Ready then
			fullName, firstName, nameColor, lastName, className, raceName = GetTRPData(playerName, playerGUID);
		else
			fullName, firstName, nameColor, lastName, className, raceName = GetMSPData(playerName, playerGUID);
		end

		-- Normalise all returned strings immediately
		fullName  = NormalizeString(fullName);
		firstName = NormalizeString(firstName);
		lastName  = NormalizeString(lastName);
		className = NormalizeString(className);
		raceName  = NormalizeString(raceName);
	end

	-- Normalise to ColorMixin, falling back to class colour.
	nameColor = ED.Utils.NormalizeColor(nameColor) or ED.Utils.NormalizeColor(GetClassColor(playerGUID));

	-- Store the result in the current generation cycle.
	-- A nil colour means MSP had nothing and GetPlayerInfoByGUID could not resolve the GUID.
	-- Nothing will tell us when that changes, so leave it uncached and resolve again next draw.
	if nameColor then
		MSP.cache[playerGUID] = { fullName, firstName, nameColor, lastName, className, raceName };
		cacheNames[ED.Utils.AddRealmSuffix(playerName)] = playerGUID;
	end

	return fullName, firstName, nameColor, lastName, className, raceName;
end

---Pending debounce ticker for MSP field update callbacks.
---@type table?
local pendingRefresh;

---Registers the MSP field-update callback and wires up keyword/name refresh on change.
function MSP.Init()
	if not MSP.IsEnabled() then return; end

	table.insert(msp.callback["updated"], function(senderID, field)
		if not Constants.MSP_RELEVANT_FIELDS[field] then return; end

		-- Other players: drop their entry only; a refresh here would fire on every event.
		if ED.Globals.player_sender_name ~= senderID then
			MSP.InvalidatePlayer(senderID);
			return;
		end

		-- Cancel any pending refresh before scheduling a new one.
		if pendingRefresh then
			pendingRefresh:Cancel();
			pendingRefresh = nil;
		end

		-- Debounce: wait 0.5 s in case multiple fields update in the same frame.
		pendingRefresh = C_Timer.NewTicker(0.5, function()
			pendingRefresh = nil;
			MSP.InvalidatePlayer(senderID);
			ED.Keywords:ParseList();
			ED.QuestText.RefreshPlayerPreferredName();
		end, 1);
	end);
end

ED.MSP = MSP;
