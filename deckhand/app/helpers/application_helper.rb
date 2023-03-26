
module ApplicationHelper
  def ansi_to_html(ansi)
    Ansi::To::Html.new(script_to_html(ansi)).to_html.html_safe
  end

  def script_to_html(script)
    Rack::Utils.escape_html(script)
    .gsub(/(https?:\/\/[^\s]+)/, '<a href="\1" target="_blank">\1</a>')
    .html_safe
  end
end
