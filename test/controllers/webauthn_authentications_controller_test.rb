require "test_helper"

class WebauthnAuthenticationsControllerTest < ActionDispatch::IntegrationTest
  test "new_authentication_options returns json with challenge" do
    post new_webauthn_authentication_options_path
    assert_response :success
    json = JSON.parse(response.body)
    assert json.key?("challenge")
  end

  test "create returns unauthorized when authentication challenge is missing" do
    # Do NOT call new_authentication_options first, so no challenge is in the session
    mock_credential = Object.new
    WebAuthn::Credential.stub(:from_get, mock_credential) do
      post webauthn_authentication_path, params: {}, as: :json
    end

    assert_response :unauthorized
    json = JSON.parse(response.body)
    assert_match "challenge", json["error"].downcase
  end

  test "create returns unauthorized when credential not found" do
    post new_webauthn_authentication_options_path

    mock_credential = Object.new
    mock_credential.define_singleton_method(:id) { "nonexistent_credential_id" }

    WebAuthn::Credential.stub(:from_get, mock_credential) do
      post webauthn_authentication_path, params: {}, as: :json
    end

    assert_response :unauthorized
    json = JSON.parse(response.body)
    assert_equal "Credential not found", json["error"]
  end

  test "create returns unauthorized when webauthn verification fails" do
    post new_webauthn_authentication_options_path

    user = User.take
    credential = user.webauthn_credentials.create!(
      external_id: "auth_test_external_id",
      public_key: "test_public_key",
      sign_count: 0
    )

    mock_cred = Object.new
    mock_cred.define_singleton_method(:id) { credential.external_id }
    mock_cred.define_singleton_method(:sign_count) { 1 }
    mock_cred.define_singleton_method(:verify) { |*_args| raise WebAuthn::Error, "Verification failed" }

    WebAuthn::Credential.stub(:from_get, mock_cred) do
      post webauthn_authentication_path, params: {}, as: :json
    end

    assert_response :unauthorized
  ensure
    credential&.destroy
  end

  test "create returns ok and redirects when verification succeeds" do
    post new_webauthn_authentication_options_path

    user = User.take
    credential = user.webauthn_credentials.create!(
      external_id: "auth_success_external_id",
      public_key: "test_public_key",
      sign_count: 0
    )

    mock_cred = Object.new
    mock_cred.define_singleton_method(:id) { credential.external_id }
    mock_cred.define_singleton_method(:sign_count) { 1 }
    mock_cred.define_singleton_method(:verify) { |*_args| true }

    WebAuthn::Credential.stub(:from_get, mock_cred) do
      post webauthn_authentication_path, params: {}, as: :json
    end

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal "ok", json["status"]
    assert cookies[:session_id], "Session cookie should be set after successful authentication"
  ensure
    credential&.destroy
  end
end
