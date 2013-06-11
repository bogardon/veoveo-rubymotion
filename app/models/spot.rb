class Spot
  include MotionModel::Model
  include MotionModel::ArrayModelAdapter
  include VeoVeo::IdentityMap

  columns :id => :integer,
          :latitude => :float,
          :longitude => :float,
          :name => :string

  belongs_to :user


end
