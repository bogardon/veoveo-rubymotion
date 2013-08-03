class Spot < Model
  include IdentityMap
  establish_identity_on :id

  set_attribute name: :id,
    type: :integer

  set_attribute name: :user_id,
    type: :integer

  set_attribute name: :latitude,
    type: :float

  set_attribute name: :longitude,
    type: :float

  set_attribute name: :created_at,
    type: :date

  set_attribute name: :hint,
    type: :string

  set_attribute name: :unlocked,
    type: :boolean

  set_relationship name: :answers,
    class_name: :Answer

  set_relationship name: :user,
    class_name: :User

  # MKProtocol
  def coordinate
    CLLocationCoordinate2DMake(self.latitude, self.longitude)
  end

  def title
    self.hint
  end

  class << self

    def in_region(region, following, &block)
      options = {
        format: :json,
        payload: {
          following: following.to_s,
          region: {
            latitude: region.center.latitude,
            longitude: region.center.longitude,
            latitude_delta: region.span.latitudeDelta,
            longitude_delta: region.span.longitudeDelta
          }
        }
      }
      VeoVeoAPI.get 'spots', options do |response, json|
        if response.ok?
          spots = json.map do |spot_json|
            Spot.merge_or_insert(spot_json)
          end
          block.call(response, spots) if block
        else
          block.call(response, nil) if block
        end
      end
    end

    def add_new(hint, location, image, &block)
      options = {
        format: :form_data,
        payload: {
          hint: hint,
          latitude: location.coordinate.latitude,
          longitude: location.coordinate.longitude
        },
        files: {
          image: UIImageJPEGRepresentation(image, 0)
        }
      }

      VeoVeoAPI.post "spots", options do |response, json|
        if response.ok?
        else
        end
        block.call(response,json) if block
      end
    end

    def for(spot_id, &block)
      options = {
        format: :json
      }

      VeoVeoAPI.get "spots/#{spot_id}", options do |response, json|
        if response.ok?
          spot = Spot.merge_or_insert(json)
          block.call(response, spot) if block
        else
          block.call(response, nil) if block
        end

      end
    end
  end
end
