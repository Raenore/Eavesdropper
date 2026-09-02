-- Copyright The Eavesdropper Authors
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Translator ZamestoTV

local title = C_AddOns.GetAddOnMetadata("Eavesdropper", "Title");
local L;

---@type ED.Locale.enUS
L = {
	WELCOMEMSG_VERSION = "Активен профиль: |cnGREEN_FONT_COLOR:%s|r (|cnGOLD_FONT_COLOR:%s|r)!",
	WELCOMEMSG_SETTINGS = "|cnGREEN_FONT_COLOR:/ed|r %s или |cnGREEN_FONT_COLOR:/ed help|r %s",

	SLASH_COMMAND_HEADER = "Список команд:",
	SLASH_COMMAND_ED = "Открыть настройки; Eavesdropper отображается во время",
	SLASH_COMMAND_ED_SHOW = "Показать Eavesdropper",
	SLASH_COMMAND_ED_HIDE = "Скрыть Eavesdropper",
	SLASH_COMMAND_ED_TOGGLE = "Переключить видимость",
	SLASH_COMMAND_ED_SETTINGS = "Toggle Settings", -- NEW
	SLASH_COMMAND_ED_HELP = "Available Commands", -- NEW
	SLASH_COMMAND_ED_MENTIONS = "Toggle Mentions", -- NEW

	BINDING_NAME_ED_TOGGLE = "Toggle Eavesdropper", -- NEW
	BINDING_NAME_ED_SETTINGS = "Toggle Settings", -- NEW
	BINDING_NAME_ED_MENTIONS = "Toggle Mentions", -- NEW
	BINDING_NAME_ED_EAVESDROP_ON = "Eavesdrop On (Dedicated)", -- NEW

	ADDON_TOOLTIP_HELP = "|cnGREEN_FONT_COLOR:Left-Click: Open settings|nRight-Click: Open profiles|nShift-Left-Click: Toggle Eavesdropper|nShift-Right-Click: Toggle Mentions|r", -- NEW
	POPUP_LINK = "|n|nНажмите |cnGREEN_FONT_COLOR:Ctrl+C|r, чтобы скопировать, и |cnGREEN_FONT_COLOR:Ctrl+V|r для вставки в браузере.",
	POPUP_COPY_NAME = "|n|nPress |cnGREEN_FONT_COLOR:CTRL-C|r to copy the highlighted character name.", -- NEW
	COPY_SYSTEM_MESSAGE = "Скопировано в буфер обмена.",
	GLOBAL_SETTING_TOOLTIP = "|cnLIGHTBLUE_FONT_COLOR:|n|n* Global setting - persists across all profiles.|r", -- NEW

	FILTER = "Фильтр",
	FILTER_HELP = "Выберите типы сообщений для отображения.|n|n- Переключение фильтров меняет только видимость сообщений.|n- Данные не удаляются; скрытые записи появятся снова при включении фильтра.|n|n|cnWARNING_FONT_COLOR:Примечание: фильтры применяются мгновенно.|r",

	MENTIONS_REASON_FILTER = "Mention Types", -- NEW
	MENTIONS_REASON_FILTER_HELP = "Choose which kinds of mentions are visible in this window.|n|n- Toggling a type only changes what is currently shown.|n- No data is actually deleted; hidden mentions will reappear if the type is turned back on.|n|n|cnWARNING_FONT_COLOR:Note: Mention Types are applied instantly.|r", -- NEW
	MENTIONS_REASON_KEYWORD = "Keywords", -- NEW
	MENTIONS_REASON_EMOTE = "Blizzard Emotes", -- NEW

	EMPTYLABEL_TEXT = "Empty Group", -- NEW
	MENTIONS_EMPTYLABEL_TEXT = "No Mentions Yet", -- NEW
	MENTIONS_WINDOW_TITLE = "Mentions", -- NEW
	MENTIONS_HELP = "A single window listing every message aimed at you, gathered from keyword hits and Blizzard emotes.", -- NEW
	MENTIONS_ENABLE_HELP = "Enables the Mentions window and the detection that feeds it.|n|n|cnWARNING_FONT_COLOR:Note: Disabling this setting stops new mentions from being recorded and hides the window if it is open.|r", -- NEW
	MENTIONS_HISTORY_SIZE = "History Size", -- NEW
	MENTIONS_HISTORY_SIZE_HELP = "Set the maximum number of mentions Eavesdropper keeps in this window.|n|n|cnWARNING_FONT_COLOR:Note: Mentions are usually sparse, so this limit rarely matters unless you're in an unusually busy or broadly-keyworded session.|r", -- NEW
	SCROLLMARKER_TEXT = "В самый низ",

	FILTER_PUBLIC = "Общие каналы",
	FILTER_PARTY = "Группа",
	FILTER_RAID = "Рейд",
	FILTER_RAID_WARNING = "Объявления рейда",
	FILTER_INSTANCE = "Подземелье",
	FILTER_GUILD = "Гильдия",
	FILTER_GUILD_OFFICER = "Офицерский чат",
	FILTER_WHISPER = "Личные сообщения",
	FILTER_ROLLS = "Ролл",

	WINDOW_OPTIONS = "Параметры окна",
	ENABLE_MOUSE = "Включить ссылки",
	ENABLE_MOUSE_HELP = "Включение и выключение возможности кликать по гиперссылкам (например, на предметы и достижения) в окне Eavesdropper.",
	LOCK_SCROLL = "Блокировка прокрутки",
	LOCK_SCROLL_HELP = "Отключает возможность прокрутки истории сообщений.|n|n- Используйте это, чтобы окно всегда оставалось в самом низу и показывало только свежие сообщения.",
	LOCK_WINDOW = "Закрепить окно",
	LOCK_WINDOW_HELP = "Запрещает перемещение и изменение размера окна.|n|n- Рекомендуется включить после настройки положения окна, чтобы случайно не сдвинуть его в пылу сражения.",
	LOCK_TITLEBAR = "Закрепить заголовок",
	LOCK_TITLEBAR_HELP = "Настройка видимости верхней панели (заголовка).|n|n- Включено: заголовок виден всегда.|n- Выключено: заголовок скрыт и появляется только при наведении курсора на окно.|n|nПримечание: в настройках можно включить отображение имени вашей цели вместо названия аддона.",

	DEDICATED_OPTIONS = "Dedicated Options", -- NEW
	MENTIONS_OPTIONS = "Mentions Options", -- NEW

	-- Category Titles
	APPEARANCE_TITLE = "Appearance", -- NEW

	-- General Tab
	GENERAL_TITLE = "Общие",
	TARGETING = "Выбор цели",
	TARGETING_PRIORITY_MOUSEOVER = "Под курсором",
	TARGETING_PRIORITY_TARGET = "Цель",
	TARGETING_PRIORITY_FOCUS = "Фокус",

	TARGET_PRIORITY = "Приоритет",
	TARGET_PRIORITY_HELP = "Определяет, чья история отображается, если у вас одновременно есть цель и юнит под курсором.|n|n- Приоритет: выберите, кто имеет преимущество.|n- Только: отслеживать исключительно один тип цели (отключает логику фокуса).",
	TARGET_PRIORITY_PRIORITIZE_MOUSEOVER = "Приоритет: под курсором",
	TARGET_PRIORITY_PRIORITIZE_TARGET = "Приоритет: цель",
	TARGET_PRIORITY_MOUSEOVER_ONLY = "Только под курсором",
	TARGET_PRIORITY_TARGET_ONLY = "Только цель",
	TARGET_PRIORITY_FOCUS_ONLY = "Только фокус",

	FOCUS = "Фокус (Запоминание цели)",
	FOCUS_HELP = "Определяет, как аддон обрабатывает вашу цель в фокусе.|n|n- Приоритет: фокус всегда важнее остальных целей.|n- Запасной вариант: фокус отображается только при отсутствии текущей цели или юнита под курсором.|n- Игнорировать: фокус не отображается в истории.|n|n|cnWARNING_FONT_COLOR:Примечание: настройка неактивна, если выше выбран режим «Только».|r",
	FOCUS_OVERRIDE = "Приоритет",
	FOCUS_FALLBACK = "Запасной вариант",
	FOCUS_IGNORE = IGNORE,

	INCLUDE_COMPANIONS = "Включать спутников",
	INCLUDE_COMPANIONS_HELP = "Показывать историю владельца при выборе или наведении на его питомцев и спутников.|n|n- Если включено, аддон связывает питомца с данными его хозяина.|n- Если выключено, питомцы и спутники будут полностью игнорироваться.",

	MESSAGES = "Сообщения",
	MESSAGES_HELP = "Эти параметры влияют только на отображение истории в Eavesdropper.",

	HISTORY_SIZE = "Размер истории",
	HISTORY_SIZE_HELP = "Максимальное количество строк, сохраняемых для каждого персонажа.|n|n|cnWARNING_FONT_COLOR:Примечание: высокие значения могут вызвать кратковременное падение FPS при обновлении окна истории.|r",

	NAME_DISPLAY_MODE = "Отображение имен",
	NAME_DISPLAY_MODE_HELP = "Choose how character names are formatted within Eavesdropper.|n|n|cnWARNING_FONT_COLOR:Note: This option is disabled and defaults to 'Original (OOC) Name' when no suitable RP addon (TRP, MRP, XRP) is loaded.|r", -- NEW
	NAME_DISPLAY_MODE_FULL_NAME = "Полное имя",
	NAME_DISPLAY_MODE_FIRST_NAME = "Только имя",
	NAME_DISPLAY_MODE_ORIGINAL_NAME = "Оригинальное (OOC) имя",
	NAME_DISPLAY_MODE_FOLLOW_PROFILE = "Follow Profile Setting", -- NEW

	USE_RP_NAME_COLOR = "Цвет имен",
	USE_RP_NAME_COLOR_HELP = "Окрашивать имена в соответствии с РП-настройками (например, из TRP3).|n|n- Если РП-цвет не задан, используется стандартный цвет класса Blizzard.",

	USE_RP_NAME_IN_ROLLS = "Имена в бросках (/roll)",
	USE_RP_NAME_IN_ROLLS_HELP = "Использовать ли РП-имя персонажа вместо его системного никнейма в результатах бросков кубика.",

	USE_RP_NAME_FOR_TARGETS = "Имена в эмоциях",
	USE_RP_NAME_FOR_TARGETS_HELP = "Использовать ли РП-имена целей в системных эмоциях (например, /махать, /указать).|n|n|cnWARNING_FONT_COLOR:Примечание: из-за особенностей работы эмоций Blizzard замена имен может срабатывать не всегда.|r",

	NPC_DIALOGUE_AND_QUEST_TEXT = "NPC Dialogue & Quest Text", -- NEW
	NPC_DIALOGUE_AND_QUEST_TEXT_HELP = "Choose how your character's name is displayed.", -- NEW

	NPC_AND_QUEST_NAME_DISPLAY = "NPC & Quest Name Display", -- NEW
	NPC_AND_QUEST_NAME_DISPLAY_HELP = "Choose how your character's name is formatted within NPC dialogue and quest text.|n|n|cnWARNING_FONT_COLOR:Note: This option defaults to 'Original (OOC) Name' if no supported RP addon (TRP, MRP, or XRP) is detected.|r", -- NEW

	USE_RP_NAME_FOR_QUEST_TEXT = "Format Quest Text", -- NEW
	USE_RP_NAME_FOR_QUEST_TEXT_HELP = "Toggles whether your name appearing in quest text uses your chosen 'NPC & Quest Name Display' or your original in-game name.|n|n|cnWARNING_FONT_COLOR:Note: This requires a supported interaction addon (e.g., Dialogue UI) to be active.|r", -- NEW

	USE_RP_NAME_FOR_NPC_DIALOGUE = "Format NPC Dialogue", -- NEW
	USE_RP_NAME_FOR_NPC_DIALOGUE_HELP = "Toggles whether your name appearing in NPC Dialogue (Say, Emote, etc.) uses your chosen 'NPC & Quest Name Display' or your original in-game name.|n|nChat bubbles will still show your original name, as Eavesdropper does not modify it (for now).|n|n|cnWARNING_FONT_COLOR:Note: This setting is disabled (and will silently do nothing) if 'Total RP 3: RP Name in Quest Text' is installed and set to modify 'NPC Speech', to prevent conflicts.|r", -- NEW

	TIMESTAMP_BRACKETS = "Скобки меток времени",
	TIMESTAMP_BRACKETS_HELP = "Отображать ли скобки вокруг времени сообщения (например, [5м] или 5м).",

	ADV_FORMATTING = "Adv. Formatting", -- NEW
	ADVANCED_FORMATTING = "Расширенное форматирование",
	ADVANCED_FORMATTING_HELP = "These options handle RP name formatting in system messages, emotes, and NPC interactions.", -- NEW

	MAIN_CHAT = "Main Chat", -- NEW
	MAIN_CHAT_HELP = "These options handle Advanced Formatting within the main Blizzard chat window.", -- NEW

	APPLY_ON_MAIN_CHAT = "Применить к основному чату",
	APPLY_ON_MAIN_CHAT_HELP = "Применять расширенное форматирование не только к истории Eavesdropper, но и к стандартному чату Blizzard.|n|n|cnWARNING_FONT_COLOR:Примечание: форматирование не применяется к уже полученным сообщениям. Если РП-данные персонажа неизвестны в момент получения сообщения, отобразится его обычное имя.|r",

	OVERRIDE_NAME_DISPLAY = "Override Name Display", -- NEW
	OVERRIDE_NAME_DISPLAY_HELP = "Toggles whether Advanced Formatting in the main Blizzard chat window uses its own name format instead of your 'Name Display' setting.", -- NEW

	ADV_FORMATTING_NAME_DISPLAY = "Adv. Formatting Name Display", -- NEW
	ADV_FORMATTING_NAME_DISPLAY_HELP = "Choose how character names are formatted by Advanced Formatting within the main Blizzard chat window.|n|n|cnWARNING_FONT_COLOR:Note: This option is only applied while 'Override Name Display' is enabled, and defaults to 'Original (OOC) Name' when no suitable RP addon (TRP, MRP, XRP) is loaded.|r", -- NEW

	DISPLAY = "Внешний вид",
	DISPLAY_HELP = "Configure the visual style and color themes of Eavesdropper.", -- NEW
	THEMES_BACKGROUND_COLOR = "Цвет фона",
	THEMES_BACKGROUND_COLOR_HELP = "Настройка цвета и прозрачности окна Eavesdropper.|n|n- Используйте ползунок в окне выбора цвета, чтобы изменить прозрачность фона.",
	THEMES_TITLEBAR_COLOR = "Цвет заголовка",
	THEMES_TITLEBAR_COLOR_HELP = "Настройка цвета и прозрачности строки заголовка.|n|n- Заголовок обычно становится видимым при наведении курсора на окно.",
	THEMES_SETTINGS_ELVUI = "Стиль ElvUI",
	THEMES_SETTINGS_ELVUI_HELP = "Принудительно использовать оформление ElvUI для окон аддона.|n|n|cnWARNING_FONT_COLOR:Примечание: переключение этой опции вызовет автоматическую перезагрузку интерфейса (Reload UI).|r",
	THEMES_SETTINGS_ELVUI_CONFIRM = "Are you sure you want to change the ElvUI theme setting?|n|n|cnWARNING_FONT_COLOR:This will trigger a UI reload.|r", -- NEW

	HIDE_CLOSE_BUTTON = "Скрыть кнопку закрытия",
	HIDE_CLOSE_BUTTON_HELP = "Скрывает «крестик» закрытия на рамке окна.|n|n- Вы по-прежнему сможете управлять окном через команды |cnGREEN_FONT_COLOR:/ed show|r и |cnGREEN_FONT_COLOR:/ed hide|r.",
	HIDE_IN_COMBAT = "Скрывать в бою",
	HIDE_IN_COMBAT_HELP = "Автоматически скрывать окно аддона при вступлении в бой.|n|n|cnWARNING_FONT_COLOR:Примечание: в некоторых подземельях или сценариях запись сообщений может быть ограничена игрой независимо от этой настройки.|r",
	HIDE_WHEN_EMPTY = "Скрывать, если пусто",
	HIDE_WHEN_EMPTY_HELP = "Автоматически скрывать окно, если в нем нет сообщений для отображения.|n|n- Окно появится снова, как только будет записано новое сообщение.|n|n|cnWARNING_FONT_COLOR:Примечание: настройка вступит в силу сразу после закрытия этого окна настроек.|r",

	TITLE_BAR_TARGET_NAME = "Имя цели в заголовке",
	TITLE_BAR_TARGET_NAME_HELP = "Заменяет название «Eavesdropper» в заголовке на имя вашей текущей цели. Позволяет быстро понять, чью историю вы сейчас просматриваете.",

	WELCOME_MSG = "Сообщение при запуске",
	WELCOME_MSG_HELP = "Показывать ли приветствие в чате при загрузке аддона.|n|n* Это общая настройка для всех профилей.",

	FONT = "Шрифт",
	FONT_HELP = "Customize the font of Eavesdropper to suit your preference.", -- NEW

	FONT_FACE = "Гарнитура",
	FONT_FACE_HELP = "Выберите шрифт для всего текста в Eavesdropper.|n|nПримечание: в этом списке также отображаются шрифты из других аддонов (через LibSharedMedia).",

	FONT_SIZE = "Размер шрифта",
	FONT_SIZE_HELP = "Настройка размера текста в окне истории.|n|n- Вы также можете менять размер, удерживая |cnGREEN_FONT_COLOR:Ctrl + колесико мыши|r при наведении на окно аддона.",

	FONT_OUTLINE = "Контур текста",
	FONT_OUTLINE_HELP = "Добавляет обводку буквам, чтобы текст лучше читался на пестром или ярком фоне.",
	FONT_OUTLINE_NONE = "Нет",
	FONT_OUTLINE_THIN = "Тонкий",
	FONT_OUTLINE_THICK = "Толстый",

	FONT_SHADOW = "Тень текста",
	FONT_SHADOW_HELP = "Добавляет мягкую тень за текстом для объема и лучшей контрастности.",

	MINIMAP = "Миникарта",

	DEDICATED_WINDOWS = "Dedicated Windows", -- NEW
	DEDICATED_WINDOWS_HELP = "Allows the creation of separate, independent windows to track specific units.|n|n|cnWARNING_FONT_COLOR:Note: Disabling this setting will close all independent dedicated windows.|r", -- NEW

	NEW_WINDOWS_UNIT_POPUPS = "Quick-Access Menu", -- NEW
	NEW_WINDOWS_UNIT_POPUPS_HELP = "Adds 'Eavesdropper' options to the standard right-click menus on unit frames (Player, Target, Party, etc.) and chat names.|n|n- Use this to quickly open a window for a specific character.", -- NEW

	NEW_WINDOWS_NEW_INDICATOR = "New Message Indicator", -- NEW
	NEW_WINDOWS_NEW_INDICATOR_HELP = "Displays a visual alert on a window that receives a new message.|n|n- The indicator clears automatically after 10 seconds or immediately upon hovering over the window.", -- NEW

	JUMP_TO_CONTEXT = "Jump to Context", -- NEW
	JUMP_TO_CONTEXT_HELP = "Adds a small clickable icon |TInterface\\AddOns\\Eavesdropper\\Resources\\Jump.png:0:0:0:1:32:32:0:32:0:32:204:204:204|t at the start of each message, opening (or focusing) that sender's Dedicated Window scrolled to that exact line.|n|n|cnWARNING_FONT_COLOR:Note: Requires Dedicated Windows to be enabled.|r", -- NEW
	JUMP_TO_CONTEXT_TOOLTIP = "|cnGREEN_FONT_COLOR:Click: Jump to this message in %s's Dedicated Window|r", -- NEW

	GROUP_WINDOWS = "Group Windows", -- NEW
	GROUP_WINDOWS_HELP = "Allows the creation of separate, independent windows to track multiple users simultaneously (e.g., DMs or Friends).|n|n|cnWARNING_FONT_COLOR:Note: Disabling this setting will close all independent group windows.|r", -- NEW

	GROUP_HISTORY_SIZE = "History Size", -- NEW
	GROUP_HISTORY_SIZE_HELP = "Set the maximum number of history messages Eavesdropper displays for each Group Window, merged across every tracked player.|n|n|cnWARNING_FONT_COLOR:Note: High values on a Group Window tracking many players may cause temporary frame drops when refreshing the history window.|r", -- NEW

	GROUP_OPTIONS = "Group Options", -- NEW
	GROUP_RENAME = "Change Group Name", -- NEW

	PLAYER_LIST = "Player List", -- NEW
	PLAYER_LIST_HELP = "Lists every player currently tracked by this Group Window.", -- NEW
	PLAYER_LIST_ADD_TARGET = "Add Target", -- NEW
	PLAYER_LIST_ADD_TARGET_HELP = "Add your current target to this group.|n|n|cnWARNING_FONT_COLOR:Note: Disabled if you have no target, your target isn't a player, or they're already in this group.|r", -- NEW
	PLAYER_LIST_EMPTY = "No players tracked", -- NEW
	PLAYER_LIST_ROW_HELP = "Uncheck to remove this player from the group; check again to re-add them.|n|n|cnWARNING_FONT_COLOR:Note: This list only refreshes once the menu is fully closed and reopened.|r", -- NEW
	PLAYER_LIST_OPEN_DEDICATED = "Open Dedicated Window", -- NEW
	PLAYER_LIST_OPEN_DEDICATED_HELP = "Open a Dedicated Window for this player.|n|n|cnWARNING_FONT_COLOR:Note: Does not do anything if this player already has a Dedicated Window.|r", -- NEW

	MINIMAP_BUTTON = "Кнопка на миникарте",
	MINIMAP_BUTTON_HELP = "Отображать значок аддона у миникарты.|n|n* Это общая настройка для всех профилей.",

	ADDON_COMPARTMENT_BUTTON = "Меню аддонов",
	ADDON_COMPARTMENT_BUTTON_HELP = "Отображать аддон в стандартном списке аддонов Blizzard (у миникарты).|n|n* Это общая настройка для всех профилей.",

	-- Notifications Tab
	NOTIFICATIONS_TITLE = "Уведомления",

	EMOTES = "Эмоции",
	EMOTES_HELP = "Когда кто-то применяет эмоцию к вашему персонажу (например, /указать, /смех).",

	TARGET = "Текущая цель",
	TARGET_HELP = "Сообщения, полученные от вашей текущей цели.",

	DEDICATED = "Dedicated", -- NEW
	DEDICATED_HELP = "Separate, independent windows to track specific units.", -- NEW
	DEDICATED_NOTIFICATIONS_HELP = "Messages received in Dedicated Windows.", -- NEW

	GROUPS = "Groups", -- NEW
	GROUP_HELP = "Separate, independent windows to track multiple users simultaneously (e.g., DMs or Friends).", -- NEW
	GROUP_NOTIFICATIONS_HELP = "Messages received in Group Windows.", -- NEW

	NOTIFICATIONS_PLAY_SOUND = "Звуковой сигнал",
	NOTIFICATIONS_PLAY_SOUND_HELP = "Включает звуковое оповещение для этого типа уведомлений.",

	NOTIFICATIONS_SOUND_FILE = "Выбор звука",
	NOTIFICATIONS_SOUND_FILE_HELP = "Выберите звук для этого оповещения.|n|nПримечание: звуки из других аддонов (через LibSharedMedia) также доступны в этом списке.",

	NOTIFICATION_FLASH_TASKBAR = "Мигание иконки",
	NOTIFICATION_FLASH_TASKBAR_HELP = "Иконка игры на панели задач будет мигать, если уведомление пришло, когда окно WoW свернуто.",

	-- Keywords Tab
	KEYWORDS_TITLE = "Ключевые слова",

	KEYWORDS_HELP = "Выделение цветом определенных слов или фраз в чате.",

	KEYWORDS_ENABLE = "Включить подсветку",
	KEYWORDS_ENABLE_HELP = "Включает систему отслеживания ключевых слов в Eavesdropper.|n|n|cnWARNING_FONT_COLOR:Примечание: списки слов сохраняются для профиля целиком, а не для каждого персонажа отдельно.|r",

	KEYWORDS_LIST = "Список слов",
	KEYWORDS_LIST_HELP = "Введите слова или фразы для выделения в истории чата.|n|nСпециальные теги:|n|cnGREEN_FONT_COLOR:<firstname>|r - ваше РП-имя|n|cnGREEN_FONT_COLOR:<lastname>|r - ваша РП-фамилия|n|cnGREEN_FONT_COLOR:<oocname>|r - ваш игровой никнейм|n|cnGREEN_FONT_COLOR:<class>|r - ваш РП-класс (или игровой)|n|cnGREEN_FONT_COLOR:<race>|r - ваша РП-раса (или игровая)|n|nПравила:|n- Разделяйте записи запятыми.|n- Регистр не учитывается (н-р, «Герой» совпадет с «герой»).|n- Пробелы внутри фраз учитываются.|n|n|cnWARNING_FONT_COLOR:Примечание: пробелы до и после запятой игнорируются.|r",

	KEYWORDS_HIGHLIGHT_COLOR = "Цвет выделения",
	KEYWORDS_HIGHLIGHT_COLOR_HELP = "Выберите цвет, которым будут окрашены ключевые слова в тексте.",

	KEYWORDS_ENABLE_PARTIAL_MATCHING = "Частичное совпадение",
	KEYWORDS_ENABLE_PARTIAL_MATCHING_HELP = "Позволяет находить ключевые слова внутри других слов.|n|nПримеры:|n- Включено: «Маг» подсветится и в слове «Магия».|n- Выключено: подсветится только отдельное слово «Маг».|n|n|cnWARNING_FONT_COLOR:Примечание: может приводить к ложным срабатываниям (например, «рог» внутри «доРОГа»).|r",

	KEYWORDS_NOTIFICATIONS_HELP = "Уведомления при обнаружении ключевого слова в сообщении.",

	-- Profiles Tab
	PROFILES_TITLE = "Профили",
	PROFILES_TITLE_HELP = "Store multiple setups and assign one to each character.", -- NEW

	PROFILES_TRANSFER = "Import & Export", -- NEW
	PROFILES_TRANSFER_HELP = "Move settings in and out of the game as a text string.", -- NEW

	PROFILES_MANAGE = "Manage Profiles", -- NEW
	PROFILES_MANAGE_HELP = "Manage your profiles. Hover over any profile to reveal more options.|n|n|cnWARNING_FONT_COLOR:Note: The 'Default' profile cannot be renamed or deleted.|r", -- NEW

	PROFILES_NEWPROFILE = "%s |cnPURE_GREEN_COLOR:New Profile|r", -- NEW

	PROFILES_RESETBUTTON = "%s |cnNORMAL_FONT_COLOR:Reset Active Profile|r", -- NEW
	PROFILES_RESETBUTTON_HELP = "Restore all settings in the active profile to their original defaults.", -- NEW

	PROFILES_DELETEPROFILE = "Удалить профиль",
	PROFILES_DELETEPROFILE_HELP = "Permanently remove this profile from the database.|n|n- Any character using this profile is switched back to 'Default'.", -- NEW

	PROFILES_OPTIONS = "Profile Options", -- NEW
	PROFILES_OPTIONS_HELP = "Copy or rename this profile.", -- NEW

	PROFILES_RENAMEPROFILE = "Rename Profile", -- NEW
	PROFILES_RENAMEPROFILE_HELP = "Choose a new name for this profile.|n|n- Renaming the profile you are using keeps you on it.", -- NEW

	PROFILES_COPYPROFILE = "Copy Profile", -- NEW
	PROFILES_COPYPROFILE_HELP = "Create a new profile holding a copy of this profile's settings, then switch to it.", -- NEW

	PROFILES_CONFIRM_RESET = "Are you sure you want to reset the active profile to its original defaults?", -- NEW
	PROFILES_CONFIRM_DELETE = "Are you sure you want to permanently delete the profile '%s'?", -- NEW
	PROFILES_CONFIRM_DELETE_CURRENT = "Are you sure you want to permanently delete the profile '%s'?|n|nAll characters with this as their active profile will be reset to 'Default'.", -- NEW

	PROFILES_IMPORTBUTTON = "Import Settings", -- NEW
	PROFILES_IMPORTBUTTON_HELP = "Import a profile or your global settings from a shareable text string.", -- NEW

	PROFILES_EXPORTBUTTON = "Export Settings", -- NEW
	PROFILES_EXPORTBUTTON_HELP = "Export the current profile or your global settings to a text string you can keep or share outside of the game.|n|nEach is exported separately.", -- NEW

	PROFILES_EXPORT_PROFILE = "Profile", -- NEW
	PROFILES_EXPORT_GLOBAL = "Global", -- NEW

	-- Import/Export Dialog
	IMPORTEXPORT_TITLE_EXPORT_PROFILE = "Export Profile", -- NEW
	IMPORTEXPORT_TITLE_EXPORT_GLOBAL = "Export Global Settings", -- NEW
	IMPORTEXPORT_TITLE_IMPORT = "Import Settings", -- NEW

	IMPORTEXPORT_INSTRUCTIONS_EXPORT = "Press |cnGREEN_FONT_COLOR:Ctrl+C|r to copy the string below, then paste it wherever you want to keep or share it.", -- NEW
	IMPORTEXPORT_INSTRUCTIONS_IMPORT = "Paste a profile or global settings string below.", -- NEW

	IMPORTEXPORT_DETECTED_PROFILE = "This is a |cnGREEN_FONT_COLOR:profile|r string. Choose which profile to import it into.", -- NEW
	IMPORTEXPORT_DETECTED_GLOBAL = "This is a |cnGREEN_FONT_COLOR:global settings|r string. Importing it changes settings for every character and profile.", -- NEW

	IMPORTEXPORT_NAME_LABEL = "Import As", -- NEW
	IMPORTEXPORT_NAME_LABEL_HELP = "The profile the pasted settings are imported into.|n|nThis is filled in from the string automatically, but you can change it to import under another name.", -- NEW
	IMPORTEXPORT_OVERWRITE = "Overwrite", -- NEW
	IMPORTEXPORT_OVERWRITE_HELP = "Allow the import to replace a profile that already uses this name.|n|n|cnWARNING_FONT_COLOR:Note: Every setting in that profile will be replaced.|r", -- NEW
	IMPORTEXPORT_BUTTON_IMPORT = "Import", -- NEW
	IMPORTEXPORT_VERSION_DEV = "Dev", -- NEW

	IMPORTEXPORT_CONFIRM_PROFILE = "Are you sure you want to import the profile '%s'?|n|nExported on |cnGREEN_FONT_COLOR:%s|r from version |cnGREEN_FONT_COLOR:%s|r.", -- NEW
	IMPORTEXPORT_CONFIRM_OVERWRITE = "Are you sure you want to overwrite the profile '%s'?|n|nExported on |cnGREEN_FONT_COLOR:%s|r from version |cnGREEN_FONT_COLOR:%s|r.|n|n|cnWARNING_FONT_COLOR:Note: Every setting in that profile will be replaced.|r", -- NEW
	IMPORTEXPORT_CONFIRM_GLOBAL = "Are you sure you want to import these global settings?|n|nExported on |cnGREEN_FONT_COLOR:%s|r from version |cnGREEN_FONT_COLOR:%s|r.|n|n|cnWARNING_FONT_COLOR:Note: This affects every character and profile.|r", -- NEW
	IMPORTEXPORT_CONFIRM_RELOAD = "Global settings have been imported. Some of them only take effect after a reload.|n|nReload your interface now?", -- NEW

	IMPORTEXPORT_SUCCESS_PROFILE = "Imported the profile '%s' and switched to it.", -- NEW
	IMPORTEXPORT_SUCCESS_PROFILE_SKIPPED = "Imported the profile '%s' and switched to it. |cnWARNING_FONT_COLOR:%d |4setting:settings; could not be read and |4was:were; skipped.|r", -- NEW
	IMPORTEXPORT_SUCCESS_GLOBAL = "Imported your global settings.", -- NEW
	IMPORTEXPORT_SUCCESS_GLOBAL_SKIPPED = "Imported your global settings. |cnWARNING_FONT_COLOR:%d |4setting:settings; could not be read and |4was:were; skipped.|r", -- NEW

	IMPORTEXPORT_ERROR_NAME_EMPTY = "Enter a name for the profile to import into.", -- NEW
	IMPORTEXPORT_ERROR_NAME_TAKEN = "A profile named '%s' already exists. Choose another name, or enable 'Overwrite'.", -- NEW
	IMPORTEXPORT_ERROR_WRITE_FAILED = "That string could not be imported.", -- NEW
	IMPORTEXPORT_ERROR_EXPORT_FAILED = "Your settings could not be exported.", -- NEW

	IMPORTEXPORT_ERROR_PEM_DECODE = "That does not look like an " .. title .. " string. Make sure you copied all of it, including the |cnGREEN_FONT_COLOR:-----BEGIN-----|r and |cnGREEN_FONT_COLOR:-----END-----|r lines.", -- NEW
	IMPORTEXPORT_ERROR_PEM_LABEL = title .. " does not recognize that kind of string. It may have come from another addon, or from a newer version.", -- NEW
	IMPORTEXPORT_ERROR_DECOMPRESS = "That string could not be unpacked and is most likely damaged or incomplete.", -- NEW
	IMPORTEXPORT_ERROR_DESERIALIZE_CBOR = "That string could not be read and is most likely damaged.", -- NEW
	IMPORTEXPORT_ERROR_PACKED_DATA_INVALID = "That string is malformed and cannot be imported.", -- NEW
	IMPORTEXPORT_ERROR_SCHEMA_TOO_NEW = "That string was created by a newer version of " .. title .. " and cannot be read. Update the addon and try again.", -- NEW

	ADDONINFO_BUILD = "|cnNORMAL_FONT_COLOR:Версия:|r %s",
	ADDONINFO_BUILD_OUTDATED = title .. " не оптимизирован для этой версии игры.|n|n|cnWARNING_FONT_COLOR:Это может привести к ошибкам в работе аддона.|r",
	ADDONINFO_BUILD_CURRENT = title .. " совместим с вашей версиями игры.|n|n|cnGREEN_FONT_COLOR:Все функции должны работать корректно.|r",
	ADDONINFO_BLUESKY_SHILL_HELP = "Подписывайтесь на меня в Bluesky!",

	-- About Tab
	ABOUT_TITLE = "About", -- NEW
	ADDONINFO_VERSION = "|cnNORMAL_FONT_COLOR:Version:|r %s", -- NEW
	CLICK_TO_COPY = "|cnGREEN_FONT_COLOR:Click: Open link to copy|r", -- NEW
	AUTHOR_COLON = "Author: ", -- NEW
	VISIT_ADDON_PAGE_TOOLTIP = "Visit the addon page on %s.", -- NEW
	RUN_CLICKABLE_COMMAND = "|cnGREEN_FONT_COLOR:Click: Run clickable command|r", -- NEW

	UNIT_POPUPS_EAVESDROPPER_OPTIONS_HEADER = "Eavesdropper Options", -- NEW
	UNIT_POPUPS_EAVESDROP_ON = "Eavesdrop On", -- NEW
	UNIT_POPUPS_EAVESDROP_ON_HELP = "Open a Dedicated Window for the current target.|n|n|cnWARNING_FONT_COLOR:Note: Disabled if the target already has a Dedicated Window.|r", -- NEW
	UNIT_POPUPS_EAVESDROP_GROUP = "Eavesdrop Group", -- NEW
	UNIT_POPUPS_EAVESDROP_GROUP_HELP = "Assign the current target to a specific Group Window or remove them from one.|n|n|cnWARNING_FONT_COLOR:Note: |cnGREEN_FONT_COLOR:Green group names|r indicate that the target is already a member of that group.|r", -- NEW
	UNIT_POPUPS_EAVESDROP_GROUP_NEW = "Create New", -- NEW
	UNIT_POPUPS_TOGGLE_MENTIONS_HELP = "Toggle the Mentions window, which lists every message that was aimed at you.|n|n- Catches keyword hits and emotes directed at you, even ones you missed in the moment.", -- NEW

	POPUP_EAVESDROP_GROUP = "Eavesdropper Group name.|nEnter to confirm.", -- NEW
	POPUP_RESTORE_GROUP = "A group named \"%s\" with %d member(s) was closed earlier this session.|n|nRestore its members?", -- NEW
	POPUP_RENAME_PROFILE = "Rename profile '%s'.|nEnter to confirm.", -- NEW
	POPUP_COPY_PROFILE = "Name the new profile copied from '%s'.|nEnter to confirm.", -- NEW
	POPUP_NEW_PROFILE = "Name the new profile.|nEnter to confirm.", -- NEW

	-- Message Prefixes (keep them shorthand)
	MSG_PREFIX_PARTY = "P", -- NEW
	MSG_PREFIX_RAID = "R", -- NEW
	MSG_PREFIX_INSTANCE = "I", -- NEW
	MSG_PREFIX_OFFICER = "O", -- NEW
	MSG_PREFIX_GUILD = "G", -- NEW
	MSG_PREFIX_CHANNEL = "C", -- NEW
	MSG_PREFIX_RAID_WARNING = "RW", -- NEW
	MSG_PREFIX_WHISPER_FROM = "W From", -- NEW
	MSG_PREFIX_WHISPER_TO = "W To", -- NEW

	MSG_VERB_SAY = "says", -- NEW
	MSG_VERB_YELL = "yells", -- NEW
	MSG_VERB_WHISPER = "whispers", -- NEW
};

ED.Localization:RegisterNewLocale("ruRU", "Russian", L);
