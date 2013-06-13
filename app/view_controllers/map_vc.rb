class MapVC < UIViewController
  include NavigationHelpers

  stylesheet :map_vc

  layout do
    @map_view = subview(MKMapView, :map_view)
    @map_view.delegate = self
    @map_view.showsUserLocation = true
    @map_view.userTrackingMode = MKUserTrackingModeFollow
  end

  def init
    super
    @foreground_observer = App.notification_center.observe UIApplicationWillEnterForegroundNotification do |notification|
      reload
    end
    @login_observer = App.notification_center.observe CurrentUserDidLoginNotification do |notification|
      reload
    end

    reload

    self
  end

  def dealloc
    App.notification_center.unobserve @foreground_observer
    App.notification_center.unobserve @login_observer
  end

  def viewDidLoad
    super
    add_logo_to_nav_bar
    add_right_nav_button "Test", self, :on_test
  end

  def on_test
    image = UIImagePNGRepresentation("bg.png".uiimage)
    options = {
      format: :form_data,
      files: {image: image},
      payload: {
        latitude: 37.7858276367188,
        longitude: -122.406402587891,
        hint: "lalala"
      }
    }
    VeoVeoAPI.post "spots", options do |response, json|

    end
  end

  def mapView(mapView, didUpdateUserLocation:userLocation)
    return unless userLocation.location
  end

  SPOT_ANNOTATION_IDENTIFIER = "SPOT_ANNOTATION_IDENTIFIER"

  def mapView(mapView, viewForAnnotation:annotation)
    return nil unless annotation.isKindOfClass(SpotProxy)
    annotation = mapView.dequeueReusableAnnotationViewWithIdentifier(SPOT_ANNOTATION_IDENTIFIER) || SpotAnnotationView.alloc.initWithAnnotation(annotation, reuseIdentifier:SPOT_ANNOTATION_IDENTIFIER)
    annotation
  end

  def mapView(mapView, annotationView:view, calloutAccessoryControlTapped:control)
    spot = view.annotation.spot
    spot_vc = SpotVC.alloc.initWithSpot spot
    navigationController.pushViewController(spot_vc, animated:true)
  end

  def mapView(mapView, regionDidChangeAnimated:animated)
    reload
  end

  def reload
    return unless User.current && @map_view && @map_view.isUserLocationVisible

    Spot.in_region @map_view.region do |response, spot_proxies|
      new_spots = spot_proxies - @map_view.annotations
      @map_view.addAnnotations(new_spots)
    end

  end

end
