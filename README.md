# Spina Blocks

> **Warning**: This plugin is not production-ready and may cause issues. Use at your own risk.

A plugin for [Spina CMS](https://www.spinacms.com) that adds reusable block components. Blocks are independent content units with their own templates and fields that can be assembled into pages.

## Installation

Add to your Gemfile:

```ruby
gem "spina-blocks"
```

Run:

```bash
bundle install
rails generate spina:blocks:install
```

This copies the plugin's migrations into your app and runs `db:migrate`.

## Upgrading

If you are upgrading from a version that used timestamp migrations (`20250101000001`–`20250101000004`), the new migrations will detect the old version numbers in your `schema_migrations` table, clean them up automatically, and skip any tables that already exist. No manual intervention is needed.

## Configuration

### Theme setup

In your theme initializer, add block templates and categories:

```ruby
# config/initializers/themes/my_theme.rb
Spina::Theme.register do |theme|
  theme.name = "my_theme"
  theme.title = "My Theme"

  # Enable the blocks plugin
  theme.plugins = ["blocks"]

  # Define all available parts (shared between pages and blocks)
  theme.parts = [
    { name: "headline", title: "Headline", part_type: "Spina::Parts::Line" },
    { name: "body", title: "Body", part_type: "Spina::Parts::Text" },
    { name: "image", title: "Image", part_type: "Spina::Parts::Image" },
    { name: "button_text", title: "Button Text", part_type: "Spina::Parts::Line" },
    { name: "button_url", title: "Button URL", part_type: "Spina::Parts::Line" }
  ]

  # Block categories (for organizing blocks in the library)
  theme.block_categories = [
    { name: "heroes", label: "Heroes" },
    { name: "features", label: "Features" },
    { name: "cta", label: "Call to Action" }
  ]

  # Block templates (which parts each block type uses)
  theme.block_templates = [
    {
      name: "hero",
      title: "Hero Section",
      description: "Full-width hero with headline and image",
      parts: ["headline", "body", "image", "button_text", "button_url"]
    },
    {
      name: "cta_banner",
      title: "CTA Banner",
      description: "Call to action banner",
      parts: ["headline", "body", "button_text", "button_url"]
    }
  ]

  # Custom blocks (layout blocks, created automatically during bootstrap)
  theme.custom_blocks = [
    { name: "header", title: "Header Block", block_template: "header", category: "heroes" },
    { name: "footer", title: "Footer Block", block_template: "footer", category: "cta" }
  ]

  # Page templates (can use BlockCollection or BlockReference parts)
  theme.view_templates = [
    {
      name: "homepage",
      title: "Homepage",
      parts: ["headline", "page_blocks"]
    }
  ]
end
```

### Block view templates

Create partials for each block template:

```erb
<%# app/views/my_theme/blocks/_hero.html.erb %>
<section class="hero">
  <h1><%= block_content(block, :headline) %></h1>
  <div><%= block.content(:body) %></div>
</section>
```

### Using blocks on pages

#### Option 1: Page assembled from blocks (via PageBlocks)

In your page template, render all attached blocks:

```erb
<%# app/views/my_theme/pages/homepage.html.erb %>
<%= render_blocks %>
```

Manage which blocks appear on a page via Admin > Blocks > (select page).

#### Option 2: Block as a part type

Use `Spina::Parts::BlockReference` for a single block or `Spina::Parts::BlockCollection` for multiple blocks in your theme parts:

```ruby
theme.parts = [
  { name: "hero_block", title: "Hero Block", part_type: "Spina::Parts::BlockReference" },
  { name: "page_blocks", title: "Page Blocks", part_type: "Spina::Parts::BlockCollection" }
]
```

#### Filtering blocks by template

By default, `BlockReference` and `BlockCollection` show all active blocks in their selects. To limit the list to blocks of a specific template, pass `block_template` in the part's `options`:

```ruby
theme.parts = [
  { name: "hero_block", title: "Hero Block",
    part_type: "Spina::Parts::BlockReference",
    options: { block_template: "hero" } },

  { name: "sidebar_blocks", title: "Sidebar Blocks",
    part_type: "Spina::Parts::BlockCollection",
    options: { block_template: "sidebar_widget" } }
]
```

With this configuration, the "Hero Block" select will only show blocks created with the `hero` template, and "Sidebar Blocks" will only show `sidebar_widget` blocks. If `options` is omitted or does not contain `block_template`, all active blocks are shown (the default behavior).

#### Filling a reference in inline

A `BlockReference` normally points at a shared block. Pass `inline: true` to also let editors fill the block template's fields in on the page itself, storing that content in the page rather than in a block record:

```ruby
theme.parts = [
  { name: "testimonials", title: "Testimonials",
    part_type: "Spina::Parts::BlockReference",
    options: { block_template: "testimonials", inline: true } }
]
```

The part form then offers two modes: **Select existing** (pick a shared block) and **Fill in here** (page-local content). Both render through the same block template partial, so `render_block(content(:testimonials))` is unchanged and the output is identical either way.

Offering inline mode requires `block_template` — it is the field set editors fill in — and it is not available on parts bound to a `custom_block`. Without `inline: true` the part stays a plain block picker.

Content already stored inline keeps rendering whatever you change later — the gate applies to the editor, not to rendering:

- Remove `inline: true`: the content still shows on the site, and the page editor presents it as read-only rather than offering a block picker that couldn't override it.
- Remove `block_template` but keep `inline: true`: the content stays editable, because the form falls back to the template it was filled in against.

Either way a save preserves the stored content untouched.

`inline: true` controls what the page editor offers, not what the model accepts; it is an authoring affordance rather than an access control.

Then in your template:

```erb
<%# Single block reference %>
<%= render_block(content(:hero_block)) %>

<%# Block collection %>
<% content(:page_blocks)&.each do |block| %>
  <%= render_block(block) %>
<% end %>
```

### Yielding content into block templates

`render_block` and `render_custom_block` forward an optional content block to the partial, so block templates can expose `<%= yield %>` slots that callers fill at render time. This lets a single shared block adapt per-page without splitting it into template variants.

In the block partial:

```erb
<%# app/views/my_theme/blocks/_funnel_form.html.erb %>
<section class="funnel-form">
  <% if block_given? %>
    <%= yield %>
  <% end %>
  <%# ...rest of the form... %>
</section>
```

In the page that includes it:

```erb
<%= render_block(content(:funnel_form_block)) do %>
  <% if (banner = content(:discount_banner_section))&.content(:enabled) %>
    <%= render "default/shared/blocks/discount_banner", block: banner %>
  <% end %>
<% end %>
```

Pages without anything to inject just call `render_block(...)` without a block — `block_given?` is `false` and the slot stays empty.

## Custom blocks (layout blocks)

Custom blocks are non-deletable blocks that are automatically created during `rake spina:bootstrap`. They work similarly to Spina's `custom_pages` — once defined in the theme configuration, they are created on bootstrap and cannot be deleted through the admin interface. In the admin UI they are labeled as **Layout** blocks.

### Defining custom blocks

Add `custom_blocks` to your theme initializer:

```ruby
theme.custom_blocks = [
  { name: "header", title: "Header Block", block_template: "header", category: "heroes" },
  { name: "footer", title: "Footer Block", block_template: "footer", category: "cta" }
]
```

Each custom block accepts:

| Key              | Description                                                              |
| ---------------- | ------------------------------------------------------------------------ |
| `name`           | Immutable machine key (used for lookups in code and templates)            |
| `title`          | (Optional) Initial display name shown in admin. Defaults to `name.titleize`. Editable by users after creation |
| `block_template` | Must match a template defined in `theme.block_templates`                 |
| `category`       | (Optional) Name of a category from `theme.block_categories`              |

### Key vs Name

Custom blocks have two identifiers:

- **`key`** — an immutable machine identifier (set from `name` in the config). Used by `render_custom_block`, `BlockReference` with `custom_block` option, and for bootstrap lookups. Cannot be changed after creation. Shown as read-only in the block settings tab.
- **`name`** — the display name shown in the admin UI. Initially set from `title` (or `name.titleize` if `title` is omitted). Users can freely rename it without breaking any template references.

Regular (non-layout) blocks do not have a `key` — it is `nil` for them.

### How it works

- **Bootstrap**: Custom blocks are created (or updated) automatically whenever `Spina::Account` is saved — this includes `rake spina:bootstrap` and admin account edits. They are created with `deletable: false` and an immutable `key`.
- **Idempotent**: Running bootstrap multiple times will not duplicate blocks. Existing blocks are found by `key` and updated. The display `name` is only set on initial creation — subsequent bootstraps preserve user edits to the display name.
- **Deletion protection**: Layout blocks cannot be deleted through the admin UI or programmatically via `destroy`. In the block editor, the `...` menu shows "Block can't be deleted" (matching Spina's page behavior). The controller also rejects delete requests.
- **Template restriction**: Block templates used by custom blocks are excluded from the "New block" form, preventing users from manually creating blocks with layout templates.
- **Admin UI**: Layout blocks are marked with a **Layout** badge (right-aligned) in the block library. A **Layout blocks** filter is available in the template filter dropdown. On page block lists, the remove button is replaced with a "Layout" label. The `key` is displayed as read-only in the block settings tab.

### Using custom blocks in templates

#### Direct rendering by key

Use `render_custom_block` to render a system block directly in any template:

```erb
<%# app/views/my_theme/pages/homepage.html.erb %>
<%= render_custom_block("header") %>

<main>
  <%= render_blocks %>
</main>

<%= render_custom_block("footer") %>
```

This looks up the block by its immutable `key` and renders it using the block's template partial, just like `render_block`. Renaming the block's display name in the admin will not affect this lookup.

#### As a pre-defined BlockReference

Use the `custom_block` option in a `BlockReference` part to hardcode which block it points to:

```ruby
theme.parts = [
  { name: "header_block", title: "Header",
    part_type: "Spina::Parts::BlockReference",
    options: { custom_block: "header" } },

  { name: "footer_block", title: "Footer",
    part_type: "Spina::Parts::BlockReference",
    options: { custom_block: "footer" } }
]
```

When `custom_block` is set:
- The part's `content` method returns the block by `key` (ignoring `block_id`)
- In the admin form, instead of a dropdown, a clickable link to the block's edit page is shown
- If the custom block does not exist yet, a warning message is displayed

Then in your template:

```erb
<%= render_block(content(:header_block)) %>
<%= render_block(content(:footer_block)) %>
```

## Models

| Model                      | Description                                        |
| -------------------------- | -------------------------------------------------- |
| `Spina::Blocks::Block`     | Reusable content block with template and parts     |
| `Spina::Blocks::Category`  | Block category for organizing the library          |
| `Spina::Blocks::PageBlock` | Join model linking blocks to pages (with position) |

## Admin interface

The plugin adds:

- **Blocks** link in the Content section of the admin sidebar
- Block library with template filter dropdown
- Block editor with content fields (same as page editor)
- Page Blocks management page (per-page block assignment and ordering)
- **Layout** badge on non-deletable blocks in the block library (right-aligned)
- **Layout blocks** filter in the template filter dropdown
- `...` menu shows "Block can't be deleted" for layout blocks (like Spina pages)
- Block templates used by layout blocks are hidden from the "New block" form
- Immutable **key** shown as read-only in block settings for layout blocks

## Helper methods

| Helper                                  | Description                                            |
| --------------------------------------- | ------------------------------------------------------ |
| `render_blocks(page)`                   | Render all blocks attached to a page via PageBlocks    |
| `render_block(block, &content_block)`   | Render a single block using its template partial; an optional content block is forwarded to the partial via `yield` |
| `render_custom_block(key, &content_block)` | Render a custom (layout) block by its immutable key; forwards a content block to the partial like `render_block`  |
| `block_content(block, :part_name)`      | Access a block's content                               |
| `block_has_content?(block, :part_name)` | Check if a block has content                           |

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
