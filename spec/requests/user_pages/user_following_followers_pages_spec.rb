require 'spec_helper'

describe "User Pages" do
  subject {page}
  
  describe "following/followers" do
    let(:user)       { FactoryGirl.create(:user) }
    let(:other_user) { FactoryGirl.create(:user) }
    before { user.follow!(other_user) }
    
    describe "followed users" do
      before do
        sign_in user
        visit following_user_path(user)
      end
      
      it { should have_selector('title', text: full_title("Following")) }
      it { should have_selector('h3', text: "Following") }
      it { should have_link(other_user.name, href: user_path(other_user)) }
    end
    
    describe "followers" do
      before do
        sign_in other_user
        visit followers_user_path(other_user)
      end
      
      it { should have_selector('title', text: full_title("Followers")) }
      it { should have_selector('h3',    text: "Followers") }
      it { should have_link(user.name, href: user_path(user)) }
    end
  end
  
  describe "follow/unfollow buttons" do
    let(:user)       { FactoryGirl.create(:user) }
    let(:other_user) { FactoryGirl.create(:user) }

    before { sign_in user }
    
    describe "following a user" do
      before { visit user_path(other_user) }
           
      it "should increment the followed user count" do
        expect do
          click_button "Follow"
        end.to change(user.followed_users, :count).by(1)
      end
      
      it "should increment the other user's follwers count" do
        expect do
          click_button "Follow"
        end.to change(other_user.followers, :count).by(1)
      end
      
      describe "toggling the button" do
        before{ click_button "Follow" }
        it { should have_selector('input', value: "Unfollow") }
      end
    end
      
    describe "unfollowing a user" do
      before do
        user.follow!(other_user)
        visit user_path(other_user)
      end
      
      it "should decrement the followed user count" do
        expect do
          click_button "Unfollow"
        end.to change(other_user.followers, :count).by(-1)
      end
      
      describe "toggling the button" do
        before { click_button "Unfollow" }
        it { should have_selector('input', value: 'Follow') }
      end
    end

  end
  
end