require "test_helper"

class SessionTest < ActiveSupport::TestCase
  setup do
    @user = User.take
  end

  test "belongs to user" do
    session = @user.sessions.create!
    assert_equal @user, session.user
  end

  test "is destroyed when user is destroyed" do
    user = User.create!(name: "Temp User", email_address: "temp@example.com", password: "password")
    user.sessions.create!
    assert_difference "Session.count", -1 do
      user.destroy
    end
  end
end
