# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Spina::Blocks::AccountExtension, type: :model) do
  describe "inclusion in Spina::Account" do
    it "is included in Spina::Account" do
      expect(Spina::Account.ancestors).to(include(described_class))
    end
  end

  describe "bootstrap_block_categories callback" do
    let(:account) { create(:spina_account) }

    it "creates block categories from theme configuration on save" do
      expect do
        account.update!(name: "Updated Website")
      end.to(change(Spina::Blocks::Category, :count))

      expect(Spina::Blocks::Category.find_by(name: "general")).to(have_attributes(
        label: "General",
        position: 0,
      ))
      expect(Spina::Blocks::Category.find_by(name: "sidebar")).to(have_attributes(
        label: "Sidebar",
        position: 1,
      ))
    end

    it "updates existing categories rather than duplicating" do
      Spina::Blocks::Category.create!(name: "general", label: "Old Label")

      # only 'sidebar' is new
      expect do
        account.update!(name: "Updated Website")
      end.to(change(Spina::Blocks::Category, :count).by(1))
      expect(Spina::Blocks::Category.find_by(name: "general").label).to(eq("General"))
    end
  end
end
