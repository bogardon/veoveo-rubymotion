class Spot < Model

  set_attributes :latitude => :float,
                 :longitude => :float,
                 :hint => :string,
                 :unlocked => :boolean,
                 :created_at => :date

  set_relationships :answers => :Answer,
                    :user => :User

  # MKProtocol
  def coordinate
    CLLocationCoordinate2DMake(self.latitude, self.longitude)
  end

  def title
    self.hint
  end

  class << self

    def in_region(region, &block)
      options = {
        format: :json,
        payload: {
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
