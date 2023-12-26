get "/" do
  login_token = request.cookies.fetch("login_token", "").strip
  user_id = UserToken.validate(login_token)
  if user_id
    session[:logged_in] = true
  else
    erb :login
  end

  @user = User.where(user_id: user_id).first
  if session[:logged_in] && @user.suspended?
    status 403
    redirect "/suspended"
  end

  sort = params.fetch("sort", "recommended")
  if sort == "recommended" && session[:logged_in]
    course_level = @user.profile.course_level
    interests = @user.profile.interests_list

    @courses = if course_level.zero? && interests.length.zero?
                 # If the user hasn't specified their interests or level
                 # we just return everything since we've nothing to go off of
                 Course.dataset
               elsif course_level.zero? && interests.length.positive?
                 # If user has no level but does have interests we use those
                 Course.where(Sequel.function(:upper, :subject) => interests.map(&:upcase))
               elsif course_level.positive? && interests.length.zero?
                 # If the user has specified their level
                 # but not interests we just use interests
                 Course.where(difficulty: course_level)
               else
                 # Trending courses where difficulty matches and
                 # user has the subject in their interests
                 Course.where(difficulty: course_level, archived: false,
                              Sequel.function(:upper, :subject) => interests.map(&:upcase))
               end
  elsif sort == "recent"
    @courses = Course.where(archived: false).order(Sequel.desc(:course_id))
  elsif sort == "popular"
    @courses = Course.where(archived: false).order(Sequel.desc(:rating))
  elsif sort == "trending"
    # Grab the IDs for the most subscribed recent courses
    trending = Db.fetch("SELECT course_id, count(course_id) FROM course_progress
      GROUP by course_id ORDER by count(course_id) DESC LIMIT 10")

    # Get the course model for each corresponding course ID
    @courses = []
    trending.each do |x|
      course = Course.where(course_id: x[:course_id]).first
      @courses << course if course
    end
  else
    @courses = Course.where(archived: false)
  end

  @signed_in = session[:logged_in]
  erb :index
end

get "/suspended" do
  login_token = request.cookies.fetch("login_token", "").strip
  user_id = UserToken.validate(login_token)
  @user = User.where(user_id: user_id).first
  @baninfo = SuspendedUser.where(user_id: user_id).first

  erb :suspended
end
