import 'dart:async';
import 'package:flutter/material.dart';
import '../../../base/api/endpoint/api_endpoint.dart';
import '../../../base/api/method/request_process.dart';
import '../../../base/utils/basic_import.dart';
import '../../../backend/model/extend_confirm_model.dart';
import '../../../backend/model/extend_preview_model.dart';
import 'booking_details_controller.dart';

class ExtendBookingController extends GetxController {
  final int bookingId;

  ExtendBookingController(this.bookingId);

  final TextEditingController extensionDaysController = TextEditingController();

  final RxBool isPreviewLoading = false.obs;
  final RxBool isConfirming = false.obs;
  final RxBool isPreviewLoaded = false.obs;
  final Rx<ExtendPreviewModel?> previewResult = Rx<ExtendPreviewModel?>(null);
  final RxString validationError = ''.obs;

  Timer? _debounce;

  void onDaysChanged(String val) {
    _debounce?.cancel();

    previewResult.value = null;
    isPreviewLoaded.value = false;
    validationError.value = '';

    if (val.isEmpty) return;

    final parsed = int.tryParse(val.trim());
    if (parsed == null || parsed <= 0) {
      validationError.value = 'Extension days must be greater than 0';
      return;
    }

    _debounce = Timer(
      const Duration(milliseconds: 800),
      () => _fetchPreview(parsed),
    );
  }

  Future<void> _fetchPreview(int days) async {
    await RequestProcess().request<ExtendPreviewModel>(
      fromJson: ExtendPreviewModel.fromJson,
      apiEndpoint: ApiEndpoint.extendPreview,
      isLoading: isPreviewLoading,
      method: HttpMethod.GET,
      queryParams: {
        'booking_id': bookingId.toString(),
        'extension_days': days.toString(),
      },
      showErrorMessage: true,
      onSuccess: (value) {
        if (value != null) {
          previewResult.value = value;
          isPreviewLoaded.value = true;
        } else {
          isPreviewLoaded.value = false;
          previewResult.value = null;
        }
      },
      onError: (_) {
        isPreviewLoaded.value = false;
        previewResult.value = null;
      },
    );
  }

  Future<void> confirmExtension() async {
    if (isConfirming.value || !isPreviewLoaded.value) return;

    final daysText = extensionDaysController.text.trim();
    final days = int.tryParse(daysText);
    if (days == null || days <= 0) {
      validationError.value = 'Extension days must be greater than 0';
      return;
    }

    await RequestProcess().request<ExtendConfirmModel>(
      fromJson: ExtendConfirmModel.fromJson,
      apiEndpoint: ApiEndpoint.extendBooking,
      isLoading: isConfirming,
      method: HttpMethod.POST,
      body: {
        'booking_id': bookingId,
        'extension_days': days,
      },
      showSuccessMessage: false,
      showErrorMessage: true,
      onSuccess: (value) {
        Get.back();
        CustomSnackBar.success(
          title: Strings.success,
          message: (value?.message.isNotEmpty == true)
              ? value!.message
              : 'Booking extended successfully',
        );
        if (Get.isRegistered<BookingDetailsController>()) {
          Get.find<BookingDetailsController>().refreshBooking();
        }
      },
      onError: (_) {
        isConfirming.value = false;
      },
    );
  }

  @override
  void onClose() {
    extensionDaysController.dispose();
    _debounce?.cancel();
    super.onClose();
  }
}
