Teacup::Stylesheet.new :spot_vc do
  style :background,
    image: "bg.png".uiimage,
    contentMode: UIViewContentModeScaleAspectFill,
    frame: [[0, 0],["100%", "100%"]]

  style :collection_view,
    frame: [[0,0], ["100%", "100%"]],
    backgroundColor: UIColor.clearColor,
    autoresizingMask: autoresize.fill

end
