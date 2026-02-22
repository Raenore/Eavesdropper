-- Copyright The Eavesdropper Authors
-- SPDX-License-Identifier: Apache-2.0

---@type EavesdropperConstants
local Constants = ED.Constants;

---@class EavesdropperKeywords
local Keywords = {};
Keywords.List = {};

---@type number
local notificationNextTime = 0;

---Build the keyword lookup table from the Settings multiline editbox.
---@return nil
function Keywords:ParseList()
	if not ED or not ED.Database then return; end

	local highlightKeywords = ED.Database:GetSetting("HighlightKeywords");
	self.List = {};

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
	if not self.List or not next(self.List) then return; end

	local enablePartial = ED.Database:GetSetting("EnablePartialKeywords");
	local originalLower = message:lower();
	local found = false;

	-- Protect links from modification
	local replaced = {};
	message = message:gsub("(|cff[0-9a-f]+|H[^|]+|h[^|]+|h|r)", function(link)
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

	for kw in pairs(self.List) do
		if kw ~= "" then
			local searchPos = 1;
			local offset = 0;

			while searchPos <= #originalLower do
				local startPos, endPos = originalLower:find(kw, searchPos, true);
				if not startPos then break; end

				local matches = true;

				if not enablePartial then
					local beforeOk = startPos == 1
						or not originalLower:sub(startPos - 1, startPos - 1):match("[%w]");
					local afterOk = endPos == #originalLower
						or not originalLower:sub(endPos + 1, endPos + 1):match("[%w]");
					matches = beforeOk and afterOk;
				end

				if matches then
					found = true;

					local realStart = startPos + offset;
					local realEnd   = endPos   + offset;

					local raw = message:sub(realStart, realEnd);
					local wrapped = ED.Utils.WrapTextInColor(raw, color);

					message =
						message:sub(1, realStart - 1)
						.. wrapped
						.. message:sub(realEnd + 1);

					offset = offset + (#wrapped - #raw);
				end

				searchPos = endPos + 1;
			end
		end
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
		message = message:gsub(
			Constants.KEYWORD_LINK_PLACEHOLDER .. "(%d+)" .. Constants.KEYWORD_LINK_PLACEHOLDER,
			function(idx)
				return replaced[tonumber(idx)];
			end
		);

		return false, message, sender, ...;
	end
end

ED.Keywords = Keywords;
