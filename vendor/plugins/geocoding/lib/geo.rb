require 'open-uri'
require 'json'

# Extensions to Hash
class Hash
  # Returns hash that is a subset of the current hash, including only the requested keys
  def subset(keys)
    keys = keys.split if keys.is_a?(String)
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

# Geocoder service class - provides access to all available geocoder subclasses
module Geo
  class Geocoder

    class << self
      def inherited(klass)
        subclasses << klass
      end
      
      def geocode(location_text)
        result=nil
        subclasses.find do |subclass|
          if location_text[/^([\-\d\.]+),\s*([\-\d\.]+)$/] && subclass.respond_to?(:reverse_geocode)
            result = subclass.reverse_geocode(location_text)
          else
            result = subclass.geocode(location_text)
          end
        end
        result
      end
      
      private
      def subclasses
        @@subclasses ||= []
      end

    end
  end
end

# Provide basic units conversion for geo purposes
class Float
  def to_km
    self*1.609344
  end

  def to_miles
    self/1.609344
  end
end

Dir["#{File.dirname(__FILE__)}/geocoders/*"].sort.each { |geolib| require "#{File.expand_path(geolib)}/geocode" }
