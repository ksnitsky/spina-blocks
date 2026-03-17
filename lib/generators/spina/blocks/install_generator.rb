# frozen_string_literal: true

module Spina
  module Blocks
    class InstallGenerator < Rails::Generators::Base
      desc "Install Spina Blocks plugin: copy migrations and run them"

      def copy_migrations
        rake("spina_blocks:install:migrations")
      end

      def run_migrations
        rake("db:migrate")
      end
    end
  end
end
