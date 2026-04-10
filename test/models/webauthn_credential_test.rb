require "test_helper"

class WebauthnCredentialTest < ActiveSupport::TestCase
  setup do
    @user = User.take
  end

  test "is valid with valid attributes" do
    credential = WebauthnCredential.new(
      user: @user,
      external_id: "unique_external_id",
      public_key: "some_public_key",
      sign_count: 0
    )
    assert credential.valid?
  end

  test "requires external_id" do
    credential = WebauthnCredential.new(
      user: @user,
      external_id: nil,
      public_key: "some_public_key",
      sign_count: 0
    )
    assert_not credential.valid?
    assert_includes credential.errors[:external_id], "can't be blank"
  end

  test "requires public_key" do
    credential = WebauthnCredential.new(
      user: @user,
      external_id: "some_external_id",
      public_key: nil,
      sign_count: 0
    )
    assert_not credential.valid?
    assert_includes credential.errors[:public_key], "can't be blank"
  end

  test "requires sign_count" do
    credential = WebauthnCredential.new(
      user: @user,
      external_id: "some_external_id",
      public_key: "some_public_key",
      sign_count: nil
    )
    assert_not credential.valid?
    assert_includes credential.errors[:sign_count], "can't be blank"
  end

  test "external_id must be unique" do
    @user.webauthn_credentials.create!(
      external_id: "duplicate_id",
      public_key: "key_one",
      sign_count: 0
    )

    duplicate = WebauthnCredential.new(
      user: @user,
      external_id: "duplicate_id",
      public_key: "key_two",
      sign_count: 0
    )

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:external_id], "has already been taken"
  ensure
    @user.webauthn_credentials.where(external_id: "duplicate_id").destroy_all
  end

  test "belongs to user" do
    credential = @user.webauthn_credentials.create!(
      external_id: "belongs_to_user_id",
      public_key: "some_public_key",
      sign_count: 0
    )
    assert_equal @user, credential.user
  ensure
    credential&.destroy
  end

  test "is destroyed when user is destroyed" do
    user = User.create!(name: "Temp User", email_address: "temp_webauthn@example.com", password: "password")
    user.webauthn_credentials.create!(
      external_id: "temp_credential_id",
      public_key: "temp_key",
      sign_count: 0
    )
    assert_difference "WebauthnCredential.count", -1 do
      user.destroy
    end
  end
end
