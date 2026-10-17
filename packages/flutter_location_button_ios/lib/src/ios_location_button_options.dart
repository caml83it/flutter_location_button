/// Label shown on the iOS `CLLocationButton`.
enum IOSLocationButtonLabel {
  none,
  currentLocation,
  sendCurrentLocation,
  sendMyCurrentLocation,
  shareCurrentLocation,
  shareMyCurrentLocation,
}

/// Icon shown on the iOS `CLLocationButton`.
enum IOSLocationButtonIcon {
  none,
  arrowFilled,
  arrowOutline,
}

/// iOS-specific styling and configuration options for LocationButton.
class IOSLocationButtonOptions {
  const IOSLocationButtonOptions({
    this.label = IOSLocationButtonLabel.currentLocation,
    this.icon = IOSLocationButtonIcon.arrowFilled,
    this.fontSize,
  });

  /// Label style on CLLocationButton.
  final IOSLocationButtonLabel label;

  /// Icon style on CLLocationButton.
  final IOSLocationButtonIcon icon;

  /// Font size for label in logical pixels.
  final double? fontSize;
}
