# frozen_string_literal: true

module Spina
  module Parts
    class BlockReference < Base
      include BlockFilterable
      include AttrJson::NestedAttributes

      attr_json :block_id, :integer, default: nil
      # "reference" (default): points at a shared block via block_id / custom_block.
      # "inline": content is filled in and stored on the page itself.
      attr_json :mode, :string, default: nil
      # Inline content, used when mode == "inline". Same shape as a Section's
      # content: a RepeaterContent holding the block template's parts.
      attr_json :inline_content, RepeaterContent.to_type, default: nil
      attr_json_accepts_nested_attributes_for :inline_content
      # The block template inline content was filled in against, persisted with
      # the content itself. Part options are a theme-side concern and are only
      # attached when Spina builds parts for the admin form — parts deserialized
      # from stored page JSON (i.e. when rendering the site) carry none — so
      # inline content has to be self-describing to render.
      attr_json :inline_block_template, :string, default: nil

      attr_accessor :options

      def content
        return inline_block if inline?

        if custom_block_name.present?
          custom_block_record
        else
          ::Spina::Blocks::Block.active.find_by(id: block_id)
        end
      end

      # Whether this reference is filled inline (page-local) instead of pointing
      # at a shared block. Absent/blank mode is treated as "reference" so existing
      # parts stay backward compatible.
      def inline?
        mode.to_s == "inline"
      end

      # Optional block template restriction from the part's theme options. Filters
      # the block picker and, when present, is what inline mode fills in against.
      # Only available where options are attached (the admin form).
      def block_template_name
        return if options.blank?

        options[:block_template] || options["block_template"]
      end

      # Returns the custom_block key from options, supporting both symbol and string keys
      def custom_block_name
        return if options.blank?

        options[:custom_block] || options["custom_block"]
      end

      # Looks up the custom block record by key
      def custom_block_record
        return if custom_block_name.blank?

        ::Spina::Blocks::Block.find_by(key: custom_block_name)
      end

      # Accepts inline content as a JSON string so the form can round-trip
      # content it cannot render fields for — e.g. the block template is no
      # longer registered in the theme. Without it the next save would drop
      # stored content that is still rendering on the site.
      def inline_content_json=(raw)
        return if raw.blank?

        parsed = JSON.parse(raw)
        self.inline_content = parsed if parsed.is_a?(Hash)
      rescue StandardError
        # Best-effort restore of a value that arrives from a client-controlled
        # hidden field: malformed JSON, or a payload naming a part type attr_json
        # won't build, must leave the stored content alone rather than break the
        # page save.
        nil
      end

      private

      # Wraps inline content so it renders through the same block template partial
      # as a shared block. Returns nil when nothing has been filled in, so callers
      # using `render_block(content)` render nothing (matching an empty reference).
      def inline_block
        template = inline_block_template.presence || block_template_name.presence
        # Without a template there is no partial to render; bail out rather than
        # let render_block fall through to its empty placeholder wrapper.
        return if template.blank?
        return if inline_content.blank?
        return if Array(inline_content.parts).none? { |part| part_filled?(part) }

        ::Spina::Blocks::InlineBlock.new(inline_content, template)
      end

      # Defers to each part's own `present?`, which Image and Attachment override
      # to check for an attached blob. The one case `present?` gets wrong here is
      # a boolean-shaped part deliberately set to false — empty by Rails' rules,
      # filled by the editor's.
      def part_filled?(part)
        value = part.content
        return true if value == false

        value.present?
      end
    end
  end
end
