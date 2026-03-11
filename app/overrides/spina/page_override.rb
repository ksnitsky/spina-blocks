# frozen_string_literal: true

Spina::Page.class_eval do
  has_many :page_blocks, class_name: 'Spina::Blocks::PageBlock', foreign_key: :page_id, dependent: :destroy
  has_many :blocks, through: :page_blocks, class_name: 'Spina::Blocks::Block'
end
