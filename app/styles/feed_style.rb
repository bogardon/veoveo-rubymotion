Teacup::Stylesheet.new :feed_vc do
  style :background,
    image: "bg.png".uiimage,
    frame: [[0,-44],["100%", "100% + 44"]]

  style :collection_view,
    frame: [[0,0], ["100%", "100%"]],
    backgroundColor: UIColor.clearColor,
    autoresizingMask: autoresize.fill

end
