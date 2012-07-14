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
# ruboto/util/toast.rb
#
# Utility methods for doing a toast.
#
#######################################################

Java::android.content.Context.class_eval do
  def toast(text, duration=5000)
    Java::android.widget.Toast.makeText(self, text, duration).show
  end

  def toast_result(result, success, failure, duration=5000)
    toast(result ? success : failure, duration)
  end
end

