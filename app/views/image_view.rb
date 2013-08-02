class ImageView < UIImageView

  def set_image_from_url(url)
    set_processed_image_from_url url do |image|
      image
    end
  end

  # SDWebImage
  # - (void)setImageWithURL:(NSURL *)url completed:(SDWebImageCompletedBlock)completedBlock;

  def set_processed_image_from_url(url, &block)
    self.image = nil

    return unless url.scheme

    self.setImageWithURL(url, placeholderImage:nil, options:SDWebImageRetryFailed, progress:nil, completed:(lambda do |image, error, cacheType|
      self.image = nil
      if image
        Dispatch::Queue.concurrent(priority=:background).async do
          image_logical = UIImage.imageWithCGImage(image.CGImage, scale:UIScreen.mainScreen.scale, orientation:image.imageOrientation)
          processed_image = block ? block.call(image_logical) : image_logical
          main_queue = Dispatch::Queue.main
          main_queue.async do
            self.image = processed_image
          end
        end
      end
    end))
  end

end
