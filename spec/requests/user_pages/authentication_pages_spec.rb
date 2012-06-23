require 'spec_helper'

describe "Authentication" do
  
  subject { page }

  let(:submit) { "Sign in" }
    
 
  describe "signin page" do
    before { visit signin_path }
    
    it { should have_selector('h1',    text: 'Sign in') }
    it { should have_selector('title', text: 'Sign in') }
  end
  
  describe "signin" do
    before { visit signin_path }
    
    describe "with valid information" do
      let(:user) { FactoryGirl.create(:user) }
      before { valid_signin(user) }
        
      it { should have_content("Welcome") }
      it { should have_link     'Users',    href: users_path      }
      it { should have_link     'Profile',  href: user_path(user) }
      it { should have_link     'Settings', href: edit_user_path(user)    }
      it { should_not have_link 'Sign in',  href: signin_path     }

      
      describe "followed by signout" do
        before { click_link "Sign out" }
        it { should have_link('Sign in') }
        it { should_not have_link     'Users',    href: users_path      }
        it { should_not have_link     'Profile'  }
        it { should_not have_link     'Settings' }
      end


    end
    
    describe "with invalid information" do
      
      before do
        click_button submit
      end
      it { should have_error_message("Invalid email/password combination") }
      
      describe "after visiting another page" do
      
        before { click_link "Home" }
        it { should_not have_error_message }
      
      end
      
    end
    
  end

  describe "Authentication on sign in" do
    
    let(:user) { FactoryGirl.create(:user) }
    before  { sign_in user }
    
    it { should have_content("Welcome") }
    it { should have_link('Profile',    href: user_path(user)) }
    it { should have_link('Settings',   href: edit_user_path(user)) }
    it { should have_link('Sign out',   href: signout_path) }
    it { should_not have_link('Sign in', href: signin_path) }
    
  end
  
  describe "Authorization" do
    describe "For non signed-in user" do
      let (:user) { FactoryGirl.create(:user) }
      
      describe "in the users controller" do
        describe "visiting the edit page" do
          before { visit edit_user_path(user) }
          it { should have_selector('title', text: "Sign in") }
          describe "after signing in it should friendly forward to edit" do
            before { sign_in user }
            it { should have_selector('title', text: "Edit") }
            describe "signing out and back in" do
              before do
                click_link "Sign out"
                sign_in user
              end
              it {should_not have_selector('title', text: 'Edit')}
            end
          end
        end
        
        describe "submitting to the update action" do
          before { put user_path(user) }
          specify { response.should redirect_to(signin_path) }
        end
        
        describe "visiting the users index" do
          before { visit users_path }
          it { should have_selector('title', text: "Sign in")}
          describe "after signing in it should friendly forward to index" do
            before { sign_in user }
            it { should have_selector('title', text: "All users") }
          end
        end
        
      end
      
    end

    describe "editing another user" do
      subject { page }
      let (:user) { FactoryGirl.create(:user) }
      let (:user2) { FactoryGirl.create(:user, name: "Joe Blow", email: "jblow@uu.com") }

      before { sign_in(user) }
      
      # describe "showing the profile of another user" do
      #   before { visit user_path(user2) }
      # 
      #   it {should_not have_selector('h1',    text: user2.name)}
      # end
      
      describe "visiting the edit page of another user" do
        before do 
           #sign_in(user) 
           visit edit_user_path(user2)
         end
         it { should_not have_selector('title', text: full_title('Edit user')) }
       end
       
       describe "submitting to the update action" do
         before do 
          # sign_in(user) 
           put user_path(user2)
         end
         specify { response.should redirect_to(root_path) }
       end
       
     end
     describe "as non-admin user" do
       let(:user) { FactoryGirl.create(:user) }
       let(:non_admin) { FactoryGirl.create(:user) }

       before { sign_in non_admin }

       describe "submitting a DELETE request to the Users#destroy action" do
         before { delete user_path(user) }
         specify { response.should redirect_to(root_path) }        
       end
     end
     describe "not signed in" do
       let(:user) { FactoryGirl.create(:user) }
       describe "submitting a DELETE request to the Users#destroy action" do
         before { delete user_path(user) }
         specify { response.should redirect_to(root_path) }        
       end
     end
   end

   describe "for signed in user" do
     let(:user) { FactoryGirl.create(:user) }
     before { sign_in user }
     
     describe "home page should not show the sign up button" do
       before { visit root_path }
       it { should_not have_link("Sign up")}
     end
     describe "home page should show the user name" do
       before { visit root_path }
       it { should have_content(user.name)}
     end
     describe "should not be able to sign up" do
       before { visit signup_path }
       it { should have_selector('title', text: full_title(""))}
     end
     
     describe "should not be able to submit a user" do
       before { post "/users" }
       specify { response.should redirect_to(root_path) }        
     end
   end
end
