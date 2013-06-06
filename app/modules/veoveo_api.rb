module VeoVeoAPI
  class << self

    [:get, :post].each do |verb|
      define_method verb do |path, params, &block|
        perform(verb, path, params, &block)
      end
    end

    def protocol
      config = NSBundle.mainBundle.objectForInfoDictionaryKey('AppConfig', Hash)
      config["api"]["protocol"]
    end

    def host
      config = NSBundle.mainBundle.objectForInfoDictionaryKey('AppConfig', Hash)
      config["api"]["host"]
    end

    def perform(method, path, params={}, &block)
      url = "#{protocol}://#{host}/#{path}"
      BW::HTTP.send(method, url, {
          payload: params,
        }) do |response|
        data = BW::JSON.parse(response.body.to_s) if response.body
        block.call(response, data) if block
      end
    end

  end
end
