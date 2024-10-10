package video.api.flutter.livestream.manager

import android.app.Activity
import android.content.Context
import android.content.pm.PackageManager
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.plugin.common.PluginRegistry

/**
 * Check if the app has the given permissions.
 * For a single permission or multiple permissions.
 */
class PermissionsManager(
    private val context: Context,
) : PluginRegistry.RequestPermissionsResultListener {
    private var uniqueRequestCode = 1

    // To request permission, we need the activity
    var activity: Activity? = null

    private val listeners = mutableMapOf<Int, IListener>()
    private fun hasPermission(permission: String) =
        ContextCompat.checkSelfPermission(context, permission) == PackageManager.PERMISSION_GRANTED

    private fun hasAllPermissions(permissions: List<String>) = permissions.all { permission ->
        ContextCompat.checkSelfPermission(
            context,
            permission
        ) == PackageManager.PERMISSION_GRANTED
    }

    private fun shouldShowRequestPermissionRationale(
        activity: Activity,
        permissions: List<String>
    ) =
        permissions.filter { permission ->
            ActivityCompat.shouldShowRequestPermissionRationale(activity, permission)
        }

    fun requestPermissions(
        permissions: List<String>,
        onAllGranted: () -> Unit,
        onShowPermissionRationale: (List<String>, () -> Unit) -> Unit,
        onAtLeastOnePermissionDenied: () -> Unit
    ) {
        activity?.let {
            requestPermissions(it, permissions, object : IListener {
                override fun onAllGranted() {
                    onAllGranted()
                }

                override fun onShowPermissionRationale(
                    permissions: List<String>,
                    onRequiredPermissionLastTime: () -> Unit
                ) {
                    onShowPermissionRationale(permissions, onRequiredPermissionLastTime)
                }

                override fun onAtLeastOnePermissionDenied() {
                    onAtLeastOnePermissionDenied()
                }
            })
        } ?: throw IllegalStateException("Missing Activity")
    }

    private fun requestPermissions(
        activity: Activity,
        permissions: List<String>,
        listener: IListener
    ) {
        val currentRequestCode = synchronized(this) {
            uniqueRequestCode++
        }
        listeners[currentRequestCode] = listener
        when {
            hasAllPermissions(permissions) -> listener.onAllGranted()
            shouldShowRequestPermissionRationale(activity, permissions).isNotEmpty() -> {
                val missingPermissions = shouldShowRequestPermissionRationale(activity, permissions)
                listener.onShowPermissionRationale(missingPermissions) {
                    ActivityCompat.requestPermissions(
                        activity,
                        missingPermissions.toTypedArray(),
                        currentRequestCode
                    )
                }
            }

            else -> ActivityCompat.requestPermissions(
                activity,
                permissions.toTypedArray(),
                currentRequestCode
            )
        }
    }

    fun requestPermission(
        permission: String,
        onGranted: () -> Unit,
        onShowPermissionRationale: (() -> Unit) -> Unit,
        onDenied: () -> Unit
    ) {
        activity?.let {
            requestPermissions(it, listOf(permission), object : IListener {
                override fun onAllGranted() {
                    onGranted()
                }

                override fun onShowPermissionRationale(
                    permissions: List<String>,
                    onRequiredPermissionLastTime: () -> Unit
                ) {
                    onShowPermissionRationale(onRequiredPermissionLastTime)
                }

                override fun onAtLeastOnePermissionDenied() {
                    onDenied()
                }
            })
        } ?: throw IllegalStateException("Missing Activity")
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<String>,
        grantResults: IntArray
    ): Boolean {
        val listener = listeners[requestCode] ?: return false
        listeners.remove(requestCode)

        if (grantResults.isEmpty()) {
            return false
        }

        grantResults.forEach {
            if (it == PackageManager.PERMISSION_GRANTED) {
                listener.onGranted(permissions[grantResults.indexOf(it)])
            } else {
                listener.onDenied(permissions[grantResults.indexOf(it)])
            }
        }

        if (grantResults.all { it == PackageManager.PERMISSION_GRANTED }) {
            listener.onAllGranted()
        } else {
            listener.onAtLeastOnePermissionDenied()
        }

        return listeners.isEmpty()
    }

    interface IListener {
        fun onAllGranted() {}
        fun onGranted(permission: String) {}
        fun onShowPermissionRationale(
            permissions: List<String>,
            onRequiredPermissionLastTime: () -> Unit
        ) {
        }

        fun onDenied(permission: String) {}
        fun onAtLeastOnePermissionDenied() {}
    }
}
