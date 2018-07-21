class Message < ApplicationRecord
    #하나의메세지는 한명의 유저에게 속한다.
    belongs_to :user
end
