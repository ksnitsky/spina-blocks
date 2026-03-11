module Spina
  module Blocks
    class Block < ApplicationRecord
      include AttrJson::Record
      include AttrJson::NestedAttributes
      include Spina::Partable
      include Spina::TranslatedContent

      belongs_to :category, class_name: 'Spina::Blocks::Category', optional: true
      has_many :page_blocks, class_name: 'Spina::Blocks::PageBlock', dependent: :destroy
      has_many :pages, through: :page_blocks, class_name: 'Spina::Page'

      validates :title, presence: true
      validates :block_template, presence: true

      scope :active, -> { where(active: true) }
      scope :sorted, -> { order(:position) }

      def to_s
        title
      end
    end
  end
end
