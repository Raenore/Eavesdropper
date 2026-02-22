-- Copyright The Eavesdropper Authors
-- SPDX-License-Identifier: Apache-2.0

---@class EavesdropperNotifications
local Notifications = {};

---@type number
local Notification_CD = 0;

---@type tables
local SharedMedia = LibStub("LibSharedMedia-3.0");

---@type table<string, {file: string, path: string}>
local soundCache = {};

---Flash the WoW client icon on the taskbar
function Notifications:FlashTaskbar()
	FlashClientIcon();
end

---Plays the configured alert sound if the throttle allows it
---@param notifType number Notification type (from ED.Enums.NOTIFICATIONS_TYPE)
function Notifications:PlayAlertSound(notifType)
	local now = GetTime();
	local throttle = ED.Database:GetSetting("NotificationThrottle");

	if now < Notification_CD + throttle then
		return;
	end
	Notification_CD = now;

	local key = ED.Enums.NOTIFICATIONS_TYPE_SOUND_KEYS[notifType];
	if not key then return; end

	local soundFile = ED.Database:GetSetting(key);
	if not soundFile or soundFile == "" then return; end

	-- Check cache: update only if user changed the setting
	if not soundCache[key] or soundCache[key].file ~= soundFile then
		local soundPath = SharedMedia:Fetch("sound", soundFile);
		soundCache[key] = { file = soundFile, path = soundPath };
	end

	local path = soundCache[key].path;
	if path then
		PlaySoundFile(path, "Master");
	end
end

ED.Notifications = Notifications;
