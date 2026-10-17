import 'package:flutter/widgets.dart';
import 'package:flutter_location_button_platform_interface/flutter_location_button_platform_interface.dart';

import 'location_button_options.dart';

export 'location_button_options.dart';

/// A system-trusted location button.
///
/// * Android 17+ : system-rendered Location Button (`androidx.core.locationbutton`),
///   which grants session-scoped precise location without a permission dialog.
///   Older Android versions fall back to a local button + runtime permission.
/// * iOS 15+ : `CLLocationButton`, which grants one-time location authorization.
class LocationButton extends StatelessWidget {
  const LocationButton({
    super.key,
    this.width = 240,
    this.height = 48,
    this.options = const LocationButtonOptions(),
    this.onPermissionResult,
    this.onPermissionError,
  });

  /// Button width in logical pixels.
  final double width;

  /// Button height in logical pixels.
  final double height;

  /// Style and configuration options for the button.
  final LocationButtonOptions options;

  /// Called after the user taps the button and the OS resolves permission.
  final ValueChanged<bool>? onPermissionResult;

  /// Called on native errors (permission, location provider, button session).
  final ValueChanged<LocationButtonException>? onPermissionError;

  @override
  Widget build(BuildContext context) {
    final params = PlatformLocationButtonCreationParams(
      width: width,
      height: height,
      backgroundColor: options.android.backgroundColor,
      foregroundColor: options.android.foregroundColor,
      cornerRadius: options.android.cornerRadius,
      textType: options.android.text.index,
      onPermissionResult: onPermissionResult,
      onPermissionError: onPermissionError,
    );
    return FlutterLocationButtonPlatform.instance.buildButton(context, params);
  }
}
