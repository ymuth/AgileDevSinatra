# frozen_string_literal: true

# define a message model

class Message < Sequel::Model(:messages)
  plugin :timestamps, update_on_create: true

  # add message to database with the necessary data
  def self.createNewMessage(message_id, thread_id, message_body, message_summary, user_id)
    # create a message and save to database
    message = Message.new
    message.message_id = message_id

    message.thread_id = if thread_id.nil? # if this is the original message, set the thread id to the message id
                          message_id
                        else # if a thread id is supplied, set it as the thread id
                          thread_id
                        end

    message.message_body = message_body
    message.message_summary = message_summary
    message.sender_id = user_id
    message.timestamp = Time.new.strftime('%Y-%m-%d %H:%M:%S') # current time in (YR-MNTH-DAY HR-MIN-SC) format
    message.save
  end

  def self.getMessages(user_id, permission_level, filter_column, filter_term, sort_column)
    # get a list/hash of messages depending on the user, also filters and sorts.
    if permission_level >= 1 && permission_level <= 4
      data = Message.db[:messages]
    else
      data = Message.db[:messages].where(Sequel.lit('sender_id = ? OR thread_id IN ?', user_id,
                                                    Message.db[:messages].where(sender_id: user_id).select(:message_id)))
    end

    unless filter_column.nil? || filter_term.nil? # if a filter is being used then apply the filter
      data = data.where(Sequel.lit("#{filter_column} LIKE ?", "%#{filter_term}%"))
    end

    unless sort_column.nil? # if a sort is being used then sort by ascending
      data = data.order(Sequel.asc(:"#{sort_column}"))
    end

    data.all
  end

  def self.isMessageIdFree(messageID)
    # checks if the message_id presented is in use, and returns a value
    Message.db[:messages].where(message_id: messageID).count <= 0
  end
end
