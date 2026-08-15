# Changelog

All notable changes to this project will be documented in this file.  

## [Unreleased]

### Added
- Added **Import & Export**, which lets you move your setup (profile & global settings) in and out of the game as a shareable text string ([#119](https://github.com/Raenore/Eavesdropper/pull/119)).  
  - **Export Settings:** Exports either the current profile or your global settings to a text string. Press **Ctrl+C** to copy it, then paste it wherever you want to keep or share it. Each is exported separately.  
  - **Import Settings:** Paste a string to bring settings back in. Eavesdropper recognizes on its own whether it holds a profile or your global settings, fills in the profile name from the string, and lets you import it under another name or overwrite an existing profile.  
  - Every string is checked before anything is written. Damaged, incomplete or unrecognized strings are refused with an explanation of what went wrong, and any individual settings that could not be read are skipped and reported instead of ending up in your profile.  
  - Strings created by a newer version of Eavesdropper are refused rather than imported halfway.  
  - The encoding used for these strings is adapted from [Total RP 3](https://www.curseforge.com/wow/addons/total-rp-3).  
- Added a **French (frFR) translation**, thanks to [Daen](https://bsky.app/profile/rake.dawnsong.me) ([#123](https://github.com/Raenore/Eavesdropper/pull/123)).  
  - Translations for other languages are very welcome. If you would like to help translate Eavesdropper, open an issue or pull request over on [GitHub](https://github.com/Raenore/Eavesdropper).  
- Advanced Formatting can now use its **own name format in the main Blizzard chat window**, separate from the one used by Eavesdropper's own windows ([#115](https://github.com/Raenore/Eavesdropper/pull/115)).  
  - **Override Name Display:** Toggles whether Advanced Formatting in the main chat window uses its own name format instead of your "Name Display" setting.  
  - **Adv. Formatting Name Display:** Choose between **Full Name**, **First Name**, or **Original (OOC) Name** for the main chat window. This only applies while "Override Name Display" is enabled, and falls back to the original (OOC) name when no suitable RP addon (TRP, MRP, XRP) is loaded.  
  - This lets you keep, for example, full RP names in your Eavesdropper windows while the main chat window stays on first names only.  
- The **main history window** now has a **New Message Indicator**, the same 'golden flash' along the bottom edge that Dedicated and Group Windows already use ([#126](https://github.com/Raenore/Eavesdropper/pull/126)).  
  - Can be toggled under **Appearance > Display**. It behaves exactly like the one for Dedicated & Group Windows and is on by default and a global setting.
  - Small recap: Clears automatically after 10 seconds or immediately if you hover over the window, and does not show for your own messages.
- Group Windows (**Settings > Groups**) now have their own independent **History Size** setting (ranging from 10–1000, default 100) to support larger history thresholds than the previous 300-message cap ([#127](https://github.com/Raenore/Eavesdropper/pull/127)).  
  - If your general History Size was set higher than 100 prior to this update, this new setting automatically scales up to match it so your history limit is not unexpectedly lowered.

### Changed
- Reworked the **Profiles** settings category around a single **Manage Profiles** dropdown, which now holds all profile management in one place ([#119](https://github.com/Raenore/Eavesdropper/pull/119)).  
  - Hovering over any profile in the dropdown reveals its own options: **Profile Options**, holding "Copy Profile" and "Rename Profile", and **Delete Profile**.  
  - **New Profile** and **Reset Active Profile** are now actions within the dropdown itself, replacing the separate "New Profile", "Copy From" and "Delete Profile" options.  
  - **Copy Profile** creates a new profile holding a copy of that profile's settings and switches to it, instead of copying another profile's settings over the one you are currently using.  
  - The **Default** profile is now guaranteed to always exist and can no longer be renamed or deleted.  
  - You can now delete the profile you are currently using. Any character using it is switched back to **Default**.  
- Reorganized the **Adv. Formatting** settings category with a new **"Main Chat"** section, which now holds the "Apply to Main Chat" option alongside the new name display override options ([#115](https://github.com/Raenore/Eavesdropper/pull/115)).  
- Eavesdropper now **redraws its timestamps every minute** instead of every 10 seconds, and stops redrawing entirely after a chat is considered 'frozen' (30 minutes after the last message) ([#126](https://github.com/Raenore/Eavesdropper/pull/126)).  
  - Quick Notes: This should have minimal to no visual user changes, however you should notice **fewer brief frame drops with several windows open, especially in busy RP areas**.
  - Timestamps were already shown in whole minutes, which means on 10 seconds they were being redrawn way too often for no visual gain.
  - Messages older than 30 minutes no longer change at all, given they (already) became fixed HH:MM timestamps. Prior these windows kept refreshing 6 times per minute for no reason whatsoever. New messages will 'revive' these windows.
  - A small trade-off is that the timestamp can sit up to a minute behind, which means if a line reads "5m" it may sometimes be closer to six.
- **RP Names now update within about 5 seconds** (instead of 10 seconds) across every open window when changes are picked up by your RP addon ([#126](https://github.com/Raenore/Eavesdropper/pull/126)).
  - This was previously tied to the timestamp update every 10 seconds, but is now decoupled from that.
  - If RP data came in for several people at once, like when you enter a busy RP area, Eavesdropper now collects and draws these together in batches to prevent unnecessary flickering and frame drops.
- **Significantly optimized Group Window rendering performance**, especially when managing groups with many active members or heavy chat histories ([#126](https://github.com/Raenore/Eavesdropper/pull/126) and [#127](https://github.com/Raenore/Eavesdropper/pull/127)).  
  - Caching for RP names, colors, and player data has been rewritten. Group windows now refresh up to twice as fast during active conversations, adding/removing members, or changing chat filters.   

### Fixed
- Emote targets in **Group Windows** now respect that window's own **Name Display** setting, instead of always falling back to the profile-wide "Name Display" setting ([#116](https://github.com/Raenore/Eavesdropper/pull/116)).  
- The **New Message Indicator** setting for **Group Windows** now actually turns the indicator off when it is unchecked ([#126](https://github.com/Raenore/Eavesdropper/pull/126)).
- Timestamps and RP names in the **main history window** now keep updating while you are scrolled up, instead of freezing until you returned to the bottom ([#126](https://github.com/Raenore/Eavesdropper/pull/126)).

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

## [0.4.1] - 2026-04-04  
Minor patch introducing the ability to rename profiles and internal data optimizations.  

### Added
- You can now rename existing profiles in the profile switching dropdown by clicking the small gear icon when hovering over them ([#63](https://github.com/Raenore/Eavesdropper/pull/63)).  

### Fixed
- Optimized how data is stored locally, there should be no user-facing changes ([#64](https://github.com/Raenore/Eavesdropper/pull/64)).  
- Resolved a rare issue where a player's name color would fail to load if their character data wasn't already cached ([#67](https://github.com/Raenore/Eavesdropper/pull/67)).  

## [0.4.0] - 2026-03-28  
Significant feature update introducing Group Windows, session persistence for dedicated frames, and various quality-of-life UI improvements.  

### Added
- Added **Group Window** support to combine multiple specific players into a single shared Eavesdropper window ([#53](https://github.com/Raenore/Eavesdropper/pull/53)).  
  - Ideal for tracking small parties or specific "inner circles" in crowded RP hubs.  
  - Create or manage groups by right-clicking a unit's portrait or chat name and selecting "Eavesdrop Group".  
  - Includes a global setting (enabled by default) that remembers your Group Name, Player List, and Display Mode even after logging out or reloading.  
- Improved how **Dedicated Windows** are saved across sessions ([#55](https://github.com/Raenore/Eavesdropper/pull/55)).  
  - Includes a global setting (enabled by default) that automatically re-opens your active Dedicated Windows after a UI reload or game restart.  
- Added the **Beep** and **Poke** sounds from the Listener addon as new notification options with proper licensing ([#28](https://github.com/Raenore/Eavesdropper/pull/28) and [#61](https://github.com/Raenore/Eavesdropper/pull/61)).  
  - Special thanks to [Bitwise1057](https://github.com/Bitwise1057) for the initial implementation.  
- Added confirmation popups for profile actions to prevent accidental clicks ([#59](https://github.com/Raenore/Eavesdropper/pull/59) and [#60](https://github.com/Raenore/Eavesdropper/pull/60)).  
  - "New," "Copy From," "Reset," and "Delete" profile options now ask for confirmation before any changes are made.  
- The title bar button (which opens the window menu) now automatically resizes to fit its text.  
  - Whether it shows "Eavesdropper," a target name, or a group name, the button will grow or shrink to fit the name while keeping a clean minimum width.  

### Changed
- Improved window dragging by allowing you to move windows by clicking directly on the title text ([#54](https://github.com/Raenore/Eavesdropper/pull/54), by [Peterodox](https://www.curseforge.com/members/peterodox/projects)).  
  - You can now click and drag anywhere on the top bar to move any Eavesdropper window.  
- New Dedicated or Group windows now automatically appear in front of existing ones when opened ([#52](https://github.com/Raenore/Eavesdropper/pull/52)).  
  - This ensures that newly created windows are always on top and not hidden behind others.  

### Fixed
- Improved the title bar menu to prevent it from flickering or closing if you click the menu button while it is already open ([#56](https://github.com/Raenore/Eavesdropper/pull/56)).  
- Resolved a rare issue where "Format Quest Text" would fail for certain NPCs that had no actual dialogue to show ([#51](https://github.com/Raenore/Eavesdropper/pull/51)).  

## Full Changelog  
The complete changelog, including older versions, can always be found on [Eavesdropper's GitHub Wiki](https://github.com/Raenore/Eavesdropper/wiki/Full-Changelog).  

[unreleased]: https://github.com/Raenore/Eavesdropper/compare/0.5.1...HEAD
[0.5.1]: https://github.com/Raenore/Eavesdropper/compare/0.5.0...0.5.1
[0.5.0]: https://github.com/Raenore/Eavesdropper/compare/0.4.1...0.5.0
[0.4.1]: https://github.com/Raenore/Eavesdropper/compare/0.4.0...0.4.1
[0.4.0]: https://github.com/Raenore/Eavesdropper/compare/0.3.0...0.4.0
