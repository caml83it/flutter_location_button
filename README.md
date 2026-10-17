# Flutter Location Button (Federated Plugin)

Mô hình Federated Plugin cho Flutter Location Button, cho phép sử dụng nút vị trí cấp hệ thống (system-trusted location button):
- **Android 17+**: Nút `androidx.core.locationbutton.LocationButton` tích hợp sẵn, hỗ trợ fallback mượt mà cho các phiên bản Android cũ hơn qua runtime permission.
- **iOS 15+**: `CLLocationButton` (sẵn sàng qua package iOS).

## Cấu trúc Packages

Dự án được tổ chức theo chuẩn kiến trúc Federated Plugin của Flutter trong thư mục `packages/`:

| Package | Đường dẫn | Mô tả |
| :--- | :--- | :--- |
| **`flutter_location_button`** | [`packages/flutter_location_button`](file:///Users/caml83it/.gemini/antigravity-ide/scratch/flutter_location_button/packages/flutter_location_button) | **App-facing package** - Package chính được cài đặt vào app Flutter của người dùng (`LocationButton`, `FlutterLocationButton`). Chứa thư mục `example/`. |
| **`flutter_location_button_platform_interface`** | [`packages/flutter_location_button_platform_interface`](file:///Users/caml83it/.gemini/antigravity-ide/scratch/flutter_location_button/packages/flutter_location_button_platform_interface) | **Platform Interface** - Định nghĩa các models (`LocationButtonException`), enums, base class `FlutterLocationButtonPlatform` và creation params. |
| **`flutter_location_button_android`** | [`packages/flutter_location_button_android`](file:///Users/caml83it/.gemini/antigravity-ide/scratch/flutter_location_button/packages/flutter_location_button_android) | **Android Implementation** - Triển khai native Kotlin trên Android 17+, AndroidView surface, SystemUI padding compensation (4dp). |
| **`flutter_location_button_ios`** | [`packages/flutter_location_button_ios`](file:///Users/caml83it/.gemini/antigravity-ide/scratch/flutter_location_button/packages/flutter_location_button_ios) | **iOS Implementation (Scaffold)** - Triển khai mã nguồn Swift, UiKitView và CLLocationButton sẵn sàng để kích hoạt/phát triển khi mở rộng iOS. |

## Chạy kiểm thử (Unit Tests)

1. **Platform Interface**:
   ```bash
   cd packages/flutter_location_button_platform_interface && flutter test
   ```

2. **Android Package**:
   ```bash
   cd packages/flutter_location_button_android && flutter test
   cd packages/flutter_location_button_android/android && ./gradlew testDebugUnitTest
   ```

3. **App-facing Package**:
   ```bash
   cd packages/flutter_location_button && flutter test
   ```

4. **Example App**:
   ```bash
   cd packages/flutter_location_button/example && flutter test
   cd packages/flutter_location_button/example && flutter build apk --debug
   ```
