class Hash

  # Convert hash keys that are Floats to BigDecimal and keys that are ISO date
  # strings to Dates.
  alias_method :__get, :[]
  def [](k)
    if k.class == Float
      __get(BigDecimal.new(k, 12))
    elsif k.class == String && k =~ /\A\s*\d\d\d\d-\d\d-\d\d\s*\z/
      __get(Date.parse(k))
    else
      __get(k)
    end
  end

  alias_method :__set, :[]=

  def []=(k, v)
    if k.class == Float
      __set(BigDecimal.new(k, 12), v)
    elsif k.class == String && k =~ /\A\s*\d\d\d\d-\d\d-\d\d\s*\z/
      __set(Date.parse(k), v)
    else
      __set(k, v)
    end
  end

  # Return all keys in hash that are == to the given value or are included in
  # an Enumerable at the given key
  def keys_with_value(val)
    result = []
    each_pair do |k, v|
      if self[k] == val || (v.respond_to?(:include?) && v.include?(val))
        result << k
      end
    end
    result
  end

  # Remove from the hash all keys that have values == to given value or that
  # include the given value if the hash has an Enumerable for a value
  def delete_with_value(v)
    keys_with_value(v).each do |k|
      delete(k)
    end
  end

  def remap_keys(key_map = {})
    new_hash = {}
    each_pair do |key, val|
      if key_map.has_key?(key)
        new_hash[key_map[key]] = val
      else
        new_hash[key] = val
      end
    end
    new_hash
  end
end
