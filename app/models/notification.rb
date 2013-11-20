class Notification < Model
  include IdentityMap
  establish_identity_on :id

  set_attribute name: :id,
    type: :integer

  set_attribute name: :notifiable_id,
    type: :integer

  set_attribute name: :notifiable_type,
    type: :string

  set_attribute name: :created_at,
    type: :date

  set_relationship name: :dst_user,
    class_name: :User

  set_relationship name: :src_user,
    class_name: :User

  set_relationship name: :notifiable,
    class_name: :Answer

  def self.get_feed(limit=10, offset=0, &block)
    options = {
      :format => :json,
      :payload => {
        :limit => limit,
        :offset => offset
      }
    }
    VeoVeoAPI.get 'notifications', options do |response, json|
      if response.ok?
        notifications = json.map do |n|
          Notification.merge_or_insert(n)
        end
      end
      block.call(response, notifications) if block
    end
  end

  def humanized_date
    formatter = Time.humanized_date_formatter
    date_str = formatter.stringFromDate(self.created_at)
    date_str
  end
end
