class UserController < ApplicationController
    #이코드가 존재하면 모든 액션에 접근시 거부되어 sign_in페이지로 돌아간다.
    #로그인 되면 이제 각 액션에서 current_user 사용이 가능하다.
    before_action :authenticate_user!, except: [:index,:list]
    # before_action :set_user, only: [:show, :edit, :update, :destroy]
    # helper_method :search_user_skill
    def index
        @user = current_user
    end
    
  #모든 유저 리스트
  #유저 검색
  def list
   @users = User.all
   skills_no = []   
     unless params[:skill].nil? and params[:category].nil?
      skills = params[:skill].split(",")  
      categories = params[:category].split(",")
      
      skills.each do |skill|
        skills_no.push(Skill.find_by(skill_contents: skill).id)
      end
      
      skill_users = SkillUser.where(skill_id: skills_no).collect{|skill_user| skill_user.user}.flatten
      category_users = Category.where(category_contents: categories).collect {|cate| cate.users}.flatten
      @users = skill_users.concat(category_users).uniq 
      p @users
    end
  end
  
  #프로필 수정 페이지
  def edit
    @user = current_user
  end
  

  
  #깃헙에서 받아온 자료 핸들링
  def github
    i=0
    result_skill= Hash.new
    start = []
    if session[:github_language].nil?
        puts "세션에 값이 없습니다 현재는"
        response=RestClient.get("https://api.github.com/users/#{current_user.user_name}/repos?client_id=#{ENV['git_client_id']}&git_client_secret=#{ENV[git_client_secret]}",
                                headers:{Authorization: current_user.user_access_token});
        ##git hub으로 부터 값을 가져온다.
        JSON.parse(response).each do |response| 
          languages = RestClient.get(response['languages_url']+"?client_id=#{ENV['git_client_id']}&client_secret=#{ENV[git_client_secret]}",
                                  headers:{Authorization: current_user.user_access_token});
          start.push(JSON.parse(languages))
        end
    
          start.each do |hash|
            hash.each{|key,value| 
              if result_skill[key].nil?
                 result_skill[key] = value
              else
                 result_skill[key] = result_skill[key] + value
              end
            }
          end
       
          #언어 랭킹 매기는 로직
          rank_skill=result_skill.sort_by { |name, age| age }
      
      
         #각각의 언어 바이트를 db에 저장
         compare_skill = GithubSkill.where(user_id: current_user.id)

         #기존에 언어가 있으면 byte값만 수정 기존에 언어가 없으면 모두 추가
         p "언어는 모두 합쳐 졌습니다."
         p result_skill
         p "등수를 매깁니다."
         p rank_skill
       
        result_skill.each{|key,value|
            if Skill.find_by(skill_contents: key).nil?
               Skill.create(skill_contents: key)
            end
            skill_id = Skill.find_by(skill_contents: key).id
            if compare_skill.include?(skill_id)
              GithubSkill.find(user_id: current_user.id,skill_id: skill_id).update(skill_byte: value)
            else
              GithubSkill.create(user_id: current_user.id,skill_id: skill_id,skill_byte: value)
            end
        }
         

        #1,2,3위 저장
        current_user.update(git_skill_1: rank_skill[-1][0], git_skill_2: rank_skill[-2][0], git_skill_3: rank_skill[-3][0])  
        #언어 바이트를 세션에 저장한다
        session[:github_language] = result_skill
    end
    
   
      #만일 기존에 한번 요청이 되었을 경우에는 두번 요청 x session에 있는 값을 보내준다
      @github_language = session[:github_language]
      @github_language
      #js파일에서 해당 부분을 보여준다.
  end
 
  #프로필 상세보기
  def profile
    @github_language = Hash.new
    @user=User.find_by(user_name: params[:user_name])
    # unless Github_skills.find_by(user_id: @user.id).nil?
      github_language=GithubSkill.where(user_id: @user.id)
      #배열안에 여러개의 해시가 있는 형태 
    # end
      github_language.each do |skill_info|
        skill_name = Skill.find(skill_info.skill_id).skill_contents
        @github_language[skill_name] = skill_info.skill_byte
      end
      
      
      @github_language
      @user
  end

    #current_user로 나중에 만들어줘야함
  def new
    @user = current_user
  end


  
  ##실시간 검색기능
  def search
    respond_to do |format|
      if params[:tech].strip.empty?
        format.js {render 'empty'} 
      else
        @skills = Skill.where("skill_contents Like ?","#{params[:tech]}%")
        format.js {render 'search_skill'}
      end
    end
  end
  

  
  
   
    
 
  
  
   #등록하기
  def update
    ##향후 user_id는 current_user.id로 교체
    skills = params[:skill].split(",")   ##받아 온 스킬들을 저장
    categories = params[:category].split(",") ##받아 온 카테고리들을 저장
    introduce = params[:introduce] ##받아 온 자기소개를 저장
    tel = params[:tel] ##받아 온 전화번호를 저장
    file_path = params[:file_path] ##회원 이미지 저장
    road_address = params[:road_address].split(" ") ##회원 주소 저장 구 까지만
    unless road_address.empty?
      address = road_address[0]+road_address[1]  
    end
    if !current_user.user_contents.nil?
       SkillUser.where(user_id: current_user.id).destroy_all
       UserCategory.where(user_id: current_user.id).destroy_all
       current_user.update(user_contents: introduce,tel: tel,user_image: file_path,address: address)
    else
       current_user.update(user_contents: introduce,tel: tel,user_image: file_path,address: address) 
    end 
     skills.each do |skill|
       #ex) skill은 'javascript'
       #current_user 로 바꿔줘야함
        skill_id = Skill.find_by(skill_contents: skill)
        SkillUser.create(user_id: current_user.id,skill_id: skill_id.id)
     end
     categories.each do |category|
          category_id = Category.find_by(category_contents: category)
          UserCategory.create(user_id: current_user.id,category_id: category_id.id)
     end
     ##받아 온 자기소개를 저장
     redirect_to "/#{current_user.user_name}/profile"
  end
end
