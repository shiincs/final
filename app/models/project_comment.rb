class ProjectComment < ApplicationRecord
    #프로젝트 코맨트들은 하나의 프로젝트에 속한다.
    belongs_to :project
end
