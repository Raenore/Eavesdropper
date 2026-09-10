-- Copyright The Eavesdropper Authors
-- SPDX-License-Identifier: GPL-3.0-or-later

---@type EavesdropperConstants
local Constants = ED.Constants;

---@class EavesdropperKeywords
local Keywords = {};
Keywords.List = {};
Keywords.SortedList = {};

---Timestamp of the next allowed keyword notification.
---@type number
local notificationNextTime = 0;

---True if the match spanning startPos-endPos in str is not adjacent to a word character.
---@param str string
---@param startPos number
---@param endPos number
---@return boolean
local function IsWordBoundaryMatch(str, startPos, endPos)
	local beforeOk = startPos == 1
		or not str:sub(startPos - 1, startPos - 1):match("[%w]");
	local afterOk = endPos == #str
		or not str:sub(endPos + 1, endPos + 1):match("[%w]");
	return beforeOk and afterOk;
end

---Rebuilds the keyword lookup table and sorted list from the HighlightKeywords setting.
---Applies token substitutions (<firstname>, <lastname>, <oocname>, <class>, <race>).
function Keywords:ParseList()
	if not ED or not ED.Database then return; end

	local highlightKeywords = ED.Database:GetSetting("HighlightKeywords");
	self.List = {};
	self.SortedList = {};

	if type(highlightKeywords) ~= "string" or highlightKeywords == "" then return; end

	-- Fetch MSP substitution values if MSP is enabled.
	local firstName, lastName, className, raceName;
	if ED.MSP.IsEnabled() then
		local _, fn, _, ln, cn, rn = ED.MSP.TryGetMSPData(ED.Globals.player_sender_name, ED.Globals.player_guid);
		firstName = fn;
		lastName  = ln;
		className = cn;
		raceName  = rn;
	end

	firstName = firstName or "";
	lastName  = lastName or "";
	className = className or "";
	raceName  = raceName or "";

	for word in highlightKeywords:gmatch("([^,]+)") do
		word = string.trim(word);
		if word ~= "" then
			-- Function replacements so a literal "%" in MSP-provided text isn't parsed as a capture reference.
			word = word
				:gsub("<firstname>", function() return firstName; end)
				:gsub("<lastname>",  function() return lastName; end)
				:gsub("<oocname>",   function() return ED.Globals.player_character_name; end)
				:gsub("<class>",     function() return className; end)
				:gsub("<race>",      function() return raceName; end);

			if word ~= "" then
				self.List[word:lower()] = true;
			end
		end
	end

	for kw in pairs(self.List) do
		self.SortedList[#self.SortedList + 1] = kw;
	end
	table.sort(self.SortedList, function(a, b) return #a > #b; end);
end

---Same matching logic as HandleChecks, without colour wrapping, link placeholders, or overlap tracking.
---@param text string
---@return boolean
function Keywords:HasMatch(text)
	if not self.SortedList or #self.SortedList == 0 then return false; end

	local enablePartial = ED.Database:GetSetting("EnablePartialKeywords");
	local lower = text:lower();

	for _, kw in ipairs(self.SortedList) do
		local searchPos = 1;
		while searchPos <= #lower do
			local startPos, endPos = lower:find(kw, searchPos, true);
			if not startPos then break; end

			if enablePartial then return true; end

			if IsWordBoundaryMatch(lower, startPos, endPos) then return true; end

			searchPos = endPos + 1;
		end
	end

	return false;
end

---Scans a chat message for keyword matches, wraps them in the highlight colour, and fires notifications.
---@param chatFrame table
---@param event string
---@param message string
---@param sender string
---@vararg any
---@return boolean? found True if keyword was found
---@return string? message Modified message with highlights
---@return string? sender Possibly updated sender
---@return any ... Remaining vararg values
function Keywords:HandleChecks(chatFrame, event, message, sender, ...) -- luacheck: no unused (chatFrame)
	if not message or not canaccessvalue(message) then return; end
	if not ED.Database:GetSetting("EnableKeywords") then return; end
	if ED.Utils.IsOwnPlayer(sender, event, select(10, ...)) then return; end
	if not self.SortedList or #self.SortedList == 0 then return; end

	-- Handle TRP NPC talk detection pattern.
	local msg = message;
	local trpNPCDetection = false;
	if event == "CHAT_MSG_EMOTE" and ED.MSP.IsTRPReady() and message == " " then
		trpNPCDetection = true;
		msg = TRP3_API.chat.getNPCMessageName();
	end

	local enablePartial = ED.Database:GetSetting("EnablePartialKeywords");
	local found = false;

	-- Protect item/spell links from being modified by wrapping them in placeholders.
	-- "|c.-|H" covers both the classic |cffRRGGBBAA hex prefix and the newer |cn<name>: named-colour prefix.
	local replaced = {};
	msg = msg:gsub("(|c.-|H[^|]+|h[^|]+|h|r)", function(link)
		replaced[#replaced + 1] = link;
		return Constants.KEYWORD_LINK_PLACEHOLDER .. #replaced .. Constants.KEYWORD_LINK_PLACEHOLDER;
	end);

	-- Computed after the link substitution so match positions stay aligned with msg.
	local searchLower = msg:lower();

	local highlightColor = ED.Database:GetSetting("HighlightColor");
	if type(highlightColor) ~= "table" then
		highlightColor = Constants.DEFAULT_HIGHLIGHT_COLOR;
	end

	local color = CreateColor(
		highlightColor.r or 0,
		highlightColor.g or 1,
		highlightColor.b or 0
	);

	local allMatches = {};
	-- Tracks character positions already consumed by a match, preventing a shorter keyword
	-- from matching inside a position already claimed by a longer one (e.g. "art" inside "party").
	local claimed = {};

	for _, kw in ipairs(self.SortedList) do
		local searchPos = 1;
		while searchPos <= #searchLower do
			local startPos, endPos = searchLower:find(kw, searchPos, true);
			if not startPos then break; end

			local matchOk = true;
			if not enablePartial then
				matchOk = IsWordBoundaryMatch(searchLower, startPos, endPos);
			end

			if matchOk then
				local overlap = false;
				for pos = startPos, endPos do
					if claimed[pos] then
						overlap = true;
						break;
					end
				end

				if not overlap then
					found = true;
					allMatches[#allMatches + 1] = { startPos, endPos };
					for pos = startPos, endPos do
						claimed[pos] = true;
					end
				end
			end

			searchPos = endPos + 1;
		end
	end

	-- Apply replacements back-to-front so earlier positions are not shifted by later changes.
	table.sort(allMatches, function(a, b) return a[1] > b[1]; end);

	for _, m in ipairs(allMatches) do
		local raw = msg:sub(m[1], m[2]);
		local wrapped = ED.Utils.WrapTextInColor(raw, color);
		msg = msg:sub(1, m[1] - 1) .. wrapped .. msg:sub(m[2] + 1);
	end

	if found then
		local now = GetTime();
		if now > notificationNextTime then
			notificationNextTime = now + Constants.KEYWORDS_NOTIFICATION_CD;

			if ED.Database:GetSetting("NotificationKeywordsSound") then
				ED.Notifications.PlayAlertSound(ED.Enums.NOTIFICATIONS_TYPE.KEYWORDS);
			end

			if ED.Database:GetSetting("NotificationKeywordsFlashTaskbar") then
				ED.Notifications.FlashTaskbar();
			end
		end

		-- Restore original links from their placeholders.
		msg = msg:gsub(
			Constants.KEYWORD_LINK_PLACEHOLDER .. "(%d+)" .. Constants.KEYWORD_LINK_PLACEHOLDER,
			function(idx)
				return replaced[tonumber(idx)];
			end
		);

		if trpNPCDetection then
			-- Safeguard for TRP versions prior to 3.3.3.
			if TRP3_API.chat.setNPCMessageName then
				TRP3_API.chat.setNPCMessageName(msg);
			end
			return false, message, sender, ...;
		end

		return false, msg, sender, ...;
	end
end

ED.Keywords = Keywords;
