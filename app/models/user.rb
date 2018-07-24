class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,:omniauthable,
         :recoverable, :rememberable, :trackable, :validatable
         
     mount_uploader :user_image, ProfilePictureUploader
    #한명의 유저는 여러개의 스킬을 가질 수 있다.
    has_many :skill_users
    has_many :skills ,through: :skill_users
    
    #한명의 유저는 여러개의 카테고리를 가질 수 있다.
    has_many :user_categories
    has_many :categories ,through: :user_categories
    
    has_many :github_skills
    has_many :skills, through: :github_skills
    
    
    #한명의 유저는 여러개의 코맨트평을 남길 수 있다.
    has_many :user_comments
    #한명의 유저는 여러개의 포트폴리오를 가진다.
    has_many :portfolios
    #한명의 유저는 여러개의 메세지를 보낼 수 있다.
    has_many :messages
    #한명의 유저는 여러개의 프로젝트에 가입할 수 있다.
    has_many :user_projects
    has_many :projects, through: :user_projects
    
      
    # has_many   :admissions
    # has_many   :projects, through: :admissions # admission을 통해서 채팅룸 여러개를 가질 수 있다.
    has_many   :chats  # 여러개의 채팅을 가질 수 있다.
    
    #pagination
    paginates_per 9
    
    def joined_project?(project)
      self.projects.include?(project)#true or false
    end
    
    def self.from_omniauth(access_token)
    data = access_token.info
    user = User.where(email: data['email']).first

    # Uncomment the section below if you want users to be created if they don't exist
      if user.nil?
        p '데이터가 넘어옴'
        p data
        user = User.create(
                user_access_token: access_token['credentials']['token'],
                user_name: data['nickname'],
                email: data['email'],
                password: Devise.friendly_token[0,20],
            )
        end
       user
  end
end
