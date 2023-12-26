# frozen_string_literal: true
# require_relative 'spec_helper'
# RSpec.describe CourseProgress do
# after(:each, teardown: true) do
# Db[:course_progress].where(course_id: 1, learner_id: 1).delete
# end

# def create_test_progress
# test_progress = course_progress.new
# test_progress.course_id = 1
# test_progress.learner_id = 1
# test_progress.progress = 50
# test_progress.rating = 3
# test_progress.save_changes
# end

# describe '#get_progress' do
# it "returns the user's progress on a given course" do
# create_test_progress
# expect(CourseProgress.get_progress(1, 1)).to eq('Started')
# end
# end

# describe '#create_progress' do
# it 'makes a new record in the table', teardown: true do
# expect(CourseProgress.create_progress(1, 1)).to eq(true)
# end
# end

# describe '#update_progress' do
# it 'updates an existing record', teardown: true do
# Db[:course_progress].insert(course_id: 1, learner_id: 1, progress: 0, rating: 5)

# Call the method that updates the record
# updateProgress(1, 1)

# Retrieve the updated record from the database
# result = DB[:course_progress].where(course_id: 1, learner_id: 1).first

# Assert that the record has been updated correctly

# expect(result[:progress]).to eq(50)
# end
# end
# end
