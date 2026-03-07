# Spina Blocks

A plugin for [Spina CMS](https://www.spinacms.com) that adds reusable block components. Blocks are independent content units with their own templates and fields that can be assembled into pages.

## Installation

Add to your Gemfile:

```ruby
gem "spina-blocks"
```

Run:

```bash
bundle install
rails db:migrate
```

## Configuration

### Theme setup

In your theme initializer, add block templates and categories:

```ruby
# config/initializers/themes/my_theme.rb
Spina::Theme.register do |theme|
  theme.name = "my_theme"
  theme.title = "My Theme"

  # Enable the blocks plugin
  theme.plugins = ["spina_blocks"]

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

Manage which blocks appear on a page via Admin > Pages > [Page] > Manage Blocks.

#### Option 2: Block as a part type

Use `Spina::Parts::BlockReference` for a single block or `Spina::Parts::BlockCollection` for multiple blocks in your theme parts:

```ruby
theme.parts = [
  { name: "hero_block", title: "Hero Block", part_type: "Spina::Parts::BlockReference" },
  { name: "page_blocks", title: "Page Blocks", part_type: "Spina::Parts::BlockCollection" }
]
```

Then in your template:

```erb
<%# Single block reference %>
<%= render_block(content(:hero_block)) %>

<%# Block collection %>
<% content(:page_blocks)&.each do |block| %>
  <%= render_block(block) %>
<% end %>
```

## Admin interface

The plugin adds:

- **Blocks** link in the Content section of the admin sidebar
- Block library with category tabs for filtering
- Block editor with content fields (same as page editor)
- Page Blocks management page (accessible from page edit)

## Helper methods

| Helper | Description |
|--------|-------------|
| `render_blocks(page)` | Render all blocks attached to a page via PageBlocks |
| `render_block(block)` | Render a single block using its template partial |
| `block_content(block, :part_name)` | Access a block's content |
| `block_has_content?(block, :part_name)` | Check if a block has content |

## License

MIT
