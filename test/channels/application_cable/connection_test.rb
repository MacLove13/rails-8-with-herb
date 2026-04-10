require "test_helper"

class ApplicationCable::ConnectionTest < ActionCable::Connection::TestCase
  test "connects with valid session cookie" do
    user = User.take
    session = user.sessions.create!
    cookies.signed[:session_id] = session.id

    connect

    assert_equal user, connection.current_user
  ensure
    session&.destroy
  end

  test "rejects connection without valid session" do
    assert_reject_connection { connect }
  end

  test "rejects connection with invalid session id" do
    cookies.signed[:session_id] = 999_999
    assert_reject_connection { connect }
  end
end
