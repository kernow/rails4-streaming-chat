class Message < ActiveRecord::Base
  attr_accessible :body

  after_create :queue

  private

    def queue
      Resque.enqueue MessageWorker, self.id
    end
end
