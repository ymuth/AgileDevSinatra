PASSWORD_REGEX = /^(?=.*)(?=.*\d).{8,}/.freeze
# Fetch the user's information from the database and searches courses by title.
get '/search' do
  login_token = request.cookies.fetch("login_token", "").strip
  user_id = UserToken.validate(login_token)
  @user = User.where(user_id: user_id).first

  if session[:logged_in] && @user.suspended?
    status 403
    redirect "/suspended"
  end

  @results = Course.where(Sequel.ilike(:title, "%#{params[:query]}%"))
  erb :search
end

get '/courses/:id' do
  # Fetch the course details from the database
  course = Course.where(course_id: params[:id]).first

  # Return the course details in a JSON format
  json course: {
    id: course['course_id'],
    title: course['title'],
    description: course['description'],
    subject: course['subject'],
    provider: course['provider'],
    difficulty: course['difficulty'],
    link: course['link'],
    rating: course['rating'],
    image: course['image']
  }
end

# Fetch the details of a specific course by its ID and renders into course_details
get '/course_details/:id' do
  course_id = params[:id].to_i
  @course = Course.where(course_id: params[:id]).first
  erb :course_details
end

# renders a form that allows the user to edit course details.
post '/edit-course-details' do
  course_id = params[:course_id].to_i
  @course = Course.where(course_id: course_id).first
  erb :edit_course_details
end

# updates course details in the database based on the form data submitted by the user.
post '/edit-course-details/:id' do
  course_id = params[:id].to_i
  @course = Course.where(course_id: course_id).first

  @course.title = params[:title]
  @course.description = params[:description]
  @course.subject = params[:subject]
  @course.provider = params[:provider]
  @course.difficulty = params[:difficulty]
  @course.link = params[:link]
  @course.image = params[:image]
  @course.save

  redirect "/profile"
end

# enrolls a user in a course by creating new CourseProgress record in the database
post "/enroll-course" do
  course_id = params.fetch("course_id", "")
  login_token = request.cookies.fetch("login_token", "").strip
  user_id = UserToken.validate(login_token)

  if course_id.empty?
    status 404
    "Course Not Found"
  elsif CourseProgress.where(learner_id: user_id, course_id: course_id).first
    status 400
    "Already Enrolled"
  else
    course = CourseProgress.new
    course.course_id = course_id
    course.learner_id = user_id
    course.progress = 0
    course.rating = 0
    course.save_changes

    redirect "/profile"
  end
end

# updates a user's progress in a course by updating the progress field of their CourseProgress record in the database.
post "/update-progress" do
  course_id = params.fetch("course_id", "")
  progress = params.fetch("progress", "")
  login_token = request.cookies.fetch("login_token", "").strip
  user_id = UserToken.validate(login_token)

  if progress.empty?
    status 400
    return redirect "/profile"
  end

  course_progress = CourseProgress.where(learner_id: user_id, course_id: course_id).first
  if course_progress
    course_progress.progress = progress
    course_progress.save_changes
    redirect "/profile"
  else
    status 404
    "Course Not Found"
  end
end

# allows user to rate a course by updating the rating field of their CourseProgress record in the database.
post "/rate-course" do
  course_id = params.fetch("course_id", "")
  course_id = course_id.to_i
  score = params.fetch("score", "")
  login_token = request.cookies.fetch("login_token", "").strip
  user_id = UserToken.validate(login_token)

  if score.empty?
    status 400
    "Score Not Given"
  end

  course_progress = CourseProgress.where(learner_id: user_id, course_id: course_id).first
  if course_progress
    course_progress.rating = score.to_i
    course_progress.save_changes
  else
    status 404
    "Course Not Found"
  end
end

#  marks course as complete by updating the progress field of the user's CourseProgress record in the database.
post "/update-done" do
  course_id = params.fetch("course_id", "")
  course_id = course_id.to_i
  score = params.fetch("score", "")
  login_token = request.cookies.fetch("login_token", "").strip
  user_id = UserToken.validate(login_token)

  course = CourseProgress.where(learner_id: user_id, course_id: course_id).first
  if course
    course.progress = 101
  else
    course = CourseProgress.new
    course.course_id = course_id
    course.learner_id = user_id
    course.progress = 101
    course.rating = 0

  end
  course.save_changes
  redirect "/profile"
end

# allows the user to search their course history and renders result to course_history

get "/course-history" do
  query = params.fetch("search", "")
  @courses = if query.empty?
               Course.dataset
             else
               Course.where(Sequel.like(:title, "%#{query}%"))
             end

  erb :course_history
end

#  adds a course to the user's course history by creating a new CourseProgress record in the database.

post "/add-course-history" do
  login_token = request.cookies.fetch("login_token", "").strip
  user_id = UserToken.validate(login_token)

  # Not a great way to do this
  # Will not scale well, but it works.
  all_courses = Course.dataset
  all_courses.each do |x|
    checked = params.fetch("course_#{x.course_id}", "")

    # check boxes are either "" or "on" and not true/false becasue ??
    next unless checked == "on"

    course = CourseProgress.new
    course.course_id = x.course_id
    course.learner_id = user_id
    course.progress = 100
    course.rating = 0
    course.save_changes
  end

  redirect "/profile"
end

# If the user exists, the route retrieves all the courses that the user has bookmarked and displays in bookmarked_courses
get "/bookmarked-courses" do
  login_token = request.cookies.fetch("login_token", "").strip
  user_id = UserToken.validate(login_token)
  @user = User.where(user_id: user_id).first

  if @user
    @courses = Course.where(course_id: @user.bookmarks.map(&:course_id)).all
    erb :bookmarked_courses
  else
    redirect "/login"
  end
end

# creates a new bookmark for the user and the course specified in :course_id.

post "/bookmarked-courses/:course_id" do
  login_token = request.cookies.fetch("login_token", "").strip
  user_id = UserToken.validate(login_token)
  @user = User.where(user_id: user_id).first
  @course = Course.where(course_id: params[:course_id]).first

  if @user && @course
    bookmark = Bookmark.create(user_id: @user.user_id, course_id: @course.course_id)
    status 200
  else
    status 401
  end
end
