class ConnectVC < UIViewController
  include ViewControllerHelpers
  stylesheet :connect_screen

  layout do
    subview(UIImageView, :background)
    scroll_view = subview(UIScrollView, :scrollview) do
      subview(UIImageView, :connect_services_container) do
        subview(UILabel, :prompt, text: "2. Connect Services")
        @facebook = subview(UIButton, :facebook)
        @facebook.enabled = User.current.facebook_connected?
      end
      @button = subview(UIButton, :button, y: 100)
      @button.setTitle("Done", forState:UIControlStateNormal)
    end
    scroll_view.alwaysBounceVertical = true
  end

  def viewDidLoad
    super
    add_logo_to_nav_bar
    @button.addTarget(self, action: :on_done, forControlEvents:UIControlEventTouchUpInside)
    @facebook.addTarget(self, action: :on_facebook, forControlEvents:UIControlEventTouchUpInside)
  end

  def on_done
    dismissViewControllerAnimated(true, completion:nil)
  end

  def on_facebook
    show_hud
    Facebook.connect do |session, state, error|
      case state
      when FBSessionStateOpen
        User.connect_facebook session do |response, json|
          if response.ok?
            @facebook.enabled = false
            User.current.facebook_access_token = session.accessToken
            User.current.facebook_expires_at = session.expirationDate
          end

          hide_hud response.ok?
        end
      end
    end
  end

end
