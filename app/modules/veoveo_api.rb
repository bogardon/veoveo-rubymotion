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

    def perform(method, path, options={}, &block)
      url = "#{protocol}://#{host}/#{path}"
      options[:headers] ||= default_headers
      BW::HTTP.send(method, url, options) do |response|
        json = BW::JSON.parse(response.body.to_s) if response.body
        block.call(response, json) if block
      end
    end

    def post(path, options={}, &block)
      perform('post', path, options, &block)
    end

    def get(path, options={}, &block)
      perform('get', path, options, &block)
    end

  end
end
