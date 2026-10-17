# location_button

A Flutter plugin providing system-trusted location buttons:
* **Android 17+**: Native system-rendered `LocationButton` (`androidx.core.locationbutton`) that grants session-scoped precise location permission with zero dialog friction.
* **Earlier Android versions**: Automatically falls back to a compliant button widget and triggers the standard Android runtime permission flow.

---

## Installation

Add `location_button` to your `pubspec.yaml` by running:

```bash
flutter pub add location_button
```

Or add it directly to your `pubspec.yaml`:

```yaml
dependencies:
  location_button: ^0.1.0
```

---

## Android Permission Setup

In your `android/app/src/main/AndroidManifest.xml`, add the required location permissions inside the `<manifest>` tag:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

    <!-- Declare location permissions -->
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
    <uses-permission
        android:name="android.permission.ACCESS_FINE_LOCATION"
        android:usesPermissionFlags="onlyForLocationButton" />
    <uses-permission android:name="android.permission.USE_LOCATION_BUTTON" />

    <application
        ...
    </application>
</manifest>
```

> **How it works:**
> - **Android 17+**: The system-trusted `LocationButton` (`androidx.core.locationbutton.LocationButton`) grants session-scoped precise location permission immediately upon user tap without displaying a runtime permission dialog.
> - **Android < 17**: The plugin automatically falls back to a standard button and launches the Android runtime permission dialog for `ACCESS_FINE_LOCATION` / `ACCESS_COARSE_LOCATION`.

---

## Usage

### 1. Basic Usage

```dart
import 'package:flutter/material.dart';
import 'package:location_button/location_button.dart';

class MyLocationWidget extends StatefulWidget {
  const MyLocationWidget({super.key});

  @override
  State<MyLocationWidget> createState() => _MyLocationWidgetState();
}

class _MyLocationWidgetState extends State<MyLocationWidget> {
  bool? _isGranted;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: LocationButton(
        width: 240,
        height: 48,
        onPermissionResult: (bool granted) {
          setState(() {
            _isGranted = granted;
          });
          if (granted) {
            print('Location permission granted!');
          } else {
            print('Location permission denied.');
          }
        },
        onPermissionError: (LocationButtonException error) {
          print('Error: ${error.code} - ${error.message}');
        },
      ),
    );
  }
}
```

---

### 2. Custom Styling & Options

You can customize the button colors, corner radius, and label text using `LocationButtonOptions` and `AndroidLocationButtonOptions`:

```dart
LocationButton(
  width: double.maxFinite,
  height: 48,
  options: const LocationButtonOptions(
    android: AndroidLocationButtonOptions(
      text: AndroidLocationButtonText.usePreciseLocation,
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      cornerRadius: 16.0,
    ),
  ),
  onPermissionResult: (granted) {
    if (granted) {
      // Handle granted state
    }
  },
  onPermissionError: (error) {
    debugPrint('Error: ${error.code}: ${error.message}');
  },
)
```

---

### 3. Fetching Location

This plugin focuses on system-trusted permission authorization via the native button. Once `onPermissionResult` returns `true`, you can retrieve the current device position using any location package (such as `geolocator`):

```dart
LocationButton(
  onPermissionResult: (bool granted) async {
    if (granted) {
      // Use geolocator to fetch the current GPS position
      final position = await Geolocator.getCurrentPosition();
      print('Coordinates: ${position.latitude}, ${position.longitude}');
    }
  },
  onPermissionError: (error) {
    print('Permission error: ${error.message}');
  },
)
```

---

## API Reference

### `LocationButton` Properties

| Property | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `width` | `double` | `240` | The button width in logical pixels. |
| `height` | `double` | `48` | The button height in logical pixels. |
| `options` | `LocationButtonOptions` | `const LocationButtonOptions()` | Platform-specific styling and configuration options. |
| `onPermissionResult` | `ValueChanged<bool>?` | `null` | Callback invoked when the user taps the button and permission is resolved (`true` if granted, `false` if denied). |
| `onPermissionError` | `ValueChanged<LocationButtonException>?` | `null` | Callback invoked when an error occurs natively. |

### `AndroidLocationButtonOptions` Properties

| Property | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `text` | `AndroidLocationButtonText` | `usePreciseLocation` | Text label displayed on the Android system button. |
| `backgroundColor` | `Color?` | `null` | Button background color. |
| `foregroundColor` | `Color?` | `null` | Button text and icon color. |
| `cornerRadius` | `double?` | `null` | Corner radius in logical pixels. |

### `AndroidLocationButtonText` Enum

| Value | Displayed Text |
| :--- | :--- |
| `AndroidLocationButtonText.none` | Icon only (no text label). |
| `AndroidLocationButtonText.preciseLocation` | "Precise location" |
| `AndroidLocationButtonText.usePreciseLocation` | "Use precise location" (default) |
| `AndroidLocationButtonText.sharePreciseLocation` | "Share precise location" |
| `AndroidLocationButtonText.nearMyPreciseLocation` | "Near my precise location" |
| `AndroidLocationButtonText.nearYourPreciseLocation` | "Near your precise location" |

---

## License

MIT License.
