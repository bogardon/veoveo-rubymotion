module VeoVeo
  module IdentityMap
    def self.included(base)
      base.extend(PublicClassMethods)
    end
    module PublicClassMethods
      def merge_or_create(json)
        existing_user = self.collection.find do |user|
          user.id == json['id']
        end

        if existing_user
          existing_user.columns.each do |column|
            new_value = json[column.to_s]
            existing_user.send("#{column.to_s}=", new_value) if new_value
          end
          return existing_user
        else
          return self.create json
        end
      end
    end
  end
end
