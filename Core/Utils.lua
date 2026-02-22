-- Copyright The Eavesdropper Authors
-- SPDX-License-Identifier: Apache-2.0

---@class EavesdropperUtils
local Utils = {};

-- ============================================================================
-- COLOR UTILITIES
-- ============================================================================

---NormalizeColor Ensures a color value is returned as a valid ColorMixin
---@param color string|table|ColorMixin
---@return ColorMixin?
function Utils.NormalizeColor(color)
	if type(color) == "string" then
		-- Strip leading '#' if present
		if color:sub(1,1) == "#" then color = color:sub(2); end

		-- Convert 6-digit or 8-digit hex string to ColorMixin
		if #color == 6 then
			return CreateColorFromHexString("ff" .. color);
		elseif #color == 8 then
			return CreateColorFromHexString(color);
		end

	elseif type(color) == "table" then
		-- Table with r,g,b,[a] -> ColorMixin
		if color.r and color.g and color.b then
			return CreateColor(color.r, color.g, color.b, color.a or 1);
		end

	elseif type(color) == "userdata" and color.WrapTextInColorCode then
		-- Already a ColorMixin
		return color;
	end

	return nil;
end

-- ============================================================================
-- STRING AND TEXT UTILITIES
-- ============================================================================

---Utils.EscapePattern Escapes Lua pattern characters in a string.
---@param text string
---@return string
function Utils.EscapePattern(text)
	return text:gsub("([^%w])", "%%%1");
end

---NormalizeColors Ensures all color codes are properly closed
---@param message string
---@return string
function Utils.NormalizeColors(message)
	if not message or not canaccessvalue(message) then return message; end

	local opens = 0;

	for _ in message:gmatch("|c%x%x%x%x%x%x%x%x") do
		opens = opens + 1;
	end

	for _ in message:gmatch("|r") do
		opens = opens - 1;
	end

	if opens > 0 then
		message = message .. string.rep("|r", opens);
	end

	return message;
end

---StripColorCodes Removes WoW color codes from text
---@param text string
---@return string
function Utils.StripColorCodes(text)
	if type(text) ~= "string" then return text; end

	text = text:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "");

	return text;
end

---HandleLinks Converts URLs to clickable WoW hyperlinks
---@param message string
---@return string
function Utils.HandleLinks(message)
	if not message or message == "" then return ""; end

	message = " " .. message .. " ";
	local links = {};

	local function storeLink(a, url, b)
		table.insert(links, url);
		return a .. "\001" .. #links .. "\001" .. b;
	end

	message = message:gsub("([%s%(])(https?://[^%)%s]+)([%s%)])", storeLink);
	message = message:gsub("([%s%(])([A-Za-z0-9-%.]+[A-Za-z0-9-]+%.[A-Za-z0-9]+/[^%)%s]*)([%s%)])", storeLink);

	message = message:gsub("\001(%d+)\001", function(i)
		local url = links[tonumber(i)];
		return "|cFF0FBEF4|Hedurl:" .. url .. "|h" .. url .. "|h|r";
	end);

	return message:sub(2, -2);
end

---SanitizeKeywordInput Trims and normalizes comma-separated keywords
---@param text string
---@return string
function Utils.SanitizeKeywordInput(text)
	local words = {};

	for word in text:gmatch("([^,]*)") do
		word = word:match("^%s*(.-)%s*$");
		if word ~= "" then
			table.insert(words, word);
		end
	end

	return table.concat(words, ", ");
end

---WrapTextInColor Wraps text in a WoW color code
---@param text string
---@param color ColorMixin
---@return string
function Utils.WrapTextInColor(text, color)
	if not text or type(text) ~= "string" or not canaccessvalue(text) then return text; end
	if not color then return text; end
	return color:WrapTextInColorCode(text);
end


---RGBtoHex Converts 0–1 RGB values to a WoW color escape sequence
---@param r number
---@param g number
---@param b number
---@return string
function Utils.RGBtoHex(r, g, b)
	return string.format("|cFF%02X%02X%02X", r * 255, g * 255, b * 255);
end

---GetCharacterNameFromEmote Extracts the character name from an emote message
---@param msg string?
---@return string?
function Utils.GetCharacterNameFromEmote(msg)
	if type(msg) ~= "string" then return; end
	return msg:match("^([^%s]+%-[^%s]+)");
end

-- RANDOM_ROLL_RESULT: "%s rolls %d (%d-%d)"
local SYSTEM_ROLL_PATTERN = RANDOM_ROLL_RESULT;
SYSTEM_ROLL_PATTERN = SYSTEM_ROLL_PATTERN:gsub("%%%d?$?s", "(%%S+)");
SYSTEM_ROLL_PATTERN = SYSTEM_ROLL_PATTERN:gsub("%%%d?$?d", "(%%d+)");
SYSTEM_ROLL_PATTERN = SYSTEM_ROLL_PATTERN:gsub("%(%(%%%d?$?d%+%)%-%(%%%d?$?d%+%)%)", "%%((%%d+)%%-(%%d+)%%)");

---Extracts roll information from a system message
---@param msg string
---@return string? sender
---@return number? roll
---@return number? min
---@return number? max
function Utils.GetRollData(msg)
	if type(msg) ~= "string" then return; end
	local sender, roll, min, max = msg:match(SYSTEM_ROLL_PATTERN);
	return sender, roll, min, max;
end

-- ============================================================================
-- TABLE UTILITIES
-- ============================================================================

---@param tbl table
---@return table
function Utils.ShallowCopy(tbl)
	local copy = {};
	for k, v in pairs(tbl) do
		copy[k] = v;
	end
	return copy;
end

---@param tbl any
---@return any
function Utils.DeepCopy(tbl)
	if type(tbl) ~= "table" then return tbl; end
	local copy = {};
	for k, v in pairs(tbl) do
		copy[k] = Utils.DeepCopy(v);
	end
	return copy;
end

-- ============================================================================
-- UNIT / PLAYER UTILITIES
-- ============================================================================

---GetUnitName Returns the normalized "Name-Realm" string for a given unit
---@param unit string? Unit token
---@return string?
function Utils.GetUnitName(unit)
	local playerName, realm = UnitNameUnmodified(unit or "player");

	if not playerName or playerName == UNKNOWNOBJECT or playerName:len() == 0 then
		return nil;
	end

	if not realm or realm:len() == 0 then
		realm = GetNormalizedRealmName();
	end

	if realm and realm:len() > 0 then
		return playerName .. "-" .. realm;
	end

	return nil;
end

---@param name string?
---@return boolean
function Utils.HasRealmSuffix(name)
	return type(name) == "string" and name:find("%-.+") ~= nil;
end

---@param name string?
---@return boolean
function Utils.IsSameRealmName(name)
	if type(name) ~= "string" then return false; end
	local realm = GetNormalizedRealmName();
	if not realm then return false; end
	return name:find("%-" .. realm .. "$") ~= nil;
end

---@param name string?
---@return string
function Utils.StripRealmSuffix(name)
	if type(name) ~= "string" then return ""; end
	return name:match("^(.-)%-.+$") or name;
end

---IsOwnPlayer Checks if the sender is the current player
---@param sender string
---@param event string
---@return boolean
function Utils.IsOwnPlayer(sender, event)
	if not sender:find('-') then
		sender = sender .. "-" .. GetRealmName():gsub("[%s%-%.]*", "");
	end
	return sender == Utils.GetUnitName()
		or event == "CHAT_MSG_WHISPER_INFORM"
		or (type(sender) == "string" and sender:match("^@.+%-self$"));
end

-- ============================================================================
-- BUILD / VERSION UTILITIES
-- ============================================================================

---ValidateLatestBuild Checks if the live build matches the addon's build
---@return boolean isLatestBuild
function Utils.ValidateLatestBuild()
	local liveBuild = tostring(select(4, GetBuildInfo()));
	local addonBuild = ED.Globals.addon_build;
	if not addonBuild then return false; end

	for token in string.gmatch(addonBuild, "[^,%s]+") do
		if token == liveBuild then
			return true;
		end
	end

	return false;
end

---FormatBuild Formats a build version as major.minor.patch
---@param build string
---@return string
local function FormatBuild(build)
	build = tostring(build);
	local major = tonumber(string.sub(build, 1, 2));
	local minor = tonumber(string.sub(build, 3, 4));
	local patch = tonumber(string.sub(build, 5, 6));
	return major .. "." .. minor .. "." .. patch;
end

---OutputBuild Returns the addon's build version, optionally colorized
---@param colorized boolean
---@return string
function Utils.OutputBuild(colorized)
	local liveBuild = tostring(select(4, GetBuildInfo()));
	local addonBuild = ED.Globals.addon_build;
	if not addonBuild then return "Unknown Build"; end

	local output;
	for token in string.gmatch(addonBuild, "[^,%s]+") do
		if token == liveBuild then
			output = FormatBuild(token);
			break;
		end
	end

	if not output then
		output = FormatBuild(addonBuild);
	end

	if colorized then
		local color = Utils.ValidateLatestBuild() and "|cnGREEN_FONT_COLOR:" or "|cnWARNING_FONT_COLOR:";
		output = color .. output .. "|r";
	end

	return output;
end

ED.Utils = Utils;
