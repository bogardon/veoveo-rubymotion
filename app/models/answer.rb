CurrentUserDidSubmitAnswer = "CurrentUserDidSubmitAnswer"
class Answer < Model
  include IdentityMap
  establish_identity_on :id

  set_attribute name: :id,
    type: :integer

  set_attribute name: :image_url_small,
    type: :url

  set_attribute name: :image_url_large,
    type: :url

  set_attribute name: :created_at,
    type: :date

  set_relationship name: :spot,
    class_name: :Spot

  set_relationship name: :user,
    class_name: :User

  def self.submit(spot, image, &block)
    options = {
      format: :form_data,
      payload: {
        spot_id: spot.id
      },
      files: {
        image: UIImageJPEGRepresentation(image, 0)
      }
    }
    VeoVeoAPI.post "answers", options do |response, json|
      spot.unlocked = response.ok?
      if response.ok?
        NSNotificationCenter.defaultCenter.postNotificationName(CurrentUserDidSubmitAnswer, object:nil)
      else

      end
      block.call(response, json) if block
    end
  end

  def self.get_feed(limit=10, offset=0, &block)
    options = {
      :format => :json,
      :payload => {
        :limit => limit,
        :offset => offset
      }
    }
    VeoVeoAPI.get 'answers', options do |response, json|
      if response.ok?
        answers = json.map do |data|
          Answer.merge_or_insert data
        end
      end
      block.call(response, answers) if block
    end
  end

  def humanized_date
    formatter = Time.cached_date_formatter("MMMM dd, YYYY")
    date_str = formatter.stringFromDate(self.created_at)
    date_str
  end
end
