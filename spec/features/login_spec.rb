# frozen_string_literal: true

require_relative '../spec_helper'

require 'bcrypt'

RSpec.describe 'Login Page' do
  it 'does not allow a user to submit a blank login' do
    visit '/login'
    fill_in 'username', with: ''
    fill_in 'password', with: ''
    click_button 'Login'

    expect(page).to have_content 'Enter a username and password'
  end

  it 'does not allow a user to submit a username with an incorrect password' do
    visit '/login'
    fill_in 'username', with: 'user'
    fill_in 'password', with: 'abcd123'
    click_button 'Login'
    expect(page).to have_content 'Incorrect username or password'
  end

  before(:example) do
    create_user
  end

  it 'logs in a user with correct username and password' do
    visit '/login'
    fill_in 'username', with: 'test'
    fill_in 'password', with: 'password123'
    click_button 'Login'

    expect(page).to have_content 'Log Out'

    clear_database
  end

  it "should toggle password visibility when the 'Show password' checkbox is clicked" do
    visit '/login'
    expect(page).to have_css("input[type='password']", visible: false)
    check 'show_password'
    expect(page).to have_css("input[type='password']", visible: true)
    uncheck 'show_password'
    expect(page).to have_css("input[type='password']", visible: false)
  end
end
