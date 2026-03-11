module Spina
  module Blocks
    module Admin
      class BlocksController < ::Spina::Admin::AdminController
        admin_section :content

        before_action :set_locale
        before_action :set_block, only: %i[edit edit_content update destroy]
        before_action :set_tabs, only: %i[edit update]

        helper ::Spina::Admin::PagesHelper

        def index
          add_breadcrumb I18n.t('spina.blocks.title'), spina.blocks_admin_blocks_path

          @block_templates = current_theme.try(:block_templates) || []

          if params[:block_template].present?
            @current_template = params[:block_template]
            @blocks = Spina::Blocks::Block.where(block_template: @current_template).sorted
          else
            @current_template = nil
            @blocks = Spina::Blocks::Block.sorted
          end
        end

        def new
          @block = Spina::Blocks::Block.new(block_template: params[:block_template])
        end

        def create
          @block = Spina::Blocks::Block.new(block_params)
          if @block.save
            redirect_to spina.edit_blocks_admin_block_url(@block)
          else
            render turbo_stream: turbo_stream.update(
              helpers.dom_id(@block, :new_block_form),
              partial: 'new_block_form'
            )
          end
        end

        def edit
          add_breadcrumb I18n.t('spina.blocks.title'), spina.blocks_admin_blocks_path, class: 'text-gray-400'
          add_breadcrumb @block.title
        end

        def edit_content
          @parts = current_theme.block_templates&.find do |bt|
            bt[:name].to_s == @block.block_template.to_s
          end&.dig(:parts) || []
        end

        def update
          Mobility.locale = @locale
          if @block.update(block_params)
            flash[:success] = I18n.t('spina.blocks.saved')
            redirect_to spina.edit_blocks_admin_block_url(@block, params: { locale: @locale })
          else
            add_breadcrumb I18n.t('spina.blocks.title'), spina.blocks_admin_blocks_path, class: 'text-gray-400'
            Mobility.locale = I18n.locale
            add_breadcrumb @block.title
            flash.now[:error] = I18n.t('spina.blocks.couldnt_be_saved')
            render :edit, status: :unprocessable_entity
          end
        end

        def sort
          params[:ids].each.with_index do |id, index|
            Spina::Blocks::Block.where(id: id).update_all(position: index + 1)
          end

          flash.now[:info] = I18n.t('spina.blocks.sorting_saved')
          render_flash
        end

        def destroy
          flash[:info] = I18n.t('spina.blocks.deleted')
          @block.destroy
          redirect_to spina.blocks_admin_blocks_url
        end

        private

        def set_locale
          @locale = params[:locale] || I18n.default_locale
        end

        def set_block
          @block = Spina::Blocks::Block.find(params[:id])
        end

        def set_tabs
          @tabs = %w[block_content block_settings]
        end

        def block_params
          params.require(:block).permit!
        end
      end
    end
  end
end
