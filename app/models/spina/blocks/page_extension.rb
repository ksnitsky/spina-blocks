# frozen_string_literal: true

module Spina
  module Blocks
    module PageExtension
      extend ActiveSupport::Concern

      included do
        has_many :page_blocks, class_name: "Spina::Blocks::PageBlock", foreign_key: :page_id, dependent: :destroy
        has_many :blocks, through: :page_blocks, class_name: "Spina::Blocks::Block"
      end
    end
  end
end
