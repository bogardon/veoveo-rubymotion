Teacup::Stylesheet.new :landing_screen do
  style :background,
    image: (Device.screen.height == 568 ? "Default-568h.png".uiimage : "Default.png".uiimage),
    frame: [[0,-20],["100%", "100% + 20"]]

  style :sign_up,
    autoresizingMask: UIViewAutoresizingFlexibleTopMargin,
    title: "Sign Up",
    y: "100% - 146",
    width: 224,
    height: 44,
    center_x: '50%',
    normal: {
      bg_image: 'signup_button.png'.uiimage.stretchable([22,4,22,4])
    },
    highlighted: {
      bg_image: 'signup_button_down.png'.uiimage.stretchable([22,4,22,4])
    },
    font: UIFont.boldSystemFontOfSize(15)

  style :sign_in,
    autoresizingMask: UIViewAutoresizingFlexibleTopMargin,
    title: "Sign In",
    y: "100% - 92",
    width: 224,
    height: 44,
    center_x: '50%',
    normal: {
      bg_image: 'signin_button.png'.uiimage.stretchable([22,4,22,4]),
      color: UIColor.darkGrayColor
    },
    highlighted: {
      bg_image: 'signin_button_down.png'.uiimage.stretchable([22,4,22,4])
    },
    font: UIFont.boldSystemFontOfSize(15)
end
