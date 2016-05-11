module UDRS
	module Renderers
		# Font styling
		class ESCPRenderer < Base
			private 

			FONT_SIZE = {
				tiny: [0b0100_0001, 56],
				small: [0b0100_0001, 56],
				normal: [0b0100_0001, 56],
				medium: [0b0100_0000, 42],
				large:  [0b0111_0111, 28],
				huge:   [0b0111_0110, 21],
			}

			UNDERLINE = {
				off: 0,
				light: 1,
				medium: 2,
			}

			def text_to_options(item)
				return {
					size: item.size,
					bold: item.is_bold?,
					underline: item.is_underline?,
					align: item.alignment,
				}
			end

			def font(options = {}, &block)
				font_size(options[:size] || @font_size) do
					bold(options[:bold] || @font_bold) do
						underline(options[:underline] || @font_underline) do
							block.call
						end
					end
				end
			end

			def font_size(size, &block)
				old_size = @font_size
				apply_font_size(size)
				block.call
				apply_font_size(old_size)
			end

			def apply_font_size(size)
				fail ArgumentError, "Invalid font size: #{size}" unless FONT_SIZE.key?(size)
				@font_size = size
				size = FONT_SIZE[size]
				@buffer << "#{ESC}!#{size[0].chr}"
				@line_width = size[1]
			end

			def bold(bold, &block)
				old_bold = @font_bold
				apply_bold(bold)
				block.call
				apply_bold(old_bold)
			end

			def apply_bold(status)
				fail ArgumentError, 'Status must be a boolean' unless status == !!status
				@font_bold = status
				@buffer << "#{ESC}E#{status ? 1.chr : 0.chr}"
			end

			def underline(underline, &block)
				old_underline = @font_underline
				apply_underline(underline)
				block.call
				apply_underline(old_underline)
			end

			def apply_underline(underline)
				underline = :medium if underline == !!underline
				fail ArgumentError, 'Invalid underline value' unless UNDERLINE.key?(underline)
				@font_underline = underline
				@buffer << "#{ESC}_#{UNDERLINE[underline].chr}"
			end
		end
	end
end
