Teacup::Stylesheet.new :map_vc do
  style :map_view,
    autoresizingMask: autoresize.fill,
    frame: [[0,0],["100%", "100%"]]

  style :center,
    frame: [["100% - 40", "100% - 40"], [40, 40]],
    autoresizingMask: UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin,
    normal: {
      image: "locate.png".uiimage
    },
end
