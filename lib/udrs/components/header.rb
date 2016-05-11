module UDRS
	module Components
		class Header
			attr_reader :text, :level

			LEVELS = 1..3

			def initialize(text, level = 1)
				@text = text.to_s
				fail ArgumentError, "Invalid level: #{level}" unless LEVELS.include?(level)
				@level = level
			end
		end
	end
end
