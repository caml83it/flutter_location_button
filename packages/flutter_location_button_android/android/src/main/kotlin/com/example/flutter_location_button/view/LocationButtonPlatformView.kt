package com.example.flutter_location_button.view

import android.app.Activity
import android.content.Context
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.view.ContextThemeWrapper
import android.view.SurfaceView
import android.view.View
import android.view.ViewGroup
import androidx.core.locationbutton.LocationButton
import androidx.core.locationbutton.OnErrorListener
import androidx.core.locationbutton.OnPermissionResultListener
import androidx.core.locationbutton.OnRequestPermissionsListener
import com.example.flutter_location_button.FlutterLocationButtonPlugin
import com.example.flutter_location_button.model.LocationButtonConfig
import com.example.flutter_location_button.permission.PermissionManager
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView

/**
 * Presentation layer component representing the native LocationButton PlatformView.
 *
 * Responsibilities:
 * - Hosts the native Android [LocationButton] (SurfaceView-backed on Android 17+, fallback view on older).
 * - Enforces exact bounding box parity between fallback and system remote button.
 * - Bridges button interactions and permission results to Flutter via MethodChannel.
 */
class LocationButtonPlatformView(
    context: Context,
    viewId: Int,
    args: Map<*, *>?,
    messenger: BinaryMessenger,
    private val permissionManager: PermissionManager,
    private val plugin: FlutterLocationButtonPlugin,
) : PlatformView, MethodChannel.MethodCallHandler {

    private val channel = MethodChannel(messenger, "flutter_location_button_$viewId")
    private val mainHandler = Handler(Looper.getMainLooper())
    private val density = context.resources.displayMetrics.density

    private val themedContext = ContextThemeWrapper(
        plugin.activity ?: context,
        com.google.android.material.R.style.Theme_Material3_DayNight_NoActionBar
    )

    // Android 17 (API 37) SystemUI enforces minimum 4dp padding on all 4 sides for anti-tapjacking security.
    // Setting 4dp padding on button and locking local fallback bounds guarantees 1:1 visual parity with zero jumping.
    private val systemPaddingPx = kotlin.math.ceil(4f * density).toInt()

    private val button = LocationButton(themedContext).apply {
        layoutParams = ViewGroup.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT,
            ViewGroup.LayoutParams.MATCH_PARENT
        )
        setPadding(systemPaddingPx, systemPaddingPx, systemPaddingPx, systemPaddingPx)
    }

    private var currentConfig: LocationButtonConfig? = null

    init {
        channel.setMethodCallHandler(this)

        // 1. Constrain fallback button layout bounds to exactly match the system surface button padding
        val localButton = (0 until button.childCount)
            .map { button.getChildAt(it) }
            .firstOrNull { it !is SurfaceView }

        localButton?.addOnLayoutChangeListener { v, left, top, right, bottom, _, _, _, _ ->
            val parent = v.parent as? ViewGroup ?: return@addOnLayoutChangeListener
            val w = parent.width
            val h = parent.height
            if (w <= 0 || h <= 0) return@addOnLayoutChangeListener
            val targetL = systemPaddingPx
            val targetT = systemPaddingPx
            val targetR = w - systemPaddingPx
            val targetB = h - systemPaddingPx
            if (left != targetL || top != targetT || right != targetR || bottom != targetB) {
                v.layout(targetL, targetT, targetR, targetB)
            }
        }

        // 2. Apply initial configuration from Flutter
        applyConfig(LocationButtonConfig.from(args, density))

        // 3. Set hosting activity
        plugin.activity?.let { setActivity(it) }

        // 4. Manage remote session lifecycle for Android 17+
        button.addOnAttachStateChangeListener(object : View.OnAttachStateChangeListener {
            override fun onViewAttachedToWindow(v: View) {
                ensureRemoteSessionOpened()
            }

            override fun onViewDetachedFromWindow(v: View) {}
        })

        // 5. Setup permission and error callbacks
        button.setOnPermissionResultListener(object : OnPermissionResultListener {
            override fun onPermissionResult(isGranted: Boolean) = handlePermissionResult(isGranted)
        })

        // Fallback path (Android < 17): delegate runtime permission request to PermissionManager
        button.setOnRequestPermissionsListener(object : OnRequestPermissionsListener {
            override fun onRequestPermissions() {
                permissionManager.requestLocationPermission { granted ->
                    handlePermissionResult(granted)
                }
            }
        })

        button.setOnErrorListener(object : OnErrorListener {
            override fun onError(throwable: Throwable) {
                sendError("LOCATION_BUTTON_ERROR", throwable.message ?: throwable.toString())
            }
        })

        plugin.registerView(this)
    }

    fun setActivity(activity: Activity) {
        if (button.parentActivity != activity) {
            button.parentActivity = activity
        }
    }

    private fun ensureRemoteSessionOpened() {
        if (Build.VERSION.SDK_INT >= 37) {
            button.post(object : Runnable {
                override fun run() {
                    if (!button.isAttachedToWindow) return
                    @Suppress("RestrictedApi")
                    if (button.isRemoteSessionActive) return

                    var surfaceView: SurfaceView? = null
                    for (i in 0 until button.childCount) {
                        val child = button.getChildAt(i)
                        if (child is SurfaceView) {
                            surfaceView = child
                            break
                        }
                    }

                    @Suppress("DEPRECATION")
                    val token = surfaceView?.hostToken
                    if (surfaceView != null && token != null) {
                        try {
                            val method = LocationButton::class.java.getDeclaredMethod("openSession")
                            method.isAccessible = true
                            method.invoke(button)
                        } catch (_: Throwable) {
                            plugin.activity?.let { act ->
                                button.parentActivity = act
                            }
                        }
                    } else {
                        button.postDelayed(this, 50)
                    }
                }
            })
        }
    }

    private fun applyConfig(newConfig: LocationButtonConfig) {
        val oldConfig = currentConfig

        if (oldConfig?.textType != newConfig.textType && newConfig.textType != null) {
            button.setTextType(newConfig.textType)
        }
        if (oldConfig?.backgroundColor != newConfig.backgroundColor && newConfig.backgroundColor != null) {
            button.setBackgroundColor(newConfig.backgroundColor)
        }
        if (oldConfig?.foregroundColor != newConfig.foregroundColor && newConfig.foregroundColor != null) {
            button.setTextColor(newConfig.foregroundColor)
            button.setIconTint(newConfig.foregroundColor)
        }
        if (oldConfig?.cornerRadius != newConfig.cornerRadius) {
            button.setCornerRadius(newConfig.cornerRadius)
            button.setPressedCornerRadius(newConfig.cornerRadius)
        }
        if (oldConfig?.strokeColor != newConfig.strokeColor && newConfig.strokeColor != null) {
            button.setStrokeColor(newConfig.strokeColor)
        }
        if (oldConfig?.strokeWidth != newConfig.strokeWidth && newConfig.strokeWidth != null) {
            button.setStrokeWidth(newConfig.strokeWidth)
        }

        currentConfig = newConfig
    }

    private fun handlePermissionResult(granted: Boolean) {
        invoke("onPermissionResult", mapOf("granted" to granted))
    }

    private fun sendError(code: String, message: String) {
        invoke("onError", mapOf("code" to code, "message" to message))
    }

    private fun invoke(method: String, arguments: Any?) {
        mainHandler.post { channel.invokeMethod(method, arguments) }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "update" -> {
                applyConfig(LocationButtonConfig.from(call.arguments as? Map<*, *>, density))
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    override fun getView(): View = button

    override fun dispose() {
        channel.setMethodCallHandler(null)
        plugin.unregisterView(this)
    }
}
