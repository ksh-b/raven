# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0-alpha] - 2024-06-29

### Added
- Ability to add your own sources (Example: https://github.com/raven-repo/sources-world-news)
- Option to bookmark articles
- RSS Feed articles will now show their favicon and URL.
- Import / Export option for saved articles, bookmarks and subscriptions.
- Content filter - Hide articles containing specified keywords
- Network logs (stored locally only)

### Changed
- Navigation - From Bottom Bar to Side Navigation Bar
- Translation - Uses Google's MLKit* instead of SimplyTranslate.

### Removed
- All sources except RSS Feed and Morss

* This may connect to Firebase, although attempts have been made to prevent that.

### Added
- Extractors: Android Police, XDA Developers (#13)
- Option to filter with tags
- Context menu action to translate parts of article (#12)

### Changed
- "Save" button is removed from category selector. Changes are auto saved
- Articles will now be saved with just swipe (#23)
- Ladder options are moved to full article page
- Minor layout changes

### Fixed
- Article sorting (really) (#22)
- Article text not selectable (#32)
- Fixed extractor: Guardian

## [0.14.0] - 2024-06-29

### Added
- Extractors: Android Police, XDA Developers (#13)
- Option to filter with tags
- Context menu action to translate parts of article (#12)

### Changed
- "Save" button is removed from category selector. Changes are auto saved 
- Articles will now be saved with just swipe (#23)
- Ladder options are moved to full article page
- Minor layout changes

### Fixed
- Article sorting (really) (#22)
- Article text not selectable (#32)
- Fixed extractor: Guardian


## [0.13.0] - 2024-06-13

### Fixed
- Fixed/Updated Extractors: APNews, The Guardian, Reuters, Ars Technica, Al Jazeera
- Yahoo trend results showing incorrect data
- Feed not loading when one of the subscription has issue

### Added
- When offline some articles will be shown instead of blank screen 
- Max articles shown per subscription can be adjusted now (earlier only 5 were shown per subscription)

## [0.12.2] - 2024-05-18

### Fixed
- Extractors: AlJazeera, APNews, BBC, CNN, The Guardian, The Verge, Ars Technica
- Next page not loading as intended

### Changed
- 'All' checkbox label to 'Default'. 
- Removed disabling of checkboxes after selecting 'Default'

## [0.12.1] - 2024-05-17

### Fixed
- Sorting (#22)
- Some RSS feeds not loading
- Source: AlJazeera

### Removed
- "All" checkbox from custom category selector

## [0.12.0] - 2024-05-12

### Added
- Option to choose translator instance
- Extractor: RSS/Atom feeds
- Extractor: Morss

### Fixed
- Article content not loading when translation is on

### Removed
- Flags from language selector (#flagsarenotlanguages)

## [0.11.0] - 2024-05-01

### Added
- Font size options (#6)

### Fixed
- Extractors (The Hindu, The Wire)

## [0.10.0] - 2024-04-27

### Added
- Save articles
- Translation on feed page
- Fallback to use smort.io when loading full article fails
- Flags to language selector

### Fixed
- Extractors
- Language selector popup not scrollable

### Removed
- Trend: Brave

## [0.9.0] - 2024-04-14

### Added:
- Source: The Hindu
- Source: The Indian Express
- Material You theme (Android S+)

### Changed:
- Minor layout changes in Settings screen
- Updated extractors: AlJazeera, APNews, BBC, CNN

## [0.8.3] - 2024-04-09

### Fixed:
- Scroll issue in category selector
- Quint search

## [0.8.2] - 2024-04-07

Fdroid release

## [0.8.1] - 2024-04-07

### Added:
- Source: AP News
- Source: CNN

### Fixed:
- Extractor: BBC


## [0.7.1] - 2024-03-31

### Changed:
- Concurrent loading from sources instead of serially

### Added:
- Source: The Guardian

### Fixed:
- Refresh (again)


## [0.6.0] - 2024-03-24

### Changed:
- App name
- Subscription page layout
- Settings page layout

### Fixed:
- Second refresh showing previous articles


## [0.5.2] - 2024-01-19

### Added:
- Search bar - search subscribed publishers
- Search trends (suggestions in search bar)
  - APNews
  - Brave
  - Google
  - Yahoo
- Setting to change preferred search trend provider
- Tags for articles in feed page
- This changelog file

### Fixed:
- Fixed extractors
- Thumbnails in feed and article page will take full width


## [0.2.0] - 2024-01-19

### Added:
- Source: The Quint 
- Translation from SimplyTranslate

### Updated:
- Added thumbnail image for articles on feed page 
- Minor layout changes

### Removed:
- Search bar on feed page (planning to add back later with better functionality)
- Nitter support. Refer this article

## [0.1.2] - 2024-01-19

### Fixed
- Extractors

### Changed
-  Excerpt styling in full article page

## [0.1.1] - 2024-01-01

### Added

- Source: Arstechnica
- Source: BleepingComputer
- Source: Engadget
- Source: Nitter

## [0.1.0] - 2023-12-29

### Added

- Publisher: Al Jazeera
- Publisher: BBC
- Settings page (Themes, Article)
- Option to share/open article URL
- Icons on subscriptions page

### Changed

- Minor layout changes

## [0.0.2] - 2023-12-26

### Fixed

- Subscription selection related issues

## [0.0.1] - 2023-12-29

### First Release

[unreleased]: https://github.com/ksh-b/raven/compare/v0.14.0...HEAD
[0.14.0]: https://github.com/ksh-b/raven/compare/v0.13.0...v0.14.0
[0.13.0]: https://github.com/ksh-b/raven/compare/v0.12.2...v0.13.0
[0.12.2]: https://github.com/ksh-b/raven/compare/v0.12.1...v0.12.2
[0.12.1]: https://github.com/ksh-b/raven/compare/v0.12.0...v0.12.1
[0.12.0]: https://github.com/ksh-b/raven/compare/v0.11.0...v0.12.0
[0.11.0]: https://github.com/ksh-b/raven/compare/v0.10.0...v0.11.0
[0.10.0]: https://github.com/ksh-b/raven/compare/v0.9.0...v0.10.0
[0.9.0]: https://github.com/ksh-b/raven/compare/v0.8.3...v0.9.0
[0.8.3]: https://github.com/ksh-b/raven/compare/v0.8.2...v0.8.3
[0.8.2]: https://github.com/ksh-b/raven/compare/v0.8.1...v0.8.2
[0.8.1]: https://github.com/ksh-b/raven/compare/v0.7.1...v0.8.1
[0.7.1]: https://github.com/ksh-b/raven/compare/v0.6.0...v0.7.1
[0.6.0]: https://github.com/ksh-b/raven/compare/v0.5.2...v0.6.0
[0.5.2]: https://github.com/ksh-b/raven/compare/v0.2.0...v0.5.2
[0.2.0]: https://github.com/ksh-b/raven/compare/v0.1.2...v0.2.0
[0.1.2]: https://github.com/ksh-b/raven/compare/v0.1.1...v0.1.2
[0.1.1]: https://github.com/ksh-b/raven/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/ksh-b/raven/compare/v0.0.2...v0.1.0
[0.0.2]: https://github.com/ksh-b/raven/compare/v0.0.1...v0.0.2
[0.0.1]: https://github.com/ksh-b/raven/releases/tag/v0.0.1
