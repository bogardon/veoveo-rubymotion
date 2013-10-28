class AnswerImageView < ImageView

  def initWithFrame(frame)
    super

    @loading_shutter = LoadingShutter.alloc.initWithFrame self.bounds

    self.addSubview(@loading_shutter)

    self
  end

  def set_image_from_url(url)
    @loading_shutter.start

    set_processed_image_from_url url do |image|
      size = [320,320]
      UIGraphicsBeginImageContextWithOptions(size, false, 0)
      context = UIGraphicsGetCurrentContext()
      UIColor.clearColor.setFill
      rect = [[0,0], size]
      CGContextFillRect(context, rect)
      path = UIBezierPath.bezierPathWithRoundedRect(rect, byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight, cornerRadii:[6,6]).CGPath
      CGContextAddPath(context, path)
      CGContextClosePath(context)
      CGContextClip(context)
      image.drawInRect rect
      processed_image = UIGraphicsGetImageFromCurrentImageContext()
      UIGraphicsEndImageContext()
      processed_image
    end
  end

  def setImage(image)
    super
    if image
      @loading_shutter.stop
    end
  end
end
