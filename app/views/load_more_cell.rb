class LoadMoreCell < UICollectionViewCell
  def initWithFrame(frame)
    super
    @activity = UIActivityIndicatorView.alloc.initWithActivityIndicatorStyle(UIActivityIndicatorViewStyleGray)
    @activity.startAnimating
    @activity.frame = [[(self.contentView.frame.size.width/2-@activity.frame.size.width/2).floor, 0], @activity.frame.size]
    self.contentView.addSubview(@activity)
    self
  end
end
