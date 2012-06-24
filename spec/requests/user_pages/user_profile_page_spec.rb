require 'spec_helper'

describe "user profile page" do
  subject { page }

  let(:user) { FactoryGirl.create(:user) }
  let!(:m1)   { FactoryGirl.create(:micropost, user: user, content: "foo") }
  let!(:m2)   { FactoryGirl.create(:micropost, user: user, content: "bar") }
  before do
    visit user_path(user) 
  end
  
  it {should have_selector('h1',    text: user.name)}
  it {should have_selector('title', text: user.name)}
  
  describe "microposts" do
    
    it { should have_content("foo") }
    it { should have_content("bar") }
    it { should have_content(user.microposts.count) }
  end
end
