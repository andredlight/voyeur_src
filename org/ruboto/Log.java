/*
This file is part of com.andredlight.voyeur.

    com.andredlight.voyeur is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    com.andredlight.voyeur is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with com.andredlight.voyeur.  If not, see <http://www.gnu.org/licenses/>.
*/

package org.ruboto;

public class Log {
	public static final String TAG = "RUBOTO";

	public static void d(String message) {
		android.util.Log.d(TAG, message);
	}

	public static void i(String message) {
		android.util.Log.i(TAG, message);
	}

	public static void e(String message) {
		android.util.Log.e(TAG, message);
	}

	public static void e(String message, Throwable t) {
		android.util.Log.e(TAG, message, t);
	}

}
