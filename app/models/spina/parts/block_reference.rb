# frozen_string_literal: true

module Spina
  module Parts
    class BlockReference < Base
      include BlockFilterable

      attr_json :block_id, :integer, default: nil

      attr_accessor :options

      def content
        if custom_block_name.present?
          custom_block_record
        else
          ::Spina::Blocks::Block.active.find_by(id: block_id)
        end
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
    end
  end
end
