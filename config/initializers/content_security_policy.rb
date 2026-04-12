# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy.
# See the Securing Rails Applications Guide for more information:
# https://guides.rubyonrails.org/security.html#content-security-policy-header

Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self
    policy.font_src    :self
    policy.img_src     :self, :data
    policy.object_src  :none
    policy.script_src  :self
    # Allow inline styles required by the Tailwind CSS browser script
    policy.style_src   :self, :unsafe_inline
    policy.connect_src :self
    # Prevent this app from being embedded in frames (clickjacking protection)
    policy.frame_ancestors :none
    policy.base_uri    :self
    policy.form_action :self
  end

  # Generate a unique nonce per request for permitted script tags (importmaps, etc.)
  config.content_security_policy_nonce_generator = ->(_request) { SecureRandom.base64(36) }
  config.content_security_policy_nonce_directives = %w[script-src]
end
