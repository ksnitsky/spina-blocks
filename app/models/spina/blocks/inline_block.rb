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
      # no argument returns a ContentPresenter.
      def content(name = nil)
        repeater_content.content(name)
      end

      def has_content?(name)
        repeater_content.has_content?(name)
      end

      # Kept in step with the content so callers can hand a view context down
      # explicitly. Without it ContentPresenter has to fall back on
      # Spina::Current.page, which isn't set everywhere blocks are rendered.
      def view_context
        repeater_content.view_context
      end

      def view_context=(value)
        repeater_content.view_context = value
        # Partable memoises its ContentPresenter, capturing the view context
        # resolved on first use. Drop the memo so a later assignment still takes
        # effect instead of silently doing nothing.
        repeater_content.instance_variable_set(:@content_presenter, nil)
      end

      # Surfaced by render_block's fallback when a block template partial is
      # missing — naming the template is what makes that visible to an editor.
      def name
        block_template
      end

      def to_s
        block_template
      end

      private

      attr_reader :repeater_content
    end
  end
end
