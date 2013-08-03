class MapVC < UIViewController
  include ViewControllerHelpers

  stylesheet :map_vc

  EVERYONE = 0
  FOLLOWING = 1

  layout do
    @map_view = subview(MKMapView, :map_view)
    @map_view.delegate = self
    @map_view.showsUserLocation = true
  end

  def init
    super

    NSNotificationCenter.defaultCenter.addObserver(self, selector: :reload, name:CurrentUserDidLoginNotification, object:nil)
    NSNotificationCenter.defaultCenter.addObserver(self, selector: 'on_did_add_spot:', name:SpotDidAddNotification, object:nil)
    NSNotificationCenter.defaultCenter.addObserver(self, selector: 'on_did_delete_spot:', name:SpotDidDeleteNotification, object:nil)

    @filter_following = false

    reload

    self
  end

  def dealloc
    NSNotificationCenter.defaultCenter.removeObserver(self)
    @query.connection.cancel if @query
    super
  end

  def viewDidLoad
    super
    @did_auto_center = false
    center_on_user

    self.tabBarController.delegate = self
    add_right_nav_button "Add", self, :on_add

    segmented_control = MapSegmentedControl.alloc.initWithItems(["Everyone", "Following"])
    segmented_control.selectedSegmentIndex = @filter_following ? FOLLOWING : EVERYONE
    segmented_control.addTarget(self, action: :on_segment, forControlEvents:UIControlEventValueChanged)

    self.navigationItem.titleView = segmented_control
  end

  def on_did_add_spot(notification)
    spot = notification.object
    @map_view.addAnnotation(spot)
    @map_view.selectAnnotation(spot, animated:false)
  end

  def on_did_delete_spot(notification)
    spot = notification.object
    @map_view.removeAnnotation(spot)
  end

  def on_segment
    @filter_following ^= true
    reload
  end

  def on_add
    return unless @map_view.userLocation.location
    vc = AddVC.alloc.init
    vc.location = @map_view.userLocation.location
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
    annotation_view = mapView.dequeueReusableAnnotationViewWithIdentifier(SPOT_ANNOTATION_IDENTIFIER) || SpotAnnotationView.alloc.initWithAnnotation(annotation, reuseIdentifier:SPOT_ANNOTATION_IDENTIFIER)
    annotation_view.update_image
    annotation_view
  end

  def mapView(mapView, annotationView:view, calloutAccessoryControlTapped:control)
    spot = view.annotation
    case control
    when view.leftCalloutAccessoryView
      profile_vc = ProfileVC.new spot.user
      self.navigationController.pushViewController(profile_vc, animated:true)
    when view.rightCalloutAccessoryView
      spot_vc = SpotVC.alloc.initWithSpot spot
      self.navigationController.pushViewController(spot_vc, animated:true)
    else
    end
  end

  def mapView(mapView, regionWillChangeAnimated:animated)
    @query.connection.cancel if @query
  end

  def mapView(mapView, regionDidChangeAnimated:animated)
    reload
  end

  def reload
    return unless User.current && @map_view && @map_view.userLocation.location
    @query.connection.cancel if @query
    @query = Spot.in_region @map_view.region, @filter_following do |response, spots|
      if response.ok?
        old_spots = @map_view.annotations.select do |a|
          a.is_a?(Spot) && !a.user.is_current? && !a.user.following && @filter_following
        end - spots
        @map_view.removeAnnotations old_spots
        new_spots = spots - @map_view.annotations
        @map_view.addAnnotations(new_spots)
        @map_view.annotations.map do |annotation|
          @map_view.viewForAnnotation(annotation)
        end.each do |annotation_view|
          next unless annotation_view.is_a?(SpotAnnotationView)
          annotation_view.update_image
        end
      end
    end

  end

end
