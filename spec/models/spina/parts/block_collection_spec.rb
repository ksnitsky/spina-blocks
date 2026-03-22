# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Spina::Parts::BlockCollection, type: :model) do
  subject(:part) { described_class.new }

  describe "#block_ids=" do
    it "stores an array of integers" do
      part.block_ids = [1, 2, 3]

      expect(part.block_ids).to(eq([1, 2, 3]))
    end

    it "filters out blank values" do
      part.block_ids = [1, "", nil, 2]

      expect(part.block_ids).to(eq([1, 2]))
    end

    it "filters out zero values" do
      part.block_ids = ["0", 0, 1, 2]

      expect(part.block_ids).to(eq([1, 2]))
    end

    it "removes duplicates" do
      part.block_ids = [1, 2, 1, 3, 2]

      expect(part.block_ids).to(eq([1, 2, 3]))
    end

    it "converts string values to integers" do
      part.block_ids = ["5", "10"]

      expect(part.block_ids).to(eq([5, 10]))
    end
  end

  describe "#content" do
    context "with valid block_ids" do
      it "returns blocks in the order of block_ids" do
        block_a = create(:spina_blocks_block, active: true)
        block_b = create(:spina_blocks_block, active: true)
        part.block_ids = [block_b.id, block_a.id]

        expect(part.content).to(eq([block_b, block_a]))
      end
    end

    context "with inactive blocks" do
      it "excludes inactive blocks from content" do
        active_block = create(:spina_blocks_block, active: true)
        inactive_block = create(:spina_blocks_block, active: false)
        part.block_ids = [active_block.id, inactive_block.id]

        expect(part.content).to(eq([active_block]))
      end
    end

    context "with empty block_ids" do
      it "returns an empty array" do
        part.block_ids = []

        expect(part.content).to(eq([]))
      end
    end

    context "with nil block_ids" do
      it "returns an empty array" do
        part.block_ids = nil

        expect(part.content).to(eq([]))
      end
    end

    context "with non-existent block_ids" do
      it "skips non-existent blocks" do
        block = create(:spina_blocks_block, active: true)
        part.block_ids = [block.id, 999_999]

        expect(part.content).to(eq([block]))
      end
    end
  end

  describe "#available_blocks" do
    let!(:cta_block) { create(:spina_blocks_block, block_template: "cta", active: true, position: 1) }
    let!(:text_block) { create(:spina_blocks_block, block_template: "text", active: true, position: 2) }
    let!(:inactive_cta) { create(:spina_blocks_block, block_template: "cta", active: false, position: 3) }

    context "without options" do
      it "returns all active blocks sorted by position" do
        expect(part.available_blocks).to(eq([cta_block, text_block]))
      end
    end

    context "with options containing block_template" do
      before { part.options = { block_template: "cta" } }

      it "returns only active blocks matching the template" do
        expect(part.available_blocks).to(eq([cta_block]))
      end

      it "does not include blocks with a different template" do
        expect(part.available_blocks).not_to(include(text_block))
      end

      it "does not include inactive blocks even if template matches" do
        expect(part.available_blocks).not_to(include(inactive_cta))
      end
    end

    context "with options containing string block_template key" do
      before { part.options = { "block_template" => "text" } }

      it "returns only blocks matching the template" do
        expect(part.available_blocks).to(eq([text_block]))
      end
    end

    context "with empty options hash" do
      before { part.options = {} }

      it "returns all active blocks" do
        expect(part.available_blocks).to(eq([cta_block, text_block]))
      end
    end

    context "with options that do not contain block_template" do
      before { part.options = { some_other_key: "value" } }

      it "returns all active blocks" do
        expect(part.available_blocks).to(eq([cta_block, text_block]))
      end
    end

    context "with nil options" do
      before { part.options = nil }

      it "returns all active blocks" do
        expect(part.available_blocks).to(eq([cta_block, text_block]))
      end
    end
  end
end
