-- Copyright The Eavesdropper Authors
-- SPDX-License-Identifier: GPL-3.0-or-later

---@type EavesdropperConstants
local Constants = ED.Constants;

---@type EavesdropperEnums
local Enums = ED.Enums;

---@class EavesdropperMagnifier
local Magnifier = {};

local magnifiedName = nil;
local magnifiedGUID = nil;
local clearTimerToken = nil;

---@type Frame?
Magnifier.Frame = nil;

---Triggers a chat timestamp refresh on the main Eavesdropper frame.
local function TickerCallback()
	if ED.Frame then
		ED.Frame:UpdateTarget();
	end
end

---Starts a repeating ticker if one is not already running.
---@param self table
---@param handleField string
---@param interval number
---@param callback function
local function CreateTicker(self, handleField, interval, callback)
	if not self[handleField] then
		self[handleField] = C_Timer.NewTicker(interval, callback);
	end
end

---Cancels and clears the stored ticker.
---@param self table
---@param handleField string
local function StopTicker(self, handleField)
	if self[handleField] then
		self[handleField]:Cancel();
		self[handleField] = nil;
	end
end

---Begins polling via OnUpdate to track mouseover unit changes.
function Magnifier:StartUpdateCheck()
	if not self.Frame or self.Frame:GetScript("OnUpdate") then return; end
	self.Frame:SetScript("OnUpdate", function()
		self:HandleUpdate(Enums.MAGNIFIER_REASON.MOUSEOVER);
	end);
end

---Stops the OnUpdate polling loop.
function Magnifier:StopUpdateCheck()
	if self.Frame then
		self.Frame:SetScript("OnUpdate", nil);
	end
end

---Returns the currently magnified unit name and GUID.
---@return string? name
---@return string? guid
function Magnifier:GetMagnified()
	return magnifiedName, magnifiedGUID;
end

---Notifies the UI of a magnifier change, debounced to avoid flicker on rapid target switches.
---@param reason EavesdropperMagnifierReason?
---@return nil
function Magnifier:OnMagnifiedChanged(reason) -- luacheck: no unused (reason)
	-- Bail out when there's secrets involved (PvP or other situations we don't support).
	if not canaccessvalue(magnifiedGUID) or not canaccessvalue(self.lastNotifiedGUID) then
		return;
	end

	-- Skip if the magnified target has not changed (except when being cleared).
	local isUnchanged = magnifiedGUID ~= nil
		and magnifiedGUID == self.lastNotifiedGUID
		and magnifiedName == self.lastNotifiedName;
	if isUnchanged then return; end

	if clearTimerToken then
		clearTimerToken:Cancel();
		clearTimerToken = nil;
	end

	-- Calculate delay (this avoids target flicks in certain situations)
	local delay = magnifiedGUID and Constants.MAGNIFIER_CHANGE_THROTTLE or Constants.MAGNIFIER_NIL_THROTTLE;

	self.lastNotifiedGUID = magnifiedGUID;
	self.lastNotifiedName = magnifiedName;
	clearTimerToken = C_Timer.NewTimer(delay, function()
		clearTimerToken = nil;
		ED.Debug:Print("Magnifier:OnMagnifiedChanged() -", magnifiedName);
		if ED and ED.Frame then
			ED.Frame:UpdateMagnifier();
		end
	end);
end

---Returns true if the unit is a player, or an owned pet/companion (with CompanionSupport on).
---@param unit string?
---@return boolean
local function IsTrackableUnit(unit)
	if not unit or not UnitExists(unit) then return false; end
	if UnitIsPlayer(unit) then return true; end
	return UnitOwnerGUID(unit) ~= nil and ED.Database:GetSetting("CompanionSupport");
end

---Polls the current target/mouseover/focus unit and updates the magnified state accordingly.
---@param reason EavesdropperMagnifierReason?
function Magnifier:HandleUpdate(reason)
	if not ED or not ED.Database then return; end
	if not canaccessvalue(magnifiedGUID) then return; end

	local targetPriority = ED.Database:GetSetting("TargetPriority");
	if not targetPriority then return; end

	local focusTarget = ED.Database:GetSetting("FocusTarget");
	local entry = Enums.TARGET_PRIORITY_UNIT_MAP[targetPriority];
	local priority = entry and entry.priority;
	local secondary = entry and entry.secondary;

	-- Focus is only considered when the mode is not target-only or mouseover-only.
	local focus;
	if focusTarget ~= Enums.FOCUS_TARGET.IGNORE
	and targetPriority ~= Enums.TARGET_PRIORITY.TARGET_ONLY
	and targetPriority ~= Enums.TARGET_PRIORITY.MOUSEOVER_ONLY then
		focus = "focus";
	end

	local unit;
	if focusTarget == Enums.FOCUS_TARGET.OVERRIDE then
		unit = (focus and IsTrackableUnit(focus) and focus)
			or (priority and IsTrackableUnit(priority) and priority)
			or (secondary and IsTrackableUnit(secondary) and secondary);
	elseif focusTarget == Enums.FOCUS_TARGET.FALLBACK then
		unit = (priority and IsTrackableUnit(priority) and priority)
			or (secondary and IsTrackableUnit(secondary) and secondary)
			or (focus and IsTrackableUnit(focus) and focus);
	elseif focusTarget == Enums.FOCUS_TARGET.IGNORE then
		unit = (priority and IsTrackableUnit(priority) and priority)
			or (secondary and IsTrackableUnit(secondary) and secondary);
	end

	-- Determine whether OnUpdate polling should be active.
	local target = UnitExists("target");
	local mouseover = UnitExists("mouseover");
	local polling = false;

	if targetPriority == Enums.TARGET_PRIORITY.TARGET_ONLY then
		polling = false; -- Never poll; target is event-driven.
	elseif targetPriority == Enums.TARGET_PRIORITY.MOUSEOVER_ONLY then
		polling = mouseover; -- Poll whenever a mouseover exists.
	elseif targetPriority == Enums.TARGET_PRIORITY.PRIORITIZE_TARGET then
		polling = not target and mouseover; -- Poll only when there is no target.
	elseif targetPriority == Enums.TARGET_PRIORITY.PRIORITIZE_MOUSEOVER then
		polling = mouseover; -- Poll whenever a mouseover exists.
	end

	local unitName, unitGUID;
	if unit then
		if UnitIsPlayer(unit) then
			unitName = ED.Utils.GetUnitName(unit);
			unitGUID = UnitGUID(unit);
		else
			-- Pets/companions are already filtered by IsTrackableUnit; track the owner's GUID, not the pet's.
			unitGUID = UnitOwnerGUID(unit);
			unitName = nil;
		end
	end

	if unitGUID and not canaccessvalue(unitGUID) then return; end

	if polling then
		self:StartUpdateCheck();
	else
		self:StopUpdateCheck();
	end

	-- Keep the chat timestamp ticker alive while a unit is magnified.
	if unitGUID then
		CreateTicker(self, "EavesdropperUpdate", Constants.WINDOW_REFRESH_INTERVAL, TickerCallback);
	else
		StopTicker(self, "EavesdropperUpdate");
	end

	-- If we are polling and the unit has not changed, nothing further to do.
	if polling and magnifiedGUID == unitGUID then return; end

	magnifiedName = unitName;
	magnifiedGUID = unitGUID;
	self:OnMagnifiedChanged(reason);
end

---Creates the internal polling frame.
function Magnifier:Setup()
	if Magnifier.Frame then return; end
	Magnifier.Frame = CreateFrame("Frame");
	Magnifier.Frame:Show();
end

ED.Magnifier = Magnifier;
