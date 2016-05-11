module UDRS
	module Components
		class TText
			attr_reader :title, :body

			def initialize(title, body)
				@title = title.to_s
				@body = body.to_s
			end
		end
	end
end
