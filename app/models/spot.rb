class Spot
  include MotionModel::Model
  include MotionModel::ArrayModelAdapter
  include VeoVeo::IdentityMap

  columns :id => :integer,
          :latitude => :float,
          :longitude => :float,
          :hint => :string,
          :unlocked => :boolean

  attr_accessor :answers
  attr_accessor :user

  def self.in_region(region, &block)
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
    VeoVeoAPI.get 'spots', options do |response, spots|
      if response.ok? && spots.present?
        spot_proxies = spots.valueForKeyPath("spot").map do |spot_json|
          spot = Spot.merge_or_create spot_json
          user = User.merge_or_create spot_json['user']
          spot.user = user
          proxy = SpotProxy.alloc.init
          proxy.spot = spot
          proxy
        end
        block.call(response, spot_proxies) if block
      else
        block.call(response, nil) if block
      end
    end
  end

  def self.for(spot_id, &block)
    options = {
      format: :json
    }

    VeoVeoAPI.get "spots/#{spot_id}", options do |response, data|
      if response.ok?
        spot_json = data['spot']
        answers_json = spot_json['answers']
        answers = answers_json.valueForKeyPath("answer").map do |answer_json|
          user_json = answer_json['user']
          answer = Answer.merge_or_create answer_json
          user = User.merge_or_create user_json
          answer.user = user
          answer
        end
        spot = Spot.merge_or_create spot_json
        spot.answers = answers
        block.call(response, spot) if block
      else
        block.call(response, nil) if block
      end

    end
  end

end
