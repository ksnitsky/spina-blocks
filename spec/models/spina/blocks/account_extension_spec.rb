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

  describe "bootstrap_custom_blocks callback" do
    let(:account) { create(:spina_account) }

    it "creates custom blocks from theme configuration on save" do
      expect do
        account.update!(name: "Updated Website")
      end.to(change(Spina::Blocks::Block, :count))

      header_block = Spina::Blocks::Block.find_by(key: "header")
      expect(header_block).to(have_attributes(
        name: "Header Block",
        block_template: "text",
        deletable: false,
        active: true,
        key: "header",
      ))
    end

    it "assigns the category to custom blocks" do
      account.update!(name: "Updated Website")

      header_block = Spina::Blocks::Block.find_by(key: "header")
      expect(header_block.category).to(have_attributes(name: "general"))
    end

    it "does not duplicate custom blocks on subsequent saves" do
      account.update!(name: "First Save")

      expect do
        account.update!(name: "Second Save")
      end.not_to(change(Spina::Blocks::Block, :count))
    end

    it "uses title from config as display name" do
      account.update!(name: "Bootstrap")

      header_block = Spina::Blocks::Block.find_by(key: "header")
      expect(header_block.name).to(eq("Header Block"))
    end

    it "preserves user-edited display name on subsequent bootstraps" do
      account.update!(name: "First Bootstrap")

      header_block = Spina::Blocks::Block.find_by(key: "header")
      header_block.update!(name: "My Custom Header")

      account.update!(name: "Second Bootstrap")

      header_block.reload
      expect(header_block.name).to(eq("My Custom Header"))
    end

    it "updates block_template and category on subsequent bootstraps" do
      account.update!(name: "First Bootstrap")

      header_block = Spina::Blocks::Block.find_by(key: "header")
      expect(header_block.block_template).to(eq("text"))
      expect(header_block.category.name).to(eq("general"))
    end

    it "marks existing blocks as undeletable when they match a custom_block key" do
      existing = Spina::Blocks::Block.create!(
        name: "Old Header",
        block_template: "old_template",
        key: "header",
        deletable: true,
      )

      account.update!(name: "Bootstrap")

      existing.reload
      expect(existing).to(have_attributes(
        name: "Old Header",
        block_template: "text",
        deletable: false,
      ))
    end

    it "preserves the active state of existing custom blocks" do
      Spina::Blocks::Block.create!(
        name: "Header",
        block_template: "text",
        key: "header",
        active: false,
        deletable: true,
      )

      account.update!(name: "Bootstrap")

      header_block = Spina::Blocks::Block.find_by(key: "header")
      expect(header_block.active).to(be(false))
    end
  end
end
