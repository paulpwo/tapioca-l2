package me.anharu.video_editor

import android.app.Activity
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import com.daasuu.mp4compose.composer.Mp4Composer
import com.daasuu.mp4compose.filter.*
import me.anharu.video_editor.filter.GlImageOverlayFilter
import me.anharu.video_editor.filter.GlImageOverlayFilterFull
import me.anharu.video_editor.ImageOverlay
import me.anharu.video_editor.ImageOverlayFull
import io.flutter.plugin.common.MethodChannel.Result
import android.graphics.Paint.Align
import android.graphics.Paint.ANTI_ALIAS_FLAG
import android.util.EventLog
import com.daasuu.mp4compose.VideoFormatMimeType
import io.flutter.plugin.common.EventChannel
import me.anharu.video_editor.filter.GlColorBlendFilter
import me.anharu.video_editor.filter.GlTextOverlayFilter
import java.util.logging.StreamHandler


interface VideoGeneratorServiceInterface {
    fun writeVideofile(processing: HashMap<String,HashMap<String,Any>>, result: Result, activity: Activity, eventSink: EventChannel.EventSink, startTime: Long, endTime: Long);
}

class VideoGeneratorService(
        private val composer: Mp4Composer
) : VideoGeneratorServiceInterface {
    override fun writeVideofile(processing: HashMap<String,HashMap<String,Any>>, result: Result, activity: Activity, eventSink: EventChannel.EventSink,  startTime: Long, endTime: Long) {
                 val filters: MutableList<GlFilter> = mutableListOf()
        try {
            processing.forEach { (k, v) ->
                when (k) {
                    "Filter" -> {
                        val passFilter = Filter(v)
                        val filter = GlColorBlendFilter(passFilter)
                        filters.add(filter)
                    }
                    "TextOverlay" -> {
                        val textOverlay = TextOverlay(v)
                        filters.add(GlTextOverlayFilter(textOverlay))
                    }
                    "ImageOverlay" -> {
                        val imageOverlay = ImageOverlay(v)
                        filters.add(GlImageOverlayFilter(imageOverlay))
                    }
                    "ImageOverlayFull" -> {
                        val imageOverlayFull = ImageOverlayFull(v)
                        filters.add(GlImageOverlayFilterFull(imageOverlayFull))
                    }
                }
            }
        } catch (e: Exception){
            println(e)
            activity.runOnUiThread(Runnable {
                result.error("processing_data_invalid", "Processing data is invalid.", null)
            })
        }
        composer.filter(GlFilterGroup( filters))
                .trim(startTime, endTime)
                .videoFormatMimeType(VideoFormatMimeType.HEVC)
                .listener(object : Mp4Composer.Listener {
                    override fun onProgress(progress: Double) {
                        println("onProgress = " + progress)
                        activity.runOnUiThread(Runnable {
                            eventSink.success(progress)
                        })
                    }

                    override fun onCompleted() {
                        activity.runOnUiThread(Runnable {
                            result.success(null)
                        })
                    }

                    override  fun onCanceled() {
                        activity.runOnUiThread(Runnable {
                            result.error("video_processing_canceled", "Video processing is canceled.", null)
                        })
                    }

                    override fun onFailed(exception: Exception) {
                        println(exception);
                        activity.runOnUiThread(Runnable {
                            result.error("video_processing_failed", "video processing is failed.", null)

                        })
                    }
                }).start()
    }
}

