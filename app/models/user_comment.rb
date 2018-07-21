class UserComment < ApplicationRecord
    #하나의 유저 코맨트는 한명의 유저에게만 속해야한다
    belongs_to :user
end
