-- Copyright The Eavesdropper Authors
-- SPDX-License-Identifier: Apache-2.0

---@type EavesdropperEnums
local Enums = ED.Enums;

---@class EavesdropperEvents : Frame
local Events = CreateFrame("Frame");

---Set up event handler to call methods on Events by event name.
---Guard here covers all handlers: if core modules are not ready, nothing fires.
Events:SetScript("OnEvent", function(self, event, ...)
	if not ED or not ED.Database or not ED.Frame then return; end
	if self[event] then
		self[event](self, event, ...);
	end
end);

Events:RegisterEvent("PLAYER_REGEN_DISABLED");
Events:RegisterEvent("PLAYER_REGEN_ENABLED");
Events:RegisterEvent("PLAYER_FOCUS_CHANGED");
Events:RegisterEvent("PLAYER_TARGET_CHANGED");
Events:RegisterEvent("UPDATE_MOUSEOVER_UNIT");

---Fired when combat begins (regen disabled). Handles frame visibility if HideInCombat is set.
function Events:PLAYER_REGEN_DISABLED()
	if not ED.Database:GetSetting("HideInCombat") then return; end
	ED.Frame:HandleVisibility();

	ED.DedicatedFrame:ForEachFrame(function(frame)
		frame.isCombatHidden = true;
		frame:HandleVisibility();
	end);

	ED.GroupFrame:ForEachFrame(function(frame)
		frame.isCombatHidden = true;
		frame:HandleVisibility();
	end);
end

---Fired when combat ends (regen enabled). Handles frame visibility if HideInCombat is set.
function Events:PLAYER_REGEN_ENABLED()
	if not ED.Database:GetSetting("HideInCombat") then return; end
	ED.Frame:HandleVisibility();

	ED.DedicatedFrame:ForEachFrame(function(frame)
		frame.isCombatHidden = false;
		frame:HandleVisibility();
	end);

	ED.GroupFrame:ForEachFrame(function(frame)
		frame.isCombatHidden = false;
		frame:HandleVisibility();
	end);
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

ED.Events = Events;
