# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Carbo** is a Flutter car rental booking app (user-facing) with GetX state management, Pusher Beams push notifications, Awesome Notifications for rich in-app alerts, KYC verification, and wallet payments. Supports English and Arabic (RTL).

## Build Commands

```bash
flutter clean && flutter pub get        # Fresh dependency install
flutter run                             # Debug run on device
flutter build apk --release             # Production APK
cd android && ./gradlew clean --no-daemon  # Clear Android build cache
```

## Architecture

### State Management: GetX
All controllers extend `GetxController` and use reactive variables (`Rx<T>`, `.obs`, `.value`). UI subscribes via `Obx()`. Never use `setState`.

### Dependency Injection
Each screen has a `*Binding` class in `lib/bindings/` that registers controllers using `Get.lazyPut()` (lazy) or `Get.put()` (immediate). Bindings must be registered in `lib/routes/route_pages.dart` before navigation.

### Navigation
Named routes defined in `lib/routes/routes.dart`. Use `Get.toNamed(Routes.xyz, arguments: {...})` and `Get.back()`. Pass data between screens via `Get.arguments`.

### API Layer
All API calls go through `RequestProcess` in `lib/base/api/method/request_process.dart`:

```dart
await RequestProcess().request<MyModel>(
  fromJson: (json) => MyModel.fromJson(json),
  apiEndpoint: ApiEndpoint.someEndpoint,
  isLoading: isLoading,        // RxBool — auto manages loading state
  method: HttpMethod.POST,
  body: {'key': 'value'},
  onSuccess: (model) { ... },  // Errors auto-handled via CustomSnackBar
);
```

For file uploads (KYC, images), add `fieldList` and `pathList` parameters. Endpoints are defined as static getters in `lib/base/api/endpoint/api_endpoint.dart`. API responses are wrapped in `{"data": {...}, "message": "...", "type": "..."}` — `ApiServices` automatically extracts `json['data']` before calling `fromJson`.

### Feature Structure
Features live in `lib/views/{feature}/` with subdirectories: `controller/`, `screen/`, `widget/`, `model/` as needed. Follow this same structure for new features.

### Design System
**Always use Carbo DS tokens. Never hardcode colors, spacing, radius, shadows, typography, gradients, or icons inline.**

```dart
import 'package:carbo/base/design_system/carbo_ds.dart';

CarboColors.primary       // brand red #E93A3A
CarboColors.background    // scaffold bg #F7F8F8
CarboColors.credit        // #21C77B (money in)
CarboColors.debit         // #E93A3A (money out)

CarboRadius.lgAll         // 16 — cards
CarboRadius.mdAll         // 12 — inputs, chips
CarboRadius.fullAll       // pill shape

CarboSpacing.x4           // 16 — standard padding
CarboSpacing.x5           // 20 — horizontal screen margin
CarboSpacing.x6           // 24 — section gaps

CarboShadow.card          // standard card shadow
CarboShadow.primaryGlow   // red glow on primary buttons

CarboTypography.titleLarge   // screen titles (use inside build() only)
CarboTypography.bodyMedium
CarboTypography.buttonLabel  // white button text

CarboGradients.primary    // red → dark red (horizontal)
CarboDuration.normal      // 200ms standard animation
```

### Models
All models use `fromJson` factory + `toJson` method. Use `?? defaultValue` for all JSON fields — never assume fields are non-null.

### Internationalization
App supports English and Arabic. Use `'key'.tr` for translated strings. Access current locale via `LocaleService.to.currentLanguageCode` and text direction via `LocaleService.to.textDirection`. Strings are defined in `lib/languages/app_translations.dart`.

### Notifications
Two-system architecture:
- **Pusher Beams** — remote FCM push from backend (Android only; iOS/APNs pending)
- **Awesome Notifications** — rich in-app UI with buttons and deep linking

Flow: Backend → Pusher FCM → `PushNotificationController` → `AwesomeNotificationService` → display. Deep-link navigation uses `MyApp.navigatorKey` (static context).

5 channels by priority: `booking_channel` (max) > `payment_channel` (high) > `chat_channel` (default) > `promo_channel` (low) > `scheduled_channel` (high, reminders).

### Logging
Use `developer.log()` for complex flow tracing and `log.i()` / `log.e()` from `basic_import.dart`. Never use `print()`.

## Known Issues & Fixes

- **`LateInitializationError` on `Get.back()`**: Replace `Get.back()` with `Navigator.of(context).pop()` in widget `onTap` handlers to avoid snackbar animation race condition.
- **`RefreshIndicator` not animating**: Do NOT use `BouncingScrollPhysics` inside a `CustomScrollView` wrapped with `RefreshIndicator`. Use `AlwaysScrollableScrollPhysics()` instead.
- **NDK conflicts**: Clear with `Remove-Item -Recurse $env:LOCALAPPDATA\Android\sdk\ndk\*`
- **API 401 errors**: Verify Bearer token is present in request headers.

## Screen-Specific Notes

### Congratulations Screen (`lib/views/congratulations/`)
- `CongratulationsButton` widget has two buttons stacked vertically:
  1. **"My Booking"** (top) — red primary button → navigates with `Get.offAllNamed(Routes.dashboardScreen)` then `Get.toNamed(Routes.historyScreen)` so back from history lands on dashboard
  2. **"Home"** (bottom) — white outlined button with red border → `Get.offAllNamed(controller.route.value)`
- `Strings.myBooking` (`appLMyBooking`) added to `strings.dart` and both EN/AR translations in `app_translations.dart`

### Booking Screen (`lib/views/booking/widget/booking_all_fields.dart`)
- `_deliveryAvailabilityBadge()` method and its call/condition have been removed from `_deliveryToggleCard`
- `_deliveryStatusBanner()` and `_statusBannerRow()` methods have been removed; the `Obx` block that called `_deliveryStatusBanner` inside `_deliveryLocationCard` is also removed

### Shared Car Summary Card (`lib/views/booking/widget/car_summary_card.dart`)
- `CarSummaryCard` is a shared public widget (takes a `CarItem`) used in both the booking and preview hero headers
- The old private `_CarSummaryCard` in `booking_mobile_screen.dart` and `_PreviewCarSummaryCard` in `preview_mobile_screen.dart` have been removed
- Preview screen imports it from `package:carbo/views/booking/widget/car_summary_card.dart` and calls `CarSummaryCard(car: Get.find<BookingController>().selectedCar)` directly — no `Builder` needed since `BookingController` is always registered before navigation to preview

## Execution Rules

- Modify only the requested code — no cleanup, refactoring, or improvements beyond scope
- Do not add comments unless explicitly asked
- Do not add extra logic, error handling, or features beyond what was requested
- always update CLAUDE.md after finish session