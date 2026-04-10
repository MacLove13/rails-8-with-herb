require "test_helper"

class CurrentTest < ActiveSupport::TestCase
  teardown do
    Current.reset
  end

  test "user returns nil when session is nil" do
    Current.session = nil
    assert_nil Current.user
  end

  test "user delegates to session" do
    user = User.take
    session = user.sessions.create!
    Current.session = session
    assert_equal user, Current.user
  ensure
    session&.destroy
  end
end
