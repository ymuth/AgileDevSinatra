# frozen_string_literal: true

require_relative '../spec_helper'

RSpec.describe 'Suspending users' do
  it 'suspends a user' do
    id = create_user
    staff_id = create_user_with_permission('manager1', 'manager1', 3)

    suspended_user = SuspendedUser.new
    suspended_user.user_id = id
    suspended_user.suspended_by = staff_id
    suspended_user.expiry = Time.now.to_i + 86_400
    suspended_user.save_changes

    user = User.where(user_id: id).first
    expect(user.suspended?).to be true

    clear_database
  end

  it 'user is not suspended if ban expires' do
    id = create_user
    staff_id = create_user_with_permission('manager1', 'manager1', 3)

    suspended_user = SuspendedUser.new
    suspended_user.user_id = id
    suspended_user.suspended_by = staff_id
    suspended_user.expiry = Time.now.to_i - 86_400
    suspended_user.save_changes

    user = User.where(user_id: id).first
    expect(user.suspended?).to be false

    clear_database
  end
end
