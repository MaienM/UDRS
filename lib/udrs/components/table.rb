module UDRS
	module Components
		class Table
			attr_reader :columns, :rows

			COLUMN_SIZES = %i(fit expand hide)

			def initialize(*columns, &block)
				@columns = columns
				invalid = (columns.reject { |c| c.is_a?(Fixnum) } - COLUMN_SIZES).uniq
				fail ArgumentError, "Invalid column size(s): #{invalid.join(', ')}" unless invalid.empty?

				@rows = []
				block.call(self)
			end

			def row(*args, &block)
				@rows << Row.new(self, *args, &block)
			end

			def get_column_widths
				return columns.each_with_index.map do |column, i|
					case column
						# Fixed width
						when Fixnum
							next [column, column, column]

						# Fit
						when :fit
							size = rows.map { |r| r.cells[i] }.map(&:text).map(&:size).max
							next [size, size, size]

						# Expand
						when :expand
							size = rows.map { |r| r.cells[i] }.map(&:text).map(&:size).max
							next [0, size, 9999]

						# Hide
						when :hide
							next [0, 0, 0]

						else
							fail ArgumentError, "Cannot calculate column width for #{column}"
					end
				end
			end
		end

		class Row
			attr_reader :cells

			def initialize(table, *args, &block)
				options = {}
				options = args.pop if args.last.is_a?(Hash)

				@cells = []
				args.each { |c| cell(c, options) }
				block.call(self) if block

				if @cells.size != table.columns.size
					fail ArgumentError, "Row contains #{cells.size} cells, but #{table.columns.size} are required"
				end
			end

			def cell(text, options = {})
				@cells << Text.new(text, options)
			end
		end
	end
end
