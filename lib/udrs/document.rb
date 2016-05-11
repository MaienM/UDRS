require 'udrs/components'
require 'udrs/renderers'

require 'attribute_predicates'

module UDRS
	class Document
		attr_reader :is_rendering

		TYPES = %i(pdf escp)

		def initialize(type)
			fail ArgumentError, "Unknown udrs type #{type}" unless TYPES.include?(type)
			@type = type
			case type
				when :pdf
					@renderer = Renderers::PDFRenderer.new
				when :escp
					@renderer = Renderers::ESCPRenderer.new
			end

			@container = Components::Container.new
			@rendering = false
		end

		# Check the document type
		def pdf?
			return @type == :pdf
		end
		def escp?
			return @type == :escp
		end

		# Add components
		def end_page(*args)
			add_component(Components::PageEnd.new(*args))
		end
		def spacer(*args)
			add_component(Components::Spacer.new(*args))
		end
		def section(txt)
			add_component(Components::Header.new(txt, 1))
		end
		def subsection(txt)
			add_component(Components::Header.new(txt, 2))
		end
		def subsubsection(txt)
			add_component(Components::Header.new(txt, 3))
		end
		def text(*args)
			add_component(Components::Text.new(*args))
		end
		def ttext(*args)
			add_component(Components::TText.new(*args))
		end
		def logo(*args)
			add_component(Components::Logo.new(*args))
		end
		def code(*args)
			add_component(Components::Code.new(*args))
		end
		def table(*args, &block)
			add_component(Components::Table.new(*args, &block))
		end
		def raw(*args, &block)
			add_component(Components::Raw.new(*args, &block))
		end
		def footer(*args, &block)
			footer = Components::Footer.new(*args)
			using_container(footer, &block)
			add_component(footer)
		end

		# Render the components using the renderer
		def render
			unless @rendered
				@is_rendering = true
				@rendered = @renderer.render(@container)
				@is_rendering = false
			end
			return @rendered
		end
		def render!
			@rendered = nil
			return render
		end

		private

		# If the rendering has already started, immediately render instead of caching
		#
		# This _should_ only happen in blocks passed to raw
		def add_component(component)
			if is_rendering?
				@renderer.render_item(component)
			else
				@container.items << component
			end
		end

		# Perform a block with the current container set to something else
		def using_container(container, &block)
			old_container = @container
			@container = container
			block.call
			@container = old_container
		end
	end
end
