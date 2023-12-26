# frozen_string_literal: true

require_relative '../spec_helper'

RSpec.describe UserToken do
  before(:example) do
    create_user
  end

  it 'generates a token when a user signs in' do
    visit '/login'
    fill_in 'username', with: 'test'
    fill_in 'password', with: 'password123'
    click_button 'Login'

    data = Db.fetch("SELECT token FROM users u JOIN
            user_tokens t ON u.user_id = t.user_id WHERE u.username = 'test'")

    expect(data).to_not be_nil

    clear_database
  end
end

describe '.validate' do
  context 'when the token is valid' do
    let(:user) { User.create(username: 'test', password: 'password123') }
    let(:token) { UserToken.generate(user) }

    it 'returns the user ID' do
      user_id = UserToken.validate(token)
      expect(user_id).to eq(user.user_id)
    end
  end

  context 'when the token is invalid' do
    it 'returns false' do
      user_id = UserToken.validate('invalid_token')
      expect(user_id).to be_falsey
    end
  end
end
