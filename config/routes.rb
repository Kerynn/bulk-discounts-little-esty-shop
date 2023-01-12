Rails.application.routes.draw do
  resources :merchants do
    resources :items, controller: "merchants/items"
    resources :invoices, only: [:index, :show], controller: 'merchants/invoices'
    resources :bulk_discounts, only: [:index, :show, :new], controller: 'merchants/bulk_discounts'
  end
  
  resources :invoice_items, only: :update

  get '/merchants/:id/dashboard', to: "merchants#show"

  resources :admin, only: [:index]

  namespace :admin do
    resources :invoices, only: [:index, :show, :update]
    resources :merchants, except: [:destroy]
  end

  root to: "admin#index"
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
