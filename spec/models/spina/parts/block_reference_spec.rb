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

  describe "#content with custom_block option" do
    let!(:custom_block) { create(:spina_blocks_block, :system, key: "header", active: true) }

    context "with symbol key" do
      before { part.options = { custom_block: "header" } }

      it "returns the block by key" do
        expect(part.content).to(eq(custom_block))
      end

      it "ignores block_id when custom_block is set" do
        other_block = create(:spina_blocks_block, active: true)
        part.block_id = other_block.id

        expect(part.content).to(eq(custom_block))
      end
    end

    context "with string key" do
      before { part.options = { "custom_block" => "header" } }

      it "returns the block by key" do
        expect(part.content).to(eq(custom_block))
      end
    end

    context "when custom_block refers to a non-existent key" do
      before { part.options = { custom_block: "non_existent" } }

      it "returns nil" do
        expect(part.content).to(be_nil)
      end
    end

    context "when custom_block option is nil" do
      before { part.options = { custom_block: nil } }

      it "falls back to block_id lookup" do
        block = create(:spina_blocks_block, active: true)
        part.block_id = block.id

        expect(part.content).to(eq(block))
      end
    end

    context "when block has key but user renames its display name" do
      it "still finds the block by key regardless of name" do
        custom_block.update!(name: "Totally Different Name")
        part.options = { custom_block: "header" }

        expect(part.content).to(eq(custom_block))
      end
    end
  end

  describe "inline mode" do
    def filled_inline_content
      rc = Spina::Parts::RepeaterContent.new
      rc.parts = [Spina::Parts::Line.new(name: "section_title", content: "Reviews")]
      rc
    end

    def empty_inline_content
      rc = Spina::Parts::RepeaterContent.new
      rc.parts = [Spina::Parts::Line.new(name: "section_title")]
      rc
    end

    describe "#inline?" do
      it "is false when mode is nil (backward compatible)" do
        part.mode = nil
        expect(part.inline?).to(be(false))
      end

      it "is false when mode is reference" do
        part.mode = "reference"
        expect(part.inline?).to(be(false))
      end

      it "is true when mode is inline" do
        part.mode = "inline"
        expect(part.inline?).to(be(true))
      end
    end

    describe "#block_template_name" do
      it "reads block_template from options (symbol or string key)" do
        part.options = { block_template: "testimonials_block" }
        expect(part.block_template_name).to(eq("testimonials_block"))

        part.options = { "block_template" => "testimonials_block" }
        expect(part.block_template_name).to(eq("testimonials_block"))
      end

      it "returns nil without options" do
        part.options = nil
        expect(part.block_template_name).to(be_nil)
      end
    end

    describe "#content" do
      before { part.options = { block_template: "testimonials_block" } }

      it "returns an InlineBlock bound to the template when filled" do
        part.mode = "inline"
        part.inline_content = filled_inline_content

        result = part.content
        expect(result).to(be_a(Spina::Blocks::InlineBlock))
        expect(result.block_template).to(eq("testimonials_block"))
        expect(result.content(:section_title)).to(eq("Reviews"))
      end

      it "uses the persisted inline_block_template when no options are attached" do
        part.options = nil
        part.mode = "inline"
        part.inline_block_template = "testimonials_block"
        part.inline_content = filled_inline_content

        result = part.content
        expect(result).to(be_a(Spina::Blocks::InlineBlock))
        expect(result.block_template).to(eq("testimonials_block"))
      end

      it "prefers the persisted template over the options template" do
        part.options = { block_template: "stale_block" }
        part.mode = "inline"
        part.inline_block_template = "testimonials_block"
        part.inline_content = filled_inline_content

        expect(part.content.block_template).to(eq("testimonials_block"))
      end

      it "treats an unattached image as unfilled" do
        # Image#content returns the part itself and overrides #present? to check
        # for an attached blob, so it is blank without being empty.
        rc = Spina::Parts::RepeaterContent.new
        rc.parts = [Spina::Parts::Image.new(name: "testimonial_avatar")]

        part.mode = "inline"
        part.inline_content = rc

        expect(part.content).to(be_nil)
      end

      it "treats a part deliberately set to false as filled" do
        false_part = instance_double(Spina::Parts::Line, content: false)

        expect(part.send(:part_filled?, false_part)).to(be(true))
      end

      it "returns nil when inline content has no filled parts" do
        part.mode = "inline"
        part.inline_content = empty_inline_content

        expect(part.content).to(be_nil)
      end

      it "returns nil when inline content is absent" do
        part.mode = "inline"
        part.inline_content = nil

        expect(part.content).to(be_nil)
      end

      it "ignores block_id while in inline mode" do
        block = create(:spina_blocks_block, active: true)
        part.mode = "inline"
        part.block_id = block.id
        part.inline_content = filled_inline_content

        expect(part.content).to(be_a(Spina::Blocks::InlineBlock))
      end

      it "uses block_id when mode is reference despite inline content present" do
        block = create(:spina_blocks_block, active: true)
        part.mode = "reference"
        part.block_id = block.id
        part.inline_content = filled_inline_content

        expect(part.content).to(eq(block))
      end
    end
  end

  describe "#custom_block_name" do
    it "returns nil when options is nil" do
      part.options = nil
      expect(part.custom_block_name).to(be_nil)
    end

    it "returns nil when options is empty" do
      part.options = {}
      expect(part.custom_block_name).to(be_nil)
    end

    it "returns the value from symbol key" do
      part.options = { custom_block: "header" }
      expect(part.custom_block_name).to(eq("header"))
    end

    it "returns the value from string key" do
      part.options = { "custom_block" => "footer" }
      expect(part.custom_block_name).to(eq("footer"))
    end
  end

  describe "#custom_block_record" do
    it "returns nil when custom_block_name is blank" do
      part.options = nil
      expect(part.custom_block_record).to(be_nil)
    end

    it "returns the block when found by key" do
      block = create(:spina_blocks_block, :system, key: "footer")
      part.options = { custom_block: "footer" }

      expect(part.custom_block_record).to(eq(block))
    end

    it "returns nil when block key is not found" do
      part.options = { custom_block: "missing" }
      expect(part.custom_block_record).to(be_nil)
    end

    it "does not match blocks by name instead of key" do
      create(:spina_blocks_block, name: "footer", key: nil)
      part.options = { custom_block: "footer" }

      expect(part.custom_block_record).to(be_nil)
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
