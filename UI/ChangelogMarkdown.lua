local changelogMarkdown = [[
# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

### Added
- Expanded multi-message support to include [EmoteScribe](https://www.curseforge.com/wow/addons/emotescribe) as the latest explicitly supported provider ([#78](https://github.com/Raenore/Eavesdropper/pull/78)).
  - This ensures that long-form RP emotes split across multiple messages remain cohesive within your history window.

### Changed
- Updated how the addon communicates with Yapper to use their latest public API for handling split messages ([#75](https://github.com/Raenore/Eavesdropper/pull/75)).

### Fixed
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

## Full Changelog
The complete changelog, including older versions, can always be found on [Eavesdropper's GitHub Wiki](https://github.com/Raenore/Eavesdropper/wiki/Full-Changelog).
]]

ED.Changelogs:SetMarkdown(changelogMarkdown);
