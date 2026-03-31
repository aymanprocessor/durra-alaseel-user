import 'package:carbo/base/api/services/basic_services.dart';
import 'package:flutter/material.dart';
import '../../../base/utils/basic_import.dart';
import '../../../views/history/model/history_model.dart';
import '../controller/booking_details_controller.dart';
import '../widget/extend_booking_bottom_sheet.dart';

class BookingDetailsScreen extends GetView<BookingDetailsController> {
  const BookingDetailsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColor.background,
      appBar: _buildAppBar(context),
      body: Obx(() {
        final booking = controller.booking.value;
        if (booking == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return _BookingDetailsBody(
          booking: booking,
          controller: controller,
        );
      }),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: CustomColor.whiteColor,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new_rounded,
            color: CustomColor.typography, size: 20),
        onPressed: () => Get.back(),
      ),
      title: Obx(() {
        final carModel = controller.booking.value?.cars.carModel?.toString();
        return TextWidget(
          carModel ?? 'Booking Details',
          typographyStyle: TypographyStyle.titleMedium,
          fontWeight: FontWeight.w700,
        );
      }),
      centerTitle: true,
    );
  }
}

class _BookingDetailsBody extends StatelessWidget {
  final History booking;
  final BookingDetailsController controller;

  const _BookingDetailsBody({
    required this.booking,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.defaultHorizontalSize,
        vertical: Dimensions.verticalSize * 0.5,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CarImageCard(booking: booking),
          SizedBox(height: Dimensions.verticalSize * 0.5),
          _StatusBadge(status: booking.status),
          SizedBox(height: Dimensions.verticalSize * 0.5),
          _InfoCard(booking: booking),
          SizedBox(height: Dimensions.verticalSize * 0.5),
          if (booking.status == 2) _NearCompletionWarning(booking: booking),
          SizedBox(height: Dimensions.verticalSize * 0.5),
          Obx(() => controller.canExtend
              ? _ExtendRentalButton(controller: controller)
              : const SizedBox.shrink()),
          SizedBox(height: Dimensions.verticalSize * 0.3),
          _ExtensionHistoryLink(controller: controller),
          SizedBox(height: Dimensions.verticalSize),
        ],
      ),
    );
  }
}

class _CarImageCard extends StatelessWidget {
  final History booking;

  const _CarImageCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    final imageUrl = booking.cars.imageUrl;
    return ClipRRect(
      borderRadius: BorderRadius.circular(Dimensions.radius),
      child: SizedBox(
        height: 200,
        width: double.infinity,
        child: imageUrl.isNotEmpty
            ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _placeholder(),
                loadingBuilder: (_, child, progress) {
                  if (progress == null) return child;
                  return _placeholder();
                },
              )
            : _placeholder(),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: CustomColor.tertiary,
      child: Icon(Icons.directions_car_outlined,
          size: 64, color: CustomColor.disableColor),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final int status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final Color color;
    final String label;

    switch (status) {
      case 1:
        color = Colors.orange;
        label = Strings.pending;
        break;
      case 2:
        color = Colors.blue;
        label = Strings.ongoing;
        break;
      case 3:
        color = CustomColor.primary;
        label = Strings.complete;
        break;
      default:
        color = CustomColor.rejected;
        label = Strings.reject;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.defaultHorizontalSize * 0.75,
        vertical: Dimensions.verticalSize * 0.2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(Dimensions.radius * 2),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(radius: 4, backgroundColor: color),
          SizedBox(width: 6),
          TextWidget(
            label.tr,
            fontSize: Dimensions.bodySmall,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final History booking;

  const _InfoCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    final curCode = BasicServices.baseCurCode.value;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: CustomColor.whiteColor,
        borderRadius: BorderRadius.circular(Dimensions.radius),
        boxShadow: [
          BoxShadow(
            color: CustomColor.blackColor.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.defaultHorizontalSize,
        vertical: Dimensions.verticalSize * 0.5,
      ),
      child: Column(
        children: [
          _infoRow(Strings.PickUpLocation, booking.location),
          _divider(),
          _infoRow(Strings.destination,
              booking.destination.isNotEmpty ? booking.destination : '—'),
          _divider(),
          _infoRow(
            Strings.PickUpdate,
            booking.pickupDate.toString().substring(0, 10),
          ),
          _divider(),
          _infoRow(Strings.PickUpTime, booking.pickupTime),
          if (booking.roundPickupDate != null) ...[
            _divider(),
            _infoRow('End Date', booking.roundPickupDate.toString().length >= 10
                ? booking.roundPickupDate.toString().substring(0, 10)
                : booking.roundPickupDate.toString()),
          ],
          _divider(),
          _infoRow(
            Strings.totalAmount,
            '${booking.totalAmount ?? 0} $curCode',
          ),
          _divider(),
          _infoRow('Payment', booking.paymentType),
          _divider(),
          _infoRow(
            Strings.status,
            booking.status == 1
                ? Strings.pending.tr
                : booking.status == 2
                    ? Strings.ongoing.tr
                    : booking.status == 3
                        ? Strings.complete.tr
                        : Strings.reject.tr,
          ),
          if (booking.message.isNotEmpty) ...[
            _divider(),
            _infoRow(Strings.note, booking.message),
          ],
        ],
      ),
    );
  }

  Widget _divider() => Divider(
        height: 1,
        thickness: 0.5,
        color: CustomColor.tertiary,
      );

  Widget _infoRow(String title, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: Dimensions.verticalSize * 0.3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: TextWidget(
              title.tr,
              fontSize: Dimensions.titleSmall,
              color: CustomColor.secondary,
            ),
          ),
          SizedBox(width: Dimensions.defaultHorizontalSize * 0.5),
          Expanded(
            child: TextWidget(
              value,
              fontSize: Dimensions.titleSmall,
              fontWeight: FontWeight.w600,
              color: CustomColor.typography,
              textAlign: TextAlign.end,
              maxLines: 3,
              textOverflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _NearCompletionWarning extends StatelessWidget {
  final History booking;

  const _NearCompletionWarning({required this.booking});

  @override
  Widget build(BuildContext context) {
    // Show warning if end date (roundPickupDate) is within 24 hours
    final endDateRaw = booking.roundPickupDate;
    if (endDateRaw == null) return const SizedBox.shrink();

    final endDate = DateTime.tryParse(endDateRaw.toString());
    if (endDate == null) return const SizedBox.shrink();

    final hoursLeft = endDate.difference(DateTime.now()).inHours;
    if (hoursLeft > 24) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Dimensions.defaultHorizontalSize * 0.75),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(Dimensions.radius * 0.8),
        border: Border.all(color: Colors.amber.shade300),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded,
              color: Colors.amber.shade700, size: 20),
          SizedBox(width: 8),
          Expanded(
            child: TextWidget(
              'Your booking ends in $hoursLeft hour${hoursLeft == 1 ? '' : 's'}. Consider extending now.',
              fontSize: Dimensions.bodySmall,
              color: Colors.amber.shade800,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExtendRentalButton extends StatelessWidget {
  final BookingDetailsController controller;

  const _ExtendRentalButton({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: PrimaryButton(
        title: 'Extend Rental',
        onPressed: () => _openExtendSheet(context),
      ),
    );
  }

  void _openExtendSheet(BuildContext context) {
    controller.prepareExtendSheet();
    Get.bottomSheet(
      const ExtendBookingBottomSheet(),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      ignoreSafeArea: false,
      enableDrag: true,
    ).then((_) => controller.disposeExtendSheet());
  }
}

class _ExtensionHistoryLink extends StatelessWidget {
  final BookingDetailsController controller;

  const _ExtensionHistoryLink({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: controller.navigateToExtensionHistory,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: Dimensions.verticalSize * 0.25,
            horizontal: Dimensions.defaultHorizontalSize,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.history_outlined,
                  size: 18, color: CustomColor.primary),
              SizedBox(width: 6),
              TextWidget(
                'View Extension History',
                fontSize: Dimensions.titleSmall,
                color: CustomColor.primary,
                fontWeight: FontWeight.w600,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
