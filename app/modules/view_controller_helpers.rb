module ViewControllerHelpers
  def add_logo_to_nav_bar
    self.navigationItem.titleView = UIImageView.alloc.initWithImage "logo.png".uiimage;
  end

  def add_right_nav_button(title, target, selector)
    self.navigationItem.rightBarButtonItem = get_nav_button(title, target, selector)
  end

  def add_left_nav_button(title, target, selector)
    self.navigationItem.leftBarButtonItem = get_nav_button(title, target, selector)
  end

  def add_title_to_nav_bar(title)
    label = UILabel.alloc.initWithFrame [[0,0],[320,44]]
    label.backgroundColor = UIColor.clearColor
    label.textAlignment = NSTextAlignmentCenter
    label.textColor = UIColor.whiteColor
    label.font = UIFont.boldSystemFontOfSize(20)
    label.text = title
    label.numberOfLines = 0
    label.sizeToFit
    self.navigationItem.titleView = label
  end

  def get_nav_button(title, target, selector)
    UIBarButtonItem.alloc.initWithTitle(title, style:UIBarButtonItemStyleBordered, target:target, action:selector)
  end

  def show_hud
    UIApplication.sharedApplication.keyWindow.setUserInteractionEnabled(false)
    hud = MBProgressHUD.HUDForView(self.view)
    if hud
      hud.show(true)
    else
      hud = MBProgressHUD.showHUDAddedTo(self.view, animated:true)
    end
    hud.mode = MBProgressHUDModeIndeterminate
    hud.labelText = nil
  end

  def hide_hud(success=true)
    UIApplication.sharedApplication.keyWindow.setUserInteractionEnabled(true)
    hud = MBProgressHUD.HUDForView self.view
    hud.mode = MBProgressHUDModeText
    hud.labelText = success ? "Success!" : "Failed."
    hud.hide(true, afterDelay:1)
  end
end
