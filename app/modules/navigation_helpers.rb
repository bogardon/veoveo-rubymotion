module NavigationHelpers
  def add_logo_to_nav_bar
    self.navigationItem.titleView = UIImageView.alloc.initWithImage "logo.png".uiimage;
  end
end
