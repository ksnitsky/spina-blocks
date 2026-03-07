module Spina
  module Blocks
    class Engine < ::Rails::Engine
      isolate_namespace Spina

      config.before_initialize do
        Spina::Plugin.register do |plugin|
          plugin.name = 'spina_blocks'
          plugin.namespace = 'spina_blocks'
        end
      end

      initializer 'spina.blocks.append_migrations' do |app|
        unless app.root.to_s.match?(root.to_s)
          config.paths['db/migrate'].expanded.each do |expanded_path|
            app.config.paths['db/migrate'] << expanded_path
          end
        end
      end

      initializer 'spina.blocks.register_parts' do
        config.to_prepare do
          Spina::Part.register(
            Spina::Parts::BlockReference,
            Spina::Parts::BlockCollection
          )
        end
      end

      initializer 'spina.blocks.extend_theme' do
        Spina::Theme.class_eval do
          attr_accessor :block_templates, :block_categories

          unless method_defined?(:initialize_without_blocks)
            alias_method :initialize_without_blocks, :initialize

            def initialize
              initialize_without_blocks
              @block_templates = []
              @block_categories = []
            end
          end
        end
      end

      initializer 'spina.blocks.extend_page' do
        config.to_prepare do
          config_path = Spina::Blocks::Engine.root.join('app/overrides')

          Dir.glob(config_path.join('**/*.rb')).sort.each do |override|
            load override
          end
        end
      end

      initializer 'spina.blocks.tailwind_content' do
        Spina.config.tailwind_content << "#{Spina::Blocks::Engine.root}/app/views/**/*.*"
        Spina.config.tailwind_content << "#{Spina::Blocks::Engine.root}/app/helpers/**/*.*"
      end

      initializer 'spina.blocks.i18n' do
        config.i18n.load_path += Dir[Spina::Blocks::Engine.root.join('config', 'locales', '*.{rb,yml}')]
      end

      initializer 'spina.blocks.helpers' do
        ActiveSupport.on_load(:action_view) do
          include Spina::BlocksHelper
        end
      end
    end
  end
end
