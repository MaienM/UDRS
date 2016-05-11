module UDRS
	module Renderers
		# Tables
		class ESCPRenderer < Base
			private

			def render_table(table)
				add_spacer

				# Get the column widths
				column_widths = _calculate_table_column_widths(table)

				# For each of the rows, render each cell according to the column with + cell properties
				table.rows.each do |row|
					# Get the non-hidden cells + their blocks
					cells = []
					parts = []
					column_widths.zip(row.cells).each do |width, cell|
						next if width == 0
						cells << cell
						parts << line_to_block(cell.text, width, text_to_options(cell))
					end

					# Make all the blocks have the same amount of lines
					max_length = parts.map(&:size).max
					column_widths.zip(parts).each do |width, lines|
						lines << (' ' * width) while lines.size < max_length
					end

					# Add lines
					parts.transpose.each do |line_parts|
						cells.zip(line_parts).each_with_index do |(cell, part), i|
							@buffer << ' ' if i > 0
							font(text_to_options(cell)) do
								@buffer << part
							end
						end
					end
				end

				@last_added = :table
				add_spacer
			end

			def _calculate_table_column_widths(table)
				# Calculate the column widths
				widths = table.get_column_widths
				totals = [widths.map(&:first).sum, widths.map(&:second).sum, widths.map(&:third).sum]
				columns = (table.columns - [:hide]).size
				spacers = columns - 1

				# Calculate the flex space
				flex = @line_width - totals[0] - spacers
				flex_columns = table.columns.count(:expand)
				flex_indexes = table.columns.each_with_index.select { |c, i| c == :expand }.map(&:second)
				flex_total_weight = widths.values_at(*flex_indexes).map(&:second).sum
				fail ArgumentError, 'Table cannot fit' if flex < flex_columns

				# Determine the final column width
				final_widths = widths.map do |min, desired, max|
					next min if min == max
					next (flex * (desired / flex_total_weight - 0.001)).round
				end
				fail ArgumentError, 'Unable to calculate column widths' if final_widths.sum + spacers > @line_width

				return final_widths
			end
		end
	end
end
