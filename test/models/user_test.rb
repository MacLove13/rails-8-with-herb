require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "downcases and strips email_address" do
    user = User.new(email_address: " DOWNCASED@EXAMPLE.COM ")
    assert_equal("downcased@example.com", user.email_address)
  end

  test "requires name" do
    user = User.new(name: nil, email_address: "user@example.com", password: "password")
    assert_not user.valid?
    assert_includes user.errors[:name], "can't be blank"
  end

  test "requires email_address" do
    user = User.new(name: "Test", email_address: nil, password: "password")
    assert_not user.valid?
    assert_includes user.errors[:email_address], "can't be blank"
  end

  test "email_address must be unique" do
    existing = User.take
    user = User.new(name: "Duplicate", email_address: existing.email_address, password: "password")
    assert_not user.valid?
    assert_includes user.errors[:email_address], "has already been taken"
  end

  test "email_address uniqueness is case-insensitive" do
    existing = User.take
    user = User.new(name: "Duplicate", email_address: existing.email_address.upcase, password: "password")
    assert_not user.valid?
    assert_includes user.errors[:email_address], "has already been taken"
  end

  test "has many sessions" do
    user = User.take
    session = user.sessions.create!
    assert_includes user.sessions, session
  ensure
    session&.destroy
  end

  test "has many webauthn_credentials" do
    user = User.take
    credential = user.webauthn_credentials.create!(
      external_id: "user_test_cred_id",
      public_key: "some_key",
      sign_count: 0
    )
    assert_includes user.webauthn_credentials, credential
  ensure
    credential&.destroy
  end

  test "authenticate_by returns user with valid credentials" do
    user = User.take
    authenticated = User.authenticate_by(email_address: user.email_address, password: "password")
    assert_equal user, authenticated
  end

  test "authenticate_by returns nil with invalid password" do
    user = User.take
    result = User.authenticate_by(email_address: user.email_address, password: "wrong")
    assert_nil result
  end

  test "name is encrypted at rest" do
    user = User.create!(name: "Encrypted Bob", email_address: "encrypted@example.com", password: "password")
    raw = User.connection.select_value(
      "SELECT name FROM users WHERE id = #{user.id}"
    )
    assert_not_equal user.name, raw, "name should be stored encrypted, not as plain text"
  ensure
    user&.destroy
  end

  test "name is decrypted transparently on read" do
    user = User.create!(name: "Encrypted Bob", email_address: "encrypted@example.com", password: "password")
    reloaded = User.find(user.id)
    assert_equal "Encrypted Bob", reloaded.name
  ensure
    user&.destroy
  end
end

