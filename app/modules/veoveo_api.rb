module VeoVeoAPI
  class << self

    USERNAME = "veoveo"
    PASSWORD = "lolumad"

    def protocol
      config = NSBundle.mainBundle.objectForInfoDictionaryKey('AppConfig', Hash)
      config["api"]["protocol"]
    end

    def default_headers
      headers = {"Accept" => 'application/json'}
      auth_header = ["#{USERNAME}:#{PASSWORD}"].pack('m0')
      headers["Authorization"] = "Basic #{auth_header}"
      headers["x-veoveo-api-token"] = User.current.api_token if User.current
      headers
    end

    def host
      config = NSBundle.mainBundle.objectForInfoDictionaryKey('AppConfig', Hash)
      config["api"]["host"]
    end

    def perform(method, path, params={}, &block)
      url = "#{protocol}://#{host}/#{path}"
      BW::HTTP.send(method, url, {
          payload: params,
          headers: default_headers,
          format: :json,
        }) do |response|
        json = BW::JSON.parse(response.body.to_s) if response.body
        p json
        block.call(response, json) if block
      end
    end

    def post(path, params={}, &block)
      perform('post', path, BW::JSON.generate(params), &block)
    end

    def get(path, params={}, &block)
      perform('get', path, params, &block)
    end

  end
end
