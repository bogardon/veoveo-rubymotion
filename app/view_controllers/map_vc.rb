class MapVC < UIViewController
  include NavigationHelpers

  stylesheet :map_vc

  layout do
    @map_view = subview(MKMapView, :map_view)
    @map_view.delegate = self
    @map_view.showsUserLocation = true
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
    @did_auto_center = false
    center_on_user

    self.tabBarController.delegate = self

    self.navigationItem.rightBarButtonItem = UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemAdd, target:self, action: :on_add)
  end

  def on_add
    return unless @map_view.userLocation.location
    vc = AddVC.alloc.init
    vc.location = @map_view.userLocation.location
    vc.completion = lambda do |spot|
      if spot
        @map_view.addAnnotation(spot)
        @map_view.selectAnnotation(spot, animated:false)
        self.dismissViewControllerAnimated(true, completion:nil)
      end
    end
    nav = UINavigationController.alloc.initWithRootViewController(vc)
    self.presentViewController(nav, animated:true, completion:nil)
  end

  def tabBarController(tabBarController, shouldSelectViewController:viewController)
    unless viewController != tabBarController.selectedViewController || viewController != self.navigationController
      center_on_user
    end
    true
  end

  def center_on_user
    return unless @map_view.userLocation.location
    region = MKCoordinateRegionMakeWithDistance(@map_view.userLocation.location.coordinate, 1500, 1500)
    @map_view.setRegion(region, animated:true)
  end

  def mapView(mapView, didUpdateUserLocation:userLocation)
    return unless userLocation.location && !@did_auto_center
    @did_auto_center = true
    center_on_user
  end

  SPOT_ANNOTATION_IDENTIFIER = "SPOT_ANNOTATION_IDENTIFIER"

  def mapView(mapView, viewForAnnotation:annotation)
    return nil unless annotation.isKindOfClass(Spot)
    annotation = mapView.dequeueReusableAnnotationViewWithIdentifier(SPOT_ANNOTATION_IDENTIFIER) || SpotAnnotationView.alloc.initWithAnnotation(annotation, reuseIdentifier:SPOT_ANNOTATION_IDENTIFIER)
    annotation
  end

  def mapView(mapView, annotationView:view, calloutAccessoryControlTapped:control)
    spot = view.annotation
    spot_vc = SpotVC.alloc.initWithSpot spot
    navigationController.pushViewController(spot_vc, animated:true)
  end

  def mapView(mapView, regionWillChangeAnimated:animated)
    @query.connection.cancel if @query
  end

  def mapView(mapView, regionDidChangeAnimated:animated)
    reload
  end

  def reload
    return unless User.current && @map_view && @map_view.isUserLocationVisible
    @query.connection.cancel if @query
    @query = Spot.in_region @map_view.region do |response, spots|
      if response.ok?
        new_spots = spots - @map_view.annotations
        @map_view.addAnnotations(new_spots)
      end
    end

  end

end
