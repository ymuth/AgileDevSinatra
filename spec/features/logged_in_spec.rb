# frozen_string_literal: true

require_relative '../spec_helper'
require 'bcrypt'

RSpec.describe 'Logged in user features' do
  context 'when user is logged in' do
    before(:example) do
      create_user
      login_user('test', 'password123')
    end

    describe 'GET/ login' do
      it 'has status code of 200 (OK)' do
        get '/login'
        expect(last_response.status).to eq(200)
      end
    end

    it 'displays the Log Out link' do
      visit '/'
      expect(page).to have_button('Log Out')
    end

    it 'displays the Profile link' do
      visit '/'
      expect(page).to have_css('.profile-icon')
    end

    after(:example) do
      clear_database
    end
  end

  context 'when user is not logged in' do
    it 'does not display the Log Out link' do
      visit '/'
      expect(page).not_to have_button('Log Out')
    end

    it 'does not display the Profile link' do
      visit '/'
      expect(page).not_to have_css('.profile-icon')
    end
  end
end
