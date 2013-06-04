class LandingScreen < PM::Screen
  stylesheet :landing_screen
  layout do
    subview(UIImageView, :background)
    subview(UIButton, :sign_up)
    subview(UIButton, :sign_in)
  end
  def on_load
    navigationController.navigationBar.hidden = true
  end
end
