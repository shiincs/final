class UserProject < ApplicationRecord
    # 양쪽에 걸침
    belongs_to  :user       # 캐시 지정 true : 자동으로 업데이트가 됨.    
    belongs_to  :project
    
    after_commit :user_joined_project_notification, on: :update
    after_commit :user_exit_project_notification, on: :destroy
    
    def user_joined_project_notification
        Pusher.trigger("project_#{self.project_id}",'join',self.as_json.merge({user_name:self.user.user_name}))
    end
    
    def user_exit_project_notification
         Pusher.trigger("project_#{self.project_id}",'exit',self.as_json.merge({user_name:self.user.user_name}))
        #  Pusher.trigger("project_#{self.project_id}",'disaster',self.as_json.merge({user_name:self.user.user_name}))
    end
end
