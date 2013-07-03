CurrentUserDidLoginNotification = "CurrentUserDidLoginNotification"
CurrentUserDidLogoutNotification = "CurrentUserDidLogoutNotification"
CurrentUserDidUpdateFollowedUsers = "CurrentUserDidUpdateFollowedUsers"
class User < Model

  set_attributes :username => :string,
                 :email => :string,
                 :api_token => :string,
                 :avatar_url_thumb => :url,
                 :avatar_url_full => :url,
                 :following => :boolean

  set_relationships :answers => :Answer,
                    :spots => :Spot

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

    def current=(current)
      @current = current
      if @current
        persist_user
        NSNotificationCenter.defaultCenter.postNotificationName(CurrentUserDidLoginNotification, object:nil)
      else
        delete_user
        NSNotificationCenter.defaultCenter.postNotificationName(CurrentUserDidLogoutNotification, object:nil)
      end
    end

    def persist_user
      attributes_to_persist = {}
      self.get_attributes.each do |name, type|
        user_value = @current.send("#{name}")
        attributes_to_persist[name.to_s] = user_value.to_s if user_value
      end
      App::Persistence['current_user'] = attributes_to_persist
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
        user = User.merge_or_insert json
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
