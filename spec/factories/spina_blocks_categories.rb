# frozen_string_literal: true

FactoryBot.define do
  factory :spina_blocks_category, class: "Spina::Blocks::Category" do
    sequence(:name) { |n| "category_#{n}" }
    sequence(:label) { |n| "Category #{n}" }
    position { 0 }
  end
end
