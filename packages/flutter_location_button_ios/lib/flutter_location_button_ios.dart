import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_location_button_platform_interface/flutter_location_button_platform_interface.dart';

export 'src/ios_location_button_options.dart';

const String _kLocationButtonViewType = 'flutter_location_button_view';

/// The iOS implementation of [FlutterLocationButtonPlatform].
class FlutterLocationButtonIOS extends FlutterLocationButtonPlatform {
  /// Registers this class as the default instance of [FlutterLocationButtonPlatform].
  static void registerWith() {
    FlutterLocationButtonPlatform.instance = FlutterLocationButtonIOS();
  }

  @override
  Widget buildButton(
    BuildContext context,
    PlatformLocationButtonCreationParams params,
  ) {
    return _IOSLocationButtonWidget(params: params);
  }
}

class _IOSLocationButtonWidget extends StatefulWidget {
  const _IOSLocationButtonWidget({required this.params});

  final PlatformLocationButtonCreationParams params;

  @override
  State<_IOSLocationButtonWidget> createState() =>
      _IOSLocationButtonWidgetState();
}

class _IOSLocationButtonWidgetState extends State<_IOSLocationButtonWidget> {
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
        widget.params.onError?.call(LocationButtonError(
          args?['code'] as String? ?? 'UNKNOWN',
          args?['message'] as String?,
        ));
    }
  }

  @override
  void didUpdateWidget(covariant _IOSLocationButtonWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newParams = widget.params.toMap();
    if (_lastCreationParams == null ||
        !mapEquals(_lastCreationParams, newParams)) {
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
    return SizedBox(
      width: widget.params.width,
      height: widget.params.height,
      child: UiKitView(
        viewType: _kLocationButtonViewType,
        creationParams: widget.params.toMap(),
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: _onPlatformViewCreated,
      ),
    );
  }
}
