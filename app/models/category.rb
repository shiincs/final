class Category < ApplicationRecord
    #하나의 카테고리는 여러 유저에게 속할 수 있다.
    has_many :user_categories
    has_many :users ,through: :user_categories
    #하나의 카테고리는 여러개의 프로젝트에 속할 수 있다.
    has_many :project_categories
    has_many :projects , through: :project_categories
    #하나의 카테고리는 여러개의 포트폴리오에 속할 수 있다.
    has_many :portfolio_categories
    has_many :portfolios ,through: :portfolio_categories
end

