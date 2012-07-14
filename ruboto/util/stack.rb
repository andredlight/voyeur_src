# This file is part of com.andredlight.voyeur.
#
#    com.andredlight.voyeur is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    com.andredlight.voyeur is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with com.andredlight.voyeur.  If not, see <http://www.gnu.org/licenses/>.

#######################################################
#
# ruboto/util/stack.rb
#
# Utility methods for running code in a separate 
# thread with a larger stack.
#
#######################################################

class Object
  def with_large_stack(opts = {}, &block)
    opts = {:size => opts} if opts.is_a? Integer
    opts = {:name => 'Block with large stack'}.update(opts)
    exception = nil
    result = nil
    t = Thread.with_large_stack(opts, &proc{result = block.call rescue exception = $!})
    t.join
    raise exception if exception
    result
  end
end

class Thread
  def self.with_large_stack(opts = {}, &block)
    opts = {:size => opts} if opts.is_a? Integer
    stack_size_kb = opts.delete(:size) || 64
    name = opts.delete(:name) || "Thread with large stack"
    raise "Unknown option(s): #{opts.inspect}" unless opts.empty?
    t = java.lang.Thread.new(nil, block, name, stack_size_kb * 1024)
    t.start
    t
  end
end

