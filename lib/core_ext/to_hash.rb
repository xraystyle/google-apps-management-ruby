
module Enumerable

	def to_hash
		
		hash = {}
		
		self.each_with_index do |item, index|
			key = index
			hash[key] = item
		end

		return hash

	end

end