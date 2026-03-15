-- Copyright The Eavesdropper Authors
-- SPDX-License-Identifier: Apache-2.0

---@type EavesdropperConstants
local Constants = ED.Constants;

---@class EavesdropperKeywords
local Keywords = {};
Keywords.List = {};
Keywords.SortedList = {};

---@type number
local notificationNextTime = 0;

---Build the keyword lookup table from the Settings multiline editbox.
---@return nil
function Keywords:ParseList()
	if not ED or not ED.Database then return; end

	local highlightKeywords = ED.Database:GetSetting("HighlightKeywords");
	self.List = {};
	self.SortedList = {};

	if type(highlightKeywords) ~= "string" or highlightKeywords == "" then
		return;
	end

	-- Get player names for substitutions
	local unitName = ED.Utils and ED.Utils.GetUnitName and ED.Utils.GetUnitName();
	local guid = UnitGUID("player");
	local firstName, lastName, className, raceName;
	if ED.MSP and ED.MSP.TryGetMSPData then
		local _, fn, _, ln, cn, rn = ED.MSP.TryGetMSPData(unitName, guid);
		firstName = fn;
		lastName  = ln;
		className = cn;
		raceName  = rn;
	end

	local oocName = UnitName("player");

	firstName = firstName or "";
	lastName  = lastName or "";
	className = className or "";
	raceName  = raceName or "";

	for word in highlightKeywords:gmatch("([^,]+)") do
		word = word:match("^%s*(.-)%s*$"); -- trim
		if word ~= "" then
			-- Substitutions
			word = word
				:gsub("<firstname>", firstName)
				:gsub("<lastname>",  lastName)
				:gsub("<oocname>",   oocName)
				:gsub("<class>",     className)
				:gsub("<race>",      raceName);

			self.List[word:lower()] = true;
		end
	end

	for kw in pairs(self.List) do
		self.SortedList[#self.SortedList + 1] = kw;
	end
	table.sort(self.SortedList, function(a, b) return #a > #b; end);
end

---Highlights keywords in a chat message.
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
	if ED.Utils.IsOwnPlayer(sender, event) then return; end
	if not self.SortedList or #self.SortedList == 0 then return; end

	-- Handle TRP NPC talk detection pattern
	local msg = message;
	local trpNPCDetection = false;
	if event == "CHAT_MSG_EMOTE" and TRP3_API and message == " " then
		trpNPCDetection = true;
		msg = TRP3_API.chat.getNPCMessageName(); -- Still allow checking for notification sounds at least, and then setNPCMessageName one day?
	end

	local enablePartial = ED.Database:GetSetting("EnablePartialKeywords");
	local originalLower = msg:lower();
	local found = false;

	-- Protect links from modification
	local replaced = {};
	msg = msg:gsub("(|cff[0-9a-f]+|H[^|]+|h[^|]+|h|r)", function(link)
		replaced[#replaced + 1] = link;
		return Constants.KEYWORD_LINK_PLACEHOLDER .. #replaced .. Constants.KEYWORD_LINK_PLACEHOLDER;
	end);

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
	local claimed = {}; -- To avoid double matches (e.g. art and party).

	for _, kw in ipairs(self.SortedList) do
		local searchPos = 1;
		while searchPos <= #originalLower do
			local startPos, endPos = originalLower:find(kw, searchPos, true);
			if not startPos then break; end

			local matchOk = true;
			if not enablePartial then
				local beforeOk = startPos == 1
					or not originalLower:sub(startPos - 1, startPos - 1):match("[%w]");
				local afterOk = endPos == #originalLower
					or not originalLower:sub(endPos + 1, endPos + 1):match("[%w]");
				matchOk = beforeOk and afterOk;
			end

			if matchOk then
				-- Check no position in this range is already claimed
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

	-- Apply replacements back-to-front so earlier positions are not shifted by changes made to later ones.
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
				ED.Notifications:PlayAlertSound(ED.Enums.NOTIFICATIONS_TYPE.KEYWORDS);
			end

			if ED.Database:GetSetting("NotificationKeywordsFlashTaskbar") then
				ED.Notifications:FlashTaskbar();
			end
		end

		-- Restore links
		msg = msg:gsub(
			Constants.KEYWORD_LINK_PLACEHOLDER .. "(%d+)" .. Constants.KEYWORD_LINK_PLACEHOLDER,
			function(idx)
				return replaced[tonumber(idx)];
			end
		);

		-- On TRP NPC Detection, we don't apply keyword highlighting as it'll just break the formatting.
		return false, trpNPCDetection and message or msg, sender, ...;
	end
end

ED.Keywords = Keywords;
