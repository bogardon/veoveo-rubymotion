class UserImageView < ImageView

  def self.create_placeholder
    image = "avatar.png".uiimage
    size = [image.size.width, image.size.height]
    bounds = [[0,0], size]
    radius = (image.size.width/10).floor
    UIGraphicsBeginImageContextWithOptions(size, false, 0)
    context = UIGraphicsGetCurrentContext()
    path = UIBezierPath.bezierPathWithRoundedRect(bounds, cornerRadius:radius).CGPath
    CGContextAddPath(context, path)
    CGContextClip(context)
    image.drawInRect bounds

    processed_image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    processed_image
  end

  def self.placeholder
    @placeholder ||= create_placeholder
  end

  def set_image_from_url(url)
    set_processed_image_from_url url, self.class.placeholder do |image|

      size = [image.size.width, image.size.height]
      bounds = [[0,0], size]
      radius = (image.size.width/10).floor
      UIGraphicsBeginImageContextWithOptions(size, false, 0)
      context = UIGraphicsGetCurrentContext()
      path = UIBezierPath.bezierPathWithRoundedRect(bounds, cornerRadius:radius).CGPath
      CGContextAddPath(context, path)
      CGContextClip(context)
      image.drawInRect bounds
      processed_image = UIGraphicsGetImageFromCurrentImageContext()
      UIGraphicsEndImageContext()
      processed_image
    end
  end

end
