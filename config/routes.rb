# require 'sidekiq/web'

RailsStripeMembershipSaas::Application.routes.draw do
  mount StripeEvent::Engine => '/stripe'
  get "content/gold"
  get "content/silver"
  get "content/platinum"

  authenticated :user do
    root :to => 'home#index'
    mount Resque::Server.new, :at => "/resque"
  end

  root :to => "home#index"
  devise_for :users, :controllers => { :registrations => 'registrations' }
  devise_scope :user do
    put 'update_plan', :to => 'registrations#update_plan'
    put 'update_card', :to => 'registrations#update_card'
  end
  resources :users

  namespace :api, defaults: {format: 'json'} do
    namespace :v1 do
      resources :items
      resources :listings
      resources :follows
      resources :admin
      get 'get_follow_urls' => 'admin#get_follow_urls'
      get 'get_all_urls' => 'admin#get_all_urls'
      get 'remove_listing_fields' => 'admin#remove_listing_fields'
      get 'match_listings' => 'admin#match_listings'
    end
  end

  resources :categories do
    member do
      get :follow
      get :unfollow
    end
  end
  resources :categories, :only => [:index, :show]
  resources :taxonomies, :only => [:index]
  resources :tags, :only => [:index]

  resources :organizations, :only => [:index]
  resources :items, :only => [:index]
  resources :listings, :only => [:index]
  resources :unknowns, :only => [:index]

  resources :listings do
    member do
      get :follow
      get :unfollow
    end
  end
end
