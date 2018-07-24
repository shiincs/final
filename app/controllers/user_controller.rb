class UserController < ApplicationController
    #이코드가 존재하면 모든 액션에 접근시 거부되어 sign_in페이지로 돌아간다.
    #로그인 되면 이제 각 액션에서 current_user 사용이 가능하다.
    before_action :authenticate_user!, except: [:index,:list]
    before_action :set_user
    # helper_method :search_user_skill
    def index
        @rank_skill = Hash.new
        store = []
        User.all.each do |user|
          store.push(user.git_skill_1)
          store.push(user.git_skill_2)
          store.push(user.git_skill_3)
        end
        remove_nil = store.compact
        remove_nil.each { |skill_name| 
        if @rank_skill[skill_name].nil? 
          @rank_skill[skill_name] = 1
        else
          @rank_skill[skill_name] += 1
        end
        }
        @rank_index =  @rank_skill.keys
        puts @rank_skill
        puts @rank_index
    end
    
  #모든 유저 리스트
  #유저 검색
  def list
   @users = User.all
   @pageuser = User.page(params[:page])
   skills_no = []
     unless params[:skill].nil? and params[:category].nil?
      skills = params[:skill].split(",")  
      categories = params[:category].split(",")
      
      skills.each do |skill|
        skills_no.push(Skill.find_by(skill_contents: skill).id)
      end
      
      skill_users = SkillUser.where(skill_id: skills_no).page(params[:page]).collect{|skill_user| skill_user.user}.flatten
      category_users = Category.where(category_contents: categories).page(params[:page]).collect {|cate| cate.users}.flatten
      @users = skill_users.concat(category_users).uniq
      p @users
    end
  end
  
  #프로필 수정 페이지
  def edit
    @year = 0
    @month = 0
    @day = 0
    unless @user.birth.nil?
      birth=@user.birth.split('.')
      @year = birth[0]
      @month = birth[1]
      @day = birth[2]
    end
    p "날짜 입니다."
    p @year 
    p @month 
    p @day 
  end
  

  
  #깃헙에서 받아온 자료 핸들링
  def github
    i=0
    result_skill= Hash.new
    start = []
    compare_skill_id =[]
    
    if session[:github_language].nil?
        # dummy1={"css"=>5000,"java"=>2500,"javascript"=>29394}
        # dummy2={"css"=>3232,"java"=>2500,"javascript"=>29394}
        # dummy3={"css"=>5000,"java"=>250440,"javascript"=>29394}
        # start.push(dummy1)
        # start.push(dummy2)
        # start.push(dummy3)
        puts "세션에 값이 없습니다 현재는"
        RestClient.post("https://api.github.com/users/repos?client_id=#{ENV['git_client_id']}&client_secret=#{ENV['git_secret_id']}")
        response=RestClient.get("https://api.github.com/users/#{current_user.user_name}/repos?client_id=#{ENV['git_client_id']}&client_secret=#{ENV['git_secret_id']}",
                                headers:{Authorization: current_user.user_access_token});
        ##git hub으로 부터 값을 가져온다.
        JSON.parse(response).each do |response| 
          languages = RestClient.get(response['languages_url']+"?client_id=#{ENV['git_client_id']}&client_secret=#{ENV['git_secret_id']}",
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
         
         compare_skill.each do |origin_skill_id|
            compare_skill_id.push(origin_skill_id)         
         end

         #기존에 언어가 있으면 byte값만 수정 기존에 언어가 없으면 모두 추가
         p "언어는 모두 합쳐 졌습니다."
         p result_skill
         p "등수를 매깁니다."
         p rank_skill
       #소문자로 db에 저장함
        result_skill.each{|key,value|
            if Skill.find_by(skill_contents: key.downcase).nil?
               Skill.create(skill_contents: key.downcase)
            end
            skill_id = Skill.find_by(skill_contents: key.downcase)
            if compare_skill_id.include?(skill_id.id)
              GithubSkill.find(user_id: current_user.id,skill_id: skill_id.id).update(skill_byte: value)
            else
              GithubSkill.create(user_id: current_user.id,skill_id: skill_id.id,skill_byte: value)
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
    # 해당 유저가 아직 깃헙으로 부터정보를 받지 않고 다른사람이 방문할 경우 에러가 발생할 수도있다.
    # unless Github_skills.find_by(user_id: @user.id).nil?
      github_language=GithubSkill.where(user_id: @user.id)
      #배열안에 여러개의 해시가 있는 형태 
    # end
      github_language.each do |skill_info|
        skill_name = Skill.find(skill_info.skill_id).skill_contents
        @github_language[skill_name] = skill_info.skill_byte
      end
      unless @user.address.nil?
        address=@user.address.split(" ")
        @address = address[0]+" "+address[1]
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
    make_birth = []
    puts params[:year]
    puts params[:month]
    puts params[:day]
    make_birth.push(params[:year])
    make_birth.push(params[:month])
    make_birth.push(params[:day])
    
    birth=make_birth.join('.')
    
    p " 생일 입니다."
    p birth
      
    skills = params[:skill].split(",")   ##받아 온 스킬들을 저장
    categories = params[:category].split(",") ##받아 온 카테고리들을 저장
    introduce = params[:introduce].strip ##받아 온 자기소개를 저장
    tel = params[:tel].strip ##받아 온 전화번호를 저장
    file_path = params[:file_path] ##회원 이미지 저장
    road_address = params[:road_address] ##회원 주소 저장 구 까지만

    if !current_user.user_contents.nil?
       SkillUser.where(user_id: current_user.id).destroy_all
       UserCategory.where(user_id: current_user.id).destroy_all
       current_user.update(user_contents: introduce,tel: tel,user_image: file_path,address: road_address,birth: birth)
    else
       current_user.update(user_contents: introduce,tel: tel,user_image: file_path,address: road_address,birth: birth) 
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
  
  private
    def set_user
      @user = current_user
    end
end
