module VoteReport
  class Error < RuntimeError; end
  class APIError < Error; end
end

class Exception
  def to_hash
    { :message => message,
      :time => Time.now }
  end
end