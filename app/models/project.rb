class Project < ApplicationRecord
    #하나의 프로젝트는 여러사람이 조인 할 수 있다.
    mount_uploader :image_path, ProjectPictureUploader
    has_many :user_projects
    has_many :users, through: :user_projects
    #하나의 프로젝트에는 여러 코맨트가 달릴 수 있다.
    has_many :project_comments
    #하나의 프로젝트에는 여러개의 스킬셋이 존재할 수 있다.
    has_many :project_skills
    has_many :skills , through: :project_skills
    #하나의 프로젝트에는 여러개의 카테고리가 존재할 수 있다.
    has_many :project_categories
    has_many :categories,  through: :project_categories
    
    has_many :impressions, :as=>:impressionable
    is_impressionable :counter_cache => true, :unique => true
 
    #하나의 프로젝트가 담고있는 채팅은 여러개일 것이다.
    has_many :chats
    
    
    #하나의 프로젝트는 여러 사람들이 들어 올 수 있고 승인된 사람들의 목록을 띄우는 admissions가 필요하다
    #admissions에는 현재 프로젝트의 id와 유저들의 id가 필요하다
    # has_many    :admissions
    # has_many    :users, through: :admissions
    
    

   
    
    # after_commit :create_chat_room_notification , on: :create
    # 파라미터로 넘어온 user 객체
    def user_admit_room(user)   # self가 없으므르 인스턴스 메서드
    #가입하고자하는 사람의 id 그리고 해당 프로젝트의 id를 저장한다.
    #저장 이후 admission객체가 생성되는데 이후에 바로 admission모델의 액션이 수행된다.
        UserProject.create(user_id: user.id, project_id: self.id)
    end
    
    def user_exit_room(user)
        
        UserProject.where(user_id: user.id,project_id: self.id)[0].destroy
    end
    
    #self는 특정유저 팀장을 의미한다. 팀장과 연관된 admission을모두 파괴
    def master_exit_room
        self.admissions.destroy_all
        self.chat.destroy_all
        self.destroy
    end
 
    # 조회수 구현
   def impression_count
       impressions.size
   end
 
 
   def unique_impression_count
       # impressions.group(:ip_address).size gives => {'127.0.0.1'=>9, '0.0.0.0'=>1}
       # so getting keys from the hash and calculating the number of keys
       impressions.group(:ip_address).size.keys.length #TESTED
   end
end
