class UserImageView < ImageView
  def self.process_image(image)
    size = [image.size.width, image.size.height]
    bounds = [[0,0], size]
    radius = (image.size.width/10).floor
    UIGraphicsBeginImageContextWithOptions(size, false, 0);
    context = UIGraphicsGetCurrentContext()
    path = UIBezierPath.bezierPathWithRoundedRect(bounds, cornerRadius:radius).CGPath;
    CGContextAddPath(context, path)
    CGContextClip(context)
    image.drawInRect bounds

    CGContextSetShadowWithColor(context, [0,0], 3, UIColor.colorWithWhite(0, alpha:0.5).CGColor)
    path = UIBezierPath.bezierPathWithRoundedRect([[-1, -1], [image.size.width+2, image.size.height+2]], cornerRadius:radius).CGPath
    CGContextAddPath(context, path)
    CGContextSetStrokeColorWithColor(context, UIColor.redColor.CGColor);
    CGContextStrokePath(context)
    CGContextAddPath(context, path)
    CGContextStrokePath(context)
    processed_image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    processed_image
  end
end
