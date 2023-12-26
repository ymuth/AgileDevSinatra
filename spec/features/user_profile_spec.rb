# frozen_string_literal: true

require_relative '../spec_helper'

RSpec.describe 'User Profile' do
  before :example do
    clear_database
    @id = create_user
    login_user('test', 'password123')
    visit '/profile'
  end

  it 'updates personal information' do
    visit '/profile'

    fill_in 'first_name', with: 'Alice'
    fill_in 'last_name', with: 'Smith'
    click_button 'Update Personal Information'

    user = User.where(user_id: @id).first
    expect(user.profile.name).to eq 'Alice Smith'
  end

  it 'does not update personal information when field is blank' do
    visit '/profile'

    fill_in 'first_name', with: 'Bob'
    fill_in 'last_name', with: ''
    click_button 'Update Personal Information'

    user = User.where(user_id: @id).first
    expect(user.profile.name).to eq 'Test Account'
  end

  it 'updates academic information' do
    visit '/profile'
    fill_in 'year', with: 2
    click_button 'Update Academic Information'

    user = User.where(user_id: @id).first
    expect(user.profile.level).to eq 'GCSE'
    expect(user.profile.year).to eq 2
  end

  it 'does not update academic information when field is blank' do
    visit '/profile'
    click_button 'Update Academic Information'

    user = User.where(user_id: @id).first
    expect(user.profile.year).to eq 0
  end

  it 'does not allow change password when fields are blank' do
    visit '/profile'

    fill_in 'currrent_password', with: ''
    fill_in 'current_password_confirm', with: ''
    fill_in 'new_password', with: 'password1234'

    user = User.where(user_id: @id).first
    expect(user.password_hash == 'password1234').to be false

    click_button 'Update Password'
  end

  it 'does not allow change password when fields do not match' do
    visit '/profile'

    fill_in 'currrent_password', with: 'password123'
    fill_in 'current_password_confirm', with: 'password321'
    fill_in 'new_password', with: 'password1234'

    user = User.where(user_id: @id).first
    expect(user.password_hash == 'password1234').to be false

    click_button 'Update Password'
  end

  it 'does not allow change password when password is incorrect' do
    visit '/profile'

    fill_in 'currrent_password', with: 'password321'
    fill_in 'current_password_confirm', with: 'password321'
    fill_in 'new_password', with: 'password1234'

    user = User.where(user_id: @id).first
    expect(user.password_hash == 'password1234').to be false

    click_button 'Update Password'
  end

  it 'does not allow change password when password is not strong enough' do
    visit '/profile'

    fill_in 'currrent_password', with: '123'
    fill_in 'current_password_confirm', with: '123'
    fill_in 'new_password', with: 'password1234'

    user = User.where(user_id: @id).first
    expect(user.password_hash == 'password1234').to be false

    click_button 'Update Password'
  end

  it 'allows user to change their password' do
    visit '/profile'

    fill_in 'currrent_password', with: 'password123'
    fill_in 'current_password_confirm', with: 'password123'
    fill_in 'new_password', with: 'password1234'

    click_button 'Update Password'

    user = User.where(user_id: @id).first
    expect(user.password_hash == 'password1234').to be true
  end

  it 'does not allow courses to be suggested with blank fields' do
    visit '/profile'

    fill_in 'title', with: ''
    fill_in 'description', with: ''
    fill_in 'subject', with: ''
    fill_in 'provider', with: ''
    fill_in 'difficulty', with: ''
    fill_in 'link', with: ''
    fill_in 'image', with: ''

    click_button 'Submit Course'

    expect(Db[:course_approval_queue].all.empty?).to be true
  end

  it 'allows courses to be suggested' do
    visit '/profile'

    fill_in 'title', with: 'Some'
    fill_in 'description', with: 'Course'
    fill_in 'subject', with: 'About'
    fill_in 'provider', with: 'Bob'
    fill_in 'difficulty', with: 0
    fill_in 'link', with: 'and'
    fill_in 'image', with: 'Alice'

    click_button 'Submit Course'

    expect(Db[:course_approval_queue].all.empty?).to be false
  end

  it 'allows user to add interest' do
    visit '/profile'

    fill_in 'interest', with: 'AI'
    click_button 'Add Interest'

    user = User.where(user_id: @id).first
    expect(user.profile.interests_list).to include 'AI'
  end

  it 'allows user to remove an interest' do
    visit '/profile'

    fill_in 'interest', with: 'Cryptography'
    click_button 'Add Interest'

    user = User.where(user_id: @id).first
    user.profile.removeInterest('Cryptography')
    expect(user.profile.interests_list).to_not include 'Cryptography'

    clear_database
  end
end
