module VeoVeoAPI
  class << self

    USERNAME = "veoveo"
    PASSWORD = "lolumad"

    def protocol
      config = NSBundle.mainBundle.objectForInfoDictionaryKey('config', Hash)
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
      config = NSBundle.mainBundle.objectForInfoDictionaryKey('config', Hash)
      config["api"]["host"]
    end

    def perform(method, path, options={}, &block)
      url = "#{protocol}://#{host}/#{path}"
      p "#{method} to #{url}"
      options[:headers] ||= default_headers
      q = BW::HTTP.send(method, url, options) do |response|
        body = response.body
        json = BW::JSON.parse(body) if body && response.ok?
        p json
        block.call(response, json) if block
      end
      q
    end

    def post(path, options={}, &block)
      perform('post', path, options, &block)
    end

    def get(path, options={}, &block)
      perform('get', path, options, &block)
    end

    def patch(path, options={}, &block)
      perform('patch', path, options, &block)
    end

    def delete(path, options={}, &block)
      perform('delete', path, options, &block)
    end

  end
end
