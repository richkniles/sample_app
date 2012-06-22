require 'spec_helper'

describe "edit user" do 
  subject { page }

  let(:user) { FactoryGirl.create(:user) }
  before do
    sign_in(user)
    visit edit_user_path(user) 
  end
  
  describe "page" do
    it { should have_selector("h1", text: "Update your profile") }
    it { should have_selector("title", text: "Edit user") }
    it { should have_link("change") }
  end
  
  describe "with invalid information" do
    before { click_button "Save changes" }
    
    it { should have_content('error') }
  end
  
  describe "with valid information" do
    let (:new_name)  { "New Name" }
    let (:new_email)  { "new@email.com" }
    before do
      fill_in "Name",                 with: new_name
      fill_in "Email",                with: new_email
      fill_in "Password",             with: user.password
      fill_in "Password confirmation",with: user.password
      click_button "Save changes"
    end
    
    it { should have_selector('title', text: new_name) }
    it { should have_selector('div.alert.alert-success') }
    it { should have_link('Sign out', href: signout_path) }
    specify { user.reload.name.should == new_name }
    specify { user.reload.email.should == new_email }
  end
  
  
  
  
end
