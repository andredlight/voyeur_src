require 'ruboto/activity'
require 'ruboto/widget'
require 'ruboto/util/stack'
require 'ruboto/generate'

ruboto_import_widgets :TextView, :LinearLayout, :Button
java_import 'android.app.Activity'
java_import 'android.content.Intent'
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
#java_import 'android.graphics.Bitmap.CompressFormat'
java_import 'android.media.FaceDetector'
java_import 'android.graphics.Canvas'
java_import 'android.graphics.Color'
java_import 'android.graphics.Paint'
java_import 'android.graphics.PointF'
java_import 'android.graphics.Rect'
java_import 'android.view.SurfaceHolder'
java_import 'android.view.SurfaceView'
java_import 'android.view.Window'

ruboto_import_widget :SurfaceView, "android.view"

module SurfaceDraw
  def draw_on_surface(holder, point, color)
    @surface = holder.getSurface
    @surface_frame = holder.getSurfaceFrame
    @canvas = @surface.lockCanvas(@surface_frame)
    @canvas.drawCircle(point[0], point[1], 5.0, color)
    @surface.unlockCanvasAndPost(@canvas)
  end

  def setup_draw(holder)
    @surface = holder.getSurface
    @surface_frame = holder.getSurfaceFrame
    @canvas = @surface.lockCanvas(@surface_frame)
  end

  def end_draw
    @surface.unlockCanvasAndPost(@canvas)
  end
end

# The callbacks for the Edit View
class RubotoSurfaceHolderCallback
  include SurfaceDraw
  attr_accessor :point_collection

  def surfaceCreated(holder)
    Log.i("VOYEUR", "surfaceCreate called")
    setup_draw(holder)
    @mBitmap ||= BitmapFactory.decodeFile("/sdcard/123.jpg")
    @num_faces ||= 1
    @getAllFaces ||= FaceDetector::Face[@num_faces].new
    @eyesMidPts = Array.new
    @eyesDistance ||= Array.new
    @picWidth ||= @mBitmap.getWidth.to_f
    @picHeight ||= @mBitmap.getHeight.to_f
    @viewWidth = @surface_frame.width
    @viewHeight = @surface_frame.height
    @xRatio = @viewWidth / @picWidth
    @yRatio = @viewHeight / @picHeight
    @pInnerBullsEye ||= Paint.new(Paint::ANTI_ALIAS_FLAG)
    @pOuterBullsEye ||= Paint.new(Paint::ANTI_ALIAS_FLAG)
    @pInnerBullsEye.setStyle(Paint::Style::FILL)
    @pInnerBullsEye.setColor(Color::GRAY)
    @pOuterBullsEye.setStyle(Paint::Style::STROKE)
    @pOuterBullsEye.setColor(Color::GRAY) 

    if @arrayFaces
      Log.i("VOYEUR", "already detected the faces, skipping")
    else
      @arrayFaces = FaceDetector.new( @picWidth, @picHeight, @num_faces )
      @arrayFaces.findFaces(@mBitmap, @getAllFaces)
      @eyesMP = PointF.new
      @the_eyes = Array.new
      @getAllFaces.each do |face|
        Log.i("VOYEUR", "begin face detection")
        if face != nil
          Log.i("VOYEUR", "found a face!")
          face.getMidPoint(@eyesMP)
          @the_eyes << {:midpoint => @eyesMP, :eye_distance => face.eyesDistance}
        end
      end
    end
    @tmpPaint = Paint.new(Paint::ANTI_ALIAS_FLAG)
    @tmpPaint.setStyle(Paint::Style::STROKE)
    @tmpPaint.setTextAlign(Paint::Align::CENTER)
    @canvas.drawBitmap(@mBitmap, nil, Rect.new(0,0, @viewWidth, @viewHeight), @tmpPaint)
    
    @the_eyes.each do |face|
      #canvas.drawCircle(face[:midpoint].x * xRatio, face[:midpoint].y * yRatio, face[:eye_distance].to_f, pInnerBullsEye);
      #canvas.drawCircle(face[:midpoint].x * xRatio, face[:midpoint].y * yRatio, face[:eye_distance].to_f / 2, pOuterBullsEye);
      #canvas.drawCircle(face[:midpoint].x * xRatio, face[:midpoint].y * yRatio, face[:eye_distance].to_f / 3, pOuterBullsEye);
      @canvas.drawCircle(face[:midpoint].x * @xRatio, face[:midpoint].y * @yRatio, face[:eye_distance].to_f / 4, @pInnerBullsEye);
      #canvas.drawCircle(face[:midpoint].x * xRatio, face[:midpoint].y * yRatio, face[:eye_distance].to_f * 1.2, pOuterBullsEye);
      #canvas.drawCircle(face[:midpoint].x * xRatio, face[:midpoint].y * yRatio, face[:eye_distance].to_f * 1.3, pOuterBullsEye);
      #canvas.drawCircle(face[:midpoint].x * xRatio, face[:midpoint].y * yRatio, face[:eye_distance].to_f * 1.4, pOuterBullsEye);
      #canvas.drawCircle(face[:midpoint].x * xRatio, face[:midpoint].y * yRatio, face[:eye_distance].to_f * 1.5, pOuterBullsEye);
    end

    end_draw
    Log.i("VOYEUR", "canvas unlocked")
    true
  end

  def surfaceChanged(holder, format, width, height)
    Log.i("VOYEUR", "surfaceChanged called")
  end

  def surfaceDestroyed(holder)
    Log.i("VOYEUR", "surfaceDestroyed called")
  end
end

class OnTouchListener
  include SurfaceDraw
  def onTouch(view, event)
    x = event.getX
    y = event.getY
    point = [x,y]
    color = Paint.new(Paint::ANTI_ALIAS_FLAG)
    color.setStyle(Paint::Style::FILL)
    color.setColor(Color::GRAY)
    draw_on_surface(view.getHolder, point, color)
    true
  end
end

class RubotoActivity
  def self.edit(context)
    context.start_ruboto_activity("$activity_edit") do
      def on_create(bundle)
        setTitle 'Edit'
        Log.i("VOYEUR", "EDIT ACTIVITY STARTING")
        setContentView(linear_layout(:orientation => :vertical) do
          linear_layout do
            #text_view :text => "hellotext"
            button :text => "Undo All Changes", :on_click_listener => @handle_click_back
            button :text => "Save", :on_click_listener => @handle_click_save
          end
          @sv = surface_view
          @sv.setOnTouchListener OnTouchListener.new  
          @sv.setDrawingCacheEnabled(true)
          @sv.holder.add_callback RubotoSurfaceHolderCallback.new
          # Deprecated, but still required for older API version
          @sv.holder.set_type android.view.SurfaceHolder::SURFACE_TYPE_PUSH_BUFFERS
        end)
      end
      @handle_click_save = proc do |view|
        Log.i("VOYEUR", "GONNA SAVE THAT")
        savethis = @sv.getDrawingCache
        savefile = JFile.new("/sdcard/123save.jpg")
        outStream = FileOutputStream.new(savefile)
        savethis.compress(Bitmap::CompressFormat::JPEG, 100, outStream);
        outStream.flush
        outStream.close
      end
      @handle_click_back = proc do |view|
        Log.i("VOYEUR", "GONNA GO BACK")
        RubotoActivity.launch(self)
      end
    end
  end

  def self.launch(context)
    context.start_ruboto_activity("$activity_voyeur") do
      def on_create(bundle)
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