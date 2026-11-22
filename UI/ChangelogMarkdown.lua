-- Copyright The Eavesdropper Authors
-- SPDX-License-Identifier: GPL-3.0-or-later

local changelogMarkdown = [[
# Changelog

All notable changes to this project will be documented in this file.

## [0.8.0] - 2026-11-xx

### Added
- Added **Sync with Party/Raid** to Group Windows, which keeps a window filled with your group members as they join, with a **Create Sync Group** shortcut (or /ed sync) to start one quickly ([#238](https://github.com/Raenore/Eavesdropper/pull/238)).
- Added an **Override Global Colors** option to Dedicated, Group and Mentions windows, so each can have its own background and title bar colors ([#237](https://github.com/Raenore/Eavesdropper/pull/237)).
- Added a **Hide When OOC** option that hides Eavesdropper while your RP status is Out of Character ([#236](https://github.com/Raenore/Eavesdropper/pull/236)).
- Added a **German translation**, thanks to [Zwixx](https://github.com/Zwixx) ([#219](https://github.com/Raenore/Eavesdropper/pull/219)).

### Changed
- The Settings window's close button now fits its border on Forever, thanks to [Peterodox](https://www.curseforge.com/members/peterodox/projects) ([#229](https://github.com/Raenore/Eavesdropper/pull/229)).

### Fixed
- Fixed emote and speech coloring being lost on Forever when using **Total RP 3** ([#231](https://github.com/Raenore/Eavesdropper/pull/231)).
- The **Total RP 3** toolbar button now works the same as the minimap button ([#233](https://github.com/Raenore/Eavesdropper/pull/233)).
- Fixed an empty Eavesdropper section appearing in the right-click menu when all its options are turned off ([#235](https://github.com/Raenore/Eavesdropper/pull/235)).
- Fixed names in system messages, such as players coming online, being changed incorrectly ([#228](https://github.com/Raenore/Eavesdropper/pull/228)).
- Fixed player names in emotes displaying incorrectly when using **Chattynator**, for RP names containing a hyphen ([#226](https://github.com/Raenore/Eavesdropper/pull/226)).
- Fixed a Lua error that could appear with **Total RP 3** for some players ([#223](https://github.com/Raenore/Eavesdropper/pull/223)).

## [0.7.1] - 2026-10-13
Maintenance update fixing the French and Russian translations not loading.

### Fixed
- Fixed the **French** and **Russian** translations not loading, so Eavesdropper shows in your game's language again ([#217](https://github.com/Raenore/Eavesdropper/pull/217)).
  - More languages are welcome, see [GitHub](https://github.com/Raenore/Eavesdropper).

## [0.7.0] - 2026-10-13
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
- Temporarily removed Eavesdropper's right-click menu options from some menus, such as the Friends list and Communities, to avoid menu tainting on Retail and Forever ([#213](https://github.com/Raenore/Eavesdropper/pull/213)).
- Updated the TOC for Patch 12.1.5.

### Fixed
- Fixed a Lua error when reloading or logging back in during combat/restrictions with **Apply to Main Chat** turned on ([#200](https://github.com/Raenore/Eavesdropper/pull/200)).
- Fixed a Lua error that could appear during combat/restrictions when other players' nameplates are shown ([#201](https://github.com/Raenore/Eavesdropper/pull/201)).

## Full Changelog
The complete changelog, including older versions, can always be found on [Eavesdropper's GitHub Wiki](https://github.com/Raenore/Eavesdropper/wiki/Full-Changelog).

[unreleased]: https://github.com/Raenore/Eavesdropper/compare/0.8.0...HEAD
[0.8.0]: https://github.com/Raenore/Eavesdropper/compare/0.7.1...0.8.0
[0.7.1]: https://github.com/Raenore/Eavesdropper/compare/0.7.0...0.7.1
[0.7.0]: https://github.com/Raenore/Eavesdropper/compare/0.6.2...0.7.0

]]

ED.Changelogs:SetMarkdown(changelogMarkdown);
