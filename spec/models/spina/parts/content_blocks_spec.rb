# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Spina::Parts::ContentBlocks, type: :model) do
  subject(:part) { described_class.new }

  let(:templates) do
    [
      { name: "rich_text", title: "Rich Text", parts: ["block_body"] },
      { name: "image", title: "Image", parts: ["block_image", "block_caption"] },
      { name: "cta_buttons", title: "CTA Buttons", parts: ["block_cta_buttons"] },
    ]
  end

  let(:theme) { Struct.new(:content_block_templates).new(templates) }

  describe "#available_templates" do
    it "returns all templates when no filter is set" do
      expect(part.available_templates(theme).size).to(eq(3))
    end

    it "filters templates by options[:content_block_templates]" do
      part.options = { content_block_templates: ["rich_text", "image"] }

      result = part.available_templates(theme)

      expect(result.map { |t| t[:name] }).to(eq(["rich_text", "image"]))
    end

    it "returns all templates when options is nil" do
      part.options = nil

      expect(part.available_templates(theme).size).to(eq(3))
    end

    it "returns all templates when options is empty hash" do
      part.options = {}

      expect(part.available_templates(theme).size).to(eq(3))
    end

    it "returns empty array when theme has no content_block_templates" do
      empty_theme = Struct.new(:content_block_templates).new(nil)

      expect(part.available_templates(empty_theme)).to(eq([]))
    end

    it "returns empty array when filter matches nothing" do
      part.options = { content_block_templates: ["nonexistent"] }

      expect(part.available_templates(theme)).to(eq([]))
    end
  end

  describe "#content" do
    it "stores and returns an array of ContentBlock items" do
      block = Spina::Parts::ContentBlock.new(block_type: "rich_text")
      part.content = [block]

      expect(part.content.size).to(eq(1))
      expect(part.content.first.block_type).to(eq("rich_text"))
    end

    it "defaults to empty array when no content is set" do
      expect(part.content).to(eq([]))
    end
  end

  describe "NestedContentBlocks" do
    it "inherits from ContentBlocks" do
      expect(Spina::Parts::NestedContentBlocks.superclass).to(eq(described_class))
    end

    it "supports available_templates filtering" do
      nested = Spina::Parts::NestedContentBlocks.new
      nested.options = { content_block_templates: ["rich_text"] }

      result = nested.available_templates(theme)

      expect(result.map { |t| t[:name] }).to(eq(["rich_text"]))
    end
  end
end
