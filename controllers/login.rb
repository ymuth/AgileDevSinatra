require 'bcrypt'

# Regular expression that checks that:
# Password has any character in any position
# Password has any digit in any position
# Password is at least 8 characters long
PASSWORD_REGEX = /^(?=.*)(?=.*\d).{8,}/.freeze
THIRTY_DAYS_IN_SECONDS = 30 * 24 * 60 * 60

# displays a login form and validates the user's credentials when they submit the form

get "/login" do
  login_token = request.cookies.fetch("login_token", "").strip
  if UserToken.validate(login_token)
    session[:logged_in] = true
    redirect "/"
  else
    erb :login
  end
end

# fetches username and password from parameter fetching form.
# sends error if either username or password not submitted

post "/login" do
  username = params.fetch("username", "")
  password = params.fetch("password", "")
  if username == "" || password == ""
    @error = "Enter a username and password"
    return erb :login
  end

  # if there is a match, session logged in is set to true

  @user = User.where(username: username).first
  if @user && @user.password_hash == password
    session[:logged_in] = true
    response.set_cookie("login_token", {
                          # generates a token based on the user's ID and a secret key.
                          value: UserToken.generate(@user),
                          expires: Time.now + THIRTY_DAYS_IN_SECONDS
                        })
    redirect "/"
  else
    # error message when there is no match
    @error = "Incorrect username or password"
    erb :login
  end
end

get "/signup" do
  erb :signup
end

# displays signup form and creates a new user account when the user submits the form

post "/signup" do
  @username = params.fetch("username", "")
  @email = params.fetch("email", "")
  @raw_password = params.fetch("password", "")

  # if user does not enter anything, error message is prompted

  if @username == "" || @email == "" || @raw_password == ""
    @error = "Please fill in all fields"
    return erb :signup
  end

  # checks if there is the username in the database, that the user entered.

  if User.where(username: @username).first
    @error = "Username is already taken"
    return erb :signup
  end

  # checks for existing emails

  if User.where(email: @email).first
    @error = "Email is already being used"
    return erb :signup
  end

  # checks if password matches with PASSWORD_REGEX, then creates new account and save in to database

  if @raw_password.match(PASSWORD_REGEX)
    @user = User.new
    @user.username = @username
    @user.password_hash = @raw_password
    @user.email = @email
    @user.permission_level = 0
    @user.save_changes

    # Create Profile
    @profile = Profile.new
    @profile.first_name = "Unknown"
    @profile.last_name = "Unknown"
    @profile.course_level = 0
    @profile.year = 0
    @profile.user_id = @user.user_id
    @profile.save_changes

    session[:logged_in] = true
    response.set_cookie("login_token", {
                          value: UserToken.generate(@user),
                          expires: Time.now + THIRTY_DAYS_IN_SECONDS
                        })
    redirect "/"
  else
    @error = "Password must be greater than 8 characters and contain at least 1 number"
  end
  erb :signup
end

get "/logout" do
  login_token = request.cookies.fetch("login_token", "").strip
  # Remove local cookie and token from database
  response.delete_cookie("login_token")
  UserToken.where(token: login_token).delete

  session.clear
  redirect "/"
end

post "/delete-tokens" do
  login_token = request.cookies.fetch("login_token", "").strip
  @user_id = UserToken.validate(login_token)

  return unless @user_id

  UserToken.where(user_id: @user_id).each(&:delete)
  redirect "/logout"
end
