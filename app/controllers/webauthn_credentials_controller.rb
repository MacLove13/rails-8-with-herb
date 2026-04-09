class WebauthnCredentialsController < ApplicationController
  def index
    @credentials = Current.user.webauthn_credentials
  end

  def new_registration_options
    options = WebAuthn::Credential.options_for_create(
      user: { id: Current.user.id.to_s, name: Current.user.email_address },
      exclude: Current.user.webauthn_credentials.pluck(:external_id)
    )
    session[:webauthn_registration_challenge] = options.challenge
    render json: options
  end

  def create
    webauthn_credential = WebAuthn::Credential.from_create(params)

    begin
      webauthn_credential.verify(session[:webauthn_registration_challenge])

      credential = Current.user.webauthn_credentials.create!(
        external_id: webauthn_credential.id,
        public_key: webauthn_credential.public_key,
        sign_count: webauthn_credential.sign_count,
        nickname: params[:nickname].presence || "Passkey"
      )
      render json: { status: "ok", credential_id: credential.id }
    rescue WebAuthn::Error => e
      render json: { error: e.message }, status: :unprocessable_entity
    end
  end

  def destroy
    credential = Current.user.webauthn_credentials.find(params[:id])
    credential.destroy
    redirect_to profile_path, notice: "Passkey removed."
  end
end
