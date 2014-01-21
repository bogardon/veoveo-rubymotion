class MapVC < UIViewController
  include ViewControllerHelpers

  EVERYONE = 0
  FOLLOWING = 1

  def init
    super

    NSNotificationCenter.defaultCenter.addObserver(self, selector: :reload, name:CurrentUserDidLoginNotification, object:nil)
    NSNotificationCenter.defaultCenter.addObserver(self, selector: :reload, name:UIApplicationWillEnterForegroundNotification, object:nil)
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

  def loadView
    super
    @map_view = MKMapView.alloc.initWithFrame(self.view.bounds)
    @map_view.delegate = self
    @map_view.showsUserLocation = true
    @map_view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth
    self.view.addSubview(@map_view)

    center_button = UIButton.buttonWithType(UIButtonTypeCustom)
    center_button.frame = [[self.view.frame.size.width - 40, self.view.frame.size.height - 40], [40, 40]]
    center_button.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin
    center_button.addTarget(self, action: :center_on_user, forControlEvents:UIControlEventTouchUpInside)
    center_button.setImage("locate.png".uiimage, forState:UIControlStateNormal)
    self.view.addSubview(center_button)
  end

  def viewDidLoad
    super
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
    vc = AddVC.alloc.init
    nav = UINavigationController.alloc.initWithRootViewController(vc)
    self.presentViewController(nav, animated:true, completion:nil)
  end

  def center_on_user
    return unless @map_view.userLocation.location
    region = MKCoordinateRegionMakeWithDistance(@map_view.userLocation.location.coordinate, 1500, 1500)
    @map_view.setRegion(region, animated:true)
  end

  def mapView(mapView, didUpdateUserLocation:userLocation)
    return unless userLocation.location
    if !@last_location || userLocation.location.distanceFromLocation(@last_location) > 200
      center_on_user
    end
    @last_location = userLocation.location
  end

  SPOT_ANNOTATION_IDENTIFIER = "SPOT_ANNOTATION_IDENTIFIER"

  def mapView(mapView, viewForAnnotation:annotation)
    return nil unless annotation.isKindOfClass(Spot)
    annotation_view = mapView.dequeueReusableAnnotationViewWithIdentifier(SPOT_ANNOTATION_IDENTIFIER) || SpotAnnotationView.alloc.initWithAnnotation(annotation, reuseIdentifier:SPOT_ANNOTATION_IDENTIFIER)
    annotation_view.annotation = annotation
    annotation_view.update_image
    index = mapView.annotations.indexOfObject(annotation)
    annotation_view.callout.tag = index
    annotation_view.left.tag = index
    annotation_view.right.tag = index

    annotation_view.left.addTarget(self, action: :'on_avatar:', forControlEvents:UIControlEventTouchUpInside) unless annotation_view.left.allTargets.count > 0
    annotation_view.callout.addTarget(self, action: :'on_spot:', forControlEvents:UIControlEventTouchUpInside) unless annotation_view.callout.allTargets.count > 0
    annotation_view.right.addTarget(self, action: :'on_spot:', forControlEvents:UIControlEventTouchUpInside) unless annotation_view.right.allTargets.count > 0

    annotation_view
  end

  def mapView(mapView, regionWillChangeAnimated:animated)
    NSObject.cancelPreviousPerformRequestsWithTarget(self, selector: :reload, object:nil)
  end

  def mapView(mapView, regionDidChangeAnimated:animated)
    self.performSelector(:reload, withObject:nil, afterDelay:1)
  end

  def on_avatar(sender)
    spot = @map_view.annotations[sender.tag]
    profile_vc = ProfileVC.new spot.user
    self.navigationController.pushViewController(profile_vc, animated:true)
  end

  def on_spot(sender)
    spot = @map_view.annotations[sender.tag]
    spot_vc = SpotVC.alloc.initWithSpot spot
    self.navigationController.pushViewController(spot_vc, animated:true)
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
        existing_spots = @map_view.annotations - new_spots
        existing_spots.map do |annotation|
          @map_view.viewForAnnotation(annotation)
        end.each do |annotation_view|
          next unless annotation_view.is_a?(SpotAnnotationView)
          annotation_view.update_image
        end
      end
    end

  end

end
