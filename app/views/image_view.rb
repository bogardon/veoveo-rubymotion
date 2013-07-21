class ImageView < UIImageView

  def self.cache
    @@cache ||= Hash.new
  end

  def dealloc
    @query.connection.cancel if @query
    super
  end

  def set_image_from_url(url)
    set_processed_image_from_url url do |image|
      image
    end
  end

  def set_processed_image_from_url(url, &block)
    return unless url.scheme
    @query.connection.cancel if @query

    if cached = ImageView.cache.objectForKey(url.to_s)
      self.image = cached
    else
      @query = BW::HTTP.get url.to_s do |response|
        if response.ok?
          bg_queue = Dispatch::Queue.concurrent(priority=:background)
          bg_queue.async do
            image_from_data = UIImage.imageWithData(response.body)
            image_logical = UIImage.imageWithCGImage(image_from_data.CGImage, scale:UIScreen.mainScreen.scale, orientation:image_from_data.imageOrientation)
            processed_image = block ? block.call(image_logical) : image_logical
            ImageView.cache.setObject(processed_image, forKey:url.to_s)
            main_queue = Dispatch::Queue.main
            main_queue.async do
              self.image = processed_image
            end
          end
        else
        end
      end
    end

  end

end
