class Object
	def proper_case
		self.to_s.humanize.split(/\s/).map { |e| e.capitalize }.join(" ")
	end
end
module CustomHelpers


	
	def inplace_error_div
		content_tag(:div, "", :id => "error_messages")
	end

	def invisible_loader(message = nil, div_id = "loader", class_name = "loader", color = "regular")
		ret = ""
		ret << "<div id=\"#{div_id}\" style=\"display:none\" class=\"#{class_name}\">"
		ret << image_tag("spinner.gif") if color == "regular"
		ret << image_tag("spinner_white.gif") if color == "white"
		ret << image_tag("spinner_update_list.gif") if color == "update_list"

		ret << "&nbsp;&nbsp;<span>#{message.to_s}</span>"
		ret << "</div>"
	end

	def text_field_with_label(object_name, method, options = {})
		set_class_name(options, "text_field")
		ret = create_label_field(object_name, method, options)
		ret << text_field( object_name, method, options)
		ret << add_break_to_form(options)
	end

	def select_field_with_label(object_name, method, choices, options = {}, html_options = {})
		set_class_name(options, "select")
		ret = create_label_field(object_name, method, options)
		ret << select( object_name, method, choices, options, html_options)
		ret << add_break_to_form(options)

	end

	def textarea_field_with_label(object_name, method, options = {})
		set_class_name(options, "textarea")
		ret = create_label_field(object_name, method, options)
		ret << text_area( object_name, method, options)
		ret << add_break_to_form(options)

	end

	def checkbox_field_with_label(object_name, method, options = {})
		set_class_name(options, "checkbox")
		ret = create_label_field(object_name, method, options)
		ret << check_box(object_name, method, options)
		ret << add_break_to_form(options)

	end

	def set_class_name(options, type)
		options.merge!({:class => "input_#{type}" })
	end

	def create_label_field(object_name, method, options = {})
		human_name = options[:human_name] || method.proper_case.gsub(/url/i, "URL")
		id_string = "#{object_name.to_s.downcase}_#{method.to_s.downcase}"
		ret = "<label for=\"#{id_string}\">#{human_name}:"
		if options[:required] == true
			ret << "*"
		end
		ret << " </label>"
	end

	def add_break_to_form(options)
		unless options[:br] == false && !options[:br].nil?
			ret = "<br />"
		end

	end

	def state_select(object, method)
		select(object, method, [ 	
			['Select a State', 'None'],
			['Alabama', 'AL'], 
			['Alaska', 'AK'],
			['Arizona', 'AZ'],
			['Arkansas', 'AR'], 
			['California', 'CA'], 
			['Colorado', 'CO'], 
			['Connecticut', 'CT'], 
			['Delaware', 'DE'], 
			['District Of Columbia', 'DC'], 
			['Florida', 'FL'],
			['Georgia', 'GA'],
			['Hawaii', 'HI'], 
			['Idaho', 'ID'], 
			['Illinois', 'IL'], 
			['Indiana', 'IN'], 
			['Iowa', 'IA'], 
			['Kansas', 'KS'], 
			['Kentucky', 'KY'], 
			['Louisiana', 'LA'], 
			['Maine', 'ME'], 
			['Maryland', 'MD'], 
			['Massachusetts', 'MA'], 
			['Michigan', 'MI'], 
			['Minnesota', 'MN'],
			['Mississippi', 'MS'], 
			['Missouri', 'MO'], 
			['Montana', 'MT'], 
			['Nebraska', 'NE'], 
			['Nevada', 'NV'], 
			['New Hampshire', 'NH'], 
			['New Jersey', 'NJ'], 
			['New Mexico', 'NM'], 
			['New York', 'NY'], 
			['North Carolina', 'NC'], 
			['North Dakota', 'ND'], 
			['Ohio', 'OH'], 
			['Oklahoma', 'OK'], 
			['Oregon', 'OR'], 
			['Pennsylvania', 'PA'], 
			['Rhode Island', 'RI'], 
			['South Carolina', 'SC'], 
			['South Dakota', 'SD'], 
			['Tennessee', 'TN'], 
			['Texas', 'TX'], 
			['Utah', 'UT'], 
			['Vermont', 'VT'], 
			['Virginia', 'VA'], 
			['Washington', 'WA'], 
			['West Virginia', 'WV'], 
			['Wisconsin', 'WI'], 
			['Wyoming', 'WY']])

		end

	end