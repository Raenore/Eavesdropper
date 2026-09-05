# Changelog

All notable changes to this project will be documented in this file.  

## [Unreleased]

### Added
- Hovering over an item, spell, or other hyperlink in any Eavesdropper window now shows its tooltip when **Enable Hyperlinks** is on, thanks to [Peterodox](https://www.curseforge.com/members/peterodox/projects) ([#179](https://github.com/Raenore/Eavesdropper/pull/179)).

### Changed
- The **Enable Mouse** setting is now called **Enable Hyperlinks**. Eavesdropper windows now always let clicks and camera movement through to the game world, so the setting only decides whether hyperlinks (items, URLs, etc.) are clickable, thanks to [Peterodox](https://www.curseforge.com/members/peterodox/projects) ([#179](https://github.com/Raenore/Eavesdropper/pull/179)).
- NPCs in your targeting priority (mouseover, target, or focus) are now skipped, letting the main window fall back to a player elsewhere in that list instead of clearing ([#182](https://github.com/Raenore/Eavesdropper/pull/182)).
- Further improved performance for timestamp updates and RP name changes, especially in busy Group Windows with many senders ([#178](https://github.com/Raenore/Eavesdropper/pull/178)).

### Fixed
- Fixed keyword highlighting sometimes breaking a nearby item or spell link in the same message ([#174](https://github.com/Raenore/Eavesdropper/pull/174)).
- Fixed a keyword token (like `<firstname>`) breaking if an RP name contained certain special characters ([#174](https://github.com/Raenore/Eavesdropper/pull/174)).
- Fixed duplicate messages appearing in your history when another chat addon resends a message it already showed you. With [Prat](https://www.curseforge.com/wow/addons/prat-3-0), this was most noticeable as roll messages showing up twice ([#176](https://github.com/Raenore/Eavesdropper/pull/176)).
- **Jump to Context** in Dedicated Windows no longer keeps extra chat history loaded after you've scrolled back to the bottom. It now returns to normal automatically ([#175](https://github.com/Raenore/Eavesdropper/pull/175)).
- Fixed the **New Message Indicator** sometimes staying lit in the main window after switching targets ([#181](https://github.com/Raenore/Eavesdropper/pull/181)).
- Fixed an emote target sometimes never updating to their RP name ([#178](https://github.com/Raenore/Eavesdropper/pull/178)).

## [0.6.0] - 2026-08-30  
Major feature update adding a Mentions History window, Import & Export, a Group Windows Player List, and a French translation, alongside wide-ranging performance and interface polish.

### Added
- Added a **Mentions History** window that lists every message aimed at you, whether a keyword hit or a Blizzard emote (e.g. /poke, /wave), across every channel, with its own filters and a new **Settings > Mentions** category ([#131](https://github.com/Raenore/Eavesdropper/pull/131)).  
  - Open it via /ed mentions, the minimap icon, your unit popup menu, or the new **Toggle Mentions** keybinding ([#154](https://github.com/Raenore/Eavesdropper/pull/154)).  
- Added **Import & Export** to move your setup (profile & global settings) in and out of the game as a shareable text string ([#119](https://github.com/Raenore/Eavesdropper/pull/119)).  
  - Export either your current profile or your global settings separately to a string, then import one back under a new name or overwrite an existing profile.
- Added a **Player List** to Group Windows' title-bar dropdown, including a quick way to add your current target ([#143](https://github.com/Raenore/Eavesdropper/pull/143)).  
- Added **quick Eavesdrop actions to the title-bar menu** of Main and Dedicated windows, so you can open a Dedicated Window or add someone to a Group Window right from the menu ([#157](https://github.com/Raenore/Eavesdropper/pull/157)).  
- Added a **Jump to Context** icon to Mentions and Group Windows, on by default for both, which opens (or focuses) that sender's Dedicated Window and scrolls straight to that message ([#131](https://github.com/Raenore/Eavesdropper/pull/131) and [#138](https://github.com/Raenore/Eavesdropper/pull/138)).  
- Dedicated, Group, and Mentions windows can each have their own **Name Display**, or just follow your profile's setting using the new **"Follow Profile Setting"** option ([#131](https://github.com/Raenore/Eavesdropper/pull/131) and [#133](https://github.com/Raenore/Eavesdropper/pull/133)).  
- Advanced Formatting can now use its own name format in Blizzard's chat window, via a new "Main Chat" section in its settings ([#115](https://github.com/Raenore/Eavesdropper/pull/115)).  
- Group Windows now have their own independent **History Size** setting (10–1000, default 100), instead of sharing the previous 300-message cap ([#127](https://github.com/Raenore/Eavesdropper/pull/127)).  
- The **main history window** now has a **New Message Indicator**, on by default under **Appearance > Display** ([#126](https://github.com/Raenore/Eavesdropper/pull/126)).  
- Every window now shows a small icon in its title bar and matching Settings category, plus cleaner close and resize buttons, thanks to [Peterodox](https://www.curseforge.com/members/peterodox/projects) ([#139](https://github.com/Raenore/Eavesdropper/pull/139) and [#143](https://github.com/Raenore/Eavesdropper/pull/143)).
- Windows now have a **slim scrollbar** that thickens on hover, thanks to [Peterodox](https://www.curseforge.com/members/peterodox/projects) ([#134](https://github.com/Raenore/Eavesdropper/pull/134)).  
- Added a **French (frFR) translation**, thanks to [Daen](https://bsky.app/profile/rake.dawnsong.me) ([#123](https://github.com/Raenore/Eavesdropper/pull/123)).  
  - More languages are welcome, see [GitHub](https://github.com/Raenore/Eavesdropper).  

### Changed
- **Dedicated and Group windows now save all their settings automatically**; the old "Save Windows"/"Save Groups" toggles are gone since this is no longer optional ([#133](https://github.com/Raenore/Eavesdropper/pull/133)).  
- Reworked the **Profiles** settings category around a single **Manage Profiles** dropdown holding all profile management in one place ([#119](https://github.com/Raenore/Eavesdropper/pull/119)).  
  - The **Default** profile can no longer be renamed or deleted, and you can now delete your active profile; its characters switch to Default automatically.  
- Improved performance across every window: timestamps, RP names, and Group Windows all update faster, especially with several windows open in busy RP areas ([#126](https://github.com/Raenore/Eavesdropper/pull/126) and [#127](https://github.com/Raenore/Eavesdropper/pull/127)).  
- **Player names are now clickable in every window** (Main, Dedicated, Group, and Mentions), including anyone mentioned in an emote, not just the sender: right-click opens the game's own context menu for that player ([#131](https://github.com/Raenore/Eavesdropper/pull/131), [#148](https://github.com/Raenore/Eavesdropper/pull/148), and [#155](https://github.com/Raenore/Eavesdropper/pull/155)).  
- **Shift-Right-Click** on the minimap icon now opens Mentions instead of the main window; **Shift-Left-Click** still toggles the main window as before ([#131](https://github.com/Raenore/Eavesdropper/pull/131)).  
- Updated the TOC for Patch 12.1 ([#122](https://github.com/Raenore/Eavesdropper/pull/122)).  

### Fixed
- Settings changes now apply instantly to open Dedicated and Group windows, no reopen or /reload needed ([#131](https://github.com/Raenore/Eavesdropper/pull/131)).  
- Fixed emotes sometimes losing their leading punctuation (like the "'s" in "'s hand trembles" or the "," in ", still smiling,") ([#142](https://github.com/Raenore/Eavesdropper/pull/142)).
- Timestamps and RP names in the **main history window** now keep updating while you are scrolled up, instead of freezing until you returned to the bottom ([#126](https://github.com/Raenore/Eavesdropper/pull/126)).  
- Emote targets in **Group Windows** now correctly use that window's own **Name Display** setting ([#116](https://github.com/Raenore/Eavesdropper/pull/116)).  
- The **Unit Popups** setting for Group Windows now works, so you can disable "Eavesdrop Group" from the unit menu ([#131](https://github.com/Raenore/Eavesdropper/pull/131)).  
- The **New Message Indicator** setting for Group Windows now actually disables the indicator when unchecked ([#126](https://github.com/Raenore/Eavesdropper/pull/126)).  
- Fixed NPC dialogue sometimes being renamed twice when both Eavesdropper and **Total RP 3: RP Name in Quest Text** were active ([#135](https://github.com/Raenore/Eavesdropper/pull/135)).  
- Dedicated Windows no longer offer a broken "Rename" option in their title-bar menu ([#131](https://github.com/Raenore/Eavesdropper/pull/131)).  
- Fixed rapid duplicate rolls (like quick re-rolls, or a toy that rolls twice) sometimes only showing the first roll ([#170](https://github.com/Raenore/Eavesdropper/pull/170)).  

## [0.5.1] - 2026-08-04  
Maintenance update switching the license to GNU GPLv3, improving Total RP 3 & MSP initialization during login, and fixing keyword token parsing across non-TRP3 RP addons.  

### Changed
- **Eavesdropper is now licensed under GNU GPLv3** instead of Apache 2.0 (as required by our relicensing process) ([#108](https://github.com/Raenore/Eavesdropper/pull/108)).  
  - The core change is that GPLv3 strictly disallows closed-source variants. It ensures the software remains completely free and open for users, while protecting the codebase from being locked behind proprietary walls.
  - Eavesdropper was made to be forever free and maintained by whoever might take over after me and to achieve that future forks or derivatives should be (legally) required to remain open-source forever.

### Fixed
- Resolved an error on login that could break the addon while [Total RP 3](https://www.curseforge.com/wow/addons/total-rp-3) was still loading, most noticeable on laggy realms or during heavy server load (like NA's Tournament of Ages / ToA) ([#110](https://github.com/Raenore/Eavesdropper/pull/110)).
  - Eavesdropper now waits for Total RP 3 to report that it has finished loading before reading any profile data, instead of assuming it is ready as soon as it is present.  
  - Your keyword tokens and RP name in quest text are also refreshed once Total RP 3 finishes loading, so they no longer stay blank for the rest of the session (or until keywords were changed).  
  - Special thanks to [LocalHaunt / Moth](#) for reporting this error and testing the accompanying fix.  
- Keyword tokens (`<firstname>`, `<lastname>`, `<class>`, `<race>`) and the RP name used in quest and NPC text now work for [MRP](https://www.curseforge.com/wow/addons/my-role-play), [XRP](https://www.curseforge.com/wow/addons/xrp) and other MSP addons, where they previously only worked with Total RP 3 ([#110](https://github.com/Raenore/Eavesdropper/pull/110)).  
- RP names of three or more words (e.g. "Pitlord Pete Odox") now fill in the first and last name correctly, and names of a single word now fill in the first name instead of being left blank ([#110](https://github.com/Raenore/Eavesdropper/pull/110)).  
- Resolved a potential error on non-English clients when reading an RP name through an MSP addon ([#110](https://github.com/Raenore/Eavesdropper/pull/110)).  

## [0.5.0] - 2026-06-30  
Significant update featuring a modernized Settings menu, initial keybindings support, expanded multi-message compatibility, and various interface fixes.  

### Added  
- Expanded multi-message support to include [EmoteScribe](https://www.curseforge.com/wow/addons/emotescribe) as the latest explicitly supported provider ([#78](https://github.com/Raenore/Eavesdropper/pull/78)).  
  - This ensures that long-form RP emotes split across multiple messages remain cohesive within your history window.  
- **Clickable commands** were introduced in the startup message and for /ed help ([#87](https://github.com/Raenore/Eavesdropper/pull/87)).  
- Added initial **Keybindings** support, which can be configured directly in Blizzard's **Options > Keybindings** menu. Current binds include:  
  - **Toggle Eavesdropper:** Opens or closes the main history window.  
  - **Toggle Settings:** Opens or closes the Eavesdropper configuration menu.  
  - **Eavesdrop On (Dedicated):** Opens a Dedicated Window for your current target or mouseover unit, respecting your configured targeting priority.  
- Expanded **"Eavesdrop Group"** right-click menu options to support **Battle.net friends** across the Social Panel and Communities tabs (available when they are actively logged into a WoW character).  
- Dedicated and Group Windows now persist their **position** and **size** across reloads and restarts ([#104](https://github.com/Raenore/Eavesdropper/pull/104)).  

### Changed
- Revamped the **Settings menu** with a new **sidebar navigation** and an "About" category featuring an in-game changelog, in collaboration with [Peterodox](https://www.curseforge.com/members/peterodox/projects) ([#69](https://github.com/Raenore/Eavesdropper/pull/69) and [#86](https://github.com/Raenore/Eavesdropper/pull/86)).  
  - Reorganized the interface by splitting options from the "General" tab into new, dedicated categories: **Appearance**, **Adv. Formatting**, **Dedicated**, and **Groups**.  
  - Added extra descriptions for various options and more clearly marked Global Settings to improve clarity.  
- Updated how the addon communicates with [Yapper](https://www.curseforge.com/wow/addons/yapper-post-splitter) to use their latest public API for handling split messages ([#75](https://github.com/Raenore/Eavesdropper/pull/75)).  
- The setting's label now greys out when disabled for better clarity ([#90](https://github.com/Raenore/Eavesdropper/pull/90)).  
- Toggling the **ElvUI skin** for the settings window now prompts for a reload confirmation instead of instantly forcing an unannounced UI reload.  
- Improved the unit popup **target menu options** ([#95](https://github.com/Raenore/Eavesdropper/pull/95)):  
  - The **"Eavesdrop On"** option will now dynamically disable itself if a Dedicated Window already exists for that target.  
  - Added informative **tooltips** to both the "Eavesdrop On" and "Eavesdrop Group" menu selections to clearly explain their functionality.  
- Improved the reliability of the **"Hide in Combat"** setting, ensuring windows hide and reveal correctly even for players experiencing high latency or poor connections ([#88](https://github.com/Raenore/Eavesdropper/pull/88)).  
- Updated the TOC for Patch 12.0.7.  

### Fixed
- Dedicated and Group Windows now maintain their own independent chat filters, based on the main window's filters on creation, and no longer share or overwrite each other's filter state ([#103](https://github.com/Raenore/Eavesdropper/pull/103)).  
- Chat history loaded into Dedicated and Group Windows is now filtered using that window's own filters, rather than the main window's ([#103](https://github.com/Raenore/Eavesdropper/pull/103)).  
- **Sound notifications**, **taskbar flash**, and the **new message indicator** on Dedicated and Group Windows are now suppressed for chat types that are filtered out on that window ([#103](https://github.com/Raenore/Eavesdropper/pull/103)).  
- Prevent Dedicated and Group Windows from scrolling down automatically when they are scrolled up, thanks to [Peterodox](https://www.curseforge.com/members/peterodox/projects) ([#101](https://github.com/Raenore/Eavesdropper/pull/101)).  
- Group Windows now correctly handle multi-part messages by using split markers, preventing player names from repeating unnecessarily on every line ([#76](https://github.com/Raenore/Eavesdropper/pull/76)).  
- Hyphenated RP names (e.g., Ivy-Rose) now display properly in emotes thanks to [Bitwise1057](https://github.com/Bitwise1057) ([#73](https://github.com/Raenore/Eavesdropper/pull/73) and [#74](https://github.com/Raenore/Eavesdropper/pull/74)).  
- When "Enable Mouse" is disabled, hyperlinks (e.g. items) no longer block camera movement or clicks, thanks to [Peterodox](https://www.curseforge.com/members/peterodox/projects) ([#68](https://github.com/Raenore/Eavesdropper/pull/68)).  

## Full Changelog  
The complete changelog, including older versions, can always be found on [Eavesdropper's GitHub Wiki](https://github.com/Raenore/Eavesdropper/wiki/Full-Changelog).  

[unreleased]: https://github.com/Raenore/Eavesdropper/compare/0.6.0...HEAD
[0.6.0]: https://github.com/Raenore/Eavesdropper/compare/0.5.1...0.6.0
[0.5.1]: https://github.com/Raenore/Eavesdropper/compare/0.5.0...0.5.1
[0.5.0]: https://github.com/Raenore/Eavesdropper/compare/0.4.1...0.5.0
