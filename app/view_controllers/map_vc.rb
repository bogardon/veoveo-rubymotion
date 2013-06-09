class MapVC < UIViewController
  include NavigationHelpers
  stylesheet :map_vc

  layout do
    @map_view = subview(MKMapView, :map_view)
    @map_view.delegate = self
    @map_view.showsUserLocation = true
    @map_view.userTrackingMode = MKUserTrackingModeFollow
  end

  def viewDidLoad
    super
    add_logo_to_nav_bar
  end
end
