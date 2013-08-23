class MapSegmentedControl < UISegmentedControl

  def initWithItems(items)
    super
    self.setBackgroundImage("navbutton.png".uiimage.stretchable([16,5,15,5]), forState:UIControlStateNormal, barMetrics:UIBarMetricsDefault)
    self.setBackgroundImage("navbutton_down.png".uiimage.stretchable([16,5,15,5]), forState:UIControlStateSelected, barMetrics:UIBarMetricsDefault)


    self.setDividerImage("divider_up_down.png".uiimage, forLeftSegmentState:UIControlStateNormal, rightSegmentState:UIControlStateSelected, barMetrics:UIBarMetricsDefault)
    self.setDividerImage("divider_down_up".uiimage, forLeftSegmentState:UIControlStateSelected, rightSegmentState:UIControlStateNormal, barMetrics:UIBarMetricsDefault)

    self.setDividerImage(UIImage.alloc.init, forLeftSegmentState:UIControlStateNormal, rightSegmentState:UIControlStateNormal, barMetrics:UIBarMetricsDefault)
    self.setDividerImage(UIImage.alloc.init, forLeftSegmentState:UIControlStateSelected, rightSegmentState:UIControlStateSelected, barMetrics:UIBarMetricsDefault)

    text_attributes = {
      UITextAttributeFont => UIFont.boldSystemFontOfSize(12),
      UITextAttributeTextColor => UIColor.whiteColor,
      UITextAttributeTextShadowColor => UIColor.clearColor,
      UITextAttributeTextShadowOffset => NSValue.valueWithUIOffset(UIOffsetMake(0,0))
    }


    self.setTitleTextAttributes(text_attributes, forState:UIControlStateNormal)
    self.setTitleTextAttributes(text_attributes, forState:UIControlStateSelected)
    self
  end

end
