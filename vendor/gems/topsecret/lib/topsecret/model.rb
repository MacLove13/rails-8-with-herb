module Topsecret
  module Model
    extend ActiveSupport::Concern

    class_methods do
      # Marks one or more model attributes as secret, encrypting them at rest.
      # Accepts the same options as ActiveRecord's +encrypts+ method.
      #
      # Example:
      #   topsecret :name
      #   topsecret :email_address, deterministic: true
      def topsecret(*attributes, **options)
        encrypts(*attributes, **options)
      end
    end
  end
end
