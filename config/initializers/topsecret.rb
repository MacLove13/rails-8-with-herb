Rails.application.configure do
  # ActiveRecord::Encryption keys for the topsecret gem.
  # In production these must be set in Rails credentials under active_record_encryption.
  # Development and test environments fall back to fixed placeholder values.
  encryption_config = Rails.application.credentials.active_record_encryption

  if Rails.env.production?
    primary_key         = encryption_config&.fetch(:primary_key, nil)         or raise "active_record_encryption.primary_key is not set in credentials"
    deterministic_key   = encryption_config&.fetch(:deterministic_key, nil)   or raise "active_record_encryption.deterministic_key is not set in credentials"
    key_derivation_salt = encryption_config&.fetch(:key_derivation_salt, nil) or raise "active_record_encryption.key_derivation_salt is not set in credentials"
  else
    primary_key         = encryption_config&.fetch(:primary_key, nil)         || "topsecret-primary-key-placeholder!"
    deterministic_key   = encryption_config&.fetch(:deterministic_key, nil)   || "topsecret-determ-key-placeholder!!"
    key_derivation_salt = encryption_config&.fetch(:key_derivation_salt, nil) || "topsecret-key-derivation-salt-here"
  end

  config.active_record.encryption.primary_key         = primary_key
  config.active_record.encryption.deterministic_key   = deterministic_key
  config.active_record.encryption.key_derivation_salt = key_derivation_salt

  # Allow querying unencrypted data during a migration to encrypted attributes.
  config.active_record.encryption.support_unencrypted_data = true
end
