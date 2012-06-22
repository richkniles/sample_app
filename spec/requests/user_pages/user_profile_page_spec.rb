require 'spec_helper'

describe "user profile page" do
  subject { page }

  let(:user) { FactoryGirl.create(:user) }
  before { visit user_path(user) }
  
  it {should have_selector('h1',    text: user.name)}
  it {should have_selector('title', text: user.name)}
end
