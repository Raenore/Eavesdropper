# Changelog

All notable changes to this project will be documented in this file.  

## [0.7.0] - 2026-10-xx  
Feature update adding early support for World of Warcraft: Forever with a matching look for its Settings, and a Mentions window that reopens after you log in.  
Preview on: [Bluesky](https://bsky.app/profile/dawnsong.me/post/3mxb2cait3s2k) | [Twitter](https://x.com/Raenore/status/2107680902641836086)

### Added
- Added **early support for Forever**, including its first and last character names ([#203](https://github.com/Raenore/Eavesdropper/pull/203)).
- On Forever, the Settings and pop-up windows now have a Forever-styled look, thanks to [Peterodox](https://www.curseforge.com/members/peterodox/projects) ([#202](https://github.com/Raenore/Eavesdropper/pull/202)).
- Added a **Title Bar Full Name** option to show full names in the title bar instead of just first names (on by default on Forever) ([#203](https://github.com/Raenore/Eavesdropper/pull/203)).
- Added `<oocfirstname>` and `<ooclastname>` tags to the **Keywords List** on Forever, to highlight your in-game first or last name ([#203](https://github.com/Raenore/Eavesdropper/pull/203)).

### Changed
- Importing a profile made on Retail into Forever (or the other way around) now offers to use this version's default settings where the two differ ([#203](https://github.com/Raenore/Eavesdropper/pull/203)).
- The **Mentions** window now remembers whether it was open on each character, so it comes back after you log in or reload ([#208](https://github.com/Raenore/Eavesdropper/pull/208)).
- Updated the **Russian translation** to cover the newer features, thanks to [Hubbotu](https://github.com/Hubbotu) ([#210](https://github.com/Raenore/Eavesdropper/pull/210)).

### Fixed
- Fixed a Lua error when reloading or logging back in during combat/restrictions with **Apply to Main Chat** turned on ([#200](https://github.com/Raenore/Eavesdropper/pull/200)).
- Fixed a Lua error that could appear during combat/restrictions when other players' nameplates are shown ([#201](https://github.com/Raenore/Eavesdropper/pull/201)).

## [0.6.2] - 2026-09-12  
Feature update adding a Copy History option to every window, improving Main Chat formatting and NPC Dialogue speech bubbles, and fixing a History Size setting and a chat name-formatting issue.  
Preview on: [Bluesky](https://bsky.app/profile/dawnsong.me/post/3mv6xeu57fc2l) | [Twitter](https://x.com/Raenore/status/2098156070103359820)

### Added
- Added a **Copy History** option to every window's title-bar menu, which opens that window's chat history as selectable text you can copy out, with options for timestamp style and how names are shown ([#192](https://github.com/Raenore/Eavesdropper/pull/192)).
- Each changelog entry with a Bluesky and/or X (Twitter) preview post now shows a clickable icon that copies the link so you can open it in your browser ([#190](https://github.com/Raenore/Eavesdropper/pull/190)).

### Changed
- **Apply to Main Chat** now retroactively reformats emotes and rolls already on screen when you turn it on or change your name display settings, instead of only affecting new messages from then on ([#188](https://github.com/Raenore/Eavesdropper/pull/188)).
- **Format NPC Dialogue** now also shows your chosen name in NPC speech bubbles, not just the dialogue text in chat ([#189](https://github.com/Raenore/Eavesdropper/pull/189)).

### Fixed
- Main and Dedicated windows now correctly respect your **History Size** setting, instead of always keeping up to 300 messages regardless of it ([#193](https://github.com/Raenore/Eavesdropper/pull/193)).
- Fixed Blizzard emotes and rolls sometimes showing the wrong name when running alongside **Total RP 3: RP Name in Quest Text**, such as an emote's starting "You" changing to your character name ([#194](https://github.com/Raenore/Eavesdropper/pull/194)).

## [0.6.1] - 2026-09-05  
Maintenance update reworking hyperlink and click-through behavior in Eavesdropper windows, improving NPC target handling, and rolling in a handful of smaller fixes and performance tweaks.  
Preview on: [Bluesky](https://bsky.app/profile/dawnsong.me/post/3musf2etc7k2v) | [Twitter](https://x.com/Raenore/status/2096344142922096953)

### Added
- Hovering over an item, spell, or other hyperlink in any Eavesdropper window now shows its tooltip when **Enable Hyperlinks** is on, thanks to [Peterodox](https://www.curseforge.com/members/peterodox/projects) ([#179](https://github.com/Raenore/Eavesdropper/pull/179)).

### Changed
- The **Enable Mouse** setting is now called **Enable Hyperlinks** and only controls whether hyperlinks (items, URLs, etc.) are clickable. Eavesdropper windows now always let clicks and camera movement pass through to the game world, thanks to [Peterodox](https://www.curseforge.com/members/peterodox/projects) ([#179](https://github.com/Raenore/Eavesdropper/pull/179)).
- Mousing over, targeting, or focusing an NPC no longer clears the main window ([#182](https://github.com/Raenore/Eavesdropper/pull/182)).
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
Preview on: [Bluesky](https://bsky.app/profile/dawnsong.me/post/3mtsebvkduk2y) | [Twitter](https://x.com/Raenore/status/2091729388387586188)

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

## Full Changelog  
The complete changelog, including older versions, can always be found on [Eavesdropper's GitHub Wiki](https://github.com/Raenore/Eavesdropper/wiki/Full-Changelog).  

[unreleased]: https://github.com/Raenore/Eavesdropper/compare/0.7.0...HEAD
[0.7.0]: https://github.com/Raenore/Eavesdropper/compare/0.6.2...0.7.0
[0.6.2]: https://github.com/Raenore/Eavesdropper/compare/0.6.1...0.6.2
[0.6.1]: https://github.com/Raenore/Eavesdropper/compare/0.6.0...0.6.1
[0.6.0]: https://github.com/Raenore/Eavesdropper/compare/0.5.1...0.6.0
