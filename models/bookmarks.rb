# frozen_string_literal: true

class Bookmark < Sequel::Model
  set_dataset :bookmarks
  many_to_one :user
  many_to_one :course, key: :course_id
end
