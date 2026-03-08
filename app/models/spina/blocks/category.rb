module Spina
  module Blocks
    class Category < ApplicationRecord
      has_many :blocks, class_name: 'Spina::Blocks::Block', foreign_key: :category_id, dependent: :nullify

      validates :name, presence: true, uniqueness: true
      validates :label, presence: true

      scope :sorted, -> { order(:position) }

      def to_s
        label
      end
    end
  end
end
