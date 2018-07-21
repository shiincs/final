class Portfolio < ApplicationRecord
    mount_uploader :portfolio_file, PortfolioPictureUploader
    
    #하나의 포트폴리오는 한명의 유저에게 속한다.
    belongs_to :user
    
    #하나의 포트폴리오는 다양한 카테고리를 받을 수 있다.
    has_many :portfolio_categories
    has_many :categories ,through: :portfolio_categories
    
    #하나의 포트폴리오는 다양한 스킬을 받을 수 있다.
    has_many :portfolio_skills
    has_many :skills ,through: :portfolio_skills
end
