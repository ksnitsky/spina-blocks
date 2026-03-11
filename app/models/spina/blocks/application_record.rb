# frozen_string_literal: true

module Spina
  module Blocks
    class ApplicationRecord < ActiveRecord::Base
      self.abstract_class = true
    end
  end
end
