max_line_length = false

exclude_files = {
	"Libs",
};

ignore = {
	-- Ignore global writes/accesses/mutations on anything prefixed with
	-- "EAVESDROPPER_". This is the standard prefix for all of our global frame names
	-- and mixins.
	"11./^Eavesdropper_",

	-- Ignore unused self. This would popup for Mixins and Objects
	"212/self",

	-- Ignore _vars, they generally imply unused
	"212/^_",
};

globals = {
	-- Globals
	"BINDING_HEADER_ED",
	"BINDING_NAME_ED_TOGGLE",
	"BINDING_NAME_ED_SETTINGS",
	"BINDING_NAME_ED_EAVESDROP_ON",
	"BINDING_NAME_ED_MENTIONS",
	"ED",
	"ED_Addon",
	"EavesdropperDB",
	"EavesdropperCharDB",
	"SLASH_EAVESDROPPER1",
	"SLASH_EAVESDROPPER2",
	"SLASH_EAVESDROPPER_RELOAD1",
	"_",
};

read_globals = {
	-- Libraries/AddOns
	"ElvUI",
	"LibStub",
	"msp",
	"TRP3_API",
	"TRP3_Addon",
	"AddOn_TotalRP3",
	"Chattery",
	"Chattynator",
	"EmoteSplitter",
	"YapperAPI",
	"LibEnscriber",
	"TRP3RPNameInQuests",

	-- Common protocol globals
	"CUSTOM_CLASS_COLORS",
	"GAME_LOCALE",
};

std = "lua51+wow";

stds.wow = {
	-- Globals that we mutate.
	globals = {
		ColorPickerFrame = {
			fields = {
				"hasOpacity",
				"opacity",
				"func",
				"opacityFunc",
				"cancelFunc",
			},
		},

		"GetColoredName",
		"ItemRefTooltip",
		"SetChannelPassword",
		"SlashCmdList",
		"StaticPopupDialogs",
	},

	-- Globals that we access.
	read_globals = {
		-- Lua function aliases and extensions

		bit = {
			fields = {
				"arshift",
				"band",
			},
		},

		string = {
			fields = {
				"contains", -- Native on Forever and 12.1.5+.
				"join",
				"split",
				"startswith", -- Native on Forever and 12.1.5+.
				"trim",
			},
		},

		table = {
			fields = {
				"wipe",
			},
		},

		"date",
		"floor",
		"format",
		"sort",
		"strlenutf8",
		"tContains",
		"time",
		"tinsert",
		"tremove",
		"wipe",

		-- Global Functions

		ChatFrameUtil = {
			fields = {
				"ActivateChat",
				"AddMessageEventFilter",
				"AddSenderNameFilter",
				"ChooseBoxForSend",
				"ForEachChatFrame",
				"RemoveMessageEventFilter",
				"RemoveSenderNameFilter",
			},
		},

		Constants = {
			fields = {
				CharacterNameSeparatorConsts = {
					fields = {
						"CHARACTERNAME_REALMNAME_SEPARATOR",
						"CHARACTERNAME_SURNAME_SEPARATOR",
					},
				},
			},
		},

		C_AddOns = {
			fields = {
				"GetAddOnMetadata",
				"IsAddOnLoaded",
			},
		},

		C_ChatBubbles = {
			fields = {
				"GetAllChatBubbles",
			},
		},

		C_ChatInfo = {
			fields = {
				"InChatMessagingLockdown",
			},
		},

		C_ClassColor = {
			fields = {
				"GetClassColor",
			},
		},

		C_EncodingUtil = {
			fields = {
				"CompressString",
				"DecodeBase64",
				"DecompressString",
				"DeserializeCBOR",
				"EncodeBase64",
				"SerializeCBOR",
			},
		},

		C_GuildInfo = {
			fields = {
				"GuildRoster",
			},
		},

		C_Roleset = {
			fields = {
				"ApplyRolesetFilters",
			},
		},

		C_StringUtil = {
			fields = {
				"StripHyperlinks",
			},
		},

		C_Timer = {
			fields = {
				"After",
				"NewTicker",
				"NewTimer",
			},
		},

		Enum = {
			fields = {
				Base64Variant = {
					fields = {
						"Standard",
					},
				},

				CompressionMethod = {
					fields = {
						"Deflate",
					},
				},
			},
		},

		EventUtil = {
			fields = {
				"ContinueOnAddOnLoaded",
				"ContinueOnPlayerLogin",
			},
		},

		Menu = {
			fields = {
				"GetManager",
				"ModifyMenu",
			},
		},

		MenuTemplates = {
			fields = {
				"AttachAutoHideCancelButton",
				"AttachAutoHideGearButton",
				"SetUtilityButtonAnchor",
				"SetUtilityButtonClickHandler",
				"SetUtilityButtonLockedEnabledState",
			},
		},

		MenuUtil = {
			fields = {
				"CreateButton",
				"CreateCheckbox",
				"CreateContextMenu",
				"CreateDivider",
				"CreateRadio",
				"CreateTitle",
				"GetElementText",
				"HookTooltipScripts",
			},
		},

		MenuVariants = {
			fields = {
				"CancelButtonAnchor",
				"GearButtonAnchor",
			},
		},

		NameUtil = {
			fields = {
				"GetFullNameWithoutRealm",
				"SplitPlayerNameIntoParts",
			},
		},

		PixelUtil = {
			fields = {
				"ConvertPixelsToUIForRegion",
				"SetPoint",
				"SetSize",
			},
		},

		ScrollUtil = {
			fields = {
				"AddResizableChildrenBehavior",
				"InitScrollBoxListWithScrollBar",
			},
		},

		"canaccessvalue",
		"Clamp",
		"CopyTable",
		"CreateAtlasMarkup",
		"CreateColor",
		"CreateColorFromHexString",
		"CreateDataProvider",
		"CreateFrame",
		"CreateFromMixins",
		"CreateScrollBoxListLinearView",
		"CreateTextureMarkup",
		"EventRegistry",
		"FlashClientIcon",
		"GameTooltip_AddNormalLine",
		"GameTooltip_SetTitle",
		"GetAppropriateTooltip",
		"GetBuildInfo",
		"GetChannelName",
		"GetCursorPosition",
		"GetDefaultLanguage",
		"GetGuildRosterInfo",
		"GetLocale",
		"GetMouseFoci",
		"GetNormalizedRealmName",
		"GetNumGroupMembers",
		"GetNumGuildMembers",
		"GetPlayerInfoByGUID",
		"GetRealmName",
		"GetTime",
		"GetUnitName",
		"hooksecurefunc",
		"InCombatLockdown",
		"IsAltKeyDown",
		"IsControlKeyDown",
		"IsInGuild",
		"IsInRaid",
		"IsShiftKeyDown",
		"Mixin",
		"PlayerIsInCombat",
		"PlaySoundFile",
		"RegionalUniqueNamesEnabled",
		"ReloadUI",
		"Round",
		"RunNextFrame",
		"Saturate",
		"SetItemRef",
		"Settings",
		"StaticPopup_Show",
		"StaticPopup_Hide",
		"StringContains",
		"TableIsEmpty",
		"UnitExists",
		"UnitGUID",
		"UnitIsPlayer",
		"UnitName",
		"UnitNameFromGUID",
		"UnitNameUnmodified",
		"UnitOwnerGUID",

		-- Global Mixins and UI Objects

		ColorPickerFrame = {
			fields = {
				"GetColorAlpha",
				"GetColorRGB",
				"SetupColorPickerAndShow",
			},
		},

		"ChatTypeInfo",
		"GameFontHighlight",
		"GameFontNormal",
		"GameFontNormalLarge",
		"GameTooltip",
		"HousingControlsFrame",
		"MenuResponse",
		"PlayerFrame",
		"PTR_IssueReporter",
		"RogueComboPointBarFrame",
		"TargetFrame",
		"UIErrorsFrame",
		"UIParent",
		"UISpecialFrames",
		"WarlockPowerFrame",

		-- Global Constants

		"ACCEPT",
		"BLUE_FONT_COLOR",
		"CANCEL",
		"COPY_CHARACTER_NAME",
		"DEFAULT_CHAT_FRAME",
		"ENABLE",
		"FOCUS",
		"GREEN_FONT_COLOR",
		"HIGHLIGHT_FONT_COLOR",
		"IGNORE",
		"LINK_FONT_COLOR",
		"MAIN_MENU",
		"NONE",
		"NORMAL_FONT_COLOR",
		"RAID_CLASS_COLORS",
		"RANDOM_ROLL_RESULT",
		"SETTINGS",
		"UNIT_FRAME_DROPDOWN_SUBSECTION_TITLE_OTHER",
		"UNKNOWN",
		"UNKNOWNOBJECT",
		"WARNING_FONT_COLOR",
		"WHITE_FONT_COLOR",
		"WOW_PROJECT_CAMELOT",
		"WOW_PROJECT_ID",
		"WOW_PROJECT_MAINLINE",
		"YELLOW_FONT_COLOR",
	},
};
