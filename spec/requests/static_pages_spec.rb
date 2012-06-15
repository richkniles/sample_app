require 'spec_helper'

describe "Static pages" do

  subject { page }

  shared_examples_for "all static pages" do
    it { should have_selector('h1', text: heading) }
    it { should have_selector('title', text: full_title(page_title))}
    it "should go to the About page when you click 'About'" do
        click_link "About"
        page.should have_selector('title', text: full_title('About Us'))
    end
    it "should go to the Help page when you click 'Help'" do
      click_link "Help"
      page.should have_selector('title', text: full_title('Help'))
    end
    it "should go to the Contact page when you click 'Contact'" do
      click_link "Contact"
      page.should have_selector('title', text: full_title('Contact'))
    end
    
  end
      
  describe "Home page" do
    before { visit root_path }
    let (:heading) { 'Sample App' }
    let (:page_title) { '' }
    it_should_behave_like 'all static pages'
    
    it { should_not have_selector 'title', text: '| Home' }

    it "should go to the Sign up page when you click 'Sign up now!'" do
      click_link "Sign up now!"
      page.should have_selector('title', text: full_title('Sign up'))
    end
    
  end

  describe "Help page" do
    before { visit help_path }
    let (:heading) { 'Help' }
    let (:page_title) { 'Help' }
    it_should_behave_like 'all static pages'
  end

  describe "About page" do
    before { visit about_path }
    let (:heading) { 'About' }
    let (:page_title) { 'About Us' }
    it_should_behave_like 'all static pages'
  end

  describe "Contact page" do
    before { visit contact_path }
    let (:heading) { 'Contact' }
    let (:page_title) { 'Contact' }
    it_should_behave_like 'all static pages'
  end
end
