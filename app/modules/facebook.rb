module Facebook
  class << self

    def invite(&block)
      FBWebDialogs.presentRequestsDialogModallyWithSession(nil, message:"Join me on VeoVeo!", title:"Invite Friends", parameters:nil, handler: lambda do |result, resultURL,error|
        block.call(result,resultURL,error) if block
      end)
    end

    def is_open?
      FBSession.activeSession.isOpen
    end

    def login
      return unless User.current && User.current.facebook_access_token && User.current.facebook_expires_at

      accessTokenData = FBAccessTokenData.createTokenFromString(User.current.facebook_access_token, permissions:read_permissions, expirationDate:User.current.facebook_expires_at, loginType:FBSessionLoginTypeNone, refreshDate:nil)
      session = FBSession.alloc.init

      return unless session.state == FBSessionStateCreated

      did_open = session.openFromAccessTokenData(accessTokenData, completionHandler:(lambda do |session, state, error|
        case state
        when FBSessionStateOpen || FBSessionStateOpenTokenExtended
          link session
        end
      end))

      if did_open
        FBSession.setActiveSession session
      end
    end

    def logout
      FBSession.activeSession.closeAndClearTokenInformation
    end

    def read_permissions
      %w[
        email
        user_about_me
        user_birthday
        user_location
      ]
    end

    def publish_permissions
      %w[
        publish_stream
      ]
    end

    def connect(allow_login_ui, &block)
      return unless User.current
      FBSession.openActiveSessionWithReadPermissions(read_permissions, allowLoginUI:allow_login_ui, completionHandler:(lambda do |session, state, error|
        case state
        when FBSessionStateOpen || FBSessionStateOpenTokenExtended
          link session, &block
        end
      end))
    end

    def authorize_for_publish(&block)
      FBSession.activeSession.requestNewPublishPermissions(publish_permissions, defaultAudience:FBSessionDefaultAudienceEveryone, completionHandler:(lambda do |session, error|

      end))
    end

    def link(session, &block)
      payload = {
        facebook_access_token: session.accessTokenData.accessToken,
        facebook_expires_at: session.accessTokenData.expirationDate.to_s
      }
      options = {
        payload: BW::JSON.generate(payload),
        format: :json
      }
      VeoVeoAPI.post 'users/facebook', options do |response, json|
        if response.ok?
          User.current.facebook_access_token = session.accessTokenData.accessToken
          User.current.facebook_expires_at = session.accessTokenData.expirationDate
        end
        block.call(response,json) if block
      end
    end

    def unlink(&block)
      VeoVeoAPI.delete 'users/facebook' do |response, json|
        if response.ok?
          User.current.facebook_id = nil
          User.current.facebook_access_token = nil
          User.current.facebook_expires_at = nil
          self.logout
        end
        block.call(response, json) if block
      end
    end

  end
end
