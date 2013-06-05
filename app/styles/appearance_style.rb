Teacup.handler UINavigationBar, :background { |image|
  setBackgroundImage(image.uiimage, forBarMetrics:UIBarMetricsDefault)
}

Teacup.handler UIBarButtonItem, :bg_image_up { |image|
  setBackgroundImage(image.uiimage.stretchable([16,16,15,16]), forState:UIControlStateNormal, barMetrics:UIBarMetricsDefault)
}

Teacup.handler UIBarButtonItem, :bg_image_down { |image|
  setBackgroundImage(image.uiimage.stretchable([16,16,15,16]), forState:UIControlStateNormal, barMetrics:UIBarMetricsDefault)
}

Teacup.handler UIBarButtonItem, :back_bg_image_up { |image|
  setBackButtonBackgroundImage(image.uiimage.stretchable([16,14,16,4]), forState:UIControlStateNormal, barMetrics:UIBarMetricsDefault)
}

Teacup.handler UIBarButtonItem, :back_bg_image_down { |image|
  setBackButtonBackgroundImage(image.uiimage.stretchable([16,14,16,4]), forState:UIControlStateNormal, barMetrics:UIBarMetricsDefault)
}

Teacup::Appearance.new do
  style UINavigationBar,
    background: 'header.png'
  style UIBarButtonItem,
    bg_image_up: 'navbutton.png',
    bg_image_down: 'navbutton_down.png',
    back_bg_image_up: 'backbutton.png',
    back_bg_image_down: 'backbutton_down.png'
end
