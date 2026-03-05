-- Copyright The Eavesdropper Authors
-- SPDX-License-Identifier: Apache-2.0

---@type EavesdropperEnums
local Enums = ED.Enums;

---@class EavesdropperEvents : Frame
local Events = CreateFrame("Frame");

-- Set up event handler to call methods on Events by event name
Events:SetScript("OnEvent", function(self, event, ...)
	if self[event] then
		self[event](self, event, ...);
	end
end);

Events:RegisterEvent("PLAYER_REGEN_DISABLED");
Events:RegisterEvent("PLAYER_REGEN_ENABLED");
Events:RegisterEvent("PLAYER_FOCUS_CHANGED");
Events:RegisterEvent("PLAYER_TARGET_CHANGED");
Events:RegisterEvent("UPDATE_MOUSEOVER_UNIT");

-- Combat is entered when regen is disabled.
function Events:PLAYER_REGEN_DISABLED()
	if not ED or not ED.Database or not ED.Frame then return; end
	-- If HideInCombat is not in play, don't continue.
	if not ED.Database:GetSetting("HideInCombat") then return; end

	ED.Frame:HandleVisibility();
end

-- Combat is left when regen is enabled.
function Events:PLAYER_REGEN_ENABLED()
	if not ED or not ED.Database or not ED.Frame then return; end
	-- If HideInCombat is not in play, don't continue.
	if not ED.Database:GetSetting("HideInCombat") then return; end

	ED.Frame:HandleVisibility();
end

---PLAYER_FOCUS_CHANGED Fired when player focus changes.
function Events:PLAYER_FOCUS_CHANGED()
	if not ED or not ED.Database or not ED.Frame then return; end
	local targetPriority = ED.Database:GetSetting("TargetPriority");
	if targetPriority == Enums.TARGET_PRIORITY.MOUSEOVER_ONLY or targetPriority == Enums.TARGET_PRIORITY.TARGET_ONLY then return; end

	ED.Magnifier:HandleUpdate(Enums.MAGNIFIER_REASON.FOCUS);
end

---PLAYER_TARGET_CHANGED Fired when player target changes.
function Events:PLAYER_TARGET_CHANGED()
	if not ED or not ED.Database or not ED.Frame then return; end
	local targetPriority = ED.Database:GetSetting("TargetPriority");
	if targetPriority == Enums.TARGET_PRIORITY.MOUSEOVER_ONLY or targetPriority == Enums.TARGET_PRIORITY.FOCUS_ONLY then return; end

	ED.Magnifier:HandleUpdate(Enums.MAGNIFIER_REASON.TARGET);
end

---UPDATE_MOUSEOVER_UNIT Fired when mouseover unit changes.
function Events:UPDATE_MOUSEOVER_UNIT()
	if not ED or not ED.Database or not ED.Frame then return; end
	local targetPriority = ED.Database:GetSetting("TargetPriority");
	if targetPriority == Enums.TARGET_PRIORITY.TARGET_ONLY or targetPriority == Enums.TARGET_PRIORITY.FOCUS_ONLY then return; end

	ED.Magnifier:StartUpdateCheck();
end

ED.Events = Events;
