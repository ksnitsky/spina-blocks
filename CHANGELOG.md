# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.4.0] - 2026-05-02

### Added

- `render_block` and `render_custom_block` now accept and forward a content block, allowing block templates to expose `<%= yield %>` slots for callers to inject markup.
- `ContentBlocks` part type for flexible page content composed of multiple content blocks.
- `NestedContentBlocks` part type for nested content-block contexts.
- Ability to mark blocks as undeleteable (#11).

### Changed

- Extracted shared dropdown positioning utility used by content-block UIs.

### Fixed

- Use dynamic identifier in `removeBlock` and `toggleCollapse` selectors so multiple instances on the same page work correctly (#13).

## [0.3.1]

See git history for changes prior to 0.4.0.
