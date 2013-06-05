class SignUpScreen < PM::Screen
  stylesheet :signup_screen
  layout do
    subview(UIImageView, :background)
  end

  def on_load
    self.title = nil
  end

  def will_appear
    navigationController.setNavigationBarHidden(false, animated:true)
  end
end
