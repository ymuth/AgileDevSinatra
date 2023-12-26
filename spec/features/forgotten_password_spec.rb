# frozen_string_literal: true

RSpec.describe 'GET /request-reset-password' do
  let!(:user) { User.create(email: 'test@example.com') }

  describe 'GET/ forgotten_password' do
    it 'has status code of 200 (OK)' do
      get '/forgotten_password'
      expect(last_response.status).to eq(200)
    end
  end

  before do
    allow_any_instance_of(Sinatra::Application).to receive(:erb)
  end

  it 'fetches user by email and renders the reset_password template' do
    expect(User).to receive(:where).with(email: 'test@example.com').and_return([user])
    expect_any_instance_of(Sinatra::Application).to receive(:erb).with(:reset_password)
    get '/request-reset-password', email: 'test@example.com'
  end
end
