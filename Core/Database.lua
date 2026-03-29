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
---@field SettingsWindowPosition EavesdropperWindowPosition?
---@field DedicatedWindowsPersist boolean?
---@field GroupWindowsPersist boolean?
---@field WelcomeMessage boolean?
local GLOBAL_DEFAULTS = {
	DedicatedWindows = true,
	DedicatedWindowsNewIndicator = true,
	DedicatedWindowsUnitPopups = true,
	DedicatedWindowsPersist = true,
	GroupWindows = true,
	GroupWindowsNewIndicator = true,
	GroupWindowsUnitPopups = true,
	GroupWindowsPersist = true,
	MinimapButton = {
		Hide = false,
		ShowAddonCompartmentButton = true,
	},
	SettingsWindowPosition = ED.Utils.ShallowCopy(Constants.DEFAULT_WINDOW_POSITION),
	WelcomeMessage = true,
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
---@field FocusTarget EavesdropperFocusTarget?
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
---@field NotificationDedicatedSound boolean?
---@field NotificationDedicatedSoundFile string?
---@field NotificationDedicatedFlashTaskbar boolean?
---@field NotificationEmotesSound boolean?
---@field NotificationEmotesSoundFile string?
---@field NotificationEmotesFlashTaskbar boolean?
---@field NotificationGroupSound boolean?
---@field NotificationGroupSoundFile string?
---@field NotificationGroupFlashTaskbar boolean?
---@field NotificationKeywordsSound boolean?
---@field NotificationKeywordsSoundFile string?
---@field NotificationKeywordsFlashTaskbar boolean?
---@field NotificationTargetSound boolean?
---@field NotificationTargetSoundFile string?
---@field NotificationTargetFlashTaskbar boolean?
---@field NotificationThrottle number?
---@field NPCAndQuestNameDisplayMode number?
---@field PreferMouseOver boolean?
---@field TargetOnly boolean?
---@field TargetPriority EavesdropperTargetPriority?
---@field TimestampBrackets boolean?
---@field UpdateTitleBarWithName boolean?
---@field UseRPName boolean?
---@field UseRPFirstName boolean?
---@field UseRPNameColor boolean?
---@field UseRPNameForTargets boolean?
---@field UseRPNameInNPCDialogue boolean?
---@field UseRPNameInQuestText boolean?
---@field UseRPNameInRolls boolean?
---@field WindowPosition EavesdropperWindowPosition?
---@field WindowSize EavesdropperWindowSize?
---@field Filters table<string, boolean>?
local DEFAULT_PROFILE = {
	ApplyOnMainChat = true,
	ColorBackground = ED.Utils.ShallowCopy(Constants.DEFAULT_BACKGROUND_COLOR),
	ColorTitleBar = ED.Utils.ShallowCopy(Constants.DEFAULT_BACKGROUND_COLOR),
	CompanionSupport = true,
	ElvUITheme = true,
	EnableKeywords = true,
	EnableMouse = false,
	EnablePartialKeywords = false,
	FocusTarget = Enums.FOCUS_TARGET.OVERRIDE,
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
	NotificationDedicatedSound = true,
	NotificationDedicatedSoundFile = "UI_VoiceChat_ChannelInitiated",
	NotificationDedicatedFlashTaskbar = true,
	NotificationEmotesSound = true,
	NotificationEmotesSoundFile = "UI_VoiceChat_ChatMessageIncomingActive",
	NotificationEmotesFlashTaskbar = true,
	NotificationGroupSound = true,
	NotificationGroupSoundFile = "UI_VoiceChat_TalkStart",
	NotificationGroupFlashTaskbar = true,
	NotificationKeywordsSound = true,
	NotificationKeywordsSoundFile = "UI_VoiceChat_ChatMessageIncoming",
	NotificationKeywordsFlashTaskbar = true,
	NotificationTargetSound = true,
	NotificationTargetSoundFile = "UI_VoiceChat_ChatMessageOutgoing",
	NotificationTargetFlashTaskbar = true,
	NotificationThrottle = 3,
	NPCAndQuestNameDisplayMode = 1,
	PreferMouseOver = true,
	TargetOnly = false,
	TargetPriority = Enums.TARGET_PRIORITY.PRIORITIZE_MOUSEOVER,
	TimestampBrackets = true,
	UpdateTitleBarWithName = false,
	UseRPName = true,
	UseRPFirstName = false,
	UseRPNameColor = true,
	UseRPNameForTargets = true,
	UseRPNameInNPCDialogue = true,
	UseRPNameInQuestText = true,
	UseRPNameInRolls = true,
	WindowPosition = ED.Utils.ShallowCopy(Constants.DEFAULT_WINDOW_POSITION),
	WindowSize = ED.Utils.ShallowCopy(Constants.DEFAULT_WINDOW_SIZE),
	Filters = ED.Utils.ShallowCopy(Constants.DEFAULT_FILTERS),
};

---@class EavesdropperCharSettings
---@field WindowVisible boolean?
local CHAR_DEFAULTS = {
	WindowVisible = true,
};

Database.currentProfile = nil;
Database.defaults = ED.Utils.DeepCopy(DEFAULT_PROFILE);
Database.charDefaults = ED.Utils.DeepCopy(CHAR_DEFAULTS);
Database.globalDefaults = ED.Utils.DeepCopy(GLOBAL_DEFAULTS);

---Returns a new table containing all keys from `base`, with keys from `override` applied on top.
---@param base table
---@param override table
---@return table
local function mergeTables(base, override)
	-- start with defaults
	local result = ED.Utils.ShallowCopy(base);
	-- apply profile overrides (including keys not in defaults)
	for k, v in pairs(override) do
		result[k] = v;
	end
	return result;
end

---Returns a pruned copy of `value` containing only keys that differ from `def`.
---Returns nil if no keys differ (signals "same as default, don't store").
---Always returns the table itself if `def` is nil (no defaults to compare against).
---@param value table
---@param def table?
---@return table?
local function pruneToDefaults(value, def)
	local newTable = {};
	-- store only keys that differ from defaults
	for k, v in pairs(value) do
		if not def or def[k] ~= v then
			newTable[k] = v;
		end
	end
	-- store table only if there is at least one diff
	return next(newTable) and newTable or nil;
end

---Removes any stored values from a profile that are identical to their defaults.
---Primitives matching defaults are nilled; table values are pruned key-by-key
---and removed entirely when every key matches the default.
---@param profile table
local function pruneProfile(profile)
	for key, value in pairs(profile) do
		local def = DEFAULT_PROFILE[key];
		if def == nil then -- luacheck: ignore 542 (empty if branch)
			-- No default exists for this key; leave it untouched.
		elseif type(value) == "table" then
			if type(def) == "table" then
				profile[key] = pruneToDefaults(value, def);
			end
		elseif value == def then
			profile[key] = nil;
		end
	end
end

---Initialises the account-wide saved variable and resolves the active profile for the current player.
function Database:Init()
	EavesdropperDB = EavesdropperDB or {
		global = {},
		profileKeys = {},
		profiles = {},
	};

	local db = EavesdropperDB;
	local playerKey = ED.Utils.GetUnitName();
	local profileName = db.profileKeys[playerKey] or "Default";

	ED.Globals.player_character_name = UnitName("player");
	ED.Globals.player_sender_name = playerKey;
	ED.Globals.player_guid = UnitGUID("player");

	db.profiles[profileName] = db.profiles[profileName] or {};

	self.currentProfile = db.profiles[profileName];
	db.profileKeys[playerKey] = profileName;

	---Prune all profiles to remove values that match their defaults.
	for _, profileData in pairs(db.profiles) do
		pruneProfile(profileData);
	end

	self:InitCharacterDatabase();
end

---@class EavesdropperCharDB
---@field version string
---@field history table
---@field playerCache table
---@field settings EavesdropperCharSettings
---@field dedicatedFrames string[]
---@field groupFrames EavesdropperSavedGroupFrame[]

---Initialises or migrates the character-specific chat database, clearing history on version change.
function Database:InitCharacterDatabase()
	EavesdropperCharDB = EavesdropperCharDB or {
		version = ED.Globals.addon_version,
		history = {},
		playerCache = {},
		settings = {},
	};

	local charDB = EavesdropperCharDB;

	-- Ensure settings, dedicatedFrames, and groupFrames tables exist for older DB versions.
	charDB.settings = charDB.settings or {};
	charDB.dedicatedFrames = charDB.dedicatedFrames or {};
	charDB.groupFrames = charDB.groupFrames or {};

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

---Creates a new profile and switches to it. If the profile already exists, switches to it.
---@param profileName string
---@return boolean success
function Database:CreateProfile(profileName)
	if not profileName or profileName == "" then return false; end
	self:SetProfile(profileName);
	return true;
end

---Creates a new profile as a copy of an existing one and switches to it.
---@param sourceName string
---@param newName string
---@return boolean success
function Database:CloneProfile(sourceName, newName)
	if not newName or newName == "" then return false; end
	if not EavesdropperDB.profiles[sourceName] then return false; end

	self:SetProfile(newName);
	return self:CopyProfile(sourceName);
end

---Copies all settings from a source profile into the current profile, overwriting everything.
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

---Deletes a profile from saved variables. Prevents deleting the active profile.
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
---| "FocusTarget"
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
---| "NotificationDedicatedSound"
---| "NotificationDedicatedSoundFile"
---| "NotificationDedicatedFlashTaskbar"
---| "NotificationEmotesSound"
---| "NotificationEmotesSoundFile"
---| "NotificationEmotesFlashTaskbar"
---| "NotificationGroupSound"
---| "NotificationGroupSoundFile"
---| "NotificationGroupFlashTaskbar"
---| "NotificationKeywordsSound"
---| "NotificationKeywordsSoundFile"
---| "NotificationKeywordsFlashTaskbar"
---| "NotificationTargetSound"
---| "NotificationTargetSoundFile"
---| "NotificationTargetFlashTaskbar"
---| "NotificationThrottle"
---| "NPCAndQuestNameDisplayMode"
---| "PreferMouseOver"
---| "TargetOnly"
---| "TargetPriority"
---| "TimestampBrackets"
---| "UpdateTitleBarWithName"
---| "UseRPName"
---| "UseRPFirstName"
---| "UseRPNameColor"
---| "UseRPNameForTargets"
---| "UseRPNameInNPCDialogue"
---| "UseRPNameInQuestText"
---| "UseRPNameInRolls"
---| "Filters"
---| "WindowPosition"
---| "WindowSize"

---Returns the effective value of a profile setting, merging profile overrides onto defaults.
---For table settings, always returns a new merged copy so callers cannot mutate stored data.
---@param key EavesdropperSettingKey
---@return any settingValue Value of the setting, or nil
function Database:GetSetting(key)
	local defaults = self.defaults;
	if not defaults then return nil; end

	local def = defaults[key];
	local profile = self.currentProfile;

	if profile and profile[key] ~= nil then
		-- Table: merge defaults with profile overrides so neither side is mutated.
		if type(def) == "table" then
			return mergeTables(def, profile[key]);
		end
		return profile[key];
	end

	-- No profile override: return a fresh copy of the default table, or the scalar.
	if type(def) == "table" then
		return ED.Utils.ShallowCopy(def);
	end

	return def;
end

---Stores a setting in the current profile, pruning values equal to their defaults.
---Table values are stored as diff-only; primitives equal to defaults are nilled out.
---@param key EavesdropperSettingKey
---@param value any
function Database:SetSetting(key, value)
	local profile = self.currentProfile;
	if not profile then return; end

	local def = self.defaults[key];

	if type(value) == "table" then
		profile[key] = pruneToDefaults(value, def);
	elseif value == def then
		profile[key] = nil;
	else
		profile[key] = value;
	end

	if ED.SettingsFrame then
		ED.SettingsFrame:RefreshWidgets();
	end
end

---@alias EavesdropperCharSettingKey
---| "WindowVisible"

---Returns the effective value of a character setting, falling back to defaults.
---@param key EavesdropperCharSettingKey
---@return any
function Database:GetCharSetting(key)
	if not EavesdropperCharDB then return nil; end

	local settings = EavesdropperCharDB.settings;
	if not settings then return nil; end

	local value = settings[key];
	if value ~= nil then return value; end

	local def = self.charDefaults[key];
	if type(def) == "table" then
		return ED.Utils.ShallowCopy(def);
	end

	return def;
end

---Stores a character setting, pruning values equal to their defaults.
---@param key EavesdropperCharSettingKey
---@param value any
function Database:SetCharSetting(key, value)
	if not EavesdropperCharDB then return; end

	local settings = EavesdropperCharDB.settings;
	if not settings then
		settings = {};
		EavesdropperCharDB.settings = settings;
	end

	local def = self.charDefaults[key];

	if type(value) == "table" then
		settings[key] = pruneToDefaults(value, def);
	elseif value == def then
		settings[key] = nil;
	else
		settings[key] = value;
	end
end

---@alias EavesdropperGlobalSettingKey
---| "DedicatedWindows"
---| "DedicatedWindowsNewIndicator"
---| "DedicatedWindowsUnitPopups"
---| "DedicatedWindowsPersist"
---| "GroupWindows"
---| "GroupWindowsNewIndicator"
---| "GroupWindowsUnitPopups"
---| "GroupWindowsPersist"
---| "MinimapButton"
---| "SettingsWindowPosition"
---| "WelcomeMessage"

---Returns the effective value of a global setting.
---For table keys, the stored table is returned directly as a live reference which is required
---by LibDBIcon, which mutates the MinimapButton table in place (e.g. minimapPos on drag).
---On first access, a missing table key is initialised from defaults and written back so that
---LibDBIcon receives a real table it can write into immediately after Register() is called.
---Took me way too long to figure out, but was the cause of how some people's minimap button reset.
---@param key EavesdropperGlobalSettingKey
---@return any
function Database:GetGlobalSetting(key)
	if not EavesdropperDB then EavesdropperDB = {}; end
	if not EavesdropperDB.global then EavesdropperDB.global = {}; end

	local stored = EavesdropperDB.global[key];

	if stored ~= nil then return stored; end

	local def = self.globalDefaults[key];
	if type(def) == "table" then
		-- Initialise and store the table so LibDBIcon has a live reference to mutate.
		local init = ED.Utils.ShallowCopy(def);
		EavesdropperDB.global[key] = init;
		return init;
	end

	return def;
end

---Stores a global setting. Table values are merged into the existing stored table in place,
---preserving keys written by LibDBIcon (e.g. minimapPos) that are not part of our defaults.
---@param key EavesdropperGlobalSettingKey
---@param value any
function Database:SetGlobalSetting(key, value)
	if not EavesdropperDB then EavesdropperDB = {}; end
	if not EavesdropperDB.global then EavesdropperDB.global = {}; end

	local def = self.globalDefaults[key];

	if type(value) == "table" then
		-- Merge into the existing table to preserve LibDBIcon-managed keys.
		EavesdropperDB.global[key] = EavesdropperDB.global[key] or {};
		for k, v in pairs(value) do
			EavesdropperDB.global[key][k] = v;
		end
	elseif value == def then
		EavesdropperDB.global[key] = nil;
	else
		EavesdropperDB.global[key] = value;
	end

	if ED.SettingsFrame then
		ED.SettingsFrame:RefreshWidgets();
	end
end

ED.Database = Database;
