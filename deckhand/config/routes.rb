Rails.application.routes.draw do
  resources :tasks
  resources :codebases

  root "main_deck#show"
end
