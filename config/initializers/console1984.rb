# frozen_string_literal: true

# Console1984 - Audited Rails console configuration
# See https://github.com/basecamp/console1984
Rails.application.config.console1984.protected_environments = %i[ production ]
Rails.application.config.console1984.username_resolver = ->(username) { User.find_by(email_address: username) }
