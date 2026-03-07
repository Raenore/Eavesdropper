# Changelog

All notable changes to this project will be documented in this file.  

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

[unreleased]: https://github.com/Raenore/Eavesdropper/compare/0.2.2...HEAD
[0.2.2]: https://github.com/Raenore/Eavesdropper/compare/0.2.1...0.2.2
[0.2.1]: https://github.com/Raenore/Eavesdropper/compare/0.2.0...0.2.1
[0.2.0]: https://github.com/Raenore/Eavesdropper/compare/0.1.5...0.2.0
[0.1.5]: https://github.com/Raenore/Eavesdropper/compare/0.1.4...0.1.5
[0.1.4]: https://github.com/Raenore/Eavesdropper/compare/0.1.3...0.1.4
[0.1.3]: https://github.com/Raenore/Eavesdropper/compare/0.1.2...0.1.3
[0.1.2]: https://github.com/Raenore/Eavesdropper/compare/0.1.1...0.1.2
[0.1.1]: https://github.com/Raenore/Eavesdropper/compare/0.1.0...0.1.1
[0.1.0]: https://github.com/Raenore/Eavesdropper/releases/tag/0.1.0
