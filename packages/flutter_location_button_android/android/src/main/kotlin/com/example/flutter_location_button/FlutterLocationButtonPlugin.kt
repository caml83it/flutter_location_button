package com.example.flutter_location_button

import android.app.Activity
import android.content.Context
import com.example.flutter_location_button.permission.DefaultPermissionManager
import com.example.flutter_location_button.permission.PermissionManager
import com.example.flutter_location_button.view.LocationButtonPlatformView
import com.example.flutter_location_button.view.LocationButtonViewFactory
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding

/**
 * Main plugin entry point for Flutter Location Button on Android.
 *
 * Coordinates plugin lifecycle with FlutterEngine and Activity, and registers
 * [LocationButtonViewFactory] to deliver native LocationButton platform views.
 */
class FlutterLocationButtonPlugin : FlutterPlugin, ActivityAware {

    private lateinit var context: Context
    private lateinit var permissionManager: PermissionManager

    private var activityBinding: ActivityPluginBinding? = null
    private val activeViews = mutableSetOf<LocationButtonPlatformView>()

    internal val activity: Activity?
        get() = activityBinding?.activity

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        permissionManager = DefaultPermissionManager(context)

        flutterPluginBinding.platformViewRegistry.registerViewFactory(
            VIEW_TYPE,
            LocationButtonViewFactory(
                messenger = flutterPluginBinding.binaryMessenger,
                permissionManager = permissionManager,
                plugin = this,
            )
        )
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        // No top-level resources to release
    }

    // region Views Management

    fun registerView(view: LocationButtonPlatformView) {
        activeViews.add(view)
    }

    fun unregisterView(view: LocationButtonPlatformView) {
        activeViews.remove(view)
    }

    // endregion

    // region ActivityAware

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activityBinding = binding
        permissionManager.setActivity(binding.activity)
        binding.addRequestPermissionsResultListener(permissionManager)
        activeViews.forEach { it.setActivity(binding.activity) }
    }

    override fun onDetachedFromActivityForConfigChanges() = detachActivity()

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) =
        onAttachedToActivity(binding)

    override fun onDetachedFromActivity() = detachActivity()

    private fun detachActivity() {
        activityBinding?.removeRequestPermissionsResultListener(permissionManager)
        activityBinding = null
        permissionManager.detach()
    }

    // endregion

    companion object {
        const val VIEW_TYPE = "flutter_location_button_view"
    }
}
