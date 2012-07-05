
class MicropostsController < ApplicationController
  before_filter :signed_in_user
  before_filter :correct_user, only: :destroy
  
  def index
    @query = params[:q]
    @microposts = Micropost.where("content like ?", "%#{params[:q]}%").paginate(page: params[:page])
  end
  
  def create
    @micropost = current_user.microposts.build(params[:micropost])
    if @micropost.save
      flash[:success] = "Micropost created"
      redirect_to root_path
    else
     #@feed_items = current_user.feed
     @user = current_user
     @microposts = current_user.feed.paginate(page: params[:page])
     render 'static_pages/home'
     #flash[:error] = @micropost.errors.full_messages.join
     #redirect_to root_path
     
    end
  end
  
  def destroy
    @micropost.destroy
    redirect_to root_path
  end
  
  private
    
    def correct_user
      @micropost = current_user.microposts.find_by_id(params[:id])
      redirect_to root_path if @micropost.nil?
    end
end
