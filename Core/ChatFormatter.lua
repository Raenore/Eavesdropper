-- Copyright The Eavesdropper Authors
-- SPDX-License-Identifier: Apache-2.0

---@class EavesdropperChatFormatter
local ChatFormatter = {};

---@param event string
---@return string
local function NormalizeEventType(event)
	if event:sub(1, 9) == "CHAT_MSG_" then
		return event:sub(10);
	end
	return event;
end

---@param eventType string
---@return table
local function ResolveChatInfo(eventType)
	local chatType = ED.Enums.ENTRY_CHAT_REMAP[eventType] or eventType;
	return ChatTypeInfo[chatType] or ChatTypeInfo.SAY;
end

---Default normal message formatter
---@param event EavesdropperChatEntry
---@param name string
---@return string
local function MsgFormatNormal(event, name) -- luacheck: no unused (name)
	local prefix = ED.Constants.MESSAGE_PREFIXES[event.e] or "";
	local msg = event.m or "";

	if event.e == "CHAT_MSG_CHANNEL" then
		local index = GetChannelName(event.c);
		if index > 0 then
			prefix = prefix:gsub("C", index, 1);
		end
	end

	return prefix .. msg;
end;

---Formats emote messages
---@param event EavesdropperChatEntry
---@param name string
---@return string
local function MsgFormatEmote(event, name)
	local msg = event.m or "";
	local shortName = strtrim(name:match("^[^-]+") or name);

	local nameDisplayMode = ED.Database:GetSetting("NameDisplayMode");
	local useRPName = nameDisplayMode ~= 3;
	local useRPColor = ED.Database:GetSetting("UseRPNameColor");

	-- early return for special prefixes
	local stripped = msg:match("^||%s*(.*)");
	if stripped then return stripped; end

	-- check for split markers, default is "»" but it can be different per addon
	-- Chattery, EmoteSplitter and Yapper are supported by default
	-- (bar no changes on their part since addition)
	local splitMarker = "»";
	if Chattery then
		splitMarker = Chattery.Settings.GetSetting(Chattery.Setting.SplitMarker);
	elseif Yapper and Yapper.Config then
		splitMarker = strtrim(Yapper.Config.Chat.DELINEATOR);
	elseif EmoteSplitter and EmoteSplitter.db then
		splitMarker = EmoteSplitter.db.global.premark;
	end

	if msg:sub(1, #splitMarker) == splitMarker then
		return msg;
	end

	-- handle leading punctuation cases
	local firstTwo = msg:sub(1,2);
	if firstTwo == ", " or firstTwo == "'s" then
		return shortName .. msg;
	end

	-- fix RP colors if disabled
	if not (useRPName and useRPColor) then
		local outerColor, rest = msg:match("^(|c%x%x%x%x%x%x%x%x)(.*)$");
		if outerColor then
			rest = rest:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "");
			msg = outerColor .. rest .. "|r";
		end
	end

	-- skip prepending name for punctuation-starting messages
	if msg:match("^%s*%p") then return msg; end

	return shortName .. " " .. msg;
end

---Formats text emotes
---@param entry EavesdropperChatEntry
---@param name string
---@return string
local function MsgFormatTextEmote(entry, name)
	local messageText = entry.m or "";
	local unitName = ED.Utils.GetUnitName();
	local shortName;

	if entry.e == "ROLL" or unitName ~= entry.s then
		shortName = name:match("^[^-]+") or name;
		local firstSpace = messageText:find(" ", 1, true) or 0;
		messageText = messageText:sub(firstSpace + 1);
	end

	local eventType = entry.e:match("^CHAT_MSG_(.+)$") or entry.e;
	local info = ResolveChatInfo(eventType);
	local color = CreateColor(info.r or 1, info.g or 1, info.b or 1);

	messageText = ED.Utils.WrapTextInColor(messageText, color);
	return (shortName and (strtrim(shortName) .. " ") or "") .. messageText;
end;

function ChatFormatter:MsgFormatTextEmote(entry, name)
	return MsgFormatTextEmote(entry, name);
end

---Formats text emotes
---@param entry EavesdropperChatEntry
---@param name string
---@return string
local function MsgFormatTextEmoteNoName(entry, name) -- luacheck: no unused (name)
	local messageText = entry.m or "";

	local firstSpace = messageText:find(" ", 1, true) or 0;
	messageText = messageText:sub(firstSpace + 1);

	local eventType = entry.e:match("^CHAT_MSG_(.+)$") or entry.e;
	local info = ResolveChatInfo(eventType);
	local color = CreateColor(info.r or 1, info.g or 1, info.b or 1);

	messageText = ED.Utils.WrapTextInColor(messageText, color);
	return messageText;
end;

function ChatFormatter:MsgFormatTextEmoteNoName(entry, name)
	return MsgFormatTextEmoteNoName(entry, name);
end

---@type table<string, fun(entry:EavesdropperChatEntry, name:string):string>
local MESSAGE_FORMATS = {
	SAY                  = MsgFormatNormal,
	PARTY                = MsgFormatNormal,
	PARTY_LEADER         = MsgFormatNormal,
	RAID                 = MsgFormatNormal,
	RAID_LEADER          = MsgFormatNormal,
	RAID_WARNING         = MsgFormatNormal,
	YELL                 = MsgFormatNormal,
	INSTANCE_CHAT        = MsgFormatNormal,
	INSTANCE_CHAT_LEADER = MsgFormatNormal,
	GUILD                = MsgFormatNormal,
	OFFICER              = MsgFormatNormal,
	CHANNEL              = MsgFormatNormal,

	EMOTE      = MsgFormatEmote,
	TEXT_EMOTE = MsgFormatTextEmote,
	ROLL       = MsgFormatTextEmote,
};

setmetatable(MESSAGE_FORMATS, {
	__index = function() return MsgFormatNormal end;
});

---Returns the RGB color for a chat entry
---@param entry EavesdropperChatEntry
---@return number r, number g, number b
local function GetEntryColor(entry)
	local info;

	if entry.c then
		local index = GetChannelName(entry.c);
		info = ChatTypeInfo["CHANNEL" .. index] or ChatTypeInfo.CHANNEL;
	else
		local eventType = NormalizeEventType(entry.e);
		local chatType = ED.Enums.ENTRY_CHAT_REMAP[eventType] or eventType;
		info = ChatTypeInfo[chatType] or ChatTypeInfo.SAY;
	end

	return info.r, info.g, info.b;
end

function ChatFormatter:GetEntryColor(entry)
	return GetEntryColor(entry);
end

---@param entry EavesdropperChatEntry
---@param msgText string
---@return string
local function FormatTextEmoteTargetWithRPName(entry, msgText)
	local bareName, sender, senderEntry = ED.PlayerCache:ResolveEmoteSender(entry.m, entry.s);
	if not bareName or not sender then return msgText; end

	local targetFullName, targetFirstName, targetNameColor = ED.MSP.TryGetMSPData(sender, senderEntry.guid);
	if not targetFullName then return msgText; end

	local targetName;
	if targetNameColor then
		if ED.Database:GetSetting("NameDisplayMode") == 2 and targetFirstName then
			targetName = ED.Utils.WrapTextInColor(targetFirstName, targetNameColor);
		elseif targetFullName then
			targetName = ED.Utils.WrapTextInColor(targetFullName, targetNameColor);
		end
	end

	if targetName and entry.s ~= bareName and entry.s ~= sender then
		local escapedSender = ED.Utils.EscapePattern(sender);
		local newText, count = msgText:gsub(escapedSender, targetName, 1);
		if count == 0 and bareName then
			local escapedBare = ED.Utils.EscapePattern(bareName);
			newText = newText:gsub(escapedBare, targetName, 1);
		end
		return newText;
	end

	return msgText;
end

function ChatFormatter:FormatTextEmoteTargetWithRPName(entry, msgText)
	return FormatTextEmoteTargetWithRPName(entry, msgText);
end

---@param entry EavesdropperChatEntry
---@return string name, boolean applyRPName, string? firstName
function ChatFormatter:GetFormattedName(entry)
	local name = entry.s;

	local fullName, firstName, nameColor = ED.MSP.TryGetMSPData(name, entry.g);

	local nameDisplayMode = ED.Database:GetSetting("NameDisplayMode");
	local useRPName = nameDisplayMode ~= 3;
	local useRPNameForTargets = ED.Database:GetSetting("UseRPNameForTargets");
	local useRPNameInRolls = ED.Database:GetSetting("UseRPNameInRolls");
	local useRPNameColor = ED.Database:GetSetting("UseRPNameColor");

	local applyRPName = useRPName;

	if entry.e == "ROLL" then
		applyRPName = useRPName and useRPNameInRolls;
	end

	if entry.e == "CHAT_MSG_TEXT_EMOTE" then
		applyRPName = useRPName and useRPNameForTargets;
	end

	if not firstName then
		name = ED.Utils.StripRealmSuffix(name);
	end

	if applyRPName then
		if nameDisplayMode == 2 and firstName then
			name = firstName;
		elseif fullName then
			name = fullName;
		end

		if useRPNameColor and nameColor then
			name = ED.Utils.WrapTextInColor(name, nameColor);
		end
	end

	return strtrim(name), applyRPName, strtrim(firstName);
end

---Formats a chat entry for display
---@param entry EavesdropperChatEntry
---@return string, string? firstName
function ChatFormatter:FormatMessage(entry)
	if not entry or not entry.m then
		return "";
	end

	-- Timestamp
	local now = time();
	local age = now - (entry.t or now);
	local timestamp;

	if age < 30 * 60 then
		timestamp = age < 60 and "<1m" or string.format("%sm", math.floor(age / 60));
	else
		timestamp = date("%H:%M", entry.t);
	end

	if ED.Database:GetSetting("TimestampBrackets") then
		timestamp = "[" .. timestamp .. "]";
	end

	local r, g, b;
	-- (Colors Credits @ Listener by tmgpub)
	if age >= 600 then
		r, g, b = 0.47, 0.47, 0.47; -- 0x77
	elseif age >= 300 then
		r, g, b = 0.53, 0.53, 0.53; -- 0x88
	elseif age >= 60 then
		r, g, b = 0.73, 0.73, 0.73; -- 0xBB
	else
		r, g, b = 0.02, 0.67, 0.97; -- 0x05ACF8
	end
	local timestampColor = CreateColor(r, g, b);

	timestamp = ED.Utils.WrapTextInColor(timestamp, timestampColor) .. " ";

	-- Name handling
	local name, applyRPName, firstName = ChatFormatter:GetFormattedName(entry);

	-- Format message
	local eventType = NormalizeEventType(entry.e);
	local formatFunc = MESSAGE_FORMATS[eventType];
	local msgText = formatFunc(entry, name);

	-- Apply entry color
	local entryR, entryG, entryB = GetEntryColor(entry);
	local entryColor = CreateColor(entryR, entryG, entryB);
	msgText = ED.Utils.WrapTextInColor(msgText, entryColor);

	if entry.e == "CHAT_MSG_TEXT_EMOTE" and applyRPName then
		msgText = FormatTextEmoteTargetWithRPName(entry, msgText);
	end

	return timestamp .. msgText, firstName;
end

ED.ChatFormatter = ChatFormatter;
