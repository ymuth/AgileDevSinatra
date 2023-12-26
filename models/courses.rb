# frozen_string_literal: true

# add
# rate

class Course < Sequel::Model
  one_to_many :bookmarks

  def course
    self
  end

  def longTitle
    "#{title} by #{provider}"
  end

  def level
    case difficulty
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

  def getRating
    course_progress = CourseProgress.where(course_id: course_id)
    course_average = course_progress.avg(:rating)

    # Calculates the course average, if this is not what we already know
    # then update the current record
    if course_average != rating
      return course_average
      rating = course_average
    else
      rating
    end
  end
end
