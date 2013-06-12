CurrentUserDidLoginNotification = "CurrentUserDidLoginNotification"
CurrentUserDidLogoutNotification = "CurrentUserDidLogoutNotification"
class User
  include MotionModel::Model
  include MotionModel::ArrayModelAdapter
  include VeoVeo::IdentityMap

  columns :id => :integer,
          :username => :string,
          :email => :string,
          :api_token => :string,
          :avatar_url_thumb => :string,
          :avatar_url_full => :string

  class << self

    attr_accessor :current

    def current=(current)
      @current = current
      if @current
        NSKeyedArchiver.archiveRootObject(@current, toFile:store_path)
        NSNotificationCenter.defaultCenter.postNotificationName(CurrentUserDidLoginNotification, object:nil)
      else
        File.delete store_path
        NSNotificationCenter.defaultCenter.postNotificationName(CurrentUserDidLogoutNotification, object:nil)
      end
    end

    def current
      @current ||= NSKeyedUnarchiver.unarchiveObjectWithFile store_path
    end

    def store_path
      File.join App.documents_path, "current_user"
    end

    def sign_up(info, &block)
      options = {payload: BW::JSON.generate(info), format: :json}
      VeoVeoAPI.post "users/sign_up", options do |response, json|
        if response.ok?
          user = self.merge_or_create json['user']
          User.current = user
        end
        block.call(response.ok?) if block
      end
    end

    def sign_in(info, &block)
      options = {payload: BW::JSON.generate(info), format: :json}
      VeoVeoAPI.post "users/sign_in", options do |response, json|
        if response.ok?
          user = self.merge_or_create json['user']
          User.current = user
        end
        block.call(response.ok?)
      end
    end

  end # class << self

end
