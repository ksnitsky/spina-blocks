# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Spina::Parts::ContentBlock, type: :model) do
  subject(:block) { described_class.new(block_type: "rich_text") }

  describe "#block_type" do
    it "stores and returns the block type" do
      expect(block.block_type).to(eq("rich_text"))
    end
  end

  describe "#find_part" do
    it "finds a part by name" do
      part = Spina::Parts::Line.new(name: "block_body", title: "Body")
      block.parts = [part]

      expect(block.find_part("block_body")).to(eq(part))
    end

    it "returns nil when part is not found" do
      part = Spina::Parts::Line.new(name: "block_body", title: "Body")
      block.parts = [part]

      expect(block.find_part("nonexistent")).to(be_nil)
    end

    it "returns nil when parts is empty" do
      block.parts = []

      expect(block.find_part("block_body")).to(be_nil)
    end

    it "returns nil when parts is nil" do
      block.parts = nil

      expect(block.find_part("block_body")).to(be_nil)
    end
  end
end
