# frozen_string_literal: true

Spina::Theme.register do |theme|
  theme.name = 'default'
  theme.title = 'Default'

  theme.page_parts = []
  theme.view_templates = []
  theme.custom_pages = []
  theme.plugins = ['blocks']

  theme.block_categories = [
    { name: 'general', label: 'General' },
    { name: 'sidebar', label: 'Sidebar' }
  ]

  theme.block_templates = [
    { name: 'text', title: 'Text Block', parts: [] }
  ]
end
