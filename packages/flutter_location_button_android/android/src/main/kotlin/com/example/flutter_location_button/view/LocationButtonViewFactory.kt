package com.example.flutter_location_button.view

import android.content.Context
import com.example.flutter_location_button.FlutterLocationButtonPlugin
import com.example.flutter_location_button.permission.PermissionManager
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

/**
 * Factory class responsible for creating instances of [LocationButtonPlatformView].
 */
class LocationButtonViewFactory(
    private val messenger: BinaryMessenger,
    private val permissionManager: PermissionManager,
    private val plugin: FlutterLocationButtonPlugin,
) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {

    override fun create(context: Context, viewId: Int, args: Any?): PlatformView =
        LocationButtonPlatformView(
            context = context,
            viewId = viewId,
            args = args as? Map<*, *>,
            messenger = messenger,
            permissionManager = permissionManager,
            plugin = plugin,
        )
}
