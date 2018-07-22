class ProjectsController < ApplicationController
  before_action :authenticate_user!, except: [:index]
  before_action :set_user
  before_action :log_impression, :only=> [:show]
  before_action :set_project, only: [:show, :edit, :update, :destroy, :create_comment, :user_exit, :join, :user_authorize, :project_chat]

  # GET /projects
  # GET /projects.json
  #프로젝트 전체 리스트 불러오는 페이지
  def index
    
    if params[:project].nil?
      @projects = Project.all.order("impressions_count DESC")
    else
      skills = params[:project][:skill]
      categories = params[:project][:category]
      skills = skills.split(",")  
      categories = categories.split(",")
      skill_projects = Skill.where(skill_contents: skills).collect {|skill| skill.projects}.flatten
      category_projects = Category.where(category_contents: categories).collect {|category| category.projects}.flatten
      @projects = skill_projects.concat(category_projects).uniq 
    end
  end

  # GET /projects/1
  # GET /projects/1.json
  def show
  end
  
  #프로젝트 생성 페이지
  # GET /projects/new
  def new
    @project = Project.new
  end

  # GET /projects/1/edit
  def edit
  end

  # POST /projects
  # POST /projects.json
  #프로젝트 생성로직
  def create
    @project = Project.new(project_params)
    @project.master_id = current_user.id
    
    skills = params[:skill].split(",")
    categories = params[:category].split(",")
    
    
    respond_to do |format|
      if @project.save
        UserProject.create(user_id: current_user.id,project_id: @project.id,authorized_member: true)
       
        @project.update(project_start: @project.created_at) 
        skills.each do |skill|
          ProjectSkill.create(project_id: @project.id ,skill_id: Skill.find_by_skill_contents(skill).id)
        end
    
        categories.each do |category|
         ProjectCategory.create(project_id: @project.id, category_id: Category.find_by_category_contents(category).id)
        end 
        
        format.html { redirect_to @project, notice: 'Project was successfully created.' }
        format.json { render :show, status: :created, location: @project }
      else
        format.html { render :new }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /projects/1
  # PATCH/PUT /projects/1.json
  # 프로젝트 수정 로직 #페이지는 edit
  def update
    
    respond_to do |format|
      if @project.update(project_params)
        #값을 받아와 수정
        new_categories=params[:category].split(",")
        new_skills=params[:skill].split(",")
        
        categories=Category.where(category_contents: new_categories)
        skills=Skill.where(skill_contents: new_skills)
        
        ProjectSkill.where(project_id: @project.id).destroy_all
        ProjectCategory.where(project_id: @project.id).destroy_all
        
        categories.each do |category|
          ProjectCategory.create(project_id: @project.id, category_id: category.id)
        end
        
        skills.each do |skill|
          ProjectSkill.create(project_id: @project.id, skill_id: skill.id)
        end
        
        format.html { redirect_to @project, notice: 'Project was successfully updated.' }
        format.json { render :show, status: :ok, location: @project }
      else
        format.html { render :edit }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /projects/1
  # DELETE /projects/1.json
  def destroy
    #프로젝트 관련 댓글
    #프로젝트 관련 스킬,카테고리
    #프로젝트 관련 유저들 모두 삭제 그 이후 프로젝트 삭제
    ProjectSkill.where(project_id: @project.id).destroy_all
    ProjectComment.where(project_id: @project.id).destroy_all
    ProjectCategory.where(project_id: @project.id).destroy_all
    UserProject.where(project_id: @project.id).destroy_all
    Chat.where(project_id: @project.id).destroy_all
    @project.destroy
    respond_to do |format|
      format.html { redirect_to projects_url, notice: 'Project was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  
  def create_comment
    @comment = ProjectComment.create(user_id: current_user.id, project_id: @project.id, comment_contents: params[:comment_contents])
  end
  
  def update_comment
    @comment = ProjectComment.find(params[:projectComment_id])
    @comment.update(comment_contents: params[:comment_contents])
  end
  
  def destroy_comment
    @comment = ProjectComment.find(params[:projectComment_id]).destroy
  end
  
  def upload_image
    @image = Image.create(image_path: params[:upload][:image])
    render json: @image
  end
  
  def search_skills
    respond_to do |format|
      if params[:tech].strip.empty?
        format.js {render 'empty'} 
      else
        @skills = Skill.where("skill_contents Like ?","#{params[:tech]}%")
        format.js {render 'search_skill'}
      end
    end
  end
  
  def log_impression
      @hit_post = Project.find(params[:id])
      # this assumes you have a current_user method in your authentication system
      @hit_post.impressions.create(ip_address: request.remote_ip, user_id: current_user.id)
  end
  
  def join
    # if @project.users.empty?
    #   UserProject.create(user_id: current_user.id, project_id: params[:id])
    #   redirect_to "/projects/#{@project.id}"
    # else
    
    unless @project.user_projects.where(authorized_member: true).count==@project.project_people
         @project.users.each do |user|
            p "join 컨트롤러로 오는 변수"
            p @project
            if user.id != current_user.id
              p "여기까지 오나??"
              UserProject.create(user_id: current_user.id,project_id: @project.id,authorized_member: false)
              redirect_to "/projects/#{@project.id}", alert: "#{@project.project_title}에 신청하셨습니다!"
            else
              redirect_to "/projects/#{@project.id}", alert: "이미 신청인원입니다."
            end
        end
    else
       redirect_to "/projects/#{@project.id}", alert: "인원이 다 찼습니다."
    end
    
  end
  
  #신청한 사람을 취소했을 때 해당 로직이 수행되고 프로젝트 상세 페이지로 이동
  def user_exit
    UserProject.find_by(user_id: params[:cancel_user].to_i).destroy
    @user = User.find(params[:cancel_user])
    @project
  end
  
  #신청한 사람을 받을 때 ajax로 통해서 해당 사람이 바로 join되고 js파일 리턴
  def user_authorize
      UserProject.find_by(user_id: params[:accept_user].to_i).update(authorized_member: true) 
      @user = User.find(params[:accept_user].to_i)
      #현재 유저가 이미 가입한 프로젝트일 경우 alert가 뜨고 아닐 경우 유저를 가입시킨다.
      #방장이 승인해주기 때문에 current_user가 아닌 @user로 파라미터 값을 넘겨 줘야한다.
      # @project.user_admit_room(@user)  
  end
  
  #채팅  
  def project_chat
      puts current_user.id
      puts @project.id
      Chat.create(user_id: current_user.id,project_id: @project.id, message: params[:message])
  end
  
  private
    def set_user
      @user = current_user
    end
    # Use callbacks to share common setup or constraints between actions.
    def set_project
      @project = Project.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def project_params
      params.require(:project).permit(:project_title, :project_contents, :user_id, :project_people, :project_start, :project_end, :image_path)
    end
end