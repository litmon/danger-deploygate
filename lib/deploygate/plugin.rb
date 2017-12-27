require_relative 'deploygate_client'

module Danger
  class DangerDeploygate < Plugin

    #
    # Uploading user or group name
    #
    # @return   [String]
    #
    attr_accessor :user

    #
    # API Token
    #
    # @return   [String]
    #
    attr_writer :token

    def token
      @token ||= ENV['DEPLOYGATE_API_TOKEN']
    end

    def upload(binary, filename, message = nil, distribution_name = nil)
      client = DeployGate::Client.new(user, token)
      response = client.upload(binary, filename, message, distribution_name)

      app_name = response['results']['name']
      revision = "＃#{response['results']['revision']}"
      url = "https://deploygate.com#{response['results']['path']}"

      message "DeployGate Uploaded #{app_name} #{revision}, see detail: #{url}"
    end
  end
end
