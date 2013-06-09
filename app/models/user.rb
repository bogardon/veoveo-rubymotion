class User
  include MotionModel::Model
  include MotionModel::ArrayModelAdapter
  include VeoVeo::IdentityMap

  columns :id => :integer,
          :username => :string,
          :email => :string

  class << self

    attr_accessor :current

    def current=(current)
      if current
        NSKeyedArchiver.archiveRootObject(current, toFile:store_path)
      else
        File.delete store_path
      end
      @current = current
    end

    def current
      @current ||= NSKeyedUnarchiver.unarchiveObjectWithFile store_path
    end

    def store_path
      File.join App.documents_path, "current_user"
    end

    def sign_up(info, &block)
      VeoVeoAPI.post "users/sign_up", info do |response, json|
        if response.ok?
          user = self.merge_or_create json['user']
          User.current = user
        end
        block.call(response.ok?) if block
      end
    end

    def sign_in(info, &block)
      VeoVeoAPI.post "users/sign_in", info do |response, json|
        if response.ok?
          user = self.merge_or_create json['user']
          User.current = user
        end
        block.call(response.ok?)
      end
    end

  end # class << self

end
