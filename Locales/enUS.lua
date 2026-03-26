-- Copyright The Eavesdropper Authors
-- SPDX-License-Identifier: Apache-2.0

local title = C_AddOns.GetAddOnMetadata("Eavesdropper", "Title");
local L;

---@class ED.Locale.enUS
L = {
	WELCOMEMSG_VERSION = "Listening with profile |cnGREEN_FONT_COLOR:%s|r (|cnGOLD_FONT_COLOR:%s|r)!",
	WELCOMEMSG_SETTINGS = "Settings available through |cnGREEN_FONT_COLOR:/ed|r & |cnGREEN_FONT_COLOR:/ed help|r",

	SLASH_COMMAND_HEADER = "List of commands:",
	SLASH_COMMAND_ED = "Show settings, Eavesdropper unhides during",
	SLASH_COMMAND_ED_SHOW = "Show Eavesdropper",
	SLASH_COMMAND_ED_HIDE = "Hide Eavesdropper",
	SLASH_COMMAND_ED_TOGGLE = "Toggle Eavesdropper",

	ADDON_TOOLTIP_HELP = "|cnGREEN_FONT_COLOR:Left-Click: Open settings|nRight-Click: Open profiles|nShift-Click: Toggle Eavesdropper|r",
	POPUP_LINK = "|n|nPress |cnGREEN_FONT_COLOR:CTRL-C|r to copy the highlighted, then paste it in your web browser with |cnGREEN_FONT_COLOR:CTRL-V|r.",
	COPY_SYSTEM_MESSAGE = "Copied to clipboard.",

	FILTER = "Filter",
	FILTER_HELP = "Choose which types of messages are visible in Eavesdropper.|n|n- Toggling a filter only changes what is currently shown.|n- No data is actually deleted; hidden messages will reappear if the filter is turned back on.|n|n|cnWARNING_FONT_COLOR:Note: Filters are applied instantly.|r",

	SCROLLMARKER_TEXT = "Scroll to Bottom",

	FILTER_PUBLIC = "Public",
	FILTER_PARTY = "Party",
	FILTER_RAID = "Raid",
	FILTER_RAID_WARNING = "Raid Warning",
	FILTER_INSTANCE = "Instance",
	FILTER_GUILD = "Guild",
	FILTER_GUILD_OFFICER = "Officer",
	FILTER_WHISPER = "Whisper",
	FILTER_ROLLS = "Rolls",

	WINDOW_OPTIONS = "Window Options",
	ENABLE_MOUSE = "Enable Mouse",
	ENABLE_MOUSE_HELP = "Toggles whether you can interact with the Eavesdropper window using your mouse.|n|n- Enabled: Allows you to click on item links, and URLs within the history.|n- Disabled: Clicks pass through the window to the game world behind it, preventing accidental clicks during gameplay.",
	LOCK_SCROLL = "Lock Scrolling",
	LOCK_SCROLL_HELP = "Disables the ability to scroll through the message history.|n|n- Use this to ensure Eavesdropper always remains at the bottom of the list to show the latest messages.",
	LOCK_WINDOW = "Lock Moving",
	LOCK_WINDOW_HELP = "Prevents Eavesdropper from being moved or resized.|n|n- Check this once you have positioned the window to avoid accidental dragging during gameplay.",
	LOCK_TITLEBAR = "Lock Title Bar",
	LOCK_TITLEBAR_HELP = "Toggles the visibility of the window's title bar.|n|n- Enabled: The title bar remains visible at all times.|n- Disabled: The title bar is hidden and only appears when you hover over the window.|n|nNote: You can enable 'Title Bar Target Name' in the settings to replace the 'Eavesdropper' text with your current target's name.",

	DEDICATED_OPTIONS = "Dedicated Options",

	-- General Tab
	GENERAL_TITLE = "General",
	TARGETING = "Targeting",
	TARGETING_PRIORITY_MOUSEOVER = "Mouseover",
	TARGETING_PRIORITY_TARGET = "Target",
	TARGETING_PRIORITY_FOCUS = "Focus",

	TARGET_PRIORITY = "Priority",
	TARGET_PRIORITY_HELP = "Determines which unit's history Eavesdropper displays when you have both a target and a mouseover unit.|n|n- Prioritize: Choose which one takes precedence.|n- Only: Choose to listen exclusively to one unit type (this disables 'Focus' logic).",
	TARGET_PRIORITY_PRIORITIZE_MOUSEOVER = "Prioritize Mouseover",
	TARGET_PRIORITY_PRIORITIZE_TARGET = "Prioritize Target",
	TARGET_PRIORITY_MOUSEOVER_ONLY = "Mouseover Only",
	TARGET_PRIORITY_TARGET_ONLY = "Target Only",
	TARGET_PRIORITY_FOCUS_ONLY = "Focus Only",

	FOCUS = "Focus",
	FOCUS_HELP = "Determines how the Eavesdropper's history window handles your focus target.|n|n- Override: Always gives precedence to your focus target over all other units.|n- Fallback: Displays the focus target only when no current target or mouseover unit exists.|n- Ignore: Completely excludes focus targets from being displayed.|n|n|cnWARNING_FONT_COLOR:Note: This setting is disabled if your Priority is set to an 'Only' option.|r",
	FOCUS_OVERRIDE = "Override",
	FOCUS_FALLBACK = "Fallback",
	FOCUS_IGNORE = IGNORE,

	INCLUDE_COMPANIONS = "Include Companions",
	INCLUDE_COMPANIONS_HELP = "Show the owner's history when targeting or hovering over their pets and companions.|n|n- When enabled, Eavesdropper treats pets as a bridge to their owner's data.|n- When disabled, Eavesdropper will ignore pets and companions entirely.",

	MESSAGES = "Messages",
	MESSAGES_HELP = "These options only apply to the Eavesdropper history.",

	HISTORY_SIZE = "History Size",
	HISTORY_SIZE_HELP = "Set the maximum number of history messages Eavesdropper displays for each unit.|n|n|cnWARNING_FONT_COLOR:Note: High values may cause temporary frame drops when refreshing the history window.|r",

	NAME_DISPLAY_MODE = "Name Display",
	NAME_DISPLAY_MODE_HELP = "Choose how character names are formatted within Eavesdropper.|n|n|cnWARNING_FONT_COLOR:Note: This option is disabled and defaults to 'Original (OOC) Name' when no suitable RP addon (TRP, MRP, XRP) is loaded.|r",
	NAME_DISPLAY_MODE_FULL_NAME = "Full Name",
	NAME_DISPLAY_MODE_FIRST_NAME = "First Name",
	NAME_DISPLAY_MODE_ORIGINAL_NAME = "Original (OOC) Name",

	USE_RP_NAME_COLOR = "Name Colors",
	USE_RP_NAME_COLOR_HELP = "Color names based on their custom RP settings (e.g., from TRP3).|n|n- If no RP color is detected, Eavesdropper falls back to the default Blizzard class color.",

	USE_RP_NAME_IN_ROLLS = "Format Roll Names",
	USE_RP_NAME_IN_ROLLS_HELP = "Toggles whether random roll results (/roll) use a character's RP name or their original in-game name.",

	USE_RP_NAME_FOR_TARGETS = "Format Emote Targets",
	USE_RP_NAME_FOR_TARGETS_HELP = "Toggles whether target names within Blizzard emotes (e.g., /wave, /point) use a character's RP name or their original in-game name.|n|n|cnWARNING_FONT_COLOR:Note: Due to how Blizzard handles emote strings, name substitution may not work consistently in all situations.|r",

	NPC_DIALOGUE_AND_QUEST_TEXT = "NPC Dialogue & Quest Text",
	NPC_DIALOGUE_AND_QUEST_TEXT_HELP = "Choose how your character's name is displayed.",

	NPC_AND_QUEST_NAME_DISPLAY = "NPC & Quest Name Display",
	NPC_AND_QUEST_NAME_DISPLAY_HELP = "Choose how your character's name is formatted within NPC dialogue and quest text.|n|n|cnWARNING_FONT_COLOR:Note: This option defaults to 'Original (OOC) Name' if no supported RP addon (TRP, MRP, or XRP) is detected.|r",

	USE_RP_NAME_FOR_QUEST_TEXT = "Format Quest Text",
	USE_RP_NAME_FOR_QUEST_TEXT_HELP = "Toggles whether your name appearing in quest text uses your chosen 'NPC & Quest Name Display' or your original in-game name.|n|n|cnWARNING_FONT_COLOR:Note: This requires a supported interaction addon (e.g., Dialogue UI) to be active.|r",

	USE_RP_NAME_FOR_NPC_DIALOGUE = "Format NPC Dialogue",
	USE_RP_NAME_FOR_NPC_DIALOGUE_HELP = "Toggles whether your name appearing in NPC Dialogue (Say, Emote, etc.) uses your chosen 'NPC & Quest Name Display' or your original in-game name.|n|n|cnWARNING_FONT_COLOR:Note: Chat bubbles will still show your original name, as they cannot be modified by addons.|r",

	TIMESTAMP_BRACKETS = "Timestamp Brackets",
	TIMESTAMP_BRACKETS_HELP = "Toggles the visibility of brackets around message timestamps (e.g., [5m] vs 5m).",

	ADVANCED_FORMATTING = "Advanced Formatting",

	APPLY_ON_MAIN_CHAT = "Apply to Main Chat",
	APPLY_ON_MAIN_CHAT_HELP = "Toggles whether Advanced Formatting is applied to the main Blizzard chat window in addition to the Eavesdropper history window.|n|n|cnWARNING_FONT_COLOR:Note: Formatting is not retroactive. If the required RP data is unavailable at the time a message is received, standard in-game names will be displayed.|r",

	DISPLAY = "Display",
	THEMES_BACKGROUND_COLOR = "Background Color",
	THEMES_BACKGROUND_COLOR_HELP = "Adjust the color and transparency of Eavesdropper.|n|n- Use the slider in the color picker to set the background opacity.",
	THEMES_TITLEBAR_COLOR = "Title Bar Color",
	THEMES_TITLEBAR_COLOR_HELP = "Set the background color and opacity for the title bar.|n|n- The title bar is typically visible when hovering over Eavesdropper.",
	THEMES_SETTINGS_ELVUI = "ElvUI Theme",
	THEMES_SETTINGS_ELVUI_HELP = "Force Eavesdropper's settings window to use ElvUI skinning.|n|n|cnWARNING_FONT_COLOR:Note: Toggling this will automatically trigger a UI Reload to apply the new skin.|r",

	HIDE_CLOSE_BUTTON = "Hide Close Button",
	HIDE_CLOSE_BUTTON_HELP = "Toggles the visibility of the close button on the Eavesdropper frame.|n|n- If hidden, you can still control the window using |cnGREEN_FONT_COLOR:/ed show|r or |cnGREEN_FONT_COLOR:/ed hide|r.",
	HIDE_IN_COMBAT = "Hide In Combat",
	HIDE_IN_COMBAT_HELP = "Automatically hide Eavesdropper upon entering combat.|n|n|cnWARNING_FONT_COLOR:Note: Certain combat encounters or instances may restrict message capturing regardless of this setting.|r",
	HIDE_WHEN_EMPTY = "Hide When Empty",
	HIDE_WHEN_EMPTY_HELP = "Automatically hides Eavesdropper when there are no messages to display.|n|n- The window will reappear as soon as a new message is recorded.|n|n|cnWARNING_FONT_COLOR:Note: This will take effect as soon as the Settings window is closed.|r",

	TITLE_BAR_TARGET_NAME = "Title Bar Target Name",
	TITLE_BAR_TARGET_NAME_HELP = "Replaces the 'Eavesdropper' label in the title bar with the name of your current target. This provides a quick visual confirmation of which character's history is currently being tracked.",

	WELCOME_MSG = "Startup message",
	WELCOME_MSG_HELP = "Toggles the display of the welcome message.|n|n* Global setting - persists across all profiles.",

	FONT = "Font",

	FONT_FACE = "Font Face",
	FONT_FACE_HELP = "Choose the typeface used for all text within Eavesdropper.|n|nNote: Fonts from other addons that use LibSharedMedia will also appear in this list.",

	FONT_SIZE = "Font Size",
	FONT_SIZE_HELP = "Adjust the size of the messages displayed in the history window.|n|n- You can also hold |cnGREEN_FONT_COLOR:Ctrl + Mouse Wheel Up/Down|r while hovering over Eavesdropper to change the size directly.",

	FONT_OUTLINE = "Font Outline",
	FONT_OUTLINE_HELP = "Apply a border to the text to improve readability against busy backgrounds.",
	FONT_OUTLINE_NONE = "None",
	FONT_OUTLINE_THIN = "Thin",
	FONT_OUTLINE_THICK = "Thick",

	FONT_SHADOW = "Font Shadow",
	FONT_SHADOW_HELP = "Toggles a soft drop shadow behind the text for added depth and contrast.",

	MINIMAP = "Minimap",

	DEDICATED_WINDOWS = "Dedicated Windows",
	DEDICATED_WINDOWS_HELP = "Allows the creation of separate, independent windows to track specific units.|n|n* Global setting - persists across all profiles.|n|n|cnWARNING_FONT_COLOR:Note: Disabling this setting will close all independent windows.|r",

	DEDICATED_WINDOWS_UNIT_POPUPS = "Quick-Access Menu",
	DEDICATED_WINDOWS_UNIT_POPUPS_HELP = "Adds 'Eavesdropper' options to the standard right-click menus on unit frames (Player, Target, Party, etc.) and chat names.|n|n- Use this to quickly open a dedicated window for a specific character.|n|n* Global setting - persists across all profiles.",

	DEDICATED_WINDOWS_NEW_INDICATOR = "New Message Indicator",
	DEDICATED_WINDOWS_NEW_INDICATOR_HELP = "Displays a visual alert on any dedicated window that receives a new message.|n|n- The indicator clears automatically after 10 seconds or immediately upon hovering over the window.",

	MINIMAP_BUTTON = "Minimap Button",
	MINIMAP_BUTTON_HELP = "Toggles the display of the minimap button.|n|n* Global setting - persists across all profiles.",

	ADDON_COMPARTMENT_BUTTON = "Addon compartment",
	ADDON_COMPARTMENT_BUTTON_HELP = "Toggles the display of the addon compartment button.|n|n* Global setting - persists across all profiles.",

	-- Notifications Tab
	NOTIFICATIONS_TITLE = "Notifications",

	EMOTES = "Emotes",
	EMOTES_HELP = "When someone emotes at your character (e.g., /point, /laugh).",

	TARGET = "Target",
	TARGET_HELP = "Messages received from your current target.",

	DEDICATED = "Dedicated",
	DEDICATED_HELP = "Messages received in Dedicated Windows.",

	NOTIFICATIONS_PLAY_SOUND = "Play Sound",
	NOTIFICATIONS_PLAY_SOUND_HELP = "Toggles whether Eavesdropper plays an audible alert for this notification type.",

	NOTIFICATIONS_SOUND_FILE = "Sound File",
	NOTIFICATIONS_SOUND_FILE_HELP = "Choose the specific sound file Eavesdropper will play for this alert.|n|nNote: Sounds from other addons that use LibSharedMedia will also appear in this list.",

	NOTIFICATION_FLASH_TASKBAR = "Flash Taskbar",
	NOTIFICATION_FLASH_TASKBAR_HELP = "Toggles whether the game's taskbar icon flashes when this notification type is triggered while the game is minimized.",

	-- Keywords Tab
	KEYWORDS_TITLE = "Keywords",

	KEYWORDS_HELP = "Highlight specific words or phrases that appear in chat.",

	KEYWORDS_ENABLE = "Enable",
	KEYWORDS_ENABLE_HELP = "Toggles the keyword highlighting system for Eavesdropper.|n|n|cnWARNING_FONT_COLOR:Note: Keyword lists are saved per profile, not per character.|r",

	KEYWORDS_LIST = "Keywords List",
	KEYWORDS_LIST_HELP = "Enter words or phrases to be highlighted in the chat history.|n|nSpecial Tags:|n|cnGREEN_FONT_COLOR:<firstname>|r - Your RP first name|n|cnGREEN_FONT_COLOR:<lastname>|r - Your RP last name|n|cnGREEN_FONT_COLOR:<oocname>|r - Your in-game name|n|cnGREEN_FONT_COLOR:<class>|r - Your RP class (falls back to game class)|n|cnGREEN_FONT_COLOR:<race>|r - Your RP race (falls back to game race)|n|nFormatting:|n- Separate multiple entries with commas.|n- Entries are case-insensitive (e.g., 'Hero' matches 'hero').|n- Spaces within a phrase are preserved.|n|n|cnWARNING_FONT_COLOR:Note: Spaces immediately before or after a comma are ignored.|r",

	KEYWORDS_HIGHLIGHT_COLOR = "Highlight Color",
	KEYWORDS_HIGHLIGHT_COLOR_HELP = "Set the color used for highlighted keywords in chat.",

	KEYWORDS_ENABLE_PARTIAL_MATCHING = "Partial Matching",
	KEYWORDS_ENABLE_PARTIAL_MATCHING_HELP = "Toggles whether keywords can be found inside larger words.|n|nExamples:|n- Enabled: 'Twin' will highlight inside 'Twins'.|n- Disabled: Only the exact word 'Twin' will highlight.|n|n|cnWARNING_FONT_COLOR:Note: This may cause 'false positives' (e.g., 'art' highlighting inside 'pARTy').|r",

	KEYWORDS_NOTIFICATIONS_HELP = "Messages received with a detected keyword.",

	-- Profiles Tab
	PROFILES_TITLE = "Profiles",

	PROFILES_CURRENTPROFILE = "Current Profile",
	PROFILES_CURRENTPROFILE_HELP = "The profile to use for this character.",

	PROFILES_NEWPROFILE = "New Profile",
	PROFILES_NEWPROFILE_HELP = "Create a new profile. Enter a name and press Enter to save it.",

	PROFILES_COPYFROM = "Copy From",
	PROFILES_COPYFROM_HELP = "Copy all settings from an existing profile into your currently active profile.",

	PROFILES_RESETBUTTON = "Reset Profile",
	PROFILES_RESETBUTTON_HELP = "Reset all settings in the current profile back to their original defaults.",

	PROFILES_DELETEPROFILE = "Delete Profile",
	PROFILES_DELETEPROFILE_HELP = "Permanently remove the selected profile from the Eavesdropper database.",

	PROFILES_CONFIRM_COPYFROM = "Are you sure you want to copy all settings from profile '%s'?",
	PROFILES_CONFIRM_RESET = "Are you sure you want to reset the current profile to its defaults?",
	PROFILES_CONFIRM_DELETE = "Are you sure you want to delete profile '%s'?",

	ADDONINFO_BUILD = "|cnNORMAL_FONT_COLOR:Build:|r %s",
	ADDONINFO_BUILD_OUTDATED = title .. " is not optimized for this game build.|n|n|cnWARNING_FONT_COLOR:This may cause unexpected behavior.|r",
	ADDONINFO_BUILD_CURRENT = title .. " is optimized for your current game build.|n|n|cnGREEN_FONT_COLOR:All features should work as expected.|r",
	ADDONINFO_BLUESKY_SHILL_HELP = "Follow me on Bluesky!",

	UNIT_POPUPS_EAVESDROPPER_OPTIONS_HEADER = "Eavesdropper Options",
	UNIT_POPUPS_EAVESDROP_ON = "Eavesdrop On",

	-- Message Prefixes (keep them shorthand)
	MSG_PREFIX_PARTY = "P",
	MSG_PREFIX_RAID = "R",
	MSG_PREFIX_INSTANCE = "I",
	MSG_PREFIX_OFFICER = "O",
	MSG_PREFIX_GUILD = "G",
	MSG_PREFIX_CHANNEL = "C",
	MSG_PREFIX_RAID_WARNING = "RW",
	MSG_PREFIX_WHISPER_FROM = "W From",
	MSG_PREFIX_WHISPER_TO = "W To",
};

---@class ED.L : ED.Locale.enUS, ED.Localization
ED.Localization = ED.LocalizationClass:New(L);
ED.Localization:RegisterNewLocale("enUS", "English", L);
