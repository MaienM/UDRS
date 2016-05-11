module UDRS
	module Engine
		module RailsHelper
			def udrs_document(&block)
				doc = UDRS::Document.new(params[:format].to_sym)
				block.call(doc)
				return doc.render
			end
		end
	end
end
