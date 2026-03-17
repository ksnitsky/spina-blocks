# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Spina::Blocks::PageBlock, type: :model) do
  subject(:page_block) { build(:spina_blocks_page_block) }

  describe "validations" do
    it { is_expected.to(be_valid) }

    it "requires a unique block per page" do
      existing = create(:spina_blocks_page_block)
      page_block.page = existing.page
      page_block.block = existing.block
      expect(page_block).not_to(be_valid)
      expect(page_block.errors[:block_id]).to(include("has already been taken"))
    end
  end

  describe "associations" do
    it "belongs to page" do
      association = described_class.reflect_on_association(:page)
      expect(association.macro).to(eq(:belongs_to))
    end

    it "belongs to block" do
      association = described_class.reflect_on_association(:block)
      expect(association.macro).to(eq(:belongs_to))
    end
  end

  describe "scopes" do
    it ".sorted orders by position" do
      second = create(:spina_blocks_page_block, position: 2)
      first = create(:spina_blocks_page_block, position: 1)

      expect(described_class.sorted).to(eq([first, second]))
    end
  end
end
