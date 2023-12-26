# frozen_string_literal: true

#  Methods  in this model:
#- get progress to dispaly
#- create a new progress record
#- update a progress record

class CourseProgress < Sequel::Model(:course_progress)
  set_dataset :course_progress
  def getProgress(course_id, user_id)
    return false if course_id.nil? # check the id is not nil
    return false if user_id.nil? # check the id is not nil
    return false unless course_id.is_a?(Integer)
    return false unless user_id.is_a?(Integer)

    course_progress = course_progress.where(course_id: course_id, learner_id: user_id)
    case course_progress
    when 0
      'Not started'
    when 50
      'Started'
    else
      'Finished'
    end
  end

  def createProgress(user_id, course_id)
    return false if course_id.nil? # check the id is not nil
    return false if user_id.nil? # check the id is not nil
    return false unless course_id.is_a?(Integer)
    return false unless user_id.is_a?(Integer)

    new_progress = course_progress.new
    new_progress.course_id = course_id
    new_progress.user_id = user_id
    new_progress.progress = 0
    new_progress.rating = 0
    new_progress.save
    true
  end

  def updateProgress(user_id, course_id)
    return false if course_id.nil? # check the id is not nil
    return false if user_id.nil? # check the id is not nil
    return false unless course_id.is_a?(Integer)
    return false unless user_id.is_a?(Integer)

    # check if already started
    current_progress = course_progress.where(course_id: course_id, learner_id: user_id)
    createProgress(user_id, course_id) if current_progress.empty?
    if current_progress < 100
      current_progress += 50
    else
      current_progress = 0
    end

    course_progress = course_progress.find(course_id: course_id, user_id: user_id)
    course_progress.progress = current_progress
    course_progress.save
  end
end
