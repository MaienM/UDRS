require 'facets/string/word_wrap'

module UDRS
	module Renderers
		# Line methods
		class ESCPRenderer < Base
			private

			def add_lines(lines, options = {})
				lines.each { |l| add_line(l, options) }
			end

			def add_line(line, options = {})
				# Reflow if needed
				line = line.gsub(/\s+/, ' ') if options[:reflow]

				# If multiple lines, process each separately
				if line.include?("\n")
					line.split("\n").each { |line| add_line(line, options) }
					return 
				end

				# Apply the font
				font(options) do
					# Get width from options
					width = options[:width] || @line_width
					width = (width * @line_width).ceil if width.is_a?(Float)
					fail ArgumentError, "Width cannot exceed max line width" if width > @line_width

					# Get indent from options
					indent = options[:indent] || 0
					fail ArgumentError, "Indent cannot be larger than width" if indent >= width
					width -= indent

					# Process the line into lines
					lines = line_to_block(line, width, options)

					# Apply indent
					lines.map! { |line| (' ' * indent) + line }

					# Store lines
					@buffer << lines.join
					@last_added = :line
				end
			end

			def line_to_block(line, width, options = {})
				line = line.to_s
				if line.include?("\n")
					lines = line.split("\n")
					return lines.map { |line| line_to_block(line) }.flatten
				end

				# Wrap lines
				lines = line.word_wrap(width).split("\n")

				# Pad all lines
				lines.map! do |line|
					diff = width - line.size
					case options[:align] || :left
						when :left
							next line + (' ' * diff)
						when :right
							next (' ' * diff) + line
						when :center
							half = diff / 2.0
							next (' ' * half.ceil) + line + (' ' * half.floor)
						else
							fail ArgumentError, "Invalid alignment #{options[:align]}"
					end
				end

				return lines
			end
		end
	end
end
