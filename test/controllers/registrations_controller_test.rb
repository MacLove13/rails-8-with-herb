require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "new" do
    get new_registration_path
    assert_response :success
  end

  test "create with valid params" do
    assert_difference("User.count", 1) do
      post registrations_path, params: {
        user: {
          name: "New User",
          email_address: "newuser@example.com",
          password: "password",
          password_confirmation: "password"
        }
      }
    end

    assert_redirected_to root_path
    assert cookies[:session_id]
  end

  test "create with invalid params" do
    assert_no_difference("User.count") do
      post registrations_path, params: {
        user: {
          name: "New User",
          email_address: "newuser@example.com",
          password: "password",
          password_confirmation: "wrong"
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "create with mismatched origin header does not raise InvalidAuthenticityToken" do
    assert_difference("User.count", 1) do
      post registrations_path,
        params: {
          user: {
            name: "Codespace User",
            email_address: "codespace@example.com",
            password: "password",
            password_confirmation: "password"
          }
        },
        headers: { "HTTP_ORIGIN" => "https://localhost:3000" }
    end

    assert_redirected_to root_path
  end
end
