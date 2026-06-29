local changelogMarkdown = [[
# Changelog

All notable changes to this project will be documented in this file.

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

[unreleased]: https://github.com/Raenore/Eavesdropper/compare/0.4.1...HEAD
[0.5.0]: https://github.com/Raenore/Eavesdropper/compare/0.4.1...0.5.0
[0.4.1]: https://github.com/Raenore/Eavesdropper/compare/0.4.0...0.4.1
[0.4.0]: https://github.com/Raenore/Eavesdropper/compare/0.3.0...0.4.0

]]

ED.Changelogs:SetMarkdown(changelogMarkdown);
