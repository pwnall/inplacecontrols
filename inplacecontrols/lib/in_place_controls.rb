require 'action_view'
require 'custom_helpers'
require 'action_view/helpers/tag_helper'
require 'action_view/helpers/form_helper'
require 'action_view/helpers/javascript_helper'
# InPlaceControls - Do in-place-style editors with other form controls
module DJDossiers
  module InPlaceControls
		include	CustomHelpers
    # These controls were designed to be used with belongs_to associations.  Just use the 
    # object and the foreign key as the attribute.  You can specify a chain of methods to 
    # use for the final display text (so you dont see the foreign key id)
    module ControllerMethods #:nodoc:
      # needed for fields that use any of the helpers below.
      # Call just like the prototype method in_place_edit_for
      # OPTIONS:
      # :final_text 				
      #		this is an array of methods calls to be executed after the update
      # 	ie: in_place_edit_for_non_text_field( :prospect, "status_id", 
      #				{ :final_text => ["status", "title"] })
      #   This will chain the methods together to display the final text for 	the update.  
      # 	The method call will look like: object.status.title
      # 
      # :highlight_endcolor 
      # 	the end color for the "highlight" visual effect.
      #		ie: in_place_edit_for_non_text_field( :prospect, "status_id", 
      #				{ :final_text => ["status", "title"],
      # 				:highlight_endcolor => "'#ffffff'" })
      #
      # :highlight_startcolor
      # 	the start color for the "highlight" visual effect.
      #		ie: in_place_edit_for_non_text_field( :prospect, "status_id", 
      #		{ :final_text => ["status", "title"],
      # 		:highlight_startcolor => "'#ffffff'" })
      #
      def in_place_edit_for_non_text_field(object, attribute, options = {}) 

        define_method("set_#{object}_#{attribute}") do
          
          @item = object.to_s.camelize.constantize.find(params[:id])
          id_string = "#{object}_#{attribute}_#{@item.id }"
          field_id = "#{object}_#{attribute}"
          if @item.update_attributes(attribute => params[object][attribute])
            highlight_endcolor = options[:highlight_endcolor] || "'#ffffff'"
            highlight_startcolor = options[:highlight_startcolor] || "'#ffff99'"
            unless options[:final_text].nil?
              methods = options[:final_text]
              sum_of_methods = @item
              methods.each do |meth|
                sum_of_methods = sum_of_methods.send(meth)
              end
              final_text = sum_of_methods
            else
              final_text = @item.send(attribute).to_s
            end
            render :update do |page|
              page.replace_html "#{id_string}", final_text
              page.hide "#{id_string}_form"
              unless options[:error_messages].nil?
								page.hide "error_messages" 
								page.select("##{id_string}_form ##{field_id}").map { |e| e.remove_class_name "fieldWithError" }
								page[:error_messages].remove_class_name "full_errors"  unless options[:error_messages].nil?
							end
              page.show "#{id_string}"
              page.visual_effect :highlight, "#{id_string}", :duration => 0.5, :endcolor => highlight_endcolor, :startcolor => highlight_startcolor
            end
          else
						#raise @item.inspect
            render :update do |page|
						
              page.select("##{id_string}_form ##{field_id}").map { |e| e.add_class_name "fieldWithError" }
              page[:error_messages].add_class_name "full_errors"
              page.replace_html :error_messages, "<h2>Errors:</h2><ul>#{@item.errors.full_messages.map { |e| "<li>#{e}</li>" }.join("\n  ")}</ul>" unless options[:error_messages]
              page.visual_effect :appear, :error_messages
              
            end unless options[:error_messages].nil?
            
          end
        end
      end

    end

    # These methods are mixed into the view as helpers.
    # Common options for the helpers:
    #   :action - the action to submit the change to
    #   :saving_text - text to show while the request is processing.  Default is "Saving..."
    #   :object - the object to create the control for, if other than an instance variable. (Useful for iterations.)
    # Any other options will be passed on to the HTML control(s).
    module HelperMethods

      # Creates an "active" select box control that submits any changes to the server
      # using an <tt>in_place_edit</tt>-style action.
      # Options:
      #   :choices 			- (required) An array of choices (see method "select")
      #   :display_text - the text to be display before the update.  Used when you want an 
      #   								in_place control for a belongs to association field: 
      # By default the value of the object's attribute will be selected, or blank.
      # Examples:
      #   <%= in_place_select :employee, :manager_id, :choices => Manager.find_all.map { |e| [e.name, e.id] } %>

      def in_place_select(object, method, options = {})

        raise ArgumentError, "Missing choices for select! Specify options[:choices]" if options[:choices].nil?
        object_name = object.to_s
        method_name = method.to_s
        @object = self.instance_variable_get("@#{object}") || options[:object] 
        @value = @object.send(method)
        display_text = options[:display_text] || @object.send(method_name)

        ret = ""
        ret << html_for_inplace_display(object_name, method_name, @object, display_text)
        ret << form_for_inplace_display(object_name, method_name, :select, @object, options)


      end

      def in_place_text_field(object, method, options = {})
        object_name = object.to_s
        method_name = method.to_s
        @object = self.instance_variable_get("@#{object}") || options[:object] 
        @value = @object.send(method)
        display_text = options[:display_text] || @object.send(method_name)

        ret = ""
        ret << html_for_inplace_display(object_name, method_name, @object, display_text)
        ret << form_for_inplace_display(object_name, method_name, :text_field, @object, options)


      end

      # Creates "active" check box controls for HABTM relationships that submits 
      # any changes to the server using an <tt>in_place_edit</tt>-style action.
      # Options:
      #   :choices 			- (required) An array of choices (see method "select")
      #   :display_text - the text to be display before the update.  Used when 
      #  									you want an in_place control for a belongs to 
      # 									association field.
      # By default the value of the object's attribute will be selected, or blank.
      # Examples:
      #   <%= in_place_check_box :manager, :employees, :choices => Employee.find_all.map { |e| [e.name, e.id] } %>

      def in_place_check_box(object, method, options = {})

        raise ArgumentError, "Missing choices for checkboxes! Specify options[:choices]" if options[:choices].nil?
        object_name = object.to_s
        method_name = method.to_s
        @object = self.instance_variable_get("@#{object}") || options[:object] 
        @value = @object.send(method)
        display_text = options[:display_text] || @object.send(method_name)

        ret = ""
        ret << html_for_inplace_display(object_name, method_name, @object, display_text)
        ret << form_for_inplace_display(object_name, method_name, :check_box, @object, options)


      end

      def in_place_radio(object, method, options = {})

        raise ArgumentError, "Missing choices for radios! Specify options[:choices]" if options[:choices].nil?
        object_name = object.to_s
        method_name = method.to_s
        @object = self.instance_variable_get("@#{object}") || options[:object] 
        @value = @object.send(method)
        display_text = options[:display_text] || @object.send(method_name)

        ret = ""
        ret << html_for_inplace_display(object_name, method_name, @object, display_text)
        ret << form_for_inplace_display(object_name, method_name, :radio, @object, options)


      end


      protected
      def html_for_inplace_display(object_name, method_name, object, display_text)
        id_string = "#{object_name}_#{method_name}_#{object.id }"
        retval = ""
        retval << content_tag(:span, 	display_text, 
        :onclick => "Element.hide(this);$('#{id_string }_form').show();", 
        :onmouseover => visual_effect(:highlight, id_string), 
        :title => "Click to Edit", 
        :id => id_string 
        )


      end

      def form_for_inplace_display(object_name, method_name, input_type, object, opts)
        retval = ""
        id_string = "#{object_name}_#{method_name}_#{object.id }"
        set_method = "set_#{object_name}_#{method_name}"
        retval << "<div class=\"in_place_editor_form\" id=\"#{id_string}_form\" style=\"display:none\">"
        retval << form_remote_tag(:url => { :action => set_method, :id => object.id },
        :loading => "$('#{id_string}_buttons').hide(); $('loader_#{id_string}').show();",	
        :complete => "$('loader_#{id_string}').hide();$('#{id_string}_buttons').show();")

        retval << field_for_inplace_editing(object_name, method_name, object, opts, input_type )
        retval << "<br />"
        retval << "<span id=\"#{id_string}_buttons\">"
        retval << submit_tag( "OK", :class => "inplace_submit")
        retval << link_to_function( "Cancel", "$('#{id_string}_form').hide();$('#{id_string}').show() ", {:class => "inplace_cancel" })
        retval << "</span>"
        retval << invisible_loader( "Updating", "loader_#{id_string}", "inplace_loader")
        retval << end_form_tag
      end

      def field_for_inplace_editing(object_name, method_name,  object, options , input_type)
        options[:class] = "inplace_#{input_type}"
        case input_type
        when :text_field
          text_field(object_name, method_name, options )
        when :select
          select(object_name, method_name,  options[:choices], options )
        when :check_box
          checkbox_collection(object_name, method_name, object,  options[:choices] )
        when :radio
          radio_collection(object_name, method_name, object,  options[:choices] )
        end

      end

      def radio_collection(object,method,instance,collection)
        ret = ""
        collection.each do |element| 
          ret << radio_button(object, method, element[1], { :class => "inplace_radio_button"  })
          ret << "<label class=\"inplace_label_for_radio\" for=\"#{object}_#{method}_#{element[1]}\">#{element.first}"

          ret << "</label><br />"
        end
        ret
      end

      def checkbox_collection(object, method, instance, collection)
        if instance.class.reflections.send(method) && instance.class.reflections.send(method).macro == :belongs_to
          m2m = instance.send("#{method}") 
        else
          m2m = instance.send("#{method}".pluralize.to_sym) 
        end
        name_string = "#{object}[#{method}_ids][]" 
        counter = 0
        collection.map do |item|
          id_string = "#{object}_#{method}_#{item.id}" 
          tag_options = {
            "type" => "checkbox", 
            "name" => name_string,
            "id" => id_string,
            "value" => item.id,
            "class" => "inplace_checkbox"
          }

          tag_options["checked"] = "checked" if m2m.respond_to?(:collect) && m2m.collect{|a| a.id}.include?( item.id)
          tag("input", tag_options) + content_tag("label",item.first,"for" => id_string) + tag("br")

        end.join("\n")
      end
    end



  end
end

# Hook code
ActionController::Base.class_eval do #:nodoc:
  extend DJDossiers::InPlaceControls::ControllerMethods
end

ActionView::Base.class_eval do #:nodoc:
  include DJDossiers::InPlaceControls::HelperMethods
end