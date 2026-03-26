# frozen_string_literal: true

module Spina
  module Blocks
    module Admin
      class BlocksController < ::Spina::Admin::AdminController
        admin_section :content

        before_action :set_locale
        before_action :set_block, only: [:edit, :edit_content, :edit_modal, :update, :destroy]
        before_action :set_tabs, only: [:edit, :edit_modal, :update]

        helper ::Spina::Admin::PagesHelper

        def index
          add_breadcrumb(I18n.t("spina.blocks.title"), spina.blocks_admin_blocks_path)

          @block_templates = current_theme.try(:block_templates) || []

          if params[:filter] == "layout"
            @current_filter = "layout"
            @blocks = Spina::Blocks::Block.undeletable.sorted
          elsif params[:block_template].present?
            @current_block_template = params[:block_template]
            @blocks = Spina::Blocks::Block.where(block_template: @current_block_template).sorted
          else
            @blocks = Spina::Blocks::Block.sorted
          end
        end

        def new
          @block_templates = creatable_block_templates
          @block = Spina::Blocks::Block.new(block_template: params[:block_template])
          @modal = params[:modal]
        end

        def create
          @block = Spina::Blocks::Block.new(block_params)
          if @block.save
            if params[:modal]
              redirect_to(spina.edit_modal_blocks_admin_block_url(@block))
            else
              redirect_to(spina.edit_blocks_admin_block_url(@block))
            end
          else
            @block_templates = creatable_block_templates
            if params[:modal]
              @modal = true
              render(turbo_stream: turbo_stream.update(
                helpers.dom_id(@block, :new_block_modal_form),
                partial: "new_block_modal_form",
              ))
            else
              render(turbo_stream: turbo_stream.update(
                helpers.dom_id(@block, :new_block_form),
                partial: "new_block_form",
              ))
            end
          end
        end

        def edit
          add_breadcrumb(I18n.t("spina.blocks.title"), spina.blocks_admin_blocks_path, class: "text-gray-400")
          add_breadcrumb(@block.name)
        end

        def edit_content
          @parts = current_theme.block_templates&.find do |bt|
            bt[:name].to_s == @block.block_template.to_s
          end&.dig(:parts) || []
        end

        def edit_modal
        end

        def update
          Mobility.locale = @locale
          if @block.update(block_params)
            if params[:modal]
              render(turbo_stream: turbo_stream.update("modal", ""))
            else
              flash[:success] = I18n.t("spina.blocks.saved")
              redirect_to(spina.edit_blocks_admin_block_url(@block, params: { locale: @locale }))
            end
          elsif params[:modal]
            flash.now[:error] = I18n.t("spina.blocks.couldnt_be_saved")
            render(:edit_modal, status: :unprocessable_entity)
          else
            add_breadcrumb(I18n.t("spina.blocks.title"), spina.blocks_admin_blocks_path, class: "text-gray-400")
            Mobility.locale = I18n.locale
            add_breadcrumb(@block.name)
            flash.now[:error] = I18n.t("spina.blocks.couldnt_be_saved")
            render(:edit, status: :unprocessable_entity)
          end
        end

        def blocks_data
          blocks = Spina::Blocks::Block.active.sorted
          template_titles = build_template_titles
          render(json: blocks.map do |b|
            {
              id: b.id,
              name: b.name,
              templateName: b.block_template.to_s,
              templateTitle: template_titles[b.block_template.to_s] || b.block_template.to_s.titleize,
            }
          end)
        end

        def sort
          params[:ids].each.with_index do |id, index|
            Spina::Blocks::Block.where(id: id).update_all(position: index + 1)
          end

          flash.now[:info] = I18n.t("spina.blocks.sorting_saved")
          render_flash
        end

        def destroy
          unless @block.deletable?
            flash[:error] = I18n.t("spina.blocks.cannot_be_deleted")
            redirect_to(spina.edit_blocks_admin_block_url(@block))
            return
          end

          flash[:info] = I18n.t("spina.blocks.deleted")
          @block.destroy
          redirect_to(spina.blocks_admin_blocks_url)
        end

        private

        def set_locale
          @locale = params[:locale] || I18n.default_locale
        end

        def set_block
          @block = Spina::Blocks::Block.find(params[:id])
        end

        def set_tabs
          @tabs = ["block_content", "block_settings"]
        end

        def build_template_titles
          titles = {}
          (current_theme.try(:block_templates) || []).each do |bt|
            titles[bt[:name].to_s] = bt[:title].to_s
          end
          titles
        end

        # Returns block templates available for manual block creation,
        # excluding templates reserved for layout (custom) blocks.
        def creatable_block_templates
          all_templates = current_theme.try(:block_templates) || []
          layout_template_names = (current_theme.try(:custom_blocks) || [])
            .map { |cb| cb[:block_template].to_s }.uniq

          all_templates.reject { |bt| layout_template_names.include?(bt[:name].to_s) }
        end

        def block_params
          params.require(:block).permit!
        end
      end
    end
  end
end
