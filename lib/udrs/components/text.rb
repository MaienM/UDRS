require 'attribute_predicates'

module UDRS
	module Components
		class Text
			attr_reader :text, :is_bold, :is_italic, :is_underline, :size, :alignment

			SIZES = %i(tiny small normal medium large huge)
			ALIGNENTS = %i(left center right)

			def initialize(text, options = {})
				@text = text.to_s

				# Text size
				@size = :normal
				@size = options[:size] if options[:size].present?
				fail ArgumentError, "Invalid size: #{@size}" unless SIZES.include?(@size)

				# Style(s)
				style = [*options[:style]]
				@is_bold = style.delete(:bold)
				@is_italic = style.delete(:italic)
				@is_underline = style.delete(:underline)
				fail ArgumentError, "Invalid style(s): #{style.join(', ')}" unless style.empty?

				# Alignment
				@alignment = :left
				@alignment = options[:align] if options[:align].present?
				fail ArgumentError, "Invalid alignment: #{@alignment}" unless ALIGNENTS.include?(@alignment)
			end
		end
	end
end
