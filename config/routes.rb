Rails.application.routes.draw do
  devise_for :users ,:controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  # post '/chat_rooms/:id/chat' => "chat_rooms#chat", as: "chat_chat_room"
root 'user#index'


#유저 라우팅
#유저의 프로필 화면
get '/:user_name/profile' => 'user#profile'
#모든 유저 리스트 및 리스트에서 검색
get '/user/list' => 'user#list'
#유저 프로필 수정
get '/profile/edit' => 'user#edit'
#유저 프로필 수정 로직
post '/profile/update'  => 'user#update'
#실시간 검색
post '/search' => 'user#search'

#깃헙에서 데이터 받아오기
post '/github' => 'user#github'

#포트폴리오 라우팅
#포트폴리오 등록페이지
get '/portfolio' => 'portfolio#portfolio'
#포트폴리오 등록 로직
post '/portfolio/register' => 'portfolio#register_portfolio'
#포트폴리오 수정페이지
get '/portfolio/edit/:id' => 'portfolio#portfolio_edit'
#포트폴리오 수정로직
post '/portfolio/update/:id' => 'portfolio#portfolio_update'
#포트폴리오 상세보기
get '/portfolio/show/:id' => 'portfolio#portfolio_show'
#포트폴리오 삭제
get '/portfolio/delete/:id' => 'portfolio#portfolio_delete'

#

#프로젝트 라우팅 
  resources :projects do
      member do
        # /projects/:id/chat
        #채팅창
        post "/chat" => 'projects#project_chat'
        get '/join' => 'projects#join'
        #유저 탈퇴 로직,스스로도 탈퇴할 수있음
        get '/user_exit/:id' => 'projects#user_exit', as: 'user_exit'
        #유저 승인
        post '/user_authorize' => 'projects#user_authorize'
        #코맨트 등록 로직
        post '/comments' => 'projects#create_comment'
      end
      collection do
        
        #코맨트 삭제로직
        delete '/comments/:projectComment_id' => 'projects#destroy_comment'
        #코맨트 수정로직
        patch  '/comments/:projectComment_id' => 'projects#update_comment'
        #실시간 검색 로직
        post '/search' => 'projects#search_skills'
        #프로젝트 검색로직
        # post '/find_skill' => 'projects#find_skill'
      end
  end
  #프로젝트 이미지 업로드 로직
  post '/uploads' => 'projects#upload_image'

end
