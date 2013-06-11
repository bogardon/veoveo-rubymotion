class Spot
  include MotionModel::Model
  include MotionModel::ArrayModelAdapter
  include VeoVeo::IdentityMap

  columns :id => :integer,
          :latitude => :float,
          :longitude => :float,
          :title => :string

  belongs_to :user

  def coordinate
    CLLocationCoordinate2DMake(self.latitude, self.longitude)
  end

  def subtitle
    "some subtitle"
  end

end
