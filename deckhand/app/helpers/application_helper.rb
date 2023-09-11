module ApplicationHelper
  def middle_truncate(str, total: 30, lead: 15, trail: 15, fill: "...")
    return nil if str.nil?
    str.truncate(total, omission: "#{str.first(lead)}#{fill}#{str.last(trail)}")
  end

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
    raise "Markdown is not a string: #{markdown.inspect}" unless markdown.is_a?(String)
    Kramdown::Document.new(markdown, input: "GFM", syntax_highlighter: :coderay).to_html.html_safe
  end
end
