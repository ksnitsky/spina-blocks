# frozen_string_literal: true

Spina::Engine.routes.draw do
  namespace :blocks, path: "", module: "blocks" do
    namespace :admin, path: Spina.config.backend_path do
      resources :blocks do
        member do
          get :edit_content
        end

        collection do
          post :sort
        end
      end

      resources :categories, only: [:index, :edit, :update]

      resources :pages, only: [] do
        resources :page_blocks, only: [:index, :create, :destroy] do
          collection do
            post :sort
          end
        end
      end
    end
  end
end
