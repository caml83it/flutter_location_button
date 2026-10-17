import CoreLocation
import CoreLocationUI
import Flutter
import UIKit

public class FlutterLocationButtonPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let factory = FlutterLocationButtonViewFactory(messenger: registrar.messenger())
    registrar.register(factory, withId: "flutter_location_button_view")
  }
}

// MARK: - Helpers

func isAuthorized(_ status: CLAuthorizationStatus) -> Bool {
  return status == .authorizedWhenInUse || status == .authorizedAlways
}

private extension UIColor {
  convenience init(argb: Int64) {
    let a = CGFloat((argb >> 24) & 0xFF) / 255.0
    let r = CGFloat((argb >> 16) & 0xFF) / 255.0
    let g = CGFloat((argb >> 8) & 0xFF) / 255.0
    let b = CGFloat(argb & 0xFF) / 255.0
    self.init(red: r, green: g, blue: b, alpha: a)
  }
}

private func colorArg(_ value: Any?) -> UIColor? {
  if let n = value as? NSNumber { return UIColor(argb: n.int64Value) }
  return nil
}

// MARK: - Platform view

class FlutterLocationButtonViewFactory: NSObject, FlutterPlatformViewFactory {
  private let messenger: FlutterBinaryMessenger

  init(messenger: FlutterBinaryMessenger) {
    self.messenger = messenger
    super.init()
  }

  func create(
    withFrame frame: CGRect,
    viewIdentifier viewId: Int64,
    arguments args: Any?
  ) -> FlutterPlatformView {
    return FlutterLocationButtonView(
      frame: frame,
      viewIdentifier: viewId,
      arguments: args,
      binaryMessenger: messenger
    )
  }

  func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
    return FlutterStandardMessageCodec.sharedInstance()
  }
}

class FlutterLocationButtonView: NSObject, FlutterPlatformView, CLLocationManagerDelegate {
  private let containerView: UIView
  private let channel: FlutterMethodChannel
  private let locationManager = CLLocationManager()
  private let button: CLLocationButton
  /// True between a button tap and the resulting authorization change.
  private var awaitingAuthorization = false

  init(
    frame: CGRect,
    viewIdentifier viewId: Int64,
    arguments args: Any?,
    binaryMessenger messenger: FlutterBinaryMessenger
  ) {
    channel = FlutterMethodChannel(name: "flutter_location_button_\(viewId)", binaryMessenger: messenger)
    containerView = UIView(frame: frame)
    button = CLLocationButton(frame: containerView.bounds)
    super.init()

    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyBest

    button.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    button.icon = .arrowFilled
    button.label = .currentLocation
    button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
    containerView.addSubview(button)

    applyArgs(args as? [String: Any])

    channel.setMethodCallHandler { [weak self] call, result in
      switch call.method {
      case "update":
        self?.applyArgs(call.arguments as? [String: Any])
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  deinit {
    channel.setMethodCallHandler(nil)
  }

  func view() -> UIView {
    return containerView
  }

  private func applyArgs(_ args: [String: Any]?) {
    guard let args = args else { return }

    if let icon = args["iosIcon"] as? Int {
      switch icon {
      case 0: button.icon = .none
      case 1: button.icon = .arrowFilled
      case 2: button.icon = .arrowOutline
      default: break
      }
    }

    if let label = args["iosLabel"] as? Int {
      switch label {
      case 0: button.label = .none
      case 1: button.label = .currentLocation
      case 2: button.label = .sendCurrentLocation
      case 3: button.label = .sendMyCurrentLocation
      case 4: button.label = .shareCurrentLocation
      case 5: button.label = .shareMyCurrentLocation
      default: break
      }
    }

    if let radius = args["cornerRadius"] as? NSNumber {
      button.cornerRadius = CGFloat(radius.doubleValue)
    }
    if let fontSize = args["fontSize"] as? NSNumber {
      button.fontSize = CGFloat(fontSize.doubleValue)
    }
    if let bg = colorArg(args["backgroundColor"]) {
      button.backgroundColor = bg
    }
    // tintColor drives both the icon and the label color.
    if let fg = colorArg(args["foregroundColor"]) {
      button.tintColor = fg
    }
  }

  @objc private func didTapButton() {
    // Tapping CLLocationButton grants one-time "When In Use" authorization.
    if isAuthorized(locationManager.authorizationStatus) {
      onAuthorized()
    } else {
      awaitingAuthorization = true
    }
  }

  private func onAuthorized() {
    channel.invokeMethod("onPermissionResult", arguments: ["granted": true])
  }

  func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    guard awaitingAuthorization else { return }
    let status = manager.authorizationStatus
    if status == .notDetermined { return }
    awaitingAuthorization = false
    if isAuthorized(status) {
      onAuthorized()
    } else {
      channel.invokeMethod("onPermissionResult", arguments: ["granted": false])
    }
  }

  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    channel.invokeMethod("onError", arguments: [
      "code": "LOCATION_ERROR",
      "message": error.localizedDescription,
    ])
  }
}
