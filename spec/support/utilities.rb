def full_title(page_title)
  base_title = "Ruby on Rails Tutorial Sample App"
  if page_title.empty?
    base_title
  else
    "#{base_title} | #{page_title}"
  end
end

def valid_signin(user)
  fill_in "Email",    with: user.email
  fill_in "Password", with: user.password
  click_button "Sign in"
end

def signup_example_user_but_with(params)
  fill_in "Name",         with: (params[:name] || "Example User")
  fill_in "Email",        with: (params[:email] || "user@example.com")
  fill_in "User name",    with: (params[:user_name]) || "user"
  fill_in "Password",     with: (params[:password] || "foobar")
  fill_in "Password confirmation", with: (params[:password_confirmation] || "foobar")
  click_button submit
end

def sign_in(user)
  visit signin_path
  fill_in "Email",        with: user.email
  fill_in "Password",     with: user.password
  click_button "Sign in"
  # Sign in when not using Capybara as well.
  cookies[:remember_token] = user.remember_token
end

Rspec::Matchers.define :have_error_message do |message|
  match do |page|
    page.should have_selector('div.alert.alert-error', text: message)
  end
end

