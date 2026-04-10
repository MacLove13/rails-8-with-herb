Rails.application.configure do
  # ActiveRecord::Encryption keys for the topsecret gem.
  # In production these are loaded from Rails credentials
  # (active_record_encryption.primary_key, etc.).
  # Development and test environments fall back to fixed placeholder values.
  encryption_config = Rails.application.credentials.active_record_encryption

  config.active_record.encryption.primary_key         = encryption_config&.fetch(:primary_key, nil)         || "topsecret-primary-key-placeholder!"
  config.active_record.encryption.deterministic_key   = encryption_config&.fetch(:deterministic_key, nil)   || "topsecret-determ-key-placeholder!!"
  config.active_record.encryption.key_derivation_salt = encryption_config&.fetch(:key_derivation_salt, nil) || "topsecret-key-derivation-salt-here"

  # Allow querying unencrypted data during a migration to encrypted attributes.
  config.active_record.encryption.support_unencrypted_data = true
end
