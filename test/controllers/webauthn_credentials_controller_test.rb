require "test_helper"

class WebauthnCredentialsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.take
    sign_in_as(@user)
  end

  test "index lists user webauthn credentials" do
    get webauthn_credentials_path
    assert_response :success
  end

  test "index redirects unauthenticated user" do
    sign_out
    get webauthn_credentials_path
    assert_redirected_to new_session_path
  end

  test "new_registration_options returns json with challenge" do
    post new_registration_options_webauthn_credentials_path
    assert_response :success
    json = JSON.parse(response.body)
    assert json.key?("challenge")
  end

  test "create registers credential when verification succeeds" do
    post new_registration_options_webauthn_credentials_path

    mock_cred = Object.new
    mock_cred.define_singleton_method(:verify) { |*_args| true }
    mock_cred.define_singleton_method(:id) { "new_passkey_id" }
    mock_cred.define_singleton_method(:public_key) { "new_public_key" }
    mock_cred.define_singleton_method(:sign_count) { 0 }

    assert_difference "@user.webauthn_credentials.count", 1 do
      WebAuthn::Credential.stub(:from_create, mock_cred) do
        post webauthn_credentials_path, params: { nickname: "My Passkey" }, as: :json
      end
    end

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal "ok", json["status"]
  ensure
    @user.webauthn_credentials.where(external_id: "new_passkey_id").destroy_all
  end

  test "create returns unprocessable_entity when registration challenge is missing" do
    # Do NOT call new_registration_options first, so no challenge is in the session
    mock_cred = Object.new
    WebAuthn::Credential.stub(:from_create, mock_cred) do
      post webauthn_credentials_path, params: { nickname: "My Passkey" }, as: :json
    end

    assert_response :unprocessable_entity
    json = JSON.parse(response.body)
    assert_match "challenge", json["error"].downcase
  end

  test "create returns unprocessable_entity when webauthn verification fails" do
    post new_registration_options_webauthn_credentials_path

    mock_cred = Object.new
    mock_cred.define_singleton_method(:verify) { |*_args| raise WebAuthn::Error, "Verification failed" }

    WebAuthn::Credential.stub(:from_create, mock_cred) do
      post webauthn_credentials_path, params: { nickname: "My Passkey" }, as: :json
    end

    assert_response :unprocessable_entity
  end

  test "destroy removes a webauthn credential" do
    credential = @user.webauthn_credentials.create!(
      external_id: "destroyable_credential",
      public_key: "test_public_key",
      sign_count: 0
    )

    assert_difference "@user.webauthn_credentials.count", -1 do
      delete webauthn_credential_path(credential)
    end

    assert_redirected_to profile_path
    assert_equal "Passkey removed.", flash[:notice]
  end
end
