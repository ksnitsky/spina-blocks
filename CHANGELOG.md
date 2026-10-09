# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.5.0] - 2026-10-09

### Added

- `BlockReference` can offer an inline (page-local) content mode. Opt in per part with `options: { block_template: "...", inline: true }` (#16, #17).

### Changed

- **Breaking:** requires Spina `>= 2.21, < 3`. Spina 2.21 compiles its admin CSS with Tailwind CSS 4, and the admin views now use Tailwind 4 utility names. Stay on 0.4.x for Spina 2.20 and older.
- Admin views: `shadow-sm` → `shadow-xs`, `focus:outline-none` → `focus:outline-hidden`, and `bg-opacity-*` → slash opacity (`bg-gray-400/25`, `bg-gray-900/5`).
- Added `cursor-pointer` to the buttons that aren't `.btn` (block pickers, add/remove buttons, template filter), because Tailwind 4 no longer gives buttons a pointer cursor.

### Fixed

- The Spina Pro search result for a block no longer renders with a solid gray background under Tailwind 4.

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
