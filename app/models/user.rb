CurrentUserDidLoginNotification = "CurrentUserDidLoginNotification"
CurrentUserDidLogoutNotification = "CurrentUserDidLogoutNotification"
CurrentUserDidUpdateFollowedUsers = "CurrentUserDidUpdateFollowedUsers"
class User < Model
  include IdentityMap
  establish_identity_on :id

  set_attribute name: :id,
    type: :integer

  set_attribute name: :username,
    type: :string

  set_attribute name: :api_token,
    type: :string

  set_attribute name: :avatar_url_thumb,
    type: :url

  set_attribute name: :avatar_url_full,
    type: :url

  set_attribute name: :following,
    type: :boolean

  set_attribute name: :email,
    type: :string

  set_relationship name: :answers,
    class_name: :Answer

  def is_current?
    self == User.current
  end

  def toggle_following(&block)
    options = {format: :json, payload: {}.to_s}
    method = self.following ? "delete" : "patch"
    VeoVeoAPI.send(method, "users/#{self.id}/follow", options) do |response, json|
      NSNotificationCenter.defaultCenter.postNotificationName(CurrentUserDidUpdateFollowedUsers, object:nil) if response.ok?
      self.following ^= response.ok?
      block.call(response, json) if block
    end
  end

  def get_following(&block)
    options = {format: :json}
    VeoVeoAPI.get "users/#{self.id}/following", options do |response, json|
      if response.ok?
        users = json.map do |j|
          User.merge_or_insert j
        end
      end
      block.call(response, users) if block
    end
  end

  class << self

    attr_accessor :current

    def patch_device_token(device_token)
      payload = BW::JSON.generate({device_token: device_token})
      options = {format: :json, payload: payload}
      VeoVeoAPI.patch 'users/device_token', options do |response, json|
      end
    end

    def register_push
      return unless User.current
      UIApplication.sharedApplication.registerForRemoteNotificationTypes(
        UIRemoteNotificationTypeAlert |
        UIRemoteNotificationTypeBadge |
        UIRemoteNotificationTypeSound
      )
    end

    def current=(current)
      @current = current
      if @current
        persist_user
        register_push
        NSNotificationCenter.defaultCenter.postNotificationName(CurrentUserDidLoginNotification, object:nil)
      else
        delete_user
        NSNotificationCenter.defaultCenter.postNotificationName(CurrentUserDidLogoutNotification, object:nil)
      end
    end

    def persist_user
      # this apparently only gets called on login, need to call more often...
      App::Persistence['current_user'] = @current.to_hash.select {|k,v| v}
    end

    def delete_user
      App::Persistence['current_user'] = nil
    end

    def get_user
      persisted_attributes = App::Persistence['current_user']
      persisted_user = self.merge_or_insert(persisted_attributes) if persisted_attributes
    end

    def current
      @current ||= get_user
    end

    def sign_up(info, &block)
      options = {payload: BW::JSON.generate(info), format: :json}
      VeoVeoAPI.post "users/signup", options do |response, json|
        if response.ok?
          user = self.merge_or_insert json
          User.current = user
        end
        block.call(response.ok?) if block
      end
    end

    def sign_in(info, &block)
      options = {payload: BW::JSON.generate(info), format: :json}
      VeoVeoAPI.post "users/signin", options do |response, json|
        if response.ok?
          user = self.merge_or_insert json
          User.current = user
        end
        block.call(response.ok?)
      end
    end

    def get_id(user_id, &block)
      options = {
        format: :json
      }

      VeoVeoAPI.get "users/#{user_id}", options do |response, json|
        if response.ok?
          user = User.merge_or_insert json
        end
        block.call(response, user) if block
      end
    end

    def upload_avatar(image, &block)
      options = {
        format: :form_data,
        files: {
          avatar: UIImagePNGRepresentation(image)
        }
      }

      VeoVeoAPI.post "users/avatar", options do |response, json|

        block.call(response, User.merge_or_insert(json)) if block
      end
    end

  end # class << self

end
