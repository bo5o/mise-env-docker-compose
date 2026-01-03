# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

### Added

- CHANGELOG.md following Keep a Changelog format

## [0.2.1] - 2026-01-03

### Added

- Added documentation for `include_build_args` configuration option

## [0.2.0] - 2026-01-03

### Added

- Option to include build arguments from Docker Compose services via
  `include_build_args` configuration

## [0.1.0] - 2025-11-23

### Added

- Initial release of mise-env-docker-compose plugin
- Support for loading environment variables from Docker Compose configuration
- Service filtering via `services` configuration option
- Variable filtering via `variables` configuration option
- Host replacement functionality via `replace_hosts` configuration option
- MIT License

[0.1.0]: https://github.com/bo5o/mise-env-docker-compose/releases/tag/0.1.0
[0.2.0]: https://github.com/bo5o/mise-env-docker-compose/compare/0.1.0...0.2.0
[0.2.1]: https://github.com/bo5o/mise-env-docker-compose/compare/0.2.0...0.2.1
[unreleased]: https://github.com/bo5o/mise-env-docker-compose/compare/0.2.1...HEAD
