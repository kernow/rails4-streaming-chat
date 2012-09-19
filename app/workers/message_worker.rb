class MessageWorker
  @queue = :messages_queue

  def self.perform(message_id)
    Message.find message_id
  end
end
