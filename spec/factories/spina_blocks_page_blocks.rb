# frozen_string_literal: true

FactoryBot.define do
  factory :spina_blocks_page_block, class: 'Spina::Blocks::PageBlock' do
    association :page, factory: :spina_page
    association :block, factory: :spina_blocks_block
    position { 0 }
  end
end
