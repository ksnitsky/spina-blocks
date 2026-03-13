# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Spina::Blocks::Block, type: :model) do
  subject(:block) { build(:spina_blocks_block) }

  describe "validations" do
    it { is_expected.to(be_valid) }

    it "requires a title" do
      block.title = nil
      expect(block).not_to(be_valid)
      expect(block.errors[:title]).to(include("can't be blank"))
    end

    it "requires a block_template" do
      block.block_template = nil
      expect(block).not_to(be_valid)
      expect(block.errors[:block_template]).to(include("can't be blank"))
    end
  end

  describe "associations" do
    it "belongs to category (optional)" do
      association = described_class.reflect_on_association(:category)
      expect(association.macro).to(eq(:belongs_to))
    end

    it "has many page_blocks" do
      expect(described_class.reflect_on_association(:page_blocks).macro).to(eq(:has_many))
    end

    it "has many pages through page_blocks" do
      association = described_class.reflect_on_association(:pages)
      expect(association.macro).to(eq(:has_many))
      expect(association.options[:through]).to(eq(:page_blocks))
    end
  end

  describe "scopes" do
    it ".active returns only active blocks" do
      active_block = create(:spina_blocks_block, active: true)
      create(:spina_blocks_block, active: false)

      expect(described_class.active).to(eq([active_block]))
    end

    it ".sorted orders by position" do
      second = create(:spina_blocks_block, position: 2)
      first = create(:spina_blocks_block, position: 1)

      expect(described_class.sorted).to(eq([first, second]))
    end
  end

  describe "#to_s" do
    it "returns the title" do
      block.title = "My Block"
      expect(block.to_s).to(eq("My Block"))
    end
  end
end
