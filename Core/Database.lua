-- Copyright The Eavesdropper Authors
-- SPDX-License-Identifier: Apache-2.0

---@type EavesdropperConstants
local Constants = ED.Constants;

---@type EavesdropperEnums
local Enums = ED.Enums;

---@class EavesdropperDatabase
---@field currentProfile EavesdropperProfile?
---@field defaults EavesdropperProfile
---@field globalDefaults EavesdropperGlobal
local Database = {};

---@class EavesdropperGlobalMinimapButton
---@field Hide boolean
---@field ShowAddonCompartmentButton boolean

---@class EavesdropperGlobal
---@field MinimapButton EavesdropperGlobalMinimapButton?
local GLOBAL_DEFAULTS = {
	MinimapButton = {
		Hide = false,
		ShowAddonCompartmentButton = true,
	},
	SettingsWindowPosition = ED.Utils.ShallowCopy(Constants.DEFAULT_WINDOW_POSITION);
};

---@class EavesdropperProfile
---@field ApplyOnMainChat boolean?
---@field ColorBackground table?
---@field ColorTitleBar table?
---@field CompanionSupport boolean?
---@field ElvUITheme boolean?
---@field EnableKeywords boolean?
---@field EnableMouse boolean?
---@field EnablePartialKeywords boolean?
---@field FontFace string?
---@field FontOutline number?
---@field FontShadow boolean?
---@field FontSize number?
---@field HideCloseButton boolean?
---@field HideInCombat boolean?
---@field HideWhenEmpty boolean?
---@field HighlightColor table<string, number>?
---@field HighlightKeywords string?
---@field HighlightMessages boolean?
---@field LockScroll boolean?
---@field LockTitleBar boolean?
---@field LockWindow boolean?
---@field MaxHistory number?
---@field NameDisplayMode number?
---@field NotificationEmotesSound boolean?
---@field NotificationEmotesSoundFile string?
---@field NotificationEmotesFlashTaskbar boolean?
---@field NotificationKeywordsSound boolean?
---@field NotificationKeywordsSoundFile string?
---@field NotificationKeywordsFlashTaskbar boolean?
---@field NotificationTargetSound boolean?
---@field NotificationTargetSoundFile string?
---@field NotificationTargetFlashTaskbar boolean?
---@field NotificationThrottle number?
---@field PreferMouseOver boolean?
---@field TargetOnly boolean?
---@field TimestampBrackets boolean?
---@field UpdateTitleBarWithName boolean?
---@field UseRPName boolean?
---@field UseRPFirstName boolean?
---@field UseRPNameColor boolean?
---@field UseRPNameForTargets boolean?
---@field UseRPNameInRolls boolean?
---@field Filters table<string, boolean>?
---@field WindowPosition EavesdropperWindowPosition?
---@field WindowSize EavesdropperWindowSize?
local DEFAULT_PROFILE = {
	ApplyOnMainChat = true,
	ColorBackground = ED.Utils.ShallowCopy(Constants.DEFAULT_BACKGROUND_COLOR),
	ColorTitleBar = ED.Utils.ShallowCopy(Constants.DEFAULT_BACKGROUND_COLOR),
	CompanionSupport = true,
	ElvUITheme = true,
	EnableKeywords = true,
	EnableMouse = false,
	EnablePartialKeywords = false,
	FontFace = "Arial Narrow",
	FontOutline = 1,
	FontShadow = true,
	FontSize = 12,
	HideCloseButton = false,
	HideInCombat = false,
	HideWhenEmpty = false,
	HighlightColor = { r = 0, g = 1, b = 0 },
	HighlightKeywords = "<firstname>, <lastname>, <oocname>",
	HighlightMessages = false,
	LockScroll = false,
	LockTitleBar = false,
	LockWindow = false,
	MaxHistory = 50,
	NameDisplayMode = 1,
	NotificationEmotesSound = true,
	NotificationEmotesSoundFile = "UI_VoiceChat_ChatMessageIncomingActive",
	NotificationEmotesFlashTaskbar = true,
	NotificationKeywordsSound = true,
	NotificationKeywordsSoundFile = "UI_VoiceChat_ChatMessageIncoming",
	NotificationKeywordsFlashTaskbar = true,
	NotificationTargetSound = true,
	NotificationTargetSoundFile = "UI_VoiceChat_ChatMessageOutgoing",
	NotificationTargetFlashTaskbar = true,
	NotificationThrottle = 3,
	PreferMouseOver = true,
	TargetOnly = false,
	TargetPriority = Enums.TARGET_PRIORITY.PRIORITIZE_MOUSEOVER,
	TimestampBrackets = true,
	UpdateTitleBarWithName = false,
	UseRPName = true,
	UseRPFirstName = false,
	UseRPNameColor = true,
	UseRPNameForTargets = true,
	UseRPNameInRolls = true,
	WindowPosition = ED.Utils.ShallowCopy(Constants.DEFAULT_WINDOW_POSITION);
	WindowSize = ED.Utils.ShallowCopy(Constants.DEFAULT_WINDOW_SIZE);
	Filters = ED.Utils.ShallowCopy(Constants.DEFAULT_FILTERS),
};

Database.currentProfile = nil;
Database.defaults = ED.Utils.DeepCopy(DEFAULT_PROFILE);
Database.globalDefaults = ED.Utils.DeepCopy(GLOBAL_DEFAULTS);

---Initializes the account-wide and character-specific databases.
---@return nil
function Database:Init()
	EavesdropperDB = EavesdropperDB or {
		global = {},
		profileKeys = {},
		profiles = {},
	};

	local db = EavesdropperDB;
	local playerKey = ED.Utils.GetUnitName();
	local profileName = db.profileKeys[playerKey] or "Default";

	db.profiles[profileName] = db.profiles[profileName] or {};

	self.currentProfile = db.profiles[profileName];
	db.profileKeys[playerKey] = profileName;

	self:InitCharacterDatabase();
end

---Initializes or migrates the character-specific chat database.
---@return nil
function Database:InitCharacterDatabase()
	EavesdropperCharDB = EavesdropperCharDB or {
		version = ED.Globals.addon_version,
		history = {},
		playerCache = {},
	};

	local charDB = EavesdropperCharDB;

	if charDB.version ~= ED.Globals.addon_version then
		charDB.version = ED.Globals.addon_version;
		charDB.history = {};
		charDB.playerCache = {};
	end

	ED.ChatHistory:LoadFromSaved(charDB.history);
	ED.PlayerCache:LoadFromSaved(charDB.playerCache, 3600);
end

---Switches to a different profile.
---@param profileName string Name of the profile to switch to.
---@return nil
function Database:SetProfile(profileName)
	if not profileName or profileName == "" then return; end

	local db = EavesdropperDB;
	db.profiles[profileName] = db.profiles[profileName] or {};

	self.currentProfile = db.profiles[profileName];

	local playerKey = ED.Utils.GetUnitName();
	db.profileKeys[playerKey] = profileName;

	ED.Frame:ApplyProfileSettings();
end

---Returns the current profile table.
---@return EavesdropperProfile? currentProfile
function Database:GetProfile()
	return self.currentProfile;
end

---Returns the name of the current profile for the current player.
---@return string? currentProfile
function Database:GetProfileName()
	if not EavesdropperDB then return nil; end
	local playerKey = ED.Utils.GetUnitName();
	return EavesdropperDB.profileKeys[playerKey];
end

---Returns a table of all profile names.
---@param excludeCurrent boolean? Exclude the active profile
---@param excludeDefault boolean? Exclude the "Default" profile
---@return table<string, string> profilesList Table of profile names
function Database:GetAllProfiles(excludeCurrent, excludeDefault)
	local results = {};
	if not EavesdropperDB or not EavesdropperDB.profiles then
		return results;
	end

	local currentName = self:GetProfileName();

	for name in pairs(EavesdropperDB.profiles) do
		if not ((excludeCurrent and name == currentName) or
				(excludeDefault and name == "Default")) then
			results[name] = name;
		end
	end

	return results;
end

---Creates a new profile and switches to it.
---@param profileName string
---@return boolean success
function Database:CreateProfile(profileName)
	if not profileName or profileName == "" then return false; end
	self:SetProfile(profileName);
	return true;
end

---Clones an existing profile into a new profile.
---@param sourceName string
---@param newName string
---@return boolean success
function Database:CloneProfile(sourceName, newName)
	if not newName or newName == "" then return false; end
	if not EavesdropperDB.profiles[sourceName] then return false; end

	self:SetProfile(newName);
	return self:CopyProfile(sourceName);
end

---Copies a source profile into the current profile, overwriting all settings.
---@param sourceName string
---@return boolean success
function Database:CopyProfile(sourceName)
	local current = self.currentProfile;
	local source = EavesdropperDB.profiles[sourceName];
	if not current or not source then return false; end

	for k in pairs(current) do
		current[k] = nil;
	end

	local copy = ED.Utils.DeepCopy(source);
	for k, v in pairs(copy) do
		current[k] = v;
	end

	ED.Frame:ApplyProfileSettings();
	return true;
end

---Deletes a profile from saved variables.
---@param profileName string
---@return boolean success
function Database:DeleteProfile(profileName)
	if not profileName or profileName == "" then return false; end
	if profileName == self:GetProfileName() then return false; end
	if not EavesdropperDB.profiles[profileName] then return true; end

	EavesdropperDB.profiles[profileName] = nil;

	for key, name in pairs(EavesdropperDB.profileKeys) do
		if name == profileName then
			EavesdropperDB.profileKeys[key] = nil;
		end
	end

	return true;
end

---Resets the current profile to default values.
---@return boolean success
function Database:ResetProfile()
	local current = self.currentProfile;
	if not current then return false; end

	for k in pairs(current) do
		current[k] = nil;
	end

	for k, v in pairs(self.defaults) do
		current[k] = type(v) == "table" and ED.Utils.ShallowCopy(v) or v;
	end

	ED.Frame:ApplyProfileSettings();
	return true;
end

---@alias EavesdropperSettingKey
---| "ApplyOnMainChat"
---| "ColorBackground"
---| "ColorTitleBar"
---| "CompanionSupport"
---| "ElvUITheme"
---| "EnableKeywords"
---| "EnableMouse"
---| "EnablePartialKeywords"
---| "FontFace"
---| "FontOutline"
---| "FontShadow"
---| "FontSize"
---| "HideCloseButton"
---| "HideInCombat"
---| "HideWhenEmpty"
---| "HighlightColor"
---| "HighlightKeywords"
---| "HighlightMessages"
---| "LockScroll"
---| "LockTitleBar"
---| "LockWindow"
---| "MaxHistory"
---| "NameDisplayMode"
---| "NotificationEmotesSound"
---| "NotificationEmotesSoundFile"
---| "NotificationEmotesFlashTaskbar"
---| "NotificationKeywordsSound"
---| "NotificationKeywordsSoundFile"
---| "NotificationKeywordsFlashTaskbar"
---| "NotificationTargetSound"
---| "NotificationTargetSoundFile"
---| "NotificationTargetFlashTaskbar"
---| "NotificationThrottle"
---| "PreferMouseOver"
---| "TargetOnly"
---| "TimestampBrackets"
---| "UpdateTitleBarWithName"
---| "UseRPName"
---| "UseRPFirstName"
---| "UseRPNameColor"
---| "UseRPNameForTargets"
---| "UseRPNameInRolls"
---| "Filters"
---| "WindowPosition"
---| "WindowSize"

---Gets a value from the current profile, falling back to defaults.
---@param key EavesdropperSettingKey
---@return any settingValue Value of the setting, or nil
function Database:GetSetting(key)
	local profile = self.currentProfile;
	local defaults = self.defaults;

	if not defaults then return nil; end
	if not profile then return defaults[key]; end

	local value = profile[key];
	if value ~= nil then
		return value;
	end

	return defaults[key];
end

---Sets a value in the current profile.
---@param key EavesdropperSettingKey
---@param value any
---@return nil
function Database:SetSetting(key, value)
	local profile = self.currentProfile;
	if not profile then return; end

	if type(value) == "table" then
		profile[key] = value;
	elseif value == self.defaults[key] then
		profile[key] = nil;
	else
		profile[key] = value;
	end

	if ED.SettingsFrame then
		ED.SettingsFrame:RefreshWidgets();
	end
end

---@alias EavesdropperGlobalSettingKey
---| "MinimapButton"
---| "SettingsWindowPosition"

---Gets a value from the global database, falling back to defaults.
---@param key EavesdropperGlobalSettingKey
---@return any settingValue Value of the Global setting, or nil
function Database:GetGlobalSetting(key)
	local defaults = self.globalDefaults;
	if not defaults then return nil; end

	if not EavesdropperDB or not EavesdropperDB.global then
		local def = defaults[key];
		return type(def) == "table" and ED.Utils.ShallowCopy(def) or def;
	end

	local value = EavesdropperDB.global[key];
	if value ~= nil then
		return value;
	end

	local def = defaults[key];
	return type(def) == "table" and ED.Utils.ShallowCopy(def) or def;
end

---Sets a value in the global database.
---@param key EavesdropperGlobalSettingKey
---@param value any
function Database:SetGlobalSetting(key, value)
	if not EavesdropperDB or not EavesdropperDB.global then
		return;
	end

	if type(value) == "table" then
		EavesdropperDB.global[key] = value;
	elseif value == self.globalDefaults[key] then
		EavesdropperDB.global[key] = nil;
	else
		EavesdropperDB.global[key] = value;
	end
end

ED.Database = Database;
