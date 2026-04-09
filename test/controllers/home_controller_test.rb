require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  setup { @user = User.take }

  test "index redirects unauthenticated user" do
    get root_path
    assert_redirected_to new_session_path
  end

  test "index is accessible when authenticated" do
    sign_in_as(@user)
    get root_path
    assert_response :success
  end
end
