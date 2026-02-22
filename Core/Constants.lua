-- Copyright The Eavesdropper Authors
-- SPDX-License-Identifier: Apache-2.0

local L = ED.Localization;

---@class EavesdropperConstants
local Constants = {};

---@type table<string, boolean>
Constants.DIVIDE_AFTER = {
	Public = true,
	Instance = true,
	Officer = true,
	Whisper = true,
};

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

---@type table<string, number>
Constants.CHAT_BOX = {
	MIN_FONT_SIZE = 6,
	MAX_FONT_SIZE = 24,
};

---@class EavesdropperChatHistory
---@field EXPIRE_AFTER number
---@field IGNORE_EMOTES string[]
Constants.CHAT_HISTORY = {};

Constants.CHAT_HISTORY.EXPIRE_AFTER = 60 * 30;

---@type string[]
Constants.CHAT_HISTORY.IGNORE_EMOTES = {
	"orders you to open fire.";
	"asks you to wait.";
	"tells you to attack";
	"motions for you to follow.";
	"looks at you with crossed eyes.";
};

-- (Credits @ Listener by tmgpub)
---@type table<string, boolean>
local COMMON_TITLES = {
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

-- Add dot variants (mr. / sgt. etc)
for title in pairs(COMMON_TITLES) do
	COMMON_TITLES[title .. "."] = true;
end

Constants.COMMON_TITLES = COMMON_TITLES;

---@type table
Constants.DEFAULT_BACKGROUND_COLOR = {
	r = 0;
	g = 0;
	b = 0;
	a = 0.5;
};

---@type table<string, boolean>
Constants.DEFAULT_FILTERS = {
	Public = true,
	Party = true,
	Raid = true,
	["Raid Warning"] = true,
	Rolls = true,
};

---@class EavesdropperColor
---@field r number
---@field g number
---@field b number

---@type EavesdropperColor
Constants.DEFAULT_HIGHLIGHT_COLOR = {
	r = 0;
	g = 1;
	b = 0;
};

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
	{ key = "UI_VoiceChat_ChatMessageIncoming"; fid = 2113871 },
	{ key = "UI_VoiceChat_ChatMessageIncomingActive"; fid = 2113870 },
	{ key = "UI_VoiceChat_ChatMessageOutgoing"; fid = 2113877 },
};

---@class EavesdropperWindowPosition
---@field point string
---@field relativePoint string
---@field x number
---@field y number

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

---@type EavesdropperWindowSize
Constants.DEFAULT_WINDOW_SIZE = {
	width = 280;
	height = 380;
};

Constants.CHAT_UPDATE_THROTTLE_DEFAULT = 10;

Constants.FRAME = {
	CLICKBLOCK_TIME = 0.4;
};

---@type table<string, string>
Constants.FILTER_LABELS = {
	Public           = L.FILTER_PUBLIC,
	Party            = L.FILTER_PARTY,
	Raid             = L.FILTER_RAID,
	["Raid Warning"] = L.FILTER_RAID_WARNING,
	Instance         = L.FILTER_INSTANCE,
	Guild            = L.FILTER_GUILD,
	Officer          = L.FILTER_GUILD_OFFICER,
	Whisper          = L.FILTER_WHISPER,
	Rolls            = L.FILTER_ROLLS,
};

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

---@type table<string, boolean>
Constants.IGNORED_CHANNELS = {
	xtensionxtooltip2 = true,
};

---@type string
Constants.KEYWORD_LINK_PLACEHOLDER = "\001\001";

---@type number
Constants.KEYWORDS_NOTIFICATION_CD = 0.15;

---@type number
Constants.MAGNIFIER_NIL_THROTTLE = 0.5;

---@type table<string, string>
Constants.MESSAGE_PREFIXES = {
	CHAT_MSG_PARTY           = "[P] ",
	CHAT_MSG_PARTY_LEADER    = "[P] ",
	CHAT_MSG_RAID            = "[R] ",
	CHAT_MSG_RAID_LEADER     = "[R] ",
	CHAT_MSG_INSTANCE_CHAT   = "[I] ",
	CHAT_MSG_INSTANCE_CHAT_LEADER = "[I] ",
	CHAT_MSG_OFFICER         = "[O] ",
	CHAT_MSG_GUILD           = "[G] ",
	CHAT_MSG_CHANNEL         = "[C] ",
	CHAT_MSG_RAID_WARNING    = "[RW] ",
	CHAT_MSG_WHISPER         = "[W From] ",
	CHAT_MSG_WHISPER_INFORM  = "[W To] ",
};

---@class EavesdropperMSP
---@field CACHE_RESET_TIME number
Constants.MSP = {};
Constants.MSP.CACHE_RESET_TIME = 5;

---@class EavesdropperPlayerCache
---@field DEFAULT_TTL number
---@field TIME number
Constants.PLAYER_CACHE = {
	DEFAULT_TTL = 3600;
	TIME = 1e-6;
};

---@class EavesdropperSettings
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

---@class EavesdropperTRP
---@field FIELDS table<string, string>
Constants.TRP = {};
Constants.TRP.FIELDS = {
	FIRST_NAME = "characteristics/FN",
	LAST_NAME  = "characteristics/LN",
};

ED.Constants = Constants;