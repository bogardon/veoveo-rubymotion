class FormTextField < UITextField
  attr_accessor :label
  def initWithFrame(frame)
    super
    @label = UILabel.alloc.initWithFrame [[0,0],[80,25]]
    @label.font = UIFont.boldSystemFontOfSize(12)
    @label.textColor = [160, 160, 160].uicolor
    @label.backgroundColor = UIColor.clearColor
    self.leftViewMode = UITextFieldViewModeAlways
    self.leftView = @label
    self.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter
    self.autocapitalizationType = UITextAutocapitalizationTypeNone
    self.backgroundColor = UIColor.clearColor
    self.returnKeyType = UIReturnKeyNext
    self.autocorrectionType = UITextAutocorrectionTypeNo
    self.textColor = UIColor.blackColor
    self.font = UIFont.systemFontOfSize 14
    self
  end

  def leftViewRectForBounds(bounds)
    [[0,0],@label.frame.size]
  end
end
