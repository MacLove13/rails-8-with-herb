require "test_helper"

class ApplicationControllerTest < ActiveSupport::TestCase
  setup do
    @user = User.take
    @admin = User.create!(name: "Admin User", email_address: "admin_app@example.com", password: "password", is_admin: true)
    @controller = ApplicationController.new
  end

  teardown do
    Current.reset
    @admin.destroy
  end

  test "find_current_auditor returns current user when user is admin" do
    Current.session = @admin.sessions.create!
    assert_equal @admin, @controller.send(:find_current_auditor)
  ensure
    Current.session&.destroy
  end

  test "find_current_auditor returns nil when user is not admin" do
    Current.session = @user.sessions.create!
    assert_nil @controller.send(:find_current_auditor)
  ensure
    Current.session&.destroy
  end

  test "find_current_auditor returns nil when no user is authenticated" do
    assert_nil @controller.send(:find_current_auditor)
  end
end
