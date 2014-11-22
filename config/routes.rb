Rails.application.routes.draw do
  get 'admin/index', to: 'admin#index', as: :admin
  get 'search/index', to: 'search#index', as: :search
  get 'movies/index', to: 'movies#index', as: :movies
  get 'musics/index', to: 'musics#index', as: :musics
  get 'images/index', to: 'images#index', as: :images

  resources :shared_folders
  resources :users, except: [:show, :update]
  put 'user/:id/update', to: 'users#update', as: :update_user

  resources :attachments, except: [:index, :show, :create] do
    post 'authorize'
    post 'create', to: 'attachments#create', as: :create
    member do
      get 'show_image/show_image.gif', to: 'attachments#show_image'
      get 'show_thumb', to: 'attachments#show_thumb'
    end
  end

  get 'attachments/:page', to: 'attachments#index', as: :attachments
  get 'attachment/:page/show', to: 'attachments#show', as: :show_attachment


  ########  files controller #############
  post 'files/move', to: 'files#move'
  post 'files/copy', to: 'files#copy'
  post 'files/share_with', to: 'files#share_with'
  post 'files/delete', to: 'files#delete'
  post 'files/new_file', to: 'files#new_file'
  post 'files/rename', to: 'files#rename'
  post 'files/upload', to: 'files#upload'
  get 'files/download', to: 'files#download'
  get 'files/text_preview', to: 'files#text_preview'
  get 'files/preview', to: 'files#preview'
  get 'files/show_image', to: 'files#show_image'
  get 'files/show_image_thumb', to: 'files#show_image_thumb'
  get 'files/stream_file', to: 'files#stream_file'
  get 'files/video_thumb', to: 'files#video_thumb'
  ########  files controller #############



  ########  homes controller #############
  get "/", to: 'home#index'
  get :refresh_sidebar, to: 'homes#refresh_sidebar'
  ########  homes controller #############

  ########  images controller #############
  get :index, to: 'images#index'
  post :manipulate_image, to: 'images#manipulate_image'
  ########  homes controller #############

  devise_for :users
  root to: 'home#index'
end
