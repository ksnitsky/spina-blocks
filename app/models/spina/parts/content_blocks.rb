# frozen_string_literal: true

module Spina
  module Parts
    class ContentBlocks < Base
      include AttrJson::NestedAttributes

      attr_json :content, ContentBlock.to_type, array: true
      attr_json_accepts_nested_attributes_for :content

      attr_accessor :options

      # Returns available content block templates from the theme,
      # optionally filtered by the :content_block_templates option.
      def available_templates(theme)
        templates = theme.content_block_templates || []
        allowed = options&.dig(:content_block_templates)
        return templates if allowed.blank?

        allowed_names = Array(allowed).map(&:to_s)
        templates.select { |t| allowed_names.include?(t[:name].to_s) }
      end
    end
  end
end
