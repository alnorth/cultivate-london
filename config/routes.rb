CultivateLondon::Application.routes.draw do
  resources :users, :except => [:show]
  devise_for :users, :skip => [:registrations]
  as :user do
    get 'users/edit' => 'devise/registrations#edit', :as => 'edit_user_registration'
    put 'users' => 'devise/registrations#update', :as => 'user_registration'
  end

  root :to => 'database#index'

  match '/database' => 'database#index'
  match '/database/:year' => 'database#index'
  resources :batches, :except => [:index, :show, :edit, :new]
  match '/reports' => 'reports#show'
  match '/reports/update' => 'reports#update'

end
