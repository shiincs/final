class SkillUser < ApplicationRecord
    belongs_to :skill
    belongs_to :user
    
    def self.find_user_skill(user_id)
        @skills=[]
        user_skill=SkillUser.where(user_id: user_id)
            user_skill.each do |skills|
            @skills.push(Skill.find(skills.skill_id).skill_contents)
        end
        @skills
    end
end
