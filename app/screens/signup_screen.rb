class SignUpScreen < PM::Screen
  stylesheet :signup_screen
  layout do
    subview(UIImageView, :background)
  end

  def on_load
    self.title = nil
    self.navigationItem.titleView = UIImageView.alloc.initWithImage "logo.png".uiimage;
  end

  def will_appear
    navigationController.setNavigationBarHidden(false, animated:true)
  end
end
