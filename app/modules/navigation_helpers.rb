module NavigationHelpers
  def add_logo_to_nav_bar
    self.navigationItem.titleView = UIImageView.alloc.initWithImage "logo.png".uiimage;
  end

  def add_right_nav_button(title, target, selector)
    self.navigationItem.rightBarButtonItem = get_nav_button(title, target, selector)
  end

  def add_left_nav_button(title, target, selector)
    self.navigationItem.leftBarButtonItem = get_nav_button(title, target, selector)
  end

  def get_nav_button(title, target, selector)
    UIBarButtonItem.alloc.initWithTitle(title, style:UIBarButtonItemStyleBordered, target:target, action:selector)
  end
end
