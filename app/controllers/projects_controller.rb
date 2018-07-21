class ProjectsController < ApplicationController
  before_action :authenticate_user!, except: [:index]
  before_action :log_impression, :only=> [:show]
  before_action :set_project, only: [:show, :edit, :update, :destroy, :create_comment, :user_exit, :join, :user_authorize]

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
    @user = current_user
  end

  # GET /projects/new
  def new
    @project = Project.new
  end

  # GET /projects/1/edit
  def edit
  end

  # POST /projects
  # POST /projects.json
  def create
    @project = Project.new(project_params)
    @project.master_id = current_user.id
    skills = params[:project][:skill].split(',')
    categories = params[:project][:category].split(',')
    
    
    respond_to do |format|
      if @project.save
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
  def update
    puts "하하하하하하하핳하하"
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
    if @project.users.empty?
       UserProject.create(user_id: current_user.id, project_id: params[:id])
       redirect_to "/projects/#{@project.id}"
    else
      @project.users.each do |user|
        if user.id != current_user.id
          UserProject.create(user_id: current_user.id, project_id: params[:id])  
        else
          redirect_to "/projects/#{@project.id}", alert: "이미 신청인원입니다."
        end
      end
    
    end
    
  end
  
  def user_exit
    puts "넘어온 값"
    puts params[:project_member].to_i
    UserProject.find_by(user_id: params[:project_member].to_i).delete
    redirect_to "/projects/#{@project.id}"
  end
  
  def user_authorize
    p "신청한 사람의 아이디는"
    p params[:request_id]
    UserProject.find_by(user_id: params[:request_id].to_i).update(authorized_member: true) 
    @user = User.find(params[:request_id].to_i)
  end
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_project
      @project = Project.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def project_params
      params.require(:project).permit(:project_title, :project_contents, :user_id, :project_people, :project_start, :project_end, :image_path)
    end
end