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
      unless user.to_s.empty?
        fail('Username must not be empty. deploygate.user = "<your-user-name>"')
        return
      end

      unless token.to_s.empty?
        fail('API Token must set. deploygate.token = "<your-api-token>, or set Environment variable DEPLOYGATE_API_TOKEN"')
        return
      end

      client = DeployGate::Client.new(user, token)

      begin
        response = client.upload(
          binary,
          filename,
          message,
          distribution_name
        )
      rescue Exception => e
        fail("DeployGate Upload throws Exception, see below for ore details.")
        show_deploygate_upload_exception(e)
        return
      end

      unless response.success?
        fail("DeployGate Upload failed for network error. see below for more details.")
        show_deploygate_upload_failed(response)
        return
      end

      app_name = response['results']['name']
      revision = "＃#{response['results']['revision']}"
      url = "https://deploygate.com#{response['results']['path']}"

      message("DeployGate Uploaded <a href='#{url}'>#{app_name} #{revision}</a>")
    end

    private

    def show_deploygate_upload_exception(e)
      error = "## DeployGate Upload Exception\n\n"
      error << "```\n"
      error << "#{e.class} #{e.message}\n"
      error << e.backtrace.join("\n")
      error << "```\n"
      markdown(error)
    end

    def show_deploygate_upload_failed(response)
      error = "## DeployGate Upload Failed\n\n"
      error << "response code #{response.code}, message #{response.message}\n"
      markdown(error)
    end
  end
end
