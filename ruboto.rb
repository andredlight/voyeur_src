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
# ruboto.rb
#
# - Wrapper for using RubotoActivity, RubotoService, and
#     RubotoBroadcastReceiver. 
# - Provides interface for generating UI elements. 
# - Imports and configures callback classes.
#
# require this script for legacy support or require
# the individual script files.
#
#######################################################

require 'ruboto/base'
require 'ruboto/activity'
require 'ruboto/service'
require 'ruboto/broadcast_receiver'

require 'ruboto/widget'
require 'ruboto/menu'
require 'ruboto/util/stack'
require 'ruboto/util/toast'
require 'ruboto/legacy'
