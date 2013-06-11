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

    end
    @background_observer = App.notification_center.observe UIApplicationDidEnterBackgroundNotification do |notification|
    end
    @login_observer = App.notification_center.observe CurrentUserDidLoginNotification do |notification|

    end
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

end
