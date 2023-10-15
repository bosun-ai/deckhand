# typed: true

# DO NOT EDIT MANUALLY
# This is an autogenerated file for types exported from the `sorted_set` gem.
# Please instead update this file by running `bin/tapioca gem sorted_set`.

# SortedSet implements a Set whose elements are sorted in ascending
# order (according to the return values of their `<=>` methods) when
# iterating over them.
#
# Every element in SortedSet must be *mutually comparable* to every
# other: comparison with `<=>` must not return nil for any pair of
# elements.  Otherwise ArgumentError will be raised.
#
# ## Example
#
# ```ruby
# require "sorted_set"
#
# set = SortedSet.new([2, 1, 5, 6, 4, 5, 3, 3, 3])
# ary = []
#
# set.each do |obj|
#   ary << obj
# end
#
# p ary # => [1, 2, 3, 4, 5, 6]
#
# set2 = SortedSet.new([1, 2, "3"])
# set2.each { |obj| } # => raises ArgumentError: comparison of Fixnum with String failed
# ```
#
# source://sorted_set//lib/sorted_set.rb#51
class SortedSet < ::Set
  # Creates a SortedSet.  See Set.new for details.
  #
  # @return [SortedSet] a new instance of SortedSet
  #
  # source://sorted_set//lib/sorted_set.rb#53
  def initialize(*args); end
end
