post "/suspend-user" do
  user_id = params.fetch("user_id", "")
  time = params.fetch("time", "")

  # Fetch the staff member's user model and check permission
  login_token = request.cookies.fetch("login_token", "").strip
  staff_id =  UserToken.validate(login_token)
  staff = User.where(user_id: staff_id).first

  unless [3, 1].include? staff.permission_level
    # User is not manager or admin
    status 403 # FORBIDDEN
    return ""
  end

  # Calculate expiry date using unix time
  expiry = Time.now.to_i + time.to_i
  Db[:suspended_users].insert(user_id: user_id, suspended_by: staff_id, expiry: expiry)

  redirect "/profile"
end

post "/revoke-suspension" do
  user_id = request.body.read

  login_token = request.cookies.fetch("login_token", "").strip
  staff_id =  UserToken.validate(login_token)
  staff = User.where(user_id: staff_id).first

  unless [3, 1].include? staff.permission_level
    status 403
    return ""
  end

  SuspendedUser.where(user_id: user_id).delete

  redirect "/profile"
end

post '/approve-course' do
  login_token = request.cookies.fetch("login_token", "").strip
  staff_id =  UserToken.validate(login_token)
  staff = User.where(user_id: staff_id).first

  unless [1, 2, 3].include? staff.permission_level
    status 403
    redirect "/profile"
  end

  course_id = params[:course_id]

  # Find the course in the approval queue
  course = Db[:course_approval_queue].where(course_id: course_id).first

  # Insert the course into the courses table
  Db[:courses].insert(title: course[:title], description: course[:description], subject: course[:subject],
                      provider: course[:provider], difficulty: course[:difficulty], link: course[:link], rating: course[:rating], image: course[:image], archived: false)

  # Delete the course from the approval queue
  Db[:course_approval_queue].where(course_id: course_id).delete

  redirect "/profile"
end

post '/reject-course' do
  login_token = request.cookies.fetch("login_token", "").strip
  staff_id =  UserToken.validate(login_token)
  staff = User.where(user_id: staff_id).first

  unless [1, 2, 3].include? staff.permission_level
    status 403
    redirect "/profile"
  end

  course_id = params[:course_id]

  # Delete the course from the approval queue
  Db[:course_approval_queue].where(course_id: course_id).delete

  redirect "/profile"
end

post '/submit-course-moderator' do
  login_token = request.cookies.fetch("login_token", "").strip
  staff_id =  UserToken.validate(login_token)
  staff = User.where(user_id: staff_id).first

  unless [1, 2, 3].include? staff.permission_level
    status 403
    redirect "/profile"
  end

  title = params[:title]
  description = params[:description]
  subject = params[:subject]
  provider = params[:provider]
  difficulty = params[:difficulty]
  link = params[:link]
  image = params[:image]

  if title.empty? || description.empty? || subject.empty? || provider.empty? || difficulty.nil? || link.empty? || image.empty?
    @error = "All fields are required"
    @error_type = "course"
  else
    Db[:courses].insert(title: title, description: description, subject: subject, provider: provider,
                        difficulty: difficulty, link: link, image: image)
  end
  redirect "/profile"
end

post '/edit-user-profile' do
  user_id = params[:user_id].to_i
  @user = User.where(user_id: user_id).first
  erb :edit_user_profile
end

post '/edit-user-profile/:id' do
  user_id = params[:id].to_i
  @user = User.where(user_id: user_id).first

  @user.username = params[:username]
  @user.password_hash = params[:password]
  @user.email = params[:email]
  @user.permission_level = params[:permission_level]
  @user.save
  redirect "/profile"
end

post '/archive-course' do
  login_token = request.cookies.fetch("login_token", "").strip
  staff_id =  UserToken.validate(login_token)
  staff = User.where(user_id: staff_id).first

  # Give access to all staff including course provider
  unless [1, 2, 3, 4, 5].include? staff.permission_level
    status 403
    redirect "/profile"
  end

  course_id = params.fetch("course_id", "")

  if course_id.empty?
    status 404
    redirect "/profile"
  end

  course = Course.where(course_id: course_id).first

  unless course
    status 404
    redirect "/profile"
  end

  course[:archived] = if (course[:archived]).zero?
                        1
                      else
                        0
                      end

  course.save_changes

  redirect "/profile"
end

post '/submit-course-provider' do
  login_token = request.cookies.fetch("login_token", "").strip
  staff_id =  UserToken.validate(login_token)
  staff = User.where(user_id: staff_id).first

  unless [5].include? staff.permission_level
    status 403
    redirect "/profile"
  end

  title = params[:title]
  description = params[:description]
  subject = params[:subject]
  provider = params[:provider]
  difficulty = params[:difficulty]
  link = params[:link]
  image = params[:image]
  archived = true # Hidden by default

  if title.empty? || description.empty? || subject.empty? || provider.empty? || difficulty.nil? || link.empty? || image.empty?
    @error = "All fields are required"
    @error_type = "course"
  else
    Db[:courses].insert(title: title, description: description, subject: subject, provider: provider,
                        difficulty: difficulty, link: link, image: image, archived: archived)
  end
  redirect "/profile"
end
