class SwitchCell < FeedCell
  attr_accessor :switch
  attr_accessor :label
  def initWithFrame(frame)
    super
    @switch = UISwitch.alloc.init
    @switch.center = [self.contentView.frame.size.width - 10 - (@switch.frame.size.width/2).floor, self.contentView.center.y]
    self.contentView.addSubview(@switch)

    @label = UILabel.alloc.initWithFrame([[10,10],[200,20]])
    @label.backgroundColor = UIColor.clearColor
    @label.font = UIFont.systemFontOfSize 13
    self.contentView.addSubview(@label)
    self
  end
end
