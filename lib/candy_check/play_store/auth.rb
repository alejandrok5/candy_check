module CandyCheck
  module PlayStore
    # Configure the usage of the official Google API SDK client
    class Auth < Utils::Config
      # @return [String] your client_id
      attr_reader :client_id
      # @return [String] your application's client_secret
      attr_reader :client_secret
      # @return [String] your refresh_token
      attr_reader :refresh_token
      # @return [String] your access_token
      attr_reader :access_token

      def initialize(attributes)
        super
      end

      def verify!(package_name, product_id, purchase_token)
        aps = Google::Apis::AndroidpublisherV2::AndroidPublisherService.new
        aps.authorization = auth_client
        is_verified = false

        aps.get_purchase_product(package_name, product_id, purchase_token) do |result, error|
          is_verified = true if result
          logger.info error.to_s if error
        end
        is_verified
      end

      private
      def auth_client
        Signet::OAuth2::Client.new(
          scope: [Google::Apis::AndroidpublisherV2::AUTH_ANDROIDPUBLISHER],
          authorization_uri: 'https://accounts.google.com/o/oauth2/auth',
          token_credential_uri: 'https://accounts.google.com/o/oauth2/token',
          client_id: client_id,
          client_secret: client_secret,
          refresh_token: refresh_token,
          access_token: access_token
        )
      end

      def validate!
        validates_presence(:client_id)
        validates_presence(:client_secret)
        validates_presence(:refresh_token)
        validates_presence(:access_token)
      end
    end
  end
end
