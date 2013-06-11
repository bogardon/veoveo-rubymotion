class MapVC < UIViewController
  include NavigationHelpers

  stylesheet :map_vc

  layout do
    @map_view = subview(MKMapView, :map_view)
    @map_view.delegate = self
    @map_view.showsUserLocation = true
    @map_view.userTrackingMode = MKUserTrackingModeFollow
    @map_view.addAnnotations(@spots)
  end

  def init
    super
    @foreground_observer = App.notification_center.observe UIApplicationWillEnterForegroundNotification do |notification|

    end
    @background_observer = App.notification_center.observe UIApplicationDidEnterBackgroundNotification do |notification|
    end
    @login_observer = App.notification_center.observe CurrentUserDidLoginNotification do |notification|

    end

    reload

    self
  end

  def dealloc
    App.notification_center.unobserve @foreground_observer
    App.notification_center.unobserve @background_observer
    App.notification_center.unobserve @login_observer
  end

  def viewDidLoad
    super
    add_logo_to_nav_bar
    add_right_nav_button "Logout", self, :logout
  end

  def logout
    User.current = nil
  end

  def mapView(mapView, didUpdateUserLocation:userLocation)
    return unless userLocation.location
    p userLocation.location.coordinate.latitude
    p userLocation.location.coordinate.longitude
  end

  SPOT_ANNOTATION_IDENTIFIER = "SPOT_ANNOTATION_IDENTIFIER"

  def mapView(mapView, viewForAnnotation:annotation)
    return nil unless annotation.isKindOfClass(Spot)
    annotation = mapView.dequeueReusableAnnotationViewWithIdentifier(SPOT_ANNOTATION_IDENTIFIER) || SpotAnnotation.alloc.initWithAnnotation(annotation, reuseIdentifier:SPOT_ANNOTATION_IDENTIFIER)
    annotation
  end

  def mapView(mapView, annotationView:annotation, calloutAccessoryTapped:control)

  end

  def reload
    VeoVeoAPI.get 'spots' do |response, data|
      @spots = data.valueForKeyPath("spot").map do |json|
        WeakRef.new(Spot.merge_or_create json)
      end
      @map_view.addAnnotations(@spots) if @map_view
    end
  end

end
