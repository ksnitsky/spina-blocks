# frozen_string_literal: true

module Spina
  module Parts
    # Same behavior as ContentBlocks but registered as a separate Part type
    # with its own Stimulus controller name ("nested-content-blocks").
    # This avoids Stimulus scope conflicts when used inside Repeaters or
    # other ContentBlocks containers.
    #
    # Use `options[:content_block_templates]` to limit which block types
    # are available (prevents recursive nesting of the same block type).
    class NestedContentBlocks < ContentBlocks
    end
  end
end
