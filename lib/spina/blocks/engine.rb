# frozen_string_literal: true

module Spina
  module Blocks
    class Engine < ::Rails::Engine
      isolate_namespace Spina::Blocks

      config.before_initialize do
        ::Spina::Plugin.register do |plugin|
          plugin.name = "blocks"
          plugin.namespace = "blocks"
        end

        ::Spina::Theme.class_eval do
          attr_accessor :block_templates, :block_categories, :custom_blocks, :content_block_templates

          unless method_defined?(:initialize_without_blocks)
            alias_method :initialize_without_blocks, :initialize

            def initialize
              initialize_without_blocks
              @block_templates = []
              @block_categories = []
              @custom_blocks = []
              @content_block_templates = []
            end
          end
        end
      end

      initializer "spina.blocks.importmap", before: "spina.blocks.register_parts" do
        Spina.config.importmap.draw do
          pin_all_from Spina::Blocks::Engine.root.join("app/assets/javascripts/spina/controllers"),
            under: "controllers",
            to: "spina/controllers"
          pin_all_from Spina::Blocks::Engine.root.join("app/assets/javascripts/spina/utils"),
            under: "spina/utils",
            to: "spina/utils"
        end
      end

      initializer "spina.blocks.assets.precompile" do |app|
        app.config.assets.precompile += %w[
          spina/controllers/block_collection_controller.js
          spina/controllers/content_blocks_controller.js
          spina/controllers/nested_content_blocks_controller.js
          spina/utils/dropdown_position.js
        ] if defined?(Sprockets)
      end

      initializer "spina.blocks.register_parts" do
        config.to_prepare do
          ::Spina::Part.register(
            Spina::Parts::BlockReference,
            Spina::Parts::BlockCollection,
            Spina::Parts::ContentBlocks,
            Spina::Parts::ContentBlock,
            Spina::Parts::NestedContentBlocks,
          )
        end
      end

      initializer "spina.blocks.extend_models" do
        config.to_prepare do
          Spina::Page.include(Spina::Blocks::PageExtension) unless Spina::Page < Spina::Blocks::PageExtension
          Spina::Account.include(Spina::Blocks::AccountExtension) unless Spina::Account < Spina::Blocks::AccountExtension
        end
      end

      initializer "spina.blocks.search" do
        config.to_prepare do
          if defined?(Spina::Pro::Search)
            Spina::Blocks::Block.include(Spina::Blocks::SearchExtension) unless Spina::Blocks::Block < Spina::Blocks::SearchExtension
          end
        end
      end

      initializer "spina.blocks.tailwind_content" do
        ::Spina.config.tailwind_content << "#{Spina::Blocks::Engine.root}/app/views/**/*.*"
        ::Spina.config.tailwind_content << "#{Spina::Blocks::Engine.root}/app/helpers/**/*.*"
        ::Spina.config.tailwind_content << "#{Spina::Blocks::Engine.root}/app/assets/javascripts/**/*.js"
      end

      initializer "spina.blocks.i18n" do
        config.i18n.load_path += Dir[Spina::Blocks::Engine.root.join("config", "locales", "*.{rb,yml}")]
      end

      initializer "spina.blocks.helpers" do
        config.to_prepare do
          ActionView::Base.include(Spina::Blocks::BlocksHelper)
        end
      end
    end
  end
end
