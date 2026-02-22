-- Copyright The Eavesdropper Authors
-- SPDX-License-Identifier: Apache-2.0

---@class EavesdropperChatFilters
local ChatFilters = {};

---@param groupName string
---@return ColorMixin
local function GetGroupColor(groupName)
	local option = ED.Constants.FILTER_OPTIONS[groupName];
	local chatType = type(option) == "table" and option[1] or option;
	chatType = ED.Enums.ENTRY_CHAT_REMAP[chatType] or chatType;

	local chatInfo = ChatTypeInfo[chatType] or { r = 1, g = 1, b = 1 };
	return CreateColor(chatInfo.r, chatInfo.g, chatInfo.b);
end

---@param event string
---@return string
local function NormalizeEvent(event)
	local remapped = ED.Enums.ENTRY_CHAT_REMAP[event];
	if remapped then
		return remapped;
	end

	if event:sub(1, 9) == "CHAT_MSG_" then
		return event:sub(10):upper();
	end

	return event:upper();
end

---@param chatType string
---@return string
local function ResolveEvent(chatType)
	local remapped = ED.Enums.ENTRY_CHAT_REMAP[chatType] or chatType;
	return remapped:upper();
end

---Generates the chat filter menu for UI
---@param menu table
function ChatFilters:GenerateFilterListMenu(menu)
	local filters = ED.Database:GetSetting("Filters");
	if not filters then
		return;
	end

	for i = 1, #ED.Constants.FILTER_ORDER do
		local groupName = ED.Constants.FILTER_ORDER[i];
		if filters[groupName] ~= nil then
			local labelText = ED.Constants.FILTER_LABELS[groupName] or groupName;
			local groupColor = GetGroupColor(groupName);
			local groupLabel = ED.Utils.WrapTextInColor(labelText, groupColor);


			menu:CreateCheckbox(
				groupLabel,
				function()
					local currentFilters = ED.Database:GetSetting("Filters");
					return currentFilters and currentFilters[groupName] or false;
				end,
				function()
					local currentFilters = ED.Database:GetSetting("Filters") or {};
					currentFilters[groupName] = not currentFilters[groupName];
					ED.Database:SetSetting("Filters", currentFilters);
					ChatFilters:UpdateFilters(ED.Frame);
				end
			);

			if ED.Constants.DIVIDE_AFTER[groupName] then
				menu:CreateDivider();
			end
		end
	end
end

---Updates the active chat events based on filter settings
---@param frame table
function ChatFilters:UpdateFilters(frame)
	local filters = ED.Database:GetSetting("Filters");
	if not filters or not frame then
		return;
	end

	frame.active_events = frame.active_events or {};
	local dirty = false;

	for groupName, enabled in pairs(filters) do
		local chatTypes = ED.Constants.FILTER_OPTIONS[groupName];
		if chatTypes then
			for _, chatType in ipairs(chatTypes) do
				local event = ResolveEvent(chatType);
				local currentlyActive = frame.active_events[event] == true;
				if enabled ~= currentlyActive then
					frame.active_events[event] = enabled and true or nil;
					dirty = true;
				end
			end
		end
	end

	if dirty then
		frame:RefreshChat();
	end
end

---Checks if a specific event is currently active
---@param event string
---@param frame table?
---@return boolean
function ChatFilters:HasEvent(event, frame)
	frame = frame or ED.Frame;
	event = NormalizeEvent(event);

	frame.active_events = frame.active_events or {};
	return frame.active_events[event] == true;
end

---Initializes active events for a frame based on filter settings
---@param frame table
function ChatFilters:Init(frame)
	if not frame then return; end
	frame.active_events = frame.active_events or {};

	local filters = ED.Database:GetSetting("Filters");
	if not filters then return; end

	for groupName, enabled in pairs(filters) do
		local chatTypes = ED.Constants.FILTER_OPTIONS[groupName];
		if chatTypes then
			for _, chatType in ipairs(chatTypes) do
				local event = ResolveEvent(chatType);
				if enabled then
					frame.active_events[event] = true;
				else
					frame.active_events[event] = nil;
				end
			end
		end
	end
end

ED.ChatFilters = ChatFilters;
