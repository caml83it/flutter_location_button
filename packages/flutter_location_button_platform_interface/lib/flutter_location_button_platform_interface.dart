import 'package:flutter/widgets.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'src/platform_location_button_creation_params.dart';

export 'src/location_button_exception.dart';
export 'src/platform_location_button_creation_params.dart';

/// The interface that platform-specific implementations of `flutter_location_button` must extend.
abstract class FlutterLocationButtonPlatform extends PlatformInterface {
  /// Constructs a FlutterLocationButtonPlatform.
  FlutterLocationButtonPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterLocationButtonPlatform _instance =
      _DefaultFlutterLocationButtonPlatform();

  /// The default instance of [FlutterLocationButtonPlatform] to use.
  static FlutterLocationButtonPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterLocationButtonPlatform] when
  /// they register themselves.
  static set instance(FlutterLocationButtonPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Builds the platform-specific Location Button widget.
  Widget buildButton(
    BuildContext context,
    PlatformLocationButtonCreationParams params,
  ) {
    return const SizedBox.shrink();
  }
}

class _DefaultFlutterLocationButtonPlatform extends FlutterLocationButtonPlatform {}
