
class StaticPagesController < ApplicationController
  def home
    if signed_in?
      @micropost = current_user.microposts.build if signed_in?
      @microposts = current_user.feed.paginate(page: params[:page])
      @user = current_user
    end
  end

  def help
  end

  def about
  end
  
  def contact
  end
     
end
