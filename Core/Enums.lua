-- Copyright The Eavesdropper Authors
-- SPDX-License-Identifier: Apache-2.0

---@class EavesdropperEnums
local Enums = {};

---@class EavesdropperChatBoxEnums
Enums.CHAT_BOX = {};

---@class EavesdropperFontOutline
---@field NONE number
---@field OUTLINE number
---@field THICKOUTLINE number
Enums.CHAT_BOX.FONT_OUTLINE = {
	NONE = 1,
	OUTLINE = 2,
	THICKOUTLINE = 3,
};

---@alias ElvUISkinType
---| "button"
---| "checkbox"
---| "dropdown"
---| "editbox"
---| "frame"
---| "icon"
---| "inset"
---| "scrollbar"
---| "slider"
---| "toptabbutton"

---@class EavesdropperElvUISkin
---@field BUTTON ElvUISkinType
---@field CHECKBOX ElvUISkinType
---@field DROPDOWN ElvUISkinType
---@field EDITBOX ElvUISkinType
---@field FRAME ElvUISkinType
---@field ICON ElvUISkinType
---@field INSET ElvUISkinType
---@field SCROLLBAR ElvUISkinType
---@field SLIDER ElvUISkinType
---@field TOPTABBUTTON ElvUISkinType
Enums.ELVUI_SKIN_TYPE = {
	BUTTON = "button",
	CHECKBOX = "checkbox",
	DROPDOWN = "dropdown",
	EDITBOX = "editbox",
	FRAME = "frame",
	ICON = "icon",
	INSET = "inset",
	SCROLLBAR = "scrollbar",
	SLIDER = "slider",
	TOPTABBUTTON = "toptabbutton",
};

---Maps internal event shorthand to the ChatTypeInfo key used for colour lookup.
---@enum EavesdropperEntryChatRemap
Enums.ENTRY_CHAT_REMAP = {
	ROLL              = "SYSTEM",
	OFFLINE           = "SYSTEM",
	ONLINE            = "SYSTEM",
	GUILD_MOTD        = "GUILD",
	GUILD_ITEM_LOOTED = "GUILD_ACHIEVEMENT",
};

---@enum EavesdropperFocusTarget
Enums.FOCUS_TARGET = {
	OVERRIDE = 1,
	FALLBACK = 2,
	IGNORE   = 3,
};

---Frame-level enumerations.
---@class EavesdropperFrameEnums
Enums.FRAME = {};

---@class EavesdropperMouseHoverState
---@field OFF boolean
---@field ON boolean
Enums.FRAME.MOUSE_HOVER_STATE = {
	OFF = false;
	ON  = true;
};

---@class EavesdropperScrollDirection
---@field UP number
---@field DOWN number
Enums.FRAME.SCROLL_DIRECTION = {
	UP   = 1;
	DOWN = -1;
};

---@enum EavesdropperMagnifierReason
Enums.MAGNIFIER_REASON = {
	LOGIN     = 0,
	TARGET    = 1,
	MOUSEOVER = 2,
	SETTINGS  = 3,
	FOCUS     = 4,
};

---@enum EavesdropperNotificationsType
Enums.NOTIFICATIONS_TYPE = {
	EMOTES = 1,
	KEYWORDS = 2,
	TARGET = 3,
	DEDICATED = 4,
	GROUP = 5,
};

---Maps each notification type to its saved-variable sound file key.
---@type table<EavesdropperNotificationsType, string>
Enums.NOTIFICATIONS_TYPE_SOUND_KEYS = {
	[Enums.NOTIFICATIONS_TYPE.DEDICATED]   = "NotificationDedicatedSoundFile",
	[Enums.NOTIFICATIONS_TYPE.EMOTES]   = "NotificationEmotesSoundFile",
	[Enums.NOTIFICATIONS_TYPE.GROUP]   = "NotificationGroupSoundFile",
	[Enums.NOTIFICATIONS_TYPE.KEYWORDS] = "NotificationKeywordsSoundFile",
	[Enums.NOTIFICATIONS_TYPE.TARGET]   = "NotificationTargetSoundFile",
};

---Maps raid target name aliases to their icon index (1–8).
---@type table<string, number>
Enums.RAID_TARGETS = {
	-- ID 1: Star
	star     = 1, rt1 = 1, yellow = 1,
	-- ID 2: Circle
	circle   = 2, rt2 = 2, orange = 2,
	-- ID 3: Diamond
	diamond  = 3, rt3 = 3, purple = 3,
	-- ID 4: Triangle
	triangle = 4, rt4 = 4, green  = 4,
	-- ID 5: Moon
	moon     = 5, rt5 = 5, silver = 5,
	-- ID 6: Square
	square   = 6, rt6 = 6, blue   = 6,
	-- ID 7: Cross / X
	x        = 7, rt7 = 7, red    = 7, cross = 7,
	-- ID 8: Skull
	skull    = 8, rt8 = 8, white  = 8,
};

---@enum EavesdropperTargetPriority
Enums.TARGET_PRIORITY = {
	PRIORITIZE_MOUSEOVER = 1,
	PRIORITIZE_TARGET    = 2,
	MOUSEOVER_ONLY       = 3,
	TARGET_ONLY          = 4,
	FOCUS_ONLY           = 5,
};

---Maps target priority modes to their localisation key pairs for display.
---@class EavesdropperPriorityStringEntry
---@field priority string
---@field secondary string?
Enums.TARGET_PRIORITY_STRING_MAP = {
	[Enums.TARGET_PRIORITY.PRIORITIZE_MOUSEOVER] = {
		priority = "TARGETING_PRIORITY_MOUSEOVER",
		secondary = "TARGETING_PRIORITY_TARGET",
	},
	[Enums.TARGET_PRIORITY.PRIORITIZE_TARGET] = {
		priority = "TARGETING_PRIORITY_TARGET",
		secondary = "TARGETING_PRIORITY_MOUSEOVER",
	},
};

---Maps target priority modes to their unit token pairs for API calls.
---@class EavesdropperPriorityUnitEntry
---@field priority string
---@field secondary string?
Enums.TARGET_PRIORITY_UNIT_MAP = {
	[Enums.TARGET_PRIORITY.TARGET_ONLY] = {
		priority = "target",
	},
	[Enums.TARGET_PRIORITY.MOUSEOVER_ONLY] = {
		priority = "mouseover",
	},
	[Enums.TARGET_PRIORITY.FOCUS_ONLY] = {
		priority = "focus",
	},
	[Enums.TARGET_PRIORITY.PRIORITIZE_MOUSEOVER] = {
		priority = "mouseover",
		secondary = "target",
	},
	[Enums.TARGET_PRIORITY.PRIORITIZE_TARGET] = {
		priority = "target",
		secondary = "mouseover",
	},
};

ED.Enums = Enums;
