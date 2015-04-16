Spree::Core::Engine.routes.draw do
  namespace :admin do
    resource :quickbooks, only: [:show, :edit, :update] do
      collection do
        get :authenticate
        get :oauth_callback
      end
    end
  end
end
