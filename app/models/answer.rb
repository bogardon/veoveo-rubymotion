class Answer < Model
  set_attributes :image_url_small => :string,
                 :image_url_large => :string,
                 :created_at => :date

  set_relationships :spot => :Spot,
                    :user => :User
end
