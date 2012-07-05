require 'spec_helper'

describe Relationship do

  let(:follower) { FactoryGirl.create(:user) }
  let(:followed) { FactoryGirl.create(:user) }
  let(:relationship) { follower.relationships.build(followed_id: followed.id) }

  subject { relationship }

  
  it { should be_valid }

  describe "accessible attributes" do
    it "should not allow access to follower_id" do
      expect do
        Relationship.new(follower_id: follower.id)
      end.should raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end    
  end
  
  describe "follower methods" do
    it { should respond_to(:follower) }
    it { should respond_to(:followed) }
    its(:follower) { should == follower }
    its(:followed) { should == followed }
  end
  
  describe "when followed id is not present" do
    before { relationship.followed_id = nil }
    it { should_not be_valid }
  end
     
  describe "when follower id is not present" do
    before { relationship.follower_id = nil }
    it { should_not be_valid }
  end
 
 describe "mutual self-assured destruction" do
   before { relationship.save }
   let!(:relationships) { follower.relationships }
   
   it "should have relationships" do
     relationships.count.should_not == 0
     relationships.each do |relationship|
       Relationship.find_by_id(relationship.id).should_not be_nil
     end
   end
   
   it "should delete relationships when follower is deleted" do
     follower.destroy 
     relationships.each do |relationship|
       Relationship.find(relationship.id).should be_nil
     end
   end
   it "should delete relationships when followed is deleted" do
     relationships.count.should_not == 0
     relationships.each do |relationship|
       Relationship.find_by_id(relationship.id).should_not be_nil
     end

     followed.destroy 
     relationships.each do |relationship|
       Relationship.find_by_id(relationship.id).should be_nil
     end
   end
 end
 
end
