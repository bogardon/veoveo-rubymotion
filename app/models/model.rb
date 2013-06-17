class Model

  class << self

    attr_accessor :attributes

    def get_attributes
      attributes = {}
      current_class = self
      while current_class.respond_to?(:attributes)
        attributes.merge!(current_class.attributes || {})
        current_class = current_class.superclass
      end
      attributes
    end

    def set_attributes(attributes)
      attributes.each do |name, type|
        attr_accessor name

        # setter
        define_method("#{name}=") do |value|
          new_value =
            case type
            when :integer
              value.to_i
            when :float
              value.to_f
            when :date
              # parse date
            when :url
              NSURL.URLWithString value.to_s
            when :string
              value.to_s
            when :boolean
              # convert to bool
              !!value
            else
              nil
            end if value
          self.willChangeValueForKey name
          self.instance_variable_set("@#{name}", new_value)
          self.didChangeValueForKey name
        end
      end
      self.attributes ||= {}
      self.attributes.merge!(attributes)
    end

    attr_accessor :relationships

    def get_relationships
      current_class = self
      relationships = {}
      while current_class.respond_to?(:relationships)
        relationships.merge!(current_class.relationships || {})
        current_class = current_class.superclass
      end
      relationships
    end

    def set_relationships(relationships)
      relationships.each do |name, type|

        attr_accessor name

        # override setter
        define_method("#{name}=") do |value|
          cls = Kernel.const_get(type.capitalize)

          new_value = case value
            when Hash
              cls.merge_or_insert value
            when Array
              value.map {|e| e.is_a?(cls) ? e : cls.merge_or_insert(e)}
            when cls
              value
            else
              nil
            end if value

          self.willChangeValueForKey name
          self.instance_variable_set("@#{name}", new_value)
          self.didChangeValueForKey name
        end
      end
      self.relationships ||= {}
      self.relationships.merge!(relationships)
    end

    def identity_map
      @@identity_map ||= Hash.new do |map, key|
        map[key] = {}
      end
    end

    def merge_or_insert(json)
      new_model = self.new json
      old_model = self.identity_map[self.to_s][new_model.id]
      self.identity_map[self.to_s][new_model.id] = new_model unless old_model
      old_model.merge_with_model(new_model) if old_model
      (old_model || new_model)
    end
  end

  set_attributes :id => :integer

  def initialize(json)
    self.class.get_relationships.each do |name, type|
      json_value = json[name.to_s]
      self.send("#{name}=", json_value) if json_value
    end if self.class.relationships

    self.class.get_attributes.each do |name, type|
      json_value = json[name.to_s]
      self.send("#{name}=", json_value) if json_value
    end if self.class.attributes
  end

  def merge_with_model(model)
    self.class.get_relationships.each do |name, type|
      model_value = model.send("#{name}")
      self.send("#{name}=", model_value) if model_value
    end if self.class.relationships

    self.class.get_attributes.each do |name, type|
      model_value = model.send("#{name}")
      self.send("#{name}=", model_value) if model_value
    end if self.class.attributes
  end

  def ==(other)
    return false unless other.is_a?(self.class)
    self.id == other.id
  end

end
