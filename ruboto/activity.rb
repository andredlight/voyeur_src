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

require 'ruboto/base'
require 'ruboto/package'

#######################################################
#
# ruboto/activity.rb
#
# Basic activity set up and callback configuration.
#
#######################################################

#
# Context
#

module Ruboto
  module Context
    def initialize_ruboto()
      eval("#{$new_context_global} = self")
      $new_context_global = nil

      instance_eval &$context_init_block if $context_init_block
      $context_init_block = nil
      setup_ruboto_callbacks 

      @initialized = true
      self
    end
  
    def start_ruboto_dialog(remote_variable, theme=Java::android.R.style::Theme_Dialog, &block)
      ruboto_import "org.ruboto.RubotoDialog"
      start_ruboto_activity(remote_variable, RubotoDialog, theme, &block)
    end
  
    def start_ruboto_activity(global_variable_name = '$activity', klass=RubotoActivity, theme=nil, &block)
      $context_init_block = block
      $new_context_global = global_variable_name
  
      if @initialized or (self == $activity && !$activity.rubotoAttachable)
        b = Java::android.os.Bundle.new
        b.putInt("Theme", theme) if theme
  
        i = Java::android.content.Intent.new
        i.setClass self, klass.java_class
        i.putExtra("RubotoActivity Config", b)
  
        self.startActivity i
      else
        initialize_ruboto
        on_create nil
      end
  
      self
    end
  end
end

java_import "android.content.Context"
Context.class_eval do
  include Ruboto::Context
end

#
# Basic Activity Setup
#

module Ruboto
  module Activity
    def initialize(java_instance)
      @java_instance = java_instance
    end

    def method_missing(method, *args, &block)
      return @java_instance.send(method, *args, &block) if @java_instance.respond_to?(method)
      super
    end
  end
end
  
def ruboto_configure_activity(klass)
  klass.class_eval do
    include Ruboto::Activity
    
    # Can't be moved into the module
    def on_create(bundle)
    end
  end
end

java_import "android.app.Activity"
ruboto_import "org.ruboto.RubotoActivity"
ruboto_configure_activity(RubotoActivity)

