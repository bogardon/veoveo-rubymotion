class ImageView < UIImageView

  def self.process_image(image)
    image
  end

  def set_image_from_url(url)
    return unless url.scheme
    @query.connection.cancel if @query

    @query = BW::HTTP.get url.to_s do |response|
      @response = response

      if @response.ok?
        bg_queue = Dispatch::Queue.concurrent(priority=:default)
        bg_queue.async do
          image_from_data = UIImage.imageWithData(@response.body)
          image_logical = UIImage.imageWithCGImage(image_from_data.CGImage, scale:UIScreen.mainScreen.scale, orientation:image_from_data.imageOrientation)
          @processed_image = self.class.process_image image_logical
          main_queue = Dispatch::Queue.main
          main_queue.async do
            self.image = @processed_image
          end
        end
      else
      end

    end
  end

end
