package com.example.flutter_location_button.permission

import android.Manifest
import android.app.Activity
import android.content.Context
import android.content.pm.PackageManager
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat

/**
 * Concrete implementation of [PermissionManager].
 * Handles Android runtime permission checks and launches permission requests when the button
 * operates on legacy Android versions without system-rendered LocationButton.
 */
class DefaultPermissionManager(
    private val context: Context,
) : PermissionManager {

    private var activity: Activity? = null
    private var pendingCallback: ((Boolean) -> Unit)? = null

    override fun setActivity(activity: Activity?) {
        this.activity = activity
    }

    override fun hasLocationPermission(): Boolean {
        val fineGranted = ContextCompat.checkSelfPermission(
            context,
            Manifest.permission.ACCESS_FINE_LOCATION
        ) == PackageManager.PERMISSION_GRANTED

        val coarseGranted = ContextCompat.checkSelfPermission(
            context,
            Manifest.permission.ACCESS_COARSE_LOCATION
        ) == PackageManager.PERMISSION_GRANTED

        return fineGranted || coarseGranted
    }

    override fun requestLocationPermission(callback: (Boolean) -> Unit) {
        if (hasLocationPermission()) {
            callback(true)
            return
        }

        val act = activity
        if (act == null) {
            callback(false)
            return
        }

        pendingCallback = callback
        ActivityCompat.requestPermissions(
            act,
            arrayOf(
                Manifest.permission.ACCESS_FINE_LOCATION,
                Manifest.permission.ACCESS_COARSE_LOCATION
            ),
            PERMISSION_REQUEST_CODE
        )
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ): Boolean {
        if (requestCode != PERMISSION_REQUEST_CODE) return false
        val granted = grantResults.any { it == PackageManager.PERMISSION_GRANTED }
        pendingCallback?.invoke(granted)
        pendingCallback = null
        return true
    }

    override fun detach() {
        activity = null
        pendingCallback?.invoke(false)
        pendingCallback = null
    }

    companion object {
        private const val PERMISSION_REQUEST_CODE = 0x4C42 // "LB"
    }
}
