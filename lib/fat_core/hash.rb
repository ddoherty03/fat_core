class Hash
  # Return all keys in hash that have a value == to the given value or have an
  # Enumerable value that includes the given value.
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
    self
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
