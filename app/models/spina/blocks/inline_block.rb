# frozen_string_literal: true

module Spina
  module Blocks
    # Duck-typed stand-in for a Spina::Blocks::Block whose content lives inline
    # in the page (a RepeaterContent) rather than in a persisted block record.
    #
    # It exposes just enough of the Block interface for `render_block` and block
    # template partials to work unchanged: `active?`, `block_template`, and
    # `content` / `has_content?` delegating to the inline RepeaterContent.
    class InlineBlock
      attr_reader :block_template

      def initialize(repeater_content, block_template)
        @repeater_content = repeater_content
        @block_template = block_template.to_s
      end

      def active?
        true
      end

      # Mirrors Spina::Partable#content: named lookup returns the part's content,
      # no argument returns a ContentPresenter (view_context resolves via
      # Spina::Current.page during page rendering).
      def content(name = nil)
        @repeater_content&.content(name)
      end

      def has_content?(name)
        @repeater_content&.has_content?(name) || false
      end

      # Present so `render_block_fallback` (missing partial) doesn't blow up.
      def name
        nil
      end

      def to_s
        ""
      end
    end
  end
end
