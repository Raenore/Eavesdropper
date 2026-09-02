-- Copyright The Eavesdropper Authors
-- SPDX-License-Identifier: GPL-3.0-or-later

local title = C_AddOns.GetAddOnMetadata("Eavesdropper", "Title");
local L;

---@class ED.Locale.enUS
L = {
	WELCOMEMSG_VERSION = "Listening with profile |cnGREEN_FONT_COLOR:%s|r (|cnGOLD_FONT_COLOR:%s|r)!",
	WELCOMEMSG_SETTINGS = "|cnGREEN_FONT_COLOR:/ed|r %s & |cnGREEN_FONT_COLOR:/ed help|r %s",

	SLASH_COMMAND_HEADER = "List of commands (clickable & writable):",
	SLASH_COMMAND_ED = "Toggle settings, Eavesdropper unhides during",
	SLASH_COMMAND_ED_SHOW = "Show Eavesdropper",
	SLASH_COMMAND_ED_HIDE = "Hide Eavesdropper",
	SLASH_COMMAND_ED_TOGGLE = "Toggle Eavesdropper",
	SLASH_COMMAND_ED_SETTINGS = "Toggle Settings",
	SLASH_COMMAND_ED_HELP = "Available Commands",
	SLASH_COMMAND_ED_MENTIONS = "Toggle Mentions",

	BINDING_NAME_ED_TOGGLE = "Toggle Eavesdropper",
	BINDING_NAME_ED_SETTINGS = "Toggle Settings",
	BINDING_NAME_ED_MENTIONS = "Toggle Mentions",
	BINDING_NAME_ED_EAVESDROP_ON = "Eavesdrop On (Dedicated)",

	ADDON_TOOLTIP_HELP = "|cnGREEN_FONT_COLOR:Left-Click: Open settings|nRight-Click: Open profiles|nShift-Left-Click: Toggle Eavesdropper|nShift-Right-Click: Toggle Mentions|r",
	POPUP_LINK = "|n|nPress |cnGREEN_FONT_COLOR:CTRL-C|r to copy the highlighted, then paste it in your web browser with |cnGREEN_FONT_COLOR:CTRL-V|r.",
	POPUP_COPY_NAME = "|n|nPress |cnGREEN_FONT_COLOR:CTRL-C|r to copy the highlighted character name.",
	COPY_SYSTEM_MESSAGE = "Copied to clipboard.",
	GLOBAL_SETTING_TOOLTIP = "|cnLIGHTBLUE_FONT_COLOR:|n|n* Global setting - persists across all profiles.|r",

	FILTER = "Filter",
	FILTER_HELP = "Choose which types of messages are visible in Eavesdropper.|n|n- Toggling a filter only changes what is currently shown.|n- No data is actually deleted; hidden messages will reappear if the filter is turned back on.|n|n|cnWARNING_FONT_COLOR:Note: Filters are applied instantly.|r",

	MENTIONS_REASON_FILTER = "Mention Types",
	MENTIONS_REASON_FILTER_HELP = "Choose which kinds of mentions are visible in this window.|n|n- Toggling a type only changes what is currently shown.|n- No data is actually deleted; hidden mentions will reappear if the type is turned back on.|n|n|cnWARNING_FONT_COLOR:Note: Mention Types are applied instantly.|r",
	MENTIONS_REASON_KEYWORD = "Keywords",
	MENTIONS_REASON_EMOTE = "Blizzard Emotes",

	EMPTYLABEL_TEXT = "Empty Group",
	MENTIONS_EMPTYLABEL_TEXT = "No Mentions Yet",
	MENTIONS_WINDOW_TITLE = "Mentions",
	MENTIONS_HELP = "A single window listing every message aimed at you, gathered from keyword hits and Blizzard emotes.",
	MENTIONS_ENABLE_HELP = "Enables the Mentions window and the detection that feeds it.|n|n|cnWARNING_FONT_COLOR:Note: Disabling this setting stops new mentions from being recorded and hides the window if it is open.|r",
	MENTIONS_HISTORY_SIZE = "History Size",
	MENTIONS_HISTORY_SIZE_HELP = "Set the maximum number of mentions Eavesdropper keeps in this window.|n|n|cnWARNING_FONT_COLOR:Note: Mentions are usually sparse, so this limit rarely matters unless you're in an unusually busy or broadly-keyworded session.|r",
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
	ENABLE_MOUSE = "Enable Hyperlinks",
	ENABLE_MOUSE_HELP = "Toggles the ability to interact with hyperlinks, such as items and URLs, in the Eavesdropper window.",
	LOCK_SCROLL = "Lock Scrolling",
	LOCK_SCROLL_HELP = "Disables the ability to scroll through the message history.|n|n- Use this to ensure Eavesdropper always remains at the bottom of the list to show the latest messages.",
	LOCK_WINDOW = "Lock Moving",
	LOCK_WINDOW_HELP = "Prevents Eavesdropper from being moved or resized.|n|n- Check this once you have positioned the window to avoid accidental dragging during gameplay.",
	LOCK_TITLEBAR = "Lock Title Bar",
	LOCK_TITLEBAR_HELP = "Toggles the visibility of the window's title bar.|n|n- Enabled: The title bar remains visible at all times.|n- Disabled: The title bar is hidden and only appears when you hover over the window.|n|nNote: You can enable 'Title Bar Target Name' in the settings to replace the 'Eavesdropper' text with your current target's name.",

	DEDICATED_OPTIONS = "Dedicated Options",
	MENTIONS_OPTIONS = "Mentions Options",

	-- Category Titles
	APPEARANCE_TITLE = "Appearance",

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
	MESSAGES_HELP = "These options only apply to the Eavesdropper windows.",

	HISTORY_SIZE = "History Size",
	HISTORY_SIZE_HELP = "Set the maximum number of history messages Eavesdropper displays for each unit.|n|n|cnWARNING_FONT_COLOR:Note: High values may cause temporary frame drops when refreshing the history window.|r",

	NAME_DISPLAY_MODE = "Name Display",
	NAME_DISPLAY_MODE_HELP = "Choose how character names are formatted within Eavesdropper.|n|n|cnWARNING_FONT_COLOR:Note: This option is disabled and defaults to 'Original (OOC) Name' when no suitable RP addon (TRP, MRP, XRP) is loaded.|r",
	NAME_DISPLAY_MODE_FULL_NAME = "Full Name",
	NAME_DISPLAY_MODE_FIRST_NAME = "First Name",
	NAME_DISPLAY_MODE_ORIGINAL_NAME = "Original (OOC) Name",
	NAME_DISPLAY_MODE_FOLLOW_PROFILE = "Follow Profile Setting",

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
	USE_RP_NAME_FOR_NPC_DIALOGUE_HELP = "Toggles whether your name appearing in NPC Dialogue (Say, Emote, etc.) uses your chosen 'NPC & Quest Name Display' or your original in-game name.|n|nChat bubbles will still show your original name, as Eavesdropper does not modify it (for now).|n|n|cnWARNING_FONT_COLOR:Note: This setting is disabled (and will silently do nothing) if 'Total RP 3: RP Name in Quest Text' is installed and set to modify 'NPC Speech', to prevent conflicts.|r",

	TIMESTAMP_BRACKETS = "Timestamp Brackets",
	TIMESTAMP_BRACKETS_HELP = "Toggles the visibility of brackets around message timestamps (e.g., [5m] vs 5m).",

	ADV_FORMATTING = "Adv. Formatting",
	ADVANCED_FORMATTING = "Advanced Formatting",
	ADVANCED_FORMATTING_HELP = "These options handle RP name formatting in system messages, emotes, and NPC interactions.",

	MAIN_CHAT = "Main Chat",
	MAIN_CHAT_HELP = "These options handle Advanced Formatting within the main Blizzard chat window.",

	APPLY_ON_MAIN_CHAT = "Apply to Main Chat",
	APPLY_ON_MAIN_CHAT_HELP = "Toggles whether Advanced Formatting is applied to the main Blizzard chat window in addition to the Eavesdropper history window.|n|n|cnWARNING_FONT_COLOR:Note: Formatting is not retroactive. If the required RP data is unavailable at the time a message is received, standard in-game names will be displayed.|r",

	OVERRIDE_NAME_DISPLAY = "Override Name Display",
	OVERRIDE_NAME_DISPLAY_HELP = "Toggles whether Advanced Formatting in the main Blizzard chat window uses its own name format instead of your 'Name Display' setting.",

	ADV_FORMATTING_NAME_DISPLAY = "Adv. Formatting Name Display",
	ADV_FORMATTING_NAME_DISPLAY_HELP = "Choose how character names are formatted by Advanced Formatting within the main Blizzard chat window.|n|n|cnWARNING_FONT_COLOR:Note: This option is only applied while 'Override Name Display' is enabled, and defaults to 'Original (OOC) Name' when no suitable RP addon (TRP, MRP, XRP) is loaded.|r",

	DISPLAY = "Display",
	DISPLAY_HELP = "Configure the visual style and color themes of Eavesdropper.",
	THEMES_BACKGROUND_COLOR = "Background Color",
	THEMES_BACKGROUND_COLOR_HELP = "Adjust the color and transparency of Eavesdropper.|n|n- Use the slider in the color picker to set the background opacity.",
	THEMES_TITLEBAR_COLOR = "Title Bar Color",
	THEMES_TITLEBAR_COLOR_HELP = "Set the background color and opacity for the title bar.|n|n- The title bar is typically visible when hovering over Eavesdropper.",
	THEMES_SETTINGS_ELVUI = "ElvUI Theme",
	THEMES_SETTINGS_ELVUI_HELP = "Toggles whether Eavesdropper's settings window uses ElvUI skinning or the default look.|n|n|cnWARNING_FONT_COLOR:Note: Changing this setting will trigger a UI Reload to toggle the skin.|r",
	THEMES_SETTINGS_ELVUI_CONFIRM = "Are you sure you want to change the ElvUI theme setting?|n|n|cnWARNING_FONT_COLOR:This will trigger a UI reload.|r",

	HIDE_CLOSE_BUTTON = "Hide Close Button",
	HIDE_CLOSE_BUTTON_HELP = "Toggles the visibility of the close button on the Eavesdropper frame.|n|n- If hidden, you can still control the window using |cnGREEN_FONT_COLOR:/ed show|r or |cnGREEN_FONT_COLOR:/ed hide|r.",
	HIDE_IN_COMBAT = "Hide In Combat",
	HIDE_IN_COMBAT_HELP = "Automatically hide Eavesdropper upon entering combat.|n|n|cnWARNING_FONT_COLOR:Note: Certain combat encounters or instances may restrict message capturing regardless of this setting.|r",
	HIDE_WHEN_EMPTY = "Hide When Empty",
	HIDE_WHEN_EMPTY_HELP = "Automatically hides Eavesdropper when there are no messages to display.|n|n- The window will reappear as soon as a new message is recorded.|n|n|cnWARNING_FONT_COLOR:Note: This will take effect as soon as the Settings window is closed.|r",

	TITLE_BAR_TARGET_NAME = "Title Bar Target Name",
	TITLE_BAR_TARGET_NAME_HELP = "Replaces the 'Eavesdropper' label in the title bar with the name of your current target. This provides a quick visual confirmation of which character's history is currently being tracked.",

	WELCOME_MSG = "Startup message",
	WELCOME_MSG_HELP = "Toggles the display of the welcome message.",

	FONT = "Font",
	FONT_HELP = "Customize the font of Eavesdropper to suit your preference.",

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
	DEDICATED_WINDOWS_HELP = "Allows the creation of separate, independent windows to track specific units.|n|n|cnWARNING_FONT_COLOR:Note: Disabling this setting will close all independent dedicated windows.|r",

	NEW_WINDOWS_UNIT_POPUPS = "Quick-Access Menu",
	NEW_WINDOWS_UNIT_POPUPS_HELP = "Adds 'Eavesdropper' options to the standard right-click menus on unit frames (Player, Target, Party, etc.) and chat names.|n|n- Use this to quickly open a window for a specific character.",

	NEW_WINDOWS_NEW_INDICATOR = "New Message Indicator",
	NEW_WINDOWS_NEW_INDICATOR_HELP = "Displays a visual alert on a window that receives a new message.|n|n- The indicator clears automatically after 10 seconds or immediately upon hovering over the window.",

	JUMP_TO_CONTEXT = "Jump to Context",
	JUMP_TO_CONTEXT_HELP = "Adds a small clickable icon |TInterface\\AddOns\\Eavesdropper\\Resources\\Jump.png:0:0:0:1:32:32:0:32:0:32:204:204:204|t at the start of each message, opening (or focusing) that sender's Dedicated Window scrolled to that exact line.|n|n|cnWARNING_FONT_COLOR:Note: Requires Dedicated Windows to be enabled.|r",
	JUMP_TO_CONTEXT_TOOLTIP = "|cnGREEN_FONT_COLOR:Click: Jump to this message in %s's Dedicated Window|r",

	GROUP_WINDOWS = "Group Windows",
	GROUP_WINDOWS_HELP = "Allows the creation of separate, independent windows to track multiple users simultaneously (e.g., DMs or Friends).|n|n|cnWARNING_FONT_COLOR:Note: Disabling this setting will close all independent group windows.|r",

	GROUP_HISTORY_SIZE = "History Size",
	GROUP_HISTORY_SIZE_HELP = "Set the maximum number of history messages Eavesdropper displays for each Group Window, merged across every tracked player.|n|n|cnWARNING_FONT_COLOR:Note: High values on a Group Window tracking many players may cause temporary frame drops when refreshing the history window.|r",

	GROUP_OPTIONS = "Group Options",
	GROUP_RENAME = "Change Group Name",

	PLAYER_LIST = "Player List",
	PLAYER_LIST_HELP = "Lists every player currently tracked by this Group Window.",
	PLAYER_LIST_ADD_TARGET = "Add Target",
	PLAYER_LIST_ADD_TARGET_HELP = "Add your current target to this group.|n|n|cnWARNING_FONT_COLOR:Note: Disabled if you have no target, your target isn't a player, or they're already in this group.|r",
	PLAYER_LIST_EMPTY = "No players tracked",
	PLAYER_LIST_ROW_HELP = "Uncheck to remove this player from the group; check again to re-add them.|n|n|cnWARNING_FONT_COLOR:Note: This list only refreshes once the menu is fully closed and reopened.|r",
	PLAYER_LIST_OPEN_DEDICATED = "Open Dedicated Window",
	PLAYER_LIST_OPEN_DEDICATED_HELP = "Open a Dedicated Window for this player.|n|n|cnWARNING_FONT_COLOR:Note: Does not do anything if this player already has a Dedicated Window.|r",

	MINIMAP_BUTTON = "Minimap Button",
	MINIMAP_BUTTON_HELP = "Toggles the display of the minimap button.",

	ADDON_COMPARTMENT_BUTTON = "Addon compartment",
	ADDON_COMPARTMENT_BUTTON_HELP = "Toggles the display of the addon compartment button.",

	-- Notifications Tab
	NOTIFICATIONS_TITLE = "Notifications",

	EMOTES = "Emotes",
	EMOTES_HELP = "When someone emotes at your character (e.g., /point, /laugh).",

	TARGET = "Target",
	TARGET_HELP = "Messages received from your current target.",

	DEDICATED = "Dedicated",
	DEDICATED_HELP = "Separate, independent windows to track specific units.",
	DEDICATED_NOTIFICATIONS_HELP = "Messages received in Dedicated Windows.",

	GROUPS = "Groups",
	GROUP_HELP = "Separate, independent windows to track multiple users simultaneously (e.g., DMs or Friends).",
	GROUP_NOTIFICATIONS_HELP = "Messages received in Group Windows.",

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
	PROFILES_TITLE_HELP = "Store multiple setups and assign one to each character.",

	PROFILES_TRANSFER = "Import & Export",
	PROFILES_TRANSFER_HELP = "Move settings in and out of the game as a text string.",

	PROFILES_MANAGE = "Manage Profiles",
	PROFILES_MANAGE_HELP = "Manage your profiles. Hover over any profile to reveal more options.|n|n|cnWARNING_FONT_COLOR:Note: The 'Default' profile cannot be renamed or deleted.|r",

	PROFILES_NEWPROFILE = "%s |cnPURE_GREEN_COLOR:New Profile|r",

	PROFILES_RESETBUTTON = "%s |cnNORMAL_FONT_COLOR:Reset Active Profile|r",
	PROFILES_RESETBUTTON_HELP = "Restore all settings in the active profile to their original defaults.",

	PROFILES_DELETEPROFILE = "Delete Profile",
	PROFILES_DELETEPROFILE_HELP = "Permanently remove this profile from the database.|n|n- Any character using this profile is switched back to 'Default'.",

	PROFILES_OPTIONS = "Profile Options",
	PROFILES_OPTIONS_HELP = "Copy or rename this profile.",

	PROFILES_RENAMEPROFILE = "Rename Profile",
	PROFILES_RENAMEPROFILE_HELP = "Choose a new name for this profile.|n|n- Renaming the profile you are using keeps you on it.",

	PROFILES_COPYPROFILE = "Copy Profile",
	PROFILES_COPYPROFILE_HELP = "Create a new profile holding a copy of this profile's settings, then switch to it.",

	PROFILES_CONFIRM_RESET = "Are you sure you want to reset the active profile to its original defaults?",
	PROFILES_CONFIRM_DELETE = "Are you sure you want to permanently delete the profile '%s'?",
	PROFILES_CONFIRM_DELETE_CURRENT = "Are you sure you want to permanently delete the profile '%s'?|n|nAll characters with this as their active profile will be reset to 'Default'.",

	PROFILES_IMPORTBUTTON = "Import Settings",
	PROFILES_IMPORTBUTTON_HELP = "Import a profile or your global settings from a shareable text string.",

	PROFILES_EXPORTBUTTON = "Export Settings",
	PROFILES_EXPORTBUTTON_HELP = "Export the current profile or your global settings to a text string you can keep or share outside of the game.|n|nEach is exported separately.",

	PROFILES_EXPORT_PROFILE = "Profile",
	PROFILES_EXPORT_GLOBAL = "Global",

	-- Import/Export Dialog
	IMPORTEXPORT_TITLE_EXPORT_PROFILE = "Export Profile",
	IMPORTEXPORT_TITLE_EXPORT_GLOBAL = "Export Global Settings",
	IMPORTEXPORT_TITLE_IMPORT = "Import Settings",

	IMPORTEXPORT_INSTRUCTIONS_EXPORT = "Press |cnGREEN_FONT_COLOR:Ctrl+C|r to copy the string below, then paste it wherever you want to keep or share it.",
	IMPORTEXPORT_INSTRUCTIONS_IMPORT = "Paste a profile or global settings string below.",

	IMPORTEXPORT_DETECTED_PROFILE = "This is a |cnGREEN_FONT_COLOR:profile|r string. Choose which profile to import it into.",
	IMPORTEXPORT_DETECTED_GLOBAL = "This is a |cnGREEN_FONT_COLOR:global settings|r string. Importing it changes settings for every character and profile.",

	IMPORTEXPORT_NAME_LABEL = "Import As",
	IMPORTEXPORT_NAME_LABEL_HELP = "The profile the pasted settings are imported into.|n|nThis is filled in from the string automatically, but you can change it to import under another name.",
	IMPORTEXPORT_OVERWRITE = "Overwrite",
	IMPORTEXPORT_OVERWRITE_HELP = "Allow the import to replace a profile that already uses this name.|n|n|cnWARNING_FONT_COLOR:Note: Every setting in that profile will be replaced.|r",
	IMPORTEXPORT_BUTTON_IMPORT = "Import",
	IMPORTEXPORT_VERSION_DEV = "Dev",

	IMPORTEXPORT_CONFIRM_PROFILE = "Are you sure you want to import the profile '%s'?|n|nExported on |cnGREEN_FONT_COLOR:%s|r from version |cnGREEN_FONT_COLOR:%s|r.",
	IMPORTEXPORT_CONFIRM_OVERWRITE = "Are you sure you want to overwrite the profile '%s'?|n|nExported on |cnGREEN_FONT_COLOR:%s|r from version |cnGREEN_FONT_COLOR:%s|r.|n|n|cnWARNING_FONT_COLOR:Note: Every setting in that profile will be replaced.|r",
	IMPORTEXPORT_CONFIRM_GLOBAL = "Are you sure you want to import these global settings?|n|nExported on |cnGREEN_FONT_COLOR:%s|r from version |cnGREEN_FONT_COLOR:%s|r.|n|n|cnWARNING_FONT_COLOR:Note: This affects every character and profile.|r",
	IMPORTEXPORT_CONFIRM_RELOAD = "Global settings have been imported. Some of them only take effect after a reload.|n|nReload your interface now?",

	IMPORTEXPORT_SUCCESS_PROFILE = "Imported the profile '%s' and switched to it.",
	IMPORTEXPORT_SUCCESS_PROFILE_SKIPPED = "Imported the profile '%s' and switched to it. |cnWARNING_FONT_COLOR:%d |4setting:settings; could not be read and |4was:were; skipped.|r",
	IMPORTEXPORT_SUCCESS_GLOBAL = "Imported your global settings.",
	IMPORTEXPORT_SUCCESS_GLOBAL_SKIPPED = "Imported your global settings. |cnWARNING_FONT_COLOR:%d |4setting:settings; could not be read and |4was:were; skipped.|r",

	IMPORTEXPORT_ERROR_NAME_EMPTY = "Enter a name for the profile to import into.",
	IMPORTEXPORT_ERROR_NAME_TAKEN = "A profile named '%s' already exists. Choose another name, or enable 'Overwrite'.",
	IMPORTEXPORT_ERROR_WRITE_FAILED = "That string could not be imported.",
	IMPORTEXPORT_ERROR_EXPORT_FAILED = "Your settings could not be exported.",

	IMPORTEXPORT_ERROR_PEM_DECODE = "That does not look like an " .. title .. " string. Make sure you copied all of it, including the |cnGREEN_FONT_COLOR:-----BEGIN-----|r and |cnGREEN_FONT_COLOR:-----END-----|r lines.",
	IMPORTEXPORT_ERROR_PEM_LABEL = title .. " does not recognize that kind of string. It may have come from another addon, or from a newer version.",
	IMPORTEXPORT_ERROR_DECOMPRESS = "That string could not be unpacked and is most likely damaged or incomplete.",
	IMPORTEXPORT_ERROR_DESERIALIZE_CBOR = "That string could not be read and is most likely damaged.",
	IMPORTEXPORT_ERROR_PACKED_DATA_INVALID = "That string is malformed and cannot be imported.",
	IMPORTEXPORT_ERROR_SCHEMA_TOO_NEW = "That string was created by a newer version of " .. title .. " and cannot be read. Update the addon and try again.",

	ADDONINFO_BUILD = "|cnNORMAL_FONT_COLOR:Build:|r %s",
	ADDONINFO_BUILD_OUTDATED = title .. " is not optimized for this game build.|n|n|cnWARNING_FONT_COLOR:This may cause unexpected behavior.|r",
	ADDONINFO_BUILD_CURRENT = title .. " is optimized for your current game build.|n|n|cnGREEN_FONT_COLOR:All features should work as expected.|r",
	ADDONINFO_BLUESKY_SHILL_HELP = "Follow me on Bluesky!",

	-- About Tab
	ABOUT_TITLE = "About",
	ADDONINFO_VERSION = "|cnNORMAL_FONT_COLOR:Version:|r %s",
	CLICK_TO_COPY = "|cnGREEN_FONT_COLOR:Click: Open link to copy|r",
	AUTHOR_COLON = "Author: ",
	VISIT_ADDON_PAGE_TOOLTIP = "Visit the addon page on %s.",
	RUN_CLICKABLE_COMMAND = "|cnGREEN_FONT_COLOR:Click: Run clickable command|r",

	UNIT_POPUPS_EAVESDROPPER_OPTIONS_HEADER = "Eavesdropper Options",
	UNIT_POPUPS_EAVESDROP_ON = "Eavesdrop On",
	UNIT_POPUPS_EAVESDROP_ON_HELP = "Open a Dedicated Window for the current target.|n|n|cnWARNING_FONT_COLOR:Note: Disabled if the target already has a Dedicated Window.|r",
	UNIT_POPUPS_EAVESDROP_GROUP = "Eavesdrop Group",
	UNIT_POPUPS_EAVESDROP_GROUP_HELP = "Assign the current target to a specific Group Window or remove them from one.|n|n|cnWARNING_FONT_COLOR:Note: |cnGREEN_FONT_COLOR:Green group names|r indicate that the target is already a member of that group.|r",
	UNIT_POPUPS_EAVESDROP_GROUP_NEW = "Create New",
	UNIT_POPUPS_TOGGLE_MENTIONS_HELP = "Toggle the Mentions window, which lists every message that was aimed at you.|n|n- Catches keyword hits and emotes directed at you, even ones you missed in the moment.",

	POPUP_EAVESDROP_GROUP = "Eavesdropper Group name.|nEnter to confirm.",
	POPUP_RESTORE_GROUP = "A group named \"%s\" with %d member(s) was closed earlier this session.|n|nRestore its members?",
	POPUP_RENAME_PROFILE = "Rename profile '%s'.|nEnter to confirm.",
	POPUP_COPY_PROFILE = "Name the new profile copied from '%s'.|nEnter to confirm.",
	POPUP_NEW_PROFILE = "Name the new profile.|nEnter to confirm.",

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

	MSG_VERB_SAY = "says",
	MSG_VERB_YELL = "yells",
	MSG_VERB_WHISPER = "whispers",
};

BINDING_HEADER_ED = title;

---@class ED.L : ED.Locale.enUS, ED.Localization
ED.Localization = ED.LocalizationClass:New(L);
ED.Localization:RegisterNewLocale("enUS", "English", L);
