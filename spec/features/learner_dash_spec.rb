# frozen_string_literal: true

RSpec.describe 'GET /profile' do
  context 'when logged in' do
    before do
      create_user
      login_user('test', 'password123')
    end

    it 'redirects to "/suspended" when suspended' do
      allow_any_instance_of(User).to receive(:suspended?).and_return(true)
      visit '/profile'
      expect(page).to have_current_path('/suspended')
    end
  end
end

context 'when not logged in' do
  it 'redirects to "/login"' do
    get '/profile'
    expect(last_response).to be_redirect
    follow_redirect!
    expect(last_request.path).to eq('/login')
  end
end
