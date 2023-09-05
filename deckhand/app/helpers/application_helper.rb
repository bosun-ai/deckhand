module ApplicationHelper
  def action_path
    "#{controller_path}##{action_name}"
  end

  def ansi_to_html(ansi)
    Ansi::To::Html.new(script_to_html(ansi)).to_html.html_safe
  end

  def script_to_html(script)
    Rack::Utils.escape_html(script)
      .gsub(/(https?:\/\/[^\s]+)/, '<a href="\1" target="_blank">\1</a>')
      .html_safe
  end

  def markdown_to_html(markdown)
    return "" if markdown.blank?
    Kramdown::Document.new(markdown, input: "GFM", syntax_highlighter: :coderay).to_html.html_safe
  end
end
