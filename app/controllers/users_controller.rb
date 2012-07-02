
class UsersController < ApplicationController
  
  before_filter :signed_in_user, 
            only: [:index, :edit, :update, :show, :following, :followers]
  before_filter :correct_user, only: [:edit, :update]
  before_filter :admin_user, only: [:destroy]
  before_filter :not_signed_in, only: [:new, :create]
  
  def index
    @users = User.paginate(page: params[:page])
  end
  
  def show
    @user = User.find(params[:id])
    @microposts = @user.microposts.paginate(page: params[:page])
  end
  
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(params[:user])
    if @user.save
      sign_in @user
      flash[:success] = "Welcome to the sample app!"
      redirect_to root_path
    else
      render 'new'
    end
  end
  
  def edit
    @user = User.find_by_id(params[:id])
  end
  
  def update
    @user = User.find_by_id(params[:id])
    if (@user.update_attributes(params[:user]))
      flash[:success] = "Profile updated"
      sign_in @user
      redirect_to @user
    else
      render 'edit'
    end
  end
  
  def destroy
    user = User.find_by_id(params[:id])
    if (user.admin?) then
      flash[:failure] = "You don't want to do that!"
    else
      user.destroy
      flash[:success] = "User deleted."
    end
    redirect_to users_path
  end
  
  def following
    @title = "Following"
    @user = User.find(params[:id])
    @users = @user.followed_users.paginate(page: params[:page])
    render 'show_follow'
  end
  
  def followers
    @title = "Followers"
    @user = User.find(params[:id])
    @users = @user.followers.paginate(page: params[:page])
    render 'show_follow'
  end
  
  def check_user_name_uniqueness
    user_name = params[:user_name]
    if (user_name.empty?)
      @username_notification = " -- can not be empty!"
    elsif current_user && current_user.user_name == user_name
      @username_notification = " -- that is you!"
    elsif current_user && current_user.user_name.downcase == user_name.downcase
      @username_notification = " -- ok to change capitaliztion..."
    else
      match = User.where("LOWER(user_name) = '#{user_name.downcase}'")
      avail = (match.count==0)
      @username_notification = "#{avail ? 'available' : 'taken'}"
    end
   # @style = "#{avail ? 'color:red; text-decoration:blink' : 'color:green; text-decoration:none'}"
    render 'username_notification'
  end
  
  private
  
    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_path) unless current_user?(@user)
    end
    
    def admin_user
      redirect_to(root_path) unless signed_in? && current_user.admin
    end
      
    def not_signed_in
      redirect_to(root_path) if signed_in?
    end
  
end
