class AnswerImageView < ImageView
  def self.process_image(image)
    size = [148, 148]
    UIGraphicsBeginImageContextWithOptions(size, false, 0)
    context = UIGraphicsGetCurrentContext()
    UIColor.clearColor.setFill
    rect = [[0,0], size]
    CGContextFillRect(context, rect)
    path = UIBezierPath.bezierPathWithRoundedRect(rect, byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight, cornerRadii:[3,3]).CGPath
    CGContextAddPath(context, path)
    CGContextClosePath(context)
    CGContextClip(context)
    image.drawInRect rect
    processed_image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    processed_image
  end
end
