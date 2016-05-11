module UDRS
	module Engine
		class TemplateRenderer
			def self.call(template)
				return <<-END
					output = #{template.source.strip}
					@filename = "\#{controller.action_name}.\#{params[:format]}"
					controller.response.headers['Content-Disposition'] = 'inline; filename="\#{@filename}"'
					return output
				END
			end
		end
	end
end
