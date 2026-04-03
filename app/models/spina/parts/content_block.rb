# frozen_string_literal: true

module Spina
  module Parts
    class ContentBlock < Base
      include Partable
      include AttrJson::NestedAttributes

      attr_json :block_type, :string
      attr_json :parts, AttrJson::Type::SpinaPartsModel.new, array: true
      attr_json_accepts_nested_attributes_for :parts

      def find_part(name)
        (parts || []).find { |part| part.name.to_s == name.to_s }
      end
    end
  end
end
