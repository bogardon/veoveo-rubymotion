class SignUpScreen < PM::Screen
  stylesheet :signup_screen
  layout do
    subview(UIImageView, :background)
    scroll_view = subview(UIScrollView, :scrollview)
    layout(scroll_view) do
      container = subview(UIImageView, :signup_form_container)
      layout(container) do
        subview(UILabel, :prompt, text: "1. Pick a Username & Password")
      end
    end
  end

  def on_load
    self.title = nil
    self.navigationItem.titleView = UIImageView.alloc.initWithImage "logo.png".uiimage;
  end

  def will_appear
    navigationController.setNavigationBarHidden(false, animated:true)
  end
end
