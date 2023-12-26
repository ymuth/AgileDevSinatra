PASSWORD_REGEX = /^(?=.*)(?=.*\d).{8,}/.freeze

get '/forgotten_password' do
  erb :forgotten_password
end

get "/request-reset-password" do
  email = params.fetch("email", "")
  @user = User.where(email: email).first

  @found = !@user.nil?

  erb :reset_password
end

post "/reset-password" do
  new_password = params.fetch("new_password", "")
  new_password_confirm = params.fetch("new_password_confirm", "")
  email = params.fetch("email", "")
  @user = User.where(email: email).first

  @found = !@user.nil?

  # Validate new password and update database
  if new_password != new_password_confirm
    @error = "Passwords do not match"
    return erb :reset_password
  end

  unless PASSWORD_REGEX.match(new_password)
    @error = "New password must be at least 8 characters and contain numbers"
    return erb :reset_password
  end

  @user.password_hash = new_password
  @user.save_changes

  erb :reset_password
end
