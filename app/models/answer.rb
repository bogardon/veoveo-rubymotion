class Answer
  include MotionModel::Model
  include MotionModel::ArrayModelAdapter
  include VeoVeo::IdentityMap

  columns :id => :integer,
          :image_url_small => :string,
          :image_url_large => :string

  attr_accessor :spot
  attr_accessor :user
end
