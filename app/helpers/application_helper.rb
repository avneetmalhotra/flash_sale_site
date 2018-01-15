module ApplicationHelper

  def strip_html_and_truncate(html_text, length)
    sanitized_html_text = sanitize html_text
    html_stripped_text = strip_tags sanitized_html_text
    truncate(html_stripped_text, length: length)
  end
end
