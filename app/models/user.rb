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

  end # class << self

end
