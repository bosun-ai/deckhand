
module ApplicationHelper
  def ansi_to_html(ansi)
    Ansi::To::Html.new(ansi).to_html
  end
end
