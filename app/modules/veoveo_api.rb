module VeoVeoAPI
  class << self

    USERNAME = "veoveo"
    PASSWORD = "lolumad"

    def protocol
      config = NSBundle.mainBundle.objectForInfoDictionaryKey('AppConfig', Hash)
      config["api"]["protocol"]
    end

    def default_headers
      auth_header = ["#{USERNAME}:#{PASSWORD}"].pack('m0')
      {"Accept" => 'application/json',
       "Authorization" => "Basic #{auth_header}"}
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

  end
end
