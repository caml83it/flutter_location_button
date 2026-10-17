package com.example.flutter_location_button.permission

import android.app.Activity
import io.flutter.plugin.common.PluginRegistry

/**
 * Clean Architecture interface for managing runtime location permissions.
 * Abstracts Android permission handling (especially fallback for Android < 17).
 */
interface PermissionManager : PluginRegistry.RequestPermissionsResultListener {
    fun setActivity(activity: Activity?)
    fun hasLocationPermission(): Boolean
    fun requestLocationPermission(callback: (Boolean) -> Unit)
    fun detach()
}
