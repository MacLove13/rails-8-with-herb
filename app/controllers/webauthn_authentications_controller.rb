class WebauthnAuthenticationsController < ApplicationController
  allow_unauthenticated_access only: %i[ new_authentication_options create ]

  def new_authentication_options
    options = WebAuthn::Credential.options_for_get
    session[:webauthn_authentication_challenge] = options.challenge
    render json: options
  end

  def create
    challenge = session.delete(:webauthn_authentication_challenge)

    unless challenge
      render json: { error: "Authentication challenge not found or expired" }, status: :unauthorized
      return
    end

    webauthn_credential = WebAuthn::Credential.from_get(params)
    stored_credential = WebauthnCredential.find_by(external_id: webauthn_credential.id)

    if stored_credential.nil?
      render json: { error: "Credential not found" }, status: :unauthorized
      return
    end

    begin
      webauthn_credential.verify(
        challenge,
        public_key: stored_credential.public_key,
        sign_count: stored_credential.sign_count
      )
      stored_credential.update!(sign_count: webauthn_credential.sign_count)

      user = stored_credential.user
      start_new_session_for(user)
      render json: { status: "ok", redirect_url: after_authentication_url }
    rescue WebAuthn::Error => e
      render json: { error: e.message }, status: :unauthorized
    end
  end
end
