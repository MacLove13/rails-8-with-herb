require "test_helper"

class ProfileControllerTest < ActionDispatch::IntegrationTest
  setup { @user = User.take }

  test "show redirects unauthenticated user" do
    get profile_path
    assert_redirected_to new_session_path
  end

  test "show is accessible when authenticated" do
    sign_in_as(@user)
    get profile_path
    assert_response :success
  end
end
