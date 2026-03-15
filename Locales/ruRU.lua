-- Copyright The Eavesdropper Authors
-- SPDX-License-Identifier: Apache-2.0
-- Translator ZamestoTV

local title = C_AddOns.GetAddOnMetadata("Eavesdropper", "Title");
local L;

L = {
	WELCOMEMSG_VERSION = "Активен профиль: |cnGREEN_FONT_COLOR:%s|r (|cnGOLD_FONT_COLOR:%s|r)!",
	WELCOMEMSG_SETTINGS = "Настройки: |cnGREEN_FONT_COLOR:/ed|r или |cnGREEN_FONT_COLOR:/ed help|r",

	SLASH_COMMAND_HEADER = "Список команд:",
	SLASH_COMMAND_ED = "Открыть настройки; Eavesdropper отображается во время",
	SLASH_COMMAND_ED_SHOW = "Показать Eavesdropper",
	SLASH_COMMAND_ED_HIDE = "Скрыть Eavesdropper",
	SLASH_COMMAND_ED_TOGGLE = "Переключить видимость",

	ADDON_TOOLTIP_HELP = "|cnGREEN_FONT_COLOR:ЛКМ: настройки|nПКМ: профили|r",
	POPUP_LINK = "|n|nНажмите |cnGREEN_FONT_COLOR:Ctrl+C|r, чтобы скопировать, и |cnGREEN_FONT_COLOR:Ctrl+V|r для вставки в браузере.",
	COPY_SYSTEM_MESSAGE = "Скопировано в буфер обмена.",

	FILTER = "Фильтр",
	FILTER_HELP = "Выберите типы сообщений для отображения.|n|n- Переключение фильтров меняет только видимость сообщений.|n- Данные не удаляются; скрытые записи появятся снова при включении фильтра.|n|n|cnWARNING_FONT_COLOR:Примечание: фильтры применяются мгновенно.|r",

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
	ENABLE_MOUSE = "Взаимодействие мышью",
	ENABLE_MOUSE_HELP = "Позволяет взаимодействовать с окном Eavesdropper при помощи мыши.|n|n- Включено: можно кликать по ссылкам на предметы и URL в истории сообщений.|n- Выключено: клики проходят «сквозь» окно, исключая случайные нажатия во время боя или игры.",
	LOCK_SCROLL = "Блокировка прокрутки",
	LOCK_SCROLL_HELP = "Отключает возможность прокрутки истории сообщений.|n|n- Используйте это, чтобы окно всегда оставалось в самом низу и показывало только свежие сообщения.",
	LOCK_WINDOW = "Закрепить окно",
	LOCK_WINDOW_HELP = "Запрещает перемещение и изменение размера окна.|n|n- Рекомендуется включить после настройки положения окна, чтобы случайно не сдвинуть его в пылу сражения.",
	LOCK_TITLEBAR = "Закрепить заголовок",
	LOCK_TITLEBAR_HELP = "Настройка видимости верхней панели (заголовка).|n|n- Включено: заголовок виден всегда.|n- Выключено: заголовок скрыт и появляется только при наведении курсора на окно.|n|nПримечание: в настройках можно включить отображение имени вашей цели вместо названия аддона.",

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
	NAME_DISPLAY_MODE_HELP = "Выберите формат имен персонажей в окне аддона.",
	NAME_DISPLAY_MODE_FULL_NAME = "Полное имя",
	NAME_DISPLAY_MODE_FIRST_NAME = "Только имя",
	NAME_DISPLAY_MODE_ORIGINAL_NAME = "Оригинальное (OOC) имя",

	USE_RP_NAME_COLOR = "Цвет имен",
	USE_RP_NAME_COLOR_HELP = "Окрашивать имена в соответствии с РП-настройками (например, из TRP3).|n|n- Если РП-цвет не задан, используется стандартный цвет класса Blizzard.",

	USE_RP_NAME_IN_ROLLS = "Имена в бросках (/roll)",
	USE_RP_NAME_IN_ROLLS_HELP = "Использовать ли РП-имя персонажа вместо его системного никнейма в результатах бросков кубика.",

	USE_RP_NAME_FOR_TARGETS = "Имена в эмоциях",
	USE_RP_NAME_FOR_TARGETS_HELP = "Использовать ли РП-имена целей в системных эмоциях (например, /махать, /указать).|n|n|cnWARNING_FONT_COLOR:Примечание: из-за особенностей работы эмоций Blizzard замена имен может срабатывать не всегда.|r",

	TIMESTAMP_BRACKETS = "Скобки меток времени",
	TIMESTAMP_BRACKETS_HELP = "Отображать ли скобки вокруг времени сообщения (например, [5м] или 5м).",

	ADVANCED_FORMATTING = "Расширенное форматирование",

	APPLY_ON_MAIN_CHAT = "Применить к основному чату",
	APPLY_ON_MAIN_CHAT_HELP = "Применять расширенное форматирование не только к истории Eavesdropper, но и к стандартному чату Blizzard.|n|n|cnWARNING_FONT_COLOR:Примечание: форматирование не применяется к уже полученным сообщениям. Если РП-данные персонажа неизвестны в момент получения сообщения, отобразится его обычное имя.|r",

	DISPLAY = "Внешний вид",
	THEMES_BACKGROUND_COLOR = "Цвет фона",
	THEMES_BACKGROUND_COLOR_HELP = "Настройка цвета и прозрачности окна Eavesdropper.|n|n- Используйте ползунок в окне выбора цвета, чтобы изменить прозрачность фона.",
	THEMES_TITLEBAR_COLOR = "Цвет заголовка",
	THEMES_TITLEBAR_COLOR_HELP = "Настройка цвета и прозрачности строки заголовка.|n|n- Заголовок обычно становится видимым при наведении курсора на окно.",
	THEMES_SETTINGS_ELVUI = "Стиль ElvUI",
	THEMES_SETTINGS_ELVUI_HELP = "Принудительно использовать оформление ElvUI для окон аддона.|n|n|cnWARNING_FONT_COLOR:Примечание: переключение этой опции вызовет автоматическую перезагрузку интерфейса (Reload UI).|r",

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

	PROFILES_CURRENTPROFILE = "Текущий профиль",
	PROFILES_CURRENTPROFILE_HELP = "Выберите профиль настроек для этого персонажа.",

	PROFILES_NEWPROFILE = "Новый профиль",
	PROFILES_NEWPROFILE_HELP = "Создать новый профиль. Введите название и нажмите Enter.",

	PROFILES_COPYFROM = "Скопировать из",
	PROFILES_COPYFROM_HELP = "Копирует все параметры из другого профиля в текущий.|n|n|cnWARNING_FONT_COLOR:Внимание: настройки будут перезаписаны мгновенно и без подтверждения!|r",

	PROFILES_RESETBUTTON = "Сбросить профиль",
	PROFILES_RESETBUTTON_HELP = "Сброс всех настроек текущего профиля до значений по умолчанию.|n|n|cnWARNING_FONT_COLOR:Внимание: сброс произойдет мгновенно и без подтверждения!|r",

	PROFILES_DELETEPROFILE = "Удалить профиль",
	PROFILES_DELETEPROFILE_HELP = "Безвозвратное удаление выбранного профиля из базы данных аддона.|n|n|cnWARNING_FONT_COLOR:Внимание: профиль будет удален мгновенно и без подтверждения!|r",

	ADDONINFO_BUILD = "|cnNORMAL_FONT_COLOR:Версия:|r %s",
	ADDONINFO_BUILD_OUTDATED = title .. " не оптимизирован для этой версии игры.|n|n|cnWARNING_FONT_COLOR:Это может привести к ошибкам в работе аддона.|r",
	ADDONINFO_BUILD_CURRENT = title .. " совместим с вашей версиями игры.|n|n|cnGREEN_FONT_COLOR:Все функции должны работать корректно.|r",
	ADDONINFO_BLUESKY_SHILL_HELP = "Подписывайтесь на меня в Bluesky!",
};

ED.Localization:RegisterNewLocale("ruRU", "Russian", L);
