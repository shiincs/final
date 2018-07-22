class Chat < ApplicationRecord
    belongs_to :user
    belongs_to :project
    
    #채팅이 생성되면 곧바로 유저의 id값과 무슨 말을 했는지 그리고 
    after_commit :chat_message_notification, on: :create
    
    def chat_message_notification
        Pusher.trigger("project_#{self.project_id}","chat",self.as_json.merge({user_name:self.user.user_name}))
    end
end
