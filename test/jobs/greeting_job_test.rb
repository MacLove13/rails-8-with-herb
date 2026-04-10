require "test_helper"

class GreetingJobTest < ActiveJob::TestCase
  test "perform logs greeting with custom name" do
    output = capture_logs { GreetingJob.perform_now("Alice") }
    assert_match "Hello, Alice!", output
  end

  test "perform logs greeting with default name" do
    output = capture_logs { GreetingJob.perform_now }
    assert_match "Hello, World!", output
  end

  private

  def capture_logs
    io = StringIO.new
    old_logger = Rails.logger
    Rails.logger = Logger.new(io)
    yield
    io.string
  ensure
    Rails.logger = old_logger
  end
end
