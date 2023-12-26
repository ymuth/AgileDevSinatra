# frozen_string_literal: true

class SuspendedUser < Sequel::Model
  one_to_one :user, key: :user_id

  def expiry_date
    time = Time.at(expiry)
    time.strftime('%d/%m/%Y')
  end
end
