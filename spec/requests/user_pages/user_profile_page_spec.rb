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
    it { should have_content("Microposts (#{user.microposts.count})") }
    it "should paginate" do
      30.times do |i|
        FactoryGirl.create(:micropost, user: user, content: "micropost #{i+1}.")
      end
      visit user_path(user)
      page.should have_selector("div.pagination")
      30.times do |i|
        page.should have_content("micropost #{i+1}.")
      end
      page.should_not have_content("foo")
    end
    it "should wrap display of long words in content" do
      FactoryGirl.create(:micropost, user: user, content: "a"*140)
      visit user_path(user)
      page.should_not have_content("a"*31)
    end
  end
end
