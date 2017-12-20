module ErrorHelper
  def display_error(attribute, model_object)
    unless model_object.errors[attribute].empty?
      content_tag :div, attribute.to_s.capitalize + ' ' +  model_object.errors[attribute].join(), class: 'invalid-feedback display-block'
    end
  end
end