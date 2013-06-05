Teacup::Stylesheet.new :form_screen do
  style :background,
  autoresizingMask: autoresize.fill,
  image: "bg.png".uiimage,
  contentMode: UIViewContentModeScaleAspectFill,
  frame: [[0,0],['100%', '100%']]

  style :scrollview,
    autoresizingMask: autoresize.fill,
    frame: [[0,0],['100%', '100%']]

  style :container,
    image: "row_top.png".uiimage.stretchable([22,22,21,21])

  style :prompt,
    font: UIFont.boldSystemFontOfSize(14),
    alignment: :center,
    backgroundColor: UIColor.clearColor,
    frame: [[5, 10], ["100% - 10", 30]]

end

Teacup::Stylesheet.new :signup_screen do
  import :form_screen

  style :signup_form_container, extends: :container,
    frame: [[7,14], ["100% - 14", 180]],

end
