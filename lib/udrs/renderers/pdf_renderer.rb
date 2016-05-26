require 'udrs/renderers/base'

require 'prawn'
require 'prawn/table'
require 'barby/barcode/qr_code'
require 'barby/outputter/prawn_outputter'

module UDRS
	module Renderers
		class PDFRenderer < Base
			def render(container)
				# Create the pdf
				@pdf = Prawn::Document.new

				# Allow bold fonts
				@pdf.font_families.update(
					'DejaVuSans' => {
						normal: 'app/assets/DejaVuSans.ttf',
						bold: 'app/assets/DejaVuSans-Bold.ttf',
					},
				)
				@pdf.font('DejaVuSans', size: @pdf.font_size)

				# Render the items
				render_item(container)

				# Render the pdf
				return @pdf.render
			end

			private

			SIZE_MAP = {
				tiny: 9,
				small: 11,
				normal: 11,
				medium: 13,
				large: 15,
				huge: 17,
			}

			def render_page_end(page_end)
				@pdf.start_new_page
			end

			def render_spacer(spacer)
				if spacer.amount > 0
					@pdf.move_down(spacer.amount)
				else
					@pdf.move_up(-1 * spacer.amount)
				end
			end

			def render_header(header)
				case header.level
					when 1
						@pdf.move_down(15)
						@pdf.font(@pdf.font.name, size: SIZE_MAP[:huge], style: :bold) do
							@pdf.text(header.text)
						end

					when 2
						@pdf.move_down(10)
						@pdf.font(@pdf.font.name, size: SIZE_MAP[:large], style: :bold) do
							@pdf.text(header.text)
						end

					when 3
						@pdf.move_down(5)
						@pdf.font(@pdf.font.name, size: SIZE_MAP[:medium], style: :bold) do
							@pdf.text(header.text)
						end

					else
						fail ArgumentError, "Invalid header level: #{header.level}"
				end
			end

			def render_text(item)
				@pdf.font('DejaVuSans', style: _text_to_style(item), size: SIZE_MAP[item.size]) do
					@pdf.text(item.text, align: item.alignment)
				end
			end

			def render_t_text(item)
				c = @pdf.cursor
				title_width = @pdf.bounds.width / 4
				@pdf.bounding_box([0, c], width: @pdf.bounds.width) do
					title_box = @pdf.bounding_box([0, 0], width: title_width) do
						@pdf.font('DejaVuSans', style: :bold) do
							@pdf.text(item.title)
						end
					end
					content_box = @pdf.bounding_box(
						[title_width, title_box.height],
						width: @pdf.bounds.width - title_width,
					) do
						@pdf.text(item.body)
					end
					@pdf.move_cursor_to([title_box.bottom, content_box.bottom].max)
				end
			end

			def render_logo(logo)
				@pdf.image('app/assets/images/logo.png', position: logo.alignment, vposition: logo.valignment)
			end

			def render_code(code)
				qrcode = Barby::QrCode.new(code.code)
				outputter = Barby::PrawnOutputter.new(qrcode)
				dim = 4
				@pdf.move_down(outputter.full_height * dim)
				outputter.annotate_pdf(@pdf, xdim: dim)
				@pdf.move_up(outputter.full_height)
			end

			def render_table(table)
				table_data = table.rows.map { |r| r.cells.map(&:text) }
				@pdf.table(table_data) do |tbl|
					# Lines between all cells
					tbl.cells.borders = %i(bottom right)
					tbl.rows(-1).borders = %i(right)
					tbl.columns(-1).borders = %i(bottom)
					tbl.rows(-1).columns(-1).borders = []

					# Column sizes
					table.columns.each_with_index do |width, ci|
						next if width == :expand # Default, so do nothing

						# For fit, calculate the needed width
						if width == :fit
							widths = table.rows.map do |row|
								cell = row.cells[ci]
								next @pdf.width_of(cell.text, style: _text_to_style(cell), size: SIZE_MAP[cell.size])
							end
							width = widths.max
						end

						pdf_cell = tbl.column(ci).first
						pdf_cell.width = width + pdf_cell.padding_left + pdf_cell.padding_right
					end

					# Cell styles
					table.rows.each_with_index do |row, ri|
						row.cells.each_with_index do |cell, ci|
							pdf_cell = tbl.rows(ri).columns(ci)
							pdf_cell.align = cell.alignment
							pdf_cell.font_style = _text_to_style(cell)
							pdf_cell.font_size = SIZE_MAP[cell.size]
						end
					end
				end
			end

			def render_container(container)
				render_items(container.items)
			end

			def render_footer(footer)
				@pdf.bounding_box([0, 35], width: @pdf.bounds.width, height: 35) do
					render_items(footer.items)
				end
			end

			def render_raw(raw)
				raw.block.call(@pdf)
			end

			def _text_to_style(text)
				style = :normal
				style = :bold if text.is_bold?
				# style = :italic if text.is_italic?
				# style = :underline if text.is_underline?
				return style
			end
		end
	end
end
