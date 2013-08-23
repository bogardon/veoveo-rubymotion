class ImageView < UIImageView

  def set_image_from_url(url, placeholder=nil)
    set_processed_image_from_url url, placeholder do |image|
      image
    end
  end

  def set_processed_image_from_url(url, placeholder=nil, &block)
    self.image = placeholder

    return unless url.scheme

    TMCache.sharedCache.objectForKey(url.to_s, block:(lambda do |cache, key, object|

      Dispatch::Queue.main.async do
        if object
          self.image = object if @url.to_s == key
        else
          BW::HTTP.get url.to_s do |response|
            if response.ok?
              Dispatch::Queue.concurrent(priority=:background).async do
                image = UIImage.alloc.initWithData(response.body, scale:UIScreen.mainScreen.scale)
                processed_image = block ? block.call(image) : image
                TMCache.sharedCache.setObject(processed_image, forKey:key)
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
