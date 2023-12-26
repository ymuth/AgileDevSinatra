include ERB::Util

get "/messages" do
  signed_in = session[:logged_in]
  redirect "/login" unless signed_in

  # error handling in case the user's data is not found in the database or if there is an error fetching the messages.
  begin
    # get log in data so you can acces the users permission_level and id
    login_token = request.cookies.fetch("login_token", "").strip
    id = UserToken.validate(login_token) # Get the user account ID from the login token cookie
    user = User.where(user_id: id).first # Fetch the user from the database

    # uses the data to choose the limits of what the user can access
    # if the permission_level is above learner show all messages
    # else shows the messages the user has sent or threads they are involved in.
    # also checks for and applys filters and sorts

    if params[:search] && params[:column] && params[:search] != ""
      column = params[:column].to_sym
      term = params[:search]
      @messages = Message.getMessages(user.user_id, user.permission_level, column, term, nil)
    else
      @messages = Message.getMessages(user.user_id, user.permission_level, nil, nil, nil)
    end

    if params[:sort]
      column = params[:sort]
      @messages = Message.getMessages(user.user_id, user.permission_level, nil, nil, column)
    end

    erb :messages
  rescue StandardError => e
    puts "An error occurred: #{e.message}"
    redirect '/login'
  end
end

post "/messages/new" do
  signed_in = session[:logged_in]
  redirect "/login" unless signed_in

  begin
    # Get the user ID from the login token cookie
    # get log in data so you can access the users id
    login_token = request.cookies.fetch("login_token", "").strip
    id = UserToken.validate(login_token)
    user = User.where(user_id: id).first

    # Get the message body from the form submission, escaping the untrusted varaibles.
    message_body = h params["message_body"]
    thread_id = h params["thread_id"]
    message_summary = h params["message_summary"]
    thread_id = nil if thread_id == ""

    # create a message_id and check if its used (must be unique)
    message_id = (user.user_id.to_s + rand(1..99_999).to_s).to_i
    message_id = (user.user_id.to_s + rand(1..99_999).to_s).to_i until Message.isMessageIdFree(message_id)

    # Create the new message in the database
    Message.createNewMessage(message_id, thread_id, message_body, message_summary, user.user_id)

    # Redirect the user back to the messages page
    redirect "/messages"
  rescue StandardError => e
    puts "An error occurred: #{e.message}"
  end
end
