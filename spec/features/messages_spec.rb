# frozen_string_literal: true

require_relative '../spec_helper'
require 'bcrypt'

RSpec.describe do
  describe '#messages model' do
    clear_database
    testid = create_user_2

    Message.createNewMessage(1, 1, 'test message 1', 'test summary 1', testid)
    Message.createNewMessage(2, nil, 'test message 2', 'test summary 2', testid)
    Message.createNewMessage(3, nil, 'test message 3', '_test summary 3', testid)

    result = Message.getMessages(testid, 0, nil, nil, nil)
    result2 = Message.getMessages(testid, 0, 'message_body', 'test message 2', nil)
    result3 = Message.getMessages(testid, 3, nil, nil, 'message_summary')

    free = Message.isMessageIdFree(4)
    not_free = Message.isMessageIdFree(3)

    # sending message/report WITH thread id
    context " when #createNewMessage given inputs: 1, 1, 'test message 1', 'test summary 1', user_id " do
      it 'creates a corresponding record in the messages database' do
        expect(result[0][:message_id]).to eq(1)
        expect(result[0][:thread_id]).to eq(1)
        expect(result[0][:message_body]).to eq('test message 1')
        expect(result[0][:message_summary]).to eq('test summary 1')
        expect(result[0][:sender_id]).to eq(testid)
        expect(result[0][:timestamp]).to be <= Time.new.strftime('%Y-%m-%d %H:%M:%S')
      end
    end

    # sending message/report WITHOUT thread id
    context " when #createNewMessage given inputs: 1, nil, 'test message 3', 'test summary 3', user_id " do
      it 'creates a corresponding record in the messages database' do
        expect(result[2][:message_id]).to eq(3)
        expect(result[2][:thread_id]).to eq(3)
        expect(result[2][:message_body]).to eq('test message 3')
        expect(result[2][:message_summary]).to eq('_test summary 3')
        expect(result[2][:sender_id]).to eq(testid)
        expect(result[2][:timestamp]).to be <= Time.new.strftime('%Y-%m-%d %H:%M:%S')
      end
    end

    # get first messages when filter is given
    context " when #getMessages is given inputs: user_id, 0, message_body, 'test message 2', nil " do
      it 'returns filtered messages if user matches sender_id or permision level is higher than user' do
        expect(result2[0][:message_body]).to eq('test message 2')
        expect(result2[0][:sender_id]).to eq(testid)
        expect(result2[0][:message_id]).to eq(2)
        expect(result2[0][:thread_id]).to eq(2)
      end
    end

    # get first messages when sort by summary is done
    context " when #getMessages is given inputs: user_id, 3, nil, nil, 'message_summary' " do
      it 'returns sorted messages if user matches sender_id or permision level is higher than user' do
        expect(result3[0][:message_body]).to eq('test message 3')
        expect(result3[0][:sender_id]).to eq(testid)
        expect(result3[0][:message_id]).to eq(3)
        expect(result3[0][:thread_id]).to eq(3)
      end
    end

    # checks for free message_id: FREE
    context ' when #isMessageIdFree is given inputs: 4' do
      it 'returns True as message id is free' do
        result = Message.isMessageIdFree(4)
        expect(free).to eq(true)
      end
    end

    # checks for free message_id: NOT FREE
    context ' when #isMessageIdFree is given inputs: 3' do
      it 'returns False as message id is taken' do
        expect(not_free).to eq(false)
      end
    end
  end

  describe 'MessagesController' do
    context 'when not logged in' do
      it 'redirects to /login' do
        get '/messages'
        expect(last_response).to be_redirect
        follow_redirect!
        expect(last_request.path).to eq('/login')
      end
    end

    context 'when user is logged in' do
      before(:example) do
        create_user
        login_user('test', 'password123')
      end

      it 'displays the Message link' do
        visit '/messages'
        expect(page).to have_button('Messages')
      end

      it 'displays the checks for form css' do
        visit '/messages'
        expect(page).to have_css('.form')
      end

      after(:example) do
        clear_database
      end
    end

    context 'POST /messages/new' do
      it 'redirects to login if not logged in' do
        post '/messages/new'
        expect(last_response).to be_redirect
        follow_redirect!
        expect(last_request.url).to eq('http://example.org/login')
      end
    end
  end
end
