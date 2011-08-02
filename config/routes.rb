AncjaUrls::Application.routes.draw do

  get "home/index"

  resources :link do
    resources :vote
    resources :comment

    # for comments ajax pagination
    post 'show', :on => :member
  end

  match "create_comment", :to => 'comment#create', :as => "create_comment", :via => "post"

  match 'login', :to => 'twitter#login', :as => "login", :via => "get"
  match 'logout', :to => 'twitter#logout', :as => "logout", :via => "get"

  get "twitter/after_login"

  root :to => "home#index"
end
