module UDRS
	module Renderers
		class Base
			def render_item(item)
				method_name = "render_#{item.class.name.demodulize.underscore}"
				fail NotImplementedError, "Cannot render #{item.class.name}" unless respond_to?(method_name, true)
				method(method_name).call(item)
			end

			protected

			def render_items(items)
				items.each(&method(:render_item))
			end
		end
	end
end
