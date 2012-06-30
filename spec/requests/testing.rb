require 'spec_helper'

describe "Junk" do
  it do
    visit signin_path
    click_link "Sign in" 
    page.should have_content("Sign in")
  end
end