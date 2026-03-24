-- Copyright The Eavesdropper Authors
-- SPDX-License-Identifier: Apache-2.0

local L = ED.Localization;

---@class EavesdropperConstants
local Constants = {};

---Events for which target/emote notifications should never fire.
---@type table<string, boolean>
Constants.CHANNELS_TO_SKIP_NOTIFICATIONS = {
	CHAT_MSG_ONLINE            = true,
	CHAT_MSG_OFFLINE           = true,
	CHAT_MSG_CHANNEL_JOIN      = true,
	CHAT_MSG_CHANNEL_LEAVE     = true,
	CHAT_MSG_GUILD_ACHIEVEMENT = true,
	CHAT_MSG_GUILD_MOTD        = true,
	CHAT_MSG_WHISPER_INFORM    = true,
};

---Font size bounds for the chat box.
---@type table<string, number>
Constants.CHAT_BOX = {
	MIN_FONT_SIZE = 6,
	MAX_FONT_SIZE = 24,
};

---All chat events the addon registers filters for.
---@type string[]
Constants.CHAT_EVENTS_ALL = {
	"CHAT_MSG_SAY",
	"CHAT_MSG_EMOTE",
	"CHAT_MSG_TEXT_EMOTE",
	"CHAT_MSG_WHISPER",
	"CHAT_MSG_WHISPER_INFORM",
	"CHAT_MSG_PARTY",
	"CHAT_MSG_PARTY_LEADER",
	"CHAT_MSG_RAID",
	"CHAT_MSG_RAID_LEADER",
	"CHAT_MSG_RAID_WARNING",
	"CHAT_MSG_YELL",
	"CHAT_MSG_GUILD",
	"CHAT_MSG_OFFICER",
	-- "CHAT_MSG_CHANNEL", -- unused right now
	-- "CHAT_MSG_CHANNEL_JOIN", -- unused right now
	-- "CHAT_MSG_CHANNEL_LEAVE", -- unused right now
	"CHAT_MSG_INSTANCE_CHAT",
	"CHAT_MSG_INSTANCE_CHAT_LEADER",
	"CHAT_MSG_SYSTEM",
};

---Chat events scanned for keyword matches.
---@type string[]
Constants.CHAT_EVENTS_KEYWORDS = {
	"CHAT_MSG_SAY",
	"CHAT_MSG_EMOTE",
	"CHAT_MSG_PARTY",
	"CHAT_MSG_PARTY_LEADER",
	"CHAT_MSG_RAID",
	"CHAT_MSG_RAID_LEADER",
	"CHAT_MSG_YELL",
	"CHAT_MSG_GUILD",
	"CHAT_MSG_OFFICER",
	-- "CHAT_MSG_CHANNEL", -- unused right now
};

---Chat events processed by the advanced formatter (text emotes, system, NPC lines).
---@type string[]
Constants.CHAT_EVENTS_ADVANCED_FORMATTING = {
	"CHAT_MSG_TEXT_EMOTE", -- Advanced Formatting
	"CHAT_MSG_SYSTEM", -- Advanced Formatting
	"CHAT_MSG_MONSTER_SAY", -- Advanced Formatting (NPCs)
	"CHAT_MSG_MONSTER_EMOTE", -- Advanced Formatting (NPCs)
	"CHAT_MSG_MONSTER_PARTY", -- Advanced Formatting (NPCs)
	"CHAT_MSG_MONSTER_YELL", -- Advanced Formatting (NPCs)
	"CHAT_MSG_MONSTER_WHISPER", -- Advanced Formatting (NPCs)
};

---Configuration constants for the chat history system.
---@class EavesdropperChatHistoryConstants
---@field EXPIRE_AFTER number
---@field IGNORE_EMOTES string[]
Constants.CHAT_HISTORY = {
	---Entries older than this many seconds are pruned on load (30 minutes).
	EXPIRE_AFTER = 60 * 30,

	---Emote substrings that mention "you" but should not trigger notifications.
	---@type string[]
	IGNORE_EMOTES = {
		"orders you to open fire",
		"asks you to wait",
		"tells you to attack",
		"motions for you to follow",
		"looks at you with crossed eyes",
		"beg everyone around you",
		"arms flapping, you strut around",
		", you mourn the loss of the dead",
		"a finger deep in one nostril, you pass the tim",
		"let everyone know that you are tired",
		"let everyone know that you are cold.",
		"think everyone around you is a son of a motherless ogre",
		"let everyone know that you are ready",
		"announce that you have low mana",
		"vow you will have your revenge",
		"beckon everyone over to you",
		"congratulate everyone around you",
		"express your curiosity to those around you",
		"hail those around you",
		"thank everyone around you",
		"sniff the air around you",
		"snub all of the lowly peons around you",
		"taunt everyone around you",
		"pity those around you",
		"encourage everyone around you",
		"glower at averyone around you",
		"hiss at everyone around you",
		"are jealous of everyone around you",
		"pout at everyone around you",
	},
};

Constants.CHAT_NEW_INDICATOR_FADE_OUT = 10;

---Default chat refresh throttle interval in milliseconds.
---@type number
Constants.CHAT_UPDATE_THROTTLE_DEFAULT = 10;

-- Credits: Listener by tmgpub.
---@type table<string, boolean>
local commonTitles = {
	private = true, pvt = true, pfc = true,
	corporal = true, cpl = true,
	sergeant = true, sgt = true,
	lieutenant = true, lt = true,
	captain = true, cpt = true,
	commander = true, major = true, admiral = true,
	ensign = true, officer = true, cadet = true, guard = true,

	dame = true, sir = true, knight = true,
	lady = true, lord = true, mister = true,
	mistress = true, master = true, miss = true,
	king = true, queen = true, prince = true, princess = true,
	archduke = true, archduchess = true,
	duke = true, duchess = true,
	marquess = true, marquis = true, marchioness = true,
	margrave = true, landgrave = true,
	count = true, countess = true,
	viscount = true, viscountess = true,
	baron = true, baroness = true,
	baronet = true, baronetess = true,

	mr = true, mrs = true,

	bishop = true, father = true, mother = true,
};

-- Add dot variants (mr. / sgt. / etc.).
for title in pairs(commonTitles) do
	commonTitles[title .. "."] = true;
end

Constants.COMMON_TITLES = commonTitles;

---@class EavesdropperColor
---@field r number
---@field g number
---@field b number

---Default RGBA background colour for the eavesdrop frame.
---@type table
Constants.DEFAULT_BACKGROUND_COLOR = {
	r = 0,
	g = 0,
	b = 0,
	a = 0.5,
};

---Filter groups enabled by default on first load.
---@type table<string, boolean>
Constants.DEFAULT_FILTERS = {
	Public = true,
	Party = true,
	Raid = true,
	["Raid Warning"] = true,
	Rolls = true,
};

---Default colour used for keyword highlights.
---@type EavesdropperColor
Constants.DEFAULT_HIGHLIGHT_COLOR = {
	r = 0,
	g = 1,
	b = 0,
};

---Sound entries registered with LibSharedMedia on startup.
---@type table<number, table<string, number>>
Constants.DEFAULT_SOUND_LIST = {
	{ key = "aggro_enter_warning_state"; fid = 567401 },
	{ key = "belltollhorde"; fid = 565853 },
	{ key = "belltolltribal"; fid = 566027 },
	{ key = "belltollnightelf"; fid = 566558 },
	{ key = "belltollalliance"; fid = 566564 },
	{ key = "fx_darkmoonfaire_bell"; fid = 1100031 },
	{ key = "fx_ship_bell_chime_01"; fid = 1129273 },
	{ key = "fx_ship_bell_chime_02"; fid = 1129274 },
	{ key = "fx_ship_bell_chime_03"; fid = 1129275 },
	{ key = "raidwarning"; fid = 567397 },
	{ key = "UI_VoiceChat_ChannelInitiated"; fid = 2113875 },
	{ key = "UI_VoiceChat_ChatMessageIncoming"; fid = 2113871 },
	{ key = "UI_VoiceChat_ChatMessageIncomingActive"; fid = 2113870 },
	{ key = "UI_VoiceChat_ChatMessageOutgoing"; fid = 2113877 },
	{ key = "UI_VoiceChat_TalkStart"; fid = 2113882 },
};

---@class EavesdropperWindowPosition
---@field point string
---@field relativePoint string
---@field x number
---@field y number

---Default anchor position for the eavesdrop frame.
---@type EavesdropperWindowPosition
Constants.DEFAULT_WINDOW_POSITION = {
	point = "CENTER",
	relativePoint = "CENTER",
	x = 0,
	y = 0,
};

---@class EavesdropperWindowSize
---@field width number
---@field height number

---Default dimensions for the eavesdrop frame.
---@type EavesdropperWindowSize
Constants.DEFAULT_WINDOW_SIZE = {
	width = 280,
	height = 380,
};

---Filter groups after which a divider is inserted in the menu.
---@type table<string, boolean>
Constants.DIVIDE_AFTER = {
	Public = true,
	Instance = true,
	Officer = true,
	Whisper = true,
};

---@class EavesdropperFrame
---@field CLICKBLOCK_TIME number
Constants.FRAME = {
	CLICKBLOCK_TIME = 0.4,
};

---Localised display labels for each filter group.
---@type table<string, string>
Constants.FILTER_LABELS = {
	Public = L.FILTER_PUBLIC,
	Party = L.FILTER_PARTY,
	Raid = L.FILTER_RAID,
	["Raid Warning"] = L.FILTER_RAID_WARNING,
	Instance = L.FILTER_INSTANCE,
	Guild = L.FILTER_GUILD,
	Officer = L.FILTER_GUILD_OFFICER,
	Whisper = L.FILTER_WHISPER,
	Rolls = L.FILTER_ROLLS,
};

---Maps each filter group name to the chat event types it covers.
---@type table<string, string[]>
Constants.FILTER_OPTIONS = {
	Public = { "SAY", "EMOTE", "TEXT_EMOTE", "YELL" },
	Party = { "PARTY", "PARTY_LEADER" },
	Raid = { "RAID", "RAID_LEADER" },
	["Raid Warning"] = { "RAID_WARNING" },
	Instance = { "INSTANCE_CHAT", "INSTANCE_CHAT_LEADER" },
	Guild = { "GUILD" },
	Officer = { "OFFICER" },
	Whisper = { "WHISPER", "WHISPER_INFORM" },
	Rolls = { "ROLL" },
};

---Display order of filter groups in the menu.
---@type string[]
Constants.FILTER_ORDER = {
	"Public",
	"Party",
	"Raid",
	"Raid Warning",
	"Instance",
	"Guild",
	"Officer",
	"Whisper",
	"Rolls",
};

---Maps event types that use a conversational verb in group windows instead of a channel prefix.
---@type table<string, string>
Constants.GROUP_EVENT_VERBS = {
	CHAT_MSG_SAY = L.MSG_VERB_SAY,
	CHAT_MSG_YELL = L.MSG_VERB_YELL,
	CHAT_MSG_WHISPER = L.MSG_VERB_WHISPER,
	CHAT_MSG_WHISPER_INFORM = L.MSG_VERB_WHISPER,
};

---Channel names that are silently ignored by the chat filter.
---@type table<string, boolean>
Constants.IGNORED_CHANNELS = {
	xtensionxtooltip2 = true,
};

---Placeholder string injected in place of item links during keyword scanning.
---@type string
Constants.KEYWORD_LINK_PLACEHOLDER = "\001\001";

---Minimum seconds between keyword notification triggers.
---@type number
Constants.KEYWORDS_NOTIFICATION_CD = 0.15;

---Local sound entries registered with LibSharedMedia on startup.
---@type table<number, table<string, string>>
Constants.LOCAL_SOUND_LIST = {
	{ key = "ListenerBeep"; fileName = "Listener\\ListenerBeep.ogg" }, -- Source: Listener by Tammya (MIT)
	{ key = "ListenerPoke"; fileName = "Listener\\ListenerPoke.ogg" }, -- Source: Listener by Tammya (MIT)
};

Constants.LOCAL_SOUND_PATH = "Interface\\AddOns\\Eavesdropper\\Sounds\\";

---Throttle for magnifier updates when the target changes.
---@type number
Constants.MAGNIFIER_CHANGE_THROTTLE = 0.15;

---Throttle for magnifier updates when the target is nil.
---@type number
Constants.MAGNIFIER_NIL_THROTTLE = 0.5;

---Short prefix strings prepended to messages by channel type.
---@type table<string, string>
Constants.MESSAGE_PREFIXES = {
	CHAT_MSG_PARTY = "[" .. L.MSG_PREFIX_PARTY .. "] ",
	CHAT_MSG_PARTY_LEADER = "[" .. L.MSG_PREFIX_PARTY .. "] ",
	CHAT_MSG_RAID = "[" .. L.MSG_PREFIX_RAID .. "] ",
	CHAT_MSG_RAID_LEADER = "[" .. L.MSG_PREFIX_RAID .. "] ",
	CHAT_MSG_INSTANCE_CHAT = "[" .. L.MSG_PREFIX_INSTANCE .. "] ",
	CHAT_MSG_INSTANCE_CHAT_LEADER = "[" .. L.MSG_PREFIX_INSTANCE .. "] ",
	CHAT_MSG_OFFICER = "[" .. L.MSG_PREFIX_OFFICER .. "] ",
	CHAT_MSG_GUILD = "[" .. L.MSG_PREFIX_GUILD .. "] ",
	CHAT_MSG_CHANNEL = "[" .. L.MSG_PREFIX_CHANNEL .. "] ",
	CHAT_MSG_RAID_WARNING = "[" .. L.MSG_PREFIX_RAID_WARNING .. "] ",
	CHAT_MSG_WHISPER = "[" .. L.MSG_PREFIX_WHISPER_FROM .. "] ",
	CHAT_MSG_WHISPER_INFORM = "[" .. L.MSG_PREFIX_WHISPER_TO .. "] ",
};

---MSP integration constants.
---@class EavesdropperMSPConstants
---@field CACHE_RESET_TIME number
Constants.MSP = {
	---Seconds before a cached MSP result is considered stale.
	CACHE_RESET_TIME = 5,
};

---MSP fields that are relevant to name/colour resolution.
---@type table<string, boolean>
Constants.MSP_RELEVANT_FIELDS = {
	RC = true,
	RA = true,
	NA = true,
};

---Player cache timing constants.
---@class EavesdropperPlayerCacheConstants
---@field DEFAULT_TTL number
---@field TIME number
Constants.PLAYER_CACHE = {
	DEFAULT_TTL = 3600,
	TIME = 1e-6,
};

---Layout constants for the settings panel widgets.
---@class EavesdropperSettingsConstants
---@field WIDGET_HEIGHT number
---@field PADDING_HEIGHT number
---@field PADDING_MULTILINE_EDITBOX number
---@field PADDING_HEIGHT_TITLE number
Constants.SETTINGS = {
	WIDGET_HEIGHT = 25,
	PADDING_HEIGHT = 5,
	PADDING_MULTILINE_EDITBOX = 10,
	PADDING_HEIGHT_TITLE = 20,
};

---TRP3 profile field paths used for name extraction.
---@class EavesdropperTRPConstants
---@field FIELDS table<string, string>
Constants.TRP = {
	FIELDS = {
		FIRST_NAME = "characteristics/FN",
		LAST_NAME  = "characteristics/LN",
	},
};

ED.Constants = Constants;
