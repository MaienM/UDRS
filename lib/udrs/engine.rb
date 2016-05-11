require 'udrs/engine/rails_helper'
require 'udrs/engine/template_renderer'

module UDRS
	module Engine
		class RailsEngine < Rails::Engine
			ActionView::Base.send(:include, UDRS::Engine::RailsHelper)
			ActionView::Template.register_template_handler(:udrs, UDRS::Engine::TemplateRenderer)

			Mime::Type.register_alias('application/pdf', :pdf) if !Mime::Type.lookup_by_extension(:pdf)
			Mime::Type.register_alias('application/octet-stream', :escp) if !Mime::Type.lookup_by_extension(:escp)
		end
	end
end
