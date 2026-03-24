# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Spina::Blocks::Block, type: :model) do
  subject(:block) { build(:spina_blocks_block) }

  describe "validations" do
    it { is_expected.to(be_valid) }

    it "requires a name" do
      block.name = nil
      expect(block).not_to(be_valid)
      expect(block.errors[:name]).to(include("can't be blank"))
    end

    it "requires a block_template" do
      block.block_template = nil
      expect(block).not_to(be_valid)
      expect(block.errors[:block_template]).to(include("can't be blank"))
    end

    it "allows nil key" do
      block.key = nil
      expect(block).to(be_valid)
    end

    it "enforces unique key (when not nil)" do
      create(:spina_blocks_block, :system, key: "unique_key")
      block.key = "unique_key"
      expect(block).not_to(be_valid)
      expect(block.errors[:key]).to(include("has already been taken"))
    end
  end

  describe "key immutability" do
    it "prevents changing key on update" do
      system_block = create(:spina_blocks_block, :system, key: "original_key")
      system_block.key = "new_key"

      expect(system_block).not_to(be_valid)
      expect(system_block.errors[:key]).to(be_present)
    end

    it "allows updating other attributes without changing key" do
      system_block = create(:spina_blocks_block, :system, key: "my_key")
      system_block.name = "Updated Name"

      expect(system_block).to(be_valid)
    end

    it "allows setting key to nil on a block that had no key" do
      regular_block = create(:spina_blocks_block, key: nil)
      regular_block.key = nil

      expect(regular_block).to(be_valid)
    end
  end

  describe "#system?" do
    it "returns true when key is present" do
      block.key = "header"
      expect(block.system?).to(be(true))
    end

    it "returns false when key is nil" do
      block.key = nil
      expect(block.system?).to(be(false))
    end

    it "returns false when key is blank" do
      block.key = ""
      expect(block.system?).to(be(false))
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

    it ".deletable returns only deletable blocks" do
      deletable_block = create(:spina_blocks_block, deletable: true)
      create(:spina_blocks_block, :undeletable)

      expect(described_class.deletable).to(eq([deletable_block]))
    end

    it ".undeletable returns only undeletable blocks" do
      create(:spina_blocks_block, deletable: true)
      undeletable_block = create(:spina_blocks_block, :undeletable)

      expect(described_class.undeletable).to(eq([undeletable_block]))
    end
  end

  describe "deletion protection" do
    it "allows destroying a deletable block" do
      deletable_block = create(:spina_blocks_block, deletable: true)

      expect { deletable_block.destroy }.to(change(described_class, :count).by(-1))
    end

    it "prevents destroying an undeletable block" do
      undeletable_block = create(:spina_blocks_block, :undeletable)

      expect { undeletable_block.destroy }.not_to(change(described_class, :count))
    end

    it "adds an error when trying to destroy an undeletable block" do
      undeletable_block = create(:spina_blocks_block, :undeletable)
      undeletable_block.destroy

      expect(undeletable_block.errors[:base]).to(be_present)
    end

    it "defaults to deletable: true for new blocks" do
      new_block = described_class.new
      expect(new_block.deletable).to(be(true))
    end
  end

  describe "#to_s" do
    it "returns the name" do
      block.name = "My Block"
      expect(block.to_s).to(eq("My Block"))
    end
  end
end
