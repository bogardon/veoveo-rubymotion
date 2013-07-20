module Facebook
  class << self
    def connect(&block)
      permissions = %w[
        email
        user_about_me
        user_birthday
        user_location
        read_friendlists
      ]
      FBSession.openActiveSessionWithReadPermissions(permissions, allowLoginUI: true, completionHandler:(lambda do |session, state, error|
        block.call(session,state,error) if block
      end))
    end
  end
end
