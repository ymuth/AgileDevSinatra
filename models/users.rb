# frozen_string_literal: true

require 'bcrypt'

class User < Sequel::Model
  one_to_one :profile
  one_to_one :suspended_users
  one_to_many :bookmarks
  many_to_many :bookmarks, left_key: :user_id, right_key: :course_id, join_table: :bookmarks, class: :Course
  include BCrypt

  # Converts password to a hash when we are trying to compare plaintext password
  # with the password stored in the database

  def password_hash
    @password_hash ||= Password.new(password)
  end

  # When we set the password of a model it generates a hash and only stores the
  # Hashed password
  def password_hash=(new_password)
    @password_hash = Password.create(new_password)
    self.password = @password_hash
  end

  def exist?
    user = User.where(username: username).first
    user.nil?
  end

  def suspended?
    ban = SuspendedUser.where(user_id: user_id).first

    if ban.nil?
      false
    else
      now = Time.now.to_i
      ban.expiry > now
    end
  end
end
