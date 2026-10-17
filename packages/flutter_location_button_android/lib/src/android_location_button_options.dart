import 'package:flutter/widgets.dart';

import 'android_location_button_text.dart';

/// Android-specific styling and configuration options for LocationButton.
class AndroidLocationButtonOptions {
  const AndroidLocationButtonOptions({
    this.text = AndroidLocationButtonText.usePreciseLocation,
    this.backgroundColor,
    this.foregroundColor,
    this.cornerRadius,
  });

  /// Text shown on the system-rendered Location Button.
  final AndroidLocationButtonText text;

  /// Background color of the button (common across platforms).
  final Color? backgroundColor;

  /// Foreground color for text and icon (common across platforms).
  final Color? foregroundColor;

  /// Corner radius in logical pixels (common across platforms).
  final double? cornerRadius;
}
