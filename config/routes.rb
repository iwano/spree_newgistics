Spree::Core::Engine.routes.draw do
  # Add your extension routes here
  namespace :api, defaults: { format: 'json' } do
    post '/newgistics_imports/products' => 'newgistics_imports#products'
    get '/newgistics_imports/log' => 'newgistics_imports#log'
  end
end
