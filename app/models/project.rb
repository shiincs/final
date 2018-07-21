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
