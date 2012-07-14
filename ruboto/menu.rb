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

require 'ruboto/activity'

#######################################################
#
# ruboto/menu.rb
#
# Make using menus a little easier. This is still using
# handle methods and may be moved into legacy code.
#
#######################################################

module Ruboto
  module Activity
    #
    # Option Menus
    #
    def add_menu title, icon=nil, &block
      mi = @menu.add(title)
      mi.setIcon(icon) if icon
      mi.class.class_eval { attr_accessor :on_click }
      mi.on_click = block

      # Seems to be needed or the block might get cleaned up
      @all_menu_items = [] unless @all_menu_items
      @all_menu_items << mi
    end

    def handle_create_options_menu &block
      p = Proc.new do |*args|
        @menu = args[0]
        instance_eval { block.call(*args) } if block
      end
      setCallbackProc(self.class.const_get("CB_CREATE_OPTIONS_MENU"), p)

      p = Proc.new do |num, menu_item|
        # handles a problem where this is called for context items
        # TODO(uwe): Remove check for SDK version when we stop supporting api level < 11
        unless @just_processed_context_item == menu_item || (android.os.Build::VERSION::SDK_INT >= 11 && menu_item.item_id == AndroidIds.home)
          instance_eval &(menu_item.on_click)
          @just_processed_context_item = nil
          true
        else
          false
        end
      end
      setCallbackProc(self.class.const_get("CB_MENU_ITEM_SELECTED"), p)
    end

    #
    # Context Menus
    #

    def add_context_menu title, &block
      mi = @context_menu.add(title)
      mi.class.class_eval { attr_accessor :on_click }
      mi.on_click = block

      # Seems to be needed or the block might get cleaned up
      @all_menu_items = [] unless @all_menu_items
      @all_menu_items << mi
    end

    def handle_create_context_menu &block
      p = Proc.new do |*args|
        @context_menu = args[0]
        instance_eval { block.call(*args) } if block
      end
      setCallbackProc(self.class.const_get("CB_CREATE_CONTEXT_MENU"), p)

      p = Proc.new do |menu_item|
        if menu_item.on_click
          arg = menu_item
          begin
            arg = menu_item.getMenuInfo.position
          rescue
          end
          instance_eval { menu_item.on_click.call(arg) }
          @just_processed_context_item = menu_item
          true
        else
          false
        end
      end
      setCallbackProc(self.class.const_get("CB_CONTEXT_ITEM_SELECTED"), p)
    end
  end
end

