CultivateLondon::Application.routes.draw do
  devise_for :users

  root :to => 'database#index'

  match '/database' => 'database#index'
  match '/database/:year' => 'database#index'
  resources :batches, :except => [:index, :show, :edit, :new]
  match '/reports' => 'reports#show'
  match '/reports/update' => 'reports#update'

end
