-- Copyright The Eavesdropper Authors
-- SPDX-License-Identifier: Apache-2.0

---@type EavesdropperConstants
local Constants = ED.Constants;

---@class EavesdropperMSP
local MSP = {};

MSP.cache = {
	guid = nil;
	data = nil;
	time = 0;
};

---@param name string
---@return string
local function StripTitle(name)
	if not name or name == "" then
		return name;
	end
	local firstWord = name:match("^%s*(%S+)");
	if firstWord and ED.Constants.COMMON_TITLES[firstWord:lower()] then
		name = name:gsub("^%s*%S+%s+", "");
	end
	return name;
end

---@param playerGUID string
---@return string?
local function GetClassColor(playerGUID)
	if not playerGUID then return; end

	local _, englishClass = GetPlayerInfoByGUID(playerGUID);
	local color;
	if TRP3_API then
		color = TRP3_API.GetClassDisplayColor(englishClass);
		color = TRP3_API.GenerateReadableColor(color, TRP3_API.Colors.Black);
		color = color:GenerateHexColor();
	else
		color = C_ClassColor.GetClassColor(englishClass):GenerateHexColor();
	end
	return color;
end

---@param playerName string
---@param playerGUID string
---@return string className
---@return string raceName
local function GetMSPClassAndRace(playerName, playerGUID)
	local className, _, raceName = GetPlayerInfoByGUID(playerGUID);

	if msp.char[playerName] and msp.char[playerName].supported then
		className = ED.Utils.StripColorCodes(msp.char[playerName].field.RC) or className;
		raceName = ED.Utils.StripColorCodes(msp.char[playerName].field.RA) or raceName;
	end

	return className, raceName;
end

---GetMSPData retrieves name and color from MSP
---@param playerName string
---@param playerGUID string
---@return string? fullName
---@return string? firstName
---@return string? nameColor
---@return string? lastName
---@return string? className
---@return string? raceName
local function GetMSPData(playerName, playerGUID)
	if not msp.char[playerName] or not msp.char[playerName].supported then
		return nil, nil, nil;
	end

	local fullName = msp.char[playerName].field.NA;
	local nameColor = fullName:match("^|c(%x%x%x%x%x%x%x%x)") or GetClassColor(playerGUID);
	fullName = fullName:gsub("^|c%x%x%x%x%x%x%x%x", ""):gsub("|r$", "");
	if fullName == "" then return nil, nil, nil; end

	fullName = GetLocale() == "enUS" and StripTitle(fullName);
	local firstName, lastName = fullName:match("^(%S+)%s+(%S+)$");

	local className, raceName = GetMSPClassAndRace(playerName, playerGUID);

	return fullName, firstName, nameColor, lastName, className, raceName;
end

---GetTRPColor returns hex color for a TRP3 profile
---@param profile table?
---@param playerGUID string
---@return string
local function GetTRPColor(profile, playerGUID)
	local _, englishClass = GetPlayerInfoByGUID(playerGUID);
	local color = TRP3_API.GetClassDisplayColor(englishClass);

	if profile and profile.characteristics then
		color = profile.characteristics.CH and TRP3_API.CreateColorFromHexString(profile.characteristics.CH) or color;
	end

	color = TRP3_API.GenerateReadableColor(color, TRP3_API.Colors.Black);
	return color:GenerateHexColor();
end

---GetTRPClassAndRace retrieves class and race from TRP3 profile
---@param profile table?
---@param playerGUID string
---@return string className
---@return string raceName
local function GetTRPClassAndRace(profile, playerGUID)
	local className, _, raceName = GetPlayerInfoByGUID(playerGUID);

	if profile and profile.characteristics then
		className = profile.characteristics.CL or className;
		raceName = profile.characteristics.RA or raceName;
	end

	return className, raceName;
end

---GetTRPData retrieves name and color from TRP3
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

---Attempts to retrieve the MSP/TRP3 name and color of a player
---@param playerName string
---@param playerGUID string
---@param isKeywords boolean?
---@return string? fullName
---@return string? firstName
---@return string? nameColor
---@return string? lastName
---@return string? className
---@return string? raceName
function MSP.TryGetMSPData(playerName, playerGUID)
	if msp == nil then return nil, nil; end
	if not playerGUID or not playerName then return nil, nil; end

	local now = GetTime();

	-- Return cached result if same GUID and still valid
	if MSP.cache.guid == playerGUID and MSP.cache.data and (now - MSP.cache.time) <= Constants.MSP.CACHE_RESET_TIME then
		local cached = MSP.cache.data;
		return strtrim(cached[1]), strtrim(cached[2]), cached[3], strtrim(cached[4]), strtrim(cached[5]), strtrim(cached[6]);
	end

	local fullName, firstName, nameColor, lastName, className, raceName;

	-- Check TRP cache if exists
	if AddOn_TotalRP3 and playerGUID then
		local player = AddOn_TotalRP3.Player.static.CreateFromGUID(playerGUID);
		if player then
			local profileID = player:GetProfileID();
			local hasNonDefaultProfile = profileID and TRP3_API and TRP3_API.profile.isDefaultProfile(profileID) == false;

			if hasNonDefaultProfile then
				fullName  = strtrim(player:GetFullName() or "");
				firstName = strtrim(player:GetFirstName() or "");
				lastName  = strtrim(player:GetLastName() or "");
				className = strtrim(player:GetCustomClass() or "");
				raceName  = strtrim(player:GetCustomRace() or "");
				nameColor = player:GetCustomColorForDisplay() or GetClassColor(playerGUID);
			end
		end
	end

	-- no TRP cache (or no TRP at all, do a fresh request).
	if not fullName then
		if TRP3_API then
			fullName, firstName, nameColor, lastName, className, raceName = GetTRPData(playerName, playerGUID);
		else
			fullName, firstName, nameColor, lastName, className, raceName = GetMSPData(playerName, playerGUID);
		end

		-- Trim all returned strings immediately
		fullName  = strtrim(fullName or "");
		firstName = strtrim(firstName or "");
		lastName  = strtrim(lastName or "");
		className = strtrim(className or "");
		raceName  = strtrim(raceName or "");
	end

	-- Normalize colors to ColorMixin
	nameColor = ED.Utils.NormalizeColor(nameColor) or ED.Utils.NormalizeColor(GetClassColor(playerGUID));

	-- Cache the trimmed result
	MSP.cache.guid = playerGUID;
	MSP.cache.time = now;
	MSP.cache.data = { fullName, firstName, nameColor, lastName, className, raceName };

	return fullName, firstName, nameColor, lastName, className, raceName;
end

ED.MSP = MSP;
