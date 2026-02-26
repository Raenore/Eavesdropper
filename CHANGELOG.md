# Changelog

All notable changes to this project will be documented in this file.  

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

[unreleased]: https://github.com/Raenore/Eavesdropper/compare/0.1.5...HEAD
[0.1.5]: https://github.com/Raenore/Eavesdropper/compare/0.1.4...0.1.5
[0.1.4]: https://github.com/Raenore/Eavesdropper/compare/0.1.3...0.1.4
[0.1.3]: https://github.com/Raenore/Eavesdropper/compare/0.1.2...0.1.3
[0.1.2]: https://github.com/Raenore/Eavesdropper/compare/0.1.1...0.1.2
[0.1.1]: https://github.com/Raenore/Eavesdropper/compare/0.1.0...0.1.1
[0.1.0]: https://github.com/Raenore/Eavesdropper/releases/tag/0.1.0
