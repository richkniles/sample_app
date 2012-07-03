require 'spec_helper'

describe Micropost do
  
  describe Micropost do
    
    let(:user) { FactoryGirl.create(:user) }
    before do
      @micropost = user.microposts.build(content: "Lorem ipsum")
    end
    
    subject { @micropost }

    it { should respond_to(:content) }
    it { should respond_to(:user_id) }
    it { should respond_to(:user) }
    it { should respond_to(:in_reply_to) }
    its(:user) { should == user }
    
    it { should be_valid }
    
    describe "when user_id is not present" do
      before { @micropost.user_id = nil }
      it { should_not be_valid }
    end
    
    describe "accessible attributes" do
      it "should not allow access to user_id" do
        expect do
          Micropost.new(user_id: user.id)
        end.should raise_error(ActiveModel::MassAssignmentSecurity::Error)
      end
    end
    
    describe "with blank content" do
     before { @micropost.content = " " }
      it { should_not be_valid }
    end
    
    describe "with long content" do
      before { @micropost.content = "a" * 141 }
      it { should_not be_valid }
    end
    
    describe "with @not-a-user at front" do
      before { @micropost.content = "@not-a-user ipsum lorem"}
      it { should_not be_valid }
    end
    
    describe "with @user.name at front" do
      before { @micropost.content = "@#{user.user_name.downcase} ipsum lorem" }
      it { should be_valid }
    end
    describe "with @user.name at front different capitalization" do
      before { @micropost.content = "@#{user.user_name.upcase} ipsum lorem" }
      it { should be_valid }
    end
    describe "it should fill in in_reply_to on save" do
      before do
        @micropost.content = "@#{user.user_name} ipsum lorem"
        @micropost.save
      end
      its(:in_reply_to) { should == user.id }
    end
        
  end
end
