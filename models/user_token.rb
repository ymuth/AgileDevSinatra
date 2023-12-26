# frozen_string_literal: true

require 'securerandom'

THIRTY_DAYS_IN_SECONDS = 30 * 24 * 60 * 60

class UserToken < Sequel::Model
  def self.generate(user)
    @user_token = UserToken.new
    @user_token.token = SecureRandom.hex(32) # Random hex string 32 length
    @user_token.created_at = Time.now.to_i # Unix timestamp
    @user_token.user_id = user.user_id
    @user_token.save_changes

    @user_token.token
  end

  def self.validate(token)
    return false if token == ''

    @token = UserToken.where(token: token).first
    if @token.nil?
      false
    else
      @created_at = Time.new(@token.created_at)
      @now = Time.now

      if (@now - @created_at) < THIRTY_DAYS_IN_SECONDS
        # Token is less than 30 days old
        @token.user_id
      else
        # Token has expired
        @token.delete
        false
      end
    end
  end
end
