class ImageView < UIImageView

  attr_accessor :query

  def set_image_from_url(url, placeholder=nil)
    set_processed_image_from_url url, placeholder do |image|
      image
    end
  end

  def set_processed_image_from_url(url, placeholder=nil, &block)
    self.image = placeholder

    return unless url && url.scheme

    @query.connection.cancel if @query

    TMCache.sharedCache.objectForKey(url.to_s, block:(lambda do |cache, key, object|
      if object
        processed_image = block ? block.call(object) : object

        Dispatch::Queue.main.async do
          self.image = processed_image if @url.to_s == key
        end

      else
        Dispatch::Queue.main.async do
          @query = BW::HTTP.get url.to_s do |response|
            if response.ok?
              Dispatch::Queue.concurrent(priority=:background).async do
                image = UIImage.alloc.initWithData(response.body, scale:UIScreen.mainScreen.scale)
                TMCache.sharedCache.setObject(image, forKey:key, nil)
                processed_image = block ? block.call(image) : image
                Dispatch::Queue.main.async do
                  self.image = processed_image if @url.to_s == key
                end
              end
            end
          end
        end
      end
    end))

    @url = url
  end

end
