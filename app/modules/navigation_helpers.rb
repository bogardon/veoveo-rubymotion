module NavigationHelpers
  def add_logo_to_nav_bar
    self.navigationItem.titleView = UIImageView.alloc.initWithImage "logo.png".uiimage;
  end

  def add_right_nav_button(title, target, selector)
    self.navigationItem.rightBarButtonItem = UIBarButtonItem.alloc.initWithTitle(title, style:UIBarButtonItemStyleBordered, target:target, action:selector)
  end
end
