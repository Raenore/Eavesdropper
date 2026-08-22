-- Copyright The Eavesdropper Authors
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Traduction Daen

local title = C_AddOns.GetAddOnMetadata("Eavesdropper", "Title");
local L;

L = {
	WELCOMEMSG_VERSION = "Écoute avec le profil |cnGREEN_FONT_COLOR:%s|r (|cnGOLD_FONT_COLOR:%s|r)!",
	WELCOMEMSG_SETTINGS = "|cnGREEN_FONT_COLOR:/ed|r %s & |cnGREEN_FONT_COLOR:/ed help|r %s",

	SLASH_COMMAND_HEADER = "Liste des commandes (cliquables & textuelles) :",
	SLASH_COMMAND_ED = "Afficher/Masquer les options, Eavesdropper s'affiche pendant la configuration",
	SLASH_COMMAND_ED_SHOW = "Afficher Eavesdropper",
	SLASH_COMMAND_ED_HIDE = "Masquer Eavesdropper",
	SLASH_COMMAND_ED_TOGGLE = "Afficher/Masquer Eavesdropper",
	SLASH_COMMAND_ED_SETTINGS = "Afficher/Masquer les options",
	SLASH_COMMAND_ED_HELP = "Liste des commandes",
	SLASH_COMMAND_ED_MENTIONS = "Afficher/Masquer les mentions",

	BINDING_NAME_ED_TOGGLE = "Afficher/Masquer Eavesdropper",
	BINDING_NAME_ED_SETTINGS = "Afficher/Masquer les options",
	BINDING_NAME_ED_EAVESDROP_ON = "Écouter la cible (Fenêtre de suivi individuel)",

	ADDON_TOOLTIP_HELP = "|cnGREEN_FONT_COLOR:Clic gauche : Ouvrir les options|nClic droit : Ouvrir les profils|nShift-Click : Afficher/Masquer Eavesdropper|r",
	POPUP_LINK = "|n|nAppuyez sur |cnGREEN_FONT_COLOR:CTRL-C|r pour copier le texte sélectionné, puis collez-le dans votre navigateur avec |cnGREEN_FONT_COLOR:CTRL-V|r.",
	POPUP_COPY_NAME = "|n|nAppuyez sur |cnGREEN_FONT_COLOR:CTRL-C|r pour copier le nom de personnage sélectionné.",
	COPY_SYSTEM_MESSAGE = "Copié dans le presse-papiers.",
	GLOBAL_SETTING_TOOLTIP = "|cnLIGHTBLUE_FONT_COLOR:|n|n* Option commune à tous les profils.|r",

	FILTER = "Filtres",
	FILTER_HELP = "Sélectionne les types de messages visibles dans Eavesdropper.|n|n- Activer ou désactiver un filtre modifie uniquement l'affichage actuel.|n- Aucune donnée n'est supprimée ; les messages masqués s'afficheront à nouveau si le filtre est réactivé.|n|n|cnWARNING_FONT_COLOR:Note : les filtres s'appliquent immédiatement.|r",

	MENTIONS_REASON_FILTER = "Types de mentions",
	MENTIONS_REASON_FILTER_HELP = "Sélection des mentions visibles dans cette fenêtre.|n|n- Afficher ou masquer un type ne modifie que l'affichage actuel.|n- Aucune donnée n'est supprimée ; les mentions masquées réapparaîtront si réactivées.|n|n|cnWARNING_FONT_COLOR:Note : le filtre des mentions s'appliquent immédiatement.|r",
	MENTIONS_REASON_KEYWORD = "Mots-clés",
	MENTIONS_REASON_EMOTE = "Émotes Blizzard",

	EMPTYLABEL_TEXT = "Groupe vide",
	MENTIONS_EMPTYLABEL_TEXT = "Aucune mention",
	MENTIONS_WINDOW_TITLE = "Mentions",
	MENTIONS_HELP = "Fenêtre indépendante regroupant l'ensemble des messages qui vous ciblent, extraits des correspondances de mots-clés et des émotes Blizzard.",
	MENTIONS_ENABLE_HELP = "Active la fenêtre des mentions ainsi que le système de détection qui l'alimente.|n|n|cnWARNING_FONT_COLOR:Note : désactiver ce paramètre interrompt l'enregistrement des nouvelles mentions et masque la fenêtre si elle est ouverte.|r",
	MENTIONS_HISTORY_SIZE = "Taille de l'historique",
	MENTIONS_HISTORY_SIZE_HELP = "Définit le nombre maximum de mentions conservées dans cette fenêtre.|n|n|cnWARNING_FONT_COLOR:Note : les mentions étant assez rares, cette limite n'a guère d'impact, sauf lors de sessions intenses ou si vos mots-clés sont trop génériques.|r",
	SCROLLMARKER_TEXT = "Défiler jusqu'en bas",

	FILTER_PUBLIC = "Public",
	FILTER_PARTY = "Groupe",
	FILTER_RAID = "Raid",
	FILTER_RAID_WARNING = "Avertissement Raid",
	FILTER_INSTANCE = "Instance",
	FILTER_GUILD = "Guilde",
	FILTER_GUILD_OFFICER = "Officier",
	FILTER_WHISPER = "Chuchotements",
	FILTER_ROLLS = "Rolls",

	WINDOW_OPTIONS = "Options de la fenêtre",
	ENABLE_MOUSE = "Activer la souris",
	ENABLE_MOUSE_HELP = "Détermine si vous pouvez interagir avec la fenêtre d'Eavesdropper avec la souris.|n|n- Activée : Permet de cliquer sur les liens d'objets et les URLs dans l'historique.|n- Désactivée : Les clics traversent la fenêtre, évitant toute interaction accidentelle.",
	LOCK_SCROLL = "Verrouiller le défilement",
	LOCK_SCROLL_HELP = "Désactive le défilement dans l'historique des messages.|n|n- Utilisez cette option pour vous assurer qu'Eavesdropper reste toujours en bas de la liste afin d'afficher les derniers messages.",
	LOCK_WINDOW = "Verrouiller la fenêtre",
	LOCK_WINDOW_HELP = "Empêche Eavesdropper d'être déplacé ou redimensionné.|n|n- Cochez cette option une fois la fenêtre positionnée pour éviter tout glissement involontaire en jeu.",
	LOCK_TITLEBAR = "Verrouiller la barre de titre",
	LOCK_TITLEBAR_HELP = "Active la barre de titre de la fenêtre.|n|n- Activée : La barre de titre reste visible en permanence.|n- Désactivée : La barre de titre est masquée et n'apparaît que lorsque vous survolez la fenêtre avec la souris.|n|nNote : vous pouvez activer 'Nom de la cible en barre de titre' dans les options pour remplacer 'Eavesdropper' par le nom de votre cible actuelle.",

	DEDICATED_OPTIONS = "Options des fenêtres individuelles",
	MENTIONS_OPTIONS = "Options des mentions",

	-- Category Titles
	APPEARANCE_TITLE = "Apparences",

	-- General Tab
	GENERAL_TITLE = "Général",
	TARGETING = "Ciblage",
	TARGETING_PRIORITY_MOUSEOVER = "Survol",
	TARGETING_PRIORITY_TARGET = "Cible",
	TARGETING_PRIORITY_FOCUS = "Focus",

	TARGET_PRIORITY = "Priorité",
	TARGET_PRIORITY_HELP = "Détermine l'historique prioritaire affiché par Eavesdropper lorsque vous avez simultanément une cible et une unité survolée.|n|n- Priorité : choix du type d'unité prioritaire.|n- Exclusif : affichage limité à un seul type d'unité (désactive la focalisation).",
	TARGET_PRIORITY_PRIORITIZE_MOUSEOVER = "Survol en priorité",
	TARGET_PRIORITY_PRIORITIZE_TARGET = "Cible en priorité",
	TARGET_PRIORITY_MOUSEOVER_ONLY = "Survol exclusivement",
	TARGET_PRIORITY_TARGET_ONLY = "Cible exclusivement",
	TARGET_PRIORITY_FOCUS_ONLY = "Focus exclusivement",

	FOCUS = "Focus",
	FOCUS_HELP = "Détermine la gestion de votre focus par Eavesdropper.|n|n- Remplacer : Donne la priorité à votre focus sur toutes les autres unités.|n- Secondaire : Affiche exclusivement votre focus lorsqu'il n'y a ni cible actuelle ni unité survolée.|n- Ignorer : Exclut totalement les focus de l'affichage.|n|n|cnWARNING_FONT_COLOR:Note : cette option est désactivée si votre Priorité est réglée sur l'option 'Exclusif'.|r",
	FOCUS_OVERRIDE = "Remplacer",
	FOCUS_FALLBACK = "Secondaire",
	FOCUS_IGNORE = IGNORE,

	INCLUDE_COMPANIONS = "Inclure les Familiers",
	INCLUDE_COMPANIONS_HELP = "Affiche l'historique du propriétaire lorsque vous ciblez ou survolez ses mascottes et familiers.|n|n- Si activée, Eavesdropper utilise les familiers comme passerelle vers les données du propriétaire.|n- Si désactivée, Eavesdropper les ignore totalement.",

	MESSAGES = "Messages",
	MESSAGES_HELP = "Ces options ne s'appliquent qu'à l'historique d'Eavesdropper.",

	HISTORY_SIZE = "Taille de l'historique",
	HISTORY_SIZE_HELP = "Définit le nombre maximum de messages à afficher dans l'historique pour chaque unité.|n|n|cnWARNING_FONT_COLOR:Note : des valeurs élevées peuvent provoquer une baisse temporaire des images par seconde lors de la mise à jour de la fenêtre.|r",

	NAME_DISPLAY_MODE = "Affichage des noms",
	NAME_DISPLAY_MODE_HELP = "Détermine le formatage des noms de personnages dans Eavesdropper.|n|n|cnWARNING_FONT_COLOR:Note : cette option est désactivée et bascule par défaut sur 'Nom original (HRP)' lorsqu'aucun addon RP compatible (TRP, MRP, XRP) n'est chargé.|r",
	NAME_DISPLAY_MODE_FULL_NAME = "Nom complet",
	NAME_DISPLAY_MODE_FIRST_NAME = "Prénom",
	NAME_DISPLAY_MODE_ORIGINAL_NAME = "Nom original (HRP)",
	NAME_DISPLAY_MODE_FOLLOW_PROFILE = "Utiliser les options du profil actif",

	USE_RP_NAME_COLOR = "Couleurs des noms",
	USE_RP_NAME_COLOR_HELP = "Colore les noms en fonction de leurs paramètres RP personnalisés (ex. depuis TRP3).|n|n- Si aucune couleur RP n'est détectée, Eavesdropper utilise la couleur de classe Blizzard par défaut.",

	USE_RP_NAME_IN_ROLLS = "Noms pour les rolls",
	USE_RP_NAME_IN_ROLLS_HELP = "Détermine si les résultats des rolls aléatoires (/roll) utilisent le nom RP ou le nom HRP.",

	USE_RP_NAME_FOR_TARGETS = "Noms des cibles d'émotes",
	USE_RP_NAME_FOR_TARGETS_HELP = "Détermine si la cible d'une émote Blizzard (ex. /signe, /montrer) utilise le nom RP ou le nom HRP.|n|n|cnWARNING_FONT_COLOR:Note : en raison de la structure des émotes de Blizzard, le remplacement peut parfois échouer.|r",

	NPC_DIALOGUE_AND_QUEST_TEXT = "Dialogues de PNJ & textes de quête",
	NPC_DIALOGUE_AND_QUEST_TEXT_HELP = "Choisit comment le nom de votre personnage est affiché.",

	NPC_AND_QUEST_NAME_DISPLAY = "Affichage du nom (PNJ & quêtes)",
	NPC_AND_QUEST_NAME_DISPLAY_HELP = "Choisit le formatage du nom de votre personnage dans les dialogues de PNJ et les textes de quête.|n|n|cnWARNING_FONT_COLOR:Note : utilise par défaut 'Nom original (HRP)' si aucun addon RP compatible (TRP, MRP ou XRP) n'est détecté.|r",

	USE_RP_NAME_FOR_QUEST_TEXT = "Configuration du texte de quête",
	USE_RP_NAME_FOR_QUEST_TEXT_HELP = "Active l'utilisation du format d'affichage choisi dans 'Affichage du nom (PNJ et quêtes)' pour les textes de quête, au lieu de votre nom HRP.|n|n|cnWARNING_FONT_COLOR:Note : nécessite un addon d'interaction compatible (ex. Dialogue UI) actif.|r",

	USE_RP_NAME_FOR_NPC_DIALOGUE = "Configuration du dialogue des PNJ",
	USE_RP_NAME_FOR_NPC_DIALOGUE_HELP = "Active l'utilisation du format d'affichage choisi dans 'Affichage du nom (PNJ et quêtes)' pour les dialogues de PNJ (Dire, Emote, etc.), au lieu de votre nom HRP.|n|nLes bulles de discussion afficheront toujours votre nom HRP, car Eavesdropper ne les modifie pas (pour l'instant).|n|n|cnWARNING_FONT_COLOR:Note : ce paramètre est désactivé (et n'aura aucun effet) si l'extension 'Total RP 3: RP Name in Quest Text' est installé et configuré pour modifier l'option 'NPC Speech', afin d'éviter tout conflit.|r",

	TIMESTAMP_BRACKETS = "Crochets des horodatages",
	TIMESTAMP_BRACKETS_HELP = "Active l'affichage des crochets autour des horodatages de message (ex. [5m] vs 5m).",

	ADV_FORMATTING = "Mise en forme av.",
	ADVANCED_FORMATTING = "Mise en forme avancée",
	ADVANCED_FORMATTING_HELP = "Gestion de la mise en forme du nom RP dans les messages système, les émotes et les interactions avec les PNJ.",

	MAIN_CHAT = "Discussion principale",
	MAIN_CHAT_HELP = "Gestion de la mise en forme avancée dans la fenêtre de discussion principale de Blizzard.",

	APPLY_ON_MAIN_CHAT = "Appliquer à la discussion principale",
	APPLY_ON_MAIN_CHAT_HELP = "Active l'application de la mise en forme avancée à la fenêtre de discussion principale de Blizzard en plus de la fenêtre d'historique d'Eavesdropper.|n|n|cnWARNING_FONT_COLOR:Note : cela n'est pas rétroactif. Si les données RP requises ne sont pas disponibles lors de la réception d'un message, les noms HRP seront affichés.|r",

	OVERRIDE_NAME_DISPLAY = "Remplacer l'affichage des noms",
	OVERRIDE_NAME_DISPLAY_HELP = "Active l'utilisation par la mise en forme avancée dans la fenêtre de discussion principale de Blizzard de son propre format de nom au lieu de votre paramètre 'Affichage des noms'.",

	ADV_FORMATTING_NAME_DISPLAY = "Affichage des noms (Mise en forme av.)",
	ADV_FORMATTING_NAME_DISPLAY_HELP = "Choisit comment les noms de personnage sont affichés par la mise en forme avancée dans la fenêtre de discussion principale de Blizzard.|n|n|cnWARNING_FONT_COLOR:Note : cette option s'applique uniquement lorsque 'Remplacer l'affichage des noms' est activé, et utilise par défaut 'Nom original (HRP)' lorsqu'aucun addon RP approprié (TRP, MRP, XRP) n'est chargé.|r",

	DISPLAY = "Affichage",
	DISPLAY_HELP = "Configuration du style visuel et des thèmes de couleur d'Eavesdropper.",
	THEMES_BACKGROUND_COLOR = "Couleur de fond",
	THEMES_BACKGROUND_COLOR_HELP = "Ajuste la couleur et la transparence d'Eavesdropper.|n|n- Utilisez le curseur du sélecteur de couleurs pour régler l'opacité du fond.",
	THEMES_TITLEBAR_COLOR = "Couleur de la barre de titre",
	THEMES_TITLEBAR_COLOR_HELP = "Définit la couleur de fond et l'opacité de la barre de titre.|n|n- La barre de titre est généralement visible lorsque vous survolez Eavesdropper.",
	THEMES_SETTINGS_ELVUI = "Thème ElvUI",
	THEMES_SETTINGS_ELVUI_HELP = "Active l'utilisation de l'apparence d'ElvUI ou de l'apparence par défaut pour la fenêtre des options d'Eavesdropper.|n|n|cnWARNING_FONT_COLOR:Note : modifier cette option déclenchera un rechargement de l'interface.|r",
	THEMES_SETTINGS_ELVUI_CONFIRM = "Êtes-vous sûr de vouloir modifier l'option du thème ElvUI ?|n|n|cnWARNING_FONT_COLOR:Cela déclenchera un rechargement de l'interface.|r",

	HIDE_CLOSE_BUTTON = "Masquer le bouton de fermeture",
	HIDE_CLOSE_BUTTON_HELP = "Masque le bouton de fermeture sur la fenêtre d'Eavesdropper.|n|n- Si masqué, vous pouvez toujours contrôler la fenêtre avec |cnGREEN_FONT_COLOR:/ed show|r ou |cnGREEN_FONT_COLOR:/ed hide|r.",
	HIDE_IN_COMBAT = "Masquer en combat",
	HIDE_IN_COMBAT_HELP = "Masque automatiquement Eavesdropper en combat.|n|n|cnWARNING_FONT_COLOR:Note : certains combats ou instances peuvent limiter la réception des messages indépendamment de cette option.|r",
	HIDE_WHEN_EMPTY = "Masquer quand la fenêtre est vide",
	HIDE_WHEN_EMPTY_HELP = "Masque automatiquement Eavesdropper lorsqu'il n'y a aucun message à afficher.|n|n- La fenêtre réapparaîtra dès qu'un nouveau message sera reçu.|n|n|cnWARNING_FONT_COLOR:Note : prend effet dès la fermeture de la fenêtre des options.|r",

	TITLE_BAR_TARGET_NAME = "Nom de la cible dans la barre de titre",
	TITLE_BAR_TARGET_NAME_HELP = "Remplace l'intitulé 'Eavesdropper' dans la barre de titre par le nom de votre cible actuelle. Cela fournit une confirmation visuelle rapide du personnage dont vous consultez l'historique.",

	WELCOME_MSG = "Message de démarrage",
	WELCOME_MSG_HELP = "Active l'affichage du message de démarrage.",

	FONT = "Police",
	FONT_HELP = "Personnalisation de la police d'Eavesdropper.",

	FONT_FACE = "Police d'écriture",
	FONT_FACE_HELP = "Choisit la police d'écriture utilisée pour l'ensemble des textes d'Eavesdropper.|n|nNote : les polices provenant d'autres addons utilisant LibSharedMedia apparaîtront également dans cette liste.",

	FONT_SIZE = "Taille de la police",
	FONT_SIZE_HELP = "Ajuste la taille des messages affichés dans la fenêtre d'historique.|n|n- Vous pouvez également maintenir |cnGREEN_FONT_COLOR:Ctrl + Mouse Wheel Up/Down|r en survolant Eavesdropper pour modifier la taille directement.",

	FONT_OUTLINE = "Contour de la police",
	FONT_OUTLINE_HELP = "Applique une bordure au texte pour améliorer la lisibilité sur les fonds chargés.",
	FONT_OUTLINE_NONE = "Aucun",
	FONT_OUTLINE_THIN = "Fin",
	FONT_OUTLINE_THICK = "Épais",

	FONT_SHADOW = "Ombre de la police",
	FONT_SHADOW_HELP = "Active une légère ombre portée sous le texte pour ajouter de la profondeur et du contraste.",

	MINIMAP = "Minicarte",

	DEDICATED_WINDOWS = "Fenêtres individuelles",
	DEDICATED_WINDOWS_HELP = "Autorise la création de fenêtres séparées et indépendantes dédiées au suivi individuel d'unités spécifiques.|n|n|cnWARNING_FONT_COLOR:Note : désactiver ce paramètre fermera toutes les fenêtres de suivi individuel.|r",

	NEW_WINDOWS_UNIT_POPUPS = "Menu d'accès rapide",
	NEW_WINDOWS_UNIT_POPUPS_HELP = "Ajoute des options 'Eavesdropper' aux menus contextuels standards (clic droit) des portraits d'unités (Joueur, Cible, Groupe, etc.) et des noms dans la discussion.|n|n- Autorise l'ouverture rapide d'une fenêtre pour un personnage spécifique.",

	NEW_WINDOWS_NEW_INDICATOR = "Indicateur de nouveau message",
	NEW_WINDOWS_NEW_INDICATOR_HELP = "Affiche une alerte visuelle dans la fenêtre qui reçoit un nouveau message.|n|n- L'alerte disparaît automatiquement après 10 secondes ou immédiatement au survol de la fenêtre.",

	JUMP_TO_CONTEXT = "Voir le contexte",
	JUMP_TO_CONTEXT_HELP = "Ajoute une icône cliquable |TInterface\\AddOns\\Eavesdropper\\Resources\\Jump.png:0:0:0:1:32:32:0:32:0:32:204:204:204|t au début de chaque message. Cliquer dessus ouvre (ou ramène au premier plan) la fenêtre individuelle de l'émetteur, directement à la ligne correspondante.|n|n|cnWARNING_FONT_COLOR:Note : nécessite l'activation des 'Fenêtres individuelles'.|r",
	JUMP_TO_CONTEXT_TOOLTIP = "|cnGREEN_FONT_COLOR:Clic : Revenir à ce message dans la fenêtre individuelle de %s|r",

	GROUP_WINDOWS = "Fenêtres de groupe",
	GROUP_WINDOWS_HELP = "Autorise la création de fenêtres séparées et indépendantes dédiées au suivi simultané de plusieurs utilisateurs (ex. : MP ou Amis).|n|n|cnWARNING_FONT_COLOR:Note : désactiver cette option fermera toutes les fenêtres de groupes.|r",

	GROUP_HISTORY_SIZE = "Taille de l'historique",
	GROUP_HISTORY_SIZE_HELP = "Définit le nombre maximum de messages affichés dans l'historique pour chaque fenêtre de groupe, tous joueurs suivis confondus.|n|n|cnWARNING_FONT_COLOR:Note : une valeur élevée sur une fenêtre regroupant de nombreux joueurs peut engendrer une baisse temporaire des images par seconde lors de l'actualisation de l'historique.|r",

	GROUP_OPTIONS = "Options du groupe",
	GROUP_RENAME = "Changer le nom du groupe",

	PLAYER_LIST = "Liste des joueurs",
	PLAYER_LIST_HELP = "Affiche l'ensemble des joueurs suivis par cette fenêtre de groupe.",
	PLAYER_LIST_ADD_TARGET = "Ajouter la cible",
	PLAYER_LIST_ADD_TARGET_HELP = "Ajoute votre cible actuelle à ce groupe.|n|n|cnWARNING_FONT_COLOR:Note : indisponible en l'absence de cible, si votre cible n'est pas un joueur, ou s'il est déjà dans ce groupe.|r",
	PLAYER_LIST_EMPTY = "Aucun joueur suivi",
	PLAYER_LIST_ROW_HELP = "Décochez pour retirer ce joueur du groupe ; cochez à nouveau pour l'y réintégrer.|n|n|cnWARNING_FONT_COLOR:Note : cette liste s'actualise uniquement après avoir fermé puis rouvert le menu.|r",
	PLAYER_LIST_OPEN_DEDICATED = "Ouvrir une fenêtre individuelle",
	PLAYER_LIST_OPEN_DEDICATED_HELP = "Ouvre une fenêtre de suivi individuel dédiée à ce joueur.|n|n|cnWARNING_FONT_COLOR:Note : aucun effet si ce joueur en a déjà une ouverte.|r",

	MINIMAP_BUTTON = "Bouton de la minicarte",
	MINIMAP_BUTTON_HELP = "Active l'affichage du bouton de la minicarte.",

	ADDON_COMPARTMENT_BUTTON = "Compartiment des addons",
	ADDON_COMPARTMENT_BUTTON_HELP = "Active l'affichage du bouton du compartiment des addons.",

	-- Notifications Tab
	NOTIFICATIONS_TITLE = "Notifications",

	EMOTES = "Émotes",
	EMOTES_HELP = "Si un joueur effectue une émote sur votre personnage (ex. : /pointer, /rire).",

	TARGET = "Cible",
	TARGET_HELP = "Messages provenant de votre cible actuelle.",

	DEDICATED = "Individus",
	DEDICATED_HELP = "Ouvre des fenêtres séparées et indépendantes dédiées au suivi individuel d'unités spécifiques.",
	DEDICATED_NOTIFICATIONS_HELP = "Messages reçus dans les fenêtres de suivi individuel.",

	GROUPS = "Groupes",
	GROUP_HELP = "Ouvre des fenêtres séparées et indépendantes dédiées au suivi simultané de plusieurs utilisateurs (ex. : MP ou Amis).",
	GROUP_NOTIFICATIONS_HELP = "Messages reçus dans les fenêtres de groupes.",

	NOTIFICATIONS_PLAY_SOUND = "Jouer un son",
	NOTIFICATIONS_PLAY_SOUND_HELP = "Active l'usage d'un signal sonore pour ce type de notification.",

	NOTIFICATIONS_SOUND_FILE = "Fichier sonore",
	NOTIFICATIONS_SOUND_FILE_HELP = "Choisissez le fichier sonore joué pour ce type de notification.|n|n|cnWARNING_FONT_COLOR:Note : les sons provenant d'autres addons utilisant LibSharedMedia apparaîtront également dans cette liste.|r",

	NOTIFICATION_FLASH_TASKBAR = "Clignotement de la barre des tâches",
	NOTIFICATION_FLASH_TASKBAR_HELP = "Active le clignotement de l'icône du jeu dans la barre des tâches à la réception de ce type de notification lorsque le jeu est réduit.",

	-- Keywords Tab
	KEYWORDS_TITLE = "Mots-clés",

	KEYWORDS_HELP = "Mise en surbrillance des mots ou phrases spécifiques qui apparaissent dans la discussion.",

	KEYWORDS_ENABLE = "Activation",
	KEYWORDS_ENABLE_HELP = "Active la mise en surbrillance des mots-clés pour Eavesdropper.|n|n|cnWARNING_FONT_COLOR:Note : les listes de mots-clés sont sauvegardées par profil et non par personnage.|r",

	KEYWORDS_LIST = "Liste des mots-clés",
	KEYWORDS_LIST_HELP = "Saisissez des mots ou phrases à mettre en surbrillance dans l'historique de discussion.|n|nBalises spéciales :|n|cnGREEN_FONT_COLOR:<firstname>|r - Votre prénom RP|n|cnGREEN_FONT_COLOR:<lastname>|r - Votre nom de famille RP|n|cnGREEN_FONT_COLOR:<oocname>|r - Votre nom HRP|n|cnGREEN_FONT_COLOR:<class>|r - Votre classe RP (utilise par défaut la classe en jeu)|n|cnGREEN_FONT_COLOR:<race>|r - Votre race RP (utilise par défaut la race en jeu)|n|nMise en forme :|n- Séparez les entrées par des virgules.|n- Elles ne tiennent pas compte de la casse (ex. : 'Héros' correspond à 'héros').|n- Les espaces au sein d'une phrase sont conservés.|n|n|cnWARNING_FONT_COLOR:Note : les espaces immédiatement situés avant ou après une virgule sont ignorés.|r",

	KEYWORDS_HIGHLIGHT_COLOR = "Couleur de surbrillance",
	KEYWORDS_HIGHLIGHT_COLOR_HELP = "Définit la couleur utilisée pour les mots-clés mis en surbrillance dans la discussion.",

	KEYWORDS_ENABLE_PARTIAL_MATCHING = "Correspondance partielle",
	KEYWORDS_ENABLE_PARTIAL_MATCHING_HELP = "Active la recherche de mots-clés au sein de mots plus longs.|n|nExemples :|n- Activée : 'Jumeau' sera mis en surbrillance dans 'Jumeaux'.|n- Désactivée : Seul le mot exact 'Jumeau' sera mis en surbrillance.|n|n|cnWARNING_FONT_COLOR:Note : cela peut provoquer de 'faux positifs' (ex. : 'art' mis en surbrillance dans 'pARTie').|r",

	KEYWORDS_NOTIFICATIONS_HELP = "Messages reçus contenant un mot-clé détecté.",

	-- Profiles Tab
	PROFILES_TITLE = "Profils",
	PROFILES_TITLE_HELP = "Enregistre plusieurs configurations et en attribue une à chaque personnage.",

	PROFILES_TRANSFER = "Import & Export",
	PROFILES_TRANSFER_HELP = "Transfère des configurations vers ou depuis le jeu sous forme de chaîne de texte.",

	PROFILES_MANAGE = "Gestion des profils",
	PROFILES_MANAGE_HELP = "Organisez vos profils. Survolez n'importe quel profil pour afficher plus d'options.|n|n|cnWARNING_FONT_COLOR:Note : le profil 'Par défaut' ne peut être ni renommé ni supprimé.|r",

	PROFILES_NEWPROFILE = "%s |cnPURE_GREEN_COLOR:Nouveau Profil|r",

	PROFILES_RESETBUTTON = "%s |cnNORMAL_FONT_COLOR:Réinitialiser le profil actif|r",
	PROFILES_RESETBUTTON_HELP = "Réinitialise l'ensemble des paramètres du profil actif pour revenir à la configuration par défaut.",

	PROFILES_DELETEPROFILE = "Supprimer le profil",
	PROFILES_DELETEPROFILE_HELP = "Supprime définitivement ce profil de la base de données.|n|n- Tout personnage l'utilisant basculera sur le profil 'Par défaut'.|r",

	PROFILES_OPTIONS = "Options du profil",
	PROFILES_OPTIONS_HELP = "Copier ou renommer ce profil.",

	PROFILES_RENAMEPROFILE = "Renommer le profil",
	PROFILES_RENAMEPROFILE_HELP = "Choisissez un nouveau nom pour ce profil.|n|n- Renommer le profil en cours d'utilisation le conserve actif.",

	PROFILES_COPYPROFILE = "Copier le profil",
	PROFILES_COPYPROFILE_HELP = "Crée un nouveau profil contenant une copie des paramètres de celui-ci, puis bascule dessus.",

	PROFILES_CONFIRM_RESET = "Êtes-vous sûr de vouloir réinitialiser le profil actif pour revenir à la configuration par défaut ?",
	PROFILES_CONFIRM_DELETE = "Êtes-vous sûr de vouloir supprimer définitivement le profil '%s' ?",
	PROFILES_CONFIRM_DELETE_CURRENT = "Êtes-vous sûr de vouloir supprimer définitivement le profil '%s' ?|n|nTous les personnages l'utilisant basculeront sur le profil 'Par défaut'.",

	PROFILES_IMPORTBUTTON = "Importer les paramètres",
	PROFILES_IMPORTBUTTON_HELP = "Importe un profil ou vos options communes à tous à partir d'une chaîne de texte partagée.",

	PROFILES_EXPORTBUTTON = "Exporter les paramètres",
	PROFILES_EXPORTBUTTON_HELP = "Exporte le profil actuel ou vos options communes à tous vers une chaîne de texte à conserver ou partager hors du jeu.|n|nChaque élément est exporté séparément.",

	PROFILES_EXPORT_PROFILE = "Profil",
	PROFILES_EXPORT_GLOBAL = "Options communes",

	-- Import/Export Dialog
	IMPORTEXPORT_TITLE_EXPORT_PROFILE = "Exporter un profil",
	IMPORTEXPORT_TITLE_EXPORT_GLOBAL = "Exporter les options communes",
	IMPORTEXPORT_TITLE_IMPORT = "Importer les paramètres",

	IMPORTEXPORT_INSTRUCTIONS_EXPORT = "Appuyez sur |cnGREEN_FONT_COLOR:Ctrl+C|r pour copier la chaîne ci-dessous, puis collez-la où vous souhaitez la conserver ou la partager.",
	IMPORTEXPORT_INSTRUCTIONS_IMPORT = "Collez ci-dessous une chaîne de profil ou d'options communes.",

	IMPORTEXPORT_DETECTED_PROFILE = "Il s'agit d'une chaîne de |cnGREEN_FONT_COLOR:profil|r. Choisissez le profil dans lequel l'importer.",
	IMPORTEXPORT_DETECTED_GLOBAL = "Il s'agit d'une chaîne d'|cnGREEN_FONT_COLOR:options communes|r. L'importer modifiera les options de tous les personnages et profils.",

	IMPORTEXPORT_NAME_LABEL = "Importer sous",
	IMPORTEXPORT_NAME_LABEL_HELP = "Profil destinataire de ces paramètres importés.|n|nCe champ est prérempli automatiquement, mais vous pouvez le modifier pour importer sous un autre nom.",
	IMPORTEXPORT_OVERWRITE = "Remplacer",
	IMPORTEXPORT_OVERWRITE_HELP = "Autorise l'importation à remplacer un profil existant du même nom.|n|n|cnWARNING_FONT_COLOR:Note : tous les paramètres de ce profil seront remplacés.|r",
	IMPORTEXPORT_BUTTON_IMPORT = "Importer",
	IMPORTEXPORT_VERSION_DEV = "Dév",

	IMPORTEXPORT_CONFIRM_PROFILE = "Êtes-vous sûr de vouloir importer le profil '%s' ?|n|nExporté |cnGREEN_FONT_COLOR:%s|r depuis la version |cnGREEN_FONT_COLOR:%s|r.",
	IMPORTEXPORT_CONFIRM_OVERWRITE = "Êtes-vous sûr de vouloir écraser le profil '%s' ?|n|nExporté |cnGREEN_FONT_COLOR:%s|r depuis la version |cnGREEN_FONT_COLOR:%s|r.|n|n|cnWARNING_FONT_COLOR:Note : tous les paramètres de ce profil seront remplacés.|r",
	IMPORTEXPORT_CONFIRM_GLOBAL = "Êtes-vous sûr de vouloir importer ces options communes ?|n|nExporté |cnGREEN_FONT_COLOR:%s|r depuis la version |cnGREEN_FONT_COLOR:%s|r.|n|n|cnWARNING_FONT_COLOR:Note : cela affectera l'ensemble des personnages et des profils.|r",
	IMPORTEXPORT_CONFIRM_RELOAD = "Les options communes ont été importées. Certaines ne prennent effet qu'après un rechargement.|n|nRecharger votre interface maintenant ?",

	IMPORTEXPORT_SUCCESS_PROFILE = "Le profil '%s' a été importé et activé.",
	IMPORTEXPORT_SUCCESS_PROFILE_SKIPPED = "Le profil '%s' a été importé et activé. |cnWARNING_FONT_COLOR:%d |4paramètre:paramètres; n'|4a:ont; pas pu être |4lu:lus; et |4a:ont; été |4ignoré:ignorés;.|r",
	IMPORTEXPORT_SUCCESS_GLOBAL = "Vos options communes ont été importées.",
	IMPORTEXPORT_SUCCESS_GLOBAL_SKIPPED = "Vos options communes ont été importées. |cnWARNING_FONT_COLOR:%d |4paramètre:paramètres; n'|4a:ont; pas pu être |4lu:lus; et |4a:ont; été |4ignoré:ignorés;.|r",

	IMPORTEXPORT_ERROR_NAME_EMPTY = "Saisissez un nom pour le profil destinataire.",
	IMPORTEXPORT_ERROR_NAME_TAKEN = "Un profil nommé '%s' existe déjà. Choisissez un autre nom ou activez 'Remplacer'.",
	IMPORTEXPORT_ERROR_WRITE_FAILED = "Impossible d'importer cette chaîne de texte.",
	IMPORTEXPORT_ERROR_EXPORT_FAILED = "Impossible d'exporter vos paramètres.",

	IMPORTEXPORT_ERROR_PEM_DECODE = "Ceci ne ressemble pas à une chaîne " .. title .. ". Assurez-vous d'avoir tout copié, y compris les lignes |cnGREEN_FONT_COLOR:-----BEGIN-----|r et |cnGREEN_FONT_COLOR:-----END-----|r.",
	IMPORTEXPORT_ERROR_PEM_LABEL = title .. " ne reconnaît pas ce type de chaîne. Elle provient peut-être d'un autre addon ou d'une version plus récente.",
	IMPORTEXPORT_ERROR_DECOMPRESS = "Décompression impossible. La chaîne est probablement corrompue ou incomplète.",
	IMPORTEXPORT_ERROR_DESERIALIZE_CBOR = "Lecture impossible. La chaîne est probablement corrompue.",
	IMPORTEXPORT_ERROR_PACKED_DATA_INVALID = "Chaîne invalide ou malformée : importation impossible.",
	IMPORTEXPORT_ERROR_SCHEMA_TOO_NEW = "Cette chaîne de texte a été créée par une version plus récente de " .. title .. " et ne peut pas être lue. Mettez à jour l'addon puis réessayez.",

	ADDONINFO_BUILD = "|cnNORMAL_FONT_COLOR:Build :|r %s",
	ADDONINFO_BUILD_OUTDATED = title .. " n'est pas optimisé pour cette version du jeu.|n|n|cnWARNING_FONT_COLOR:Des dysfonctionnements peuvent survenir.|r",
	ADDONINFO_BUILD_CURRENT = title .. " est optimisé pour votre version actuelle du jeu.|n|n|cnGREEN_FONT_COLOR:Toutes les fonctionnalités devraient fonctionner correctement.|r",
	ADDONINFO_BLUESKY_SHILL_HELP = "Retrouvez-moi sur Bluesky !",

	-- About Tab
	ABOUT_TITLE = "À propos",
	ADDONINFO_VERSION = "|cnNORMAL_FONT_COLOR:Version :|r %s",
	CLICK_TO_COPY = "|cnGREEN_FONT_COLOR:Clic : Ouvrir le lien à copier|r",
	AUTHOR_COLON = "Auteur : ",
	VISIT_ADDON_PAGE_TOOLTIP = "Visitez la page de l'addon sur %s.",
	RUN_CLICKABLE_COMMAND = "|cnGREEN_FONT_COLOR:Clic : Exécuter la commande cliquable|r",

	UNIT_POPUPS_EAVESDROPPER_OPTIONS_HEADER = "Options d'Eavesdropper",
	UNIT_POPUPS_EAVESDROP_ON = "Écouter la cible",
	UNIT_POPUPS_EAVESDROP_ON_HELP = "Ouvre une fenêtre spécifique pour la cible actuelle.|n|n|cnWARNING_FONT_COLOR:Option désactivée si déjà suivie.|r",
	UNIT_POPUPS_EAVESDROP_GROUP = "Écouter un groupe",
	UNIT_POPUPS_EAVESDROP_GROUP_HELP = "Assigne la cible actuelle à une fenêtre de groupe spécifique ou l'en retire.|n|n|cnWARNING_FONT_COLOR:Note : |cnGREEN_FONT_COLOR:les noms de groupe en vert|r indiquent que la cible est déjà membre de ce groupe.|r",
	UNIT_POPUPS_EAVESDROP_GROUP_NEW = "Créer un nouveau groupe",
	UNIT_POPUPS_TOGGLE_MENTIONS_HELP = "Affiche ou masque la fenêtre des mentions, qui répertorie l'ensemble des messages vous ciblant.|n|n- Détecte les mots-clés et les émotes qui vous sont destinés, même ceux manqués sur le moment.",

	POPUP_EAVESDROP_GROUP = "Nom du groupe.|nAppuyez sur Entrée pour confirmer.",
	POPUP_RESTORE_GROUP = "Un groupe nommé \"%s\" avec %d membre(s) a précédemment été fermé au cours de cette session.|n|nRétablir ses membres ?",
	POPUP_RENAME_PROFILE = "Renommer le profil '%s'.|nAppuyez sur Entrée pour confirmer.",
	POPUP_COPY_PROFILE = "Saisissez le nom du nouveau profil copié depuis '%s'.|nAppuyez sur Entrée pour confirmer.",
	POPUP_NEW_PROFILE = "Saisissez le nom du nouveau profil.|nAppuyez sur Entrée pour confirmer.",

	-- Message Prefixes (keep them shorthand)
	MSG_PREFIX_PARTY = "P",
	MSG_PREFIX_RAID = "R",
	MSG_PREFIX_INSTANCE = "I",
	MSG_PREFIX_OFFICER = "O",
	MSG_PREFIX_GUILD = "G",
	MSG_PREFIX_CHANNEL = "C",
	MSG_PREFIX_RAID_WARNING = "RW",
	MSG_PREFIX_WHISPER_FROM = "W de",
	MSG_PREFIX_WHISPER_TO = "W à",

	MSG_VERB_SAY = "dit",
	MSG_VERB_YELL = "crie",
	MSG_VERB_WHISPER = "chuchote",
};

ED.Localization:RegisterNewLocale("frFR", "French", L);
