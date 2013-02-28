CultivateLondon::Application.routes.draw do
  root :to => 'database#index'

  match '/database' => 'database#index'
  match '/batch/save' => 'batch#save'
  match '/reports' => 'reports#show'
  match '/reports/:year/:week' => 'reports#show'

end
