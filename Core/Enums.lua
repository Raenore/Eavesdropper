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
	NONE = 1;
	OUTLINE = 2;
	THICKOUTLINE = 3;
};

--@alias ElvUISkinType
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
	BUTTON = "button";
	CHECKBOX = "checkbox";
	DROPDOWN = "dropdown";
	EDITBOX = "editbox";
	FRAME = "frame";
	ICON = "icon";
	INSET = "inset";
	SCROLLBAR = "scrollbar";
	SLIDER = "slider";
	TOPTABBUTTON = "toptabbutton";
};

--@enum EavesdropperEntryChatRemap
Enums.ENTRY_CHAT_REMAP = {
	ROLL              = "SYSTEM",
	OFFLINE           = "SYSTEM",
	ONLINE            = "SYSTEM",
	GUILD_MOTD        = "GUILD",
	GUILD_ITEM_LOOTED = "GUILD_ACHIEVEMENT",
};

---@class EavesdropperFrameEnums
Enums.FRAME = {};

---@class EavesdropperMouseHoverState
---@field OFF number
---@field ON number
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
	LOGIN    = 0,
	TARGET   = 1,
	MOUSEOVER = 2,
	SETTINGS = 3,
};

---@enum EavesdropperNotificationsType
Enums.NOTIFICATIONS_TYPE = {
	EMOTES = 1,
	KEYWORDS = 2,
	TARGET = 3,
};

---@type table<EavesdropperNotificationsType, string>
Enums.NOTIFICATIONS_TYPE_SOUND_KEYS = {
	[Enums.NOTIFICATIONS_TYPE.EMOTES]   = "NotificationEmotesSoundFile",
	[Enums.NOTIFICATIONS_TYPE.KEYWORDS] = "NotificationKeywordsSoundFile",
	[Enums.NOTIFICATIONS_TYPE.TARGET]   = "NotificationTargetSoundFile",
};

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
};

ED.Enums = Enums;
