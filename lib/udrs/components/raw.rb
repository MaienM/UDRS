module UDRS
	module Components
		class Raw
			attr_reader :block

			def initialize(&block)
				@block = block
			end
		end
	end
end
