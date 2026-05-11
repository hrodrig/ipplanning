# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

## [0.9.2] - 2026-05-09

### Added

- Light/dark theme toggle with persisted preference (`localStorage`) and Stimulus `theme_controller`.
- Sign-in page layout with network imagery, Unsplash attribution, and improved contrast for both themes.
- README screenshots for login and IP planning views; SPECIFICATIONS §3.12 documents theme and sign-in presentation.

### Changed

- Application layout and Tailwind setup for theme-aware styling (`@custom-variant dark`, `ipplanning-theme` tokens).
- English and Spanish locale strings for theme UI and sign-in copy.

### Fixed

- Server rack destroy flash prefers rack-specific host/switch messages when `restrict_with_error` blocks deletion.
- Model tests use IP addresses inside fixture VLAN subnets where validation requires it.

[Unreleased]: https://github.com/hrodrig/ipplanning/compare/v0.9.2...HEAD
[0.9.2]: https://github.com/hrodrig/ipplanning/compare/c63a837...v0.9.2
