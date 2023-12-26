PASSWORD_REGEX = /^(?=.*)(?=.*\d).{8,}/.freeze

get "/profile" do
  if session[:logged_in]
    # logic to retrieve and display user profile
    login_token = request.cookies.fetch("login_token", "").strip
    id =  UserToken.validate(login_token) # Get the user account ID from the login token cookie

    @user = User.where(user_id: id).first # Fetch the user from the database

    # If the user is suspended we redirect them to a suspended screen
    if session[:logged_in] && @user.suspended?
      status 403 # HTTP Unauthorised status
      redirect "/suspended"
      return
    end

    @courses = Db[:courses].all
    @unapproved_courses = Db[:course_approval_queue].all

    @title = "Profile - #{@user.profile.name}" # Get the name from the profile association

    if session[:error_type] == "course"
      @error_type = session[:error_type]
      @error = session[:error]
      session.delete(:error_type)
      session.delete(:error)
    end

    # If the user is an admin, manager or owner we fetch all suspended users
    if [1, 3, 4].include? @user.permission_level
      @users = User.dataset
      @suspended_users = SuspendedUser.join_table(:inner, :users, user_id: :user_id)
                                      .join_table(:left, :profiles, user_id: :user_id)
                                      .map(&:to_hash)
    end

    # If the user is a learner we fetch their courses and interests
    if @user.permission_level.zero?
      @my_courses = Course.join(CourseProgress.where(learner_id: id)
      .order(Sequel.desc(:progress)), course_id: :course_id)
      @interests = @user.profile.interests_list
    end
    erb :profile
  else
    redirect "/login"
  end
end

# Update learner personal information
post "/update-personal" do
  login_token = request.cookies.fetch("login_token", "").strip
  id = UserToken.validate(login_token)
  unless id
    status 401 # HTTP 401: UNAUTHORISED
    return ""
  end
  @user = User.where(user_id: id).first

  first_name = params.fetch("first_name", "")
  last_name = params.fetch("last_name", "")

  if first_name == "" || last_name == ""
    @error_type = "personal"
    @error = "You must enter values"
    return erb :profile
  end

  # Save new information & redirect back to the page

  @user.profile.first_name = first_name
  @user.profile.last_name = last_name
  @user.profile.save_changes

  redirect "/profile"
end

# Update learner's academic information
post "/update-academic" do
  login_token = request.cookies.fetch("login_token", "").strip
  id = UserToken.validate(login_token)
  unless id
    status 401 # HTTP 401: UNAUTHORISED
    return ""
  end
  @user = User.where(user_id: id).first

  level = params.fetch("course_level", "")
  year = params.fetch("year", "")

  if level == "" || year == ""
    @error_type = "academic"
    @error = "You must enter values"
    return erb :profile
  end

  level = level.to_i
  year = year.to_i

  if level.zero? || year.zero?
    @error_type = "academic"
    @error = "You must enter valid options"
    return erb :profile
  end

  # Save new information & redirect back to the page

  @user.profile.course_level = level
  @user.profile.year = year
  @user.profile.save_changes

  redirect "/profile"
end

post "/update-password" do
  login_token = request.cookies.fetch("login_token", "").strip
  id = UserToken.validate(login_token)
  unless id
    status 401 # HTTP 401: UNAUTHORISED
    return ""
  end
  @user = User.where(user_id: id).first

  current_password = params.fetch("currrent_password", "")
  currrent_password_confirm = params.fetch("current_password_confirm", "")
  new_password = params.fetch("new_password", "")

  # Validate the input

  if current_password == "" || currrent_password_confirm == "" || new_password == ""
    @error_type = "password"
    @error = "You must enter values"
    return erb :profile
  end

  if currrent_password_confirm != current_password
    @error_type = "password"
    @error = "Passwords do not match"
    return erb :profile
  end

  if @user.password_hash != current_password
    @error_type = "password"
    @error = "Incorrect password"
    return erb :profile
  end

  unless PASSWORD_REGEX.match(new_password)
    @error_type = "password"
    @error = "New password must be at least 8 characters and contain numbers"
    return erb :profile
  end

  # Update password and save
  @user.password_hash = new_password
  @user.save_changes

  redirect "/profile"
end

post "/add-interest" do
  login_token = request.cookies.fetch("login_token", "").strip
  id = UserToken.validate(login_token)
  unless id
    status 401 # HTTP 401: UNAUTHORISED
    return ""
  end
  @user = User.where(user_id: id).first

  # Add new user interests which are used for recomending
  interest = params[:interest]
  @user.profile.addInterest(interest)

  redirect "/profile"
end

post "/delete-interest" do
  login_token = request.cookies.fetch("login_token", "").strip
  id = UserToken.validate(login_token)
  unless id
    status 401 # HTTP 401: UNAUTHORISED
    return ""
  end
  @user = User.where(user_id: id).first

  interest = request.body.read
  @user.profile.removeInterest(interest)

  redirect "/profile"
end

post '/submit-course' do
  title = params[:title]
  description = params[:description]
  subject = params[:subject]
  provider = params[:provider]
  difficulty = params[:difficulty]
  link = params[:link]
  image = params[:image]

  # Validate input and send it to approval queue
  if title.empty? || description.empty? || subject.empty? || provider.empty? || difficulty.nil? || link.empty? || image.empty?
    session[:error] = "All fields are required"
    session[:error_type] = "course"
  else
    Db[:course_approval_queue].insert(title: title, description: description, subject: subject, provider: provider,
                                      difficulty: difficulty, link: link, image: image)
  end
  redirect "/profile"
end
