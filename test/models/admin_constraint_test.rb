require "test_helper"

class AdminConstraintTest < ActiveSupport::TestCase
  setup do
    @constraint = AdminConstraint.new
  end

  test "matches? returns false when no session cookie" do
    request = ActionDispatch::TestRequest.create
    assert_not @constraint.matches?(request)
  end

  test "matches? returns false when session not found" do
    request = ActionDispatch::TestRequest.create
    request.cookie_jar.signed[:session_id] = 999_999
    assert_not @constraint.matches?(request)
  end

  test "matches? returns false when user is not admin" do
    user = User.take
    session = user.sessions.create!
    request = ActionDispatch::TestRequest.create
    request.cookie_jar.signed[:session_id] = session.id
    assert_not @constraint.matches?(request)
  ensure
    session&.destroy
  end

  test "matches? returns true when user is admin" do
    user = User.create!(name: "Admin User", email_address: "admin@example.com", password: "password", is_admin: true)
    session = user.sessions.create!
    request = ActionDispatch::TestRequest.create
    request.cookie_jar.signed[:session_id] = session.id
    assert @constraint.matches?(request)
  ensure
    user&.destroy
  end

  test "matches? returns false when StandardError is raised" do
    constraint = AdminConstraint.new
    request = ActionDispatch::TestRequest.create

    Session.stub(:find_by, ->(_args) { raise StandardError, "DB error" }) do
      request.cookie_jar.signed[:session_id] = 1
      assert_not constraint.matches?(request)
    end
  end
end
