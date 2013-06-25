class Answer < Model
  set_attributes :image_url_small => :string,
                 :image_url_large => :string,
                 :created_at => :date

  set_relationships :spot => :Spot,
                    :user => :User

  def self.submit(spot, image, &block)
    options = {
      format: :form_data,
      payload: {
        spot_id: spot.id
      },
      files: {
        image: UIImagePNGRepresentation(image)
      }
    }
    VeoVeoAPI.post "answers", options do |response, json|
      if response.ok?

      else

      end
      block.call(response, json) if block
    end
  end

  def humanized_date
    formatter = Time.cached_date_formatter("MMMM dd, YYYY")
    date_str = formatter.stringFromDate(self.created_at)
    date_str
  end
end
