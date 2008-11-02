# Extensions to String
class String
  def capitalize_words
    split.map(&:capitalize_word).join " "
  end
  
  def capitalize_words!
    replace capitalize_words
  end

	def capitalize_word
		self.size > 3 ? self.capitalize : self
	end
end