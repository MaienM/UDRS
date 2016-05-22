require 'udrs/renderers/base'
require 'udrs/renderers/escp_renderer/font.rb'
require 'udrs/renderers/escp_renderer/line.rb'
require 'udrs/renderers/escp_renderer/table.rb'

module UDRS
	module Renderers
		# The renderer for ESC/P, short for Epson Standard Code for Printers
		class ESCPRenderer < Base
			NUL = 0.chr
			EOT = 4.chr
			ENQ = 5.chr
			HT = 9.chr
			LF = 10.chr
			FF = 12.chr
			CR = 13.chr
			DLE = 16.chr
			DC4 = 20.chr
			CAN = 24.chr
			ESC = 27.chr
			FS = 28.chr
			GS = 29.chr

			CHARACTER_MAP = {
				'€' => "\xD5",
				'£' => "\x9C",
				'¢' => "\xBD",
				'«' => "\xAE",
				'»' => "\xAF",
				'→' => "\xAF",
				'©' => "\xB8",
				'®' => "\xA9",
			}

			CODE_NUM = 48 # The code num for PDF417
			CODE_SIZE = 3

			def render(container)
				@buffer = ''
				@buffer << "#{ESC}@" # Re-init printer
				@buffer << "#{ESC}t#{19.chr}" # Reset character code table to PC858: Euro
				@buffer << "#{ESC}M#{1.chr}" # Set the font
				@buffer << "#{ESC}G#{0.chr}" # Set double-strike to off
				apply_font_size(:normal)
				apply_bold(false)
				apply_underline(:off)

				# Open the cash drawer
				@buffer << "#{ESC}p#{0.chr}#{100.chr}#{100.chr}"

				# Render the items
				@last_item = :page_end
				render_item(container)
				render_page_end(nil)

				# Replace special characters
				buffer = @buffer.dup
				CHARACTER_MAP.each do |char_orig, char_new|
					buffer.gsub!(char_orig, char_new)
				end

				return buffer
			end

			private

			##############################
			# Render methods
			##############################

			def render_page_end(page_end)
				return if @last_item == :page_end

				# Cut the paper at page end
				@buffer << "\n\n\n\n\n\x1DV1\n"

				@last_item = :page_end
			end

			def render_spacer(spacer)
				add_spacer
			end

			def render_header(header)
				case header.level
					when 1
						add_spacer
						add_line(header.text, size: :huge, bold: true, align: :center)
						add_spacer

					when 2
						add_spacer
						add_line(header.text, size: :large, bold: true)

					when 3
						add_line(header.text, size: :medium, bold: true)

					else
						fail ArgumentError, "Invalid header level: #{header.level}"
				end
			end

			def render_text(item)
				add_line(item.text, text_to_options(item).merge(reflow: true))
			end

			def render_t_text(item)
				add_line("#{item.title}: #{item.body}", size: :normal, bold: false, underline: false, reflow: true)
			end

			def render_logo(logo)
				@buffer << "#{GS}(L#{6.chr}#{0.chr}#{48.chr}#{69.chr}#{32.chr}#{32.chr}#{1.chr}#{1.chr}"
				@last_added = :logo
				add_spacer
			end

			def render_code(code)
				get_pl_ph = proc do |*params|
					# From the docs:
					# pL, pH specify the number of parameters after pH as (pL + pH*256)
					next [params.size % 256, params.size / 256]
				end

				# The way to build a single line/setting of the code
				part = proc do |function, *params| 
					fail ArgumentError unless params.all? { |p| p.is_a?(String) && p.length == 1 }
					pl, ph = get_pl_ph.call(CODE_NUM, function, *params)
					next "#{GS}(k#{pl.chr}#{ph.chr}#{CODE_NUM.chr}#{function.chr}#{params.join}"
				end

				@buffer << "\n"
				@buffer << "#{ESC}a#{1.chr}" # Center
				@buffer << part.call(67, CODE_SIZE.chr) # Set size
				@buffer << part.call(69, 51.chr) # Set error correction
				@buffer << part.call(80, 48.chr, *code.code.chars) # Set the code data
				@buffer << part.call(81, 48.chr) # Start the print
				@buffer << "#{ESC}a#{0.chr}" # End centering

				@last_added = :code
			end

			def render_container(container)
				render_items(container.items)
			end

			def render_footer(footer)
				add_spacer
				render_items(footer.items)
			end

			def render_raw(raw)
				raw.block.call(@buffer)
			end

			def add_spacer
				@buffer << ' ' * @line_width unless @last_added == :spacer
				@last_added = :spacer
			end
		end
	end
end
