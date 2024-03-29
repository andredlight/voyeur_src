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
# ruboto/preference.rb
#
# Basic set up for preferences (activity and widgets).
#
#######################################################

require 'ruboto/activity'

java_import "android.preference.PreferenceScreen"
java_import "android.preference.Preference"
ruboto_import "org.ruboto.RubotoPreferenceActivity"
ruboto_configure_activity(RubotoPreferenceActivity)

RubotoPreferenceActivity.class_eval do
    def preference_screen(params={})
      rv = self.getPreferenceManager.createPreferenceScreen(self)
      rv.configure self, params
      @parent.addPreference(rv) if @parent
      if block_given?
        old_parent, @parent = @parent, rv
        yield
        @parent = old_parent
      end
      rv
    end

    def setup_preference_screen &block
      @preference_screen_block = block
    end

    def on_create(bundle)
      @parent = nil
      setPreferenceScreen(instance_eval &@preference_screen_block) if @preference_screen_block
      instance_eval { @finish_create_block.call } if @finish_create_block
    end
end

Preference.class_eval do
    def configure(context, params = {})
      params.each do |k, v|
        if v.is_a?(Array)
          self.send("set#{k.to_s.gsub(/(^|_)([a-z])/) { $2.upcase }}", *v)
        else
          self.send("set#{k.to_s.gsub(/(^|_)([a-z])/) { $2.upcase }}", v)
        end
      end
    end
end

#
# RubotoPreferenceActivity Preference Generation
#

def ruboto_import_preferences(*preferences)
  preferences.each { |i| ruboto_import_preference i }
end

def ruboto_import_preference(class_name, package_name="android.preference")
  klass = java_import("#{package_name}.#{class_name}") || eval("Java::#{package_name}.#{class_name}")
  return unless klass

  RubotoPreferenceActivity.class_eval "
     def #{(class_name.to_s.gsub(/([A-Z])/) { '_' + $1.downcase })[1..-1]}(params={})
        rv = #{class_name}.new self
        rv.configure self, params
        @parent.addPreference(rv) if @parent
        if block_given?
          old_parent, @parent = @parent, rv
          yield
          @parent = old_parent
        end
        rv
     end
   "
end

