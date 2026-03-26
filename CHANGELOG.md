# Changelog

All notable changes to this project will be documented in this file.  

## [Unreleased] - 2026-03-xx 
<Super Awesome Summary Line That Is To Be Decided.>  

### Added
- Added Group Window support to combine multiple specific players into a single shared Eavesdropper window ([#53](https://github.com/Raenore/Eavesdropper/pull/53)).  
  - Ideal for tracking small parties or specific "inner circles" in crowded RP hubs.  
  - Create or manage groups by right-clicking a unit's portrait or chat name and selecting "Eavesdrop Group".  
  - Includes a global setting (enabled by default) that saves your Group Name, Player List, and Display Mode even after logging out or reloading.  
- Implemented a persistence upgrade for Dedicated Windows ([#55](https://github.com/Raenore/Eavesdropper/pull/55)).  
  - Includes a global setting (enabled by default) that automatically re-opens your active Dedicated Windows after a UI reload or game restart.  

### Changed
- Improved window dragging by allowing you to move windows by clicking on the title text button ([#54](https://github.com/Raenore/Eavesdropper/pull/54), by [Peterodox](https://www.curseforge.com/members/peterodox/projects)).  
  - You can now click and drag anywhere on the top bar to move any Eavesdropper window.  
- New Dedicated or Group windows now automatically appear in front of existing ones when opened ([#52](https://github.com/Raenore/Eavesdropper/pull/52)).  
  - This ensures that newly created windows are always visible and not hidden behind others.  

### Fixed
- Improved the title bar menu to prevent it from closing and immediately re-opening when clicking the menu button while it is already active ([#56](https://github.com/Raenore/Eavesdropper/pull/56)).  
- Resolved a rare issue where "Format Quest Text" would fail for specific NPCs that had no actual dialogue to display ([#51](https://github.com/Raenore/Eavesdropper/pull/51)).  

## [0.3.0] - 2026-03-22  
Significant feature update introducing Dedicated Windows for unique targets, RP name integration with Dialogue UI, and localized Russian support.  

### Added
- Dedicated Window support for unique targets ([#26](https://github.com/Raenore/Eavesdropper/pull/26)).  
  - This feature can be toggled under the "Dedicated Windows" category.  
  - Open a unique window by right-clicking a unit's portrait or their name in chat and selecting "Eavesdrop On".  
  - Includes optional notification options (sounds and taskbar flashing) in the "Notifications" tab.  
  - New messages will trigger a yellow message indicator on the respective window to help track conversations (enabled by default, can be disabled in settings).  
- Eavesdropper can now replace your character's name with your RP name within quest text when using [Dialogue UI](https://www.curseforge.com/wow/addons/dialogueui) (special thanks to [Peterodox](https://www.curseforge.com/members/peterodox/projects) for his work on his side) ([#36](https://github.com/Raenore/Eavesdropper/pull/36) and [#44](https://github.com/Raenore/Eavesdropper/pull/44)).  
- Eavesdropper can now replace your character's name within NPC dialogue (Say, Emote, etc.) when a supported RP addon is used ([#42](https://github.com/Raenore/Eavesdropper/pull/42) and [#44](https://github.com/Raenore/Eavesdropper/pull/44)).  
  - Quest Text and NPC Dialogue features can be toggled under the "Advanced Formatting" category.  
  - Note: Chat bubbles will still show your original name, as they cannot be modified by addons.  
  - Includes three display modes:  
    - Full Name: Displays your complete RP name.  
    - First Name: Displays only the first part of your RP name.  
    - Original (OOC) Name: Reverts to your standard character name.  
- Eavesdropper window visibility is now saved per character rather than per session ([#25](https://github.com/Raenore/Eavesdropper/pull/25)).  
  - Allows the frame to be shown or hidden independently across different characters.  
  - The most recent visibility state is now remembered across logins and UI reloads.  
- Russian translation added thanks to [Hubbotu](https://github.com/Hubbotu) / ZamestoTV ([#32](https://github.com/Raenore/Eavesdropper/pull/32)).  

### Changed
- Standardized terminology across the addon; all instances now consistently use "Settings" instead of a mix of "Options" and "Settings".  
- Refined the keyword highlighting system to improve overall consistency and resolve rare occurrences of missed keywords ([#31](https://github.com/Raenore/Eavesdropper/pull/31)).  
- Implemented various improvements to the Keywords multi-line editbox ([#30](https://github.com/Raenore/Eavesdropper/pull/30)).  
  - Escaping or clicking out of the editbox will now properly sanitize and save your changes.  
  - Scrolling while hovering over the editbox (without focus) will now correctly scroll the Keywords tab itself.  
  - Improved the scrollbar logic to reveal more intuitively when the content exceeds the editbox height.  
  - Clicking anywhere within the editbox now properly focuses the text, removing the need to click specifically on existing text.  
- Total RP 3 NPC Speech Emotes once again support keyword color highlighting for users on TRP3 v3.3.3; for users on older versions, support remains limited to keyword notification sounds ([#40](https://github.com/Raenore/Eavesdropper/pull/40)).  

### Fixed
- Resolved another issue where TRP3 NPC Speech emotes (which typically begin with `| `) could appear invisible for certain users after using a standard Blizzard emote (e.g., /point, /wave) ([#40](https://github.com/Raenore/Eavesdropper/pull/40)).  
- Resolved an Eavesdropper conflict with RP addons in specific rare circumstances when using completely empty profiles ([#43](https://github.com/Raenore/Eavesdropper/pull/43)).  
- Resolved an issue where the Eavesdropper window would sometimes randomly hide when entering instances (dungeons, Trial of Style, etc.) ([#25](https://github.com/Raenore/Eavesdropper/pull/25)).  

## [0.2.4] - 2026-03-14  
Fourth minor patch, addressing a critical bug with TRP3's NPC Speech Emotes being invisible.  

### Fixed
- Resolved an issue where TRP3 NPC Speech Emotes (which typically begin with `| `) could appear invisible for certain users.  
  - Note: As a side effect of this fix, NPC Speech Emotes will only support keyword notification sounds; color highlighting is currently unsupported for these specific emotes.  

## [0.2.3] - 2026-03-09  
Third minor patch following the Midnight launch, resolving a few filter-related issues.  

### Fixed
- Resolved an issue where some users were unable to view or toggle all available filters ([#22](https://github.com/Raenore/Eavesdropper/pull/22)).  
- Resolved an issue where filters failed to update immediately upon switching profiles, previously requiring a UI reload or changing filters ([#23](https://github.com/Raenore/Eavesdropper/pull/23)).  

## [0.2.2] - 2026-03-07  
Second minor patch following the Midnight launch, resolving duplicate emotes when using the Prat chat addon.  

### Fixed
- Resolved an issue where duplicate emotes were being recorded in Eavesdropper history following a recent Prat update ([#19](https://github.com/Raenore/Eavesdropper/pull/19)).  

## [0.2.1] - 2026-03-05  
First minor patch following the Midnight launch, resolving some user-submitted bugs.  

### Fixed
- Resolved several issues regarding frame visibility in specific scenarios, such as "Hide In Combat" and "Hide When Empty" ([#16](https://github.com/Raenore/Eavesdropper/pull/16)).  
- Resolved an issue where some standard Blizzard emotes would incorrectly trigger a "targeted by emote" notification ([#18](https://github.com/Raenore/Eavesdropper/pull/18)).  

## [0.2.0] - 2026-03-02  
To start off the Midnight expansion, introducing Focus as a targeting option.  

### Added
- Settings now display your current priority in green within the Targeting category ([#12](https://github.com/Raenore/Eavesdropper/pull/12)).  
- Added the ability to use your Focus target for Eavesdropper's history!  
  - Focus can be set to: Override, Fallback, or Ignore.  
  - Override: Focus targets will always take priority over other targets.  
  - Fallback: Show focus only if there is no current target or mouseover.  
  - Ignore: Disregard the focus target entirely.  
- Added a new priority preset: Focus Only (ignores everything except your Focus target).  

### Fixed
- Resolved an issue where the scroll wheel failed to function when hovering near scrollbars on the Settings page ([#13](https://github.com/Raenore/Eavesdropper/pull/13)).  

## [0.1.5] - 2026-02-26  
Fifth minor patch for Eavesdropper, likely the final update before Midnight launch, barring any major issues. This patch addresses a specific visual bug with mouseover and target switching ("prioritize mouseover" specific).  

### Fixed
- Resolved a split-second text flicker that occurred when mousing over a new unit while having a prior target and then selecting them ([#11](https://github.com/Raenore/Eavesdropper/pull/11)).  

## [0.1.4] - 2026-02-25  
Fourth minor patch for Eavesdropper featuring a new way to identify global settings and resolving issues with specific options not toggling correctly.  

### Added
- Added an asterisk (*) to global settings and included information in tooltips to indicate settings that are not tied to specific profiles ([#10](https://github.com/Raenore/Eavesdropper/pull/10)).  

### Fixed
- Resolved an issue where certain settings failed to toggle on or off correctly ([#10](https://github.com/Raenore/Eavesdropper/pull/10)).  

## [0.1.3] - 2026-02-24  
Third minor patch for Eavesdropper featuring further bug fixes, primarily focusing on Secrets (which occur during combat, encounters, and PvP matches).  

### Fixed
- Resolved additional errors occurring within restricted environments, such as PvP, combat, and dungeons ([#9](https://github.com/Raenore/Eavesdropper/pull/9)).  

## [0.1.2] - 2026-02-24  
Second minor patch for Eavesdropper featuring bug fixes reported by the community via Discord and Bluesky.

### Fixed
- Fixed errors occurring within restricted environments, such as PvP, combat, and dungeons ([#6](https://github.com/Raenore/Eavesdropper/pull/6)).  
- Fixed "Hide When Empty" setting not applying correctly upon login or UI reload ([#8](https://github.com/Raenore/Eavesdropper/pull/8)).  
- Fixed occurrences of missing or invisible names in emotes and chat when the sender is from an opposing faction ([#7](https://github.com/Raenore/Eavesdropper/pull/7)).  

## [0.1.1] - 2026-02-23  
First minor patch for Eavesdropper after its initial release; includes minor improvements and clean-ups.  

### Added  
- Welcome message stating the current loaded profile and version (can be toggled) ([#2](https://github.com/Raenore/Eavesdropper/pull/2)).  
- Implemented `/ed help` to show all available commands ([#2](https://github.com/Raenore/Eavesdropper/pull/2)).  

### Fixed  
- Fixed an issue where minimap button positions and other settings failed to save in rare occurrences ([#5](https://github.com/Raenore/Eavesdropper/pull/5)).  
- Guarded against potential naming issues with certain NPC text and emotes ([#3](https://github.com/Raenore/Eavesdropper/pull/3)).  

## [0.1.0] - 2026-02-22  
Eavesdropper's initial release build, targeting Midnight Pre-Patch.  

### Added  
- Initial release.  

[unreleased]: https://github.com/Raenore/Eavesdropper/compare/0.3.0...HEAD
[0.3.0]: https://github.com/Raenore/Eavesdropper/compare/0.2.4...0.3.0
[0.2.4]: https://github.com/Raenore/Eavesdropper/compare/0.2.3...0.2.4
[0.2.3]: https://github.com/Raenore/Eavesdropper/compare/0.2.2...0.2.3
[0.2.2]: https://github.com/Raenore/Eavesdropper/compare/0.2.1...0.2.2
[0.2.1]: https://github.com/Raenore/Eavesdropper/compare/0.2.0...0.2.1
[0.2.0]: https://github.com/Raenore/Eavesdropper/compare/0.1.5...0.2.0
[0.1.5]: https://github.com/Raenore/Eavesdropper/compare/0.1.4...0.1.5
[0.1.4]: https://github.com/Raenore/Eavesdropper/compare/0.1.3...0.1.4
[0.1.3]: https://github.com/Raenore/Eavesdropper/compare/0.1.2...0.1.3
[0.1.2]: https://github.com/Raenore/Eavesdropper/compare/0.1.1...0.1.2
[0.1.1]: https://github.com/Raenore/Eavesdropper/compare/0.1.0...0.1.1
[0.1.0]: https://github.com/Raenore/Eavesdropper/releases/tag/0.1.0
