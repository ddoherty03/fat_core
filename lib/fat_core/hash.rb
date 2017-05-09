module FatCore

  module Hash
    # Yield each key-value pair in the Hash together with boolean flags that
    # indicate whether the item is the first or last yielded.
    def each_pair_with_flags
      last_k = size - 1
      k = 0
      each_pair do |key, val|
        first = (k == 0 ? true : false)
        last  = (k == last_k ? true : false)
        yield(key, val, first, last)
        k += 1
      end
    end

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

    # Change each key of this Hash to its value in key_map
    def remap_keys(key_map = {})
      new_hash = {}
      each_pair do |key, val|
        if key_map.key?(key)
          new_hash[key_map[key]] = val
        else
          new_hash[key] = val
        end
      end
      new_hash
    end

    # Change the keys of this Hash to new_keys, an array of keys
    def replace_keys(new_keys)
      unless keys.size == new_keys.size
        raise ArgumentError, 'replace_keys: new keys size differs from key size'
      end
      to_a.each_with_index.map { |(_k, v), i| [new_keys[i], v] }.to_h
    end
  end
end

Hash.include FatCore::Hash
