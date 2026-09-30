package com.example.pext

import android.content.ContentValues
import android.content.Intent
import android.media.MediaScannerConnection
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.pext/native_downloads"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "saveToPublicDownloads" -> {
                    val bytes = call.argument<ByteArray>("bytes")
                    val fileName = call.argument<String>("fileName") ?: "documento.pdf"
                    val mimeType = call.argument<String>("mimeType") ?: "application/pdf"
                    if (bytes == null) {
                        result.error("INVALID_BYTES", "Bytes array is null", null)
                        return@setMethodCallHandler
                    }

                    try {
                        var resolvedPath: String? = null

                        // 1. Direct write to public Download folder (/storage/emulated/0/Download/)
                        try {
                            val publicDownloads = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS)
                            if (!publicDownloads.exists()) {
                                publicDownloads.mkdirs()
                            }
                            val destFile = File(publicDownloads, fileName)
                            FileOutputStream(destFile).use { out ->
                                out.write(bytes)
                                out.flush()
                            }
                            MediaScannerConnection.scanFile(this, arrayOf(destFile.absolutePath), arrayOf(mimeType), null)
                            resolvedPath = destFile.absolutePath
                        } catch (_: Exception) {
                            // Direct file write may fail on scoped storage devices without legacy flags
                        }

                        // 2. MediaStore.Downloads API (Android 10+ / API 29+)
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                            try {
                                val contentValues = ContentValues().apply {
                                    put(MediaStore.MediaColumns.DISPLAY_NAME, fileName)
                                    put(MediaStore.MediaColumns.MIME_TYPE, mimeType)
                                    put(MediaStore.MediaColumns.RELATIVE_PATH, Environment.DIRECTORY_DOWNLOADS)
                                    put(MediaStore.MediaColumns.IS_PENDING, 1)
                                }
                                val resolver = applicationContext.contentResolver
                                val uri = resolver.insert(MediaStore.Downloads.EXTERNAL_CONTENT_URI, contentValues)
                                if (uri != null) {
                                    resolver.openOutputStream(uri)?.use { out ->
                                        out.write(bytes)
                                        out.flush()
                                    }
                                    contentValues.clear()
                                    contentValues.put(MediaStore.MediaColumns.IS_PENDING, 0)
                                    resolver.update(uri, contentValues, null, null)
                                    if (resolvedPath == null) {
                                        resolvedPath = uri.toString()
                                    }
                                }
                            } catch (_: Exception) {}
                        }

                        // 3. Fallback to external files dir if both previous steps failed
                        if (resolvedPath == null) {
                            val fallbackDir = getExternalFilesDir(Environment.DIRECTORY_DOWNLOADS) ?: filesDir
                            val fallbackFile = File(fallbackDir, fileName)
                            FileOutputStream(fallbackFile).use { out ->
                                out.write(bytes)
                                out.flush()
                            }
                            resolvedPath = fallbackFile.absolutePath
                        }

                        result.success(resolvedPath)
                    } catch (e: Exception) {
                        result.error("SAVE_FAILED", e.message, null)
                    }
                }
                "scanFile" -> {
                    val path = call.argument<String>("path")
                    if (path != null) {
                        MediaScannerConnection.scanFile(this, arrayOf(path), null) { _, uri ->
                            result.success(uri?.toString() ?: path)
                        }
                    } else {
                        result.error("INVALID_PATH", "Path is null", null)
                    }
                }
                "openFile" -> {
                    val path = call.argument<String>("path")
                    val mimeType = call.argument<String>("mimeType") ?: "application/pdf"
                    if (path != null) {
                        try {
                            val uri: Uri = if (path.startsWith("content://")) {
                                Uri.parse(path)
                            } else {
                                val file = File(path)
                                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                                    FileProvider.getUriForFile(this, "${applicationContext.packageName}.fileprovider", file)
                                } else {
                                    Uri.fromFile(file)
                                }
                            }
                            val viewIntent = Intent(Intent.ACTION_VIEW).apply {
                                setDataAndType(uri, mimeType)
                                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                            }
                            val chooser = Intent.createChooser(viewIntent, "Abrir documento")
                            chooser.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                            startActivity(chooser)
                            result.success(true)
                        } catch (e: Exception) {
                            result.error("OPEN_FAILED", e.message, null)
                        }
                    } else {
                        result.error("INVALID_PATH", "Path is null", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }
}
