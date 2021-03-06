# == Schema Information
#
# Table name: users
#
#  id         :integer         not null, primary key
#  name       :string(255)
#  email      :string(255)
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

require 'spec_helper'

describe User do

  before do 
    @user = User.new(name: "Example User", email: "user@example.com", user_name: "Example",
                      password: "foobar", password_confirmation: "foobar")
  end
  
  subject { @user }
  
  it { should respond_to(:name)  }
  it { should respond_to(:email) }
  it { should respond_to(:user_name) }
  it { should respond_to(:password_digest)}
  it { should respond_to(:password) }
  it { should respond_to(:password_confirmation) }
  it { should respond_to(:remember_token) }
  it { should respond_to(:admin) }
  it { should respond_to(:authenticate) }
  
  it { should respond_to(:microposts) }
  it { should respond_to(:feed) }
  
  it { should respond_to(:relationships) }
  it { should respond_to(:followed_users) }
  it { should respond_to(:following?) }
  it { should respond_to(:follow!) }
  it { should respond_to(:unfollow!) }
  
  it { should respond_to(:reverse_relationships) }
  it { should respond_to(:followers) }
    
  it { should be_valid }
  
  describe "when name is not present" do
    before { @user.name = " " }
    it { should_not be_valid }
  end
  
  describe "when email is not present" do
    before { @user.email = " " }
    it { should_not be_valid }
  end
  
  describe "when user_name is not present" do
    before { @user.user_name = " " }
    it { should_not be_valid }
  end
  
  describe "when name is too long" do
    before {  @user.name = "a"*51 }
    it { should_not be_valid }
  end
  
  describe "when email format is invalid" do
    it "should be invalid" do
      addresses = %w[user@foo,com user_at_foo.org example.user@foo.
                       foo@bar_baz.com foo@bar+baz.com]
      addresses.each do |invalid_address|
        @user.email = invalid_address
        @user.should_not be_valid
      end      
    end
  end

  describe "when email format is valid" do
    it "should be valid" do
      addresses = %w[user@foo.COM A_US-ER@f.b.org frst.lst@foo.jp a+b@baz.cn]
      addresses.each do |valid_address|
        @user.email = valid_address
        @user.should be_valid
      end      
    end
  end
  
  describe "when email address is already taken" do
    before do
      user_with_same_email = @user.dup
      user_with_same_email.email = @user.email.upcase
      user_with_same_email.save
    end
    
    it { should_not be_valid }
  end
  
  describe "user name already taken" do
    before do
      user_with_same_user_name = @user.dup
      user_with_same_user_name.user_name = @user.user_name.upcase
      if user_with_same_user_name.user_name == @user.user_name
        user_with_same_user_name.user_name = @user.user_name.downcase 
      end
      user_with_same_user_name.save
    end
      
    it { should_not be_valid }
  end
  
  describe "when password is not present" do
    before { @user.password = @user.password_confirmation = " " }
    it { should_not be_valid }
  end
  
  describe "when password doesn't match confirmation" do
    before { @user.password_confirmation = "mismatch" }
    it { should_not be_valid }
  end
  
  describe "when password_confirmation is nil" do
    before { @user.password_confirmation = nil }
    it { should_not be_valid }
  end
  
  
  describe "with a password that's too short" do
    before { @user.password = @user.password_confirmation = "a"*5 }
    it { should be_invalid }
  end
  
  describe "return value of authenticate method" do
    before { @user.save }
    let (:found_user) { User.find_by_email(@user.email) }
    
    describe "with valid password" do
      it { should == found_user.authenticate(@user.password) }
    end
    
    describe "with invalid password" do
      let(:user_for_invalid_password) { found_user.authenticate("invalid") }
    
      it { should_not == user_for_invalid_password }
      specify { user_for_invalid_password.should be_false }
    end
  end
  
  describe "mixed case email" do
    let(:mixed_case_email) { "RichKNiles@Gmail.Com" }
    
    it "should be saved as all lower case" do
      @user.email = mixed_case_email 
      @user.save 
      @user.reload.email.should == mixed_case_email.downcase
    end
  end
  
  describe "remember token" do
    before { @user.save }
    its(:remember_token) { should_not be_blank }
  end
  
  describe "when try to access admin attribute through the controller" do
    it "should not allow access to admin" do
      expect do
        @user.assign_attributes(admin: true)
      end.should raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end
  end
  
  describe "with admin attribute set to true" do
    before { @user.toggle!(:admin) }
    
    it { should be_admin }
  end
  
  describe "micropost associations" do
    
    before { @user.save }
    let!(:older_micropost) do
      FactoryGirl.create(:micropost, user: @user, created_at: 1.day.ago)
    end
    let!(:newer_micropost) do
      FactoryGirl.create(:micropost, user: @user, created_at: 1.hour.ago)
    end
    
    it "should have the right order" do
      @user.microposts.should == [newer_micropost, older_micropost]
    end
    
    it "should destroy assocated microposts" do
      microposts = @user.microposts
      @user.destroy
      microposts.each do |micropost|
        Micropost.find_by_id(micropost.id).should be_nil
      end
    end
    
    describe "micropost feed" do
      let(:unfollowed_post) do
        FactoryGirl.create(:micropost, user: FactoryGirl.create(:user, user_name: 'UnFollowedUser'))
      end
      let!(:followed_user) { FactoryGirl.create(:user, user_name: 'FollowedUser') }
      
      before do
        @user.follow!(followed_user)
        3.times { followed_user.microposts.create(content: "Lorem ipsum")}
      end
      
      its(:feed) { should include(newer_micropost) }
      its(:feed) { should include(older_micropost) }
      its(:feed) { should_not include(unfollowed_post) }
      its(:feed) do
        followed_user.microposts.each do |micropost|
          should include(micropost)
        end
      end
      describe "replies should land in appropriate feeds" do
        let!(:third_user) { FactoryGirl.create(:user) }
        let!(:reply_micropost_to_followed_user) do
          third_user.microposts.create content: "@FollowedUser ipsum nicht!"
        end
        let!(:reply_micropost_to_unfollowed_user) do
          third_user.microposts.create content: "@UnFollowedUser ipsum nicht!"
        end
        before do
          third_user.follow!(followed_user)
          reply_micropost_to_followed_user.save
          reply_micropost_to_unfollowed_user.save
        end
        
        describe "reply to followed user" do
          its(:feed) { should include(reply_micropost_to_followed_user) } 
        end
        
        describe "reply to unfollowed user" do
          its(:feed) { should_not include(reply_micropost_to_unfollowed_user) }
        end
      end

    end
    
    
  end
  
  describe "following" do
    let(:other_user) { FactoryGirl.create(:user) }
    before do
      @user.save
      @user.follow!(other_user)
    end
    
    it { should be_following(other_user) }
    its(:followed_users) { should include(other_user) }
    
    describe "followed user" do
      subject { other_user }
      its(:followers) { should include(@user) }
    end
    
    describe "and unfollowing" do
      before { @user.unfollow!(other_user) }
      
      it { should_not be_following(other_user) }
      its(:followed_users) { should_not include other_user }
    end
  end
  
end
