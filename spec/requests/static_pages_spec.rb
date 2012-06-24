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
    
    describe 'for signed_in user' do
      let(:user) { FactoryGirl.create(:user) }
      before do
        FactoryGirl.create(:micropost, user: user, content: "micropost 1.")
        sign_in user
        visit root_path
      end
    
      it "should show the feed and paginate" do
        page.should have_content("1 micropost")
        30.times  do |i| 
          FactoryGirl.create(:micropost, user: user, content: "micropost #{i+2}.")
        end
        visit root_path
        page.should have_content("31 microposts")
        page.should have_selector("div.pagination") 
        30.times do |i|
          page.should have_content("micropost #{i+2}") 
        end
        # note the '1.' The period is required to avoid match with micropost 10
        page.should_not have_content("micropost 1.") 
      end

      
      it "should render the user feed" do
        user.feed.each do |item|
          page.should have_selector("li##{item.id}", text: item.content)
        end
      end
      
      describe "delete links" do
        let (:other_user) { FactoryGirl.create(:user) }
        before do
          FactoryGirl.create(:micropost, user: other_user, content: "should have delete link") 
          visit root_path
        end
        it "should only display delete links for signed-in user" do
          user.feed.each do |item|
            list_item = find_by_id("#{item.id}")
            if (item.user_id != user.id)
              list_item.should_not have_link("delete")
            else
              list_item.should have_link("delete")
            end
          end          
        end
      end
      
      describe "should wrap long words in micropost content display" do
        before do
          FactoryGirl.create(:micropost, user: user, content: "a"*140)
          visit root_path
        end
        it { should_not have_content("a"*31) }
      end
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
