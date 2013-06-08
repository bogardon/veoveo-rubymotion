module VeoVeoAPI
  class << self

    def protocol
      config = NSBundle.mainBundle.objectForInfoDictionaryKey('AppConfig', Hash)
      config["api"]["protocol"]
    end

    def default_headers
      {"Accept" => 'application/json'}
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
        data = BW::JSON.parse(response.body.to_s) if response.body
        block.call(response, data) if block
      end
    end

    def post(path, params={}, &block)
      perform('post', path, BW::JSON.generate(params), &block)
    end

  end
end
