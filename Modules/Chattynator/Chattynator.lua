-- Copyright The Eavesdropper Authors
-- SPDX-License-Identifier: GPL-3.0-or-later

---@class EavesdropperChattynator
ED.Chattynator = {};

---Message IDs of emote/roll lines for retroactive refresh.
---Capped to avoid invalidating IDs Chattynator has already discarded.
local knownMessageIds = {};
local knownMessageIdCount = 0;
local MAX_KNOWN_MESSAGE_IDS = 2000;

---Records id, resetting the set if it reaches the cap.
---@param id string
local function RememberMessageId(id)
	if knownMessageIds[id] then return; end
	if knownMessageIdCount >= MAX_KNOWN_MESSAGE_IDS then
		wipe(knownMessageIds);
		knownMessageIdCount = 0;
	end
	knownMessageIds[id] = true;
	knownMessageIdCount = knownMessageIdCount + 1;
end

---Chattynator modifier; must be named upvalue for RemoveModifier to match by reference.
---@param data table Chattynator message data: text, id, typeInfo.event, typeInfo.player.name
local function ApplyAdvancedFormatting(data)
	local typeInfo = data.typeInfo;
	local event = typeInfo and typeInfo.event;
	if event ~= "CHAT_MSG_TEXT_EMOTE" and event ~= "CHAT_MSG_SYSTEM" then return; end

	if data.id then
		RememberMessageId(data.id);
	end

	if not ED.Database:GetSetting("ApplyOnMainChat") then return; end

	-- Chattynator only exposes a name here, never a GUID.
	local sender = typeInfo.player and typeInfo.player.name;
	local displayMode = ED.AdvancedFormatter:ResolveMainChatDisplayMode();
	local entry, name, applyRPName = ED.AdvancedFormatter:BuildFormattingEntry(event, data.text, sender, nil, displayMode);
	if not entry then return; end

	if entry.e == "CHAT_MSG_TEXT_EMOTE" then
		data.text = ED.ChatFormatter.FormatTextEmoteTargetWithRPName(entry, data.text, displayMode);
	elseif entry.e == "ROLL" then
		local rollName = applyRPName and ED.Utils.PlayerHyperlink(entry.s, name) or name;
		data.text = ED.ChatFormatter.SubstituteNameOccurrence(data.text, entry.s, rollName);
	end
end

-- Chattynator may load before or after this file.
EventUtil.ContinueOnAddOnLoaded("Chattynator", function()
	Chattynator.API.AddModifier(ApplyAdvancedFormatting);
end);

---Retroactively reformats emote/roll lines Chattynator has already processed.
function ED.Chattynator.RefreshMessages()
	if not Chattynator or type(Chattynator.API.InvalidateMessage) ~= "function" then return; end

	for id in pairs(knownMessageIds) do
		Chattynator.API.InvalidateMessage(id);
	end
end
