module UDRS
	module Components
		class Logo
			attr_reader :alignment, :valignment

			def initialize(options = {})
				@alignment = options[:alignment] || :center
				@valignment = options[:valignment] || :top
			end
		end
	end
end
