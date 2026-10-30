-- Copyright The Eavesdropper Authors
-- SPDX-License-Identifier: GPL-3.0-or-later

local title = C_AddOns.GetAddOnMetadata("Eavesdropper", "Title");
local L;

---@class ED.Locale.deDE
L = {
	WELCOMEMSG_VERSION = "Hört mit Profil |cnGREEN_FONT_COLOR:%s|r (|cnGOLD_FONT_COLOR:%s|r) zu!",
	WELCOMEMSG_SETTINGS = "|cnGREEN_FONT_COLOR:/ed|r %s & |cnGREEN_FONT_COLOR:/ed help|r %s",

	SLASH_COMMAND_HEADER = "Befehlsliste (klickbar & beschreibbar):",
	SLASH_COMMAND_ED = "Einstellungen umschalten, Eavesdropper wird währenddessen eingeblendet",
	SLASH_COMMAND_ED_SHOW = "Eavesdropper anzeigen",
	SLASH_COMMAND_ED_HIDE = "Eavesdropper ausblenden",
	SLASH_COMMAND_ED_TOGGLE = "Eavesdropper umschalten",
	SLASH_COMMAND_ED_SETTINGS = "Einstellungen umschalten",
	SLASH_COMMAND_ED_HELP = "Verfügbare Befehle",
	SLASH_COMMAND_ED_MENTIONS = "Erwähnungen umschalten",

	BINDING_NAME_ED_TOGGLE = "Eavesdropper umschalten",
	BINDING_NAME_ED_SETTINGS = "Einstellungen umschalten",
	BINDING_NAME_ED_MENTIONS = "Erwähnungen umschalten",
	BINDING_NAME_ED_EAVESDROP_ON = "Beobachten (Getrennt)",

	ADDON_TOOLTIP_HELP = "|cnGREEN_FONT_COLOR:Linksklick: Einstellungen öffnen|nRechtsklick: Profile öffnen|nUmschalt+Linksklick: Eavesdropper umschalten|nUmschalt+Rechtsklick: Erwähnungen umschalten|r",
	POPUP_LINK = "|n|nDrücke |cnGREEN_FONT_COLOR:STRG-C|r, um das Hervorgehobene zu kopieren, und füge es dann in deinem Webbrowser mit |cnGREEN_FONT_COLOR:STRG-V|r ein.",
	POPUP_COPY_NAME = "|n|nDrücke |cnGREEN_FONT_COLOR:STRG-C|r, um den hervorgehobenen Charakternamen zu kopieren.",
	COPY_SYSTEM_MESSAGE = "In die Zwischenablage kopiert.",
	GLOBAL_SETTING_TOOLTIP = "|cnLIGHTBLUE_FONT_COLOR:|n|n* Globale Einstellung - bleibt in allen Profilen erhalten.|r",

	FILTER = "Filter",
	FILTER_HELP = "Wähle aus, welche Nachrichtentypen in Eavesdropper sichtbar sind.|n|n- Das Umschalten eines Filters ändert nur, was gerade angezeigt wird.|n- Es werden keine Daten wirklich gelöscht; versteckte Nachrichten erscheinen wieder, wenn der Filter erneut aktiviert wird.|n|n|cnWARNING_FONT_COLOR:Hinweis: Filter werden sofort angewendet.|r",

	MENTIONS_REASON_FILTER = "Erwähnungsarten",
	MENTIONS_REASON_FILTER_HELP = "Wähle aus, welche Arten von Erwähnungen in diesem Fenster sichtbar sind.|n|n- Das Umschalten eines Typs ändert nur, was gerade angezeigt wird.|n- Es werden keine Daten wirklich gelöscht; versteckte Erwähnungen erscheinen wieder, wenn der Typ erneut aktiviert wird.|n|n|cnWARNING_FONT_COLOR:Hinweis: Erwähnungsarten werden sofort angewendet.|r",
	MENTIONS_REASON_KEYWORD = "Schlüsselwörter",
	MENTIONS_REASON_EMOTE = "Blizzard-Emotes",

	EMPTYLABEL_TEXT = "Leere Gruppe",
	MENTIONS_EMPTYLABEL_TEXT = "Noch keine Erwähnungen",
	MENTIONS_WINDOW_TITLE = "Erwähnungen",
	MENTIONS_HELP = "Ein einzelnes Fenster, in dem jede Nachricht aufgelistet wird, die auf dich abzielt und aus Schlüsselworttreffern sowie Blizzard-Emotes gesammelt wurde.",
	MENTIONS_ENABLE_HELP = "Aktiviert das Erwähnungsfenster und die Erkennung, die es speist.|n|n|cnWARNING_FONT_COLOR:Hinweis: Wenn diese Einstellung deaktiviert wird, werden neue Erwähnungen nicht mehr gespeichert und das Fenster wird ausgeblendet, falls es geöffnet ist.|r",
	MENTIONS_HISTORY_SIZE = "Verlaufslänge",
	MENTIONS_HISTORY_SIZE_HELP = "Legt die maximale Anzahl von Erwähnungen fest, die Eavesdropper in diesem Fenster behält.|n|n|cnWARNING_FONT_COLOR:Hinweis: Erwähnungen sind normalerweise selten, daher ist dieses Limit meist irrelevant, außer in besonders aktiven oder breit gefassten Sitzungen.|r",
	SCROLLMARKER_TEXT = "Zum Ende scrollen",

	FILTER_PUBLIC = "Öffentlich",
	FILTER_PARTY = "Gruppe",
	FILTER_RAID = "Schlachtzug",
	FILTER_RAID_WARNING = "Schlachtzugswarnung",
	FILTER_INSTANCE = "Instanz",
	FILTER_GUILD = "Gilde",
	FILTER_GUILD_OFFICER = "Offizier",
	FILTER_WHISPER = "Flüstern",
	FILTER_ROLLS = "Würfe",

	WINDOW_OPTIONS = "Fensteroptionen",
	ENABLE_MOUSE = "Hyperlinks aktivieren",
	ENABLE_MOUSE_HELP = "Schaltet die Interaktion mit Hyperlinks wie Gegenständen und URLs im Eavesdropper-Fenster ein oder aus.",
	LOCK_SCROLL = "Scrollen sperren",
	LOCK_SCROLL_HELP = "Deaktiviert das Scrollen durch den Nachrichtenverlauf.|n|n- Damit bleibt Eavesdropper immer unten in der Liste, um die neuesten Nachrichten anzuzeigen.",
	LOCK_WINDOW = "Bewegen sperren",
	LOCK_WINDOW_HELP = "Verhindert, dass Eavesdropper verschoben oder in der Größe geändert wird.|n|n- Aktiviere dies, nachdem du das Fenster positioniert hast, um versehentliche Dragging-Aktionen im Spiel zu vermeiden.",
	LOCK_TITLEBAR = "Titelleiste sperren",
	LOCK_TITLEBAR_HELP = "Schaltet die Sichtbarkeit der Titelleiste des Fensters um.|n|n- Aktiviert: Die Titelleiste bleibt immer sichtbar.|n- Deaktiviert: Die Titelleiste bleibt ausgeblendet und erscheint nur, wenn du mit der Maus über das Fenster fährst.|n|nHinweis: Du kannst im Menü 'Titelleisten-Zielname' aktivieren, um den Text 'Eavesdropper' durch den Namen deines aktuellen Ziels zu ersetzen.",

	DEDICATED_OPTIONS = "Optionen für getrennte Fenster",
	MENTIONS_OPTIONS = "Erwähnungsoptionen",

	-- Category Titles
	APPEARANCE_TITLE = "Erscheinungsbild",

	-- General Tab
	GENERAL_TITLE = "Allgemein",
	TARGETING = "Zielauswahl",
	TARGETING_PRIORITY_MOUSEOVER = "Mauszeiger",
	TARGETING_PRIORITY_TARGET = "Ziel",
	TARGETING_PRIORITY_FOCUS = "Fokus",

	TARGET_PRIORITY = "Priorität",
	TARGET_PRIORITY_HELP = "Legt fest, welche Einheitenhistorie Eavesdropper anzeigt, wenn du sowohl ein Ziel als auch eine Einheit unter dem Mauszeiger hast.|n|n- Priorisieren: Wähle, welche Vorrang hat.|n- Nur: Wähle, ausschließlich einen Einheitentyp zu hören (dies deaktiviert die 'Fokus'-Logik).",
	TARGET_PRIORITY_PRIORITIZE_MOUSEOVER = "Mauszeiger priorisieren",
	TARGET_PRIORITY_PRIORITIZE_TARGET = "Ziel priorisieren",
	TARGET_PRIORITY_MOUSEOVER_ONLY = "Nur Mauszeiger",
	TARGET_PRIORITY_TARGET_ONLY = "Nur Ziel",
	TARGET_PRIORITY_FOCUS_ONLY = "Nur Fokus",

	FOCUS = "Fokus",
	FOCUS_HELP = "Legt fest, wie das Verlaufsfenster von Eavesdropper mit deinem Fokusziel umgeht.|n|n- Überschreiben: Gibt deinem Fokusziel immer Vorrang vor allen anderen Einheiten.|n- Ausweichen: Zeigt das Fokusziel nur an, wenn kein aktuelles Ziel oder Mauszeiger vorhanden ist.|n- Ignorieren: Schließt Fokusziele vollständig aus der Anzeige aus.|n|n|cnWARNING_FONT_COLOR:Hinweis: Diese Einstellung ist deaktiviert, wenn deine Priorität auf eine 'Nur'-Option gesetzt ist.|r",
	FOCUS_OVERRIDE = "Überschreiben",
	FOCUS_FALLBACK = "Ausweichen",
	FOCUS_IGNORE = IGNORE,

	INCLUDE_COMPANIONS = "Begleiter einbeziehen",
	INCLUDE_COMPANIONS_HELP = "Zeigt die Historie des Besitzers an, wenn du auf seine Haustiere oder Begleiter zielst oder den Mauszeiger darüber hältst.|n|n- Wenn aktiviert, behandelt Eavesdropper Haustiere als Brücke zu den Daten des Besitzers.|n- Wenn deaktiviert, ignoriert Eavesdropper Haustiere und Begleiter vollständig.",

	MESSAGES = "Nachrichten",
	MESSAGES_HELP = "Diese Optionen gelten nur für die Eavesdropper-Fenster.",

	HISTORY_SIZE = "Verlaufslänge",
	HISTORY_SIZE_HELP = "Legt die maximale Anzahl an Verlaufsnachrichten fest, die Eavesdropper für jede Einheit anzeigt.|n|n|cnWARNING_FONT_COLOR:Hinweis: Hohe Werte können bei der Aktualisierung des Verlaufsfensters vorübergehend zu Frame-Einbrüchen führen.|r",

	NAME_DISPLAY_MODE = "Namensdarstellung",
	NAME_DISPLAY_MODE_HELP = "Wähle aus, wie Charakternamen in Eavesdropper formatiert werden.|n|n|cnWARNING_FONT_COLOR:Hinweis: Diese Option ist deaktiviert und fällt auf 'Originaler (OOC)-Name' zurück, wenn kein geeignetes RP-Addon (TRP, MRP, XRP) geladen ist.|r",
	NAME_DISPLAY_MODE_FULL_NAME = "Vollständiger Name",
	NAME_DISPLAY_MODE_FIRST_NAME = "Vorname",
	NAME_DISPLAY_MODE_ORIGINAL_NAME = "Originaler (OOC)-Name",
	NAME_DISPLAY_MODE_FOLLOW_PROFILE = "Profil-Einstellung folgen",

	USE_RP_NAME_COLOR = "Namensfarben",
	USE_RP_NAME_COLOR_HELP = "Färbt Namen nach ihren individuellen RP-Einstellungen (z. B. aus TRP3).|n|n- Wenn keine RP-Farbe erkannt wird, fällt Eavesdropper auf die Standard- Klassenfarbe von Blizzard zurück.",

	USE_RP_NAME_IN_ROLLS = "Würfelnamen formatieren",
	USE_RP_NAME_IN_ROLLS_HELP = "Legt fest, ob zufällige Würfelergebnisse (/roll) den RP-Namen oder den ursprünglichen Ingame-Namen eines Charakters verwenden.",

	USE_RP_NAME_FOR_TARGETS = "Emote-Ziele formatieren",
	USE_RP_NAME_FOR_TARGETS_HELP = "Legt fest, ob Zielnamen innerhalb von Blizzard-Emotes (z. B. /wave, /point) den RP-Namen oder den ursprünglichen Ingame-Namen verwenden.|n|n|cnWARNING_FONT_COLOR:Hinweis: Aufgrund der Art, wie Blizzard Emote-Strings verarbeitet, kann die Namensersetzung nicht in allen Situationen konsistent funktionieren.|r",

	NPC_DIALOGUE_AND_QUEST_TEXT = "NPC-Dialog & Questtext",
	NPC_DIALOGUE_AND_QUEST_TEXT_HELP = "Wähle aus, wie dein Charakternamen angezeigt wird.",

	NPC_AND_QUEST_NAME_DISPLAY = "NPC- & Quest-Name anzeigen",
	NPC_AND_QUEST_NAME_DISPLAY_HELP = "Wähle aus, wie dein Charakternamen in NPC-Dialogen und Questtexten formatiert wird.|n|n|cnWARNING_FONT_COLOR:Hinweis: Diese Option fällt auf 'Originaler (OOC)-Name' zurück, wenn kein unterstütztes RP-Addon (TRP, MRP oder XRP) erkannt wird.|r",

	USE_RP_NAME_FOR_QUEST_TEXT = "Questtext formatieren",
	USE_RP_NAME_FOR_QUEST_TEXT_HELP = "Legt fest, ob dein Name im Questtext mit der gewählten 'NPC- & Quest-Name' oder deinem ursprünglichen Ingame-Namen angezeigt wird.|n|n|cnWARNING_FONT_COLOR:Hinweis: Dafür muss ein unterstütztes Interaktions-Addon (z. B. Dialogue UI) aktiv sein.|r",

	USE_RP_NAME_FOR_NPC_DIALOGUE = "NPC-Dialog formatieren",
	USE_RP_NAME_FOR_NPC_DIALOGUE_HELP = "Legt fest, ob dein Name in NPC-Dialogen und Sprechblasen mit der gewählten 'NPC- & Quest-Name' oder deinem ursprünglichen Ingame-Namen angezeigt wird.|n|n|cnWARNING_FONT_COLOR:Hinweis: Diese Option ist deaktiviert, wenn 'Total RP 3: RP Name in Quest Text' installiert ist und so konfiguriert wurde, dass es 'NPC Speech' verändert, um Konflikte zu vermeiden.|r",

	TIMESTAMP_BRACKETS = "Zeitstempelklammern",
	TIMESTAMP_BRACKETS_HELP = "Schaltet die Sichtbarkeit von Klammern um Nachrichtentimestamps um (z. B. [5m] statt 5m).",

	ADV_FORMATTING = "Erw. Formatierung",
	ADVANCED_FORMATTING = "Erweiterte Formatierung",
	ADVANCED_FORMATTING_HELP = "Diese Optionen behandeln die RP-Namensformatierung in Systemnachrichten, Emotes und NPC-Interaktionen.",

	MAIN_CHAT = "Hauptchat",
	MAIN_CHAT_HELP = "Diese Optionen behandeln die erweiterte Formatierung im Hauptchatfenster von Blizzard.",

	APPLY_ON_MAIN_CHAT = "Auf Hauptchat anwenden",
	APPLY_ON_MAIN_CHAT_HELP = "Legt fest, ob die erweiterte Formatierung auf das Hauptchatfenster von Blizzard angewendet wird. Formatiert zusätzlich bereits sichtbare Emote- und Würfel-Namen neu.|n|n|cnWARNING_FONT_COLOR:Hinweis: Dafür sind RP-Daten erforderlich und es kann mit chatmodifizierenden Addons nicht funktionieren.|r",

	OVERRIDE_NAME_DISPLAY = "Namensdarstellung überschreiben",
	OVERRIDE_NAME_DISPLAY_HELP = "Legt fest, ob die erweiterte Formatierung im Hauptchatfenster ihre eigene Namensformatierung verwendet, statt der Einstellung 'Namensdarstellung'.",

	ADV_FORMATTING_NAME_DISPLAY = "Erw. Formatierungs-Namensdarstellung",
	ADV_FORMATTING_NAME_DISPLAY_HELP = "Wähle aus, wie Charakternamen von der erweiterten Formatierung im Hauptchatfenster formatiert werden.|n|n|cnWARNING_FONT_COLOR:Hinweis: Diese Option wird nur angewendet, wenn 'Namensdarstellung überschreiben' aktiviert ist und fällt auf 'Originaler (OOC)-Name' zurück, wenn kein geeignetes RP-Addon (TRP, MRP, XRP) geladen ist.|r",

	DISPLAY = "Darstellung",
	DISPLAY_HELP = "Konfiguriere den visuellen Stil und die Farbthemen von Eavesdropper.",
	THEMES_BACKGROUND_COLOR = "Hintergrundfarbe",
	THEMES_BACKGROUND_COLOR_HELP = "Passe die Farbe und Transparenz von Eavesdropper an.|n|n- Verwende den Schieberegler im Farbwähler, um die Hintergrunddeckkraft einzustellen.",
	THEMES_TITLEBAR_COLOR = "Titelleistenfarbe",
	THEMES_TITLEBAR_COLOR_HELP = "Lege die Hintergrundfarbe und Deckkraft der Titelleiste fest.|n|n- Die Titelleiste ist normalerweise sichtbar, wenn du mit der Maus über Eavesdropper fährst.",
	THEMES_SETTINGS_ELVUI = "ElvUI-Theme",
	THEMES_SETTINGS_ELVUI_HELP = "Legt fest, ob das Einstellungsfenster von Eavesdropper ElvUI-Skinning verwendet oder das Standardaussehen.|n|n|cnWARNING_FONT_COLOR:Hinweis: Das Ändern dieser Einstellung löst ein UI-Reload aus, um das Skin umzuschalten.|r",
	THEMES_SETTINGS_ELVUI_CONFIRM = "Bist du sicher, dass du die ElvUI-Theme-Einstellung ändern möchtest?|n|n|cnWARNING_FONT_COLOR:Dies löst ein UI-Reload aus.|r",

	HIDE_CLOSE_BUTTON = "Schließen-Schaltfläche ausblenden",
	HIDE_CLOSE_BUTTON_HELP = "Schaltet die Sichtbarkeit der Schließen-Schaltfläche am Eavesdropper-Fenster um.|n|n- Wenn sie ausgeblendet ist, kannst du das Fenster weiterhin mit |cnGREEN_FONT_COLOR:/ed show|r oder |cnGREEN_FONT_COLOR:/ed hide|r steuern.",
	HIDE_IN_COMBAT = "Im Kampf ausblenden",
	HIDE_IN_COMBAT_HELP = "Blendet Eavesdropper automatisch aus, sobald du in den Kampf gerätst.|n|n|cnWARNING_FONT_COLOR:Hinweis: Bestimmte Kampfbegegnungen oder Instanzen können das Erfassen von Nachrichten unabhängig von dieser Einstellung einschränken.|r",
	HIDE_WHEN_EMPTY = "Ausblenden, wenn leer",
	HIDE_WHEN_EMPTY_HELP = "Blendet Eavesdropper automatisch aus, wenn keine Nachrichten angezeigt werden.|n|n- Das Fenster erscheint erneut, sobald eine neue Nachricht aufgezeichnet wurde.|n|n|cnWARNING_FONT_COLOR:Hinweis: Dies tritt wirksam in Kraft, sobald das Einstellungsfenster geschlossen wird.|r",

	TITLE_BAR_TARGET_NAME = "Name des Zieles in der Titelleiste",
	TITLE_BAR_TARGET_NAME_HELP = "Ersetzt das Label 'Eavesdropper' in der Titelleiste durch den Namen deines aktuellen Ziels. Dadurch erhältst du eine schnelle visuelle Bestätigung, welche Charakterhistorie gerade verfolgt wird.",
	TITLE_BAR_FULL_NAME = "Vollständiger Name in der Titelleiste",
	TITLE_BAR_FULL_NAME_HELP = "Zeigt den vollständigen Namen in der Titelleiste statt nur den Vornamen an. Gilt auch für getrennte Fenster, die immer einen Namen anzeigen.|n|n- Mit RP-Daten ist das der vollständige RP-Name, sonst der Charaktername.",

	WELCOME_MSG = "Startmeldung",
	WELCOME_MSG_HELP = "Schaltet die Anzeige der Startmeldung um.",

	FONT = "Schriftart",
	FONT_HELP = "Passe die Schriftart von Eavesdropper an deine Vorlieben an.",

	FONT_FACE = "Schriftart",
	FONT_FACE_HELP = "Wähle die Schriftart, die für den gesamten Text in Eavesdropper verwendet wird.|n|nHinweis: Schriften anderer Addons, die LibSharedMedia verwenden, erscheinen ebenfalls in dieser Liste.",

	FONT_SIZE = "Schriftgröße",
	FONT_SIZE_HELP = "Passe die Größe der im Verlaufsfenster angezeigten Nachrichten an.|n|n- Du kannst auch |cnGREEN_FONT_COLOR:Strg + Mausrad hoch/runter|r halten, während du über Eavesdropper fährst, um die Größe direkt zu ändern.",

	FONT_OUTLINE = "Schriftumrandung",
	FONT_OUTLINE_HELP = "Fügt dem Text einen Rand hinzu, um die Lesbarkeit vor hektischen Hintergründen zu verbessern.",
	FONT_OUTLINE_NONE = "Keine",
	FONT_OUTLINE_THIN = "Dünn",
	FONT_OUTLINE_THICK = "Dick",

	FONT_SHADOW = "Schrift-Schatten",
	FONT_SHADOW_HELP = "Schaltet einen weichen Schlagschatten hinter dem Text ein, um Tiefe und Kontrast zu erhöhen.",

	MINIMAP = "Minikarte",

	DEDICATED_WINDOWS = "Getrennte Fenster",
	DEDICATED_WINDOWS_HELP = "Erlaubt die Erstellung separater, unabhängiger Fenster zur Verfolgung bestimmter Einheiten.|n|n|cnWARNING_FONT_COLOR:Hinweis: Wenn diese Einstellung deaktiviert wird, schließen sich alle unabhängigen getrennten Fenster.|r",

	NEW_WINDOWS_UNIT_POPUPS = "Schnellzugriffsmenü",
	NEW_WINDOWS_UNIT_POPUPS_HELP = "Fügt dem Standard-Rechtsklickmenü von Einheitenfenstern (Spieler, Ziel, Gruppe usw.) und Charnamen die Optionen von 'Eavesdropper' hinzu.|n|n- Damit kannst du schnell ein Fenster für einen bestimmten Charakter öffnen.",

	NEW_WINDOWS_NEW_INDICATOR = "Anzeiger für neue Nachrichten",
	NEW_WINDOWS_NEW_INDICATOR_HELP = "Zeigt eine visuelle Warnung an einem Fenster an, das eine neue Nachricht erhält.|n|n- Der Indikator verschwindet automatisch nach 10 Sekunden oder sofort beim Hovern über dem Fenster.",

	JUMP_TO_CONTEXT = "Zum Kontext springen",
	JUMP_TO_CONTEXT_HELP = "Fügt am Anfang jeder Nachricht ein kleines klickbares Symbol |TInterface\AddOns\Eavesdropper\Resources\Jump.png:0:0:0:1:32:32:0:32:0:32:204:204:204|t hinzu, das das Dedicated-Fenster des Absenders öffnet oder fokussiert und genau auf diese Zeile scrollt.|n|n|cnWARNING_FONT_COLOR:Hinweis: Dafür müssen geteilte Fenster aktiviert sein.|r",
	JUMP_TO_CONTEXT_TOOLTIP = "|cnGREEN_FONT_COLOR:Klick: Zu dieser Nachricht im Dedicated-Fenster von %s springen|r",

	GROUP_WINDOWS = "Gruppenfenster",
	GROUP_WINDOWS_HELP = "Erlaubt die Erstellung separater, unabhängiger Fenster zur gleichzeitigen Verfolgung mehrerer Benutzer (z. B. DMs oder Freunde).|n|n|cnWARNING_FONT_COLOR:Hinweis: Wenn diese Einstellung deaktiviert wird, schließen sich alle unabhängigen Gruppenfenster.|r",

	GROUP_HISTORY_SIZE = "Verlaufslänge",
	GROUP_HISTORY_SIZE_HELP = "Legt die maximale Anzahl von Verlaufsnachrichten fest, die Eavesdropper für jedes Gruppenfenster anzeigt, zusammengefasst über alle verfolgten Spieler.|n|n|cnWARNING_FONT_COLOR:Hinweis: Hohe Werte in einem Gruppenfenster, das viele Spieler verfolgt, können bei der Aktualisierung des Verlaufsfensters vorübergehend zu Frame-Einbrüchen führen.|r",

	GROUP_OPTIONS = "Gruppenoptionen",
	GROUP_RENAME = "Gruppenname ändern",

	PLAYER_LIST = "Spielerliste",
	PLAYER_LIST_HELP = "Listet jeden Spieler auf, der derzeit von diesem Gruppenfenster verfolgt wird.",
	PLAYER_LIST_ADD_TARGET = "Ziel hinzufügen",
	PLAYER_LIST_ADD_TARGET_HELP = "Fügt dein aktuelles Ziel dieser Gruppe hinzu.|n|n|cnWARNING_FONT_COLOR:Hinweis: Deaktiviert, wenn du kein Ziel hast, dein Ziel kein Spieler ist oder sie bereits in dieser Gruppe sind.|r",
	PLAYER_LIST_EMPTY = "Keine Spieler verfolgt",
	PLAYER_LIST_ROW_HELP = "Abwählen, um diesen Spieler aus der Gruppe zu entfernen; erneut ankreuzen, um ihn wieder hinzuzufügen.|n|n|cnWARNING_FONT_COLOR:Hinweis: Diese Liste aktualisiert sich erst, wenn das Menü vollständig geschlossen und erneut geöffnet wurde.|r",
	PLAYER_LIST_OPEN_DEDICATED = "Getrenntes Fenster öffnen",
	PLAYER_LIST_OPEN_DEDICATED_HELP = "Öffnet ein separates Fenster für diesen Spieler.|n|n|cnWARNING_FONT_COLOR:Hinweis: Tut nichts, wenn dieser Spieler bereits ein separates Fenster hat.|r",

	MINIMAP_BUTTON = "Minimap-Schaltfläche",
	MINIMAP_BUTTON_HELP = "Schaltet die Anzeige der Minimap-Schaltfläche um.",

	ADDON_COMPARTMENT_BUTTON = "Add-on-Fach",
	ADDON_COMPARTMENT_BUTTON_HELP = "Schaltet die Anzeige der Schaltfläche im Add-on-Fach um.",

	-- Notifications Tab
	NOTIFICATIONS_TITLE = "Benachrichtigungen",

	EMOTES = "Emotes",
	EMOTES_HELP = "Wenn jemand an deinen Charakter emote-t (z. B. /point, /laugh).",

	TARGET = "Ziel",
	TARGET_HELP = "Nachrichten, die du von deinem aktuellen Ziel erhalten hast.",

	DEDICATED = "Getrennt",
	DEDICATED_HELP = "Separate, unabhängige Fenster zur Verfolgung bestimmter Einheiten.",
	DEDICATED_NOTIFICATIONS_HELP = "Nachrichten, die in getrennten Fenstern empfangen wurden.",

	GROUPS = "Gruppen",
	GROUP_HELP = "Separate, unabhängige Fenster zur gleichzeitigen Verfolgung mehrerer Benutzer (z. B. DMs oder Freunde).",
	GROUP_NOTIFICATIONS_HELP = "Nachrichten, die in Gruppenfenstern empfangen wurden.",

	NOTIFICATIONS_PLAY_SOUND = "Ton abspielen",
	NOTIFICATIONS_PLAY_SOUND_HELP = "Legt fest, ob Eavesdropper für diesen Benachrichtigungstyp einen Warnsound abspielt.",

	NOTIFICATIONS_SOUND_FILE = "Sounddatei",
	NOTIFICATIONS_SOUND_FILE_HELP = "Wähle die konkrete Sounddatei, die Eavesdropper für diese Warnung abspielen soll.|n|nHinweis: Sounds anderer Addons, die LibSharedMedia nutzen, erscheinen ebenfalls in dieser Liste.",

	NOTIFICATION_FLASH_TASKBAR = "Taskleiste blinken",
	NOTIFICATION_FLASH_TASKBAR_HELP = "Legt fest, ob das Taskleistensymbol des Spiels bei Auslösung dieses Benachrichtigungstyps blinkt, wenn das Spiel minimiert ist.",

	-- Keywords Tab
	KEYWORDS_TITLE = "Schlüsselwörter",

	KEYWORDS_HELP = "Hebt bestimmte Wörter oder Phrasen hervor, die im Chat erscheinen.",

	KEYWORDS_ENABLE = "Aktivieren",
	KEYWORDS_ENABLE_HELP = "Schaltet das Schlüsselwort-Hervorhebungs-System für Eavesdropper um.|n|n|cnWARNING_FONT_COLOR:Hinweis: Schlüsselwortlisten werden pro Profil gespeichert, nicht pro Charakter.|r",

	KEYWORDS_LIST = "Schlüsselwortliste",
	KEYWORDS_LIST_HELP = "Gib Wörter oder Phrasen ein, die im Chathistorie hervorgehoben werden sollen.|n|nSpezialtags:|n|cnGREEN_FONT_COLOR:<firstname>|r - Dein RP-Vorname|n|cnGREEN_FONT_COLOR:<lastname>|r - Dein RP-Nachname|n|cnGREEN_FONT_COLOR:<oocname>|r - Dein Ingame-Name|n%s|cnGREEN_FONT_COLOR:<class>|r - Deine RP-Klasse (fällt auf die Spielklasse zurück)|n|cnGREEN_FONT_COLOR:<race>|r - Deine RP-Rasse (fällt auf die Spielrasse zurück)|n|nFormatierung:|n- Trenne mehrere Einträge mit Kommas.|n- Einträge sind groß-/kleinschreibungsempfindlich (z. B. 'Held' entspricht 'held').|n- Leerzeichen innerhalb einer Phrase bleiben erhalten.|n|n|cnWARNING_FONT_COLOR:Hinweis: Leerzeichen unmittelbar vor oder nach einem Komma werden ignoriert.|r",
	KEYWORDS_LIST_HELP_OOC_PARTS = "|cnGREEN_FONT_COLOR:<oocfirstname>|r - Dein Ingame-Vorname|n|cnGREEN_FONT_COLOR:<ooclastname>|r - Dein Ingame-Nachname|n",

	KEYWORDS_HIGHLIGHT_COLOR = "Hervorhebungsfarbe",
	KEYWORDS_HIGHLIGHT_COLOR_HELP = "Lege die Farbe fest, mit der Schlüsselwörter im Chat hervorgehoben werden.",

	KEYWORDS_ENABLE_PARTIAL_MATCHING = "Teilweise Übereinstimmung",
	KEYWORDS_ENABLE_PARTIAL_MATCHING_HELP = "Legt fest, ob Schlüsselwörter innerhalb größerer Wörter gefunden werden können.|n|nBeispiele:|n- Aktiviert: 'Zwilling' wird innerhalb von 'Zwillinge' hervorgehoben.|n- Deaktiviert: Nur das genaue Wort 'Zwilling' wird hervorgehoben.|n|n|cnWARNING_FONT_COLOR:Hinweis: Das kann zu 'falschen Positiven' führen (z. B. 'art' innerhalb von 'pARTy').|r",

	KEYWORDS_NOTIFICATIONS_HELP = "Nachrichten, die mit einem erkannten Schlüsselwort empfangen wurden.",

	-- Profiles Tab
	PROFILES_TITLE = "Profile",
	PROFILES_TITLE_HELP = "Speichere mehrere Konfigurationen und weise sie jeweils einem Charakter zu.",

	PROFILES_TRANSFER = "Importieren & Exportieren",
	PROFILES_TRANSFER_HELP = "Verschiebe Einstellungen als Textzeichenfolge in das Spiel hinein oder hinaus.",

	PROFILES_MANAGE = "Profile verwalten",
	PROFILES_MANAGE_HELP = "Verwalte deine Profile. Bewege den Mauszeiger über ein Profil, um weitere Optionen anzuzeigen.|n|n|cnWARNING_FONT_COLOR:Hinweis: Das 'Standard'-Profil kann nicht umbenannt oder gelöscht werden.|r",

	PROFILES_NEWPROFILE = "%s |cnPURE_GREEN_COLOR:Neues Profil|r",

	PROFILES_RESETBUTTON = "%s |cnNORMAL_FONT_COLOR:Aktives Profil zurücksetzen|r",
	PROFILES_RESETBUTTON_HELP = "Stellt alle Einstellungen im aktiven Profil auf ihre ursprünglichen Standardwerte zurück.",

	PROFILES_DELETEPROFILE = "Profil löschen",
	PROFILES_DELETEPROFILE_HELP = "Entfernt dieses Profil dauerhaft aus der Datenbank.|n|n- Jeder Charakter, der dieses Profil verwendet, wird auf 'Standard' zurückgesetzt.",

	PROFILES_OPTIONS = "Profiloptionen",
	PROFILES_OPTIONS_HELP = "Kopiere oder benenne dieses Profil um.",

	PROFILES_RENAMEPROFILE = "Profil umbenennen",
	PROFILES_RENAMEPROFILE_HELP = "Wähle einen neuen Namen für dieses Profil.|n|n- Wenn du das von dir verwendete Profil umbenennst, bleibst du auf ihm.",

	PROFILES_COPYPROFILE = "Profil kopieren",
	PROFILES_COPYPROFILE_HELP = "Erstellt ein neues Profil mit einer Kopie der Einstellungen dieses Profils und schaltet anschließend darauf um.",

	PROFILES_CONFIRM_RESET = "Bist du sicher, dass du das aktive Profil auf seine ursprünglichen Standardwerte zurücksetzen möchtest?",
	PROFILES_CONFIRM_DELETE = "Bist du sicher, dass du das Profil '%s' dauerhaft löschen möchtest?",
	PROFILES_CONFIRM_DELETE_CURRENT = "Bist du sicher, dass du das Profil '%s' dauerhaft löschen möchtest?|n|nAlle Charaktere, die dieses Profil als aktiv verwendet haben, werden auf 'Standard' zurückgesetzt.",

	PROFILES_IMPORTBUTTON = "Einstellungen importieren",
	PROFILES_IMPORTBUTTON_HELP = "Importiert ein Profil oder deine globalen Einstellungen aus einer teilbaren Textzeichenfolge.",

	PROFILES_EXPORTBUTTON = "Einstellungen exportieren",
	PROFILES_EXPORTBUTTON_HELP = "Exportiert das aktuelle Profil oder deine globalen Einstellungen in eine Textzeichenfolge, die du außerhalb des Spiels aufbewahren oder teilen kannst.|n|nJedes wird separat exportiert.",

	PROFILES_EXPORT_PROFILE = "Profil",
	PROFILES_EXPORT_GLOBAL = "Global",

	-- Import/Export Dialog
	IMPORTEXPORT_TITLE_EXPORT_PROFILE = "Profil exportieren",
	IMPORTEXPORT_TITLE_EXPORT_GLOBAL = "Globale Einstellungen exportieren",
	IMPORTEXPORT_TITLE_IMPORT = "Einstellungen importieren",

	IMPORTEXPORT_INSTRUCTIONS_EXPORT = "Drücke |cnGREEN_FONT_COLOR:Strg+C|r, um die Zeichenfolge unten zu kopieren, und füge sie dann an einer beliebigen Stelle ein, an der du sie aufbewahren oder teilen möchtest.",
	IMPORTEXPORT_INSTRUCTIONS_IMPORT = "Füge unten eine Profil- oder globale Einstellungszeichenfolge ein.",

	IMPORTEXPORT_DETECTED_PROFILE = "Das ist eine |cnGREEN_FONT_COLOR:Profil|r-Zeichenfolge. Wähle aus, in welches Profil sie importiert werden soll.",
	IMPORTEXPORT_DETECTED_GLOBAL = "Das ist eine |cnGREEN_FONT_COLOR:globale Einstellungs|r-Zeichenfolge. Beim Importieren werden Einstellungen für jeden Charakter und jedes Profil geändert.",

	IMPORTEXPORT_NAME_LABEL = "Importieren als",
	IMPORTEXPORT_NAME_LABEL_HELP = "Das Profil, in das die eingefügten Einstellungen importiert werden.|n|nDas wird automatisch aus der Zeichenfolge übernommen, aber du kannst es ändern, um unter einem anderen Namen zu importieren.",
	IMPORTEXPORT_OVERWRITE = "Überschreiben",
	IMPORTEXPORT_OVERWRITE_HELP = "Erlaubt es beim Importieren ein Profil zu ersetzen, das bereits diesen Namen verwendet.|n|n|cnWARNING_FONT_COLOR:Hinweis: Jede Einstellung in diesem Profil wird ersetzt.|r",
	IMPORTEXPORT_BUTTON_IMPORT = "Importieren",
	IMPORTEXPORT_VERSION_DEV = "Entwicklung",

	IMPORTEXPORT_CONFIRM_PROFILE = "Bist du sicher, dass du das Profil '%s' importieren möchtest?|n|nExportiert am |cnGREEN_FONT_COLOR:%s|r aus Version |cnGREEN_FONT_COLOR:%s|r.",
	IMPORTEXPORT_CONFIRM_OVERWRITE = "Bist du sicher, dass du das Profil '%s' überschreiben möchtest?|n|nExportiert am |cnGREEN_FONT_COLOR:%s|r aus Version |cnGREEN_FONT_COLOR:%s|r.|n|n|cnWARNING_FONT_COLOR:Hinweis: Jede Einstellung in diesem Profil wird ersetzt.|r",
	IMPORTEXPORT_CONFIRM_GLOBAL = "Bist du sicher, dass du diese globalen Einstellungen importieren möchtest?|n|nExportiert am |cnGREEN_FONT_COLOR:%s|r aus Version |cnGREEN_FONT_COLOR:%s|r.|n|n|cnWARNING_FONT_COLOR:Hinweis: Dies betrifft jeden Charakter und jedes Profil.|r",
	IMPORTEXPORT_CONFIRM_RELOAD = "Globale Einstellungen wurden importiert. Einige davon treten erst nach einem Reload in Kraft.|n|nInterface jetzt neu laden?",
	IMPORTEXPORT_CONFIRM_FLAVOR_DEFAULTS = "Dieses Profil wurde aus einer anderen Spielversion exportiert, die für einige Einstellungen andere Standardwerte verwendet.|n|nDiese Einstellungen auf die Standardwerte dieser Version umstellen?",

	IMPORTEXPORT_SUCCESS_PROFILE = "Das Profil '%s' wurde importiert und aktiviert.",
	IMPORTEXPORT_SUCCESS_PROFILE_SKIPPED = "Das Profil '%s' wurde importiert und aktiviert. |cnWARNING_FONT_COLOR:%d |4Einstellung:Einstellungen; konnte nicht gelesen werden und |4wurde:wurden; übersprungen.|r",
	IMPORTEXPORT_SUCCESS_GLOBAL = "Deine globalen Einstellungen wurden importiert.",
	IMPORTEXPORT_SUCCESS_GLOBAL_SKIPPED = "Deine globalen Einstellungen wurden importiert. |cnWARNING_FONT_COLOR:%d |4Einstellung:Einstellungen; konnte nicht gelesen werden und |4wurde:wurden; übersprungen.|r",

	IMPORTEXPORT_ERROR_NAME_EMPTY = "Gib einen Namen für das Profil ein, in das importiert werden soll.",
	IMPORTEXPORT_ERROR_NAME_TAKEN = "Ein Profil mit dem Namen '%s' existiert bereits. Wähle einen anderen Namen oder aktiviere 'Überschreiben'.",
	IMPORTEXPORT_ERROR_WRITE_FAILED = "Diese Zeichenfolge konnte nicht importiert werden.",
	IMPORTEXPORT_ERROR_EXPORT_FAILED = "Deine Einstellungen konnten nicht exportiert werden.",

	IMPORTEXPORT_ERROR_PEM_DECODE = "Das sieht nicht nach einer " .. title .. "-Zeichenfolge aus. Stelle sicher, dass du sie vollständig kopiert hast, inklusive der |cnGREEN_FONT_COLOR:-----BEGIN-----|r- und |cnGREEN_FONT_COLOR:-----END-----|r-Zeilen.",
	IMPORTEXPORT_ERROR_PEM_LABEL = title .. " erkennt diese Art von Zeichenfolge nicht. Sie könnte von einem anderen Addon oder einer neueren Version stammen.",
	IMPORTEXPORT_ERROR_DECOMPRESS = "Diese Zeichenfolge konnte nicht entpackt werden und ist höchstwahrscheinlich beschädigt oder unvollständig.",
	IMPORTEXPORT_ERROR_DESERIALIZE_CBOR = "Diese Zeichenfolge konnte nicht gelesen werden und ist höchstwahrscheinlich beschädigt.",
	IMPORTEXPORT_ERROR_PACKED_DATA_INVALID = "Diese Zeichenfolge ist fehlerhaft und kann nicht importiert werden.",
	IMPORTEXPORT_ERROR_SCHEMA_TOO_NEW = "Diese Zeichenfolge wurde von einer neueren Version von " .. title .. " erstellt und kann nicht gelesen werden. Aktualisiere das Addon und versuche es erneut.",

	-- Copy History Dialog
	COPY_HISTORY = "Verlauf kopieren",
	COPY_HISTORY_HELP = "Öffnet den Chatverlauf dieses Fensters als auswählbaren Text, den du kopieren kannst.",

	COPYHISTORY_TITLE = "Verlauf kopieren",
	COPYHISTORY_TIMESTAMP_FIXED = "Fest",
	COPYHISTORY_TIMESTAMP_RELATIVE = "Relativ",
	COPYHISTORY_TIMESTAMP_NONE = "Keine",
	COPYHISTORY_SELECT_ALL = "Alles auswählen",
	COPYHISTORY_FORMATTING_TITLE = "Formatierung",
	COPYHISTORY_TIMESTAMPS_TITLE = "Zeitstempel",
	COPYHISTORY_TIMESTAMPS_HELP = "Wähle aus, wie Zeitstempel beim Kopieren des Textes erscheinen.|n|n- Fest: Exakte Uhrzeit (z. B. 19:53:22).|n- Relativ: Wie lange her (z. B. 5m).|n- Keine: Keine Zeitstempel.",
	COPYHISTORY_SHOW_NAMES_TITLE = "Namen anzeigen",
	COPYHISTORY_SHOW_NAMES_HELP = "Wähle aus, ob Absendernamen in den kopierten Text aufgenommen werden sollen.|n|n- Fensterstandard: Nutzt das normale Verhalten dieses Fensters.|n- Immer an: Fügt immer Namen hinzu.|n- Immer aus: Fügt nie Namen hinzu.|n|n|cnWARNING_FONT_COLOR:Hinweis: Emotes und Würfe verwenden immer ihre eigenen Namensregeln.|r",
	COPYHISTORY_SHOW_NAMES_WINDOW_DEFAULT = "Fensterstandard",
	COPYHISTORY_SHOW_NAMES_ON = "Immer an",
	COPYHISTORY_SHOW_NAMES_OFF = "Immer aus",
	COPYHISTORY_NAME_DISPLAY_HELP = "Wähle aus, wie Namen im kopierten Text formatiert werden.|n|n- Profil-Einstellung folgen: Nutzt die Namensdarstellung des aktuellen Profils.|n- Vollständiger Name / Vorname / Originaler (OOC)-Name: Verwendet immer diese Variante.|n|n|cnWARNING_FONT_COLOR:Hinweis: RP-Namen benötigen ein kompatibles RP-Addon (TRP, MRP, XRP); ohne es wird der Ingame-Name verwendet.|r",

	ADDONINFO_BUILD = "|cnNORMAL_FONT_COLOR:Build:|r %s",
	ADDONINFO_BUILD_OUTDATED = title .. " ist für diesen Spielbuild nicht optimiert.|n|n|cnWARNING_FONT_COLOR:Dies kann zu unerwartetem Verhalten führen.|r",
	ADDONINFO_BUILD_CURRENT = title .. " ist für deinen aktuellen Spielbuild optimiert.|n|n|cnGREEN_FONT_COLOR:Alle Funktionen sollten wie erwartet funktionieren.|r",
	ADDONINFO_BLUESKY_SHILL_HELP = "Folge mir auf Bluesky!",

	-- About Tab
	ABOUT_TITLE = "Info",
	ADDONINFO_VERSION = "|cnNORMAL_FONT_COLOR:Version:|r %s",
	CLICK_TO_COPY = "|cnGREEN_FONT_COLOR:Klick: Link zum Kopieren öffnen|r",
	AUTHOR_COLON = "Autor: ",
	VISIT_ADDON_PAGE_TOOLTIP = "Besuche die Add-on-Seite auf %s.",
	PREVIEW_POST_TOOLTIP = "Zeige die Release-Vorschau auf %s an.",
	RUN_CLICKABLE_COMMAND = "|cnGREEN_FONT_COLOR:Klick: Klickbaren Befehl ausführen|r",

	UNIT_POPUPS_EAVESDROPPER_OPTIONS_HEADER = "Eavesdropper-Optionen",
	UNIT_POPUPS_EAVESDROP_ON = "Beobachten",
	UNIT_POPUPS_EAVESDROP_ON_HELP = "Öffnet ein separates Fenster für das aktuelle Ziel.|n|n|cnWARNING_FONT_COLOR:Hinweis: Deaktiviert, wenn das Ziel bereits ein separates Fenster hat.|r",
	UNIT_POPUPS_EAVESDROP_GROUP = "Gruppe beobachten",
	UNIT_POPUPS_EAVESDROP_GROUP_HELP = "Weist das aktuelle Ziel einer bestimmten Gruppenfenster zu oder entfernt es daraus.|n|n|cnWARNING_FONT_COLOR:Hinweis: |cnGREEN_FONT_COLOR:Grüne Gruppennamen|r zeigen an, dass das Ziel bereits Mitglied dieser Gruppe ist.|r",
	UNIT_POPUPS_EAVESDROP_GROUP_NEW = "Neu erstellen",
	UNIT_POPUPS_TOGGLE_MENTIONS_HELP = "Schaltet das Erwähnungsfenster um, das jede Nachricht auflistet, die auf dich gezielt war.|n|n- Erfasst Schlüsselworttreffer und Emotes, die auf dich gerichtet sind, auch solche, die du im Moment verpasst hast.",

	POPUP_EAVESDROP_GROUP = "Eavesdropper-Gruppenname.|nEnter zum Bestätigen.",
	POPUP_RESTORE_GROUP = "Eine Gruppe mit dem Namen \"%s\" mit %d Mitgliedern wurde in dieser Sitzung früher geschlossen.|n|nMitglieder wiederherstellen?",
	POPUP_RENAME_PROFILE = "Profil '%s' umbenennen.|nEnter zum Bestätigen.",
	POPUP_COPY_PROFILE = "Nenne das neue Profil, das von '%s' kopiert wurde.|nEnter zum Bestätigen.",
	POPUP_NEW_PROFILE = "Nenne das neue Profil.|nEnter zum Bestätigen.",

	-- Message Prefixes (keep them shorthand)
	MSG_PREFIX_PARTY = "P",
	MSG_PREFIX_RAID = "R",
	MSG_PREFIX_INSTANCE = "I",
	MSG_PREFIX_OFFICER = "O",
	MSG_PREFIX_GUILD = "G",
	MSG_PREFIX_CHANNEL = "C",
	MSG_PREFIX_RAID_WARNING = "RW",
	MSG_PREFIX_WHISPER_FROM = "W Von",
	MSG_PREFIX_WHISPER_TO = "W An",

	MSG_VERB_SAY = "sagt",
	MSG_VERB_YELL = "schreit",
	MSG_VERB_WHISPER = "flüstert",
};

BINDING_HEADER_ED = title;

---@class ED.L : ED.Locale.deDE, ED.Localization
ED.Localization = ED.LocalizationClass:New(L);
ED.Localization:RegisterNewLocale("deDE", "German", L);
