# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Spina::Parts::BlockReference, type: :model) do
  subject(:part) { described_class.new }

  describe "#content" do
    context "when block_id refers to an active block" do
      it "returns the block" do
        block = create(:spina_blocks_block, active: true)
        part.block_id = block.id

        expect(part.content).to(eq(block))
      end
    end

    context "when block_id refers to an inactive block" do
      it "returns nil" do
        block = create(:spina_blocks_block, active: false)
        part.block_id = block.id

        expect(part.content).to(be_nil)
      end
    end

    context "when block_id refers to a non-existent block" do
      it "returns nil" do
        part.block_id = 999_999

        expect(part.content).to(be_nil)
      end
    end

    context "when block_id is nil" do
      it "returns nil" do
        part.block_id = nil

        expect(part.content).to(be_nil)
      end
    end
  end

  describe "#available_blocks" do
    let!(:hero_block) { create(:spina_blocks_block, block_template: "hero", active: true, position: 1) }
    let!(:text_block) { create(:spina_blocks_block, block_template: "text", active: true, position: 2) }
    let!(:inactive_hero) { create(:spina_blocks_block, block_template: "hero", active: false, position: 3) }

    context "without options" do
      it "returns all active blocks sorted by position" do
        expect(part.available_blocks).to(eq([hero_block, text_block]))
      end
    end

    context "with options containing block_template" do
      before { part.options = { block_template: "hero" } }

      it "returns only active blocks matching the template" do
        expect(part.available_blocks).to(eq([hero_block]))
      end

      it "does not include blocks with a different template" do
        expect(part.available_blocks).not_to(include(text_block))
      end

      it "does not include inactive blocks even if template matches" do
        expect(part.available_blocks).not_to(include(inactive_hero))
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
        expect(part.available_blocks).to(eq([hero_block, text_block]))
      end
    end

    context "with options that do not contain block_template" do
      before { part.options = { some_other_key: "value" } }

      it "returns all active blocks" do
        expect(part.available_blocks).to(eq([hero_block, text_block]))
      end
    end

    context "with nil options" do
      before { part.options = nil }

      it "returns all active blocks" do
        expect(part.available_blocks).to(eq([hero_block, text_block]))
      end
    end
  end
end
