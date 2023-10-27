require 'test_helper'

require 'deckhand/process'

class DeckhandProcessTest < ActiveSupport::TestCase
  test "tail should call the callback with what's up" do
    lines = %w[line1 line2 line3]
    args = ['echo', lines.join("\n")]
    out_path = "/tmp/test_output#{rand(10_000)}"

    buffer = ''
    process = Deckhand::Process.spawn(*args, out: out_path) do |output|
      buffer += output[:out] if output[:out]
    end
    process.wait
    assert_equal lines, buffer.lines.map(&:strip)
    assert_equal lines, File.read(out_path).lines.map(&:strip)
  end
end
