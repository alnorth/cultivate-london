CultivateLondon::Application.routes.draw do
  root :to => 'database#index'

  match '/database' => 'database#index'
  resources :batches, :except => [:index, :show, :edit, :new]
  match '/reports' => 'reports#show'
  match '/reports/update/:stage' => 'reports#update_stage'
  match '/reports/:year/:week' => 'reports#show'

end
