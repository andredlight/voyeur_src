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
require 'ruboto/widget'
require 'ruboto/util/stack'
require 'ruboto/util/toast'
require 'ruboto/generate'

ruboto_import_widgets :TextView, :LinearLayout, :Button
java_import 'android.app.Activity'
java_import 'android.content.Intent'
java_import 'android.content.pm.ActivityInfo'
java_import 'android.os.Bundle'
java_import 'android.util.Log'
java_import 'android.view.View'
java_import 'android.widget.ImageView'
java_import 'android.provider.MediaStore'
java_import 'java.io.File' do |package_name, class_name|
  class_name = "JFile"
end
java_import 'java.io.FileOutputStream'
java_import 'java.io.FileNotFoundException'
java_import 'android.net.Uri'
java_import 'android.graphics.BitmapFactory'
java_import 'android.graphics.Bitmap'
java_import 'android.media.FaceDetector'
java_import 'android.graphics.Canvas'
java_import 'android.graphics.Color'
java_import 'android.graphics.Paint'
java_import 'android.graphics.PointF'
java_import 'android.graphics.Rect'
java_import 'android.view.SurfaceHolder'
java_import 'android.view.SurfaceView'
java_import 'android.view.Window'

java_import 'android.os.Debug'

ruboto_import_widget :SurfaceView, "android.view"

module SurfaceDraw
  def draw_on_surface(holder, point, color)
    setup_draw(holder)
    @canvas.drawCircle(point[0], point[1], 5.0, color)
    end_draw
  end

  def setup_draw(holder=nil)
    Log.i("VOYEUR", "setup_draw called with holder: #{holder}")
    @holder = holder if holder
    @surface = @holder.getSurface
    Log.i("VOYEUR", "surface was #{@surface.inspect}")
    @surface_frame = @holder.getSurfaceFrame
    save_file = "/sdcard/123save.jpg"
    if File.exists?(save_file)
      use_this_file = save_file
    else
      use_this_file = "/sdcard/123.jpg"
    end
    @mBitmap ||= BitmapFactory.decodeFile(use_this_file)
    @viewWidth = @surface_frame.width
    @viewHeight = @surface_frame.height
    @drawing_cache_bitmap ||= Bitmap.createBitmap(@viewWidth, @viewHeight, Bitmap::Config::ARGB_8888)
    @alt_canvas ||= Canvas.new(@drawing_cache_bitmap)
    @holder.synchronized do 
      @canvas = @holder.lockCanvas(nil)
    end
  end

  def init_drawing(holder=nil)
    @holder = holder if holder
    setup_draw(@holder)
    #detect_faces
    @alt_canvas.drawBitmap(@mBitmap, nil, Rect.new(0,0, @viewWidth, @viewHeight), @tmpPaint)
    flush_to_canvas
    end_draw
  end

  def undo_all
    init_drawing
  end

  def flush_to_canvas
    @canvas.drawBitmap(@drawing_cache_bitmap, nil, Rect.new(0,0, @viewWidth, @viewHeight), @tmpPaint) 
  end

  def end_draw
    @surface.unlockCanvasAndPost(@canvas)
  end

  def draw_over_faces
    setup_draw
    num_faces = 1
    getAllFaces = FaceDetector::Face[num_faces].new
    eyesMidPts = Array.new
    eyesDistance = Array.new
    picWidth = @mBitmap.getWidth.to_f
    picHeight = @mBitmap.getHeight.to_f
    viewWidth = @surface_frame.width
    viewHeight = @surface_frame.height
    xRatio = viewWidth / picWidth
    yRatio = viewHeight / picHeight
    arrayFaces = FaceDetector.new( picWidth, picHeight, num_faces )
    arrayFaces.findFaces(@mBitmap, getAllFaces)
    eyesMP = PointF.new
    the_eyes = Array.new
    getAllFaces.each do |face|
      Log.i("VOYEUR", "begin face detection")
      if face != nil
        Log.i("VOYEUR", "found a face!")
        @found_faces = true
        face.getMidPoint(eyesMP)
        the_eyes << {:midpoint => eyesMP, :eye_distance => face.eyesDistance}
      end
    end
    tmpPaint = Paint.new(Paint::ANTI_ALIAS_FLAG)
    tmpPaint.setStyle(Paint::Style::STROKE)
    tmpPaint.setTextAlign(Paint::Align::CENTER)
    @alt_canvas.drawBitmap(@mBitmap, nil, Rect.new(0,0, viewWidth, viewHeight), tmpPaint)

    color = Paint.new(Paint::ANTI_ALIAS_FLAG)
    color.setStyle(Paint::Style::FILL)
    color.setColor(Color::GRAY)
    the_eyes.each do |face|
      @alt_canvas.drawCircle(face[:midpoint].x * xRatio, face[:midpoint].y * yRatio, face[:eye_distance].to_f * xRatio, color);
    end
    flush_to_canvas
    end_draw
    @found_faces
  end

  def recycle
    @mBitmap.recycle
    @drawing_cache_bitmap.recycle
  end
end

# The callbacks for the Edit View
class RubotoSurfaceHolderCallback
  include SurfaceDraw
  def set_touch_listener(tl)
    @touch_listener = tl
  end

  def surfaceCreated(holder)
    Log.i("VOYEUR", "surfaceCreate called")
    # use the touch_listener to initialize the drawing surface
    @touch_listener.init_drawing(holder)
    true
  end

  def surfaceChanged(holder, format, width, height)
    Log.i("VOYEUR", "surfaceChanged called")
  end

  def surfaceDestroyed(holder)
    Log.i("VOYEUR", "surfaceDestroyed called")
    @touch_listener.recycle
    #Debug.stopAllocCounting
    #Debug.stopMethodTracing
  end
end

class OnTouchListener
  include SurfaceDraw
  attr_accessor :drawing_cache_bitmap

  def onTouch(view, event)
    Log.i("VOYEUR", "onTouch called")
    x = event.getX
    y = event.getY
    point = [x,y]
    color = Paint.new(Paint::ANTI_ALIAS_FLAG)
    color.setStyle(Paint::Style::FILL)
    color.setColor(Color::GRAY)
    setup_draw(view.getHolder)
    @alt_canvas.drawCircle(point[0], point[1], 7.0, color)
    @tmpPaint ||= Paint.new(Paint::ANTI_ALIAS_FLAG)
    @tmpPaint.setStyle(Paint::Style::STROKE)
    @tmpPaint.setTextAlign(Paint::Align::CENTER)
    flush_to_canvas
    end_draw
    Log.i("VOYEUR", "onTouch draw complete")
    true
  end
end

class RubotoActivity
  def self.edit(context)
    context.start_ruboto_activity("$activity_edit") do
      def on_create(bundle)
 
        # due to bug in ruboto activity or something this doesn't work.
        # TODO: would like to fix orientation problem in Edit Activity
        #if self.getRequestedOrientation == ActivityInfo::SCREEN_ORIENTATION_UNSPECIFIED
        #  self.setRequestedOrientation(ActivityInfo::SCREEN_ORIENTATION_PORTRAIT)
        #else
        #  self.setRequestedOrientation(self.getRequestedOrientation)
        #end

        setTitle 'Edit'
        Log.i("VOYEUR", "EDIT ACTIVITY STARTING")
        setContentView(linear_layout(:orientation => :vertical) do
          linear_layout do
            #button :text => "Menu", :on_click_listener => @handle_click_menu
            button :text => "Undo All", :on_click_listener => @handle_click_undo
            button :text => "Save", :on_click_listener => @handle_click_save
            button :text => "Face", :on_click_listener => @handle_click_face
          end
          @sv = surface_view
          @callback ||= RubotoSurfaceHolderCallback.new
          @touch_listener ||= OnTouchListener.new
          @callback.set_touch_listener(@touch_listener)
          @sv.holder.add_callback @callback
          @sv.setOnTouchListener @touch_listener
        end)
      end
      @handle_click_save = proc do |view|
        savefile = JFile.new("/sdcard/123save.jpg")
        outStream = FileOutputStream.new(savefile)
        @touch_listener.drawing_cache_bitmap.compress(Bitmap::CompressFormat::JPEG, 100, outStream);
        outStream.flush
        outStream.close
        toast "saved."
      end
      # This caused bug in orientation stuff.
      #@handle_click_menu = proc do |view|
      #  #self.setRequestedOrientation(ActivityInfo::SCREEN_ORIENTATION_USER)
      #  RubotoActivity.launch(self)
      #end
      @handle_click_face = proc do |view|
        unless @touch_listener.draw_over_faces
          toast "no face detected."
        end
      end
      @handle_click_undo = proc do |view|
        del_this = JFile.new("/sdcard/123save.jpg")
        del_this.delete
        @touch_listener.undo_all
        #RubotoActivity.launch(self)
      end
    end
  end

  def self.launch(context)
    context.start_ruboto_activity("$activity_voyeur") do
      def on_create(bundle)
        #Debug.startMethodTracing("voyeurtrace")
        #Debug.startAllocCounting
        setTitle 'Voyeur'
        setContentView(
          linear_layout(:orientation => :vertical) do
            @text_view = text_view :text => "an AndRedLight Production"
            button :text => "Capture Pic", :width => :fill_parent, :on_click_listener => @on_capture_click
            button :text => "Edit Pic", :width => :fill_parent, :on_click_listener => @on_edit_click
          end
        )
      end

      def on_activity_result(requestCode, resultCode, data)
        Log.i("VOYEUR", "back from activity camera!")
      end
      
      @on_capture_click = proc do |view|
        capture_intent = Intent.new(MediaStore::ACTION_IMAGE_CAPTURE)
        capture_intent.putExtra(MediaStore::EXTRA_OUTPUT, Uri.fromFile(JFile.new("/sdcard/123.jpg")))
        startActivityForResult(capture_intent, 1)
      end

      @on_edit_click = proc do |view|
        RubotoActivity.edit(self)
      end
    end
  end
end

RubotoActivity.launch $activity #, "$voyeur_activity"
