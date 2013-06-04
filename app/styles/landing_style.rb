Teacup::Stylesheet.new :landing_screen do
  style :background,
    image: "splash.png".uiimage,
    frame: [[0,-20],["100%", "100% + 20"]]

  style :sign_up,
    autoresizingMask: UIViewAutoresizingFlexibleTopMargin,
    title: "Sign Up",
    y: "100% - 146",
    width: 224,
    height: 44,
    center_x: '50%'

  style :sign_in,
    autoresizingMask: UIViewAutoresizingFlexibleTopMargin,
    title: "Sign In",
    y: "100% - 92",
    width: 224,
    height: 44,
    center_x: '50%'
end
