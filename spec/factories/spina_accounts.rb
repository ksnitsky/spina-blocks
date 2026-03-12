# frozen_string_literal: true

FactoryBot.define do
  factory :spina_account, class: 'Spina::Account' do
    name { 'Test Website' }
    email { 'test@example.com' }
    preferences { { 'theme' => 'default' } }
  end
end
