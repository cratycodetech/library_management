package com.example.library_app

import android.database.Cursor
import android.net.Uri
import android.provider.MediaStore
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "file_provider"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getRealPath") {
                val uri: String? = call.argument("uri")
                val path = uri?.let { getRealPathFromUri(it) }
                result.success(path)
            } else {
                result.notImplemented()
            }
        }
    }

    private fun getRealPathFromUri(uriString: String): String? {
        val uri = Uri.parse(uriString)
        var result: String? = null

        val projection = arrayOf(MediaStore.Images.Media.DATA)
        val cursor: Cursor? = contentResolver.query(uri, projection, null, null, null)

        cursor?.use {
            if (it.moveToFirst()) {
                val columnIndex = it.getColumnIndexOrThrow(MediaStore.Images.Media.DATA)
                result = it.getString(columnIndex)
            }
        }

        return result
    }
}