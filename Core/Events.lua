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
Events:RegisterEvent("PLAYER_TARGET_CHANGED");
Events:RegisterEvent("UPDATE_MOUSEOVER_UNIT");

function Events:PLAYER_REGEN_DISABLED()
	-- Combat is entered when regen is disabled.
	if not ED or not ED.Database or not ED.Frame then return; end
	if not ED.Database:GetSetting("HideInCombat") then return; end

	ED.Frame:Hide();
end

function Events:PLAYER_REGEN_ENABLED()
	-- Combat is left when regen is enabled.
	if not ED or not ED.Database or not ED.Frame then return; end
	if not ED.Database:GetSetting("HideInCombat") then return; end

	ED.Frame:Show();
end

---PLAYER_TARGET_CHANGED Fired when player target changes.
function Events:PLAYER_TARGET_CHANGED()
	if not ED or not ED.Database or not ED.Frame then return; end
	local targetPriority = ED.Database:GetSetting("TargetPriority");
	if targetPriority == Enums.TARGET_PRIORITY.MOUSEOVER_ONLY then return; end

	ED.Magnifier:HandleUpdate(1);
end

---UPDATE_MOUSEOVER_UNIT Fired when mouseover unit changes.
function Events:UPDATE_MOUSEOVER_UNIT()
	if not ED or not ED.Database or not ED.Frame then return; end
	local targetPriority = ED.Database:GetSetting("TargetPriority");
	if targetPriority == Enums.TARGET_PRIORITY.TARGET_ONLY then return; end

	ED.Magnifier:StartUpdateCheck();
end


ED.Events = Events;
