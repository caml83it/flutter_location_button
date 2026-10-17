import 'package:flutter/widgets.dart';
import 'package:flutter_location_button_android/flutter_location_button_android.dart';


/// Common styling and platform-specific configuration options for [LocationButton].
class LocationButtonOptions {
  const LocationButtonOptions({
    this.android = const AndroidLocationButtonOptions(),
  });

  /// Android-specific options.
  final AndroidLocationButtonOptions android;
}

/// Alias for [LocationButtonOptions] referencing native configuration naming.
typedef LocationButtonConfig = LocationButtonOptions;
