require 'spec_helper'

describe "user signup page" do
  
  subject { page }

  before { visit signup_path }
  
  it { should have_selector("h1",   text: "Sign up") }
  it { should have_selector("title", text: "Sign up")}

  describe "signup" do

    before { visit signup_path }

    let(:submit) { "Create my account" }

    describe "with invalid information" do

      it "should not create a user with no information" do
        expect { click_button submit }.not_to change(User, :count)
      end

      describe "after submission" do

        describe "with no user name" do
          before do
            signup_example_user_but_with ({ name: " ",  } )
          end 
          it { should have_selector('title', text: 'Sign up') }
          it { should have_content("Name can't be blank")}
        end

        describe "with no email" do
          before do
            signup_example_user_but_with ( { email: " " } )
          end 
          it { should have_selector('title', text: 'Sign up') }
          it { should have_content("Email can't be blank")}
        end

        describe "with invalid email" do
          before do
            signup_example_user_but_with({ email: "mary$mary.com" })
           end 
          it { should have_selector('title', text: 'Sign up') }
          it { should have_content("Email is invalid")}
        end
        
        describe "with no user_name" do
          before do
            signup_example_user_but_with ( { user_name: " " } )
          end 
          it { should have_selector('title', text: 'Sign up') }
          it { should have_content("User name can't be blank")}
        end
        
        describe "with no password" do
          before do
            signup_example_user_but_with( { password: " " })
          end 
          it { should have_selector('title', text: 'Sign up') }
          it { should have_content("Password can't be blank")}
        end

        describe "with short password" do
          before do
            signup_example_user_but_with( { password: "fooba" })
         end 
          it { should have_selector('title', text: 'Sign up') }
          it { should have_content("Password is too short")}
        end

        describe "with password confirmation not matching password" do
          before do
            signup_example_user_but_with( { password_confirmation: "foobas" })
          end 
          it { should have_selector('title', text: 'Sign up') }
          it { should have_content("Password doesn't match confirmation ")}
        end

      end

    end

    describe "with valid information" do
      before do
        fill_in "Name",         with: "Example User"
        fill_in "Email",        with: "user@example.com"
        fill_in "User name",    with: "user"
        fill_in "Password",     with: "foobar"
        fill_in "Password confirmation", with: "foobar"
      end
      it "should create a user" do
        expect { click_button submit }.to change(User, :count)
        page.should have_content("Micropost Feed")
      end

      # it "should go home" do
      #   expect { re }.to have_content("Micropost Feed") 
      # end
      # 
      describe "after saving the user" do
        before { click_button submit }
        let (:user) { User.find_by_email('user@example.com') }

        #it { should have_selector('title', text: user.name) }
        it { should have_selector('div.alert.alert-success', text: 'Welcome') }
        it { should have_link('Sign out') }

        describe "try to create another user with same email" do
          before do 
            click_link "Sign out"
            visit signup_path
            fill_in "Name",         with: "Example User"
            fill_in "Email",        with: "user@example.com"
            fill_in "Password",     with: "foobar"
            fill_in "User name",    with: "foouser"
            fill_in "Password confirmation", with: "foobar"
            click_button submit
          end
          it { should have_selector('title', text: 'Sign up') }
          it { should have_content("Email has already been taken")}

        end
        
        describe "try to create another user with same user_name" do
          before do 
            click_link "Sign out"
            visit signup_path
            fill_in "Name",         with: "Example User"
            fill_in "Email",        with: "foouser@example.com"
            fill_in "Password",     with: "foobar"
            fill_in "User name",    with: "user"
            fill_in "Password confirmation", with: "foobar"
            click_button submit
          end
          it { should have_selector('title', text: 'Sign up') }
          it { should have_content("User name has already been taken")}

        end
        
        describe "it should check user name uniqueness while typing" do
          let(:user) { FactoryGirl.create (:user) }
          # don't know how to do this without including implementation details in test
          it "should say already taken" do
            xhr :get, "/check_user_name_uniqueness", { user_name: user.user_name }
            response.should be_success
            #page.should have_content("taken")
          end
          it "should say available" do
            xhr :get, "/check_user_name_uniqueness", { user_name: "blah" }
            response.should be_success
            #page.should have_content("available")
          end
        end
        
        
      end
    end

  end

end


