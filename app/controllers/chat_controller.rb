require 'reloader/sse'

class ChatController < ApplicationController
  include ActionController::Live

  def index
    @message = Message.new
  end

  def stream
    response.headers['Content-Type'] = 'text/event-stream'
    sse = Reloader::SSE.new response.stream

    worker = Resque::Worker.new '*'

    begin
      loop do
        if job = worker.reserve
          klass = Resque::Job.constantize(job.payload['class'])
          message = klass.perform(*job.payload['args'])
          sse.write({ message: message.body }, event: 'message')
        else
          sleep 5 # Polling frequency = 5
        end
      end
    rescue IOError
      # When the client disconnects, we'll get an IOError on write
    ensure
      sse.close
    end
  end
end
