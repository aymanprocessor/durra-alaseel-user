import 'package:get/get.dart';
import '../../../routes/routes.dart';
import '../../../views/history/controller/history_controller.dart';
import '../../../views/history/model/history_model.dart';
import 'extend_booking_controller.dart';

class BookingDetailsController extends GetxController {
  final Rx<History?> booking = Rx<History?>(null);

  @override
  void onInit() {
    super.onInit();
    booking.value = Get.arguments['booking'] as History?;
  }

  bool get canExtend => booking.value?.status == 2;

  /// Registers [ExtendBookingController] before the screen opens the sheet.
  /// Calling multiple times is safe — registers only once.
  void prepareExtendSheet() {
    final id = booking.value?.id;
    if (id == null) return;
    if (!Get.isRegistered<ExtendBookingController>()) {
      Get.put(ExtendBookingController(id));
    }
  }

  /// Cleans up [ExtendBookingController] after the bottom sheet is closed.
  void disposeExtendSheet() {
    if (Get.isRegistered<ExtendBookingController>()) {
      Get.delete<ExtendBookingController>();
    }
  }

  Future<void> refreshBooking() async {
    if (!Get.isRegistered<HistoryController>()) return;

    final historyController = Get.find<HistoryController>();
    await historyController.getHistoryInfo();

    final updated = historyController.historyList
        .firstWhereOrNull((h) => h.id == booking.value?.id);
    if (updated != null) {
      booking.value = updated;
    }
  }

  void navigateToExtensionHistory() {
    final id = booking.value?.id;
    if (id == null) return;
    Get.toNamed(
      Routes.extensionHistoryScreen,
      arguments: {'bookingId': id},
    );
  }
}
