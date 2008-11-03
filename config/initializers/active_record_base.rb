class ActiveRecord::Base
  def self.safe_find_from_ids(*args)
    ids = args.kind_of?(Array) ? args.flatten : [args]
    ids.empty? ? [] : self.find(:all, :conditions => ["#{self.table_name}.id IN (#{ids.collect{|p| '?'}.join(',')})", ids].flatten)
  end
end