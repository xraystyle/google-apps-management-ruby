class String

	def titleize
		self.split(" ").collect { |e| e.capitalize }.join(" ")
	end

end
