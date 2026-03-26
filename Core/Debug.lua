-- Copyright The Eavesdropper Authors
-- SPDX-License-Identifier: Apache-2.0

---@class EavesdropperDebug
local Debug = {};

local printEnabled = false;

---Returns true if debug mode is currently active.
---@return boolean
function Debug:IsEnabled()
	return ED and ED.Globals and ED.Globals.DEBUG_MODE == true;
end

---Prints a prefixed debug message if debug mode and printEnabled are both active.
---@param ... any
function Debug:Print(...)
	if not self:IsEnabled() or not printEnabled then return; end
	print("|cnFRAMESTACK_REGION_COLOR:Eavesdropper|r", ...);
end

-- ============================================================
-- Test Entry Injection (debug only)
-- ============================================================

---Parses test command arguments.
---Format: "GroupName" event class "SenderName" message...
---@param args string
---@return string? groupName
---@return string? event
---@return string? class
---@return string? senderName
---@return string? message
local function ParseTestArgs(args)
	if not args or args == "" then return; end

	local groupName, rest = args:match('^"([^"]+)"%s+(.+)$');
	if not groupName or not rest then return; end

	local event, class, rest2 = rest:match("^(%S+)%s+(%S+)%s+(.+)$");
	if not event or not class or not rest2 then return; end

	local senderName, message = rest2:match('^"([^"]+)"%s+(.+)$');
	if not senderName or not message then return; end

	return groupName, event:upper(), class:upper(), senderName, message;
end

---Parses testclear command arguments.
---Format: "GroupName"
---@param args string
---@return string? groupName
local function ParseTestClearArgs(args)
	if not args or args == "" then return; end
	return args:match('^"([^"]+)"');
end

---Maps a user-provided event shorthand to the internal event string.
---ROLL is stored without the CHAT_MSG_ prefix; all others are prefixed.
---@param event string
---@return string
local function ResolveEventType(event)
	if event == "ROLL" then return "ROLL"; end
	if event:sub(1, 9) == "CHAT_MSG_" then return event; end
	return "CHAT_MSG_" .. event;
end

---Injects a test chat entry into ChatHistory and ensures the sender
---is present in the target group frame's player list.
---The sender name is wrapped in the class colour so it renders coloured
---in the formatted output without requiring MSP data.
---Test senders bypass AddPlayer to avoid persisting to charDB.
---@param groupName string
---@param event string Uppercased event shorthand (e.g. "SAY", "EMOTE", "ROLL")
---@param class string Uppercased English class token (e.g. "ROGUE", "PALADIN")
---@param senderName string Display name for the sender
---@param message string Message body
function Debug:InjectTestEntry(groupName, event, class, senderName, message)
	if not self:IsEnabled() then return; end

	local frame = ED.GroupFrame.frames[groupName];
	if not frame then
		ED.Utils.Write("Group frame not found: " .. groupName);
		return;
	end

	local classColor = RAID_CLASS_COLORS[class];
	if not classColor then
		ED.Utils.Write("Unknown class: " .. class .. ". Use the uppercase token (e.g. ROGUE, DEATHKNIGHT).");
		return;
	end

	local coloredName = classColor:WrapTextInColorCode(senderName);
	local resolvedEvent = ResolveEventType(event);

	---Directly insert into the player list to avoid triggering SaveToCharDB.
	if not frame:HasPlayer(coloredName) then
		table.insert(frame.players, coloredName);
		frame:RefreshEmptyState();
	end

	---Build and insert the chat entry.
	local entry = {
		id = ED.ChatHistory.nextEntryId,
		t = time(),
		e = resolvedEvent,
		m = message,
		s = coloredName,
		g = nil,
		test = true,
	};

	ED.ChatHistory.list[entry.id] = entry;
	ED.ChatHistory.nextEntryId = ED.ChatHistory.nextEntryId + 1;
	ED.ChatHistory.history[coloredName] = ED.ChatHistory.history[coloredName] or {};
	tinsert(ED.ChatHistory.history[coloredName], entry);

	frame:RefreshChat();
end

---Removes all test entries from the target group frame.
---Scans for entries flagged with test = true so it works even after a reload.
---@param groupName string
function Debug:ClearTestEntries(groupName)
	if not self:IsEnabled() then return; end

	local frame = ED.GroupFrame.frames[groupName];
	if not frame then
		ED.Utils.Write("Group frame not found: " .. groupName);
		return;
	end

	---Collect senders that have at least one test entry.
	local sendersToClean = {};
	for _, player in ipairs(frame.players) do
		local history = ED.ChatHistory.history[player];
		if history then
			for _, entry in ipairs(history) do
				if entry.test then
					sendersToClean[player] = true;
					break;
				end
			end
		end
	end

	if not next(sendersToClean) then
		ED.Utils.Write("No test entries found for: " .. groupName);
		return;
	end

	---Remove test entries from history; remove sender if no real entries remain.
	for sender in pairs(sendersToClean) do
		local history = ED.ChatHistory.history[sender];
		if history then
			local kept = {};
			for _, entry in ipairs(history) do
				if entry.test then
					ED.ChatHistory.list[entry.id] = nil;
				else
					tinsert(kept, entry);
				end
			end

			if #kept > 0 then
				ED.ChatHistory.history[sender] = kept;
			else
				ED.ChatHistory.history[sender] = nil;
			end
		end
	end

	---Remove test-only senders from the player list (reverse iterate for safe removal).
	for i = #frame.players, 1, -1 do
		local player = frame.players[i];
		if sendersToClean[player] and not ED.ChatHistory.history[player] then
			table.remove(frame.players, i);
		end
	end

	frame:RefreshEmptyState();
	frame:RefreshChat();
	ED.Utils.Write("Cleared test entries for: " .. groupName);
end

---Handles the /ed test command.
---@param args string Raw (non-lowercased) arguments after "test "
function Debug:HandleTest(args)
	if not self:IsEnabled() then return; end

	local groupName, event, class, senderName, message = ParseTestArgs(args);
	if not groupName then
		ED.Utils.Write('Usage: /ed test "GroupName" event class "SenderName" message...');
		ED.Utils.Write('Example: /ed test "Demo" say Mage "Sylvestine" Hello there!');
		return;
	end

	self:InjectTestEntry(groupName, event, class, senderName, message);
end

---Handles the /ed testclear command.
---@param args string Raw (non-lowercased) arguments after "testclear "
function Debug:HandleTestClear(args)
	if not self:IsEnabled() then return; end

	local groupName = ParseTestClearArgs(args);
	if not groupName then
		ED.Utils.Write('Usage: /ed testclear "GroupName"');
		return;
	end

	self:ClearTestEntries(groupName);
end

ED.Debug = Debug;
