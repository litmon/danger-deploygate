require 'net/http'
require 'uri'
require 'json'

module DeployGate
  class Client
    BASE_URL = 'https://deploygate.com/api'

    def initialize(user: '', token: '')
      @user = user
      @token = token
    end

    def upload(file, filename, message = nil, distribution_name = nil)
      data = [
        ['file', file, { filename: filename }],
        ['token', @token],
      ]
      if message 
        data << ['message', message]
      end
      if distribution_name
        data << ['distribution_name', distribution_name]
      end

      uri = URI.parse(BASE_URL + "/users/#{@user}/apps")
      res = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
        req = Net::HTTP::Post.new(uri)
        req.set_form(data, 'multipart/form-data')
        http.request(req)
      end

      ::DeployGate::Response.new(res)
    end
  end

  class Response
    
    def initialize(res)
      @res = res
    end

    def success?
      @res.code == '200'
    end

    def body
      @body ||= JSON.parse(@res.body)
    end

    def results
      @results ||= body['results']
    end

    def [](name)
      body[name]
    end

  end
end

