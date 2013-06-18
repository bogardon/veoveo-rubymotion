CurrentUserDidLoginNotification = "CurrentUserDidLoginNotification"
CurrentUserDidLogoutNotification = "CurrentUserDidLogoutNotification"
class User < Model

  set_attributes :username => :string,
                 :email => :string,
                 :api_token => :string,
                 :avatar_url_thumb => :string,
                 :avatar_url_full => :string

  def is_current?
    self == User.current
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
        attributes_to_persist[name.to_s] = user_value if user_value
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

  end # class << self

end
