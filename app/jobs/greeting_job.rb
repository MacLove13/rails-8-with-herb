class GreetingJob < ApplicationJob
  queue_as :default

  def perform(name = "World")
    Rails.logger.info "Hello, #{name}! Processed by Solid Queue."
  end
end
