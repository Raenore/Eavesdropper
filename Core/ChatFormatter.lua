-- Copyright The Eavesdropper Authors
-- SPDX-License-Identifier: Apache-2.0

---@class EavesdropperChatFormatter
local ChatFormatter = {};

---Strips the "CHAT_MSG_" prefix from a WoW event name, returning the bare type.
---@param event string
---@return string
local function NormalizeEventType(event)
	if event:sub(1, 9) == "CHAT_MSG_" then
		return event:sub(10);
	end
	return event;
end

---Resolves a ChatTypeInfo entry for the given event type, falling back to SAY.
---@param eventType string
---@return table
local function ResolveChatInfo(eventType)
	local chatType = ED.Enums.ENTRY_CHAT_REMAP[eventType] or eventType;
	return ChatTypeInfo[chatType] or ChatTypeInfo.SAY;
end

---Formats a normal chat message, prepending any configured prefix.
---@param entry EavesdropperChatEntry
---@param name string
---@return string
local function MsgFormatNormal(entry, name) -- luacheck: no unused (name)
	local prefix = ED.Constants.MESSAGE_PREFIXES[entry.e] or "";
	local msg = entry.m or "";

	if entry.e == "CHAT_MSG_CHANNEL" then
		local index = GetChannelName(entry.c);
		if index > 0 then
			prefix = prefix:gsub("C", index, 1);
		end
	end

	return prefix .. msg;
end

---Formats an emote message, prepending the sender short-name and handling split markers and RP colour.
---@param entry EavesdropperChatEntry
---@param name string
---@return string
local function MsgFormatEmote(entry, name)
	local msg = entry.m or "";

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
		splitMarker = string.trim(Yapper.Config.Chat.DELINEATOR);
	elseif EmoteSplitter and EmoteSplitter.db then
		splitMarker = EmoteSplitter.db.global.premark;
	end

	if msg:sub(1, #splitMarker) == splitMarker then
		return msg;
	end

	-- handle leading punctuation cases
	local firstTwo = msg:sub(1, 2);
	if firstTwo == ", " or firstTwo == "'s" then
		return name .. msg;
	end

	-- Strip inner RP colours when RP colour display is disabled.
	if not (useRPName and useRPColor) then
		local outerColor, rest = msg:match("^(|c%x%x%x%x%x%x%x%x)(.*)$");
		if outerColor then
			rest = rest:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "");
			msg  = outerColor .. rest .. "|r";
		end
	end

	-- Skip prepending name for punctuation-starting messages.
	if msg:match("^%s*%p") then return msg; end

	return name .. " " .. msg;
end

---Group-aware emote formatter: delegates to MsgFormatEmote, then ensures the
---sender name is visible so multi-player group windows remain legible.
---@param entry EavesdropperChatEntry
---@param name string
---@return string
local function MsgFormatEmoteGroup(entry, name)
	local result = MsgFormatEmote(entry, name);

	---Strip WoW colour escapes for a plain-text prefix check.
	local plainResult = result:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "");
	local plainName = name:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "");

	if plainResult:sub(1, #plainName) ~= plainName then
		return name .. " " .. result;
	end

	return result;
end

---Strips the leading sender token (everything up to and including the first space).
---@param text string
---@return string
local function StripLeadingToken(text)
	local firstSpace = text:find(" ", 1, true) or 0;
	return text:sub(firstSpace + 1);
end

---Resolves the chat colour for the given event and wraps text in it.
---@param text string
---@param event string
---@return string
local function ColorByEvent(text, event)
	local eventType = event:match("^CHAT_MSG_(.+)$") or event;
	local info = ResolveChatInfo(eventType);
	local color = CreateColor(info.r or 1, info.g or 1, info.b or 1);
	return ED.Utils.WrapTextInColor(text, color);
end

---Formats a text-emote or roll message, colouring the message body and prepending the sender name in rolls and when not self.
---@param entry EavesdropperChatEntry
---@param name string
---@return string
local function MsgFormatTextEmote(entry, name)
	local messageText = entry.m or "";
	local prependName = (entry.e == "ROLL" or ED.Utils.GetUnitName() ~= entry.s);

	if prependName then
		messageText = StripLeadingToken(messageText);
	end

	messageText = ColorByEvent(messageText, entry.e);

	if prependName then
		return name .. " " .. messageText;
	end

	return messageText;
end

---Formats a text-emote message body only, stripping the leading sender token and colouring the remainder.
---@param entry EavesdropperChatEntry
---@param name string
---@return string
local function MsgFormatTextEmoteNoName(entry, name) -- luacheck: no unused (name)
	return ColorByEvent(StripLeadingToken(entry.m or ""), entry.e);
end

---Group-aware text-emote formatter: always prepends the sender name, even when
---the sender is the current player, so group windows remain identifiable.
---@param entry EavesdropperChatEntry
---@param name string
---@return string
local function MsgFormatTextEmoteGroup(entry, name)
	return name .. " " .. ColorByEvent(StripLeadingToken(entry.m or ""), entry.e);
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

---Formats a normal message for a group window, always embedding the sender name.
---Verb events produce "Name says: msg"; prefix events produce "[Party] Name: msg".
---@param entry EavesdropperChatEntry
---@param name string
---@return string
local function MsgFormatNormalGroup(entry, name)
	local msg = entry.m or "";
	local verb = ED.Constants.GROUP_EVENT_VERBS[entry.e];

	if verb then
		return name .. " " .. verb .. ": " .. msg;
	end

	local prefix = ED.Constants.MESSAGE_PREFIXES[entry.e] or "";

	if entry.e == "CHAT_MSG_CHANNEL" then
		local index = GetChannelName(entry.c);
		if index > 0 then
			prefix = prefix:gsub("C", index, 1);
		end
	end

	---"[Party] Name: msg", "[Raid] Name: msg", etc.
	return prefix .. name .. ": " .. msg;
end

---@type table<string, fun(entry:EavesdropperChatEntry, name:string):string>
local GROUP_MESSAGE_FORMATS = {
	SAY                  = MsgFormatNormalGroup,
	PARTY                = MsgFormatNormalGroup,
	PARTY_LEADER         = MsgFormatNormalGroup,
	RAID                 = MsgFormatNormalGroup,
	RAID_LEADER          = MsgFormatNormalGroup,
	RAID_WARNING         = MsgFormatNormalGroup,
	YELL                 = MsgFormatNormalGroup,
	INSTANCE_CHAT        = MsgFormatNormalGroup,
	INSTANCE_CHAT_LEADER = MsgFormatNormalGroup,
	GUILD                = MsgFormatNormalGroup,
	OFFICER              = MsgFormatNormalGroup,
	CHANNEL              = MsgFormatNormalGroup,
	WHISPER              = MsgFormatNormalGroup,
	WHISPER_INFORM       = MsgFormatNormalGroup,

	EMOTE      = MsgFormatEmoteGroup,
	TEXT_EMOTE = MsgFormatTextEmoteGroup,
	ROLL       = MsgFormatTextEmoteGroup,
};

setmetatable(GROUP_MESSAGE_FORMATS, {
	__index = function() return MsgFormatNormalGroup; end,
});

---Returns the RGB color for a chat entry, accounting for channel-specific colours.
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

---Replaces the emote target's OOC name with their RP name in a formatted text-emote string.
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

-- Expose formatting helpers for external callers (e.g. AdvancedFormatter).
ChatFormatter.MsgFormatTextEmote = MsgFormatTextEmote;
ChatFormatter.MsgFormatTextEmoteNoName = MsgFormatTextEmoteNoName;
ChatFormatter.FormatTextEmoteTargetWithRPName = FormatTextEmoteTargetWithRPName;
ChatFormatter.GetEntryColor = GetEntryColor;

---Returns the display name for a chat entry, applying RP name and colour based on current settings.
---@param entry EavesdropperChatEntry
---@param forceDisplayMode boolean? If true, force first name usage.
---@return string name, boolean applyRPName, string? firstName
function ChatFormatter:GetFormattedName(entry, forceDisplayMode)
	local name = entry.s;

	local fullName, firstName, nameColor = ED.MSP.TryGetMSPData(name, entry.g);

	local nameDisplayMode = forceDisplayMode or ED.Database:GetSetting("NameDisplayMode");
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

	if not firstName or not useRPName then
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

	local trimmedName = string.trim(name);
	local trimmedFirstName = firstName and string.trim(firstName) or trimmedName;

	return trimmedName, applyRPName, trimmedFirstName;
end

---Formats a full chat entry for display: timestamp, sender name, message body, and entry colour.
---@param entry EavesdropperChatEntry
---@param forGroup boolean? If true, uses group-aware formatting that always embeds the sender name.
---@param forceDisplayMode boolean? If true, force specific display mode.
---@return string formattedMsg
---@return string? firstName
function ChatFormatter:FormatMessage(entry, forGroup, forceDisplayMode)
	if not entry or not entry.m then return ""; end

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

	-- Age-based timestamp colour (Credits: Listener by tmgpub).
	local r, g, b;
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
	local name, applyRPName, firstName = ChatFormatter:GetFormattedName(entry, forceDisplayMode);

	-- Format message
	local eventType = NormalizeEventType(entry.e);
	local formatTable = forGroup and GROUP_MESSAGE_FORMATS or MESSAGE_FORMATS;
	local msgText = formatTable[eventType](entry, name);

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
