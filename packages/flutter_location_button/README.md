# flutter_location_button

A Flutter plugin providing system-trusted location buttons:
* **Android 17+**: System-rendered `LocationButton` (`androidx.core.locationbutton`) granting session-scoped location without a permission dialog. On earlier Android versions, falls back smoothly to standard runtime permission.
* **iOS 15+**: `CLLocationButton` (via `flutter_location_button_ios`).

## Federated Architecture

This plugin uses Flutter's federated plugin architecture:
* `flutter_location_button`: App-facing package
* `flutter_location_button_platform_interface`: Common platform interface
* `flutter_location_button_android`: Android implementation
* `flutter_location_button_ios`: iOS implementation

## Usage

```dart
import 'package:flutter_location_button/flutter_location_button.dart';

LocationButton(
  width: 240,
  height: 48,
  options: const LocationButtonOptions(
    backgroundColor: Colors.black,
    foregroundColor: Colors.white,
    borderRadius: 16,
    androidText: AndroidLocationButtonText.usePreciseLocation,
  ),
  onPermissionResult: (granted) {
    print('Permission granted: $granted');
  },
  onLocation: (location) {
    print('Got location: ${location.latitude}, ${location.longitude}');
  },
  onError: (error) {
    print('Error: ${error.code} - ${error.message}');
  },
)
```
