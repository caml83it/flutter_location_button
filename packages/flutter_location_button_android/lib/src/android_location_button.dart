import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_location_button_platform_interface/flutter_location_button_platform_interface.dart';

/// View type registered by the Android native side of the plugin.
const String kLocationButtonViewType = 'flutter_location_button_view';

/// System-enforced margin on Android (4dp on each side: top, bottom, left, right).
///
/// Android SystemUI enforces a strict minimum 4dp padding around the system-rendered
/// location button. To ensure that the visible button matches width and height
/// exactly, this padding is automatically compensated for on Android.
const double kAndroidSystemPadding = 4.0;

class AndroidLocationButton extends StatefulWidget {
  const AndroidLocationButton({
    super.key,
    required this.params,
  });

  final PlatformLocationButtonCreationParams params;

  @override
  State<AndroidLocationButton> createState() => _AndroidLocationButtonState();
}

class _AndroidLocationButtonState extends State<AndroidLocationButton> {
  MethodChannel? _channel;
  Map<String, dynamic>? _lastCreationParams;

  void _onPlatformViewCreated(int id) {
    final channel = MethodChannel('flutter_location_button_$id');
    channel.setMethodCallHandler(_handleNativeCall);
    _channel = channel;
    _lastCreationParams = widget.params.toMap();
  }

  Future<void> _handleNativeCall(MethodCall call) async {
    if (!mounted) return;
    final args = call.arguments as Map<dynamic, dynamic>?;
    switch (call.method) {
      case 'onPermissionResult':
        widget.params.onPermissionResult?.call(args?['granted'] == true);
      case 'onError':
        widget.params.onPermissionError?.call(LocationButtonException(
          args?['code'] as String? ?? 'UNKNOWN',
          args?['message'] as String?,
        ));
    }
  }

  @override
  void didUpdateWidget(covariant AndroidLocationButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newParams = widget.params.toMap();
    if (_lastCreationParams == null || !mapEquals(_lastCreationParams, newParams)) {
      _lastCreationParams = newParams;
      _channel?.invokeMethod<void>('update', newParams);
    }
  }

  @override
  void dispose() {
    _channel?.setMethodCallHandler(null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double extra = kAndroidSystemPadding * 2;
    return SizedBox(
      width: widget.params.width + extra,
      height: widget.params.height + extra,
      child: PlatformViewLink(
        viewType: kLocationButtonViewType,
        surfaceFactory: (context, controller) {
          return AndroidViewSurface(
            controller: controller as AndroidViewController,
            gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{
              Factory<OneSequenceGestureRecognizer>(
                EagerGestureRecognizer.new,
              ),
            },
            hitTestBehavior: PlatformViewHitTestBehavior.opaque,
          );
        },
        onCreatePlatformView: (viewParams) {
          return PlatformViewsService.initExpensiveAndroidView(
            id: viewParams.id,
            viewType: kLocationButtonViewType,
            layoutDirection:
                Directionality.maybeOf(context) ?? TextDirection.ltr,
            creationParams: widget.params.toMap(),
            creationParamsCodec: const StandardMessageCodec(),
            onFocus: () {
              viewParams.onFocusChanged(true);
            },
          )
            ..addOnPlatformViewCreatedListener(viewParams.onPlatformViewCreated)
            ..addOnPlatformViewCreatedListener(_onPlatformViewCreated)
            ..create();
        },
      ),
    );
  }
}
