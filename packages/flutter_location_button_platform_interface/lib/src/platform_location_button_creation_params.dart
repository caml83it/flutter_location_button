import 'package:flutter/widgets.dart';

import 'location_button_exception.dart';

/// Parameters for creating a platform-specific location button.
class PlatformLocationButtonCreationParams {
  const PlatformLocationButtonCreationParams({
    this.onPermissionResult,
    this.onPermissionError,
    this.width = 240,
    this.height = 48,
    this.backgroundColor,
    this.foregroundColor,
    this.cornerRadius,
    this.textType,
  });

  /// Called after the user taps the button and the OS resolves permission.
  final ValueChanged<bool>? onPermissionResult;

  /// Called on native errors (permission, location provider, button session).
  final ValueChanged<LocationButtonException>? onPermissionError;

  /// Button width in logical pixels.
  final double width;

  /// Button height in logical pixels.
  final double height;

  /// Button background color.
  final Color? backgroundColor;

  /// Text + icon color.
  final Color? foregroundColor;

  /// Corner radius in logical pixels.
  final double? cornerRadius;

  /// Android only: Text type index matching `androidx.core.locationbutton.LocationButton.TEXT_TYPE_*`.
  final int? textType;

  /// Converts creation parameters to a map to be passed to native view creation.
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    if (backgroundColor != null) {
      map['backgroundColor'] = backgroundColor!.toARGB32();
    }
    if (foregroundColor != null) {
      map['foregroundColor'] = foregroundColor!.toARGB32();
    }
    if (cornerRadius != null) {
      map['cornerRadius'] = cornerRadius;
    }
    if (textType != null) {
      map['textType'] = textType;
    }

    return map;
  }
}
