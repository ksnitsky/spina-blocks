# frozen_string_literal: true

FactoryBot.define do
  factory :spina_blocks_block, class: "Spina::Blocks::Block" do
    sequence(:title) { |n| "Block #{n}" }
    block_template { "text" }
    active { true }
    position { 0 }
    association :category, factory: :spina_blocks_category
  end
end
