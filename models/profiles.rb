# frozen_string_literal: true

require 'json'

class Profile < Sequel::Model
  one_to_one :profile

  # concatenate first and last name

  def name
    "#{first_name} #{last_name}"
  end

  def level
    case course_level
    when 1
      'GCSE'
    when 2
      'A Level'
    when 3
      'Undergraduate'
    when 4
      'Post Graduate'
    else
      'Unknown Level'
    end
  end

  # returns a parsed array of interests from the interests field of the profile, which is stored as a JSON-encoded string in the database.

  def interests_list
    @interests_list ||= JSON.parse(interests)
  end

  # adds to interests_list array, updates the interests field with the new array, and saves the changes to the database.

  def addInterest(interest)
    interests_ = JSON.parse(interests)
    interests_ << interest
    self.interests = interests_.to_json

    save_changes
  end

  # same method as adding

  def removeInterest(interest)
    interests_ = JSON.parse(interests)
    interests_.delete(interest)

    self.interests = interests_.to_json
    save_changes
  end
end
