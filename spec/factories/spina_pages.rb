# frozen_string_literal: true

FactoryBot.define do
  factory :spina_page, class: 'Spina::Page' do
    sequence(:title) { |n| "Page #{n}" }
    draft { false }
    active { true }
  end
end
