import 'package:flutter/widgets.dart';
import 'package:flutter_location_button_platform_interface/flutter_location_button_platform_interface.dart';

import 'src/android_location_button.dart';

export 'src/android_location_button.dart';
export 'src/android_location_button_options.dart';
export 'src/android_location_button_text.dart';

/// The Android implementation of [FlutterLocationButtonPlatform].
class FlutterLocationButtonAndroid extends FlutterLocationButtonPlatform {
  /// Registers this class as the default instance of [FlutterLocationButtonPlatform].
  static void registerWith() {
    FlutterLocationButtonPlatform.instance = FlutterLocationButtonAndroid();
  }

  @override
  Widget buildButton(
    BuildContext context,
    PlatformLocationButtonCreationParams params,
  ) {
    return AndroidLocationButton(params: params);
  }
}
