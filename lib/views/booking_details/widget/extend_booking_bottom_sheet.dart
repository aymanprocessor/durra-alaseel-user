import 'package:carbo/base/api/services/basic_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../base/utils/basic_import.dart';
import '../controller/booking_details_controller.dart';
import '../controller/extend_booking_controller.dart';

class ExtendBookingBottomSheet extends GetView<ExtendBookingController> {
  const ExtendBookingBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final booking = Get.isRegistered<BookingDetailsController>()
        ? Get.find<BookingDetailsController>().booking.value
        : null;

    return Container(
      decoration: BoxDecoration(
        color: CustomColor.whiteColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(Dimensions.radius * 2),
          topRight: Radius.circular(Dimensions.radius * 2),
        ),
      ),
      padding: EdgeInsets.only(
        left: Dimensions.defaultHorizontalSize,
        right: Dimensions.defaultHorizontalSize,
        top: Dimensions.verticalSize * 0.5,
        bottom: bottomInset + Dimensions.verticalSize,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DragHandle(),
            _SheetHeader(),
            SizedBox(height: Dimensions.verticalSize * 0.6),
            if (booking?.roundPickupDate != null)
              _ReadonlyRow(
                label: 'Current End Date',
                value: booking!.roundPickupDate.toString().length >= 10
                    ? booking.roundPickupDate.toString().substring(0, 10)
                    : booking.roundPickupDate.toString(),
              ),
            SizedBox(height: Dimensions.verticalSize * 0.5),
            _DaysInputField(controller: controller),
            SizedBox(height: Dimensions.verticalSize * 0.25),
            _ValidationError(controller: controller),
            SizedBox(height: Dimensions.verticalSize * 0.4),
            _PreviewLoadingIndicator(controller: controller),
            _PreviewResultCard(controller: controller),
            SizedBox(height: Dimensions.verticalSize * 0.6),
            _ConfirmButton(controller: controller),
          ],
        ),
      ),
    );
  }
}

class _DragHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        margin: EdgeInsets.only(bottom: Dimensions.verticalSize * 0.3),
        decoration: BoxDecoration(
          color: CustomColor.disableColor,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextWidget(
          'Extend Rental',
          typographyStyle: TypographyStyle.titleLarge,
          fontWeight: FontWeight.w700,
        ),
        IconButton(
          icon: Icon(Icons.close, color: CustomColor.typography),
          onPressed: () => Get.back(),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }
}

class _ReadonlyRow extends StatelessWidget {
  final String label;
  final String value;

  const _ReadonlyRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.defaultHorizontalSize * 0.75,
        vertical: Dimensions.verticalSize * 0.35,
      ),
      decoration: BoxDecoration(
        color: CustomColor.background,
        borderRadius: BorderRadius.circular(Dimensions.radius * 0.8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextWidget(
            label,
            fontSize: Dimensions.bodySmall,
            color: CustomColor.secondary,
          ),
          TextWidget(
            value,
            fontSize: Dimensions.titleSmall,
            fontWeight: FontWeight.w600,
            color: CustomColor.typography,
          ),
        ],
      ),
    );
  }
}

class _DaysInputField extends StatelessWidget {
  final ExtendBookingController controller;

  const _DaysInputField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextWidget(
          'Extension Days',
          fontSize: Dimensions.titleSmall,
          color: CustomColor.secondary,
          fontWeight: FontWeight.w500,
        ),
        SizedBox(height: Dimensions.verticalSize * 0.2),
        PrimaryInputWidget(
          controller: controller.extensionDaysController,
          hintText: 'e.g. 3',
          textInputType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(3),
          ],
          onChanged: controller.onDaysChanged,
        ),
      ],
    );
  }
}

class _ValidationError extends StatelessWidget {
  final ExtendBookingController controller;

  const _ValidationError({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final error = controller.validationError.value;
      if (error.isEmpty) return const SizedBox.shrink();
      return Padding(
        padding: EdgeInsets.only(top: Dimensions.verticalSize * 0.15),
        child: Row(
          children: [
            Icon(Icons.error_outline,
                size: 14, color: CustomColor.primary),
            SizedBox(width: 4),
            TextWidget(
              error,
              fontSize: Dimensions.bodySmall,
              color: CustomColor.primary,
            ),
          ],
        ),
      );
    });
  }
}

class _PreviewLoadingIndicator extends StatelessWidget {
  final ExtendBookingController controller;

  const _PreviewLoadingIndicator({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!controller.isPreviewLoading.value) return const SizedBox.shrink();
      return Column(
        children: [
          LinearProgressIndicator(
            backgroundColor: CustomColor.tertiary,
            valueColor: AlwaysStoppedAnimation<Color>(CustomColor.primary),
          ),
          SizedBox(height: Dimensions.verticalSize * 0.25),
          TextWidget(
            'Calculating cost...',
            fontSize: Dimensions.bodySmall,
            color: CustomColor.secondary,
          ),
          SizedBox(height: Dimensions.verticalSize * 0.25),
        ],
      );
    });
  }
}

class _PreviewResultCard extends StatelessWidget {
  final ExtendBookingController controller;

  const _PreviewResultCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!controller.isPreviewLoaded.value) return const SizedBox.shrink();

      final preview = controller.previewResult.value;
      if (preview == null) return const SizedBox.shrink();

      final cur = BasicServices.baseCurCode.value;

      return AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: 1.0,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(Dimensions.defaultHorizontalSize * 0.85),
          decoration: BoxDecoration(
            color: CustomColor.primaryColorShadeZero,
            borderRadius: BorderRadius.circular(Dimensions.radius),
            border: Border.all(
              color: CustomColor.primary.withValues(alpha: 0.25),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _previewRow('Extra Days', '${preview.extraDays} day${preview.extraDays == 1 ? '' : 's'}'),
              _divider(),
              _previewRow('New End Date', preview.newEndDate),
              _divider(),
              _previewRow('Daily Rate', '${_fmt(preview.dailyRate)} $cur'),
              _divider(),
              _previewRow('Subtotal', '${_fmt(preview.subtotal)} $cur'),
              _divider(),
              _previewRow('Tax', '${_fmt(preview.tax)} $cur'),
              _divider(),
              _totalRow('Total', '${_fmt(preview.total)} $cur'),
            ],
          ),
        ),
      );
    });
  }

  String _fmt(double val) {
    if (val == val.truncateToDouble()) return val.toInt().toString();
    return val.toStringAsFixed(2);
  }

  Widget _divider() => Divider(
        height: Dimensions.verticalSize * 0.4,
        thickness: 0.5,
        color: CustomColor.primary.withValues(alpha: 0.15),
      );

  Widget _previewRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextWidget(
          label,
          fontSize: Dimensions.bodySmall,
          color: CustomColor.secondary,
        ),
        TextWidget(
          value,
          fontSize: Dimensions.bodySmall,
          fontWeight: FontWeight.w600,
          color: CustomColor.typography,
        ),
      ],
    );
  }

  Widget _totalRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextWidget(
          label,
          fontSize: Dimensions.titleSmall,
          fontWeight: FontWeight.w700,
          color: CustomColor.typography,
        ),
        TextWidget(
          value,
          fontSize: Dimensions.titleSmall,
          fontWeight: FontWeight.w700,
          color: CustomColor.primary,
        ),
      ],
    );
  }
}

class _ConfirmButton extends StatelessWidget {
  final ExtendBookingController controller;

  const _ConfirmButton({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final canConfirm =
          controller.isPreviewLoaded.value && !controller.isConfirming.value;
      final isConfirming = controller.isConfirming.value;

      return SizedBox(
        width: double.infinity,
        child: PrimaryButton(
          title: 'Confirm Extension',
          isLoading: isConfirming,
          disable: !canConfirm,
          buttonColor: canConfirm ? CustomColor.primary : CustomColor.disableColor,
          onPressed: canConfirm ? controller.confirmExtension : () {},
        ),
      );
    });
  }
}
