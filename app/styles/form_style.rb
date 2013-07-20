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
    image: "row_top.png".uiimage.stretchable([22,22,21,21]),
    userInteractionEnabled: true

  style :prompt,
    font: UIFont.boldSystemFontOfSize(14),
    alignment: :center,
    backgroundColor: UIColor.clearColor,
    frame: [[5, 10], ["100% - 10", 30]]

  style :textfield,
    x: 15,
    width: 276,
    height: 25

  style :username, extends: :textfield,
    labelText: "USERNAME:"

  style :password, extends: :textfield,
    labelText: "PASSWORD:",
    secureTextEntry: true

  style :email, extends: :textfield,
    labelText: "EMAIL:",
    returnKeyType: UIReturnKeyDone

  style :separator,
    x: 0,
    width: 306,
    height: 1,
    image: "line.png".uiimage

  style :button,
    font: UIFont.boldSystemFontOfSize(20),
    height: 44,
    x: 7,
    width: "100% - 14",
    titleFont: UIFont.boldSystemFontOfSize(20),
    shadowOffset: [0, 0.5],
    shadowColor: UIColor.darkGrayColor,
    normal: {
      bg_image: "halfbutton.png".uiimage.stretchable([22,22,21,21]),
      color: UIColor.whiteColor
    },
    highlighted: {
      bg_image: "halfbutton_down.png".uiimage.stretchable([22,22,21,21])
    }

end

Teacup::Stylesheet.new :signup_screen do
  import :form_screen

  style :signup_form_container, extends: :container,
    frame: [[7,14], ["100% - 14", 157]],

end

Teacup::Stylesheet.new :signin_screen do
  import :form_screen

  style :signin_form_container, extends: :container,
    frame: [[7,14], ["100% - 14", 71]],

end

Teacup::Stylesheet.new :connect_screen do
  import :form_screen

  style :connect_services_container, extends: :container,
    frame: [[7,14], ["100% - 14", 100]]

  style :facebook,
    height: 32,
    x: 15,
    y: 45,
    width: 32,
    normal: {
      bg_image: "fb_icon_off.png".uiimage
    },
    disabled: {
      bg_image: "fb_icon_on.png".uiimage
    }


end

Teacup.handler FormTextField, :labelText, :text do |target, text|
  target.label.text = text
end

Teacup.handler UIButton, :shadowOffset, :offset do |target, offset|
  target.titleLabel.shadowOffset = offset
end

Teacup.handler UIButton, :shadowColor, :color do |target, color|
  target.setTitleShadowColor(color, forState:UIControlStateNormal)
end
