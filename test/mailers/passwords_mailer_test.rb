require "test_helper"

class PasswordsMailerTest < ActionMailer::TestCase
  test "reset email is sent to user" do
    user = User.take
    mail = PasswordsMailer.reset(user)

    assert_equal "Reset your password", mail.subject
    assert_equal [ user.email_address ], mail.to
    assert_match "reset your password", mail.body.encoded
  end
end
