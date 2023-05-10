package me.anharu.video_editor.filter

import com.daasuu.mp4compose.filter.GlOverlayFilter;
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Canvas
import me.anharu.video_editor.ImageOverlayFull

class GlImageOverlayFilterFull(imageOverlay: ImageOverlayFull) : GlOverlayFilter() {
    private val imageOverlay: ImageOverlayFull = imageOverlay;

    protected override fun drawCanvas(canvas: Canvas) {
        val canvasWidth = canvas.width
        val canvasHeight = canvas.height
        // Decodificar la imagen en un objeto Bitmap
        val imageBitmap = BitmapFactory.decodeByteArray(imageOverlay.bitmap, 0, imageOverlay.bitmap.size)
        // Escalar la imagen al tamaño del canvas
        val scaledBitmap = Bitmap.createScaledBitmap(imageBitmap, canvasWidth, canvasHeight, true)
        // Dibujar la imagen en el canvas
        canvas.drawBitmap(scaledBitmap, 0f, 0f, null)

    }
}