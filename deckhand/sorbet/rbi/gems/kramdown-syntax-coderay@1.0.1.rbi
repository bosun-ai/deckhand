# typed: true

# DO NOT EDIT MANUALLY
# This is an autogenerated file for types exported from the `kramdown-syntax-coderay` gem.
# Please instead update this file by running `bin/tapioca gem kramdown-syntax-coderay`.

# source://kramdown-syntax-coderay//lib/kramdown/converter/syntax_highlighter/coderay.rb#14
module Kramdown
  class << self
    # source://kramdown/2.4.0/lib/kramdown/document.rb#49
    def data_dir; end
  end
end

# source://kramdown-syntax-coderay//lib/kramdown/converter/syntax_highlighter/coderay.rb#100
module Kramdown::Converter
  class << self
    # source://kramdown/2.4.0/lib/kramdown/utils/configurable.rb#37
    def add_math_engine(data, *args, &block); end

    # source://kramdown/2.4.0/lib/kramdown/utils/configurable.rb#37
    def add_syntax_highlighter(data, *args, &block); end

    # source://kramdown/2.4.0/lib/kramdown/utils/configurable.rb#30
    def configurables; end

    # source://kramdown/2.4.0/lib/kramdown/utils/configurable.rb#34
    def math_engine(data); end

    # source://kramdown/2.4.0/lib/kramdown/utils/configurable.rb#34
    def syntax_highlighter(data); end
  end
end

# source://kramdown-syntax-coderay//lib/kramdown/converter/syntax_highlighter/coderay.rb#101
module Kramdown::Converter::SyntaxHighlighter; end

# Uses Coderay to highlight code blocks and code spans.
#
# source://kramdown-syntax-coderay//lib/kramdown/converter/syntax_highlighter/coderay.rb#104
module Kramdown::Converter::SyntaxHighlighter::Coderay
  class << self
    # source://kramdown-syntax-coderay//lib/kramdown/converter/syntax_highlighter/coderay.rb#108
    def call(converter, text, lang, type, call_opts); end

    # source://kramdown-syntax-coderay//lib/kramdown/converter/syntax_highlighter/coderay.rb#123
    def options(converter, type); end

    # source://kramdown-syntax-coderay//lib/kramdown/converter/syntax_highlighter/coderay.rb#128
    def prepare_options(converter); end
  end
end

# source://kramdown-syntax-coderay//lib/kramdown/converter/syntax_highlighter/coderay.rb#106
Kramdown::Converter::SyntaxHighlighter::Coderay::VERSION = T.let(T.unsafe(nil), String)

# source://kramdown-syntax-coderay//lib/kramdown/converter/syntax_highlighter/coderay.rb#16
module Kramdown::Options
  class << self
    # source://kramdown/2.4.0/lib/kramdown/options.rb#72
    def defaults; end

    # source://kramdown/2.4.0/lib/kramdown/options.rb#51
    def define(name, type, default, desc, &block); end

    # source://kramdown/2.4.0/lib/kramdown/options.rb#67
    def defined?(name); end

    # source://kramdown/2.4.0/lib/kramdown/options.rb#62
    def definitions; end

    # source://kramdown/2.4.0/lib/kramdown/options.rb#82
    def merge(hash); end

    # source://kramdown/2.4.0/lib/kramdown/options.rb#96
    def parse(name, data); end

    # source://kramdown/2.4.0/lib/kramdown/options.rb#141
    def simple_array_validator(val, name, size = T.unsafe(nil)); end

    # source://kramdown/2.4.0/lib/kramdown/options.rb#158
    def simple_hash_validator(val, name); end

    # source://kramdown/2.4.0/lib/kramdown/options.rb#122
    def str_to_sym(data); end
  end
end