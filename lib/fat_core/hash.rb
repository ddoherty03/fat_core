class Hash
  # @group Enumerable Extensions
  #
  # Yield each key-value pair in the Hash together with two boolean flags that
  # indicate whether the item is the first or last item in the Hash.
  #
  # @example
  #   {a: 1, b: 2, c: 3}.each_pair_with_flags do |k, val, first, last|
  #     print "#{k} => #{val}"
  #     print " is first" if first
  #     print " is last" if last
  #     print " is nothing special" if !first && !last
  #     print "\n"
  #   end
  #
  #   #=> output:
  #   a => 1 is first
  #   b => 2 is nothing special
  #   c => 3 is last
  #
  # @return self [Hash]
  def each_pair_with_flags
    last_k = size - 1
    k = 0
    each_pair do |key, val|
      first = (k == 0 ? true : false)
      last  = (k == last_k ? true : false)
      yield(key, val, first, last)
      k += 1
    end
    self
  end

  # @group Deletion
  #
  # Remove from the hash all keys that have values == to given value or that
  # include the given value if the hash has an Enumerable for a value
  #
  # @example
  #   h = { a: 1, b: 2, c: 3, d: 2, e: 1 }
  #   h.delete_with_value(2) #=> { a: 1, c: 3, e: 1 }
  #   h.delete_with_value([1, 3]) #=> { b: 2, d: 2 }
  #
  # @param v [Object, Enumerable<Object>] value to test for
  # @return [Hash] hash having entries === v or including v deleted
  def delete_with_value(v)
    keys_with_value(v).each do |k|
      delete(k)
    end
    self
  end

  # @group Key Manipulation
  #
  # Return all keys in hash that have a value == to the given value or have an
  # Enumerable value that includes the given value.
  #
  # @example
  #   h = { a: 1, b: 2, c: 3, d: 2, e: 1 }
  #   h.keys_with_value(2) #=> [:b, :d]
  #   h.keys_with_value([1, 3]) #=> [:a, :c, :e]
  #
  # @param v [Object, Enumerable<Object>] value to test for
  # @return [Array<Object>] the keys with value or values v
  def keys_with_value(val)
    result = []
    each_pair do |k, v|
      if self[k] == val || (v.respond_to?(:include?) && v.include?(val))
        result << k
      end
    end
    result
  end

  # Change each key of this Hash to its value in `key_map`. Keys not appearing in
  # the `key_map` remain in the result Hash.
  #
  # @example
  #   h = { a: 1, b: 2, c: 3, d: 2, e: 1 }
  #   key_map = { a: 'alpha', b: 'beta' }
  #   h.remap_keys(key_map) #=> {"alpha"=>1, "beta"=>2, :c=>3, :d=>2, :e=>1}
  #
  # @param key_map [Hash] hash mapping old keys to new
  # @return [Hash] new hash with remapped keys
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

  # Change the keys of this Hash to new_keys, an array of keys of the same size
  # as the Array self.keys.
  #
  # @example
  #   h = { a: 1, b: 2, c: 3, d: 2, e: 1 }
  #   nk = [:z, :y, :x, :w, :v]
  #   h.replace_keys(nk) #=> {:z=>1, :y=>2, :x=>3, :w=>2, :v=>1}
  #
  # @raise [ArgumentError] if new_keys.size != self.keys.size
  # @param new_keys [Array<Object>] replacement keys
  # @return [Hash]
  def replace_keys(new_keys)
    unless keys.size == new_keys.size
      raise ArgumentError, 'replace_keys: new keys size differs from key size'
    end
    to_a.each_with_index.map { |(_k, v), i| [new_keys[i], v] }.to_h
  end
end
