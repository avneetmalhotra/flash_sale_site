module ErrorHelper
  def display_error(attribute, model_object)
    unless model_object.errors[attribute].empty?
      content_tag :div, model_object.errors[attribute].join().capitalize, class: 'field-error display-block'
    end
  end

  def has_error?(attribute, model_object)
    return false if model_object.errors[attribute].empty?
    true
  end
end
