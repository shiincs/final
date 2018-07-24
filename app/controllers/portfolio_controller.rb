class PortfolioController < ApplicationController
  before_action :authenticate!
  before_action :set_user
  #포트폴리오 등록 페이지
  def portfolio
  end
  
  #포트폴리오 상세 페이지
  def portfolio_show
    @portfolio = Portfolio.find(params[:id])
  end
  
  def portfolio_delete
     PortfolioCategory.where(portfolio_id:params[:id]).destroy_all
     PortfolioSkill.where(portfolio_id:params[:id]).destroy_all
     Portfolio.destroy(params[:id])
     redirect_to "/#{current_user.user_name}/profile"
     #current_user로 변경 필요 
  end
  #포트폴리오 등록 로직
  def register_portfolio
    
    @user.increment!(:exp)
    #나중에 current_user를 만들어 줘야함
      start_date=[]
      end_date=[]
      #포트폴리오 시작 날짜
      start_date.push(params[:start_year])
      start_date.push(params[:start_month])
      portfolio_start=start_date.join('.')
      #포트폴리오 끝날짜
      
      end_date.push(params[:end_year])
      end_date.push(params[:end_month])
      portfolio_end = end_date.join('.')
      
      puts "포트폴리오 시작날짜"
      p portfolio_start
      puts "포트폴리오 끝날짜"
      p portfolio_end
      
      
      portfolio=Portfolio.create(
         portfolio_start: portfolio_start,
         portfolio_end: portfolio_end,
         portfolio_title: params[:portfolio_title],
         portfolio_contents:  params[:portfolio_introduce],
         portfolio_file: params[:file_path],
         portfolio_start: portfolio_start,
         portfolio_end: portfolio_end,
         user_id: current_user.id
      )
      skills = params[:skill].split(',');
      categories = params[:category].split(',');
      
      categories.each do |category|
        category_id=Category.find_by_category_contents(category).id
        PortfolioCategory.create(portfolio_id: portfolio.id,category_id: category_id)
      end
      
      skills.each do |skill|
        skill_id=Skill.find_by_skill_contents(skill).id
        PortfolioSkill.create(portfolio_id: portfolio.id,skill_id: skill_id)
      end
      
      redirect_to "/#{current_user.user_name}/profile"
  end
  
  #포트폴리오 수정 로직
  def portfolio_update
     #나중에 current_user를 만들어 줘야함
      start_date=[]
      end_date=[]
      #포트폴리오 시작 날짜
      start_date.push(params[:start_year])
      start_date.push(params[:start_month])
      portfolio_start=start_date.join('.')
      #포트폴리오 끝날짜
      
      end_date.push(params[:end_year])
      end_date.push(params[:end_month])
      portfolio_end = end_date.join('.')
      
      puts "포트폴리오 시작날짜"
      p portfolio_start
      puts "포트폴리오 끝날짜"
      p portfolio_end
    
    skills = params[:skill].split(',');
    categories = params[:category].split(',');
     Portfolio.find(params[:id]).update(
         portfolio_title: params[:portfolio_title],
         portfolio_contents:  params[:portfolio_introduce],
         portfolio_file: params[:file_path],
         portfolio_start: portfolio_start,
         portfolio_end: portfolio_end,
         user_id: @user.id
    )
      PortfolioCategory.where(portfolio_id: params[:id]).destroy_all
      PortfolioSkill.where(portfolio_id: params[:id]).destroy_all
    
      categories.each do |category|
        category_id=Category.find_by(category_contents: category)
       @p = PortfolioCategory.create(portfolio_id: params[:id],category_id: category_id.id)
        p @p.errors
      end
      
      skills.each do |skill|
        skill_id=Skill.find_by(skill_contents: skill)
        PortfolioSkill.create(portfolio_id: params[:id],skill_id: skill_id.id)
      end
      redirect_to "/portfolio/show/#{params[:id]}"
  end
  
  #포트폴리오 수정 페이지
  def portfolio_edit
    @portfolio = Portfolio.find(params[:id])
    p_start = @portfolio.portfolio_start.split(".")
    p_end = @portfolio.portfolio_end.split(".")
    
    @start_year = p_start[0]
    @start_month = p_start[1]
    @end_year = p_end[0]
    @end_month = p_end[1]
    
  end
  
  private
    def set_user
      @user = current_user
    end
    
    def authenticate!
       	unless user_signed_in?
        	redirect_to '/users/auth/github'
        end
    end
end
