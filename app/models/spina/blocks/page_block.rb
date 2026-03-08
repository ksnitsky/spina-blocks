module Spina
  module Blocks
    class PageBlock < ApplicationRecord
      belongs_to :page, class_name: 'Spina::Page'
      belongs_to :block, class_name: 'Spina::Blocks::Block'

      validates :block_id, uniqueness: { scope: :page_id }

      scope :sorted, -> { order(:position) }
    end
  end
end
