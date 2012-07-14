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
# ruboto/broadcast_receiver.rb
#
# Basic broadcast_receiver set up and callback configuration.
#
#######################################################

require 'ruboto/base'

ruboto_import "org.ruboto.RubotoBroadcastReceiver"
RubotoBroadcastReceiver.class_eval do
    def self.new_with_callbacks &block
      (($broadcast_receiver.nil? || $broadcast_receiver.initialized) ? new : $broadcast_receiver).initialize_ruboto_callbacks &block
    end

    def initialized
      @initialized ||= false
    end

    def initialize_ruboto_callbacks &block
      instance_eval &block
      setup_ruboto_callbacks
      @initialized = true
      self
    end

    def on_receive(context, intent)
    end
end

module Ruboto
  module BroadcastReceiver
    def initialize(java_instance)
      @java_instance = java_instance
    end

    def method_missing(method, *args, &block)
      return @java_instance.send(method, *args, &block) if @java_instance.respond_to?(method)
      super
    end
  end
end
