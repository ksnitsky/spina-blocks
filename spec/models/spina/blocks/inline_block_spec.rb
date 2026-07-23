# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Spina::Blocks::InlineBlock, type: :model) do
  subject(:inline_block) { described_class.new(repeater_content, "testimonials_block") }

  let(:repeater_content) do
    Spina::Parts::RepeaterContent.new.tap do |rc|
      rc.parts = [
        Spina::Parts::Line.new(name: "section_title", content: "Reviews"),
        Spina::Parts::Line.new(name: "section_subtitle"),
      ]
    end
  end

  describe "#active?" do
    it "is always active — inline content has no activation flag of its own" do
      expect(inline_block.active?).to(be(true))
    end
  end

  describe "#block_template" do
    it "returns the template it was built with" do
      expect(inline_block.block_template).to(eq("testimonials_block"))
    end

    it "coerces to a string" do
      expect(described_class.new(repeater_content, :testimonials_block).block_template)
        .to(eq("testimonials_block"))
    end
  end

  describe "#content" do
    it "returns a named part's content" do
      expect(inline_block.content(:section_title)).to(eq("Reviews"))
    end

    it "returns nil for an unknown part" do
      expect(inline_block.content(:nope)).to(be_nil)
    end

    it "returns a ContentPresenter when called without a name" do
      expect(inline_block.content).to(be_a(Spina::ContentPresenter))
    end
  end

  describe "#has_content?" do
    it "is true for a part that exists" do
      expect(inline_block.has_content?(:section_title)).to(be(true))
    end

    it "is false for a part that does not" do
      expect(inline_block.has_content?(:nope)).to(be(false))
    end
  end

  describe "#view_context" do
    it "forwards to the underlying content so callers can hand one down" do
      view_context = Object.new
      inline_block.view_context = view_context

      expect(repeater_content.view_context).to(be(view_context))
      expect(inline_block.view_context).to(be(view_context))
    end

    it "applies a view context assigned after the presenter was already built" do
      # Partable memoises its ContentPresenter on first use, so the setter has to
      # drop that memo. This guards the reach into Spina's internals that does so.
      inline_block.content

      view_context = Object.new
      inline_block.view_context = view_context

      expect(inline_block.content.view_context).to(be(view_context))
    end
  end

  describe "labelling" do
    it "names itself after the template so a missing partial is visible" do
      expect(inline_block.name).to(eq("testimonials_block"))
      expect(inline_block.to_s).to(eq("testimonials_block"))
    end
  end
end
