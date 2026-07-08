# Car Booking Calculation Flow - Complete Guide

## High-Level Flow Diagram

```
Dashboard (Car Selection)
       ↓
Booking Screen (Form Input)
  ├─ selectedCar
  ├─ rentalDays
  ├─ pickupDate/Time
  ├─ roundPickupDate/Time
  └─ deliveryLocation
       ↓
Preview Screen (API Calculation)
  ├─ GET /api/v1/user/car-booking/preview
  └─ Response: PricingBreakdown
       ↓
Calculate Total
  ├─ rentalFees (backend calculated)
  ├─ deliveryPrice
  ├─ charges (if any)
  ├─ tax (rentalFees + delivery) × taxPercentage
  └─ total
       ↓
Payment/Confirmation
```

---

## 1. BOOKING FORM DATA (BookingController)

**Location:** `lib/views/booking/controller/booking_controller.dart`

### Input Fields Collected:
```dart
dateController            // Not used directly
timeController            // Not used directly
rentalDaysController      // e.g., "3" days
selectedPickupDate        // e.g., "2026-02-15"
selectedPickupTime        // e.g., "10:00 AM"
selectedRoundDate         // Optional: return date for round trip
selectedRoundTime         // Optional: return time for round trip
selectedCar               // CarItem with pricing info
```

### Delivery State:
```dart
isPickupFromBranch        // true = pickup at branch, false = delivery to location
selectedDeliveryLocation  // LatLng of custom delivery
deliveryCheckResult       // API validation of delivery feasibility
forcePickupFromBranch     // true if delivery unavailable OR datetime invalid
```

### Key Getters:
```dart
deliveryPriceValue       // Double from selectedCar.deliveryPrice
isDeliveryEnabled        // true if (!isPickupFromBranch && deliveryCheckResult?.allowed)
canConfirmBooking        // true if form valid && delivery available
```

---

## 2. PREVIEW API REQUEST (PreviewController.getPreviewData())

**Endpoint:** `POST /api/v1/user/car-booking/preview`

### Query Parameters Built:
```dart
Map<String, String> queryParams = {
  'car_id': bookingController.selectedCar.id,
  'car_type': bookingController.selectedCar.carType!.id,  // Optional
  'rental_days': bookingController.rentalDaysController.text,
  'pickup_date': bookingController.selectedPickupDate.value,
  'pickup_time': bookingController.selectedPickupTime.value,
  'include_delivery': (deliveryPrice > 0).toString(),
  'delivery_price': deliveryPrice.toString(),
  'pickup_location[latitude]': pickupLocation.latitude.toString(),
  'pickup_location[longitude]': pickupLocation.longitude.toString(),
  'pickup_location[address]': pickupLocation.address,
};
```

### Request Code:
```dart
RequestProcess().request<BookingPreviewModel>(
  queryParams: queryParams,
  fromJson: BookingPreviewModel.fromJson,
  apiEndpoint: ApiEndpoint.getBookingPreview,
  isLoading: _isLoading,
  showErrorMessage: false,
  onSuccess: (value) {
    _bookingPreviewModel = value;
    _getPreviewALlData();  // Extract & display data
  },
);
```

---

## 3. PRICING BREAKDOWN MODEL

**Location:** `lib/views/preview/model/booking_preview_model.dart`

### PricingBreakdown Class:
```dart
class PricingBreakdown {
  int rentalDays;           // e.g., 3
  String rentalFees;        // e.g., "300.00" — base rental cost
  String deliveryPrice;     // e.g., "50.00" — delivery/pickup cost
  String charges;           // e.g., "10.00" — additional charges
  String subtotal;          // e.g., "360.00" — rental + delivery + charges
  double taxPercentage;     // e.g., 15.0 (%)
  String taxAmount;         // e.g., "54.00" — tax calculated
  String total;             // e.g., "414.00" — final amount
  String priceRuleApplied;  // e.g., "daily", "weekly", "monthly"
  double taxRate;           // Same as taxPercentage or alternative format
}
```

### Backend Calculation (Server-Side):
```
rentalFees = rentalDays × dailyRate (or weekly/monthly rule)
subtotal = rentalFees + deliveryPrice + charges
taxAmount = (rentalFees + deliveryPrice) × (taxPercentage / 100)
total = rentalFees + deliveryPrice + charges + taxAmount
```

---

## 4. FRONTEND TAX RECALCULATION (PreviewController._getPreviewALlData())

After API response, the app **recalculates** tax to handle delivery price overrides:

```dart
void _getPreviewALlData() {
  final pricing = model.data.pricingBreakdown;
  
  // If user has delivery enabled, override backend's delivery price
  final deliveryPrice = _deliveryPriceForBooking(bookingController);
  if (deliveryPrice > 0) {
    pricing.deliveryPrice = deliveryPrice.toStringAsFixed(2);
    // If backend's deliveryPrice was 0, add to total
    if (previewDeliveryPrice == 0) {
      totalPayable.value += deliveryPrice;
    }
  } else {
    pricing.deliveryPrice = '0.00';
  }
  
  // Recalculate tax on (rental + delivery)
  final rentalFees = double.tryParse(pricing.rentalFees) ?? 0.0;
  final effectiveDelivery = double.tryParse(pricing.deliveryPrice) ?? 0.0;
  final taxPct = pricing.taxPercentage;
  final computedTax = (rentalFees + effectiveDelivery) * taxPct / 100;
  
  taxAmountDisplay.value = computedTax.toStringAsFixed(2);
  totalPayable.value = rentalFees + effectiveDelivery + computedTax;
}
```

### Key Point:
**Tax is NOT recalculated on charges.** Only rental fees + delivery are taxed.

---

## 5. PREVIEW SCREEN DISPLAY

**Location:** `lib/views/preview/widget/preview_section_card.dart`

### _PricingCard Widget Shows:

| Item | Display | Value from | Notes |
|------|---------|-----------|-------|
| Rental Days | "Rental Days" | `pricingBreakdown.rentalDays` | Count only |
| Rental Fees | Label: "Rental Fees" | `pricingBreakdown.rentalFees` | Base rental |
| Delivery | Label: "Delivery" | `pricingBreakdown.deliveryPrice` | Only if > 0 |
| Charges | Label: "Charges" | `pricingBreakdown.charges` | Only if > 0 |
| Tax | Label: "Tax" | `controller.taxAmountDisplay` | Recalculated value |
| **Total** | **Gradient red box** | `controller.totalPayable` | **Final amount** |

### Pricing Row Component:
```dart
_PricingRow(
  label: "Rental Fees",
  value: "300.00",
  currency: "SAR",
);
// Output: "Rental Fees                 300.00 SAR"
```

---

## 6. CONFIRM BOOKING PROCESS

**Location:** `lib/views/preview/controller/preview_controller.dart`

After user confirms, the controller sends **new booking confirm request** (NOT a preview):

### Endpoint: `POST /api/v1/user/car-booking/confirm`

### Request Body:
```dart
Map<String, dynamic> inputBody = {
  'car_id': carId,
  'car_slug': carSlugValue,
  'location': locationDisplay,
  'rental_days': rentalDays,
  'pickup_location': pickupLocationJson,
  'pickup_date': selectedPickupDate,
  'pickup_time': selectedPickupTime,
  'credentials': email,
  'mobile': mobile,
  'message': notes,
  'payment': paymentMethod,  // 'cash' or 'online-payment'
  'include_delivery': includeDelivery,
  'delivery_price': deliveryPrice,
  'round_pickup_date': selectedRoundDate,      // Optional
  'round_pickup_time': selectedRoundTime,      // Optional
  'gateway_type': paymentTypes,
  'gateway_currency': selectedCurrency,
  'token': tokenFromPreview,                   // If available
  'transaction_id': manualTransactionId,       // If manual payment
};
```

---

## 7. COMPLETE CALCULATION EXAMPLE

### Scenario:
- **Car Daily Rate:** 100 SAR
- **Rental Days:** 3
- **Tax Rate:** 15%
- **Delivery Enabled:** Yes (50 SAR)

### Calculation:

```
BACKEND CALCULATES:
─────────────────
rental_fees = 3 days × 100 SAR = 300 SAR
charges = 0 SAR
subtotal = 300 SAR
delivery_price (from API) = 0 SAR (backend doesn't know about custom delivery)
tax_percentage = 15%

API RESPONSE:
{
  "data": {
    "pricing_breakdown": {
      "rental_days": 3,
      "rental_fees": "300.00",
      "delivery_price": "0.00",
      "charges": "0.00",
      "subtotal": "300.00",
      "tax_percentage": 15.0,
      "tax_amount": "45.00",
      "total": "345.00",
      "price_rule_applied": "daily"
    }
  }
}

FRONTEND RECALCULATES (IN _getPreviewALlData):
───────────────────────────────────────────
1. Override delivery price:
   delivery_price = 50.00 SAR (from BookingController)
   
2. Recalculate tax:
   tax = (rental_fees + delivery_price) × tax_percentage ÷ 100
   tax = (300.00 + 50.00) × 15 ÷ 100
   tax = 350.00 × 0.15
   tax = 52.50 SAR
   
3. Calculate total:
   total = rental_fees + delivery_price + tax
   total = 300.00 + 50.00 + 52.50
   total = 402.50 SAR

DISPLAY ON PREVIEW SCREEN:
───────────────────────────
Rental Days:        3
Rental Fees:        300.00 SAR
Delivery:           50.00 SAR
Tax:                52.50 SAR
─────────────────────────────
TOTAL PAYABLE:      402.50 SAR  ← (gradient red box)
```

---

## 8. KEY REACTIVE VARIABLES (Obx)

**Location:** `lib/views/preview/controller/preview_controller.dart`

```dart
// Display values
RxString carModel = ''.obs;
RxString carNumber = ''.obs;
RxString pickupTime = ''.obs;
RxString slug = ''.obs;
RxString Id = ''.obs;

// Calculated values
RxDouble totalPayable = 0.0.obs;              // Final amount
RxString taxAmountDisplay = ''.obs;          // Tax display
RxString cashBalance = ''.obs;               // Unused in modern flow
RxString onlinePayment = ''.obs;             // Unused in modern flow

// Payment method
RxInt selectedMethod = 0.obs;                // 0=cash, 1=online

// Loading state
final _isLoading = true.obs;
final _isBookingLoading = false.obs;
```

All these are wrapped in `Obx()` in the UI to auto-rebuild on change.

---

## 9. SPECIAL CASES

### Case 1: Charges
- **When:** Backend returns charges (e.g., insurance, airport fee)
- **Calculation:** Added to subtotal but **NOT** included in tax calculation
- **Display:** Shown only if > 0

### Case 2: Round Trip Booking
- **When:** User selects return date/time
- **Data:** Stored as `round_pickup_date` and `round_pickup_time`
- **Pricing:** Backend handles different pricing rules (same day return, etc.)
- **Display:** Shows both pickup and return in preview

### Case 3: Delivery Validation
- **When:** `BookingController.dateTimeValidation` returns `isValid=false`
- **Effect:** `forcePickupFromBranch` becomes `true`
- **UI:** Delivery toggle disabled, shows warning banner

### Case 4: Insufficient Wallet Balance
- **Check:** `wallet.balance < totalPayable`
- **UI:** Confirm button disabled, red border on wallet card
- **Action:** User can tap "Recharge Wallet" to top-up

---

## 10. API ENDPOINTS USED

| Endpoint | Method | Purpose | Notes |
|----------|--------|---------|-------|
| `/user/car-booking/preview` | GET | Get pricing breakdown | Uses query params, **NOT** request body |
| `/user/car-booking/confirm` | POST | Confirm & create booking | Uses JSON request body |
| `/user/validate-datetime` | POST | Check if pickup datetime valid | Also validates delivery availability |

---

## 11. DEBUG LOGGING

**In BookingPreviewModel.fromJson():**
```dart
print('🔍 Parsing BookingPreviewModel - Full JSON keys: ${json.keys.toList()}');
print('  - message type: ${json["message"].runtimeType}');
print('  - message value: ${json["message"]}');
```

**In PreviewController._getPreviewALlData():**
```dart
developer.log('Preview data loaded', name: 'preview');
```

---

## 12. SUMMARY

| Step | Who | What | Result |
|------|-----|------|--------|
| 1 | BookingController | Collect form data (car, days, dates, delivery) | Form state ready |
| 2 | PreviewController | Call `/preview` API with query params | PricingBreakdown received |
| 3 | PreviewController | Recalculate tax with delivery override | taxAmountDisplay + totalPayable set |
| 4 | PreviewScreen | Display _PricingCard with Obx reactive data | User sees breakdown |
| 5 | PreviewController | On confirm, call `/confirm` API with body | Booking created |
| 6 | CongratulatoryScreen | Show booking success | Flow complete |

---

## 13. RELATED FILES

- **Booking Form:** [lib/views/booking/screen/booking_mobile_screen.dart](lib/views/booking/screen/booking_mobile_screen.dart)
- **Preview Screen:** [lib/views/preview/screen/preview_mobile_screen.dart](lib/views/preview/screen/preview_mobile_screen.dart)
- **Booking Details:** [lib/views/booking_details/screen/booking_details_screen.dart](lib/views/booking_details/screen/booking_details_screen.dart) — Displays final booked details
- **Models:** [lib/views/preview/model/booking_preview_model.dart](lib/views/preview/model/booking_preview_model.dart)
- **API Endpoint:** [lib/base/api/endpoint/api_endpoint.dart](lib/base/api/endpoint/api_endpoint.dart)
