module ApplicationHelper
	def nav_link_classes(active: false)
		base_classes = "border-b-2 pb-1 text-sm font-medium transition"

		if active
			"#{base_classes} border-orange-500 text-orange-400"
		else
			"#{base_classes} border-transparent text-white/80 hover:border-orange-500/60 hover:text-orange-400"
		end
	end

	def nav_section_active?(*controller_names)
		controller_names.include?(controller_path)
	end
end
