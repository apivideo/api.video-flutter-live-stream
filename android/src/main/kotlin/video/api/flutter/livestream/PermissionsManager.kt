// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package video.api.flutter.livestream

import android.Manifest
import android.app.Activity
import android.content.pm.PackageManager
import androidx.annotation.VisibleForTesting
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.plugin.common.PluginRegistry.RequestPermissionsResultListener
import kotlin.reflect.KFunction1

class PermissionsManager(private val permissions: List<String>) {
    interface ResultCallback {
        fun onResult(errorCode: String?, errorDescription: String?)
    }

    private var ongoing = false
    fun requestPermissions(
        activity: Activity,
        permissionsRegistry: KFunction1<RequestPermissionsResultListener, Unit>,
        callback: (String?, String?) -> Unit
    ) {
        if (ongoing) {
            callback("camera_permission", "Camera permission request ongoing")
        }
        if (!hasAllPermissions(activity, permissions)) {
            permissionsRegistry(
                CameraRequestPermissionsListener(
                    object : ResultCallback {
                        override fun onResult(errorCode: String?, errorDescription: String?) {
                            ongoing = false
                            callback(errorCode, errorDescription)
                        }
                    })
            )
            ongoing = true
            ActivityCompat.requestPermissions(
                activity,
                permissions.toTypedArray(),
                CAMERA_REQUEST_ID
            )
        } else {
            // Permissions already exist. Call the callback with success.
            callback(null, null)
        }
    }

    private fun hasAllPermissions(activity: Activity, permissions: List<String>): Boolean {
        return permissions.all { hasPermission(activity, it) }
    }

    private fun hasPermission(activity: Activity, permission: String): Boolean {
        return (ContextCompat.checkSelfPermission(activity, permission)
                == PackageManager.PERMISSION_GRANTED)
    }

    @VisibleForTesting
    internal class CameraRequestPermissionsListener @VisibleForTesting constructor(val callback: ResultCallback) :
        RequestPermissionsResultListener {
        // There's no way to unregister permission listeners in the v1 embedding, so we'll be called
        // duplicate times in cases where the user denies and then grants a permission. Keep track of if
        // we've responded before and bail out of handling the callback manually if this is a repeat
        // call.
        var alreadyCalled = false
        override fun onRequestPermissionsResult(
            id: Int,
            permissions: Array<String>,
            grantResults: IntArray
        ): Boolean {
            if (alreadyCalled || id != CAMERA_REQUEST_ID) {
                return false
            }
            alreadyCalled = true
            val notGrantedPermission = mutableListOf<String>()
            List(grantResults.filter { result ->
                result != PackageManager.PERMISSION_GRANTED
            }.size) { index ->
                notGrantedPermission.add(permissions[index])
            }
            if (notGrantedPermission.isEmpty()) {
                callback.onResult(null, null)
            } else {
                callback.onResult(
                    "camera_permission",
                    "The user did not grant the permission(s): $notGrantedPermission"
                )
            }
            return true
        }
    }

    companion object {
        private const val CAMERA_REQUEST_ID = 9799


        fun hasCameraPermission(activity: Activity): Boolean {
            return (ContextCompat.checkSelfPermission(activity, Manifest.permission.CAMERA)
                    == PackageManager.PERMISSION_GRANTED)
        }

        fun hasMicrophonePermission(activity: Activity): Boolean {
            return (ContextCompat.checkSelfPermission(activity, Manifest.permission.RECORD_AUDIO)
                    == PackageManager.PERMISSION_GRANTED)
        }
    }
}