require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "new renders registration form" do
    get register_path
    assert_response :success
  end

  test "create with valid params creates user and redirects" do
    assert_difference "User.count", 1 do
      post register_path, params: {
        user: {
          name: "New User",
          email_address: "newuser@example.com",
          password: "password",
          password_confirmation: "password"
        }
      }
    end
    assert_redirected_to root_path
  ensure
    User.find_by(email_address: "newuser@example.com")&.destroy
  end

  test "create with invalid params re-renders new form" do
    assert_no_difference "User.count" do
      post register_path, params: {
        user: {
          name: "",
          email_address: "",
          password: "password",
          password_confirmation: "password"
        }
      }
    end
    assert_response :unprocessable_entity
  end

end
