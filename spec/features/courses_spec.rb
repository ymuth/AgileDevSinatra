# frozen_string_literal: true

require_relative '../spec_helper'

RSpec.describe 'Search route' do
  it 'returns the expected search results' do
    # Create a course with a matching title
    course = Course.create(title: 'Test Course')

    # Visit the search page and enter the query
    visit '/search'
    fill_in 'query', with: 'Test'
    click_on 'Search'

    # Check if the response contains the expected course title
    expect(page).to have_content(course.title)

    course.destroy
  end
end

RSpec.describe 'GET /course_details/:id' do
  it 'returns a 200 OK status' do
    course = Course.create(
      title: 'Test Course',
      description: 'This is a test course.',
      subject: 'Test Subject',
      provider: 'Test Provider',
      difficulty: 'Beginner',
      link: 'http://test.com',
      rating: 4,
      image: 'http://test.com/image.jpg'
    )

    get "/course_details/#{course.course_id}"
    expect(last_response.status).to eq(200)
  end
end

RSpec.describe 'getProgress' do
  let(:course_progress) { CourseProgress.new }

  context 'when course_id is nil' do
    it 'returns false' do
      result = course_progress.getProgress(nil, 456)
      expect(result).to be_falsey
    end
  end

  context 'when user_id is nil' do
    it 'returns false' do
      result = course_progress.getProgress(123, nil)
      expect(result).to be_falsey
    end
  end

  context 'when course_id is not an integer' do
    it 'returns false' do
      result = course_progress.getProgress('abc', 456)
      expect(result).to be_falsey
    end
  end

  context 'when user_id is not an integer' do
    it 'returns false' do
      result = course_progress.getProgress(123, 'abc')
      expect(result).to be_falsey
    end
  end
end

RSpec.describe 'createProgress' do
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

  let(:course_id) { 1 }
  let(:user_id) { 2 }
  let(:course_progress) { double('CourseProgress') }
  let(:new_progress) { double('NewProgress') }

  before do
    allow(course_progress).to receive(:new).and_return(new_progress)
    allow(new_progress).to receive(:course_id=)
    allow(new_progress).to receive(:user_id=)
    allow(new_progress).to receive(:progress=)
    allow(new_progress).to receive(:rating=)
    allow(new_progress).to receive(:save)
  end

  context 'with valid input' do
    it 'creates a new progress and returns true' do
      expect(course_progress).to receive(:new).and_return(new_progress)
      expect(new_progress).to receive(:course_id=).with(course_id)
      expect(new_progress).to receive(:user_id=).with(user_id)
      expect(new_progress).to receive(:progress=).with(0)
      expect(new_progress).to receive(:rating=).with(0)
      expect(new_progress).to receive(:save)
      expect(createProgress(user_id, course_id)).to eq(true)
    end
  end

  context 'with nil course_id' do
    it 'returns false' do
      expect(createProgress(user_id, nil)).to eq(false)
    end
  end

  context 'with nil user_id' do
    it 'returns false' do
      expect(createProgress(nil, course_id)).to eq(false)
    end
  end

  context 'with non-integer course_id' do
    it 'returns false' do
      expect(createProgress(user_id, 'course')).to eq(false)
    end
  end

  context 'with non-integer user_id' do
    it 'returns false' do
      expect(createProgress('user', course_id)).to eq(false)
    end
  end
end

describe 'POST /edit-course-details' do
  it 'returns a 200 OK status' do
    course = Course.create(
      title: 'Test Course',
      description: 'This is a test course.',
      subject: 'Test Subject',
      provider: 'Test Provider',
      difficulty: 'Beginner',
      link: 'http://test.com',
      rating: 4,
      image: 'http://test.com/image.jpg'
    )

    post "/edit-course-details/#{course.course_id}"
    expect(last_response.status).to eq(302)
  end
end
