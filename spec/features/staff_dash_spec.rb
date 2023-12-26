# frozen_string_literal: true

require_relative '../spec_helper'

RSpec.describe 'Manager panel' do
  before :example do
    create_user
    create_user_with_permission('manager', 'password123', 3)
    login_user('manager', 'password123')
    visit '/profile'
  end

  it 'shows users table' do
    visit '/profile'
    expect(page).to have_selector '#users-table'
  end

  it 'users table has suspend action' do
    visit '/profile'
    expect(page).to have_selector '#suspend'
  end

  it 'shows courses' do
    visit '/profile'
    expect(page).to have_text('Courses')
    clear_database
  end
end

RSpec.describe 'Admin panel' do
  before :example do
    create_user
    create_user_with_permission('admin', 'password123', 1)
    login_user('admin', 'password123')
    visit '/profile'
  end

  it 'shows users table' do
    visit '/profile'
    expect(page).to have_selector '#users-table'
  end

  it 'users table has suspend action' do
    visit '/profile'
    expect(page).to have_selector '#suspend'
    clear_database
  end
end

RSpec.describe 'Moderator panel' do
  before :example do
    create_user
    create_user_with_permission('moderator', 'password123', 2)
    login_user('moderator', 'password123')
    visit '/profile'
  end

  it 'has course table' do
    visit '/profile'
    expect(page).to have_selector '.course-table'
  end

  it 'has course input form' do
    visit '/profile'
    expect(page).to have_selector '.submit-course-form'
    clear_database
  end

  it 'has a course input form for moderators' do
    visit '/profile'
    expect(page).to have_selector('.submit-course-form')

    fill_in 'title', with: 'New Course Title'
    fill_in 'description', with: 'New Course Description'
    fill_in 'subject', with: 'New Course Subject'
    fill_in 'provider', with: 'New Course Provider'
    fill_in 'difficulty', with: 1
    fill_in 'link', with: 'http://newcourse.com'
    fill_in 'image', with: 'http://newcourse.com/image.jpg'
    click_button 'Submit Course'

    expect(page).to have_current_path('/profile')
    expect(page).to have_content('New Course Title')
    expect(page).to have_content('New Course Description')
    expect(page).to have_content('New Course Subject')
    expect(page).to have_content('New Course Provider')
    expect(page).to have_content('1')
    expect(page).to have_content('http://newcourse.com')
    expect(page).to have_content('http://newcourse.com/image.jpg')
  end
end
