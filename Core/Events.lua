-- Copyright The Eavesdropper Authors
-- SPDX-License-Identifier: GPL-3.0-or-later

---@type EavesdropperEnums
local Enums = ED.Enums;

---@class EavesdropperEvents : Frame
local Events = CreateFrame("Frame");

---Set up event handler to call methods on Events by event name.
---Guard here covers all handlers: nothing fires until the Main and Mentions frames exist.
Events:SetScript("OnEvent", function(self, event, ...)
	if not ED.Frame or not ED.MentionsFrame then return; end
	if self[event] then
		self[event](self, event, ...);
	end
end);

Events:RegisterEvent("PLAYER_REGEN_DISABLED");
Events:RegisterEvent("PLAYER_REGEN_ENABLED");
Events:RegisterEvent("PLAYER_FOCUS_CHANGED");
Events:RegisterEvent("PLAYER_TARGET_CHANGED");
Events:RegisterEvent("UPDATE_MOUSEOVER_UNIT");
Events:RegisterEvent("GROUP_ROSTER_UPDATE");
Events:RegisterEvent("NAME_PLATE_UNIT_ADDED");

---Fired when combat begins (regen disabled). Handles frame visibility if HideInCombat is set.
function Events:PLAYER_REGEN_DISABLED()
	if not ED.Database:GetSetting("HideInCombat") then return; end
	Eavesdropper_SharedFrameMixin.ApplyCombatHidden(true);
end

---Fired when combat ends (regen enabled). Handles frame visibility if HideInCombat is set.
function Events:PLAYER_REGEN_ENABLED()
	if not ED.Database:GetSetting("HideInCombat") then return; end
	Eavesdropper_SharedFrameMixin.ApplyCombatHidden(false);
end

---Fired when the player's focus changes.
function Events:PLAYER_FOCUS_CHANGED()
	local targetPriority = ED.Database:GetSetting("TargetPriority");
	if targetPriority == Enums.TARGET_PRIORITY.MOUSEOVER_ONLY
	or targetPriority == Enums.TARGET_PRIORITY.TARGET_ONLY then return; end

	ED.Magnifier:HandleUpdate(Enums.MAGNIFIER_REASON.FOCUS);
end

---Fired when the player's target changes.
function Events:PLAYER_TARGET_CHANGED()
	local targetPriority = ED.Database:GetSetting("TargetPriority");
	if targetPriority == Enums.TARGET_PRIORITY.MOUSEOVER_ONLY
	or targetPriority == Enums.TARGET_PRIORITY.FOCUS_ONLY then return; end

	ED.Magnifier:HandleUpdate(Enums.MAGNIFIER_REASON.TARGET);
end

---Fired when the mouseover unit changes.
function Events:UPDATE_MOUSEOVER_UNIT()
	local targetPriority = ED.Database:GetSetting("TargetPriority");
	if targetPriority == Enums.TARGET_PRIORITY.TARGET_ONLY
	or targetPriority == Enums.TARGET_PRIORITY.FOCUS_ONLY then return; end

	ED.Magnifier:StartUpdateCheck();
end

---Fired when group composition changes.
function Events:GROUP_ROSTER_UPDATE()
	ED.PlayerCache:BackfillFromGroupRoster();
end

---Guild/communities panel re-fires this repeatedly while open, so it's debounced and only
---registered while a bare name is actually pending (PlayerCache:InsertAndRetrieve resumes it);
---unregistered below once nothing's left.
local guildRosterUpdatePending = false;

---Also fires after our own GuildRoster() request completes, not just on external roster changes.
function Events:GUILD_ROSTER_UPDATE()
	if guildRosterUpdatePending then return; end
	guildRosterUpdatePending = true;

	C_Timer.After(1, function()
		guildRosterUpdatePending = false;
		if not ED.PlayerCache:BackfillFromGuildRoster() then
			Events:UnregisterEvent("GUILD_ROSTER_UPDATE");
		end
	end);
end

---Fired when a nameplate appears; caches the unit's identity for later resolution.
function Events:NAME_PLATE_UNIT_ADDED(_, unitToken)
	ED.PlayerCache:CacheNameplateUnit(unitToken);
end

ED.Events = Events;
