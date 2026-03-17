# frozen_string_literal: true

module Spina
  module Blocks
    module SearchExtension
      extend ActiveSupport::Concern

      included do
        include Spina::Pro::Search

        spina_searchable against: [:name]
      end
    end
  end
end
