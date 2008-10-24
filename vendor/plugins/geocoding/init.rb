# Basic multi-source geocoding library
# (C) 2007-2008 David Troy, dave@roundhousetech.com

# Initialization is not needed; everything will be loaded in the loadpath via lib/geo.rb
require 'geo'

class Hash
  # Returns hash that is a subset of the current hash, including only the requested keys
  def subset(keys)
    keys.split! if keys is_a?(String)
    result = keys.inject({}) { |result, k| result[k.to_sym] = self[k.to_sym]; result }
  end
end

class ExtractableHash < Hash
  # Allows the extraction of fields from a nested hash with a key string:
  # 'top next_key ... last_key'
  def extract(args)
    h = clone
    args = args.split
    args.each { |a| h=h[a]; h=h.first if (h.is_a?(Array) && h.first.is_a?(Hash)) }
    h
   rescue
     nil
  end
  
  # Generate a new hash with the passed keys => extracted values
  # :new_value => 'top next_key ... last_key'
  def transform(transformation)
    fields = transformation.keys
    fields.inject(ExtractableHash.new) do |result, f|
      result[f] = extract(transformation[f])
      result
    end
  end
end
