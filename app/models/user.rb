class User
  include MotionModel::Model
  columns :id => :integer,
          :first_name => :string,
          :last_name => :string

  def self.current
    @current
  end

  def self.login(user)
    @current = user
    @current
  end
end
