# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Spina::Blocks::BlocksHelper, type: :helper) do
  describe "#render_block" do
    let(:block) { create(:spina_blocks_block, block_template: "text", active: true) }

    before do
      Spina::Current.theme = Spina::Theme.find_by_name("default")
    end

    after do
      Spina::Current.reset
    end

    it "renders the block_template partial with the block as a local" do
      output = helper.render_block(block)

      expect(output).to(include("Text content for #{block.name}"))
    end

    it "forwards a content block to the partial via yield" do
      output = helper.render_block(block) do
        helper.content_tag(:span, "yielded content", class: "extra")
      end

      expect(output).to(include("yielded content"))
      expect(output).to(include("Text content for #{block.name}"))
    end

    it "renders without yielded content when no block is passed" do
      output = helper.render_block(block)

      expect(output).not_to(include("yielded content"))
    end

    it "returns nil for inactive blocks" do
      block.update!(active: false)

      expect(helper.render_block(block)).to(be_nil)
    end

    it "returns nil for nil blocks" do
      expect(helper.render_block(nil)).to(be_nil)
    end

    it "falls back to a placeholder when the partial is missing" do
      block.update!(block_template: "missing_template")

      output = helper.render_block(block)

      expect(output).to(include("spina-block--missing_template"))
      expect(output).to(include(block.name))
    end
  end

  describe "#render_custom_block" do
    let!(:custom_block) do
      create(:spina_blocks_block, :system, key: "header", block_template: "text", active: true)
    end

    before do
      Spina::Current.theme = Spina::Theme.find_by_name("default")
    end

    after do
      Spina::Current.reset
    end

    it "looks up a block by key and renders its partial" do
      output = helper.render_custom_block("header")

      expect(output).to(include("Text content for #{custom_block.name}"))
    end

    it "forwards a content block to the partial via yield" do
      output = helper.render_custom_block("header") do
        helper.content_tag(:span, "yielded from custom")
      end

      expect(output).to(include("yielded from custom"))
    end

    it "returns nil when no block matches the key" do
      expect(helper.render_custom_block("missing")).to(be_nil)
    end
  end
end
